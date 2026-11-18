#!/usr/bin/env node
/**
 * Builds edopro/deck-ids.json: for each card code only the EDOPro card
 * databases use, the code the same card has in the client's own card pool.
 *
 * A deck built in EDOPro can hold codes the client has never seen: an
 * unreleased card under EDOPro's temporary number, an alternate artwork, a
 * pre-errata or anime version filed as a copy of the real card. The client
 * shows such a card as an empty frame and the YGOPro server rejects the deck.
 * This file tells the client which of its own cards is meant, so it can
 * convert the deck when it is imported or opened.
 *
 * A code is given an entry only when the card it stands for is unmistakable:
 *
 * - a copy (a card with an `alias`) becomes the card it copies, when the
 *   client has that one or it can itself be resolved;
 * - any other card printed in the OCG or the TCG is paired by what it is: the
 *   English names are equal, the type, ATK and DEF are equal, and exactly one
 *   card of the client qualifies. The client's released cards are tried
 *   first, then its unreleased ones.
 *
 * Everything else is left out and stays unknown to the client: anime, video
 * game and skill cards, which can share a name with a real card and play
 * differently; tokens; and Rush Duel cards, whose pool the client numbers
 * separately. A code the client's released pool already has needs no entry.
 *
 * The EDOPro databases are a directory of .cdb files, a checkout of
 * ProjectIgnis/BabelCDB, merged in file name order with a later file replacing
 * the rows of an earlier one. mirror-edopro-prompts.yml runs this daily.
 *
 * Usage:
 *   node scripts/build-edopro-deck-ids.mjs --databases <dir> [--base cdb/base.en.cdb.gz] \
 *     [--prerelease cdb/prerelease.en.cdb.gz] [--out edopro/deck-ids.json]
 */
import { existsSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

import { withPlainDatabase } from "./build-edopro-cards.mjs";
import { readCards, readEdoproCards } from "./build-edopro-prerelease-ids.mjs";
import { listDatabases } from "./build-edopro-prompts.mjs";

export function parseArgs(argv) {
	const opts = {
		databases: null,
		base: "cdb/base.en.cdb.gz",
		prerelease: "cdb/prerelease.en.cdb.gz",
		out: "edopro/deck-ids.json",
	};
	const keys = { "--databases": "databases", "--base": "base", "--prerelease": "prerelease", "--out": "out" };
	for (let i = 0; i < argv.length; i += 2) {
		const key = keys[argv[i]];
		if (!key || argv[i + 1] === undefined) throw new Error(`unknown or incomplete option: ${argv[i]}`);
		opts[key] = argv[i + 1];
	}
	if (!opts.databases) throw new Error("--databases <dir> is required");
	return opts;
}

/** The `ot` bits of a card printed in the OCG or the TCG, released or not. */
const SCOPE_OFFICIAL = 0x3;
/** The `ot` bit of a Rush Duel card. */
const SCOPE_RUSH = 0x200;
const TYPE_TOKEN = 0x4000;
/** A chain of copies longer than this is a loop in the data, not a card. */
const MAX_ALIAS_HOPS = 4;

const nameKey = (name) => name.trim().toLowerCase();

/** The originals (cards that copy no other) of a pool, by name. */
function originalsByName(cards) {
	const byName = new Map();
	for (const card of cards) {
		if (card.alias !== 0 || nameKey(card.name) === "") continue;
		const key = nameKey(card.name);
		if (!byName.has(key)) byName.set(key, []);
		byName.get(key).push(card);
	}
	return byName;
}

/** The one card of `byName` that is `card`, or null when none or several are. */
function sameCard(card, byName) {
	const same = (byName.get(nameKey(card.name)) ?? []).filter(
		(candidate) => candidate.type === card.type && candidate.atk === card.atk && candidate.def === card.def,
	);
	return same.length === 1 ? same[0].id : null;
}

/**
 * Maps each EDOPro code the client's released pool lacks to the client's code
 * for the same card. `base` and `prerelease` are the client's released and
 * unreleased cards. Returns a Map of EDOPro code to client code, in code order.
 */
export function mapDeckIds(edoproCards, base, prerelease) {
	const baseIds = new Set(base.map((card) => card.id));
	const baseByName = originalsByName(base);
	const prereleaseByName = originalsByName(prerelease);

	const resolve = (card, hops) => {
		if (baseIds.has(card.id)) return card.id;
		if ((card.ot & SCOPE_RUSH) !== 0 || (card.type & TYPE_TOKEN) !== 0) return null;
		if (card.alias !== 0) {
			if (baseIds.has(card.alias)) return card.alias;
			const original = edoproCards.get(card.alias);
			return original && hops < MAX_ALIAS_HOPS ? resolve(original, hops + 1) : null;
		}
		if ((card.ot & SCOPE_OFFICIAL) === 0) return null;
		return sameCard(card, baseByName) ?? sameCard(card, prereleaseByName);
	};

	const ids = new Map();
	for (const card of [...edoproCards.values()].sort((a, b) => a.id - b.id)) {
		if (baseIds.has(card.id)) continue;
		const ours = resolve(card, 0);
		if (ours !== null && ours !== card.id) ids.set(card.id, ours);
	}
	return ids;
}

export function renderDeckIds(ids) {
	const entries = {};
	for (const [from, to] of ids) entries[String(from)] = to;
	return `${JSON.stringify({ version: 1, ids: entries }, null, "\t")}\n`;
}

function main() {
	const opts = parseArgs(process.argv.slice(2));
	const paths = listDatabases(opts.databases);
	if (paths.length === 0) throw new Error(`no .cdb files in ${opts.databases}`);
	for (const pool of [opts.base, opts.prerelease]) {
		if (!existsSync(pool)) throw new Error(`card database not found: ${pool}`);
	}
	const base = withPlainDatabase(opts.base, readCards);
	const prerelease = withPlainDatabase(opts.prerelease, readCards);
	const ids = mapDeckIds(readEdoproCards(paths), base, prerelease);
	writeFileSync(opts.out, renderDeckIds(ids));
	process.stdout.write(`${opts.out}: ${ids.size} EDOPro codes mapped to the client's card pool\n`);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) main();

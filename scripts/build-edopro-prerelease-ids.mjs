#!/usr/bin/env node
/**
 * Builds edopro/prerelease-ids.json: for each unreleased card of the YGOPro
 * card pool, the code the same card has in the EDOPro card databases.
 *
 * A card that has no passcode yet gets a temporary number, and the two
 * ecosystems number it independently. A deck built against the YGOPro pool
 * holds a code a room run by the EDOPro core has never seen, so the room
 * rejects the deck. This file tells the server which EDOPro card is meant.
 *
 * Nothing but the card itself links the two numbers, so a pair is made only
 * when it is unmistakable: the English names are equal, the type, ATK and DEF
 * are equal, and exactly one EDOPro card printed in the OCG or the TCG
 * qualifies. A card with no such
 * counterpart is left out, and the room goes on reporting it as unknown.
 * A card whose code EDOPro already knows needs no entry.
 *
 * The EDOPro databases are a directory of .cdb files, a checkout of
 * ProjectIgnis/BabelCDB, merged in file name order with a later file replacing
 * the rows of an earlier one. mirror-edopro-prompts.yml runs this daily.
 *
 * Usage:
 *   node scripts/build-edopro-prerelease-ids.mjs --databases <dir> [--prerelease cdb/prerelease.en.cdb.gz] [--out edopro/prerelease-ids.json]
 */
import { existsSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { DatabaseSync } from "node:sqlite";

import { withPlainDatabase } from "./build-edopro-cards.mjs";
import { listDatabases } from "./build-edopro-prompts.mjs";

export function parseArgs(argv) {
	const opts = { databases: null, prerelease: "cdb/prerelease.en.cdb.gz", out: "edopro/prerelease-ids.json" };
	const keys = { "--databases": "databases", "--prerelease": "prerelease", "--out": "out" };
	for (let i = 0; i < argv.length; i += 2) {
		const key = keys[argv[i]];
		if (!key || argv[i + 1] === undefined) throw new Error(`unknown or incomplete option: ${argv[i]}`);
		opts[key] = argv[i + 1];
	}
	if (!opts.databases) throw new Error("--databases <dir> is required");
	return opts;
}

const CARD_QUERY = "SELECT datas.id AS id, ot, alias, type, atk, def, name FROM datas JOIN texts ON datas.id = texts.id";

/** The `ot` bits of a card printed in the OCG or the TCG, released or not. */
const SCOPE_OFFICIAL = 0x3;

/** The cards of one database as { id, ot, alias, type, atk, def, name }. */
function readCards(path) {
	const db = new DatabaseSync(path, { readOnly: true });
	try {
		return db.prepare(CARD_QUERY).all().map((row) => ({
			id: Number(row.id),
			ot: Number(row.ot ?? 0),
			alias: Number(row.alias ?? 0),
			type: Number(row.type ?? 0),
			atk: Number(row.atk ?? 0),
			def: Number(row.def ?? 0),
			name: String(row.name ?? ""),
		}));
	} finally {
		db.close();
	}
}

/** The cards of every database in `paths`, by code; a later file wins. */
export function readEdoproCards(paths) {
	const cards = new Map();
	for (const path of paths) {
		for (const card of readCards(path)) cards.set(card.id, card);
	}
	return cards;
}

const nameKey = (name) => name.trim().toLowerCase();

/**
 * Pairs each of `prerelease` with its EDOPro counterpart. Returns the pairs as
 * a Map of YGOPro code to EDOPro code, in code order.
 */
export function pairPrereleaseIds(prerelease, edoproCards) {
	const byName = new Map();
	for (const card of edoproCards.values()) {
		// An alternate artwork carries the name of its original; only the
		// original is a card a deck can be resolved to. EDOPro also files anime,
		// video game and skill cards, which can share a name with a real card
		// and play differently.
		if (card.alias !== 0 || (card.ot & SCOPE_OFFICIAL) === 0 || nameKey(card.name) === "") continue;
		const key = nameKey(card.name);
		if (!byName.has(key)) byName.set(key, []);
		byName.get(key).push(card);
	}
	const pairs = new Map();
	for (const card of [...prerelease].sort((a, b) => a.id - b.id)) {
		if (edoproCards.has(card.id)) continue;
		const same = (byName.get(nameKey(card.name)) ?? []).filter(
			(candidate) => candidate.type === card.type && candidate.atk === card.atk && candidate.def === card.def,
		);
		if (same.length === 1) pairs.set(card.id, same[0].id);
	}
	return pairs;
}

export function renderPrereleaseIds(pairs) {
	const ids = {};
	for (const [from, to] of pairs) ids[String(from)] = to;
	return `${JSON.stringify({ version: 1, ids }, null, "\t")}\n`;
}

function main() {
	const opts = parseArgs(process.argv.slice(2));
	const paths = listDatabases(opts.databases);
	if (paths.length === 0) throw new Error(`no .cdb files in ${opts.databases}`);
	if (!existsSync(opts.prerelease)) throw new Error(`prerelease database not found: ${opts.prerelease}`);
	const prerelease = withPlainDatabase(opts.prerelease, readCards);
	const pairs = pairPrereleaseIds(prerelease, readEdoproCards(paths));
	writeFileSync(opts.out, renderPrereleaseIds(pairs));
	process.stdout.write(`${opts.out}: ${pairs.size} of ${prerelease.length} prerelease cards paired\n`);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) main();

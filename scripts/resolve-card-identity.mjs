// The repo's own card database is the identity authority for point lists:
// `datas.alias` states outright when a printing is alternate art of a base
// card, which a name-resolving API cannot always tell apart. See
// odd/tasks/genesys-cdb-identity-validation.md for the audit that motivated
// this and the decisions below.

import { execFileSync } from "node:child_process";
import { gunzipSync } from "node:zlib";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

function sqlite(dbPath, sql) {
	return execFileSync("sqlite3", [dbPath, sql], { encoding: "utf8" });
}

/**
 * Reads `(id, alias)` pairs from a card database and returns them as a
 * `Map<number, number>`. An alias of 0 means the row is itself a base card;
 * a non-zero alias names the base card's id. Accepts either a raw `.cdb` or a
 * gzip-compressed one (decompressed to a scratch file under `os.tmpdir()` and
 * cleaned up before returning). Throws on any failure — the caller decides
 * the fallback.
 *
 * @param {string} cdbPath
 * @returns {Map<number, number>}
 */
export function readCardIdentity(cdbPath) {
	if (!cdbPath.endsWith(".gz")) {
		return queryIdentity(cdbPath);
	}

	const workDir = mkdtempSync(join(tmpdir(), "card-identity-"));
	const rawPath = join(workDir, "db.cdb");

	try {
		writeFileSync(rawPath, gunzipSync(readFileSync(cdbPath)));

		return queryIdentity(rawPath);
	} finally {
		rmSync(workDir, { recursive: true, force: true });
	}
}

function queryIdentity(dbPath) {
	const output = sqlite(dbPath, "SELECT id, alias FROM datas;");
	const identity = new Map();

	for (const line of output.split("\n")) {
		if (line === "") {
			continue;
		}

		const [id, alias] = line.split("|");
		identity.set(Number(id), Number(alias));
	}

	return identity;
}

/**
 * Corrects a card list against the database's identity map. Pure: takes no
 * database dependency, so every rule is testable without one.
 *
 * - A code with a non-zero alias is alternate art: its `code` is rewritten to
 *   the base code and the rewrite is reported in `corrections`.
 * - A code absent from `identity` is left unchanged and reported in
 *   `unknown` — absence means the database mirror has not caught up yet, not
 *   that the code is wrong.
 * - A correction whose target code already exists elsewhere in the list is
 *   dropped instead of applied, and reported in `dropped`: the entry that
 *   already carries the base code wins, regardless of which entry appears
 *   first in `cards`.
 *
 * Never mutates `cards` or its elements.
 *
 * @param {Array<{ code: number, points: number, name: string, sourceUrl?: string }>} cards
 * @param {Map<number, number>} identity
 * @returns {{
 *   cards: Array<{ code: number, points: number, name: string, sourceUrl?: string }>,
 *   corrections: Array<{ from: number, to: number, name: string }>,
 *   unknown: Array<{ code: number, name: string }>,
 *   dropped: Array<{ from: number, to: number, name: string }>,
 * }}
 */
export function correctCardIdentities(cards, identity) {
	// Pre-existing base codes are collected up front so a target collision is
	// judged against the list's original codes, not against corrections
	// applied earlier in the same pass — that is what makes the winner
	// independent of array order.
	const existingCodes = new Set(cards.map((card) => card.code));

	const corrected = [];
	const corrections = [];
	const unknown = [];
	const dropped = [];

	for (const card of cards) {
		const alias = identity.get(card.code);

		if (alias === undefined) {
			unknown.push({ code: card.code, name: card.name });
			corrected.push(card);
			continue;
		}

		if (alias === 0) {
			corrected.push(card);
			continue;
		}

		if (existingCodes.has(alias)) {
			dropped.push({ from: card.code, to: alias, name: card.name });
			continue;
		}

		corrections.push({ from: card.code, to: alias, name: card.name });
		corrected.push({ ...card, code: alias });
	}

	return { cards: corrected, corrections, unknown, dropped };
}

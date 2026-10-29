#!/usr/bin/env node
/**
 * Writes cdb/alternates.json, the map from a card's original passcode to the ids of its
 * alternates: cdb rows whose `alias` points at that passcode (pre-errata versions, alternate
 * artworks). Consumers use it to swap a card a ban list does not allow for an alternate the
 * list does allow, e.g. an Edison deck's Armory Arm 29071332 for its pre-errata 910003009.
 *
 * Reads every uncompressed cdb in cdb/. The `.gz` copies are the same databases, and the base
 * databases are only published compressed, so their alternate artworks are not listed.
 *
 * Usage:
 *   node scripts/build-card-alternates.mjs          rewrite cdb/alternates.json
 *   node scripts/build-card-alternates.mjs --check  exit 1 when the map is out of date
 */
import { execFileSync } from "node:child_process";
import { readdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const CDB_DIR = join(dirname(fileURLToPath(import.meta.url)), "..", "cdb");
const OUTPUT_FILE = "alternates.json";

const byNumber = (a, b) => a - b;

/** The uncompressed cdb paths in `dir`, sorted by name. */
export function listCdbs(dir = CDB_DIR) {
	return readdirSync(dir)
		.filter((name) => name.endsWith(".cdb"))
		.sort((a, b) => a.localeCompare(b, "en"))
		.map((name) => join(dir, name));
}

/** The `[id, alias]` pairs of the rows in `cdbPath` that are alternates of another card. */
export function readAliasRows(cdbPath) {
	const out = execFileSync(
		"sqlite3",
		["-readonly", cdbPath, "SELECT id || ' ' || alias FROM datas WHERE alias != 0 AND alias != id;"],
		{ encoding: "utf8" },
	);
	return out
		.split("\n")
		.filter(Boolean)
		.map((line) => line.split(" ").map(Number));
}

/** Map of original passcode → sorted, distinct alternate ids, across every cdb in `cdbPaths`. */
export function collectAlternates(cdbPaths, readRows = readAliasRows) {
	const alternates = new Map();
	for (const path of cdbPaths) {
		for (const [id, alias] of readRows(path)) {
			if (!alternates.has(alias)) alternates.set(alias, new Set());
			alternates.get(alias).add(id);
		}
	}
	return new Map(
		[...alternates.keys()].sort(byNumber).map((alias) => [alias, [...alternates.get(alias)].sort(byNumber)]),
	);
}

/** The alternates document for this map; ids are written as strings, like ydk passcodes. */
export function renderAlternates(alternates) {
	const body = {};
	for (const [alias, ids] of alternates) body[String(alias)] = ids.map(String);
	return `${JSON.stringify({ version: 1, alternates: body }, null, "\t")}\n`;
}

function main() {
	const alternates = collectAlternates(listCdbs());
	const expected = renderAlternates(alternates);
	const path = join(CDB_DIR, OUTPUT_FILE);
	if (process.argv.includes("--check")) {
		let current = "";
		try {
			current = readFileSync(path, "utf8");
		} catch {}
		if (current !== expected) {
			console.error("cdb/alternates.json is out of date: run `npm run card-alternates`.");
			process.exit(1);
		}
		console.log("cdb/alternates.json is up to date.");
		return;
	}
	writeFileSync(path, expected);
	console.log(`cdb/alternates.json: ${alternates.size} cards with alternates.`);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) main();

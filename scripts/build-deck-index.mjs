#!/usr/bin/env node
/**
 * Writes decks/index.json, the list of deck templates the web client offers.
 *
 * The client reads this file from raw.githubusercontent.com, which follows `main` within
 * minutes; jsDelivr's directory listing for `@main` can stay stale for a long time.
 *
 * Usage:
 *   node scripts/build-deck-index.mjs          rewrite decks/index.json
 *   node scripts/build-deck-index.mjs --check  exit 1 when the index is out of date
 */
import { readdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const DECKS_DIR = join(dirname(fileURLToPath(import.meta.url)), "..", "decks");
const INDEX_FILE = "index.json";

/** The template file names in `dir`, sorted, as the index lists them. */
export function listTemplates(dir = DECKS_DIR) {
	return readdirSync(dir)
		.filter((name) => name.toLowerCase().endsWith(".ydk"))
		.sort((a, b) => a.localeCompare(b, "en"));
}

/** The index document for these file names. */
export function renderIndex(files) {
	return `${JSON.stringify({ version: 1, decks: files }, null, "\t")}\n`;
}

function main() {
	const expected = renderIndex(listTemplates());
	const path = join(DECKS_DIR, INDEX_FILE);
	if (process.argv.includes("--check")) {
		let current = "";
		try {
			current = readFileSync(path, "utf8");
		} catch {}
		if (current !== expected) {
			console.error("decks/index.json is out of date: run `npm run deck-index`.");
			process.exit(1);
		}
		console.log("decks/index.json is up to date.");
		return;
	}
	writeFileSync(path, expected);
	console.log(`decks/index.json: ${listTemplates().length} templates.`);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) main();

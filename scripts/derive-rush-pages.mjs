// Derives rush/pages.json — ygopro card id → Yugipedia page title — for every
// card in the three Rush cdbs. The cdbs only know the Chinese card name, so the
// bridge to Yugipedia goes through print codes: rush/sets.md turns an id into
// candidate codes (scripts/rush-sets.mjs), and the Set Card Lists wikitext of
// each set says which code was actually printed and what card it names.
//
// The wikitext lives in a pre-fetched setpages.json (page title → raw wikitext)
// passed as a directory argument, because deriving must not hit the network.
// Codes are globally unique across all Set Card Lists pages, so one merged
// code → title index resolves every candidate without consulting set names.
//
// An id whose candidates match zero printed codes, or more than one, stays out
// of the map and is reported instead — a wrong title is worse than a gap.

import { execFileSync } from "node:child_process";
import { readFileSync, writeFileSync } from "node:fs";

import { parseSetBlocks, printCodeCandidates } from "./rush-sets.mjs";

const RUSH_CDBS = ["rush/RD Standard.cdb", "rush/RD Patch.cdb", "rush/RD Alternate.cdb"];

/**
 * Parse one Set Card Lists wikitext page into `{ 'RD/DK01-JP001': 'Seiyaryu (Rush Duel)' }`.
 *
 * Card lines sit between a `{{Set list|...|` opener and its `}}` closer, one
 * per line, as `;`-separated fields: code; name; [rarity]; [print]; [qty] —
 * trailing fields optional and sometimes empty. Only `RD/` codes are Rush
 * cards; mixed pages also list OCG prints under bare codes.
 *
 * The name field needs three repairs to become a page title: a
 * `// description :: (...)` annotation after the fields goes, a ` [L]`/` [R]`
 * artwork-piece marker goes (both pieces are the same card page), and
 * invisible left-to-right marks pasted in from the wiki editor go. A
 * parenthesised disambiguation like `(Rush Duel)` stays — it IS the title.
 */
export function parseSetLists(text) {
	const map = {};
	let inList = false;

	for (const raw of text.split("\n")) {
		const line = raw.trim();
		if (line.startsWith("{{Set list")) {
			inList = true;
			continue;
		}
		if (inList && line.startsWith("}}")) {
			inList = false;
			continue;
		}
		if (!inList || line === "") continue;

		const fields = line.split("//")[0].split(";");
		const code = fields[0].trim();
		if (!code.startsWith("RD/")) continue;

		const title = (fields[1] ?? "")
			.replace(/\u200e/g, "")
			.trim()
			.replace(/\s*\[[LR]\]$/, "");
		if (title) map[code] = title;
	}

	return map;
}

/** Merge every fetched page into one code → title index. */
export function buildCodeIndex(pagesByTitle) {
	const index = {};
	for (const text of Object.values(pagesByTitle)) {
		Object.assign(index, parseSetLists(text));
	}
	return index;
}

/**
 * Map each card id to its page title. A block naming several sets yields
 * several candidate codes; the printed one wins because only it exists in the
 * index. Zero or multiple printed candidates leave the id unresolved.
 */
export function resolvePages(ids, blocks, index) {
	const pages = {};
	const noCandidate = [];
	const ambiguous = [];

	for (const id of ids) {
		const printed = printCodeCandidates(id, blocks).filter((code) => code in index);
		if (printed.length === 1) pages[id] = index[printed[0]];
		else if (printed.length === 0) noCandidate.push(String(id));
		else ambiguous.push(String(id));
	}

	return { pages, noCandidate, ambiguous };
}

/** Serialize with ids ascending and a trailing newline — same bytes every run. */
export function renderPagesJson(pages) {
	const sorted = {};
	for (const id of Object.keys(pages).sort((a, b) => Number(a) - Number(b))) {
		sorted[id] = pages[id];
	}
	return `${JSON.stringify(sorted, null, 2)}\n`;
}

// Ids are disjoint across the three cdbs, so a plain concat is the union.
function rushCardIds() {
	const ids = [];
	for (const cdb of RUSH_CDBS) {
		const out = execFileSync("sqlite3", [cdb, "SELECT id FROM datas ORDER BY id;"], {
			encoding: "utf8",
		});
		ids.push(...out.trim().split("\n"));
	}
	return ids;
}

function main() {
	const [dataDir] = process.argv.slice(2);
	if (!dataDir) {
		console.error("usage: node scripts/derive-rush-pages.mjs <dataDir with setpages.json>");
		process.exit(1);
	}

	const ids = rushCardIds();
	const blocks = parseSetBlocks(readFileSync("rush/sets.md", "utf8"));
	const index = buildCodeIndex(JSON.parse(readFileSync(`${dataDir}/setpages.json`, "utf8")));
	const { pages, noCandidate, ambiguous } = resolvePages(ids, blocks, index);

	writeFileSync("rush/pages.json", renderPagesJson(pages));

	// Soft check only: yugipedia.json is a partial SMW dump, so a title missing
	// there is a warning, not a failure.
	const known = JSON.parse(readFileSync(`${dataDir}/yugipedia.json`, "utf8"));
	const unknown = [...new Set(Object.values(pages).filter((title) => !(title in known)))];

	console.error(`ids: ${ids.length}`);
	console.error(`resolved: ${Object.keys(pages).length}`);
	console.error(`unresolved (no candidate): ${noCandidate.length}`);
	console.error(`unresolved (ambiguous): ${ambiguous.length}`);
	if (noCandidate.length) console.error(`  no candidate: ${noCandidate.join(", ")}`);
	if (ambiguous.length) console.error(`  ambiguous: ${ambiguous.join(", ")}`);
	console.error(`titles not in yugipedia.json (soft): ${unknown.length}`);
	if (unknown.length) for (const title of unknown) console.error(`  ? ${title}`);
}

if (process.argv[1]?.endsWith("derive-rush-pages.mjs")) {
	main();
}

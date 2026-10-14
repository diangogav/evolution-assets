// Builds rush/lflist.conf, the Rush ban list the duel server and the client
// both read, out of two sources:
//
//   - rush/mdpro4/Rush_lflist.conf: the official Konami regulation as
//     ElderLich/MDPro4_Data tracks it (forbidden/limited/semi-limited);
//   - rush/lflist.mycard.conf: mycard's list, mirrored verbatim. Only its
//     Legend credit system is taken: the `$legend_* 1` group declarations and
//     the `<id> $legend_<kind> 1` member lines that cap a deck at one Legend
//     card per kind. The regulation has no notion of it.
//
// mycard's file lives under its own name so the legend lines survive a run in
// which only MDPro4 moved. A card that is both a Legend and limited keeps both
// lines: they are separate mechanisms and the engine applies both.
//
// The section is published as `!RD` whatever the regulation calls itself: the
// client resolves the Rush room's list by that name (sources.config.ts,
// `sectionHeader: 'RD'`). The regulation's own name stays as a comment.
//
// Every id the result names must exist in the fused Rush cdb — the mycard
// union plus the MDPro4 alternate arts build-rush-cdb.mjs admits — or nothing
// is written. `--verify <rush.cdb.gz>` re-checks the committed list against a
// built database instead of building.

import { execFileSync } from "node:child_process";
import { existsSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { gunzipSync } from "node:zlib";

import { selectAliasRows } from "./build-rush-cdb.mjs";
import { reportFragment } from "./run-report.mjs";

const UNION_CDBS = ["rush/RD Standard.cdb", "rush/RD Patch.cdb", "rush/RD Alternate.cdb"];
const MDPRO4_EN_PATH = "rush/mdpro4/rush_cards.en.cdb";
const REGULATION_PATH = "rush/mdpro4/Rush_lflist.conf";
const MYCARD_PATH = "rush/lflist.mycard.conf";
const OUT_PATH = "rush/lflist.conf";

/** The section name the client and the duel server look the Rush list up by. */
export const RUSH_SECTION = "RD";

const LEGEND_DECLARATION = /^\$(legend_\w+)\s+\d+\s*$/;
const LEGEND_ENTRY = /^(\d+)\s+\$(legend_\w+)\s+\d+\b/;
// Any active entry: a numeric limit or a credit group.
const ENTRY = /^(\d+)\s+(\d+|\$\w+)\b/;

const lines = (text) => text.split(/\r?\n/);

/**
 * mycard's Legend block: the group declarations and the active member lines,
 * in source order. A commented-out member stays out, and a member listed
 * twice is kept once. A member of a group nobody declared would be silently
 * ignored by the engine, so it is refused instead.
 */
export function extractLegendBlock(mycardText) {
	const declarations = [];
	const declared = new Set();
	const entries = [];
	const seen = new Set();
	for (const raw of lines(mycardText)) {
		const line = raw.trim();
		const declaration = LEGEND_DECLARATION.exec(line);
		if (declaration) {
			if (!declared.has(declaration[1])) declarations.push(line);
			declared.add(declaration[1]);
			continue;
		}
		const entry = LEGEND_ENTRY.exec(line);
		if (!entry) continue;
		const key = `${entry[1]} ${entry[2]}`;
		if (seen.has(key)) continue;
		seen.add(key);
		entries.push({ line, id: entry[1], group: entry[2] });
	}
	for (const { id, group } of entries) {
		if (!declared.has(group)) throw new Error(`legend member ${id} names undeclared group $${group}`);
	}
	return { declarations, entries: entries.map(({ line }) => line) };
}

/**
 * The regulation split around its one `!` line: the comment preamble above
 * it, the section name, and the body below it with trailing blanks dropped.
 */
export function splitRegulation(text) {
	const all = lines(text).map((line) => line.trimEnd());
	const headers = all.flatMap((line, index) => (line.startsWith("!") ? [index] : []));
	if (headers.length !== 1) {
		throw new Error(`regulation: expected exactly one "!" section, found ${headers.length}`);
	}
	const [at] = headers;
	const body = all.slice(at + 1);
	while (body.length > 0 && body.at(-1) === "") body.pop();
	return { preamble: all.slice(0, at), name: all[at].slice(1).trim(), body };
}

/** The published list: regulation preamble, the Rush section, legends, then limits. */
export function fuseRushLflist({ regulationText, mycardText }) {
	const { preamble, name, body } = splitRegulation(regulationText);
	const { declarations, entries } = extractLegendBlock(mycardText);
	const legend = declarations.length > 0 ? ["", "#Legend", ...declarations, "", ...entries] : [];
	const out = [
		...preamble,
		`# Regulation: ${name}`,
		`#[${RUSH_SECTION}]`,
		`!${RUSH_SECTION}`,
		...legend,
		...body,
	];
	return `${out.join("\n")}\n`;
}

function activeEntries(text) {
	return lines(text).flatMap((raw) => {
		const match = ENTRY.exec(raw.trim());
		return match ? [{ id: Number(match[1]), limit: match[2] }] : [];
	});
}

/** Every card id an active line names, legend members included, ascending. */
export function listedIds(text) {
	return [...new Set(activeEntries(text).map(({ id }) => id))].sort((a, b) => a - b);
}

/** Listed ids the card database does not carry. */
export function findMissingIds(text, knownIds) {
	return listedIds(text).filter((id) => !knownIds.has(id));
}

/** Entry counts per limit, legend members apart. */
export function countEntries(text) {
	const counts = { forbidden: 0, limited: 0, semiLimited: 0, legend: 0 };
	const key = { 0: "forbidden", 1: "limited", 2: "semiLimited" };
	for (const { limit } of activeEntries(text)) {
		if (limit.startsWith("$")) counts.legend++;
		else if (key[limit]) counts[key[limit]]++;
	}
	return counts;
}

/** The ids of the fused Rush cdb, derived the way build-rush-cdb.mjs admits them. */
export function fusedCardIds({ unionIds, mdpro4Rows }) {
	const union = new Set(unionIds);
	return new Set([...union, ...selectAliasRows(mdpro4Rows, union).map(({ id }) => id)]);
}

export function buildLflistFragment(counts, regulation, changed) {
	return { step: "build-lflist", status: changed ? "changed" : "unchanged", regulation, counts };
}

// Whole-table JSON reads outgrow execFileSync's 1 MiB default buffer.
const SQLITE_MAX_BUFFER = 256 * 1024 * 1024;

function sqliteJson(path, sql) {
	return JSON.parse(
		execFileSync("sqlite3", ["-readonly", path, sql], { encoding: "utf8", maxBuffer: SQLITE_MAX_BUFFER }).trim(),
	);
}

const readIds = (path) => sqliteJson(path, "SELECT json_group_array(id) FROM datas;");

function requireFiles(paths) {
	// sqlite3 would create an empty db for a missing path and every id would
	// then read as missing; say what is actually wrong instead.
	const missing = paths.filter((path) => !existsSync(path));
	if (missing.length > 0) {
		console.error(`aborted, ${OUT_PATH} untouched: missing ${missing.join(", ")}`);
		process.exit(1);
	}
}

function failOnMissing(missing, against) {
	if (missing.length === 0) return;
	console.error(
		`${OUT_PATH} names ${missing.length} ids absent from ${against}: ${missing.slice(0, 20).join(", ")}`,
	);
	process.exit(1);
}

function verify(gzPath) {
	requireFiles([OUT_PATH, gzPath]);
	const workDir = mkdtempSync(join(tmpdir(), "rush-lflist-"));
	try {
		const raw = join(workDir, "rush.cdb");
		writeFileSync(raw, gunzipSync(readFileSync(gzPath)));
		failOnMissing(findMissingIds(readFileSync(OUT_PATH, "utf8"), new Set(readIds(raw))), gzPath);
	} finally {
		rmSync(workDir, { recursive: true, force: true });
	}
	console.error(`${OUT_PATH}: every listed id exists in ${gzPath}`);
}

function build() {
	requireFiles([REGULATION_PATH, MYCARD_PATH, MDPRO4_EN_PATH, ...UNION_CDBS]);
	const regulationText = readFileSync(REGULATION_PATH, "utf8");
	const fused = fuseRushLflist({ regulationText, mycardText: readFileSync(MYCARD_PATH, "utf8") });

	const known = fusedCardIds({
		unionIds: UNION_CDBS.flatMap(readIds),
		mdpro4Rows: sqliteJson(MDPRO4_EN_PATH, "SELECT json_group_array(json_object('id',id,'ot',ot,'alias',alias)) FROM datas;"),
	});
	failOnMissing(findMissingIds(fused, known), "the fused Rush card pool");

	const changed = !existsSync(OUT_PATH) || readFileSync(OUT_PATH, "utf8") !== fused;
	if (changed) writeFileSync(OUT_PATH, fused);

	const counts = countEntries(fused);
	const { name } = splitRegulation(regulationText);
	console.error(
		`${OUT_PATH} ${changed ? "rewritten" : "unchanged"} (${name}): ` +
			`${counts.forbidden} forbidden, ${counts.limited} limited, ${counts.semiLimited} semi-limited, ` +
			`${counts.legend} legend members`,
	);
	reportFragment(process.env, buildLflistFragment(counts, name, changed));
}

function main() {
	const args = process.argv.slice(2);
	if (args[0] === "--verify") {
		if (!args[1]) {
			console.error("usage: node scripts/build-rush-lflist.mjs [--verify <rush.cdb.gz>]");
			process.exit(1);
		}
		verify(args[1]);
		return;
	}
	try {
		build();
	} catch (err) {
		console.error(`aborted, ${OUT_PATH} untouched: ${err.message}`);
		process.exit(1);
	}
}

if (process.argv[1]?.endsWith("build-rush-lflist.mjs")) {
	main();
}

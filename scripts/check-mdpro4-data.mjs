// Refuses a fresh ElderLich/MDPro4_Data snapshot before it replaces the copy
// under rush/mdpro4/. Run by mirror-rush-pack.yml between the shallow clone
// and the copy.
//
// The fused Rush databases take MDPro4's texts and alternate-art rows on top
// of mycard's cards, and build-rush-cdb.mjs trusts that the two describe the
// same mechanics for every id they share. That holds today byte for byte; the
// moment it stops holding, a card would play by one source's numbers and read
// by the other's, so the mirror stops instead of guessing which one is right.
// MDPro4 lacking some mycard ids (the newest sets) is expected and not checked.
//
//   node scripts/check-mdpro4-data.mjs <Data dir> [upstream sha]
//
// <Data dir> is the clone's `Data/` tree; the sha defaults to the clone's HEAD.

import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { existsSync, readFileSync } from "node:fs";
import { dirname, join } from "node:path";

import { reportFragment, sampled } from "./run-report.mjs";

const UNION_CDBS = ["rush/RD Standard.cdb", "rush/RD Patch.cdb", "rush/RD Alternate.cdb"];
const SOURCE_COMMIT_PATH = "rush/mdpro4/SOURCE_COMMIT";

// Candidate path inside Data/ → the committed copy it replaces.
export const MDPRO4_INPUTS = {
	en: { candidate: "locales/en-US/rush_cards.cdb", committed: "rush/mdpro4/rush_cards.en.cdb" },
	es: { candidate: "locales/es-ES/rush_cards.cdb", committed: "rush/mdpro4/rush_cards.es.cdb" },
	lflist: { candidate: "Banlists/Rush_lflist.conf", committed: "rush/mdpro4/Rush_lflist.conf" },
};

const SQLITE_HEADER = Buffer.from("SQLite format 3\0", "latin1");
const REQUIRED_TABLES = ["datas", "texts"];
const MISMATCH_SAMPLE = 10;

/** The `datas` columns that decide how a card plays. */
export const MECHANIC_COLUMNS = ["type", "atk", "def", "level", "race", "attribute", "setcode", "alias"];

/** Whether the bytes open with the SQLite file header (an HTML error page does not). */
export function hasSqliteHeader(bytes) {
	return bytes.length >= SQLITE_HEADER.length && bytes.subarray(0, SQLITE_HEADER.length).equals(SQLITE_HEADER);
}

/**
 * Shared ids whose mechanic columns differ, in id order, each with the columns
 * that moved. Ids only one side carries are not compared.
 */
export function findMechanicMismatches(candidateRows, unionRows) {
	const union = new Map(unionRows.map((row) => [row.id, row]));
	const mismatches = [];
	for (const row of candidateRows) {
		const theirs = union.get(row.id);
		if (!theirs) continue;
		const columns = MECHANIC_COLUMNS.filter((column) => row[column] !== theirs[column]);
		if (columns.length > 0) mismatches.push({ id: row.id, columns });
	}
	return mismatches.sort((a, b) => a.id - b.id);
}

/**
 * A table holding fewer rows than the committed copy means a truncated or
 * reorganised upstream; growth and equality are fine. No committed copy means
 * this is the first mirror and there is nothing to regress from.
 */
export function countRegressions(label, counts, committedCounts) {
	if (!committedCounts) return [];
	return REQUIRED_TABLES.filter((table) => counts[table] < committedCounts[table]).map(
		(table) => `${label}: ${table} has ${counts[table]} rows, fewer than the committed ${committedCounts[table]}`,
	);
}

// An entry line: `<id> <limit>` with an optional comment.
const ENTRY_LINE = /^\d+\s+\d+\b/;

/**
 * The regulation must be a single section with at least one card: the fused
 * ban list republishes that one section under the Rush name.
 */
export function checkLflistShape(text) {
	const lines = text.split(/\r?\n/).map((line) => line.trim());
	const sections = lines.filter((line) => line.startsWith("!")).length;
	const errors = [];
	if (sections !== 1) errors.push(`Rush_lflist.conf: expected exactly one "!" section, found ${sections}`);
	if (!lines.some((line) => ENTRY_LINE.test(line))) errors.push("Rush_lflist.conf: no card entries");
	return errors;
}

const byNumber = (a, b) => a - b;

/** Ids the current snapshot gained and lost against the previous one, ascending. */
export function diffIds(previous, current) {
	const before = new Set(previous);
	const after = new Set(current);
	return {
		added: [...after].filter((id) => !before.has(id)).sort(byNumber),
		removed: [...before].filter((id) => !after.has(id)).sort(byNumber),
	};
}

function mismatchError(label, mismatches) {
	const sample = mismatches
		.slice(0, MISMATCH_SAMPLE)
		.map(({ id, columns }) => `${id} (${columns.join(",")})`)
		.join(", ");
	return (
		`${label}: ${mismatches.length} shared ids differ from the mycard union in ` +
		`${MECHANIC_COLUMNS.join("/")} (first ${MISMATCH_SAMPLE}): ${sample}`
	);
}

/**
 * Pure: every check over an already-read candidate. `cdbs` are the
 * readCandidateCdb results; `committed` maps a cdb label to the committed
 * copy's `{ counts, ids }`, or null when there is none. Returns the error
 * list (empty means the snapshot may replace ours) and the report fragment.
 */
export function evaluateCandidate({
	cdbs,
	committed,
	unionRows,
	lflistText,
	upstreamCommit,
	previousCommit,
	contentChanged,
}) {
	const errors = [];
	for (const cdb of cdbs) {
		if (!cdb.header) {
			errors.push(`${cdb.label}: not a SQLite database`);
			continue;
		}
		const missing = REQUIRED_TABLES.filter((table) => !cdb.tables.includes(table));
		if (missing.length > 0) {
			for (const table of missing) errors.push(`${cdb.label}: missing table ${table}`);
			continue;
		}
		errors.push(...countRegressions(cdb.label, cdb.counts, committed[cdb.label]?.counts));
		const mismatches = findMechanicMismatches(cdb.rows, unionRows);
		if (mismatches.length > 0) errors.push(mismatchError(cdb.label, mismatches));
	}
	errors.push(...checkLflistShape(lflistText));

	// The English cdb is the one whose ids feed the fusion, so it carries the diff.
	const en = cdbs.find((cdb) => cdb.label === "en");
	const { added, removed } = diffIds(committed.en?.ids ?? [], en?.rows.map(({ id }) => id) ?? []);
	const fragment = {
		step: "check-mdpro4",
		status: contentChanged ? "changed" : "unchanged",
		upstreamCommit,
		previousCommit,
		counts: Object.fromEntries(cdbs.map((cdb) => [cdb.label, cdb.counts])),
		idsAdded: sampled(added),
		idsRemoved: sampled(removed),
	};
	return { errors, fragment };
}

// Whole-table JSON reads outgrow execFileSync's 1 MiB default buffer.
const SQLITE_MAX_BUFFER = 256 * 1024 * 1024;

function sqliteJson(path, sql) {
	const out = execFileSync("sqlite3", ["-readonly", path, sql], {
		encoding: "utf8",
		maxBuffer: SQLITE_MAX_BUFFER,
	}).trim();
	return JSON.parse(out === "" ? "null" : out);
}

function mechanicRows(path) {
	const fields = ["id", ...MECHANIC_COLUMNS].map((column) => `'${column}',"${column}"`).join(",");
	return sqliteJson(path, `SELECT json_group_array(json_object(${fields})) FROM (SELECT * FROM datas ORDER BY id);`);
}

/**
 * One cdb as the checks see it. A file without the SQLite header is not
 * opened at all: sqlite3 would either fail or, for a missing path, create one.
 */
export function readCandidateCdb(label, path) {
	const blank = { label, header: false, tables: [], counts: null, rows: [] };
	if (!existsSync(path) || !hasSqliteHeader(readFileSync(path).subarray(0, SQLITE_HEADER.length))) {
		return blank;
	}
	const tables = sqliteJson(
		path,
		"SELECT json_group_array(name) FROM (SELECT name FROM sqlite_master WHERE type='table' ORDER BY name);",
	).filter((name) => REQUIRED_TABLES.includes(name));
	if (tables.length < REQUIRED_TABLES.length) return { ...blank, header: true, tables };
	const counts = sqliteJson(
		path,
		"SELECT json_object('datas',(SELECT count(*) FROM datas),'texts',(SELECT count(*) FROM texts));",
	);
	return { label, header: true, tables, counts, rows: mechanicRows(path) };
}

function sha256(path) {
	return existsSync(path) ? createHash("sha256").update(readFileSync(path)).digest("hex") : null;
}

function upstreamHead(dataDir) {
	return execFileSync("git", ["-C", dirname(dataDir), "rev-parse", "HEAD"], { encoding: "utf8" }).trim();
}

function main() {
	const [dataDir, shaArg] = process.argv.slice(2);
	if (!dataDir) {
		console.error("usage: node scripts/check-mdpro4-data.mjs <Data dir> [upstream sha]");
		process.exit(1);
	}

	const cdbs = ["en", "es"].map((label) => readCandidateCdb(label, join(dataDir, MDPRO4_INPUTS[label].candidate)));
	const committed = Object.fromEntries(
		["en", "es"].map((label) => {
			const cdb = readCandidateCdb(label, MDPRO4_INPUTS[label].committed);
			return [label, cdb.counts ? { counts: cdb.counts, ids: cdb.rows.map(({ id }) => id) } : null];
		}),
	);
	const lflistPath = join(dataDir, MDPRO4_INPUTS.lflist.candidate);
	const contentChanged = Object.values(MDPRO4_INPUTS).some(
		({ candidate, committed: ours }) => sha256(join(dataDir, candidate)) !== sha256(ours),
	);

	const { errors, fragment } = evaluateCandidate({
		cdbs,
		committed,
		unionRows: UNION_CDBS.flatMap(mechanicRows),
		lflistText: existsSync(lflistPath) ? readFileSync(lflistPath, "utf8") : "",
		upstreamCommit: shaArg ?? upstreamHead(dataDir),
		previousCommit: existsSync(SOURCE_COMMIT_PATH) ? readFileSync(SOURCE_COMMIT_PATH, "utf8").trim() : null,
		contentChanged,
	});

	if (errors.length > 0) {
		console.error("refusing the MDPro4 snapshot, rush/mdpro4/ untouched:");
		for (const error of errors) console.error(`  - ${error}`);
		process.exit(1);
	}

	for (const { label, counts } of cdbs) console.error(`${label}: ${counts.datas} datas, ${counts.texts} texts`);
	console.error(
		`MDPro4 ${fragment.upstreamCommit}: ${fragment.idsAdded.count} ids added, ` +
			`${fragment.idsRemoved.count} removed, ${contentChanged ? "content changed" : "content unchanged"}`,
	);
	reportFragment(process.env, fragment);
}

if (process.argv[1]?.endsWith("check-mdpro4-data.mjs")) {
	main();
}

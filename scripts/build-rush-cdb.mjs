// Builds the client-facing unified Rush databases in cdb/ out of the three
// per-origin cdbs mirrored in rush/ (RD Standard + RD Patch + RD Alternate,
// identical `datas`/`texts` schemas). The per-origin files are consumed
// read-only — the game server assembles its card pool from them directly.
//
// Three variants ship, gzipped only (like the prerelease family, no raw
// unified .cdb is kept):
//   rush.cdb.gz    — the plain union, untranslated (zh-CN, as upstream ships).
//   rush.en.cdb.gz — texts.name/desc overridden from rush/translations.json
//                    (`en`/`en_lore`) where non-empty; zh otherwise. Cards the
//                    wiki does not document yet ship in Chinese by design and
//                    pick up English on a later daily run.
//   rush.es.cdb.gz — per-field fallback chain es → en → zh.
// str1..str16 stay untouched in every variant, and `datas` is byte-identical
// across variants (translation only ever UPDATEs texts rows in a file copy).
//
// The en/es variants additionally gain a leading `Maximum ATK <n>` line on the
// Maximum monsters that declare one, sourced from the Chinese original — see
// TYPE_MAXIMUM below.
//
// A card id present in more than one source cdb aborts the run before anything
// is written: precedence between origins is a human decision, not a merge
// default. Output is deterministic — rows are inserted in global id order and
// the gzip carries no mtime/name (gzip -9 -n semantics) — so two runs over the
// same inputs are byte-identical.

import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { copyFileSync, existsSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { basename, join } from "node:path";
import { gzipSync } from "node:zlib";

import { reportFragment } from "./run-report.mjs";

const RUSH_CDBS = ["rush/RD Standard.cdb", "rush/RD Patch.cdb", "rush/RD Alternate.cdb"];
const TRANSLATIONS_PATH = "rush/translations.json";
const OUT_DIR = "cdb";

function sqlite(dbPath, sql) {
	return execFileSync("sqlite3", [dbPath, sql], { encoding: "utf8" });
}

/** Ids that appear in more than one source id list, sorted. */
export function findDuplicateIds(idLists) {
	const seen = new Map();
	for (const ids of idLists) {
		for (const id of ids) seen.set(id, (seen.get(id) ?? 0) + 1);
	}
	return [...seen.entries()]
		.filter(([, count]) => count > 1)
		.map(([id]) => id)
		.sort((a, b) => a - b);
}

/**
 * The name/desc override one translation entry yields for a variant, per
 * field: `en` takes `en`/`en_lore` when non-empty; `es` falls back per field
 * through es → en. A null field keeps the Chinese original.
 */
export function resolveVariantTexts(entry, variant) {
	const pick = (fields) => {
		for (const source of variant === "es" ? ["es", "en"] : ["en"]) {
			const text = entry[fields[source]];
			if (text) return { text, source };
		}
		return null;
	};
	return {
		name: pick({ en: "en", es: "es" }),
		desc: pick({ en: "en_lore", es: "es_lore" }),
	};
}

// --- Maximum ATK ---
//
// A Maximum monster is played as three cards: a centre piece and an [L]/[R]
// pair. MDPro3 draws the centre piece's Maximum ATK box from the DESCRIPTION,
// not from a column: Card.GetRushDescriptionBodyStartIndex looks at the first
// non-empty line of a TYPE_MAXIMUM card and, for a non-Chinese client language,
// accepts it only when it starts with "Maximum ATK" and splits into 2..4
// space-separated parts. It then reads the trailing digits and drops the line
// from the body it renders.
//
// Upstream ships that value only in Chinese, as a `极大攻击 <n>` line, and only
// on the centre pieces. It is NOT the `atk` column — 120150002 has atk 1900 and
// Maximum ATK 3500 — so the Chinese text is the only source there is.
//
// The literal is English in BOTH the en and es variants on purpose: MDPro3
// matches the Spanish client against the same "Maximum ATK" prefix and only
// accepts `极大攻击`/`極大攻擊` when the client language is zh-CN or zh-TW.
const TYPE_MAXIMUM = 0x8000;

// Anchored to the whole line, mirroring the client's own "the line IS the
// declaration" reading: a `极大攻击` mentioned inside a sentence is not one.
const MAXIMUM_ATK_LINE = /^极大攻击\s*(\d+)$/;

/** The Maximum ATK a Chinese desc declares on a line of its own, or null. */
export function parseMaximumAtk(desc) {
	// Chinese descs are CRLF-terminated; translated lore is LF.
	for (const line of (desc ?? "").split(/\r?\n/)) {
		const match = MAXIMUM_ATK_LINE.exec(line.trim());
		if (match) return Number(match[1]);
	}
	return null;
}

/**
 * Whether a Maximum card is an [L]/[R] half. Upstream names them with FULLWIDTH
 * brackets (U+FF3B/U+FF3D), never the ASCII pair.
 */
export function isMaximumSidePiece(name) {
	return (name ?? "").includes("［L］") || (name ?? "").includes("［R］");
}

/**
 * Sorts the TYPE_MAXIMUM rows into the centre pieces that declare a value, the
 * [L]/[R] halves, and the centre pieces that declare none. The last bucket is
 * reported rather than guessed at: a centre piece that renames itself to a half
 * in hand legitimately has no box to draw, and inventing a value would draw one.
 */
export function classifyMaximumRows(rows) {
	const withValue = [];
	const sidePieces = [];
	const centreWithoutValue = [];

	for (const { id, name, desc } of [...rows].sort((a, b) => a.id - b.id)) {
		if (isMaximumSidePiece(name)) {
			sidePieces.push(id);
			continue;
		}
		const atk = parseMaximumAtk(desc);
		if (atk === null) centreWithoutValue.push(id);
		else withValue.push({ id, atk });
	}

	return { withValue, sidePieces, centreWithoutValue };
}

/**
 * UPDATEs that put the English line first in `desc`. Prepended, never inserted
 * after a print code: MDPro3 skips the first line only for zh-CN/zh-TW, so a
 * print code carried into en/es would show up as visible body text.
 */
export function buildMaximumAtkUpdates(withValue) {
	return withValue
		.map(
			({ id, atk }) =>
				`UPDATE texts SET "desc"=${sqlQuote(`Maximum ATK ${atk}`)} || char(10) || "desc" ` +
				`WHERE id=${id};`,
		)
		.join("\n");
}

// SQL single-quote escaping — the sqlite3 CLI has no parameter binding.
function sqlQuote(text) {
	return `'${text.replaceAll("'", "''")}'`;
}

/**
 * UPDATE script + per-source counts for one variant, restricted to ids the
 * merged db actually ships — translation rows for cards we don't ship are
 * silently dropped, never added.
 */
export function buildVariantUpdates(translations, variant, presentIds) {
	const stats =
		variant === "es"
			? { name: { es: 0, en: 0 }, desc: { es: 0, en: 0 } }
			: { name: { en: 0 }, desc: { en: 0 } };
	const statements = [];

	for (const [id, entry] of Object.entries(translations)) {
		if (!presentIds.has(Number(id))) continue;
		const { name, desc } = resolveVariantTexts(entry, variant);
		const sets = [];
		if (name) {
			sets.push(`name=${sqlQuote(name.text)}`);
			stats.name[name.source]++;
		}
		if (desc) {
			sets.push(`"desc"=${sqlQuote(desc.text)}`);
			stats.desc[desc.source]++;
		}
		if (sets.length > 0) statements.push(`UPDATE texts SET ${sets.join(",")} WHERE id=${id};`);
	}

	return { sql: statements.join("\n"), stats };
}

// The TYPE_MAXIMUM texts rows, as JSON — descs are multi-line, which the CLI's
// default row format cannot round-trip.
function readMaximumRows(cdbPath) {
	const out = sqlite(
		cdbPath,
		"SELECT json_group_array(json_object('id',id,'name',name,'desc',\"desc\")) FROM " +
			`(SELECT t.id, t.name, t."desc" FROM datas d JOIN texts t ON t.id=d.id ` +
			`WHERE d.type & ${TYPE_MAXIMUM});`,
	).trim();
	return JSON.parse(out);
}

function readIds(cdbPath) {
	const out = sqlite(cdbPath, "SELECT id FROM datas ORDER BY id;").trim();
	return out === "" ? [] : out.split("\n").map(Number);
}

// Deterministic gzip of a raw cdb: node's zlib writes a zero mtime and no
// name, matching the `gzip -9 -n` the other cdb pipelines use.
function gzipTo(rawPath, gzPath) {
	writeFileSync(gzPath, gzipSync(readFileSync(rawPath), { level: 9 }));
}

/**
 * Merge the source cdbs into workDir and gzip the three variants into outDir.
 * Throws before anything lands in outDir when a card id appears in more than
 * one source. Returns the merge and per-variant translation stats.
 */
export function buildRushCdbs({ sources, translations, outDir, workDir }) {
	const idLists = sources.map(readIds);
	const duplicates = findDuplicateIds(idLists);
	if (duplicates.length > 0) {
		throw new Error(
			`duplicate card ids across source cdbs (precedence needs a human decision): ${duplicates.join(", ")}`,
		);
	}

	// Seed the schema from the first source, then insert the union in global id
	// order — insert order fixes the page layout, so output bytes are stable.
	const rawPath = join(workDir, "rush.cdb");
	const schema = execFileSync("sqlite3", [sources[0], ".schema"], { encoding: "utf8" });
	execFileSync("sqlite3", [rawPath], { input: schema, encoding: "utf8" });

	const attaches = sources.map((src, i) => `ATTACH ${sqlQuote(src)} AS s${i};`).join("");
	const union = (table) => sources.map((_, i) => `SELECT * FROM s${i}.${table}`).join(" UNION ALL ");
	// Plain INSERT (never OR REPLACE): a conflict the id pre-check missed must
	// still abort, not silently pick a winner.
	sqlite(
		rawPath,
		attaches +
			`INSERT INTO datas SELECT * FROM (${union("datas")}) ORDER BY id;` +
			`INSERT INTO texts SELECT * FROM (${union("texts")}) ORDER BY id;`,
	);

	const presentIds = new Set(idLists.flat());
	// Read off the merged Chinese db: the value only ever exists there, and both
	// translated variants take the same 30-odd ids from it.
	const maximumAtk = classifyMaximumRows(readMaximumRows(rawPath));
	const maximumSql = buildMaximumAtkUpdates(maximumAtk.withValue);

	const variants = {};
	for (const variant of ["en", "es"]) {
		const variantPath = join(workDir, `rush.${variant}.cdb`);
		copyFileSync(rawPath, variantPath);
		const { sql, stats } = buildVariantUpdates(translations, variant, presentIds);
		// Translation first: it REPLACES `desc`, so a line prepended before it would
		// be overwritten on every card the wiki documents.
		const script = [sql, maximumSql].filter((part) => part !== "").join("\n");
		if (script !== "") {
			execFileSync("sqlite3", [variantPath], {
				input: `BEGIN;\n${script}\nCOMMIT;\n`,
				encoding: "utf8",
			});
		}
		variants[variant] = stats;
	}

	gzipTo(rawPath, join(outDir, "rush.cdb.gz"));
	gzipTo(join(workDir, "rush.en.cdb"), join(outDir, "rush.en.cdb.gz"));
	gzipTo(join(workDir, "rush.es.cdb"), join(outDir, "rush.es.cdb.gz"));

	return {
		merged: {
			perSource: sources.map((src, i) => ({ name: basename(src), rows: idLists[i].length })),
			total: presentIds.size,
		},
		variants,
		maximumAtk: {
			withValue: maximumAtk.withValue.length,
			sidePieces: maximumAtk.sidePieces.length,
			centreWithoutValue: maximumAtk.centreWithoutValue,
		},
	};
}

/**
 * The run-report fragment for this step. The builder always rewrites the
 * gzips, so `changed` is decided by the caller from their bytes: a digest
 * taken before against one taken after the build.
 */
export function buildCdbFragment(stats, changed) {
	return {
		step: "build-cdb",
		status: changed ? "changed" : "unchanged",
		merged: stats.merged,
		variants: stats.variants,
		maximumAtk: stats.maximumAtk,
	};
}

// sha256 per published gz, null before the first build — the before/after
// pair decides the fragment's changed/unchanged verdict.
function gzDigests() {
	const digests = {};
	for (const name of ["rush.cdb.gz", "rush.en.cdb.gz", "rush.es.cdb.gz"]) {
		const path = join(OUT_DIR, name);
		digests[path] = existsSync(path)
			? createHash("sha256").update(readFileSync(path)).digest("hex")
			: null;
	}
	return digests;
}

function main() {
	const translations = JSON.parse(readFileSync(TRANSLATIONS_PATH, "utf8"));
	const workDir = mkdtempSync(join(tmpdir(), "rush-cdb-"));
	const before = gzDigests();

	let stats;
	try {
		stats = buildRushCdbs({ sources: RUSH_CDBS, translations, outDir: OUT_DIR, workDir });
	} catch (err) {
		console.error(`aborted, ${OUT_DIR}/ untouched: ${err.message}`);
		process.exit(1);
	} finally {
		rmSync(workDir, { recursive: true, force: true });
	}

	for (const { name, rows } of stats.merged.perSource) console.error(`merged ${name}: ${rows} rows`);
	console.error(`total: ${stats.merged.total} rows`);
	const { en, es } = stats.variants;
	console.error(`en: ${en.name.en} names, ${en.desc.en} descs translated`);
	console.error(
		`es: ${es.name.es} names (+${es.name.en} en fallback), ` +
			`${es.desc.es} descs (+${es.desc.en} en fallback)`,
	);

	const { withValue, sidePieces, centreWithoutValue } = stats.maximumAtk;
	console.error(
		`Maximum ATK: ${withValue} lines added to en/es ` +
			`(${sidePieces} [L]/[R] halves, ${centreWithoutValue.length} centre pieces declare none)`,
	);

	const changed = JSON.stringify(gzDigests()) !== JSON.stringify(before);
	reportFragment(process.env, buildCdbFragment(stats, changed));
}

if (process.argv[1]?.endsWith("build-rush-cdb.mjs")) {
	main();
}

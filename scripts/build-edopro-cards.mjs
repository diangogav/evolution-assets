#!/usr/bin/env node
/**
 * Builds edopro/cards.cdb: the cards of the EDOPro card databases that the
 * client's own base database does not have.
 *
 * A room run by the EDOPro core puts EDOPro's card codes on the wire. Most are
 * the official passcodes both sides share, but EDOPro also files its own
 * codes: pre-errata copies, alternate artworks, unreleased cards under a
 * temporary number. A client that reads only its own database cannot name
 * such a card or show its text. This file gives it the card as the room
 * plays it.
 *
 * The output has the layout of any card database (`datas` and `texts`), so
 * the client opens it with the reader it already has. Each row keeps its
 * `alias`, which is how the client finds the artwork of the original. The
 * prompts (texts.str1..str16) are left empty: those are published for every
 * card in edopro/prompts.cdb.
 *
 * The EDOPro databases are a directory of .cdb files, a checkout of
 * ProjectIgnis/BabelCDB, merged the way the server merges them: in file name
 * order, a later file replacing the rows of an earlier one. The known
 * database is the client's base one; only that one is subtracted, because the
 * other pools a client composes on top of it differ from one duel to the next.
 * mirror-edopro-prompts.yml runs this daily.
 *
 * Usage:
 *   node scripts/build-edopro-cards.mjs --databases <dir> [--known cdb/base.en.cdb.gz] [--out edopro/cards.cdb]
 *
 * The client downloads the gzip next to it:
 *   gzip -9 -n -k -f edopro/cards.cdb
 */
import { existsSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { gunzipSync } from "node:zlib";
import { DatabaseSync } from "node:sqlite";

import { STR_COLUMNS, listDatabases } from "./build-edopro-prompts.mjs";

const DATA_COLUMNS = ["id", "ot", "alias", "setcode", "type", "atk", "def", "level", "race", "attribute", "category"];

export function parseArgs(argv) {
	const opts = { databases: null, known: "cdb/base.en.cdb.gz", out: "edopro/cards.cdb" };
	const keys = { "--databases": "databases", "--known": "known", "--out": "out" };
	for (let i = 0; i < argv.length; i += 2) {
		const key = keys[argv[i]];
		if (!key || argv[i + 1] === undefined) throw new Error(`unknown or incomplete option: ${argv[i]}`);
		opts[key] = argv[i + 1];
	}
	if (!opts.databases) throw new Error("--databases <dir> is required");
	return opts;
}

const quoted = (path) => `'${path.replaceAll("'", "''")}'`;

/**
 * Writes to `outPath` the cards of `paths` that `knownPath` does not define,
 * and returns how many there are. A card defined in several files keeps the
 * row of the last one.
 */
export function writeForeignCards(paths, knownPath, outPath) {
	if (existsSync(outPath)) rmSync(outPath);
	const out = new DatabaseSync(outPath);
	try {
		out.exec(`CREATE TABLE datas (${DATA_COLUMNS.map((c) => `${c} INTEGER${c === "id" ? " PRIMARY KEY" : " NOT NULL"}`).join(", ")})`);
		out.exec(`CREATE TABLE texts (id INTEGER PRIMARY KEY, name TEXT NOT NULL, desc TEXT NOT NULL, ${STR_COLUMNS.map((c) => `${c} TEXT NOT NULL`).join(", ")})`);
		for (const path of paths) {
			out.exec(`ATTACH DATABASE ${quoted(path)} AS source`);
			out.exec(`INSERT OR REPLACE INTO datas SELECT ${DATA_COLUMNS.map((c) => `coalesce(${c}, 0)`).join(", ")} FROM source.datas`);
			out.exec(`INSERT OR REPLACE INTO texts SELECT id, coalesce(name, ''), coalesce(desc, ''), ${STR_COLUMNS.map(() => "''").join(", ")} FROM source.texts`);
			out.exec("DETACH DATABASE source");
		}
		out.exec(`ATTACH DATABASE ${quoted(knownPath)} AS known`);
		out.exec("DELETE FROM datas WHERE id IN (SELECT id FROM known.datas)");
		out.exec("DETACH DATABASE known");
		// A card needs both rows to be read; a half-defined one is left out.
		out.exec("DELETE FROM datas WHERE id NOT IN (SELECT id FROM texts)");
		out.exec("DELETE FROM texts WHERE id NOT IN (SELECT id FROM datas)");
		out.exec("VACUUM");
		return Number(out.prepare("SELECT count(*) AS total FROM datas").get().total);
	} finally {
		out.close();
	}
}

/** Runs `use` with the path of `path` as a plain database, unpacking a .gz. */
export function withPlainDatabase(path, use) {
	if (!path.endsWith(".gz")) return use(path);
	const directory = mkdtempSync(join(tmpdir(), "edopro-cards-"));
	try {
		const plain = join(directory, "known.cdb");
		writeFileSync(plain, gunzipSync(readFileSync(path)));
		return use(plain);
	} finally {
		rmSync(directory, { recursive: true, force: true });
	}
}

function main() {
	const opts = parseArgs(process.argv.slice(2));
	const paths = listDatabases(opts.databases);
	if (paths.length === 0) throw new Error(`no .cdb files in ${opts.databases}`);
	if (!existsSync(opts.known)) throw new Error(`known database not found: ${opts.known}`);
	const total = withPlainDatabase(opts.known, (known) => writeForeignCards(paths, known, opts.out));
	process.stdout.write(`${opts.out}: ${total} cards from ${paths.length} databases that ${opts.known} lacks\n`);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) main();

#!/usr/bin/env node
/**
 * Builds edopro/prompts.cdb: the duel-time prompt strings of the EDOPro
 * card databases, and nothing else.
 *
 * A card script names its prompts by position (`aux.Stringid(id, n)` reads
 * texts.str<n+1>), and the EDOPro and YGOPro databases number the prompts of
 * the same card independently. A client that plays in a room run by the
 * EDOPro core while reading its own YGOPro database shows the wrong label
 * for an option. This file gives it the labels the running scripts mean.
 *
 * The output has one table, `texts (id, str1..str16)`, with a row for every
 * card that has at least one prompt. Names, lore and stats are left out: the
 * client keeps reading those from its own database.
 *
 * The input is the directory of .cdb files the server loads for EDOPro
 * rooms. They are merged the way the server merges them: in file name order,
 * a later file replacing the rows of an earlier one.
 *
 * Usage:
 *   node scripts/build-edopro-prompts.mjs --databases <dir> [--out edopro/prompts.cdb]
 *
 * The client downloads the gzip next to it:
 *   gzip -9 -n -k -f edopro/prompts.cdb
 */
import { existsSync, readdirSync, rmSync } from "node:fs";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { DatabaseSync } from "node:sqlite";

export const STR_COLUMNS = Array.from({ length: 16 }, (_, i) => `str${i + 1}`);

export function parseArgs(argv) {
	const opts = { databases: null, out: "edopro/prompts.cdb" };
	const keys = { "--databases": "databases", "--out": "out" };
	for (let i = 0; i < argv.length; i += 2) {
		const key = keys[argv[i]];
		if (!key || argv[i + 1] === undefined) throw new Error(`unknown or incomplete option: ${argv[i]}`);
		opts[key] = argv[i + 1];
	}
	if (!opts.databases) throw new Error("--databases <dir> is required");
	return opts;
}

/** The .cdb files of a directory, in the order they are merged. */
export function listDatabases(directory) {
	return readdirSync(directory)
		.filter((file) => file.endsWith(".cdb"))
		.sort()
		.map((file) => join(directory, file));
}

/**
 * Reads the prompts of every card across `paths`. A card defined in several
 * files keeps the row of the last one, even when that row has no prompts.
 */
export function collectPrompts(paths) {
	const prompts = new Map();
	for (const path of paths) {
		const db = new DatabaseSync(path, { readOnly: true });
		try {
			for (const row of db.prepare(`SELECT id, ${STR_COLUMNS.join(", ")} FROM texts`).iterate()) {
				prompts.set(Number(row.id), STR_COLUMNS.map((column) => (row[column] ?? "").trim()));
			}
		} finally {
			db.close();
		}
	}
	for (const [id, strings] of prompts) {
		if (strings.every((text) => text === "")) prompts.delete(id);
	}
	return prompts;
}

export function writePrompts(prompts, outPath) {
	if (existsSync(outPath)) rmSync(outPath);
	const out = new DatabaseSync(outPath);
	try {
		out.exec(`CREATE TABLE texts (id INTEGER PRIMARY KEY, ${STR_COLUMNS.map((c) => `${c} TEXT NOT NULL`).join(", ")})`);
		const put = out.prepare(`INSERT INTO texts (id, ${STR_COLUMNS.join(", ")}) VALUES (?, ${STR_COLUMNS.map(() => "?").join(", ")})`);
		out.exec("BEGIN");
		for (const id of [...prompts.keys()].sort((a, b) => a - b)) put.run(id, ...prompts.get(id));
		out.exec("COMMIT");
		out.exec("VACUUM");
	} finally {
		out.close();
	}
}

function main() {
	const opts = parseArgs(process.argv.slice(2));
	const paths = listDatabases(opts.databases);
	if (paths.length === 0) throw new Error(`no .cdb files in ${opts.databases}`);
	const prompts = collectPrompts(paths);
	writePrompts(prompts, opts.out);
	process.stdout.write(`${opts.out}: prompts of ${prompts.size} cards from ${paths.length} databases\n`);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) main();

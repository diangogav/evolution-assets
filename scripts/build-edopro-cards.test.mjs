import assert from "node:assert/strict";
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { gzipSync } from "node:zlib";
import { DatabaseSync } from "node:sqlite";

import { parseArgs, withPlainDatabase, writeForeignCards } from "./build-edopro-cards.mjs";
import { STR_COLUMNS, listDatabases } from "./build-edopro-prompts.mjs";

/** A card database in the layout of the EDOPro ones; `cards` are [id, alias, name, prompt]. */
function makeCdb(path, cards, { texts = true } = {}) {
	const db = new DatabaseSync(path);
	db.exec("CREATE TABLE datas (id INTEGER PRIMARY KEY, ot INTEGER, alias INTEGER, setcode INTEGER, type INTEGER, atk INTEGER, def INTEGER, level INTEGER, race INTEGER, attribute INTEGER, category INTEGER)");
	db.exec(`CREATE TABLE texts (id INTEGER PRIMARY KEY, name TEXT, desc TEXT, ${STR_COLUMNS.map((c) => `${c} TEXT`).join(", ")})`);
	const data = db.prepare("INSERT INTO datas VALUES (?, 3, ?, 0, 33, 2800, 2400, 10, 8192, 32, 0)");
	const text = db.prepare(`INSERT INTO texts (id, name, desc, ${STR_COLUMNS.join(", ")}) VALUES (?, ?, ?, ?, ${STR_COLUMNS.slice(1).map(() => "''").join(", ")})`);
	for (const [id, alias, name, prompt] of cards) {
		data.run(id, alias);
		if (texts) text.run(id, name, `lore of ${name}`, prompt ?? "");
	}
	db.close();
}

/**
 * Builds the output from EDOPro `sources` ({ fileName: cards }) and the cards
 * the client already knows, and returns the cards it holds.
 */
function build(sources, known) {
	const directory = mkdtempSync(join(tmpdir(), "edopro-cards-test-"));
	try {
		const sourcesDirectory = join(directory, "sources");
		mkdirSync(sourcesDirectory);
		for (const [name, cards] of Object.entries(sources)) makeCdb(join(sourcesDirectory, name), cards);
		const knownPath = join(directory, "known.cdb");
		makeCdb(knownPath, known);
		const out = join(directory, "out.cdb");
		const total = writeForeignCards(listDatabases(sourcesDirectory), knownPath, out);
		const db = new DatabaseSync(out, { readOnly: true });
		const rows = db
			.prepare("SELECT datas.id, alias, atk, name, desc, str1 FROM datas JOIN texts ON datas.id = texts.id ORDER BY datas.id")
			.all()
			.map((row) => ({ ...row }));
		db.close();
		return { total, rows };
	} finally {
		rmSync(directory, { recursive: true, force: true });
	}
}

test("parseArgs requires the databases directory and defaults the rest", () => {
	assert.throws(() => parseArgs([]), /--databases/);
	assert.deepEqual(parseArgs(["--databases", "dbs"]), {
		databases: "dbs",
		known: "cdb/base.en.cdb.gz",
		out: "edopro/cards.cdb",
	});
	assert.throws(() => parseArgs(["--databases", "dbs", "--nope", "x"]), /unknown or incomplete/);
});

test("keeps only the cards the known database lacks, with their stats, text and alias", () => {
	const { total, rows } = build(
		{
			"cards.cdb": [
				[88264978, 0, "Red-Eyes Darkness Metal Dragon"],
				[88264988, 88264978, "Red-Eyes Darkness Metal Dragon (Pre-Errata)"],
			],
		},
		[[88264978, 0, "Red-Eyes Darkness Metal Dragon"]],
	);
	assert.equal(total, 1);
	assert.deepEqual(rows, [
		{
			id: 88264988,
			alias: 88264978,
			atk: 2800,
			name: "Red-Eyes Darkness Metal Dragon (Pre-Errata)",
			desc: "lore of Red-Eyes Darkness Metal Dragon (Pre-Errata)",
			str1: "",
		},
	]);
});

test("leaves the prompts out", () => {
	const { rows } = build({ "cards.cdb": [[100, 0, "Card", "Special Summon"]] }, []);
	assert.equal(rows[0].str1, "");
});

test("lets a later database replace the row of an earlier one", () => {
	const { rows } = build(
		{ "a-cards.cdb": [[100, 0, "Old name"]], "b-fixes.cdb": [[100, 0, "New name"]] },
		[],
	);
	assert.deepEqual(rows.map((row) => row.name), ["New name"]);
});

test("leaves out a card that has stats but no text", () => {
	const directory = mkdtempSync(join(tmpdir(), "edopro-cards-test-"));
	try {
		const source = join(directory, "cards.cdb");
		const known = join(directory, "known.cdb");
		makeCdb(source, [[100, 0, "No text"]], { texts: false });
		makeCdb(known, []);
		assert.equal(writeForeignCards([source], known, join(directory, "out.cdb")), 0);
	} finally {
		rmSync(directory, { recursive: true, force: true });
	}
});

test("replaces an old output file", () => {
	const directory = mkdtempSync(join(tmpdir(), "edopro-cards-test-"));
	try {
		const first = join(directory, "first.cdb");
		const second = join(directory, "second.cdb");
		const known = join(directory, "known.cdb");
		const out = join(directory, "out.cdb");
		makeCdb(first, [[999, 0, "Stale"]]);
		makeCdb(second, [[100, 0, "Fresh"]]);
		makeCdb(known, []);
		writeForeignCards([first], known, out);
		assert.equal(writeForeignCards([second], known, out), 1);
		const db = new DatabaseSync(out, { readOnly: true });
		const ids = db.prepare("SELECT id FROM datas").all().map((row) => row.id);
		db.close();
		assert.deepEqual(ids, [100]);
	} finally {
		rmSync(directory, { recursive: true, force: true });
	}
});

test("withPlainDatabase unpacks a gzip and passes a plain file through", () => {
	const directory = mkdtempSync(join(tmpdir(), "edopro-cards-test-"));
	try {
		const plain = join(directory, "known.cdb");
		makeCdb(plain, [[100, 0, "Card"]]);
		const packed = join(directory, "known.cdb.gz");
		writeFileSync(packed, gzipSync(readFileSync(plain)));
		assert.equal(withPlainDatabase(plain, (path) => path), plain);
		const header = withPlainDatabase(packed, (path) => readFileSync(path).subarray(0, 15).toString());
		assert.equal(header, "SQLite format 3");
	} finally {
		rmSync(directory, { recursive: true, force: true });
	}
});

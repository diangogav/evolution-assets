import assert from "node:assert/strict";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { DatabaseSync } from "node:sqlite";

import { STR_COLUMNS, collectPrompts, listDatabases, parseArgs, writePrompts } from "./build-edopro-prompts.mjs";

function makeCdb(path, rows) {
	const db = new DatabaseSync(path);
	db.exec(`CREATE TABLE texts (id INTEGER PRIMARY KEY, name TEXT, desc TEXT, ${STR_COLUMNS.map((c) => `${c} TEXT`).join(", ")})`);
	const put = db.prepare(`INSERT INTO texts (id, name, desc, ${STR_COLUMNS.join(", ")}) VALUES (?, ?, ?, ${STR_COLUMNS.map(() => "?").join(", ")})`);
	for (const [id, strings] of rows) {
		put.run(id, `card ${id}`, "lore", ...STR_COLUMNS.map((_, i) => strings[i] ?? ""));
	}
	db.close();
}

function withDirectory(run) {
	const directory = mkdtempSync(join(tmpdir(), "edopro-prompts-"));
	try {
		return run(directory);
	} finally {
		rmSync(directory, { recursive: true, force: true });
	}
}

test("parseArgs requires the databases directory", () => {
	assert.throws(() => parseArgs([]), /--databases/);
	assert.deepEqual(parseArgs(["--databases", "dbs"]), { databases: "dbs", out: "edopro/prompts.cdb" });
});

test("listDatabases returns only .cdb files, in file name order", () => {
	withDirectory((directory) => {
		makeCdb(join(directory, "cards.cdb"), []);
		makeCdb(join(directory, "a-first.cdb"), []);
		makeCdb(join(directory, "notes.txt"), []);
		assert.deepEqual(listDatabases(directory), [join(directory, "a-first.cdb"), join(directory, "cards.cdb")]);
	});
});

test("collectPrompts keeps each prompt in its own position", () => {
	withDirectory((directory) => {
		makeCdb(join(directory, "cards.cdb"), [[100, ["Activate 1 of these effects", "Special Summon", "", "Take control"]]]);
		const strings = collectPrompts(listDatabases(directory)).get(100);
		assert.equal(strings.length, 16);
		assert.deepEqual(strings.slice(0, 5), ["Activate 1 of these effects", "Special Summon", "", "Take control", ""]);
	});
});

test("collectPrompts leaves out a card with no prompts", () => {
	withDirectory((directory) => {
		makeCdb(join(directory, "cards.cdb"), [[100, ["Draw"]], [200, []]]);
		assert.deepEqual([...collectPrompts(listDatabases(directory)).keys()], [100]);
	});
});

test("collectPrompts lets a later database replace the row of an earlier one", () => {
	withDirectory((directory) => {
		makeCdb(join(directory, "a-cards.cdb"), [[100, ["Draw", "Discard"]], [300, ["Banish"]]]);
		makeCdb(join(directory, "b-fixes.cdb"), [[100, ["Discard"]], [300, []]]);
		const prompts = collectPrompts(listDatabases(directory));
		assert.deepEqual(prompts.get(100).slice(0, 2), ["Discard", ""]);
		assert.equal(prompts.has(300), false);
	});
});

test("writePrompts writes a database holding only ids and prompts, replacing an old file", () => {
	withDirectory((directory) => {
		const out = join(directory, "out.cdb");
		const strings = (first) => STR_COLUMNS.map((_, i) => (i === 0 ? first : ""));
		writePrompts(new Map([[999, strings("stale")]]), out);
		writePrompts(new Map([[200, strings("Destroy")], [100, strings("Draw")]]), out);
		const db = new DatabaseSync(out, { readOnly: true });
		const columns = db.prepare("PRAGMA table_info(texts)").all().map((column) => column.name);
		const rows = db.prepare("SELECT id, str1 FROM texts ORDER BY rowid").all().map((row) => ({ ...row }));
		db.close();
		assert.deepEqual(columns, ["id", ...STR_COLUMNS]);
		assert.deepEqual(rows, [{ id: 100, str1: "Draw" }, { id: 200, str1: "Destroy" }]);
	});
});

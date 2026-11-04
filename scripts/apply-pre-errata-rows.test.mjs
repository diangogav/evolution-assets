import assert from "node:assert/strict";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { DatabaseSync } from "node:sqlite";
import { test } from "node:test";

import { applyRows, parseArgs } from "./apply-pre-errata-rows.mjs";

const SCHEMA = `
CREATE TABLE datas (id INTEGER, ot INTEGER, alias INTEGER, setcode INTEGER, type INTEGER, atk INTEGER, def INTEGER, level INTEGER, race INTEGER, attribute INTEGER, category INTEGER, PRIMARY KEY(id));
CREATE TABLE texts (id INTEGER, name TEXT, desc TEXT, str1 TEXT, str2 TEXT, str3 TEXT, str4 TEXT, str5 TEXT, str6 TEXT, str7 TEXT, str8 TEXT, str9 TEXT, str10 TEXT, str11 TEXT, str12 TEXT, str13 TEXT, str14 TEXT, str15 TEXT, str16 TEXT, PRIMARY KEY(id));
`;

function makeDbs() {
	const dir = mkdtempSync(join(tmpdir(), "pre-errata-rows-"));
	const officialPath = join(dir, "official.cdb");
	const outPath = join(dir, "overlay.cdb");
	const official = new DatabaseSync(officialPath);
	official.exec(SCHEMA);
	official.exec(`INSERT INTO datas VALUES (29401950, 3, 0, 0, 4, 0, 0, 0, 0, 0, 32)`);
	official.exec(`INSERT INTO texts VALUES (29401950, 'Bottomless Trap Hole', 'modern text', 'Hint 1', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '')`);
	official.close();
	const out = new DatabaseSync(outPath);
	out.exec(SCHEMA);
	out.close();
	return { dir, officialPath, outPath };
}

const ROW = { code: 504700052, alias: 29401950, name_en: "Bottomless Trap Hole", name_es: "Agujero Trampa Sin Fondo", desc_en: "2005 text", desc_es: "texto 2005" };

test("writes the official datas under the new code with alias and the era text", () => {
	const { dir, officialPath, outPath } = makeDbs();
	try {
		const applied = applyRows({ rows: [ROW], marker: "GOAT", officialPath, outPath, lang: "en" });
		assert.deepEqual(applied, [{ code: 504700052, name: "Bottomless Trap Hole (GOAT)" }]);
		const db = new DatabaseSync(outPath, { readOnly: true });
		const datas = db.prepare("SELECT * FROM datas WHERE id = ?").get(504700052);
		assert.equal(datas.alias, 29401950);
		assert.equal(datas.type, 4);
		assert.equal(datas.category, 32);
		const texts = db.prepare("SELECT name, desc, str1 FROM texts WHERE id = ?").get(504700052);
		assert.deepEqual({ ...texts }, { name: "Bottomless Trap Hole (GOAT)", desc: "2005 text", str1: "Hint 1" });
		db.close();
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("uses the Spanish name and text for the es overlay and replaces an existing row", () => {
	const { dir, officialPath, outPath } = makeDbs();
	try {
		applyRows({ rows: [ROW], marker: "GOAT", officialPath, outPath, lang: "es" });
		applyRows({ rows: [{ ...ROW, desc_es: "texto corregido" }], marker: "GOAT", officialPath, outPath, lang: "es" });
		const db = new DatabaseSync(outPath, { readOnly: true });
		assert.equal(db.prepare("SELECT COUNT(*) AS n FROM texts").get().n, 1);
		const texts = db.prepare("SELECT name, desc FROM texts WHERE id = ?").get(504700052);
		assert.deepEqual({ ...texts }, { name: "Agujero Trampa Sin Fondo (GOAT)", desc: "texto corregido" });
		db.close();
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("fails without writing when the official card is missing", () => {
	const { dir, officialPath, outPath } = makeDbs();
	try {
		assert.throws(() => applyRows({ rows: [{ ...ROW, alias: 1 }], marker: "GOAT", officialPath, outPath, lang: "en" }), /official card 1/);
		const db = new DatabaseSync(outPath, { readOnly: true });
		assert.equal(db.prepare("SELECT COUNT(*) AS n FROM datas").get().n, 0);
		db.close();
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("parses the options with their defaults", () => {
	assert.equal(parseArgs([]).marker, "GOAT");
	assert.equal(parseArgs(["--marker", "Pre-Errata", "--rows", "x.json"]).rows, "x.json");
	assert.throws(() => parseArgs(["--bogus"]), /unknown/);
});

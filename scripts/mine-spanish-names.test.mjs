import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";

import {
	indexBaseByName,
	mineSpanishTexts,
	readNameLoreRows,
	renderMinedTranslations,
} from "./mine-spanish-names.mjs";

const TEXTS_SCHEMA =
	"CREATE TABLE texts(id integer primary key,name text,desc text,str1 text,str2 text,str3 text," +
	"str4 text,str5 text,str6 text,str7 text,str8 text,str9 text,str10 text,str11 text,str12 text," +
	"str13 text,str14 text,str15 text,str16 text);";

/** A base index over one English row and its Spanish counterpart. */
function index(english, spanish) {
	return indexBaseByName(english, spanish);
}

// --- indexBaseByName + mineSpanishTexts: the name join ---

test("a Rush card whose English name is a base card's gains that card's Spanish name", () => {
	const base = index(
		[{ id: 5, name: "Time Wizard", desc: "Toss a coin." }],
		[{ id: 5, name: "Mago del Tiempo", desc: "Lanza una moneda." }],
	);

	const { entries } = mineSpanishTexts({ 1201: { en: "Time Wizard" } }, base);
	assert.deepEqual(entries, { 1201: { es: "Mago del Tiempo" } });
});

test("a Rush card no base card shares a name with mines nothing", () => {
	const base = index([{ id: 5, name: "Time Wizard", desc: "" }], [{ id: 5, name: "Mago", desc: "" }]);

	const { entries, stats } = mineSpanishTexts({ 1201: { en: "Sevens Road Magician" } }, base);
	assert.deepEqual(entries, {});
	assert.equal(stats.matched, 0);
});

test("a base card that never sold in Spanish yields no name", () => {
	const base = index(
		[{ id: 5, name: "Time Wizard", desc: "Toss a coin." }],
		[{ id: 5, name: "", desc: "" }],
	);

	const { entries, stats } = mineSpanishTexts({ 1201: { en: "Time Wizard" } }, base);
	assert.deepEqual(entries, {});
	assert.equal(stats.matched, 1);
	assert.equal(stats.names, 0);
});

test("a Rush card with no English name of its own cannot be joined", () => {
	const base = index([{ id: 5, name: "Time Wizard", desc: "" }], [{ id: 5, name: "Mago", desc: "" }]);

	assert.deepEqual(mineSpanishTexts({ 1201: { en: "" } }, base).entries, {});
});

test("the join ignores surrounding whitespace and carriage returns on either side", () => {
	const base = index(
		[{ id: 5, name: " Time Wizard\r", desc: "" }],
		[{ id: 5, name: "Mago del Tiempo\r", desc: "" }],
	);

	assert.deepEqual(mineSpanishTexts({ 1201: { en: "Time Wizard " } }, base).entries, {
		1201: { es: "Mago del Tiempo" },
	});
});

test("two base cards sharing an English name but not a Spanish one are too ambiguous to mine", () => {
	const base = index(
		[
			{ id: 5, name: "Time Wizard", desc: "" },
			{ id: 6, name: "Time Wizard", desc: "" },
		],
		[
			{ id: 5, name: "Mago del Tiempo", desc: "" },
			{ id: 6, name: "Hechicero del Tiempo", desc: "" },
		],
	);

	assert.deepEqual(mineSpanishTexts({ 1201: { en: "Time Wizard" } }, base).entries, {});
});

test("reprints of one card agree on its Spanish name, so the name is still mined", () => {
	const base = index(
		[
			{ id: 5, name: "Time Wizard", desc: "" },
			{ id: 6, name: "Time Wizard", desc: "" },
		],
		[
			{ id: 5, name: "Mago del Tiempo", desc: "" },
			{ id: 6, name: "Mago del Tiempo", desc: "" },
		],
	);

	assert.deepEqual(mineSpanishTexts({ 1201: { en: "Time Wizard" } }, base).entries, {
		1201: { es: "Mago del Tiempo" },
	});
});

// --- the lore rule: same name is not same effect ---

test("lore is copied when the Rush card's English lore is the base card's, byte for byte", () => {
	const base = index(
		[{ id: 5, name: "Thousand Dragon", desc: "Fusion Material." }],
		[{ id: 5, name: "Dragón Milenario", desc: "Material de Fusión." }],
	);

	const { entries, stats } = mineSpanishTexts({ 1201: { en: "Thousand Dragon", en_lore: "Fusion Material." } }, base);
	assert.deepEqual(entries, { 1201: { es: "Dragón Milenario", es_lore: "Material de Fusión." } });
	assert.equal(stats.lore, 1);
	assert.equal(stats.loreRejectedDiffering, 0);
});

test("lore is rejected when the Rush card's effect differs from its classic namesake's", () => {
	const base = index(
		[{ id: 5, name: "Time Wizard", desc: "Toss a coin." }],
		[{ id: 5, name: "Mago del Tiempo", desc: "Lanza una moneda." }],
	);

	const { entries, stats } = mineSpanishTexts(
		{ 1201: { en: "Time Wizard", en_lore: "[REQUIREMENT] Discard 1 card." } },
		base,
	);
	assert.deepEqual(entries, { 1201: { es: "Mago del Tiempo" } });
	assert.equal(stats.lore, 0);
	assert.equal(stats.loreRejectedDiffering, 1);
});

test("lore is rejected when the Rush card has no English lore to compare", () => {
	const base = index(
		[{ id: 5, name: "Time Wizard", desc: "Toss a coin." }],
		[{ id: 5, name: "Mago del Tiempo", desc: "Lanza una moneda." }],
	);

	const { entries, stats } = mineSpanishTexts({ 1201: { en: "Time Wizard", en_lore: "" } }, base);
	assert.deepEqual(entries, { 1201: { es: "Mago del Tiempo" } });
	assert.equal(stats.lore, 0);
	assert.equal(stats.loreWithoutEnglish, 1);
});

test("identical English lore that never sold in Spanish yields no lore", () => {
	const base = index(
		[{ id: 5, name: "Time Wizard", desc: "Toss a coin." }],
		[{ id: 5, name: "Mago del Tiempo", desc: "" }],
	);

	const { entries } = mineSpanishTexts({ 1201: { en: "Time Wizard", en_lore: "Toss a coin." } }, base);
	assert.deepEqual(entries, { 1201: { es: "Mago del Tiempo" } });
});

test("lore matching strips carriage returns so a CRLF desc still counts as identical", () => {
	const base = index(
		[{ id: 5, name: "Time Wizard", desc: "Toss a coin.\r\nWin the flip." }],
		[{ id: 5, name: "Mago del Tiempo", desc: "Lanza una moneda.\r\nGana." }],
	);

	const { entries } = mineSpanishTexts(
		{ 1201: { en: "Time Wizard", en_lore: "Toss a coin.\nWin the flip." } },
		base,
	);
	assert.equal(entries[1201].es_lore, "Lanza una moneda.\nGana.");
});

test("one English lore with two Spanish readings across reprints is too ambiguous to mine", () => {
	const base = index(
		[
			{ id: 5, name: "Time Wizard", desc: "Toss a coin." },
			{ id: 6, name: "Time Wizard", desc: "Toss a coin." },
		],
		[
			{ id: 5, name: "Mago del Tiempo", desc: "Lanza una moneda." },
			{ id: 6, name: "Mago del Tiempo", desc: "Tira una moneda." },
		],
	);

	const { entries } = mineSpanishTexts({ 1201: { en: "Time Wizard", en_lore: "Toss a coin." } }, base);
	assert.deepEqual(entries, { 1201: { es: "Mago del Tiempo" } });
});

// --- cards that already carry their own Spanish ---

test("a field the wiki already translated is left to the wiki and counted as skipped", () => {
	const base = index(
		[{ id: 5, name: "Time Wizard", desc: "Toss a coin." }],
		[{ id: 5, name: "Mago del Tiempo", desc: "Lanza una moneda." }],
	);

	const { entries, stats } = mineSpanishTexts(
		{
			1201: { en: "Time Wizard", en_lore: "Toss a coin.", es: "Brujo del Tiempo" },
			1202: { en: "Time Wizard", en_lore: "Toss a coin.", es_lore: "Echa una moneda." },
		},
		base,
	);

	assert.deepEqual(entries, {
		1201: { es_lore: "Lanza una moneda." },
		1202: { es: "Mago del Tiempo" },
	});
	assert.equal(stats.skippedHadSpanishName, 1);
	assert.equal(stats.skippedHadSpanishLore, 1);
});

test("a card whose Spanish is complete is omitted from the file entirely", () => {
	const base = index(
		[{ id: 5, name: "Time Wizard", desc: "Toss a coin." }],
		[{ id: 5, name: "Mago del Tiempo", desc: "Lanza una moneda." }],
	);

	const { entries } = mineSpanishTexts(
		{ 1201: { en: "Time Wizard", en_lore: "Toss a coin.", es: "Brujo", es_lore: "Echa." } },
		base,
	);
	assert.deepEqual(entries, {});
});

// --- renderMinedTranslations: the artifact text ---

test("renderMinedTranslations sorts ids ascending and ends with a newline", () => {
	const json = renderMinedTranslations({
		120150002: { es: "Dos" },
		1201: { es: "Uno", es_lore: "Lore" },
	});

	assert.equal(
		json,
		'{\n  "1201": {\n    "es": "Uno",\n    "es_lore": "Lore"\n  },\n' +
			'  "120150002": {\n    "es": "Dos"\n  }\n}\n',
	);
});

test("renderMinedTranslations sorts numerically, not by code unit", () => {
	const ids = Object.keys(JSON.parse(renderMinedTranslations({ 90: { es: "b" }, 100: { es: "a" } })));
	assert.deepEqual(ids, ["90", "100"]);
});

test("renderMinedTranslations is deterministic: insertion order does not reach the file", () => {
	const forward = renderMinedTranslations({ 1: { es: "A" }, 2: { es: "B" }, 3: { es: "C" } });
	const backward = renderMinedTranslations({ 3: { es: "C" }, 2: { es: "B" }, 1: { es: "A" } });
	assert.equal(forward, backward);
});

// --- readNameLoreRows: the sqlite read the miner runs over each base cdb ---

test("readNameLoreRows returns id/name/desc in id order, NULL read as empty", () => {
	const dir = mkdtempSync(join(tmpdir(), "mine-spanish-names-"));
	try {
		const path = join(dir, "base.cdb");
		execFileSync("sqlite3", [path], { input: TEXTS_SCHEMA, encoding: "utf8" });
		execFileSync("sqlite3", [
			path,
			"INSERT INTO texts(id,name,\"desc\") VALUES(2,'Time Wizard','Toss a coin.\nWin.');" +
				"INSERT INTO texts(id,name) VALUES(1,'Nameless');",
		]);

		assert.deepEqual(readNameLoreRows(path), [
			{ id: 1, name: "Nameless", desc: "" },
			{ id: 2, name: "Time Wizard", desc: "Toss a coin.\nWin." },
		]);
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

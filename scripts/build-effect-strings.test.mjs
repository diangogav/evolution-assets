import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";

import {
	MIN_ATTESTING_CARDS,
	mineTerms,
	pairStrings,
	readStrRows,
	renderEffectStrings,
} from "./build-effect-strings.mjs";

const STR_SCHEMA =
	"CREATE TABLE texts(id integer primary key,name text,desc text,str1 text,str2 text,str3 text," +
	"str4 text,str5 text,str6 text,str7 text,str8 text,str9 text,str10 text,str11 text,str12 text," +
	"str13 text,str14 text,str15 text,str16 text);";

/** A texts row with only the str columns the caller names filled in. */
function row(id, strs) {
	const filled = { id };
	for (let i = 1; i <= 16; i++) filled[`str${i}`] = strs[`str${i}`] ?? "";
	return filled;
}

// --- pairStrings: (card id, str index) alignment across two cdbs ---

test("pairStrings aligns every one of the 16 columns by card id", () => {
	const chinese = [row(1, { str1: "甲", str9: "乙", str16: "丙" })];
	const translated = [row(1, { str1: "Alpha", str9: "Beta", str16: "Gamma" })];

	assert.deepEqual(pairStrings(chinese, translated), [
		{ id: 1, chinese: "甲", translated: "Alpha" },
		{ id: 1, chinese: "乙", translated: "Beta" },
		{ id: 1, chinese: "丙", translated: "Gamma" },
	]);
});

test("pairStrings skips a column empty on either side and ids absent from one db", () => {
	const chinese = [row(1, { str1: "甲", str2: "乙" }), row(2, { str1: "丙" })];
	// 1.str2 has no counterpart; card 2 is absent from the translated db entirely.
	const translated = [row(1, { str1: "Alpha", str3: "Orphan" })];

	assert.deepEqual(pairStrings(chinese, translated), [
		{ id: 1, chinese: "甲", translated: "Alpha" },
	]);
});

test("pairStrings trims padding so one term does not split into two keys", () => {
	const pairs = pairStrings(
		[row(1, { str1: " 甲 " }), row(2, { str1: "甲" })],
		[row(1, { str1: "Alpha " }), row(2, { str1: "Alpha" })],
	);
	assert.deepEqual(
		pairs.map(({ chinese, translated }) => [chinese, translated]),
		[
			["甲", "Alpha"],
			["甲", "Alpha"],
		],
	);
});

// --- mineTerms: the consistency + attestation filter ---

test("the threshold is two distinct cards", () => {
	assert.equal(MIN_ATTESTING_CARDS, 2);
});

test("mineTerms accepts a term two distinct cards translate the same way", () => {
	const { terms, stats } = mineTerms([
		{ id: 1, chinese: "特殊召唤", translated: "Special Summon" },
		{ id: 2, chinese: "特殊召唤", translated: "Special Summon" },
	]);

	assert.deepEqual(terms, { 特殊召唤: "Special Summon" });
	assert.deepEqual(stats, {
		examined: 2,
		accepted: 1,
		rejectedInconsistent: 0,
		rejectedSingleCard: 0,
	});
});

test("mineTerms rejects a term with two translations, however well attested", () => {
	const { terms, stats } = mineTerms([
		{ id: 1, chinese: "特殊召唤", translated: "Special Summon" },
		{ id: 2, chinese: "特殊召唤", translated: "Special Summon" },
		{ id: 3, chinese: "特殊召唤", translated: "Invocar de Modo Especial a este monstruo" },
		{ id: 4, chinese: "特殊召唤", translated: "Invocar de Modo Especial a este monstruo" },
	]);

	assert.deepEqual(terms, {});
	assert.deepEqual(stats, {
		examined: 4,
		accepted: 0,
		rejectedInconsistent: 1,
		rejectedSingleCard: 0,
	});
});

test("mineTerms rejects a term only one card attests — it cannot be told from that card's own prose", () => {
	const { terms, stats } = mineTerms([{ id: 1, chinese: "破坏", translated: "Destroy" }]);

	assert.deepEqual(terms, {});
	assert.deepEqual(stats, {
		examined: 1,
		accepted: 0,
		rejectedInconsistent: 0,
		rejectedSingleCard: 1,
	});
});

test("mineTerms counts cards, not occurrences: one card repeating a term is one attestation", () => {
	const { terms, stats } = mineTerms([
		{ id: 1, chinese: "破坏", translated: "Destroy" },
		{ id: 1, chinese: "破坏", translated: "Destroy" },
	]);

	assert.deepEqual(terms, {});
	assert.equal(stats.rejectedSingleCard, 1);
});

test("pairStrings credits a reprint to the card it reprints, so aliases cannot attest each other", () => {
	// 2 and 3 are alt-art printings of 1. Their prose is one card's, so the term
	// stays a single attestation and mineTerms rejects it — without the family
	// map the three ids would look like three cards agreeing.
	const chinese = [
		{ id: 1, str1: "破坏" },
		{ id: 2, str1: "破坏" },
		{ id: 3, str1: "破坏" },
	];
	const translated = [
		{ id: 1, str1: "Destroy the monster" },
		{ id: 2, str1: "Destroy the monster" },
		{ id: 3, str1: "Destroy the monster" },
	];
	const families = new Map([
		[2, 1],
		[3, 1],
	]);

	const pairs = pairStrings(chinese, translated, families);
	assert.deepEqual(
		pairs.map((p) => p.id),
		[1, 1, 1],
	);
	assert.deepEqual(mineTerms(pairs).terms, {});

	// Without the map the same rows read as three separate cards.
	assert.deepEqual(mineTerms(pairStrings(chinese, translated)).terms, {
		破坏: "Destroy the monster",
	});
});

test("mineTerms is per-term: a rejected term never taints an accepted one", () => {
	const { terms, stats } = mineTerms([
		{ id: 1, chinese: "抽卡", translated: "Draw" },
		{ id: 2, chinese: "抽卡", translated: "Draw" },
		{ id: 1, chinese: "破坏", translated: "Destroy" },
		{ id: 2, chinese: "破坏", translated: "Destruir" },
		{ id: 3, chinese: "发动", translated: "Activate" },
	]);

	assert.deepEqual(terms, { 抽卡: "Draw" });
	assert.deepEqual(stats, {
		examined: 5,
		accepted: 1,
		rejectedInconsistent: 1,
		rejectedSingleCard: 1,
	});
});

// --- renderEffectStrings: the committed artifact ---

test("renderEffectStrings sorts keys, indents by 2 and ends with a newline", () => {
	const json = renderEffectStrings({
		en: { 破坏: "Destroy", 抽卡: "Draw" },
		es: { 抽卡: "Robar" },
	});

	assert.equal(
		json,
		`{\n  "抽卡": {\n    "en": "Draw",\n    "es": "Robar"\n  },\n  "破坏": {\n    "en": "Destroy"\n  }\n}\n`,
	);
});

test("renderEffectStrings omits a language with no entry instead of writing an empty string", () => {
	const entry = JSON.parse(renderEffectStrings({ en: {}, es: { 抽卡: "Robar" } }))["抽卡"];
	assert.deepEqual(entry, { es: "Robar" });
});

test("renderEffectStrings is deterministic: insertion order does not reach the file", () => {
	const forward = renderEffectStrings({ en: { 甲: "A", 乙: "B", 丙: "C" }, es: {} });
	const backward = renderEffectStrings({ en: { 丙: "C", 乙: "B", 甲: "A" }, es: {} });
	assert.equal(forward, backward);
});

// --- readStrRows: the sqlite read the miner runs over each base cdb ---

test("readStrRows returns every str column in id order, NULL read as empty", () => {
	const dir = mkdtempSync(join(tmpdir(), "effect-strings-"));
	try {
		const path = join(dir, "base.cdb");
		execFileSync("sqlite3", [path], { input: STR_SCHEMA, encoding: "utf8" });
		execFileSync("sqlite3", [
			path,
			"INSERT INTO texts(id,name,str1,str16) VALUES(2,'Two','特殊召唤','破坏');" +
				"INSERT INTO texts(id,name) VALUES(1,'One');",
		]);

		const rows = readStrRows(path);
		assert.deepEqual(
			rows.map(({ id }) => id),
			[1, 2],
		);
		assert.deepEqual(rows[0], row(1, {}));
		assert.deepEqual(rows[1], row(2, { str1: "特殊召唤", str16: "破坏" }));
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

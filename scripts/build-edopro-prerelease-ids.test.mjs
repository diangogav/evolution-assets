import assert from "node:assert/strict";
import { test } from "node:test";

import { pairPrereleaseIds, parseArgs, renderPrereleaseIds } from "./build-edopro-prerelease-ids.mjs";

const SPELL = 2;
const MONSTER = 33;
const OCG = 0x101;
const ANIME = 0x4;

const card = (id, name, { type = SPELL, atk = 0, def = 0, alias = 0, ot = OCG } = {}) => ({ id, ot, alias, type, atk, def, name });
const pool = (...cards) => new Map(cards.map((entry) => [entry.id, entry]));
const pairsOf = (prerelease, edopro) => [...pairPrereleaseIds(prerelease, edopro)];

test("parseArgs requires the databases directory and defaults the rest", () => {
	assert.throws(() => parseArgs([]), /--databases/);
	assert.deepEqual(parseArgs(["--databases", "dbs"]), {
		databases: "dbs",
		prerelease: "cdb/prerelease.en.cdb.gz",
		base: "cdb/base.en.cdb.gz",
		out: "edopro/prerelease-ids.json",
	});
});

test("pairs a card with the EDOPro card of the same name and stats", () => {
	const pairs = pairsOf(
		[card(101306092, "Angelechy Strategy Score")],
		pool(card(101402092, "Angelechy Strategy Score"), card(101402093, "Angelechy Brilliant Move")),
	);
	assert.deepEqual(pairs, [[101306092, 101402092]]);
});

test("ignores letter case and surrounding spaces in the name", () => {
	const pairs = pairsOf([card(1, " angelechy verdict ")], pool(card(2, "Angelechy Verdict")));
	assert.deepEqual(pairs, [[1, 2]]);
});

test("needs no entry for a card whose code EDOPro already has", () => {
	const pairs = pairsOf([card(100, "Shared")], pool(card(100, "Shared"), card(200, "Shared")));
	assert.deepEqual(pairs, []);
});

test("leaves out a card with no namesake", () => {
	assert.deepEqual(pairsOf([card(1, "Provisional name")], pool(card(2, "Another name"))), []);
});

test("leaves out a namesake whose type, ATK or DEF differs", () => {
	const mine = card(1, "Dragon", { type: MONSTER, atk: 2800, def: 2400 });
	assert.deepEqual(pairsOf([mine], pool(card(2, "Dragon", { type: MONSTER, atk: 2800, def: 2000 }))), []);
	assert.deepEqual(pairsOf([mine], pool(card(2, "Dragon", { type: SPELL }))), []);
});

test("leaves out a card with more than one counterpart", () => {
	assert.deepEqual(pairsOf([card(1, "Twin")], pool(card(2, "Twin"), card(3, "Twin"))), []);
});

test("never pairs with an alternate artwork, nor with an anime or skill card", () => {
	const edopro = pool(card(2, "Arcana Force", { ot: ANIME }), card(3, "Arcana Force"), card(4, "Arcana Force", { alias: 3 }));
	assert.deepEqual(pairsOf([card(1, "Arcana Force")], edopro), [[1, 3]]);
	assert.deepEqual(pairsOf([card(1, "Arcana Force")], pool(card(2, "Arcana Force", { ot: ANIME }))), []);
});

test("renders the pairs in code order as stable JSON", () => {
	const pairs = pairPrereleaseIds([card(20, "B"), card(10, "A")], pool(card(11, "A"), card(21, "B")));
	assert.equal(renderPrereleaseIds(pairs), '{\n\t"version": 1,\n\t"ids": {\n\t\t"10": 11,\n\t\t"20": 21\n\t}\n}\n');
});

test("pairs a card the YGOPro pool holds under its passcode with EDOPro's temporary code for it", () => {
	const pairs = pairsOf(
		[card(86457955, "Angelechy Opposition", { ot: 0x2 })],
		pool(card(101402094, "Angelechy Opposition")),
	);
	assert.deepEqual(pairs, [[86457955, 101402094]]);
});

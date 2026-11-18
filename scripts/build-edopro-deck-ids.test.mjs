import assert from "node:assert/strict";
import { test } from "node:test";

import { mapDeckIds, parseArgs, renderDeckIds } from "./build-edopro-deck-ids.mjs";

const SPELL = 2;
const MONSTER = 33;
const TOKEN = 0x4011;
const OCG = 0x1;
const UNRELEASED = 0x101;
const ANIME = 0x4;
const RUSH = 0x200;

const card = (id, name, { type = SPELL, atk = 0, def = 0, alias = 0, ot = OCG } = {}) => ({ id, ot, alias, type, atk, def, name });
const pool = (...cards) => new Map(cards.map((entry) => [entry.id, entry]));
const idsOf = (edopro, base, prerelease = []) => [...mapDeckIds(edopro, base, prerelease)];

test("parseArgs requires the databases directory and defaults the rest", () => {
	assert.throws(() => parseArgs([]), /--databases/);
	assert.deepEqual(parseArgs(["--databases", "dbs"]), {
		databases: "dbs",
		base: "cdb/base.en.cdb.gz",
		prerelease: "cdb/prerelease.en.cdb.gz",
		out: "edopro/deck-ids.json",
	});
});

test("needs no entry for a code the client's released pool has", () => {
	assert.deepEqual(idsOf(pool(card(100, "Shared")), [card(100, "Shared")]), []);
});

test("maps an unreleased card of EDOPro to the passcode the client already has for it", () => {
	const ids = idsOf(
		pool(card(101402094, "Angelechy Opposition", { ot: UNRELEASED })),
		[card(86457955, "Angelechy Opposition")],
	);
	assert.deepEqual(ids, [[101402094, 86457955]]);
});

test("maps it to the client's own temporary code when the client has not released it either", () => {
	const ids = idsOf(
		pool(card(101402200, "Not Out Yet", { ot: UNRELEASED })),
		[],
		[card(101306200, "Not Out Yet", { ot: UNRELEASED })],
	);
	assert.deepEqual(ids, [[101402200, 101306200]]);
});

test("prefers the released card over the unreleased one of the same name", () => {
	const ids = idsOf(
		pool(card(101402094, "Angelechy Opposition", { ot: UNRELEASED })),
		[card(86457955, "Angelechy Opposition")],
		[card(101306094, "Angelechy Opposition", { ot: UNRELEASED })],
	);
	assert.deepEqual(ids, [[101402094, 86457955]]);
});

test("maps a copy to the card it copies", () => {
	const ids = idsOf(
		pool(
			card(3784444, "Rampaging Rhynos (Pre-Errata)", { alias: 3784434 }),
			card(511001989, "Revival Swarm (Anime)", { alias: 89226534, ot: ANIME }),
		),
		[card(3784434, "Rampaging Rhynos"), card(89226534, "Revival Swarm")],
	);
	assert.deepEqual(ids, [
		[3784444, 3784434],
		[511001989, 89226534],
	]);
});

test("follows a copy of an unreleased card to the client's code for that card", () => {
	const ids = idsOf(
		pool(
			card(101402094, "Angelechy Opposition", { ot: UNRELEASED }),
			card(101402095, "Angelechy Opposition", { ot: UNRELEASED, alias: 101402094 }),
		),
		[card(86457955, "Angelechy Opposition")],
	);
	assert.deepEqual(ids, [
		[101402094, 86457955],
		[101402095, 86457955],
	]);
});

test("leaves out a copy whose original the client cannot resolve, and survives a loop of copies", () => {
	const edopro = pool(
		card(1, "Orphan copy", { alias: 999 }),
		card(2, "Loop A", { alias: 3 }),
		card(3, "Loop B", { alias: 2 }),
	);
	assert.deepEqual(idsOf(edopro, []), []);
});

test("leaves out a card with no namesake, or whose type, ATK or DEF differs", () => {
	const mine = [card(10, "Dragon", { type: MONSTER, atk: 2800, def: 2400 })];
	assert.deepEqual(idsOf(pool(card(1, "Provisional name", { ot: UNRELEASED })), mine), []);
	assert.deepEqual(idsOf(pool(card(1, "Dragon", { ot: UNRELEASED, type: MONSTER, atk: 2800, def: 2000 })), mine), []);
	assert.deepEqual(idsOf(pool(card(1, "Dragon", { ot: UNRELEASED, type: SPELL })), mine), []);
});

test("leaves out a card when several of the client's cards qualify", () => {
	const ids = idsOf(pool(card(1, "Twin", { ot: UNRELEASED })), [card(10, "Twin"), card(11, "Twin")]);
	assert.deepEqual(ids, []);
});

test("does not pair with a copy in the client's pool, only with the original", () => {
	const ids = idsOf(
		pool(card(1, "Dark Magician", { ot: UNRELEASED, type: MONSTER, atk: 2500, def: 2100 })),
		[
			card(46986414, "Dark Magician", { type: MONSTER, atk: 2500, def: 2100 }),
			card(46986415, "Dark Magician", { type: MONSTER, atk: 2500, def: 2100, alias: 46986414 }),
		],
	);
	assert.deepEqual(ids, [[1, 46986414]]);
});

test("leaves out anime cards that copy nothing, tokens and Rush Duel cards", () => {
	const edopro = pool(
		card(511000001, "Polymerization", { ot: ANIME }),
		card(4014, "Sheep Token", { type: TOKEN }),
		card(160001000, "Blue-Eyes White Dragon", { ot: RUSH, alias: 89631139, type: MONSTER, atk: 3000, def: 2500 }),
	);
	const mine = [
		card(24094653, "Polymerization"),
		card(4015, "Sheep Token", { type: TOKEN }),
		card(89631139, "Blue-Eyes White Dragon", { type: MONSTER, atk: 3000, def: 2500 }),
	];
	assert.deepEqual(idsOf(edopro, mine), []);
});

test("renderDeckIds writes the codes in code order under a version", () => {
	assert.equal(renderDeckIds(new Map([[2, 20], [1, 10]])), '{\n\t"version": 1,\n\t"ids": {\n\t\t"1": 10,\n\t\t"2": 20\n\t}\n}\n');
});

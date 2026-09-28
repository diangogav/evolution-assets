import assert from "node:assert/strict";
import { existsSync } from "node:fs";
import { join } from "node:path";
import { test } from "node:test";

import { correctCardIdentities, readCardIdentity } from "./resolve-card-identity.mjs";

// -- correctCardIdentities ----------------------------------------------------

test("rewrites an alternate-art code to its base code", () => {
	const cards = [{ code: 3294539, points: 1, name: "Crimson Blade Dragon" }];
	const identity = new Map([[3294539, 80321197]]);

	const result = correctCardIdentities(cards, identity);

	assert.equal(result.cards[0].code, 80321197);
	assert.deepEqual(result.corrections, [
		{ from: 3294539, to: 80321197, name: "Crimson Blade Dragon" },
	]);
	assert.deepEqual(result.unknown, []);
	assert.deepEqual(result.dropped, []);
});

test("drops a correction whose target code already exists in the list, base first", () => {
	const cards = [
		{ code: 83764718, points: 1, name: "Monster Reborn" },
		{ code: 83764719, points: 1, name: "Monster Reborn (alt art)" },
	];
	const identity = new Map([
		[83764718, 0],
		[83764719, 83764718],
	]);

	const result = correctCardIdentities(cards, identity);

	assert.equal(result.cards.length, 1);
	assert.equal(result.cards[0].code, 83764718);
	assert.deepEqual(result.corrections, []);
	assert.deepEqual(result.dropped, [
		{ from: 83764719, to: 83764718, name: "Monster Reborn (alt art)" },
	]);
});

test("drops a correction whose target code already exists in the list, alternate first", () => {
	const cards = [
		{ code: 83764719, points: 1, name: "Monster Reborn (alt art)" },
		{ code: 83764718, points: 1, name: "Monster Reborn" },
	];
	const identity = new Map([
		[83764718, 0],
		[83764719, 83764718],
	]);

	const result = correctCardIdentities(cards, identity);

	assert.equal(result.cards.length, 1);
	assert.equal(result.cards[0].code, 83764718);
	assert.deepEqual(result.corrections, []);
	assert.deepEqual(result.dropped, [
		{ from: 83764719, to: 83764718, name: "Monster Reborn (alt art)" },
	]);
});

test("keeps a card unchanged and reports it when the database has no entry for it", () => {
	const cards = [{ code: 101303084, points: 1, name: "Unknown Card" }];
	const identity = new Map();

	const result = correctCardIdentities(cards, identity);

	assert.deepEqual(result.cards, cards);
	assert.deepEqual(result.unknown, [{ code: 101303084, name: "Unknown Card" }]);
	assert.deepEqual(result.corrections, []);
	assert.deepEqual(result.dropped, []);
});

test("leaves a base card (alias 0) untouched", () => {
	const cards = [{ code: 68468459, points: 1, name: "Fallen of the White Dragon" }];
	const identity = new Map([[68468459, 0]]);

	const result = correctCardIdentities(cards, identity);

	assert.deepEqual(result.cards, cards);
	assert.deepEqual(result.corrections, []);
	assert.deepEqual(result.unknown, []);
	assert.deepEqual(result.dropped, []);
});

test("preserves sourceUrl across a correction", () => {
	const cards = [
		{
			code: 18144507,
			points: 1,
			name: "Harpie's Feather Duster",
			sourceUrl: "https://yugiohblog.konami.com/2026/genesys/some-points-update/",
		},
	];
	const identity = new Map([[18144507, 18144506]]);

	const result = correctCardIdentities(cards, identity);

	assert.equal(result.cards[0].code, 18144506);
	assert.equal(
		result.cards[0].sourceUrl,
		"https://yugiohblog.konami.com/2026/genesys/some-points-update/",
	);
});

test("does not mutate the input array or its objects", () => {
	const cards = [{ code: 3294539, points: 1, name: "Crimson Blade Dragon" }];
	const snapshot = JSON.parse(JSON.stringify(cards));
	const identity = new Map([[3294539, 80321197]]);

	correctCardIdentities(cards, identity);

	assert.deepEqual(cards, snapshot);
});

test("an empty identity map treats every card as unknown and corrects nothing", () => {
	const cards = [
		{ code: 3294539, points: 1, name: "Crimson Blade Dragon" },
		{ code: 68468459, points: 1, name: "Fallen of the White Dragon" },
	];

	const result = correctCardIdentities(cards, new Map());

	assert.deepEqual(result.cards, cards);
	assert.deepEqual(result.corrections, []);
	assert.deepEqual(result.dropped, []);
	assert.deepEqual(result.unknown, [
		{ code: 3294539, name: "Crimson Blade Dragon" },
		{ code: 68468459, name: "Fallen of the White Dragon" },
	]);
});

// The four real wrong identities the 2026-08-25 audit found against
// cdb/base.en.cdb (see odd/tasks/genesys-cdb-identity-validation.md).
const REAL_ALTERNATE_ART_CASES = [
	{ from: 3294539, to: 80321197, name: "Crimson Blade Dragon" },
	{ from: 18144507, to: 18144506, name: "Harpie's Feather Duster" },
	{ from: 73819701, to: 68468459, name: "Fallen of the White Dragon" },
	{ from: 83764719, to: 83764718, name: "Monster Reborn" },
];

test("corrects the four real alternate-art codes from the audit", () => {
	const cards = REAL_ALTERNATE_ART_CASES.map(({ from, name }) => ({ code: from, points: 1, name }));
	const identity = new Map(REAL_ALTERNATE_ART_CASES.map(({ from, to }) => [from, to]));

	const result = correctCardIdentities(cards, identity);

	assert.deepEqual(
		result.cards.map((card) => card.code),
		REAL_ALTERNATE_ART_CASES.map(({ to }) => to),
	);
	assert.deepEqual(
		result.corrections,
		REAL_ALTERNATE_ART_CASES.map(({ from, to, name }) => ({ from, to, name })),
	);
	assert.deepEqual(result.unknown, []);
	assert.deepEqual(result.dropped, []);
});

// -- readCardIdentity, against the real local database (skipped when absent) -

const REAL_CDB = join(import.meta.dirname, "..", "cdb", "base.en.cdb");

test(
	"reads the real card database and maps the audited alternate art to its base",
	{ skip: !existsSync(REAL_CDB) },
	() => {
		const identity = readCardIdentity(REAL_CDB);

		assert.equal(identity.get(83764719), 83764718);
		assert.equal(identity.get(83764718), 0);
	},
);

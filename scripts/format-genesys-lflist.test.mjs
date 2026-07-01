import assert from "node:assert/strict";
import { test } from "node:test";

import { formatGenesysLflist } from "./format-genesys-lflist.mjs";

test("starts with the Genesys header", () => {
	const conf = formatGenesysLflist([{ code: 21044178, points: 100, name: "Abyss Dweller" }]);
	assert.ok(conf.startsWith("#[Genesys]\n!Genesys\n"));
});

test("emits each card as `code 3 points --name`", () => {
	const conf = formatGenesysLflist([{ code: 21044178, points: 100, name: "Abyss Dweller" }]);
	assert.ok(conf.includes("21044178 3 100 --Abyss Dweller"));
});

test("skips cards with zero or negative points", () => {
	const conf = formatGenesysLflist([
		{ code: 111, points: 0, name: "Free" },
		{ code: 222, points: 50, name: "Costed" },
	]);
	assert.ok(!conf.includes("111 3"));
	assert.ok(conf.includes("222 3 50"));
});

test("sorts entries by code for deterministic diffs", () => {
	const conf = formatGenesysLflist([
		{ code: 300, points: 10, name: "C" },
		{ code: 100, points: 10, name: "A" },
		{ code: 200, points: 10, name: "B" },
	]);
	const codes = conf
		.split("\n")
		.filter((l) => /^\d/.test(l))
		.map((l) => Number(l.split(" ")[0]));
	assert.deepEqual(codes, [100, 200, 300]);
});

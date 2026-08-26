import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

import { parseSetBlocks, printCodeCandidates } from "./rush-sets.mjs";

test("reads the set prefix and region out of a dated line", () => {
	const blocks = parseSetBlocks(
		"- **December 20, 2024**: Elemental HERO Duel Set (RD/JF25-JP): `120281XXX`",
	);
	assert.deepEqual(blocks["120281"], [{ set: "RD/JF25", region: "JP" }]);
});

test("reads a line whose set carries no card-set name", () => {
	const blocks = parseSetBlocks("- **April 11, 2026** (RD/ORP4-JP): `120295XXX`");
	assert.deepEqual(blocks["120295"], [{ set: "RD/ORP4", region: "JP" }]);
});

test("keeps region suffixes other than JP", () => {
	const blocks = parseSetBlocks("- **May 31, 2025**: 5th SPECIAL PACK (RD/5THS-JPA): `120286XXX`");
	assert.deepEqual(blocks["120286"], [{ set: "RD/5THS", region: "JPA" }]);
});

test("defaults to JP when the line omits the region", () => {
	const blocks = parseSetBlocks(
		"- **July 21, 2024**: Jump Victory Carnival 2024 promotional card (RD/VC24) `120267XXX`",
	);
	assert.deepEqual(blocks["120267"], [{ set: "RD/VC24", region: "JP" }]);
});

test("collapses repeated lines that name the same set", () => {
	const blocks = parseSetBlocks(
		[
			"- **October 1, 2020**: Saikyō Jump November 2020 (RD/SJMP-JP): `120109XXX`",
			"- **February 4, 2021**: Saikyō Jump March 2021 (RD/SJMP-JP): `120109XXX`",
		].join("\n"),
	);
	assert.deepEqual(blocks["120109"], [{ set: "RD/SJMP", region: "JP" }]);
});

test("keeps every candidate when one block spans different sets", () => {
	const blocks = parseSetBlocks(
		[
			"- **April 1, 2022**: Battle Pack 2022 Vol.1 (RD/B221-JP): `120215XXX`",
			"- **April 1, 2022**: Secret Ace Pack 2022 Vol. 1 (RD/S221-JP): `120215XXX`",
		].join("\n"),
	);
	assert.deepEqual(blocks["120215"], [
		{ set: "RD/B221", region: "JP" },
		{ set: "RD/S221", region: "JP" },
	]);
});

test("ignores lines that carry no id block", () => {
	assert.deepEqual(parseSetBlocks("# Upcoming\nhttps://yugipedia.com/wiki/Category:Rush_Duel"), {});
});

test("builds one print code per candidate set, keeping the card number", () => {
	const blocks = { 120215: [{ set: "RD/B221", region: "JP" }, { set: "RD/S221", region: "JP" }] };
	assert.deepEqual(printCodeCandidates("120215007", blocks), ["RD/B221-JP007", "RD/S221-JP007"]);
});

test("returns nothing for an id whose block no set claims", () => {
	assert.deepEqual(printCodeCandidates("120999001", {}), []);
});

test("covers the mirrored sets.md", () => {
	const blocks = parseSetBlocks(readFileSync("rush/sets.md", "utf8"));
	const lines = readFileSync("rush/sets.md", "utf8")
		.split("\n")
		.filter((line) => /`120\d{3}XXX`/.test(line));

	// Every line that declares a block must land in the map.
	const declared = new Set(lines.map((line) => /`(120\d{3})XXX`/.exec(line)[1]));
	assert.deepEqual(new Set(Object.keys(blocks)), declared);
	assert.ok(declared.size > 100, `expected the real file to declare many blocks, got ${declared.size}`);
});

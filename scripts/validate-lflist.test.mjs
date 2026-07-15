import assert from "node:assert/strict";
import { test } from "node:test";

import { validateLflist } from "./validate-lflist.mjs";

const validList = `#[2010.3 Edison]
!2010.3 Edison
$whitelist
#forbidden
72989439 0 --Black Luster Soldier
82301904 0 --Chaos Emperor Dragon
#limited
4031928 1 -- Change of Heart
`;

test("a well-formed list produces no errors", () => {
	assert.deepEqual(validateLflist(validList, "edison"), []);
});

test("flags a missing banlist header", () => {
	const text = "#[No Header]\n72989439 0\n";
	const errors = validateLflist(text, "edison");
	assert.ok(errors.some((e) => e.includes("missing banlist header")));
});

test("flags an empty banlist (header but no entries)", () => {
	const text = "#[Empty]\n!Empty\n$whitelist\n";
	const errors = validateLflist(text, "edison");
	assert.ok(errors.some((e) => e.includes("no card entries")));
});

test("flags a duplicate card id and reports both lines", () => {
	const text = "!Dup\n72989439 0\n11111111 1\n72989439 2\n";
	const errors = validateLflist(text, "edison");
	const dup = errors.find((e) => e.includes("duplicate card id 72989439"));
	assert.ok(dup, "expected a duplicate error");
	assert.ok(dup.includes("lines 2 and 4"), `expected line numbers, got: ${dup}`);
});

test("flags an unparseable entry line", () => {
	const text = "!Bad\nnot-a-card-line\n72989439 0\n";
	const errors = validateLflist(text, "edison");
	assert.ok(errors.some((e) => e.includes("unparseable line")));
});

test("accepts entries that carry a trailing comment or points", () => {
	const text = "!Points\n72989439 3 100 --Costed card\n11111111 1 -- Named\n";
	assert.deepEqual(validateLflist(text, "genesys"), []);
});

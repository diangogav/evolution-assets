import assert from "node:assert/strict";
import { test } from "node:test";

import { bridgeListName, isShippedUpstream } from "./check-tcg-bridge.mjs";

const bridge = `#[2026.10 TCG]
!2026.10 TCG
#Forbidden TCG
21044178 0 --Abyss Dweller
`;

test("reads the list name from the bridge file", () => {
	assert.equal(bridgeListName(bridge), "2026.10 TCG");
});

test("fails loudly when the bridge file has no list header", () => {
	assert.throws(() => bridgeListName("21044178 0\n"), /no "!name" header/);
});

test("reports not shipped while upstream only has older TCG lists", () => {
	const upstream = "#[2026.10][2026.9 TCG]\n!2026.10\n1 0\n!2026.9 TCG\n2 0\n";
	assert.equal(isShippedUpstream("2026.10 TCG", upstream), false);
});

test("reports shipped once upstream declares the same list", () => {
	const upstream = "!2026.10\n1 0\n!2026.10 TCG\n2 0\n!2026.9 TCG\n3 0\n";
	assert.equal(isShippedUpstream("2026.10 TCG", upstream), true);
});

test("matches an upstream name written without the leading zero", () => {
	assert.equal(isShippedUpstream("2026.09 TCG", "!2026.9 TCG\n1 0\n"), true);
});

test("ignores the OCG list that shares the date", () => {
	assert.equal(isShippedUpstream("2026.10 TCG", "!2026.10\n1 0\n"), false);
});

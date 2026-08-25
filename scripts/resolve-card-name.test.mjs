import assert from "node:assert/strict";
import { test } from "node:test";

import { normalizeCardName, overrideCardCode } from "./resolve-card-name.mjs";

test("normalizes en and em dashes to plain hyphens", () => {
	assert.equal(normalizeCardName("Kuriboh – Multiply!"), "Kuriboh - Multiply!");
	assert.equal(normalizeCardName("Kuriboh — Multiply!"), "Kuriboh - Multiply!");
});

test("trims and collapses whitespace", () => {
	assert.equal(normalizeCardName("  D.D.  Crow "), "D.D. Crow");
});

test("maps Konami's preliminary Sacred Beast names to their TCG ids", () => {
	assert.equal(
		overrideCardCode("Calamity of the Sacred Beasts – Hamon, Lord of Striking Thunder"),
		50251045,
	);
	assert.equal(
		overrideCardCode("Infinity of the Sacred Beasts - Raviel, Lord of Phantasms"),
		96345184,
	);
});

test("maps the table's mangled renderings to their ids", () => {
	// The table renders Ω as a plain O and serves the ØØ in Lupis as Latin-1
	// bytes inside a UTF-8 page, which decode to U+FFFD.
	assert.equal(overrideCardCode("Exstellarknight Constellar Ptolemy O7"), 6195332);
	assert.equal(overrideCardCode("K9-�� Lupis"), 91025875);
});

test("maps renamed cards to their ids", () => {
	assert.equal(overrideCardCode("Stellarnova Binding"), 69678646);
	assert.equal(overrideCardCode("The Three Champions of Swordsoul"), 74405783);
});

test("returns null for names without an override", () => {
	assert.equal(overrideCardCode("Abyss Dweller"), null);
});

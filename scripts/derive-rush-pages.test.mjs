import assert from "node:assert/strict";
import test from "node:test";

import {
	buildCodeIndex,
	parseSetLists,
	renderPagesJson,
	resolvePages,
} from "./derive-rush-pages.mjs";

// --- parseSetLists: one wikitext page → { print code: page title } ---

test("reads a plain code-and-name line", () => {
	const map = parseSetLists("{{Set list|region=JP|print=New|\nRD/DK01-JP002; CAN:D\n}}");
	assert.deepEqual(map, { "RD/DK01-JP002": "CAN:D" });
});

test("reads a line that carries a rarity field", () => {
	const map = parseSetLists(
		"{{Set list|region=JP|\nRD/5TH1-JP053; Altierra the Skysavior Transience; SPR, ScR\n}}",
	);
	assert.deepEqual(map, { "RD/5TH1-JP053": "Altierra the Skysavior Transience" });
});

test("reads a line with an empty rarity slot before a print field", () => {
	const map = parseSetLists(
		"{{Set list|region=JP|\nRD/DK01-JP001; Seiyaryu (Rush Duel);; New\n}}",
	);
	assert.deepEqual(map, { "RD/DK01-JP001": "Seiyaryu (Rush Duel)" });
});

test("reads a line that ends in a quantity field", () => {
	const map = parseSetLists("{{Set list|region=JP|\nRD/GRD1-JP007; Silver Seyfert;;; 2\n}}");
	assert.deepEqual(map, { "RD/GRD1-JP007": "Silver Seyfert" });
});

test("drops the // description :: annotation after the fields", () => {
	const map = parseSetLists(
		"{{Set list|region=JP|\nRD/SST1-JP028; Kuribot // description :: (alternate artwork)\n}}",
	);
	assert.deepEqual(map, { "RD/SST1-JP028": "Kuribot" });
});

test("drops the annotation even when rarity and print fields precede it", () => {
	const map = parseSetLists(
		"{{Set list|region=JP|\nRD/5TH1-JP001; Eternity Ether Dragon; ORRBlack; New // description :: (alternate artwork)\n}}",
	);
	assert.deepEqual(map, { "RD/5TH1-JP001": "Eternity Ether Dragon" });
});

test("skips codes without the RD/ prefix — non-Rush cards on mixed pages", () => {
	const map = parseSetLists(
		"{{Set list|region=JP|\nDK01-JP001; Aussa the Earth Charmer\nRD/DK01-JP001; Seiyaryu (Rush Duel)\n}}",
	);
	assert.deepEqual(map, { "RD/DK01-JP001": "Seiyaryu (Rush Duel)" });
});

test("strips the [L]/[R] piece marker — the page title has none", () => {
	const map = parseSetLists(
		"{{Set list|region=JP|\nRD/AP01-JP025; Doomblaze Fiend Overlord Despairacion [L]\nRD/AP01-JP027; Doomblaze Fiend Overlord Despairacion [R]\n}}",
	);
	assert.deepEqual(map, {
		"RD/AP01-JP025": "Doomblaze Fiend Overlord Despairacion",
		"RD/AP01-JP027": "Doomblaze Fiend Overlord Despairacion",
	});
});

test("strips invisible left-to-right marks pasted into a name", () => {
	const map = parseSetLists("{{Set list|region=JP|\nRD/KP01-JP001; Necromaid Nana\u200e\n}}");
	assert.deepEqual(map, { "RD/KP01-JP001": "Necromaid Nana" });
});

test("keeps a parenthesised disambiguation — it is part of the title", () => {
	const map = parseSetLists("{{Set list|region=JP|\nRD/KP02-JP035; Tyhone #2 (Rush Duel)\n}}");
	assert.deepEqual(map, { "RD/KP02-JP035": "Tyhone #2 (Rush Duel)" });
});

test("reads only inside Set list blocks and ignores surrounding markup", () => {
	const map = parseSetLists(
		[
			"{{Set page header}}",
			"",
			"{{Set list|region=JP|rarities=SR, ScR|print=New artwork|",
			"RD/DK01-JP005; Secret Order",
			"}}",
			"RD/XX99-JP999; Not A Card",
		].join("\n"),
	);
	assert.deepEqual(map, { "RD/DK01-JP005": "Secret Order" });
});

// --- buildCodeIndex: every page merged into one code → title map ---

test("merges pages and keeps duplicate reprint codes that agree", () => {
	const index = buildCodeIndex({
		"Set Card Lists:A (OCG-JP)": "{{Set list|region=JP|\nRD/KP01-JP001; Sevens Road Magician\n}}",
		"Set Card Lists:B (OCG-JP)": "{{Set list|region=JP|\nRD/KP01-JP001; Sevens Road Magician\nRD/B221-JP002; Dragias\n}}",
	});
	assert.deepEqual(index, {
		"RD/KP01-JP001": "Sevens Road Magician",
		"RD/B221-JP002": "Dragias",
	});
});

// --- resolvePages: card id → title through the print-code candidates ---

const blocks = {
	120281: [{ set: "RD/JF25", region: "JP" }],
	120241: [
		{ set: "RD/B221", region: "JP" },
		{ set: "RD/B231", region: "JP" },
	],
};

test("resolves an id whose only candidate code exists in the index", () => {
	const { pages, noCandidate, ambiguous } = resolvePages(
		["120281007"],
		blocks,
		{ "RD/JF25-JP007": "Elemental HERO Neos (Rush Duel)" },
	);
	assert.deepEqual(pages, { 120281007: "Elemental HERO Neos (Rush Duel)" });
	assert.deepEqual(noCandidate, []);
	assert.deepEqual(ambiguous, []);
});

test("resolves an ambiguous block when only one candidate is printed", () => {
	const { pages, noCandidate, ambiguous } = resolvePages(["120241001"], blocks, {
		"RD/B221-JP001": "Fire Guardian",
	});
	assert.deepEqual(pages, { 120241001: "Fire Guardian" });
	assert.deepEqual(noCandidate, []);
	assert.deepEqual(ambiguous, []);
});

test("reports an id whose block no set claims", () => {
	const { pages, noCandidate } = resolvePages(["120999001"], blocks, {});
	assert.deepEqual(pages, {});
	assert.deepEqual(noCandidate, ["120999001"]);
});

test("reports an id whose candidate codes were never printed", () => {
	const { pages, noCandidate } = resolvePages(["120281050"], blocks, {});
	assert.deepEqual(pages, {});
	assert.deepEqual(noCandidate, ["120281050"]);
});

test("reports an id whose candidates are both printed, never guessing", () => {
	const { pages, ambiguous } = resolvePages(["120241006"], blocks, {
		"RD/B221-JP006": "One Card",
		"RD/B231-JP006": "Another Card",
	});
	assert.deepEqual(pages, {});
	assert.deepEqual(ambiguous, ["120241006"]);
});

// --- renderPagesJson: deterministic bytes for rush/pages.json ---

test("renders keys in ascending id order with a trailing newline", () => {
	const text = renderPagesJson({ 120281007: "B", 120110001: "A" });
	assert.equal(text, `${JSON.stringify({ 120110001: "A", 120281007: "B" }, null, 2)}\n`);
	assert.ok(text.endsWith("\n"));
});

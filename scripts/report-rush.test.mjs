import assert from "node:assert/strict";
import { test } from "node:test";

import {
	PIPELINE_STEPS,
	composeReport,
	hasNotableEvents,
	renderSummary,
	reportSignature,
	runUrlFromEnv,
} from "./report-rush.mjs";

const NOW = "2026-08-26T06:00:00.000Z";

function compose(overrides = {}) {
	return composeReport({
		fragments: {},
		cards: {},
		translations: {},
		oldIds: null,
		existing: null,
		generatedAt: NOW,
		runUrl: null,
		...overrides,
	});
}

// --- composeReport: steps ---

test("covers the four pipeline steps in order, absent fragments as missing", () => {
	const report = compose({
		fragments: { "build-cdb": { step: "build-cdb", status: "changed" } },
	});

	assert.deepEqual(PIPELINE_STEPS, [
		"resolve-pages",
		"fetch-translations",
		"build-cdb",
		"update-manifest",
	]);
	assert.deepEqual(
		report.steps.map(({ step, status }) => [step, status]),
		[
			["resolve-pages", "missing"],
			["fetch-translations", "missing"],
			["build-cdb", "changed"],
			["update-manifest", "missing"],
		],
	);
	assert.equal(report.schemaVersion, 1);
	assert.equal(report.pipeline, "rush");
	assert.equal(report.generatedAt, NOW);
});

// --- composeReport: card diff events ---

test("diffs current ids against the old dump, naming additions from cdb and cache", () => {
	const report = compose({
		cards: { 120100001: "七道魔导士", 120310001: "新怪兽", 120310002: "另一张" },
		translations: {
			120310001: { en: "New Monster", en_lore: "", es: "", es_lore: "" },
		},
		oldIds: ["120100001", "120250001"],
	});

	assert.deepEqual(report.events.cardsAdded, [
		{ id: "120310001", zh: "新怪兽", en: "New Monster", es: null },
		{ id: "120310002", zh: "另一张", en: null, es: null },
	]);
	assert.deepEqual(report.events.cardsRemoved, ["120250001"]);
});

test("fabricates no additions when the old dump is unavailable", () => {
	const report = compose({
		cards: { 120100001: "七道魔导士" },
		oldIds: null,
	});
	assert.deepEqual(report.events.cardsAdded, []);
	assert.deepEqual(report.events.cardsRemoved, []);
});

// --- composeReport: translation events ---

test("keeps gained translations that are not new cards, named like additions", () => {
	const report = compose({
		fragments: {
			"fetch-translations": {
				step: "fetch-translations",
				status: "changed",
				gained: ["120310001", "120200001"],
			},
		},
		cards: { 120200001: "旧怪兽", 120310001: "新怪兽" },
		translations: {
			120200001: { en: "Old Monster", en_lore: "", es: "Monstruo viejo", es_lore: "" },
		},
		oldIds: ["120200001"],
	});

	// 120310001 is a cardsAdded event already — announcing it twice is noise.
	assert.deepEqual(report.events.translationsAdded, [
		{ id: "120200001", zh: "旧怪兽", en: "Old Monster", es: "Monstruo viejo" },
	]);
});

// --- composeReport: gap and ambiguity events ---

test("takes gaps and ambiguities from the resolve-pages fragment", () => {
	const report = compose({
		fragments: {
			"resolve-pages": {
				step: "resolve-pages",
				status: "unchanged",
				mapped: [],
				unresolved: { count: 116, sample: ["120260001"] },
				noBlock: { count: 49, sample: ["120270001"] },
				ambiguous: [
					{ id: "120310003", zh: "罐头D", candidates: [{ code: "RD/B221-JP006", title: "CAN:D" }] },
				],
			},
		},
	});

	assert.deepEqual(report.events.unresolved, { count: 116, sample: ["120260001"] });
	assert.deepEqual(report.events.noBlock, { count: 49, sample: ["120270001"] });
	assert.equal(report.events.ambiguous.length, 1);
});

test("carries the previous gap counts when the resolve step never reported", () => {
	const existing = {
		schemaVersion: 1,
		pipeline: "rush",
		events: {
			cardsAdded: [],
			cardsRemoved: [],
			translationsAdded: [],
			unresolved: { count: 116, sample: ["120260001"] },
			noBlock: { count: 49, sample: [] },
			ambiguous: [],
		},
	};
	const report = compose({ existing });

	// A skipped/failed resolve step must not read as "the gaps went to zero".
	assert.deepEqual(report.events.unresolved, { count: 116, sample: ["120260001"] });
	assert.deepEqual(report.events.noBlock, { count: 49, sample: [] });
	assert.deepEqual(report.events.ambiguous, []);
});

// --- hasNotableEvents: the commit-worthiness rule ---

function emptyEvents(overrides = {}) {
	return {
		cardsAdded: [],
		cardsRemoved: [],
		translationsAdded: [],
		unresolved: { count: 116, sample: [] },
		noBlock: { count: 49, sample: [] },
		ambiguous: [],
		...overrides,
	};
}

test("any card, translation, or ambiguity entry is notable", () => {
	const existing = { events: emptyEvents() };
	assert.equal(hasNotableEvents(emptyEvents(), existing), false);
	assert.equal(
		hasNotableEvents(emptyEvents({ cardsAdded: [{ id: "1", zh: "x", en: null, es: null }] }), existing),
		true,
	);
	assert.equal(hasNotableEvents(emptyEvents({ cardsRemoved: ["1"] }), existing), true);
	assert.equal(
		hasNotableEvents(emptyEvents({ translationsAdded: [{ id: "1", zh: "x", en: "X", es: null }] }), existing),
		true,
	);
	assert.equal(
		hasNotableEvents(emptyEvents({ ambiguous: [{ id: "1", zh: "x", candidates: [] }] }), existing),
		true,
	);
});

test("a moved gap count is notable; an equal one is not", () => {
	const existing = { events: emptyEvents() };
	assert.equal(hasNotableEvents(emptyEvents({ unresolved: { count: 115, sample: [] } }), existing), true);
	assert.equal(hasNotableEvents(emptyEvents({ noBlock: { count: 50, sample: [] } }), existing), true);
});

test("without a previous report, nonzero gap counts are notable", () => {
	assert.equal(hasNotableEvents(emptyEvents(), null), true);
	assert.equal(
		hasNotableEvents(
			emptyEvents({ unresolved: { count: 0, sample: [] }, noBlock: { count: 0, sample: [] } }),
			null,
		),
		false,
	);
});

// --- reportSignature: the rewrite guard ignores the per-run stamps ---

test("two reports differing only in generatedAt/runUrl share a signature", () => {
	const a = compose({ generatedAt: NOW, runUrl: "https://github.com/x/y/actions/runs/1" });
	const b = compose({ generatedAt: "2026-08-27T06:00:00.000Z", runUrl: null });
	assert.equal(reportSignature(a), reportSignature(b));

	const c = compose({ cards: { 120310001: "新怪兽" }, oldIds: [] });
	assert.notEqual(reportSignature(a), reportSignature(c));
});

// --- runUrlFromEnv ---

test("builds the run url from the Actions env, null outside it", () => {
	assert.equal(
		runUrlFromEnv({
			GITHUB_SERVER_URL: "https://github.com",
			GITHUB_REPOSITORY: "evolutionygo/evolution-assets",
			GITHUB_RUN_ID: "1234",
		}),
		"https://github.com/evolutionygo/evolution-assets/actions/runs/1234",
	);
	assert.equal(runUrlFromEnv({}), null);
});

// --- renderSummary ---

test("renders step and event tables with at most 10 named new cards", () => {
	const cards = {};
	for (let i = 0; i < 12; i++) cards[String(120310001 + i)] = `新怪兽${i}`;
	const report = compose({
		fragments: {
			"resolve-pages": {
				step: "resolve-pages",
				status: "changed",
				mapped: [],
				unresolved: { count: 116, sample: [] },
				noBlock: { count: 49, sample: [] },
				ambiguous: [
					{ id: "120310003", zh: "罐头D", candidates: [{ code: "RD/B221-JP006", title: "CAN:D" }] },
				],
			},
		},
		cards,
		translations: { 120310001: { en: "New Monster 0", en_lore: "", es: "", es_lore: "" } },
		oldIds: [],
	});
	const summary = renderSummary(report);

	assert.match(summary, /\| resolve-pages \| changed \|/);
	assert.match(summary, /\| fetch-translations \| missing \|/);
	assert.match(summary, /\| Cards added \| 12 \|/);
	assert.match(summary, /\| Unresolved ids \| 116 \|/);
	assert.match(summary, /`120310001` 新怪兽0 — New Monster 0/);
	assert.equal(summary.match(/^- `\d+` 新怪兽/gm).length, 10);
	assert.match(summary, /…and 2 more/);
	assert.match(summary, /`RD\/B221-JP006` → CAN:D/);
});

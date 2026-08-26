import assert from "node:assert/strict";
import test from "node:test";

import {
	batchCodes,
	fetchRedirectTargets,
	mergePages,
	redirectTargets,
	resolveIds,
	runDaily,
	unmappedIds,
} from "./fetch-rush-code-pages.mjs";

// --- unmappedIds: the daily work list is whatever pages.json does not cover ---

test("keeps only ids without a pages.json entry, in cdb order", () => {
	const ids = unmappedIds(["120100001", "120100002", "120100003"], {
		120100002: "Star Traleo",
	});
	assert.deepEqual(ids, ["120100001", "120100003"]);
});

test("returns an empty work list when every id is mapped", () => {
	assert.deepEqual(unmappedIds(["120100001"], { 120100001: "Road Magic - Explosion" }), []);
});

// --- batchCodes: the API accepts at most 50 titles per request ---

test("splits codes into batches of at most 50", () => {
	const codes = Array.from({ length: 120 }, (_, i) => `RD/KP01-JP${String(i).padStart(3, "0")}`);
	const batches = batchCodes(codes);
	assert.deepEqual(
		batches.map((b) => b.length),
		[50, 50, 20],
	);
	assert.equal(batches[0][0], codes[0]);
	assert.equal(batches[2][19], codes[119]);
});

test("keeps exactly 50 codes in a single batch", () => {
	const codes = Array.from({ length: 50 }, (_, i) => `RD/KP01-JP${String(i).padStart(3, "0")}`);
	assert.deepEqual(batchCodes(codes), [codes]);
});

test("yields no batches for no codes", () => {
	assert.deepEqual(batchCodes([]), []);
});

// --- redirectTargets: requested title → redirect target through one response ---

test("maps a requested code to the page its redirect points at", () => {
	const body = {
		batchcomplete: "",
		query: {
			redirects: [{ from: "RD/LP01-JP001", to: "Dark Magician of Chaos (Rush Duel)" }],
			pages: { 137405: { pageid: 137405, ns: 0, title: "Dark Magician of Chaos (Rush Duel)" } },
		},
	};
	assert.deepEqual(redirectTargets(["RD/LP01-JP001"], body), {
		"RD/LP01-JP001": "Dark Magician of Chaos (Rush Duel)",
	});
});

test("follows the normalized chain before the redirect", () => {
	const body = {
		batchcomplete: "",
		query: {
			normalized: [{ from: "RD/lp01-JP001", to: "RD/LP01-JP001" }],
			redirects: [{ from: "RD/LP01-JP001", to: "Dark Magician of Chaos (Rush Duel)" }],
			pages: { 137405: { pageid: 137405, ns: 0, title: "Dark Magician of Chaos (Rush Duel)" } },
		},
	};
	assert.deepEqual(redirectTargets(["RD/lp01-JP001"], body), {
		"RD/lp01-JP001": "Dark Magician of Chaos (Rush Duel)",
	});
});

test("ignores codes the wiki reports as missing", () => {
	const body = {
		batchcomplete: "",
		query: {
			pages: { "-1": { ns: 0, title: "RD/CA01-JP099", missing: "" } },
		},
	};
	assert.deepEqual(redirectTargets(["RD/CA01-JP099"], body), {});
});

test("ignores a code that is a plain page rather than a redirect", () => {
	const body = {
		batchcomplete: "",
		query: {
			pages: { 4211: { pageid: 4211, ns: 0, title: "RD/ST01-JP001" } },
		},
	};
	assert.deepEqual(redirectTargets(["RD/ST01-JP001"], body), {});
});

// --- resolveIds: per-id verdict from the distinct redirect targets ---

test("maps an id whose only candidate code redirected", () => {
	const { mapped, unresolved, ambiguous } = resolveIds(
		{ 120281007: ["RD/JF25-JP007"] },
		{ "RD/JF25-JP007": "Elemental HERO Neos (Rush Duel)" },
	);
	assert.deepEqual(mapped, { 120281007: "Elemental HERO Neos (Rush Duel)" });
	assert.deepEqual(unresolved, []);
	assert.deepEqual(ambiguous, []);
});

test("maps an id whose several candidates agree on one target", () => {
	const { mapped, ambiguous } = resolveIds(
		{ 120241001: ["RD/B221-JP001", "RD/B231-JP001"] },
		{ "RD/B221-JP001": "Fire Guardian", "RD/B231-JP001": "Fire Guardian" },
	);
	assert.deepEqual(mapped, { 120241001: "Fire Guardian" });
	assert.deepEqual(ambiguous, []);
});

test("reports an id with no redirected candidate as unresolved", () => {
	const { mapped, unresolved } = resolveIds({ 120281050: ["RD/JF25-JP050"] }, {});
	assert.deepEqual(mapped, {});
	assert.deepEqual(unresolved, ["120281050"]);
});

test("reports disagreeing targets as ambiguous with every code→title pair", () => {
	const { mapped, ambiguous } = resolveIds(
		{ 120241006: ["RD/B221-JP006", "RD/B231-JP006"] },
		{ "RD/B221-JP006": "One Card", "RD/B231-JP006": "Another Card" },
	);
	assert.deepEqual(mapped, {});
	assert.deepEqual(ambiguous, [
		{
			id: "120241006",
			matches: [
				{ code: "RD/B221-JP006", title: "One Card" },
				{ code: "RD/B231-JP006", title: "Another Card" },
			],
		},
	]);
});

// --- mergePages: new mappings join the existing map without touching it ---

test("adds new mappings and keeps every existing entry", () => {
	const existing = { 120100001: "Road Magic - Explosion" };
	const merged = mergePages(existing, { 120281007: "Elemental HERO Neos (Rush Duel)" });
	assert.deepEqual(merged, {
		120100001: "Road Magic - Explosion",
		120281007: "Elemental HERO Neos (Rush Duel)",
	});
	assert.deepEqual(existing, { 120100001: "Road Magic - Explosion" });
});

// --- fetchRedirectTargets: the sequential, rate-limited network loop ---

function cannedFetch(bodiesByCall, calls) {
	return async (url, init) => {
		calls.push({ url: new URL(url), init });
		const body = bodiesByCall[calls.length - 1];
		return { status: 200, json: async () => body };
	};
}

test("requests batches sequentially with the API shape and User-Agent", async () => {
	const codes = Array.from({ length: 60 }, (_, i) => `RD/KP01-JP${String(i).padStart(3, "0")}`);
	const calls = [];
	const naps = [];
	const bodies = [
		{ query: { redirects: [{ from: "RD/KP01-JP001", to: "Sevens Road Magician" }], pages: {} } },
		{ query: { redirects: [{ from: "RD/KP01-JP055", to: "Dragias the Striking Dragon" }], pages: {} } },
	];

	const targets = await fetchRedirectTargets(codes, {
		fetchImpl: cannedFetch(bodies, calls),
		sleep: async (ms) => naps.push(ms),
	});

	assert.equal(calls.length, 2);
	const first = calls[0].url;
	assert.equal(first.origin + first.pathname, "https://yugipedia.com/api.php");
	assert.equal(first.searchParams.get("action"), "query");
	assert.equal(first.searchParams.get("format"), "json");
	assert.ok(first.searchParams.has("redirects"));
	assert.deepEqual(first.searchParams.get("titles").split("|"), codes.slice(0, 50));
	assert.deepEqual(calls[1].url.searchParams.get("titles").split("|"), codes.slice(50));
	for (const { init } of calls) {
		assert.match(init.headers["User-Agent"], /^EvolutionAssetsBot\/1\.0 /);
	}
	assert.deepEqual(naps, [1100]);
	assert.deepEqual(targets, {
		"RD/KP01-JP001": "Sevens Road Magician",
		"RD/KP01-JP055": "Dragias the Striking Dragon",
	});
});

test("rejects on a non-200 response", async () => {
	await assert.rejects(
		fetchRedirectTargets(["RD/KP01-JP001"], {
			fetchImpl: async () => ({ status: 503, json: async () => ({}) }),
			sleep: async () => {},
		}),
		/503/,
	);
});

test("rejects on a body without a query object", async () => {
	await assert.rejects(
		fetchRedirectTargets(["RD/KP01-JP001"], {
			fetchImpl: async () => ({ status: 200, json: async () => ({ error: "maxlag" }) }),
			sleep: async () => {},
		}),
	);
});

test("rejects on a non-JSON body", async () => {
	await assert.rejects(
		fetchRedirectTargets(["RD/KP01-JP001"], {
			fetchImpl: async () => ({
				status: 200,
				json: async () => {
					throw new SyntaxError("Unexpected token <");
				},
			}),
			sleep: async () => {},
		}),
	);
});

// --- runDaily: the whole incremental run against injected IO ---

const blocks = {
	120281: [{ set: "RD/JF25", region: "JP" }],
	120282: [{ set: "RD/CA01", region: "JP" }],
};

test("writes the merged pages.json when the run mapped something new", async () => {
	const writes = [];
	const stats = await runDaily({
		ids: ["120100001", "120281007", "120282001", "120999001"],
		pages: { 120100001: "Road Magic - Explosion" },
		blocks,
		fetchImpl: async () => ({
			status: 200,
			json: async () => ({
				query: {
					redirects: [{ from: "RD/JF25-JP007", to: "Elemental HERO Neos (Rush Duel)" }],
					pages: { "-1": { ns: 0, title: "RD/CA01-JP001", missing: "" } },
				},
			}),
		}),
		sleep: async () => {},
		writePages: (text) => writes.push(text),
	});

	assert.deepEqual(stats.workList, ["120281007", "120282001", "120999001"]);
	assert.deepEqual(stats.mapped, { 120281007: "Elemental HERO Neos (Rush Duel)" });
	assert.deepEqual(stats.noBlock, ["120999001"]);
	assert.deepEqual(stats.unresolved, ["120282001"]);
	assert.deepEqual(stats.ambiguous, []);
	assert.deepEqual(writes, [
		`${JSON.stringify(
			{
				120100001: "Road Magic - Explosion",
				120281007: "Elemental HERO Neos (Rush Duel)",
			},
			null,
			2,
		)}\n`,
	]);
});

test("writes nothing when no id resolved", async () => {
	const writes = [];
	const stats = await runDaily({
		ids: ["120282001"],
		pages: {},
		blocks,
		fetchImpl: async () => ({ status: 200, json: async () => ({ query: { pages: {} } }) }),
		sleep: async () => {},
		writePages: (text) => writes.push(text),
	});

	assert.deepEqual(stats.mapped, {});
	assert.deepEqual(writes, []);
});

test("writes nothing when the API fails mid-run", async () => {
	const writes = [];
	await assert.rejects(
		runDaily({
			ids: ["120281007"],
			pages: {},
			blocks,
			fetchImpl: async () => ({ status: 500, json: async () => ({}) }),
			sleep: async () => {},
			writePages: (text) => writes.push(text),
		}),
	);
	assert.deepEqual(writes, []);
});

test("skips the network entirely when only no-block ids remain", async () => {
	const calls = [];
	const writes = [];
	const stats = await runDaily({
		ids: ["120999001"],
		pages: {},
		blocks,
		fetchImpl: async (url) => {
			calls.push(url);
			return { status: 200, json: async () => ({ query: { pages: {} } }) };
		},
		sleep: async () => {},
		writePages: (text) => writes.push(text),
	});

	assert.deepEqual(stats.noBlock, ["120999001"]);
	assert.deepEqual(calls, []);
	assert.deepEqual(writes, []);
});

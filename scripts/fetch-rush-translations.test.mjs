import assert from "node:assert/strict";
import test from "node:test";

import {
	askQuery,
	batchTitles,
	cachedTitleEntries,
	fetchTranslations,
	neededTitles,
	resultsByTitle,
	run,
	stripMarkup,
	translationFromPrintouts,
	uncoveredIds,
} from "./fetch-rush-translations.mjs";

// --- stripMarkup: SMW printout wikitext → the plain text we store ---
// Every fixture below is a verbatim string from the Yugipedia SMW store.

test("resolves a piped link to its label and a plain link to its target", () => {
	const lore =
		"[[Special Summon]] 1 [[Level 1 Monster Cards|Level 1]] [[Normal Monster]] from your [[Graveyard]] [[face-up]] to your field.";
	assert.equal(
		stripMarkup(lore),
		"Special Summon 1 Level 1 Normal Monster from your Graveyard face-up to your field.",
	);
});

test("keeps a colon inside a plain link target", () => {
	assert.equal(stripMarkup('[[Special Summon]] 1 "[[CAN:D]]"'), 'Special Summon 1 "CAN:D"');
});

test("drops the italic quotes around flavor text", () => {
	assert.equal(
		stripMarkup("''A fast and lethal creature with very dangerous claws.''"),
		"A fast and lethal creature with very dangerous claws.",
	);
});

test("turns <br /> into a newline", () => {
	assert.equal(
		stripMarkup(
			"''A jet-powered hawk that travels at the speed of sound.''<br /><br />" +
				'(This card is not treated as a "Cyber" card.)',
		),
		'A jet-powered hawk that travels at the speed of sound.\n\n(This card is not treated as a "Cyber" card.)',
	);
});

test("drops div tags and collapses the newline pile before them", () => {
	const lore =
		"''Donpen was born in [[wikipedia:Antarctica|Antarctica]] and raised in " +
		"[[wikipedia:Tokyo|Tokyo]]. He recently started [[Yu-Gi-Oh! Rush Duel|Rush Dueling]] " +
		"with Donko.''<br /><br /><br /><div style=\"text-align: right\">" +
		"©Pan Pacific International Holdings Corporation</div>";
	assert.equal(
		stripMarkup(lore),
		"Donpen was born in Antarctica and raised in Tokyo. He recently started Rush Dueling " +
			"with Donko.\n\n©Pan Pacific International Holdings Corporation",
	);
});

test("keeps literal single brackets — they are card text, not markup", () => {
	assert.equal(
		stripMarkup(
			"[[Draw a card|Draw]] 3 cards and show them. If 2 or more Level 7 monsters are among " +
				"them, gain [[LP]] equal to [the number of those Level 7 monsters] x 1500.",
		),
		"Draw 3 cards and show them. If 2 or more Level 7 monsters are among them, gain LP " +
			"equal to [the number of those Level 7 monsters] x 1500.",
	);
	assert.equal(
		stripMarkup("Abyss Kraken, the Abyssal Sea Serpent [L]"),
		"Abyss Kraken, the Abyssal Sea Serpent [L]",
	);
});

test("keeps a literal bracket span even when it nests a real link", () => {
	assert.equal(
		stripMarkup(
			"equal to [the number of monsters shuffled into the Deck to meet the " +
				"[[Activation condition|requirement]]] x 300",
		),
		"equal to [the number of monsters shuffled into the Deck to meet the requirement] x 300",
	);
});

// --- translationFromPrintouts: one SMW printouts object → one cache entry ---

test("reads all four fields and strips their markup", () => {
	const entry = translationFromPrintouts({
		"English name": ["1-Up"],
		Lore: [
			"[[Special Summon]] 1 [[Level 1 Monster Cards|Level 1]] [[Normal Monster]] from your [[Graveyard]] [[face-up]] to your field.",
		],
		"Spanish name": ["1 más"],
		"Spanish lore": [
			"Invoca de Modo Especial, desde tu Cementerio, 1 Monstruo Normal de Nivel 1 boca arriba en tu Campo.",
		],
		ATK: [],
		DEF: [],
		Level: [],
	});
	assert.deepEqual(entry, {
		en: "1-Up",
		en_lore:
			"Special Summon 1 Level 1 Normal Monster from your Graveyard face-up to your field.",
		es: "1 más",
		es_lore:
			"Invoca de Modo Especial, desde tu Cementerio, 1 Monstruo Normal de Nivel 1 boca arriba en tu Campo.",
	});
});

test("stores an empty string for a field the wiki does not have", () => {
	const entry = translationFromPrintouts({
		"English name": ["Nekogal #2"],
		Lore: ["''A fast and lethal creature with very dangerous claws.''"],
		"Spanish name": [],
		"Spanish lore": [],
	});
	assert.deepEqual(entry, {
		en: "Nekogal #2",
		en_lore: "A fast and lethal creature with very dangerous claws.",
		es: "",
		es_lore: "",
	});
});

test("treats an absent printout key like an empty one", () => {
	assert.deepEqual(translationFromPrintouts({ "English name": ["Charging Remora"] }), {
		en: "Charging Remora",
		en_lore: "",
		es: "",
		es_lore: "",
	});
});

// --- uncoveredIds: the work list is whatever translations.json does not cover ---

test("keeps only ids without a translations entry, in pages order", () => {
	const pages = { 120100001: "A", 120100002: "B", 120100003: "C" };
	const translations = { 120100002: { en: "B", en_lore: "", es: "", es_lore: "" } };
	assert.deepEqual(uncoveredIds(pages, translations), ["120100001", "120100003"]);
});

// --- cachedTitleEntries: a reprint reuses the entry its sibling id already has ---

test("indexes cached entries by title through pages.json", () => {
	const pages = { 120102001: "Thousand Dragon (Rush Duel)", 120200001: "Thousand Dragon (Rush Duel)" };
	const entry = { en: "Thousand Dragon", en_lore: "x", es: "", es_lore: "" };
	assert.deepEqual(cachedTitleEntries(pages, { 120102001: entry }), {
		"Thousand Dragon (Rush Duel)": entry,
	});
});

// --- neededTitles: distinct titles still without data, sibling coverage counts ---

test("lists each uncovered title once and skips titles a sibling already covers", () => {
	const pages = {
		120100001: "Road Magic - Explosion",
		120100002: "Star Traleo",
		120100003: "Star Traleo",
		120100004: "Thousand Dragon (Rush Duel)",
	};
	const translations = { 120100004: { en: "Thousand Dragon", en_lore: "", es: "", es_lore: "" } };
	assert.deepEqual(neededTitles(pages, translations), [
		"Road Magic - Explosion",
		"Star Traleo",
	]);
});

// --- batchTitles: at most 20 disjunction conditions per ask request ---

test("splits titles into batches of at most 20", () => {
	const titles = Array.from({ length: 45 }, (_, i) => `Card ${i}`);
	const batches = batchTitles(titles);
	assert.deepEqual(
		batches.map((b) => b.length),
		[20, 20, 5],
	);
	assert.equal(batches[0][0], "Card 0");
	assert.equal(batches[2][4], "Card 44");
});

// --- askQuery: the SMW disjunction with `#` stripped from every condition ---

test("joins hash-stripped conditions with OR and asks for the four printouts", () => {
	assert.equal(
		askQuery(["Jinzo #7.7", "1-Up"]),
		"[[Jinzo 7.7]] OR [[1-Up]]|?English name|?Lore|?Spanish name|?Spanish lore|limit=50",
	);
});

// --- resultsByTitle: response keys map back to the requested titles ---

test("maps a result back to its requested title through the hash-stripped key", () => {
	const body = {
		query: {
			results: {
				"Jinzo 7.7": {
					printouts: { "English name": ["Jinzo #7.7"], Lore: ["x"] },
					fulltext: "Jinzo 7.7",
				},
			},
		},
	};
	assert.deepEqual(resultsByTitle(["Jinzo #7.7", "Dynamight Dino Dynamix"], body), {
		"Jinzo #7.7": { "English name": ["Jinzo #7.7"], Lore: ["x"] },
	});
});

test("throws when the answer has no results object", () => {
	assert.throws(() => resultsByTitle(["1-Up"], { query: {} }), /results/);
});

test("accepts the empty-result array SMW sends instead of an object", () => {
	assert.deepEqual(resultsByTitle(["Dynamight Dino Dynamix"], { query: { results: [] } }), {});
});

// --- fetchTranslations: the sequential, rate-limited network loop ---

function cannedFetch(bodiesByCall, calls) {
	return async (url, init) => {
		calls.push({ url: new URL(url), init });
		const body = bodiesByCall[calls.length - 1];
		return { status: 200, json: async () => body };
	};
}

const printoutsOf = (en) => ({
	"English name": [en],
	Lore: [],
	"Spanish name": [],
	"Spanish lore": [],
});

test("requests batches sequentially with the ask shape and User-Agent", async () => {
	const titles = Array.from({ length: 25 }, (_, i) => `Card ${i}`);
	const calls = [];
	const naps = [];
	const bodies = [
		{
			query: {
				results: Object.fromEntries(
					titles.slice(0, 20).map((t) => [t, { printouts: printoutsOf(t) }]),
				),
			},
		},
		{
			query: {
				results: Object.fromEntries(
					titles.slice(20).map((t) => [t, { printouts: printoutsOf(t) }]),
				),
			},
		},
	];

	const { printoutsByTitle, missing } = await fetchTranslations(titles, {
		fetchImpl: cannedFetch(bodies, calls),
		sleep: async (ms) => naps.push(ms),
	});

	assert.equal(calls.length, 2);
	const first = calls[0].url;
	assert.equal(first.origin + first.pathname, "https://yugipedia.com/api.php");
	assert.equal(first.searchParams.get("action"), "ask");
	assert.equal(first.searchParams.get("format"), "json");
	assert.equal(first.searchParams.get("query"), askQuery(titles.slice(0, 20)));
	assert.equal(calls[1].url.searchParams.get("query"), askQuery(titles.slice(20)));
	for (const { init } of calls) {
		assert.match(init.headers["User-Agent"], /^EvolutionAssetsBot\/1\.0 /);
	}
	assert.deepEqual(naps, [1100]);
	assert.equal(Object.keys(printoutsByTitle).length, 25);
	assert.deepEqual(missing, []);
});

test("retries a leftover title solo and adopts its redirect-keyed result", async () => {
	const calls = [];
	const bodies = [
		{ query: { results: {} } },
		{
			query: {
				results: {
					"Charging Remora": { printouts: printoutsOf("Charging Remora") },
				},
			},
		},
		{ query: { results: [] } },
	];

	const { printoutsByTitle, missing } = await fetchTranslations(
		["Charge Remora", "Dynamight Dino Dynamix"],
		{ fetchImpl: cannedFetch(bodies, calls), sleep: async () => {} },
	);

	assert.equal(calls.length, 3);
	assert.equal(calls[1].url.searchParams.get("query"), askQuery(["Charge Remora"]));
	assert.deepEqual(printoutsByTitle, { "Charge Remora": printoutsOf("Charging Remora") });
	assert.deepEqual(missing, ["Dynamight Dino Dynamix"]);
});

test("rejects on a non-200 response", async () => {
	await assert.rejects(
		fetchTranslations(["1-Up"], {
			fetchImpl: async () => ({ status: 503, json: async () => ({}) }),
			sleep: async () => {},
		}),
		/503/,
	);
});

test("rejects on a non-JSON body", async () => {
	await assert.rejects(
		fetchTranslations(["1-Up"], {
			fetchImpl: async () => ({
				status: 200,
				json: async () => {
					throw new SyntaxError("nope");
				},
			}),
			sleep: async () => {},
		}),
		/non-JSON/,
	);
});

test("issues no request when every title is already covered", async () => {
	const { printoutsByTitle, missing } = await fetchTranslations([], {
		fetchImpl: async () => {
			throw new Error("must not fetch");
		},
		sleep: async () => {},
	});
	assert.deepEqual(printoutsByTitle, {});
	assert.deepEqual(missing, []);
});

// --- run: seed first, fetch the rest, omit dataless titles, write sorted ---

test("seeds from the dump, fetches the rest, and writes a sorted cache", async () => {
	const pages = {
		120100002: "Fetched Card",
		120100001: "1-Up",
		120100003: "Dynamight Dino Dynamix",
		120100004: "1-Up",
	};
	const seed = {
		"1-Up": {
			printouts: {
				"English name": ["1-Up"],
				Lore: ["[[Special Summon]] 1 monster."],
				"Spanish name": ["1 más"],
				"Spanish lore": ["Invoca 1 monstruo."],
			},
		},
	};
	const bodies = [
		{ query: { results: { "Fetched Card": { printouts: printoutsOf("Fetched Card") } } } },
		{ query: { results: [] } },
	];
	const calls = [];
	const written = [];

	const stats = await run({
		pages,
		translations: {},
		seed,
		fetchImpl: cannedFetch(bodies, calls),
		sleep: async () => {},
		writeTranslations: (text) => written.push(text),
	});

	assert.equal(written.length, 1);
	const parsed = JSON.parse(written[0]);
	assert.deepEqual(Object.keys(parsed), ["120100001", "120100002", "120100004"]);
	assert.deepEqual(parsed["120100001"], {
		en: "1-Up",
		en_lore: "Special Summon 1 monster.",
		es: "1 más",
		es_lore: "Invoca 1 monstruo.",
	});
	assert.deepEqual(parsed["120100004"], parsed["120100001"]);
	assert.deepEqual(parsed["120100002"], {
		en: "Fetched Card",
		en_lore: "",
		es: "",
		es_lore: "",
	});
	assert.ok(written[0].endsWith("}\n"));

	assert.equal(stats.idsTotal, 4);
	assert.deepEqual(stats.workList, ["120100001", "120100002", "120100003", "120100004"]);
	assert.equal(stats.seededIds, 2);
	assert.equal(stats.fetchedIds, 1);
	assert.deepEqual(stats.missing, ["Dynamight Dino Dynamix"]);
	assert.deepEqual(stats.coverage, { en: 3, en_lore: 2, es: 2, es_lore: 2 });
});

test("reuses a sibling's cached entry without touching the network", async () => {
	const entry = { en: "1-Up", en_lore: "x", es: "", es_lore: "" };
	const written = [];

	const stats = await run({
		pages: { 120100001: "1-Up", 120100009: "1-Up" },
		translations: { 120100001: entry },
		seed: {},
		fetchImpl: async () => {
			throw new Error("must not fetch");
		},
		sleep: async () => {},
		writeTranslations: (text) => written.push(text),
	});

	assert.deepEqual(JSON.parse(written[0]), { 120100001: entry, 120100009: entry });
	assert.equal(stats.reusedIds, 1);
});

test("aborts without writing when the fetch fails", async () => {
	const written = [];
	await assert.rejects(
		run({
			pages: { 120100001: "1-Up" },
			translations: {},
			seed: {},
			fetchImpl: async () => ({ status: 500, json: async () => ({}) }),
			sleep: async () => {},
			writeTranslations: (text) => written.push(text),
		}),
		/500/,
	);
	assert.deepEqual(written, []);
});

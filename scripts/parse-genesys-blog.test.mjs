import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import { test } from "node:test";

import {
	applyBlogDeltas,
	extractGenesysPostUrls,
	extractPostDate,
	parseGenesysBlogPost,
} from "./parse-genesys-blog.mjs";

// -- extractGenesysPostUrls ---------------------------------------------------

test("extracts genesys post URLs in document order, deduplicated", () => {
	const html = `
		<a href="https://yugiohblog.konami.com/2026/genesys/magnificent-monsters-points-update/">A</a>
		<a href="https://yugiohblog.konami.com/2026/genesys/genesys-june-points-update/">B</a>
		<a href="https://yugiohblog.konami.com/2026/genesys/magnificent-monsters-points-update/">A again</a>
	`;
	assert.deepEqual(extractGenesysPostUrls(html), [
		"https://yugiohblog.konami.com/2026/genesys/magnificent-monsters-points-update/",
		"https://yugiohblog.konami.com/2026/genesys/genesys-june-points-update/",
	]);
});

test("ignores non-genesys and category URLs", () => {
	const html = `
		<a href="https://yugiohblog.konami.com/2026/event-information/latin-america-genesys-remote-duel-ycs-2026-main-event-information/">event</a>
		<a href="https://yugiohblog.konami.com/category/genesys/">category</a>
		<a href="https://yugiohblog.konami.com/tag/genesys/">tag</a>
		<a href="https://yugiohblog.konami.com/2026/ycs/2026-08-quebec/genesys-format-1st-place-after-swiss-duelist/">ycs</a>
	`;
	assert.deepEqual(extractGenesysPostUrls(html), []);
});

// -- parseGenesysBlogPost -----------------------------------------------------

test("parses new-card lines (`Name -> N`) with null oldPoints", () => {
	const html = `<p class="wp-block-paragraph">Kuriboh &#8211; Multiply! -> 10<br>Dark Magical Curtain -> 30</p>`;
	assert.deepEqual(parseGenesysBlogPost(html), [
		{ name: "Kuriboh – Multiply!", oldPoints: null, newPoints: 10 },
		{ name: "Dark Magical Curtain", oldPoints: null, newPoints: 30 },
	]);
});

test("keeps trailing digits attached to the name (LV10 case)", () => {
	const html = `<p>Winged Kuriboh Sabatiel LV10 -> 7</p>`;
	assert.deepEqual(parseGenesysBlogPost(html), [
		{ name: "Winged Kuriboh Sabatiel LV10", oldPoints: null, newPoints: 7 },
	]);
});

test("parses adjustment lines (`Name OLD->NEW`) with numeric oldPoints", () => {
	const html = `<p>Number 86: Heroic Champion &#8211; Rhongomyniad 68-&gt;100</p><p>D.D. Crow 1-&gt;2<br>Whisker Blitzclique 0-&gt;6</p>`;
	assert.deepEqual(parseGenesysBlogPost(html), [
		{ name: "Number 86: Heroic Champion – Rhongomyniad", oldPoints: 68, newPoints: 100 },
		{ name: "D.D. Crow", oldPoints: 1, newPoints: 2 },
		{ name: "Whisker Blitzclique", oldPoints: 0, newPoints: 6 },
	]);
});

test("ignores prose lines, even when mixed into the same paragraph", () => {
	const html = `<p>These point changes will take effect on Monday.</p>
		<p>Elfnote Lucina 0-&gt;1<br><br>The Clown Crew's antics have steadily increased.<br><br>Clown Crew Flair 0-&gt;5</p>`;
	assert.deepEqual(parseGenesysBlogPost(html), [
		{ name: "Elfnote Lucina", oldPoints: 0, newPoints: 1 },
		{ name: "Clown Crew Flair", oldPoints: 0, newPoints: 5 },
	]);
});

test("parses bare point lines (`Name N`) with null oldPoints", () => {
	const html = `<p>Swiftwind Panther Warrior 3<br>Dark Time Wizard 5<br>Theorealized Medius 80</p>`;
	assert.deepEqual(parseGenesysBlogPost(html), [
		{ name: "Swiftwind Panther Warrior", oldPoints: null, newPoints: 3 },
		{ name: "Dark Time Wizard", oldPoints: null, newPoints: 5 },
		{ name: "Theorealized Medius", oldPoints: null, newPoints: 80 },
	]);
});

test("parses bare point lines whose names carry punctuation and trailing tokens", () => {
	const html = `<p>Alligator&#8217;s Dragon Knight 4<br>Number 104: Masquerade V 20<br>CXyz Hope Chaos Barian Dragon 100<br>Destiny HERO &#8211; Destro-Dogma 10<br>Ars Magna &#8220;Citrinitas&#8221; 10<br>Hey, Space Trunade! 11<br>Verre, the Maid of Endymion 5</p>`;
	assert.deepEqual(parseGenesysBlogPost(html), [
		{ name: "Alligator’s Dragon Knight", oldPoints: null, newPoints: 4 },
		{ name: "Number 104: Masquerade V", oldPoints: null, newPoints: 20 },
		{ name: "CXyz Hope Chaos Barian Dragon", oldPoints: null, newPoints: 100 },
		{ name: "Destiny HERO – Destro-Dogma", oldPoints: null, newPoints: 10 },
		{ name: "Ars Magna “Citrinitas”", oldPoints: null, newPoints: 10 },
		{ name: "Hey, Space Trunade!", oldPoints: null, newPoints: 11 },
		{ name: "Verre, the Maid of Endymion", oldPoints: null, newPoints: 5 },
	]);
});

test("parses a single-line bare point paragraph", () => {
	const html = `<p>Monster Arms of Atlantis 10</p>`;
	assert.deepEqual(parseGenesysBlogPost(html), [
		{ name: "Monster Arms of Atlantis", oldPoints: null, newPoints: 10 },
	]);
});

test("keeps trailing digits attached to the name in bare point lines (LV10 case)", () => {
	const html = `<p>Cyber Dragon LV10 7</p>`;
	assert.deepEqual(parseGenesysBlogPost(html), [
		{ name: "Cyber Dragon LV10", oldPoints: null, newPoints: 7 },
	]);
});

test("ignores prose paragraphs that carry no point lines", () => {
	const html = `<p>The Beyond the Brave Premiere! events aren&#8217;t until next week, but to hold you over until then, we present the initial Genesys points for Beyond the Brave.</p>
		<p>The OP schedule is pretty tight for this, but expect YCS Ecuador to play with the current points and then Houston to play with the new adjustments.</p>`;
	assert.deepEqual(parseGenesysBlogPost(html), []);
});

test("does not promote a prose line sharing a paragraph with bare point lines", () => {
	// The bare `Name N` shape is only honored when every non-empty line of the
	// paragraph is a point line, so one prose neighbour disarms the whole block
	// rather than letting the sentence through as a card.
	//
	// Known tradeoff: a prose sentence that ends in a standalone number and sits
	// alone in its own paragraph is indistinguishable from a bare point line and
	// would be read as one. Konami's prose paragraphs end in sentence
	// punctuation, so this has not been observed in practice.
	const html = `<p>These point changes take effect on Monday.<br>Dark Time Wizard 5</p>`;
	assert.deepEqual(parseGenesysBlogPost(html), []);
});

test("still parses arrow lines in a paragraph mixed with prose and bare lines", () => {
	const html = `<p>Elfnote Lucina 0-&gt;1<br>These point changes take effect on Monday.<br>Dark Time Wizard 5</p>`;
	assert.deepEqual(parseGenesysBlogPost(html), [
		{ name: "Elfnote Lucina", oldPoints: 0, newPoints: 1 },
	]);
});

test("returns an empty list for posts without point lines", () => {
	const html = `<p>Standings after day 1 of the Genesys Championship.</p>`;
	assert.deepEqual(parseGenesysBlogPost(html), []);
});

// -- extractPostDate ----------------------------------------------------------

test("extracts the publication date from the entry-date time tag", () => {
	const html = `<time itemprop="August 24, 2026" class="entry-date"></time>`;
	assert.equal(extractPostDate(html), "2026-08-24");
});

test("returns null when the date tag is missing or unparseable", () => {
	assert.equal(extractPostDate("<p>no date</p>"), null);
	assert.equal(extractPostDate(`<time itemprop="not a date" class="entry-date"></time>`), null);
});

// -- applyBlogDeltas ----------------------------------------------------------

const NOW = Date.parse("2026-08-25T12:00:00Z");

const freeze = (value) => {
	if (value !== null && typeof value === "object") {
		Object.values(value).forEach(freeze);
		Object.freeze(value);
	}
	return value;
};

test("leaves converged deltas alone and marks the post spent", () => {
	const base = freeze([{ name: "A", points: 5, code: 1 }]);
	const entries = freeze([
		{ url: "u", status: "pending", deltas: [{ name: "A", code: 1, oldPoints: null, newPoints: 5 }] },
	]);
	const { cards, state, conflicts } = applyBlogDeltas(base, entries);
	assert.deepEqual(cards, [{ name: "A", points: 5, code: 1 }]);
	assert.equal(state[0].status, "spent");
	assert.deepEqual(conflicts, []);
});

test("adds cards missing from the base list while the post is fresh", () => {
	const base = freeze([{ name: "A", points: 5, code: 1 }]);
	const entries = freeze([
		{
			url: "u",
			status: "pending",
			publishedAt: "2026-08-24",
			deltas: [{ name: "New", code: 99, oldPoints: null, newPoints: 7 }],
		},
	]);
	const { cards, state } = applyBlogDeltas(base, entries, { now: NOW });
	assert.deepEqual(cards.find((c) => c.code === 99), {
		name: "New",
		points: 7,
		code: 99,
		sourceUrl: "u",
	});
	assert.equal(state[0].status, "pending");
});

test("treats an absent card from a stale post as converged (points were removed)", () => {
	const base = freeze([{ name: "A", points: 5, code: 1 }]);
	const entries = freeze([
		{
			url: "u",
			status: "pending",
			publishedAt: "2026-06-01",
			deltas: [{ name: "Removed", code: 99, oldPoints: null, newPoints: 10 }],
		},
	]);
	const { cards, state, conflicts } = applyBlogDeltas(base, entries, { now: NOW });
	assert.equal(cards.find((c) => c.code === 99), undefined);
	assert.equal(state[0].status, "spent");
	assert.deepEqual(conflicts, []);
});

test("treats an absent card as converged when the post date is unknown", () => {
	const base = freeze([{ name: "A", points: 5, code: 1 }]);
	const entries = freeze([
		{ url: "u", status: "pending", deltas: [{ name: "New", code: 99, oldPoints: null, newPoints: 7 }] },
	]);
	const { cards, state } = applyBlogDeltas(base, entries, { now: NOW });
	assert.equal(cards.find((c) => c.code === 99), undefined);
	assert.equal(state[0].status, "spent");
});

test("applies old->new when the base still holds the old value", () => {
	const base = freeze([{ name: "A", points: 5, code: 1 }]);
	const entries = freeze([
		{ url: "u", status: "pending", deltas: [{ name: "A", code: 1, oldPoints: 5, newPoints: 8 }] },
	]);
	const { cards, state, conflicts } = applyBlogDeltas(base, entries);
	assert.equal(cards.find((c) => c.code === 1).points, 8);
	assert.equal(state[0].status, "pending");
	assert.deepEqual(conflicts, []);
});

test("keeps the base value and records a conflict when the table is newer", () => {
	const base = freeze([{ name: "A", points: 7, code: 1 }]);
	const entries = freeze([
		{ url: "u", status: "pending", deltas: [{ name: "A", code: 1, oldPoints: 5, newPoints: 8 }] },
	]);
	const { cards, state, conflicts } = applyBlogDeltas(base, entries);
	assert.equal(cards.find((c) => c.code === 1).points, 7);
	assert.equal(conflicts.length, 1);
	assert.equal(conflicts[0].code, 1);
	assert.equal(state[0].status, "spent");
});

test("treats a new-card delta as a conflict when the base holds a different value", () => {
	const base = freeze([{ name: "A", points: 5, code: 1 }]);
	const entries = freeze([
		{ url: "u", status: "pending", deltas: [{ name: "A", code: 1, oldPoints: null, newPoints: 9 }] },
	]);
	const { cards, conflicts } = applyBlogDeltas(base, entries);
	assert.equal(cards.find((c) => c.code === 1).points, 5);
	assert.equal(conflicts.length, 1);
});

test("converges an unresolved (null code) delta once the post can no longer act", () => {
	const base = freeze([{ name: "A", points: 5, code: 1 }]);
	const entries = freeze([
		{
			url: "u",
			status: "pending",
			deltas: [
				{ name: "A", code: 1, oldPoints: null, newPoints: 5 },
				{ name: "Unknown", code: null, oldPoints: null, newPoints: 3 },
			],
		},
	]);
	const { cards, state } = applyBlogDeltas(base, entries);
	assert.deepEqual(cards, [{ name: "A", points: 5, code: 1 }]);
	assert.equal(state[0].status, "spent");
});

test("keeps a fresh post pending while an unresolved delta may still resolve", () => {
	const base = freeze([{ name: "A", points: 5, code: 1 }]);
	const entries = freeze([
		{
			url: "u",
			status: "pending",
			publishedAt: "2026-09-22",
			deltas: [
				{ name: "A", code: 1, oldPoints: null, newPoints: 5 },
				{ name: "Unknown", code: null, oldPoints: null, newPoints: 3 },
			],
		},
	]);
	const { state } = applyBlogDeltas(base, entries, { now: Date.parse("2026-09-23") });
	assert.equal(state[0].status, "pending");
});

test("converges an unresolved delta once the post is past the freshness window", () => {
	const base = freeze([{ name: "A", points: 5, code: 1 }]);
	const entries = freeze([
		{
			url: "u",
			status: "pending",
			publishedAt: "2026-01-01",
			deltas: [
				{ name: "A", code: 1, oldPoints: null, newPoints: 5 },
				{ name: "Unknown", code: null, oldPoints: null, newPoints: 3 },
			],
		},
	]);
	const { state } = applyBlogDeltas(base, entries, { now: Date.parse("2026-09-23") });
	assert.equal(state[0].status, "spent");
});

test("applies deltas down to zero points", () => {
	const base = freeze([{ name: "A", points: 5, code: 1 }]);
	const entries = freeze([
		{ url: "u", status: "pending", deltas: [{ name: "A", code: 1, oldPoints: 5, newPoints: 0 }] },
	]);
	const { cards } = applyBlogDeltas(base, entries);
	assert.equal(cards.find((c) => c.code === 1).points, 0);
});

test("ignores entries that are not pending", () => {
	const base = freeze([{ name: "A", points: 5, code: 1 }]);
	const entries = freeze([
		{ url: "spent", status: "spent", deltas: [{ name: "A", code: 1, oldPoints: 5, newPoints: 9 }] },
		{ url: "none", status: "no-deltas", deltas: [] },
	]);
	const { cards, state } = applyBlogDeltas(base, entries);
	assert.equal(cards.find((c) => c.code === 1).points, 5);
	assert.deepEqual(state.map((e) => e.status), ["spent", "no-deltas"]);
});

test("stamps the applying post's URL on updates, never on converged or conflict cards", () => {
	const base = freeze([
		{ name: "A", points: 5, code: 1 },
		{ name: "B", points: 3, code: 2 },
		{ name: "C", points: 9, code: 3 },
	]);
	const entries = freeze([
		{
			url: "u",
			status: "pending",
			deltas: [
				{ name: "A", code: 1, oldPoints: 5, newPoints: 8 },
				{ name: "B", code: 2, oldPoints: null, newPoints: 3 },
				{ name: "C", code: 3, oldPoints: 4, newPoints: 6 },
			],
		},
	]);
	const { cards } = applyBlogDeltas(base, entries);
	assert.equal(cards.find((c) => c.code === 1).sourceUrl, "u");
	assert.equal(cards.find((c) => c.code === 2).sourceUrl, undefined);
	assert.equal(cards.find((c) => c.code === 3).sourceUrl, undefined);
});

// -- supersession between posts ------------------------------------------------

test("a newer removal supersedes an older fresh addition of the same card", () => {
	const base = freeze([{ name: "A", points: 5, code: 1 }]);
	const entries = freeze([
		{
			url: "old",
			status: "pending",
			publishedAt: "2026-08-01",
			deltas: [{ name: "X", code: 99, oldPoints: null, newPoints: 10 }],
		},
		{
			url: "new",
			status: "pending",
			publishedAt: "2026-08-20",
			deltas: [{ name: "X", code: 99, oldPoints: 10, newPoints: 0 }],
		},
	]);
	const { cards, state, conflicts } = applyBlogDeltas(base, entries, { now: NOW });
	assert.equal(cards.find((c) => c.code === 99), undefined);
	assert.deepEqual(state.map((e) => e.status), ["spent", "spent"]);
	assert.deepEqual(conflicts, []);
});

test("a spent newer post still supersedes a pending older one", () => {
	const base = freeze([{ name: "A", points: 5, code: 1 }]);
	const entries = freeze([
		{
			url: "old",
			status: "pending",
			publishedAt: "2026-08-01",
			deltas: [{ name: "X", code: 99, oldPoints: null, newPoints: 10 }],
		},
		{
			url: "new",
			status: "spent",
			publishedAt: "2026-08-20",
			deltas: [{ name: "X", code: 99, oldPoints: 10, newPoints: 0 }],
		},
	]);
	const { cards, state } = applyBlogDeltas(base, entries, { now: NOW });
	assert.equal(cards.find((c) => c.code === 99), undefined);
	assert.deepEqual(state.map((e) => e.status), ["spent", "spent"]);
});

test("an undated entry loses to a dated one", () => {
	const base = freeze([{ name: "A", points: 5, code: 1 }]);
	const entries = freeze([
		{
			url: "undated",
			status: "pending",
			deltas: [{ name: "X", code: 99, oldPoints: null, newPoints: 7 }],
		},
		{
			url: "dated",
			status: "pending",
			publishedAt: "2026-08-24",
			deltas: [{ name: "X", code: 99, oldPoints: null, newPoints: 9 }],
		},
	]);
	const { cards, state } = applyBlogDeltas(base, entries, { now: NOW });
	assert.equal(cards.find((c) => c.code === 99).points, 9);
	assert.equal(cards.find((c) => c.code === 99).sourceUrl, "dated");
	assert.deepEqual(state.map((e) => e.status), ["spent", "pending"]);
});

test("a publication-date tie is broken by later array position", () => {
	const base = freeze([{ name: "A", points: 5, code: 1 }]);
	const entries = freeze([
		{
			url: "first",
			status: "pending",
			publishedAt: "2026-08-24",
			deltas: [{ name: "A", code: 1, oldPoints: 5, newPoints: 8 }],
		},
		{
			url: "second",
			status: "pending",
			publishedAt: "2026-08-24",
			deltas: [{ name: "A", code: 1, oldPoints: 5, newPoints: 9 }],
		},
	]);
	const { cards, conflicts } = applyBlogDeltas(base, entries, { now: NOW });
	assert.equal(cards.find((c) => c.code === 1).points, 9);
	assert.deepEqual(conflicts, []);
});

test("supersession is per-card: unrelated cards in the older post still apply", () => {
	const base = freeze([{ name: "A", points: 5, code: 1 }]);
	const entries = freeze([
		{
			url: "old",
			status: "pending",
			publishedAt: "2026-08-01",
			deltas: [
				{ name: "X", code: 99, oldPoints: null, newPoints: 10 },
				{ name: "A", code: 1, oldPoints: 5, newPoints: 6 },
			],
		},
		{
			url: "new",
			status: "pending",
			publishedAt: "2026-08-20",
			deltas: [{ name: "X", code: 99, oldPoints: 10, newPoints: 0 }],
		},
	]);
	const { cards, state } = applyBlogDeltas(base, entries, { now: NOW });
	assert.equal(cards.find((c) => c.code === 99), undefined);
	assert.equal(cards.find((c) => c.code === 1).points, 6);
	assert.deepEqual(state.map((e) => e.status), ["pending", "spent"]);
});

test("does not mutate its inputs", () => {
	const base = [{ name: "A", points: 5, code: 1 }];
	const entries = [
		{ url: "u", status: "pending", deltas: [{ name: "A", code: 1, oldPoints: 5, newPoints: 8 }] },
	];
	applyBlogDeltas(freeze(base), freeze(entries));
	assert.equal(base[0].points, 5);
	assert.equal(entries[0].status, "pending");
});

// -- validation against saved real pages (skipped when absent) ----------------

const SCRATCHPAD =
	"/tmp/claude-1000/-home-diango-code-evolution-evolution-assets/4b1de6c8-43f0-45df-9067-315fb0557a17/scratchpad";
const REAL_POST = `${SCRATCHPAD}/konami-post.html`;
const REAL_CATEGORY = `${SCRATCHPAD}/genesys-cat.html`;

const INITIAL_POINTS_SCRATCHPAD =
	"/tmp/claude-1000/-home-diango-code-evolution-evolution-assets/ff1a777c-b73f-43d7-963d-222e2964dcc7/scratchpad";
const REAL_INITIAL_POINTS_POST = `${INITIAL_POINTS_SCRATCHPAD}/post.html`;

test("parses the real Magnificent Monsters post", { skip: !existsSync(REAL_POST) }, () => {
	const deltas = parseGenesysBlogPost(readFileSync(REAL_POST, "utf-8"));
	assert.equal(deltas.length, 10);
	assert.deepEqual(
		deltas.find((d) => d.name === "Starjunk Synchron"),
		{ name: "Starjunk Synchron", oldPoints: null, newPoints: 1 },
	);
	assert.ok(deltas.every((d) => d.oldPoints === null));
});

test("extracts the date from the real Magnificent Monsters post", { skip: !existsSync(REAL_POST) }, () => {
	assert.equal(extractPostDate(readFileSync(REAL_POST, "utf-8")), "2026-08-24");
});

test(
	"parses the real Beyond the Brave initial-points post",
	{ skip: !existsSync(REAL_INITIAL_POINTS_POST) },
	() => {
		const deltas = parseGenesysBlogPost(readFileSync(REAL_INITIAL_POINTS_POST, "utf-8"));
		assert.equal(deltas.length, 31);
		assert.ok(deltas.every((d) => d.oldPoints === null));
		assert.deepEqual(
			deltas.find((d) => d.name === "CXyz Hope Chaos Barian Dragon"),
			{ name: "CXyz Hope Chaos Barian Dragon", oldPoints: null, newPoints: 100 },
		);
		assert.deepEqual(
			deltas.find((d) => d.name === "Number 104: Masquerade V"),
			{ name: "Number 104: Masquerade V", oldPoints: null, newPoints: 20 },
		);
		// The post opens and closes with prose paragraphs; none of them may leak in.
		assert.ok(deltas.every((d) => !d.name.includes("Genesys points for")));
	},
);

test("extracts post URLs from the real category page", { skip: !existsSync(REAL_CATEGORY) }, () => {
	const urls = extractGenesysPostUrls(readFileSync(REAL_CATEGORY, "utf-8"));
	assert.ok(urls.length >= 10, `expected >= 10 urls, got ${urls.length}`);
	assert.ok(urls.every((u) => /^https:\/\/yugiohblog\.konami\.com\/\d{4}\/genesys\/[^/]+\/$/.test(u)));
});

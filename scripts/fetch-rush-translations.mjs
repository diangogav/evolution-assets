// Maintains rush/translations.json — ygopro card id → en/es names and lores —
// from Yugipedia's SMW store, for every id rush/pages.json maps to a page
// title. Stored text is plain: links, italic quotes, and layout HTML are
// stripped so the cdb build step can drop it straight into card text.
//
// The run is incremental and idempotent: only ids without a cached entry are
// worked, a reprint reuses the entry a sibling id already holds for the same
// title, and a bootstrap run may seed titles from a pre-fetched SMW dump
// (directory argument with yugipedia.json, same pattern as
// derive-rush-pages.mjs). Any network or API failure aborts the whole run
// without touching translations.json — same contract as
// fetch-rush-code-pages.mjs.
//
// Titles are queried through `action=ask` disjunctions. A `#` in a stored
// title is display-only — MediaWiki forbids `#` in page titles, so the real
// page drops it (`Jinzo #7.7` lives at `Jinzo 7.7`) — and SMW's own
// `smwbrowse` cannot take it either, because `#` is its subject-serialization
// separator (verified live: browsing `Jinzo_#7.7` answers for `Jinzo`).
// Conditions therefore use the hash-stripped title and results map back to the
// stored one. A title whose result comes back under a different key — a
// redirect, like `Charge Remora` → `Charging Remora` — is retried solo, where
// the single result is unambiguous.

import { existsSync, readFileSync, writeFileSync } from "node:fs";

import { renderPagesJson } from "./derive-rush-pages.mjs";
import { reportFragment } from "./run-report.mjs";

const API_URL = "https://yugipedia.com/api.php";
const USER_AGENT =
	"EvolutionAssetsBot/1.0 (https://github.com/evolutionygo; card translations)";
const BATCH_SIZE = 20;
const REQUEST_INTERVAL_MS = 1100;
const PRINTOUTS = ["English name", "Lore", "Spanish name", "Spanish lore"];

/**
 * SMW printout wikitext → the plain text we store. The rules cover every
 * shape present in the store: piped and plain links, `''` flavor-text
 * italics, `<br />` line breaks, and the right-aligned `<div>` around
 * mascot-card copyright lines. Single square brackets are card text
 * (`[the number of ...]`, `[L]`) and stay. Three or more newlines collapse to
 * a paragraph break.
 */
export function stripMarkup(text) {
	return text
		.replace(/\[\[(?:[^[\]|]*\|)*([^[\]|]*)\]\]/g, "$1")
		.replaceAll("''", "")
		.replace(/<br\s*\/?>/gi, "\n")
		.replace(/<\/?div[^>]*>/gi, "")
		.replace(/\n{3,}/g, "\n\n")
		.trim();
}

/** One SMW printouts object → one cache entry; an absent field is "". */
export function translationFromPrintouts(printouts) {
	const field = (name) => {
		const value = printouts[name]?.[0];
		return typeof value === "string" ? stripMarkup(value) : "";
	};
	return {
		en: field("English name"),
		en_lore: field("Lore"),
		es: field("Spanish name"),
		es_lore: field("Spanish lore"),
	};
}

/** The ids translations.json does not cover yet, in pages.json order. */
export function uncoveredIds(pages, translations) {
	return Object.keys(pages).filter((id) => !(id in translations));
}

/**
 * Title → cached entry, through the ids that already carry it. A reprint id
 * mapping to an already-translated title reuses that entry instead of
 * refetching the page.
 */
export function cachedTitleEntries(pages, translations) {
	const entries = {};
	for (const [id, title] of Object.entries(pages)) {
		if (!(title in entries) && id in translations) entries[title] = translations[id];
	}
	return entries;
}

/** Distinct titles of uncovered ids that no cached sibling covers either. */
export function neededTitles(pages, translations) {
	const cached = cachedTitleEntries(pages, translations);
	const seen = new Set();
	const titles = [];
	for (const id of uncoveredIds(pages, translations)) {
		const title = pages[id];
		if (title in cached || seen.has(title)) continue;
		seen.add(title);
		titles.push(title);
	}
	return titles;
}

/** Split into request-sized batches — long OR chains time the query out. */
export function batchTitles(titles) {
	const batches = [];
	for (let i = 0; i < titles.length; i += BATCH_SIZE) {
		batches.push(titles.slice(i, i + BATCH_SIZE));
	}
	return batches;
}

/**
 * The `action=ask` query string: hash-stripped title conditions joined with
 * OR, the four printouts, and a limit above any batch size.
 */
export function askQuery(titles) {
	const conditions = titles.map((title) => `[[${title.replaceAll("#", "")}]]`).join(" OR ");
	const printouts = PRINTOUTS.map((name) => `|?${name}`).join("");
	return `${conditions}${printouts}|limit=50`;
}

/**
 * Read one ask response into `{ requested title: printouts }`. Result keys are
 * real page titles, so a requested title matches through its hash-stripped
 * form; a title answered under any other key (redirect) is simply absent here
 * and retried solo by the caller. SMW sends `results: []` instead of `{}` when
 * nothing matched.
 */
export function resultsByTitle(requested, body) {
	let results = body?.query?.results;
	if (Array.isArray(results) && results.length === 0) results = {};
	if (typeof results !== "object" || results === null) {
		throw new Error(`yugipedia answer has no results object: ${JSON.stringify(body)}`);
	}

	const found = {};
	for (const title of requested) {
		const printouts = results[title.replaceAll("#", "")]?.printouts;
		if (typeof printouts === "object" && printouts !== null) found[title] = printouts;
	}
	return found;
}

/**
 * Resolve every title through the API, sequentially and at least
 * REQUEST_INTERVAL_MS apart: batched first, then one solo request per
 * leftover, whose single result is adopted whatever key it came under. Titles
 * still without a result are missing — the wiki has no data for them yet.
 * Throws on any non-200 or malformed response so the caller aborts instead of
 * writing a partial cache.
 */
export async function fetchTranslations(titles, { fetchImpl, sleep }) {
	let requestCount = 0;
	const request = async (queried) => {
		if (requestCount++ > 0) await sleep(REQUEST_INTERVAL_MS);

		const url = new URL(API_URL);
		url.searchParams.set("action", "ask");
		url.searchParams.set("query", askQuery(queried));
		url.searchParams.set("format", "json");

		const res = await fetchImpl(url, { headers: { "User-Agent": USER_AGENT } });
		if (res.status !== 200) throw new Error(`yugipedia answered HTTP ${res.status}`);
		try {
			return await res.json();
		} catch {
			throw new Error("yugipedia answered a non-JSON body");
		}
	};

	const printoutsByTitle = {};
	for (const batch of batchTitles(titles)) {
		Object.assign(printoutsByTitle, resultsByTitle(batch, await request(batch)));
	}

	const missing = [];
	for (const title of titles.filter((t) => !(t in printoutsByTitle))) {
		const body = await request([title]);
		let results = body?.query?.results;
		if (Array.isArray(results) && results.length === 0) results = {};
		if (typeof results !== "object" || results === null) {
			throw new Error(`yugipedia answer has no results object: ${JSON.stringify(body)}`);
		}
		const values = Object.values(results);
		if (values.length === 0) missing.push(title);
		else if (values.length === 1 && typeof values[0]?.printouts === "object") {
			printoutsByTitle[title] = values[0].printouts;
		} else {
			throw new Error(`ambiguous solo answer for ${title}: ${JSON.stringify(body)}`);
		}
	}

	return { printoutsByTitle, missing };
}

/**
 * One incremental run over injected IO: compute the work list, cover it from
 * cached siblings, then the seed dump, then the network, and write the merged
 * cache with ids ascending. An id whose title has no data at all stays out. A
 * thrown fetch error propagates before any write happens.
 */
export async function run({ pages, translations, seed, fetchImpl, sleep, writeTranslations }) {
	const workList = uncoveredIds(pages, translations);
	const cached = cachedTitleEntries(pages, translations);

	const seeded = {};
	const toFetch = [];
	for (const title of neededTitles(pages, translations)) {
		const printouts = seed[title]?.printouts;
		if (typeof printouts === "object" && printouts !== null) {
			seeded[title] = translationFromPrintouts(printouts);
		} else {
			toFetch.push(title);
		}
	}

	const { printoutsByTitle, missing } = await fetchTranslations(toFetch, { fetchImpl, sleep });
	const fetched = {};
	for (const [title, printouts] of Object.entries(printoutsByTitle)) {
		fetched[title] = translationFromPrintouts(printouts);
	}

	const next = { ...translations };
	let reusedIds = 0;
	let seededIds = 0;
	// The network-fetched ids by identity, not just count: they are the run's
	// genuinely new translations, which the run report announces.
	const gainedIds = [];
	for (const id of workList) {
		const title = pages[id];
		if (title in cached) {
			next[id] = cached[title];
			reusedIds++;
		} else if (title in seeded) {
			next[id] = seeded[title];
			seededIds++;
		} else if (title in fetched) {
			next[id] = fetched[title];
			gainedIds.push(id);
		}
	}

	writeTranslations(renderPagesJson(next));

	const coverage = { en: 0, en_lore: 0, es: 0, es_lore: 0 };
	for (const entry of Object.values(next)) {
		for (const key of Object.keys(coverage)) if (entry[key] !== "") coverage[key]++;
	}

	return {
		idsTotal: Object.keys(pages).length,
		workList,
		reusedIds,
		seededIds,
		fetchedIds: gainedIds.length,
		gainedIds,
		missing,
		entries: Object.keys(next).length,
		coverage,
	};
}

/**
 * The run-report fragment for this step. The cache file is rewritten on every
 * run, but its content only moves when some id gained an entry — from cache,
 * seed, or network — so that is the changed/unchanged line.
 */
export function fetchTranslationsFragment(stats) {
	return {
		step: "fetch-translations",
		status: stats.reusedIds + stats.seededIds + stats.fetchedIds > 0 ? "changed" : "unchanged",
		gained: stats.gainedIds,
		missing: stats.missing,
		entries: stats.entries,
		coverage: stats.coverage,
	};
}

async function main() {
	const [dataDir] = process.argv.slice(2);

	const pages = JSON.parse(readFileSync("rush/pages.json", "utf8"));
	const translations = existsSync("rush/translations.json")
		? JSON.parse(readFileSync("rush/translations.json", "utf8"))
		: {};
	const seed = dataDir ? JSON.parse(readFileSync(`${dataDir}/yugipedia.json`, "utf8")) : {};

	let stats;
	try {
		stats = await run({
			pages,
			translations,
			seed,
			fetchImpl: fetch,
			sleep: (ms) => new Promise((resolve) => setTimeout(resolve, ms)),
			writeTranslations: (text) => writeFileSync("rush/translations.json", text),
		});
	} catch (err) {
		console.error(`aborted, translations.json untouched: ${err.message}`);
		process.exit(1);
	}

	console.error(`ids: ${stats.idsTotal}`);
	console.error(`work list: ${stats.workList.length}`);
	console.error(`reused from cache: ${stats.reusedIds}`);
	console.error(`seeded: ${stats.seededIds}`);
	console.error(`fetched: ${stats.fetchedIds}`);
	console.error(`missing after fetch: ${stats.missing.length}`);
	for (const title of stats.missing) console.error(`  ? ${title}`);
	console.error(`entries: ${stats.entries}`);
	console.error(
		`coverage: en ${stats.coverage.en}, en_lore ${stats.coverage.en_lore}, ` +
			`es ${stats.coverage.es}, es_lore ${stats.coverage.es_lore}`,
	);

	reportFragment(process.env, fetchTranslationsFragment(stats));
}

if (process.argv[1]?.endsWith("fetch-rush-translations.mjs")) {
	await main();
}

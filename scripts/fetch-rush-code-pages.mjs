// Fills the gaps in rush/pages.json — ygopro card id → Yugipedia page title —
// over the network. The bulk of the map came from Set Card Lists wikitext
// (scripts/derive-rush-pages.mjs); the ids that derivation could not place are
// resolved here through Yugipedia's print-code redirect pages: `RD/LP01-JP001`
// is a wiki page redirecting to `Dark Magician of Chaos (Rush Duel)`, and the
// MediaWiki API resolves up to 50 such titles in one request.
//
// The run is incremental and idempotent: only unmapped ids are queried, and an
// id the wiki does not know yet simply stays unmapped until a later run. Any
// network or API failure aborts the whole run without touching pages.json — a
// partial day is retried tomorrow, never half-written.
//
// Candidates whose redirects disagree on the target are ambiguous and reported
// instead of mapped — a wrong title is worse than a gap.

import { execFileSync } from "node:child_process";
import { readFileSync, writeFileSync } from "node:fs";

import { renderPagesJson } from "./derive-rush-pages.mjs";
import { parseSetBlocks, printCodeCandidates } from "./rush-sets.mjs";

const RUSH_CDBS = ["rush/RD Standard.cdb", "rush/RD Patch.cdb", "rush/RD Alternate.cdb"];

const API_URL = "https://yugipedia.com/api.php";
const USER_AGENT =
	"EvolutionAssetsBot/1.0 (https://github.com/evolutionygo; card id to page mapping)";
const BATCH_SIZE = 50;
const REQUEST_INTERVAL_MS = 1100;

/** The ids pages.json does not cover yet, in cdb order. */
export function unmappedIds(ids, pages) {
	return ids.filter((id) => !(id in pages));
}

/** Split into request-sized batches — the API caps a query at 50 titles. */
export function batchCodes(codes) {
	const batches = [];
	for (let i = 0; i < codes.length; i += BATCH_SIZE) {
		batches.push(codes.slice(i, i + BATCH_SIZE));
	}
	return batches;
}

/**
 * Read one API response into `{ requested title: redirect target }`.
 *
 * The API may normalize a title before resolving it (`query.normalized` maps
 * from → to), so each requested title chains through normalization first and
 * only then through `query.redirects`. Titles that end up in `query.pages` as
 * missing or as plain pages are not redirects and yield nothing.
 */
export function redirectTargets(requested, body) {
	const normalized = new Map((body.query.normalized ?? []).map(({ from, to }) => [from, to]));
	const redirects = new Map((body.query.redirects ?? []).map(({ from, to }) => [from, to]));

	const targets = {};
	for (const title of requested) {
		const target = redirects.get(normalized.get(title) ?? title);
		if (target !== undefined) targets[title] = target;
	}
	return targets;
}

/**
 * Resolve every batch through the API, sequentially and at least
 * REQUEST_INTERVAL_MS apart. Throws on any non-200 or malformed response so
 * the caller aborts instead of writing a partial map.
 */
export async function fetchRedirectTargets(codes, { fetchImpl, sleep }) {
	const targets = {};
	const batches = batchCodes([...new Set(codes)]);

	for (let i = 0; i < batches.length; i++) {
		if (i > 0) await sleep(REQUEST_INTERVAL_MS);

		const url = new URL(API_URL);
		url.searchParams.set("action", "query");
		url.searchParams.set("titles", batches[i].join("|"));
		url.searchParams.set("redirects", "1");
		url.searchParams.set("format", "json");

		const res = await fetchImpl(url, { headers: { "User-Agent": USER_AGENT } });
		if (res.status !== 200) throw new Error(`yugipedia answered HTTP ${res.status}`);

		let body;
		try {
			body = await res.json();
		} catch {
			throw new Error("yugipedia answered a non-JSON body");
		}
		if (typeof body?.query !== "object" || body.query === null) {
			throw new Error(`yugipedia answer has no query object: ${JSON.stringify(body)}`);
		}

		Object.assign(targets, redirectTargets(batches[i], body));
	}

	return targets;
}

/**
 * Per-id verdict from the redirect targets of its candidate codes. Several
 * codes may redirect — reprints — but they must agree: exactly one distinct
 * target maps the id, zero leaves it unresolved for a later run, and two or
 * more distinct targets are ambiguous and carry every code → title pair.
 */
export function resolveIds(candidatesById, codeToTitle) {
	const mapped = {};
	const unresolved = [];
	const ambiguous = [];

	for (const [id, codes] of Object.entries(candidatesById)) {
		const matches = codes
			.filter((code) => code in codeToTitle)
			.map((code) => ({ code, title: codeToTitle[code] }));
		const distinct = [...new Set(matches.map((m) => m.title))];

		if (distinct.length === 1) mapped[id] = distinct[0];
		else if (distinct.length === 0) unresolved.push(id);
		else ambiguous.push({ id, matches });
	}

	return { mapped, unresolved, ambiguous };
}

/** New mappings join the existing map; neither input is modified. */
export function mergePages(existing, added) {
	return { ...existing, ...added };
}

/**
 * One incremental run over injected IO: compute the work list, query the API
 * for every candidate code, resolve, and write the merged pages.json only when
 * at least one id newly mapped. A thrown fetch error propagates before any
 * write happens.
 */
export async function runDaily({ ids, pages, blocks, fetchImpl, sleep, writePages }) {
	const workList = unmappedIds(ids, pages);

	const candidatesById = {};
	const noBlock = [];
	for (const id of workList) {
		const codes = printCodeCandidates(id, blocks);
		if (codes.length === 0) noBlock.push(id);
		else candidatesById[id] = codes;
	}

	const codeToTitle = await fetchRedirectTargets(Object.values(candidatesById).flat(), {
		fetchImpl,
		sleep,
	});
	const { mapped, unresolved, ambiguous } = resolveIds(candidatesById, codeToTitle);

	if (Object.keys(mapped).length > 0) {
		writePages(renderPagesJson(mergePages(pages, mapped)));
	}

	return { workList, mapped, noBlock, unresolved, ambiguous };
}

// Ids are disjoint across the three cdbs, so a plain concat is the union.
function rushCardIds() {
	const ids = [];
	for (const cdb of RUSH_CDBS) {
		const out = execFileSync("sqlite3", [cdb, "SELECT id FROM datas ORDER BY id;"], {
			encoding: "utf8",
		});
		ids.push(...out.trim().split("\n"));
	}
	return ids;
}

// The zh names of the given ids, for the ambiguous report — the cdb name is
// the only human-readable identity these cards have on our side.
function cardNames(ids) {
	const names = {};
	if (ids.length === 0) return names;

	const sql = `SELECT id, name FROM texts WHERE id IN (${ids.join(",")});`;
	for (const cdb of RUSH_CDBS) {
		const out = execFileSync("sqlite3", ["-separator", "\t", cdb, sql], { encoding: "utf8" });
		for (const line of out.trim().split("\n")) {
			if (line === "") continue;
			const [id, name] = line.split("\t");
			names[id] = name;
		}
	}
	return names;
}

async function main() {
	const ids = rushCardIds();
	const pages = JSON.parse(readFileSync("rush/pages.json", "utf8"));
	const blocks = parseSetBlocks(readFileSync("rush/sets.md", "utf8"));

	let stats;
	try {
		stats = await runDaily({
			ids,
			pages,
			blocks,
			fetchImpl: fetch,
			sleep: (ms) => new Promise((resolve) => setTimeout(resolve, ms)),
			writePages: (text) => writeFileSync("rush/pages.json", text),
		});
	} catch (err) {
		console.error(`aborted, pages.json untouched: ${err.message}`);
		process.exit(1);
	}

	const { workList, mapped, noBlock, unresolved, ambiguous } = stats;
	const names = cardNames(ambiguous.map(({ id }) => id));

	console.error(`work list: ${workList.length}`);
	console.error(`newly mapped: ${Object.keys(mapped).length}`);
	console.error(`no block: ${noBlock.length}`);
	if (noBlock.length) console.error(`  no block: ${noBlock.join(", ")}`);
	console.error(`unresolved: ${unresolved.length}`);
	if (unresolved.length) console.error(`  unresolved: ${unresolved.join(", ")}`);
	console.error(`ambiguous: ${ambiguous.length}`);
	for (const { id, matches } of ambiguous) {
		console.error(`  ${id} (${names[id] ?? "?"})`);
		for (const { code, title } of matches) console.error(`    ${code} → ${title}`);
	}
}

if (process.argv[1]?.endsWith("fetch-rush-code-pages.mjs")) {
	await main();
}

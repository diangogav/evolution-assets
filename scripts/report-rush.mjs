// Composes reports/rush.json — the run-report v1 for the Rush pipeline — out
// of the per-step fragments the pipeline scripts drop under REPORT_PATH (see
// scripts/run-report.mjs and reports/README.md). Run by mirror-rush-pack.yml
// after the pipeline, even when a step failed: absent fragments compose into
// `"status": "missing"` steps instead of aborting, so the summary still tells
// what happened.
//
// The card diff comes from OLD_IDS_FILE, a dump of the ids the three rush
// cdbs held BEFORE the mirror refresh — the workflow takes it, because by the
// time this script runs the refresh has already replaced those files. Without
// the dump the old ids default to the current ones: a run without mirror
// context must not fabricate additions.
//
// Only the latest report is kept; its history is the git log of the file. It
// is rewritten only when the run produced notable events (new/removed cards,
// new translations, ambiguities, or moved gap counts) and the content really
// moved — same contentSignature-style guard as build-version-manifest.mjs —
// so scheduled no-op runs never commit a timestamp-only change.

import { execFileSync } from "node:child_process";
import { appendFileSync, existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const RUSH_CDBS = ["rush/RD Standard.cdb", "rush/RD Patch.cdb", "rush/RD Alternate.cdb"];
const TRANSLATIONS_PATH = "rush/translations.json";
const REPORT_PATH = "reports/rush.json";

export const PIPELINE_STEPS = [
	"resolve-pages",
	"fetch-translations",
	"build-cdb",
	"update-manifest",
];

/** The Actions run url, or null outside a workflow. */
export function runUrlFromEnv(env) {
	const { GITHUB_SERVER_URL: server, GITHUB_REPOSITORY: repo, GITHUB_RUN_ID: id } = env;
	return server && repo && id ? `${server}/${repo}/actions/runs/${id}` : null;
}

// One announced card: zh from the cdb, en/es from the translation cache when
// non-empty — a card the wiki does not document yet announces as null.
function namedCard(id, cards, translations) {
	const entry = translations[id];
	return {
		id,
		zh: cards[id] ?? null,
		en: entry?.en ? entry.en : null,
		es: entry?.es ? entry.es : null,
	};
}

const byIdAsc = (a, b) => Number(a) - Number(b);

/**
 * Pure: fold the step fragments and the card diff into one report object.
 * `oldIds: null` means the pre-refresh dump is unavailable — the diff then
 * compares current against current and yields nothing. When the resolve-pages
 * fragment is missing, the gap counts carry over from `existing` so a skipped
 * step never reads as "the gaps went to zero".
 */
export function composeReport({
	fragments,
	cards,
	translations,
	oldIds,
	existing,
	generatedAt,
	runUrl,
}) {
	const steps = PIPELINE_STEPS.map(
		(step) => fragments[step] ?? { step, status: "missing" },
	);

	const currentIds = Object.keys(cards).sort(byIdAsc);
	const old = new Set(oldIds ?? currentIds);
	const cardsAdded = currentIds
		.filter((id) => !old.has(id))
		.map((id) => namedCard(id, cards, translations));
	const cardsRemoved = [...old].filter((id) => !(id in cards)).sort(byIdAsc);

	const addedIds = new Set(cardsAdded.map(({ id }) => id));
	const translationsAdded = (fragments["fetch-translations"]?.gained ?? [])
		.filter((id) => !addedIds.has(id))
		.sort(byIdAsc)
		.map((id) => namedCard(id, cards, translations));

	const resolve = fragments["resolve-pages"];
	const carried = existing?.events;
	const empty = { count: 0, sample: [] };

	return {
		schemaVersion: 1,
		pipeline: "rush",
		generatedAt,
		runUrl,
		steps,
		events: {
			cardsAdded,
			cardsRemoved,
			translationsAdded,
			unresolved: resolve?.unresolved ?? carried?.unresolved ?? empty,
			noBlock: resolve?.noBlock ?? carried?.noBlock ?? empty,
			ambiguous: resolve?.ambiguous ?? [],
		},
	};
}

/**
 * Whether the run earned a rewrite: any card/translation/ambiguity entry, or
 * a gap count that moved against the previous report. The first report ever
 * is notable as soon as any gap exists at all.
 */
export function hasNotableEvents(events, existing) {
	if (
		events.cardsAdded.length > 0 ||
		events.cardsRemoved.length > 0 ||
		events.translationsAdded.length > 0 ||
		events.ambiguous.length > 0
	) {
		return true;
	}
	const previous = existing?.events;
	if (!previous) return events.unresolved.count > 0 || events.noBlock.count > 0;
	return (
		events.unresolved.count !== previous.unresolved?.count ||
		events.noBlock.count !== previous.noBlock?.count
	);
}

// The report minus its per-run stamps — two runs over the same pipeline state
// share a signature, so the guard can skip the rewrite (and the commit).
export function reportSignature(report) {
	const { generatedAt, runUrl, ...content } = report;
	return JSON.stringify(content);
}

// One `- ...` line per card, zh first, en appended when known.
function cardLine({ id, zh, en }) {
	return `- \`${id}\` ${zh ?? "?"}${en ? ` — ${en}` : ""}`;
}

/** The $GITHUB_STEP_SUMMARY markdown for one report. */
export function renderSummary(report) {
	const { events } = report;
	const lines = ["# Rush pipeline report", ""];

	lines.push("| Step | Status |", "| --- | --- |");
	for (const { step, status } of report.steps) lines.push(`| ${step} | ${status} |`);
	lines.push("");

	lines.push(
		"| Event | Count |",
		"| --- | --- |",
		`| Cards added | ${events.cardsAdded.length} |`,
		`| Cards removed | ${events.cardsRemoved.length} |`,
		`| Translations added | ${events.translationsAdded.length} |`,
		`| Unresolved ids | ${events.unresolved.count} |`,
		`| Ids without a set block | ${events.noBlock.count} |`,
		`| Ambiguous ids | ${events.ambiguous.length} |`,
		"",
	);

	if (events.cardsAdded.length > 0) {
		lines.push("## New cards", "");
		for (const card of events.cardsAdded.slice(0, 10)) lines.push(cardLine(card));
		if (events.cardsAdded.length > 10) lines.push(`…and ${events.cardsAdded.length - 10} more`);
		lines.push("");
	}

	if (events.translationsAdded.length > 0) {
		lines.push("## New translations", "");
		for (const card of events.translationsAdded.slice(0, 10)) lines.push(cardLine(card));
		if (events.translationsAdded.length > 10) {
			lines.push(`…and ${events.translationsAdded.length - 10} more`);
		}
		lines.push("");
	}

	if (events.ambiguous.length > 0) {
		lines.push("## Ambiguous ids", "");
		for (const { id, zh, candidates } of events.ambiguous) {
			lines.push(`- \`${id}\` ${zh ?? "?"}`);
			for (const { code, title } of candidates) lines.push(`  - \`${code}\` → ${title}`);
		}
		lines.push("");
	}

	return `${lines.join("\n")}\n`;
}

// Current id → zh name over the three source cdbs. Ids are disjoint across
// them (build-rush-cdb.mjs enforces it), so plain assignment is the union.
function currentCards() {
	const cards = {};
	for (const cdb of RUSH_CDBS) {
		const out = execFileSync(
			"sqlite3",
			["-separator", "\t", cdb, "SELECT datas.id, texts.name FROM datas LEFT JOIN texts ON datas.id = texts.id ORDER BY datas.id;"],
			{ encoding: "utf8" },
		);
		for (const line of out.trim().split("\n")) {
			if (line === "") continue;
			const [id, name] = line.split("\t");
			cards[id] = name ?? null;
		}
	}
	return cards;
}

// A fragment a step never wrote — or wrote broken — is simply missing: the
// composer's job is to report the run, not to fail alongside it.
function readFragments(dir) {
	const fragments = {};
	for (const step of PIPELINE_STEPS) {
		try {
			fragments[step] = JSON.parse(readFileSync(join(dir, `${step}.json`), "utf8"));
		} catch {
			// absent or unparsable — composed as { status: "missing" }
		}
	}
	return fragments;
}

function readOldIds(path) {
	if (!path || !existsSync(path)) return null;
	return readFileSync(path, "utf8")
		.split("\n")
		.filter((line) => line !== "");
}

function main() {
	const [fragmentsDir] = process.argv.slice(2);
	if (!fragmentsDir) {
		console.error("usage: node scripts/report-rush.mjs <fragmentsDir>");
		process.exit(1);
	}

	const existing = existsSync(REPORT_PATH)
		? JSON.parse(readFileSync(REPORT_PATH, "utf8"))
		: null;
	const report = composeReport({
		fragments: readFragments(fragmentsDir),
		cards: currentCards(),
		translations: existsSync(TRANSLATIONS_PATH)
			? JSON.parse(readFileSync(TRANSLATIONS_PATH, "utf8"))
			: {},
		oldIds: readOldIds(process.env.OLD_IDS_FILE),
		existing,
		generatedAt: new Date().toISOString(),
		runUrl: runUrlFromEnv(process.env),
	});

	if (process.env.GITHUB_STEP_SUMMARY) {
		appendFileSync(process.env.GITHUB_STEP_SUMMARY, renderSummary(report));
	}

	if (!hasNotableEvents(report.events, existing)) {
		console.log(`skipped ${REPORT_PATH} — no notable events this run`);
		return;
	}
	if (existing !== null && reportSignature(report) === reportSignature(existing)) {
		console.log(`skipped ${REPORT_PATH} — content unchanged`);
		return;
	}

	mkdirSync("reports", { recursive: true });
	writeFileSync(REPORT_PATH, `${JSON.stringify(report, null, 2)}\n`);
	console.log(`wrote ${REPORT_PATH}`);
}

if (process.argv[1]?.endsWith("report-rush.mjs")) {
	main();
}

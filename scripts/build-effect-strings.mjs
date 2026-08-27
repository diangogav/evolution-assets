// Mines rush/effect-strings.json — a Chinese → en/es dictionary for the
// duel-time UI prompts a card shows when it asks the player to choose
// ("Special Summon", "Destroy", "select the monster whose ATK to increase").
// Those live in texts.str1..str16, are addressed by lua as
// `aux.Stringid(id, offset)`, and upstream ships them in Chinese only for the
// Rush cdbs — so players read Chinese mid-duel. They are NOT card text: the
// name/lore pipeline (fetch-rush-translations.mjs) never touches them.
//
// Nothing here is translated. mycard's BASE cdbs carry the same prompts
// already translated for 14981 cards, and the same Chinese string recurs as
// the same term across many cards, so the dictionary is read off them by
// aligning the three databases on (card id, str index):
//   zh — the argument, mycard's zh-CN cards.cdb (~8 MB, redirects; fetch with
//        `curl -L`). Not committed: a daily 8 MB download does not belong in
//        the pipeline, and the mined JSON is the artifact that ships.
//   en/es — cdb/base.{en,es}.cdb.gz, already mirrored in this repo.
//
// A pair is accepted only when the Chinese string maps to EXACTLY ONE
// translation and at least MIN_ATTESTING_CARDS distinct cards attest that same
// pair. Both halves matter. English is near-uniform (4193 of 4195 distinct
// strings have a single counterpart), but Spanish is not: its translators
// wrote per-card prose where English wrote the term — `特殊召唤` alone has
// 1207 distinct Spanish "translations" — and a pair only one card attests
// cannot be told apart from that card's own prose. Applying such a pair would
// stamp another card's sentence onto a Rush card. On the Rush strings the
// two-card floor costs ~1% of covered occurrences and cuts the dictionary by
// 77%; a three-card floor starts costing real coverage.
//
// Deliberately NOT filtered on string-length ratio: a compact Chinese term
// legitimately expands in English, and that rule discards good entries.

import { execFileSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { gunzipSync } from "node:zlib";

export const MIN_ATTESTING_CARDS = 2;

/** The prompt columns of `texts`, str1..str16 — the whole addressable range. */
export const STR_NAMES = Array.from({ length: 16 }, (_, i) => `str${i + 1}`);

const LANGUAGES = ["en", "es"];
const BASE_GZ = (language) => `cdb/base.${language}.cdb.gz`;
const OUT_PATH = "rush/effect-strings.json";

/**
 * The `texts` str columns of one cdb, in id order. Read as JSON because a
 * prompt may hold any character the CLI's row format cannot round-trip, and a
 * NULL column is normalised to "" so callers only ever test for empty.
 */
export function readStrRows(cdbPath) {
	const selected = ["id", ...STR_NAMES.map((name) => `ifnull(${name},'') AS ${name}`)].join(",");
	const object = ["id", ...STR_NAMES].map((name) => `'${name}',${name}`).join(",");
	const out = execFileSync(
		"sqlite3",
		[
			cdbPath,
			`SELECT json_group_array(json_object(${object})) FROM ` +
				`(SELECT ${selected} FROM texts ORDER BY id);`,
		],
		// A full base cdb yields several MB of JSON on one line.
		{ encoding: "utf8", maxBuffer: 1024 * 1024 * 1024 },
	).trim();
	return JSON.parse(out);
}

/**
 * Two str-row sets aligned on (card id, str index). A column empty on either
 * side yields no pair — an untranslated prompt is absence, not evidence.
 * Surrounding whitespace is trimmed off both sides so stray padding in one
 * row does not split a term into two dictionary keys.
 */
export function pairStrings(chineseRows, translatedRows, familyById = new Map()) {
	const byId = new Map(translatedRows.map((row) => [row.id, row]));
	const pairs = [];

	for (const chineseRow of chineseRows) {
		const translatedRow = byId.get(chineseRow.id);
		if (!translatedRow) continue;
		// An alt-art reprint is a second id carrying the same card's prose, so it
		// attests nothing the original did not. Collapsing both onto the original
		// is what keeps `mineTerms` counting cards rather than printings.
		const card = familyById.get(chineseRow.id) ?? chineseRow.id;
		for (const name of STR_NAMES) {
			const chinese = (chineseRow[name] ?? "").trim();
			const translated = (translatedRow[name] ?? "").trim();
			if (chinese === "" || translated === "") continue;
			pairs.push({ id: card, chinese, translated });
		}
	}

	return pairs;
}

/**
 * Card id → the id of the card it reprints, for every alias in the pack.
 *
 * `datas.alias` is 0 for an original and the original's id for a reprint, so
 * the map holds only the reprints and callers fall back to the id itself.
 */
export function readAliasFamilies(cdbPath) {
	const out = execFileSync(
		"sqlite3",
		[cdbPath, "SELECT id||','||alias FROM datas WHERE alias!=0;"],
		{ encoding: "utf8", maxBuffer: 1024 * 1024 * 1024 },
	).trim();
	const families = new Map();
	if (out === "") return families;
	for (const line of out.split("\n")) {
		const [id, alias] = line.split(",").map(Number);
		if (Number.isFinite(id) && Number.isFinite(alias)) families.set(id, alias);
	}
	return families;
}

/**
 * The dictionary those pairs support, plus why the rest were dropped. A term
 * is accepted only when it has one translation AND that pair is attested by
 * MIN_ATTESTING_CARDS distinct cards; the two rejection counts are reported
 * apart because they mean different things about the source data.
 */
export function mineTerms(pairs) {
	// chinese → translation → the distinct card ids attesting that pair.
	const attestations = new Map();
	for (const { id, chinese, translated } of pairs) {
		let byTranslation = attestations.get(chinese);
		if (!byTranslation) attestations.set(chinese, (byTranslation = new Map()));
		let cards = byTranslation.get(translated);
		if (!cards) byTranslation.set(translated, (cards = new Set()));
		cards.add(id);
	}

	const terms = {};
	let rejectedInconsistent = 0;
	let rejectedSingleCard = 0;

	for (const [chinese, byTranslation] of attestations) {
		if (byTranslation.size > 1) {
			rejectedInconsistent++;
			continue;
		}
		const [[translated, cards]] = byTranslation;
		if (cards.size < MIN_ATTESTING_CARDS) {
			rejectedSingleCard++;
			continue;
		}
		terms[chinese] = translated;
	}

	return {
		terms,
		stats: {
			examined: pairs.length,
			accepted: Object.keys(terms).length,
			rejectedInconsistent,
			rejectedSingleCard,
		},
	};
}

/**
 * The artifact text: `{ "<chinese>": { "en": ..., "es": ... } }`, keys sorted
 * by code unit so the file never depends on mining order. A language with no
 * entry for a term is omitted rather than written empty — an absent key is a
 * gap, an empty string would read as "translates to nothing".
 */
export function renderEffectStrings(byLanguage) {
	const chineseKeys = new Set();
	for (const terms of Object.values(byLanguage)) for (const key of Object.keys(terms)) chineseKeys.add(key);

	const dictionary = {};
	for (const chinese of [...chineseKeys].sort()) {
		const entry = {};
		for (const language of LANGUAGES) {
			const translated = byLanguage[language]?.[chinese];
			if (translated) entry[language] = translated;
		}
		dictionary[chinese] = entry;
	}

	return `${JSON.stringify(dictionary, null, 2)}\n`;
}

function main() {
	const [chinesePath] = process.argv.slice(2);
	if (!chinesePath) {
		console.error("usage: node scripts/build-effect-strings.mjs <zh-CN cards.cdb>");
		console.error("  curl -L -o cards.cdb https://cdntx.moecube.com/ygopro-database/zh-CN/cards.cdb");
		process.exit(1);
	}

	const workDir = mkdtempSync(join(tmpdir(), "effect-strings-"));
	try {
		const chineseRows = readStrRows(chinesePath);
		const families = readAliasFamilies(chinesePath);
		const byLanguage = {};

		for (const language of LANGUAGES) {
			const rawPath = join(workDir, `base.${language}.cdb`);
			writeFileSync(rawPath, gunzipSync(readFileSync(BASE_GZ(language))));
			const { terms, stats } = mineTerms(
				pairStrings(chineseRows, readStrRows(rawPath), families),
			);
			byLanguage[language] = terms;
			console.error(
				`${language}: ${stats.examined} pairs examined, ${stats.accepted} entries accepted, ` +
					`${stats.rejectedInconsistent} rejected (several translations), ` +
					`${stats.rejectedSingleCard} rejected (one card only)`,
			);
		}

		const text = renderEffectStrings(byLanguage);
		writeFileSync(OUT_PATH, text);
		console.error(`${OUT_PATH}: ${Object.keys(JSON.parse(text)).length} terms`);
	} finally {
		rmSync(workDir, { recursive: true, force: true });
	}
}

if (process.argv[1]?.endsWith("build-effect-strings.mjs")) {
	main();
}

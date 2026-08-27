// Mines rush/translations.base.json — official Spanish NAMES (and, rarely,
// lore) for Rush cards, read off mycard's base databases rather than
// translated.
//
// Rush Duel never sold in Spanish, so rush/translations.json — scraped from
// the wiki by fetch-rush-translations.mjs — covers only a sixth of the pool.
// But a large share of Rush cards are Rush versions of classic cards that DID
// sell in Spanish, and those carry an official Spanish name in
// cdb/base.es.cdb.gz already. The join key is the ENGLISH card name: our Rush
// card's `en`, matched against `texts.name` in cdb/base.en.cdb.gz, then that
// same base id's Spanish row.
//
// The two halves of a card are NOT equally safe to copy, and this is the whole
// point of the script:
//
//   NAME — always copyable. A Rush card printed under a classic card's English
//   name is that card by name, so its Spanish name is that card's Spanish name.
//   "Thousand Dragon" is "Dragón Milenario" in either format.
//
//   LORE — copyable only when the ENGLISH lore is identical. A Rush card
//   usually has a DIFFERENT effect from its classic namesake: Rush rewrote the
//   game's text into [REQUIREMENT]/[EFFECT] form and often changed what the
//   card does outright. Most name-sharing cards diverge here. Copying the base
//   Spanish desc on a name match alone would stamp the wrong effect onto them,
//   so the base Spanish desc is taken only when our `en_lore` matches the base
//   `desc` exactly (after stripping \r and trimming).
//
// A name or lore several base cards disagree on is dropped rather than picked
// from — mirroring build-effect-strings.mjs, ambiguity is absence of evidence.
// Reprints of one card agree, so this only ever costs genuinely unclear cases.
//
// Fields rush/translations.json already fills are skipped: that Spanish came
// from the Rush card's own wiki page and is about the card in hand, while
// anything mined here comes from a DIFFERENT card that merely shares a name.
// build-rush-cdb.mjs keeps the same precedence when it merges the two files.

import { execFileSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { gunzipSync } from "node:zlib";

const BASE_GZ = (language) => `cdb/base.${language}.cdb.gz`;
const TRANSLATIONS_PATH = "rush/translations.json";
const OUT_PATH = "rush/translations.base.json";

/**
 * Comparison form of one text field. Card text reaches us CRLF-terminated from
 * the cdbs and LF-terminated from the wiki, so \r is stripped before comparing;
 * an empty result means the field is absent, never "translates to nothing".
 */
function normalize(text) {
	return (text ?? "").replaceAll("\r", "").trim();
}

/**
 * The id/name/desc of every `texts` row of one cdb, in id order. Read as JSON
 * because descs are multi-line, which the CLI's default row format cannot
 * round-trip, and a NULL column is normalised to "" so callers only ever test
 * for empty.
 */
export function readNameLoreRows(cdbPath) {
	const out = execFileSync(
		"sqlite3",
		[
			cdbPath,
			"SELECT json_group_array(json_object('id',id,'name',ifnull(name,''),'desc',ifnull(\"desc\",''))) " +
				'FROM (SELECT id,name,"desc" FROM texts ORDER BY id);',
		],
		// A full base cdb yields several MB of JSON on one line.
		{ encoding: "utf8", maxBuffer: 1024 * 1024 * 1024 },
	).trim();
	return JSON.parse(out);
}

/**
 * English card name → the Spanish that name is evidence for:
 *   `names` — every distinct Spanish name a base card under it carries.
 *   `lore`  — English desc → every distinct Spanish desc it is paired with.
 *
 * Both are sets rather than single values because a name may cover several base
 * ids (reprints, errata). Callers accept a value only when its set holds one.
 */
export function indexBaseByName(englishRows, spanishRows) {
	const spanishById = new Map(spanishRows.map((row) => [row.id, row]));
	const index = new Map();

	for (const englishRow of englishRows) {
		const englishName = normalize(englishRow.name);
		if (englishName === "") continue;
		const spanishRow = spanishById.get(englishRow.id);
		if (!spanishRow) continue;

		let entry = index.get(englishName);
		if (!entry) index.set(englishName, (entry = { names: new Set(), lore: new Map() }));

		const spanishName = normalize(spanishRow.name);
		if (spanishName !== "") entry.names.add(spanishName);

		const englishLore = normalize(englishRow.desc);
		const spanishLore = normalize(spanishRow.desc);
		if (englishLore === "" || spanishLore === "") continue;
		let readings = entry.lore.get(englishLore);
		if (!readings) entry.lore.set(englishLore, (readings = new Set()));
		readings.add(spanishLore);
	}

	return index;
}

/** The single value a set is evidence for, or null when it is empty or split. */
function unambiguous(values) {
	return values?.size === 1 ? [...values][0] : null;
}

/**
 * The Spanish those translations can borrow from the base index, plus why the
 * rest were not borrowed. `loreRejectedDiffering` is the count that matters:
 * it is the number of cards that share a classic card's name but not its
 * effect, and it is what stands between this file and the wrong lore.
 */
export function mineSpanishTexts(translations, index) {
	const entries = {};
	const stats = {
		matched: 0,
		names: 0,
		lore: 0,
		loreRejectedDiffering: 0,
		loreWithoutEnglish: 0,
		skippedHadSpanishName: 0,
		skippedHadSpanishLore: 0,
	};

	for (const [id, card] of Object.entries(translations)) {
		const englishName = normalize(card.en);
		if (englishName === "") continue;
		const base = index.get(englishName);
		if (!base) continue;
		stats.matched++;

		const mined = {};

		if (normalize(card.es) !== "") {
			stats.skippedHadSpanishName++;
		} else {
			const spanishName = unambiguous(base.names);
			if (spanishName) {
				mined.es = spanishName;
				stats.names++;
			}
		}

		const englishLore = normalize(card.en_lore);
		if (normalize(card.es_lore) !== "") {
			stats.skippedHadSpanishLore++;
		} else if (englishLore === "") {
			stats.loreWithoutEnglish++;
		} else {
			// The rule the whole script exists for: same name, same effect text,
			// or no lore at all.
			const spanishLore = unambiguous(base.lore.get(englishLore));
			if (spanishLore) {
				mined.es_lore = spanishLore;
				stats.lore++;
			} else {
				stats.loreRejectedDiffering++;
			}
		}

		if (Object.keys(mined).length > 0) entries[id] = mined;
	}

	return { entries, stats };
}

/**
 * The artifact text: `{ "<card id>": { "es": ..., "es_lore": ... } }`, ids
 * sorted ascending as numbers so the file never depends on mining order and
 * never reorders itself if the id range ever changes width.
 */
export function renderMinedTranslations(entries) {
	const sorted = {};
	for (const id of Object.keys(entries).sort((a, b) => Number(a) - Number(b))) {
		const mined = entries[id];
		const written = {};
		// Written in a fixed field order, and an absent field is omitted rather
		// than written empty — an empty string would read as a translation.
		if (mined.es) written.es = mined.es;
		if (mined.es_lore) written.es_lore = mined.es_lore;
		if (Object.keys(written).length > 0) sorted[id] = written;
	}
	return `${JSON.stringify(sorted, null, 2)}\n`;
}

function main() {
	const translations = JSON.parse(readFileSync(TRANSLATIONS_PATH, "utf8"));
	const workDir = mkdtempSync(join(tmpdir(), "spanish-names-"));
	try {
		const rows = {};
		for (const language of ["en", "es"]) {
			const rawPath = join(workDir, `base.${language}.cdb`);
			writeFileSync(rawPath, gunzipSync(readFileSync(BASE_GZ(language))));
			rows[language] = readNameLoreRows(rawPath);
		}

		const { entries, stats } = mineSpanishTexts(
			translations,
			indexBaseByName(rows.en, rows.es),
		);
		writeFileSync(OUT_PATH, renderMinedTranslations(entries));

		console.error(
			`${stats.matched} Rush cards share an English name with a base card: ` +
				`${stats.names} names mined, ${stats.lore} lore mined`,
		);
		console.error(
			`${stats.loreRejectedDiffering} lore rejected (the Rush card's English effect differs), ` +
				`${stats.loreWithoutEnglish} rejected (no English lore to compare)`,
		);
		console.error(
			`skipped, already translated by the wiki: ` +
				`${stats.skippedHadSpanishName} names, ${stats.skippedHadSpanishLore} lore`,
		);
		console.error(`${OUT_PATH}: ${Object.keys(entries).length} entries`);
	} finally {
		rmSync(workDir, { recursive: true, force: true });
	}
}

if (process.argv[1]?.endsWith("mine-spanish-names.mjs")) {
	main();
}

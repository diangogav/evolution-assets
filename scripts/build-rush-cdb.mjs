// Builds the client-facing unified Rush databases in cdb/ out of the three
// per-origin cdbs mirrored in rush/ (RD Standard + RD Patch + RD Alternate,
// identical `datas`/`texts` schemas). The per-origin files are consumed
// read-only — the game server assembles its card pool from them directly.
//
// A fourth output, rush/RD MDPro4 Alternate.cdb, carries the admitted MDPro4
// alternate-art rows (below) on their own, raw and with the same schema. The
// duel server loads rush/*.cdb and never reads the unified cdbs, so without
// this file it would not know those ids; it loads it like RD Alternate.cdb.
// It is an output only: RUSH_CDBS must never list it, or the rows would be
// merged twice and the duplicate-id check would abort.
//
// mycard stays the source of mechanics. ElderLich/MDPro4_Data, mirrored in
// rush/mdpro4/ with the same schema, contributes two things on top:
//   - Alternate artwork rows (ids 129xxxxxx) whose `alias` is a card of the
//     union. Their `datas` are copied verbatim; their text is their base
//     card's wherever ours is keyed by the base id (see below). Alternate arts
//     of MDPro4's anime customs are left out — those customs have no mycard
//     script, so the art would point at a card nobody can play.
//   - Renumbered cards: MDPro4 still uses ids mycard has since moved to new
//     ones, so decks built there would name a card the duel server does not
//     know, and mycard ships scripts only under the new id. A MDPro4 row below
//     the anime range, with no alias and no mycard row of its own, whose
//     English name matches exactly one mycard card (by rush/translations.json)
//     with identical type, atk, def, level, race, attribute and setcode, is
//     emitted like an alternate art with `alias` set to that mycard id. Rows
//     with no match, several matches or different mechanics stay out and are
//     listed in the run report.
//   - Complete English and Spanish card texts, used as a tier below ours.
//
// Three variants ship, gzipped only (like the prerelease family, no raw
// unified .cdb is kept):
//   rush.cdb.gz    — the plain union, untranslated (zh-CN, as upstream ships).
//                    The alternate-art rows have no Chinese source at all, so
//                    they carry MDPro4's English text here.
//   rush.en.cdb.gz — per field: rush/translations.json (`en`, and `en_req` +
//                    `en_lore` composed into the two blocks a Rush card
//                    prints) → MDPro4 English → zh.
//   rush.es.cdb.gz — per field: rush/translations.json Spanish → rush/
//                    translations.base.json (official names mined off the base
//                    databases, see mine-spanish-names.mjs) → MDPro4 Spanish →
//                    the whole en chain. MDPro4's Spanish is partly machine
//                    translated, which is why our wiki-sourced text outranks
//                    it; a MDPro4 Spanish text identical to its English one is
//                    an untranslated copy and is skipped. The run report lists
//                    the MDPro4 Spanish texts used that carry known
//                    machine-translation telltales.
// An alternate-art row looks up translations.json and translations.base.json
// by its own id first and its alias second: an alternate art prints its base
// card's text. MDPro4 text is taken by the row's own id first; the MDPro4 rows
// of the card's `datas` alias (a reprint of another card, mycard's own or an
// admitted MDPro4 art) follow in a tier of their own, right after the row's
// own MDPro4 tier of the same language and above the next language in the
// chain.
// In the en/es variants texts.str1..str16 — the duel-time UI prompts a card
// shows when it asks the player to choose — are additionally run through
// rush/effect-strings.json (see build-effect-strings.mjs). A prompt is
// replaced on an exact dictionary hit first. On a miss, a prompt that is
// still Chinese takes MDPro4's prompt for the same card id and slot (the
// alias's rows after the card's own): in es MDPro4's Spanish when it is
// non-empty, free of Chinese and differs from its English, else its English
// when that is free of Chinese; in en MDPro4's English. When nothing applies
// the Chinese stays — a prompt is never blanked. The run report counts the
// prompts per source. `datas` stays byte-identical across variants
// (translation only ever UPDATEs texts rows in a file copy).
//
// The en/es variants lead the desc of every Maximum monster that declares a
// value with a `Maximum ATK <n>` line, sourced from the Chinese original — see
// TYPE_MAXIMUM below. MDPro4 descs already carry that line, so it is added only
// to a desc that does not lead with one.
//
// A card id present in more than one source cdb, alternate-art rows included,
// aborts the run before anything is written: precedence between origins is a
// human decision, not a merge default. Output is deterministic — rows are
// inserted in global id order and the gzip carries no mtime/name (gzip -9 -n
// semantics) — so two runs over the same inputs are byte-identical.

import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import {
	copyFileSync,
	existsSync,
	mkdtempSync,
	readFileSync,
	renameSync,
	rmSync,
	writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { basename, join } from "node:path";
import { gzipSync } from "node:zlib";

import { readStrRows, STR_NAMES } from "./build-effect-strings.mjs";
import { reportFragment, sampled } from "./run-report.mjs";

const RUSH_CDBS = ["rush/RD Standard.cdb", "rush/RD Patch.cdb", "rush/RD Alternate.cdb"];
const TRANSLATIONS_PATH = "rush/translations.json";
const TRANSLATIONS_BASE_PATH = "rush/translations.base.json";
const MDPRO4_EN_PATH = "rush/mdpro4/rush_cards.en.cdb";
const MDPRO4_ES_PATH = "rush/mdpro4/rush_cards.es.cdb";
const EFFECT_STRINGS_PATH = "rush/effect-strings.json";
const EFFECT_STRINGS_MANUAL_PATH = "rush/effect-strings.manual.json";

/**
 * The mined dictionary, filled in by the hand-written one.
 *
 * Mined entries win: they carry the wording mycard's own translators used for
 * the same term in the base databases, so a card reads the way its OCG
 * counterpart already does. The manual file only covers prompts Rush uses that
 * no base card does, which is why it can never overrule one.
 */
export function mergeEffectStrings(mined, manual) {
	const merged = { ...manual };
	for (const [chinese, entry] of Object.entries(mined)) {
		merged[chinese] = { ...manual[chinese], ...entry };
	}
	return merged;
}

const OUT_DIR = "cdb";
const ALTERNATE_CDB_NAME = "RD MDPro4 Alternate.cdb";
const ALTERNATE_CDB_PATH = `rush/${ALTERNATE_CDB_NAME}`;

// Whole-table JSON reads (the MDPro4 texts) outgrow execFileSync's 1 MiB
// default output buffer.
const SQLITE_MAX_BUFFER = 256 * 1024 * 1024;

function sqlite(dbPath, sql) {
	return execFileSync("sqlite3", [dbPath, sql], { encoding: "utf8", maxBuffer: SQLITE_MAX_BUFFER });
}

/** Ids that appear in more than one source id list, sorted. */
export function findDuplicateIds(idLists) {
	const seen = new Map();
	for (const ids of idLists) {
		for (const id of ids) seen.set(id, (seen.get(id) ?? 0) + 1);
	}
	return [...seen.entries()]
		.filter(([, count]) => count > 1)
		.map(([id]) => id)
		.sort((a, b) => a - b);
}

// The two blocks a Rush card prints are labelled per language. English
// labels follow the Asian-English print; Spanish has no official Rush
// printing, so the Spanish labels follow the convention the MDPro4 texts
// already use, which keeps one style across the whole Spanish variant.
const BLOCK_LABELS = {
	en: { requirement: "[REQUIREMENT]", effect: "[EFFECT]" },
	es: { requirement: "[REQUISITO]", effect: "[EFECTO]" },
};
/**
 * The desc one language's two blocks make. A card with no requirement keeps
 * its bare effect: labelling a single block would add a heading the printed
 * card does not have.
 */
export function composeDesc(requirement, effect, language = "en") {
	if (!requirement) return effect;
	const labels = BLOCK_LABELS[language] ?? BLOCK_LABELS.en;
	return `${labels.requirement}\n${requirement}\n\n${labels.effect}\n${effect}`;
}

// Per language, the translation-entry fields one tier is read from.
const ENTRY_FIELDS = {
	en: { name: "en", effect: "en_lore", requirement: "en_req" },
	es: { name: "es", effect: "es_lore", requirement: "es_req" },
};

/**
 * The name/desc one translation file offers for a language, each null when
 * absent. `entries` is the card's own entry followed by its alias's (for an
 * alternate art); the first entry that has a field wins that field.
 *
 * The effect anchors the desc: an entry with no effect is skipped whole, so a
 * requirement never gets glued to another entry's or language's effect.
 */
function translationTier(entries, language) {
	const fields = ENTRY_FIELDS[language];
	const first = (read) => {
		for (const entry of entries) {
			const text = entry ? read(entry) : "";
			if (text) return text;
		}
		return null;
	};
	return {
		name: first((entry) => entry[fields.name]),
		desc: first((entry) =>
			entry[fields.effect]
				? composeDesc(entry[fields.requirement], entry[fields.effect], language)
				: "",
		),
	};
}

// --- MDPro4 text ---
//
// MDPro4 ends every desc line with a tab before the LF and escapes a few
// double quotes as `&quot;`. Neither belongs in a card text: the tab would
// trail the `Maximum ATK <n>` line MDPro3 parses, and the entity would print
// literally.

/** A MDPro4 text as it should ship: entities unescaped, tab-free line ends. */
export function cleanMdpro4Text(text) {
	return (text ?? "").replaceAll("&quot;", '"').replaceAll("\t\n", "\n");
}

// Substrings that betray MDPro4's machine-translated Spanish. Matched on the
// raw text, before `&quot;` is unescaped, and only ever reported: a telltale
// is a lead for a human, not proof a text is wrong.
const MACHINE_TRANSLATION_TELLTALES = [
	"invoca de modo",
	"no puedes se",
	"tomar el daño",
	"destruye todos monstruos",
	"tails:",
	"cabezas:",
	"&quot;",
];

/** Whether a text contains any machine-translation telltale, ignoring case. */
export function hasMachineTranslationTelltale(text) {
	const lower = (text ?? "").toLowerCase();
	return MACHINE_TRANSLATION_TELLTALES.some((telltale) => lower.includes(telltale));
}

function mdpro4Tier(row) {
	return { name: cleanMdpro4Text(row?.name) || null, desc: cleanMdpro4Text(row?.desc) || null };
}

// MDPro4 ships its English text in the Spanish file wherever it has no
// translation, so a Spanish field equal to the English one is no Spanish.
function mdpro4SpanishTier(esRow, enRow) {
	const es = mdpro4Tier(esRow);
	const en = mdpro4Tier(enRow);
	return {
		name: es.name !== en.name ? es.name : null,
		desc: es.desc !== en.desc ? es.desc : null,
	};
}

// Every source label a variant can report, in chain order; `zh` is the
// Chinese original a card keeps when no tier has the field.
const VARIANT_SOURCES = {
	en: ["translations", "mdpro4", "alias.mdpro4", "zh"],
	es: [
		"translations",
		"base",
		"mdpro4",
		"alias.mdpro4",
		"en.translations",
		"en.mdpro4",
		"en.alias.mdpro4",
		"zh",
	],
};

/**
 * The name/desc override one card yields for a variant, per field, as
 * `{ text, source }`, or null to keep the Chinese original.
 *
 * `card` carries `translations` and `bases` — entry lists from
 * translations.json and translations.base.json, own id first then alias —
 * and `mdpro4En`/`mdpro4Es`, the MDPro4 rows for the card's own id, with
 * `aliasMdpro4En`/`aliasMdpro4Es` the rows of the card it aliases.
 */
export function resolveCardTexts(card, variant) {
	const english = [
		["translations", translationTier(card.translations ?? [], "en")],
		["mdpro4", mdpro4Tier(card.mdpro4En)],
		["alias.mdpro4", mdpro4Tier(card.aliasMdpro4En)],
	];
	const chain =
		variant === "es"
			? [
					["translations", translationTier(card.translations ?? [], "es")],
					["base", translationTier(card.bases ?? [], "es")],
					["mdpro4", mdpro4SpanishTier(card.mdpro4Es, card.mdpro4En)],
					["alias.mdpro4", mdpro4SpanishTier(card.aliasMdpro4Es, card.aliasMdpro4En)],
					...english.map(([source, tier]) => [`en.${source}`, tier]),
				]
			: english;
	const pick = (field) => {
		for (const [source, tier] of chain) {
			if (tier[field]) return { text: tier[field], source };
		}
		return null;
	};
	return { name: pick("name"), desc: pick("desc") };
}

// --- Maximum ATK ---
//
// A Maximum monster is played as three cards: a centre piece and an [L]/[R]
// pair. MDPro3 draws the centre piece's Maximum ATK box from the DESCRIPTION,
// not from a column: Card.GetRushDescriptionBodyStartIndex looks at the first
// non-empty line of a TYPE_MAXIMUM card and, for a non-Chinese client language,
// accepts it only when it starts with "Maximum ATK" and splits into 2..4
// space-separated parts. It then reads the trailing digits and drops the line
// from the body it renders.
//
// Upstream ships that value only in Chinese, as a `极大攻击 <n>` line, and only
// on the centre pieces. It is NOT the `atk` column — 120150002 has atk 1900 and
// Maximum ATK 3500 — so the Chinese text is the only source there is.
//
// The literal is English in BOTH the en and es variants on purpose: MDPro3
// matches the Spanish client against the same "Maximum ATK" prefix and only
// accepts `极大攻击`/`極大攻擊` when the client language is zh-CN or zh-TW.
const TYPE_MAXIMUM = 0x8000;

// Anchored to the whole line, mirroring the client's own "the line IS the
// declaration" reading: a `极大攻击` mentioned inside a sentence is not one.
const MAXIMUM_ATK_LINE = /^极大攻击\s*(\d+)$/;

/** The Maximum ATK a Chinese desc declares on a line of its own, or null. */
export function parseMaximumAtk(desc) {
	// Chinese descs are CRLF-terminated; translated lore is LF.
	for (const line of (desc ?? "").split(/\r?\n/)) {
		const match = MAXIMUM_ATK_LINE.exec(line.trim());
		if (match) return Number(match[1]);
	}
	return null;
}

/**
 * Whether a Maximum card is an [L]/[R] half. Upstream names them with FULLWIDTH
 * brackets (U+FF3B/U+FF3D), never the ASCII pair.
 */
export function isMaximumSidePiece(name) {
	return (name ?? "").includes("［L］") || (name ?? "").includes("［R］");
}

/**
 * Sorts the TYPE_MAXIMUM rows into the centre pieces that declare a value, the
 * [L]/[R] halves, and the centre pieces that declare none. The last bucket is
 * reported rather than guessed at: a centre piece that renames itself to a half
 * in hand legitimately has no box to draw, and inventing a value would draw one.
 */
export function classifyMaximumRows(rows) {
	const withValue = [];
	const sidePieces = [];
	const centreWithoutValue = [];

	for (const { id, name, desc } of [...rows].sort((a, b) => a.id - b.id)) {
		if (isMaximumSidePiece(name)) {
			sidePieces.push(id);
			continue;
		}
		const atk = parseMaximumAtk(desc);
		if (atk === null) centreWithoutValue.push(id);
		else withValue.push({ id, atk });
	}

	return { withValue, sidePieces, centreWithoutValue };
}

// Whether a desc already leads with the line, as MDPro4's descs do: the
// client only reads the first non-empty line, so a second one would print.
const LEADING_MAXIMUM_LINE = /^Maximum ATK\s+\d+/;

/**
 * A desc led by `Maximum ATK <atk>`. Prepended, never inserted after a print
 * code: MDPro3 skips the first line only for zh-CN/zh-TW, so a print code
 * carried into en/es would show up as visible body text. A desc that already
 * leads with the line, or a card with no value, is returned as is.
 */
export function withMaximumLine(desc, atk) {
	if (atk === null || atk === undefined) return desc;
	const firstLine = desc.split("\n").find((line) => line.trim() !== "") ?? "";
	if (LEADING_MAXIMUM_LINE.test(firstLine.trim())) return desc;
	return `Maximum ATK ${atk}\n${desc}`;
}

// SQL single-quote escaping — the sqlite3 CLI has no parameter binding.
function sqlQuote(text) {
	return `'${text.replaceAll("'", "''")}'`;
}

/**
 * UPDATE script, per-source counts and machine-translation suspects for one
 * variant. `cards` are the shipped cards in id order, each a resolveCardTexts
 * input plus its `id` and, on a Maximum monster that declares one, its
 * `maximumAtk`.
 *
 * Every card counts once per field, `zh` included, so a variant's counts add
 * up to the cards shipped. `telltales` lists the ids whose MDPro4 Spanish was
 * used and looks machine translated (always empty for en).
 */
export function buildVariantUpdates(cards, variant) {
	const counts = () => Object.fromEntries(VARIANT_SOURCES[variant].map((source) => [source, 0]));
	const stats = { name: counts(), desc: counts() };
	const statements = [];
	const telltales = [];

	for (const card of cards) {
		const { name, desc } = resolveCardTexts(card, variant);
		const sets = [];
		stats.name[name?.source ?? "zh"]++;
		stats.desc[desc?.source ?? "zh"]++;
		if (name) sets.push(`name=${sqlQuote(name.text)}`);
		if (desc) {
			sets.push(`"desc"=${sqlQuote(withMaximumLine(desc.text, card.maximumAtk))}`);
		} else if (card.maximumAtk !== undefined && card.maximumAtk !== null) {
			// The Chinese desc stays, so the line goes on top of it in SQL.
			sets.push(`"desc"=${sqlQuote(`Maximum ATK ${card.maximumAtk}`)} || char(10) || "desc"`);
		}
		if (sets.length > 0) statements.push(`UPDATE texts SET ${sets.join(",")} WHERE id=${card.id};`);

		const spanishRow = (source) =>
			source === "mdpro4" ? card.mdpro4Es : source === "alias.mdpro4" ? card.aliasMdpro4Es : null;
		const fromMdpro4 = [
			spanishRow(name?.source)?.name,
			spanishRow(desc?.source)?.desc,
		];
		if (variant === "es" && fromMdpro4.some((text) => text && hasMachineTranslationTelltale(text))) {
			telltales.push(card.id);
		}
	}

	return { sql: statements.join("\n"), stats, telltales };
}

// --- Alternate artwork ---
//
// MDPro4 numbers its alternate arts from 129000000 up, each aliasing the card
// it reprints. Its anime customs sit in 128000000..128999999, flagged ot & 4,
// and have no mycard row or script.
const ALTERNATE_ART_MIN_ID = 129000000;
const ANIME_CUSTOM_MIN_ID = 128000000;
const ANIME_CUSTOM_MAX_ID = 128999999;
const OT_CUSTOM = 4;

/**
 * The MDPro4 alternate-art rows the union gains, in id order, as
 * `{ id, alias }`. `rows` are MDPro4's `datas` rows (`id`, `ot`, `alias`);
 * an alias must be a union card and not an anime custom. Alternate arts carry
 * ot & 4 themselves, so the flag only marks a custom on a card mycard lacks.
 */
export function selectAliasRows(rows, unionIds) {
	const otById = new Map(rows.map(({ id, ot }) => [id, ot]));
	const isAnimeCustom = (id) =>
		(id >= ANIME_CUSTOM_MIN_ID && id <= ANIME_CUSTOM_MAX_ID) ||
		((otById.get(id) ?? 0) & OT_CUSTOM && !unionIds.has(id));
	return rows
		.filter(({ id, alias }) => id >= ALTERNATE_ART_MIN_ID && unionIds.has(alias) && !isAnimeCustom(alias))
		.map(({ id, alias }) => ({ id, alias }))
		.sort((a, b) => a.id - b.id);
}

const MECHANICS_COLUMNS = ["type", "atk", "def", "level", "race", "attribute", "setcode"];

/**
 * Which MDPro4 cards are mycard cards under an old id. `rows` are MDPro4's
 * `datas` rows with its English `name`; `unionCards` are every mycard card with
 * its English `name` (empty or absent when untranslated). A candidate has no
 * alias, an id below the anime customs and none in the union. It is admitted
 * only when its trimmed, case-insensitive name matches exactly one union card
 * whose mechanics are identical; anything else is skipped with a reason.
 * Returns `{ admitted: [{ id, alias }], skipped: [{ id, reason }] }` in id order.
 */
export function selectRenumberedRows(rows, unionCards) {
	const normalise = (name) => (name ?? "").trim().toLowerCase();
	const unionIds = new Set(unionCards.map(({ id }) => id));
	const byName = new Map();
	for (const union of unionCards) {
		const name = normalise(union.name);
		if (name === "") continue;
		byName.set(name, [...(byName.get(name) ?? []), union]);
	}
	const admitted = [];
	const skipped = [];
	const candidates = rows
		.filter((row) => row.id < ANIME_CUSTOM_MIN_ID && row.alias === 0 && !unionIds.has(row.id))
		.sort((a, b) => a.id - b.id);
	for (const row of candidates) {
		const matches = byName.get(normalise(row.name)) ?? [];
		if (matches.length === 0) {
			skipped.push({ id: row.id, reason: "no mycard card with this name" });
		} else if (matches.length > 1) {
			skipped.push({ id: row.id, reason: "ambiguous name" });
		} else if (MECHANICS_COLUMNS.some((column) => row[column] !== matches[0][column])) {
			skipped.push({ id: row.id, reason: "mechanics differ" });
		} else {
			admitted.push({ id: row.id, alias: matches[0].id });
		}
	}
	return { admitted, skipped };
}

// --- Effect strings ---
//
// texts.str1..str16 are not card text: they are the prompts the duel client
// shows when a card asks the player to choose, addressed from lua as
// `aux.Stringid(id, offset)` and resolved by the client as `(id << 4) | offset`.
// Upstream ships them in Chinese only, so without this step players read
// Chinese mid-duel in the en/es variants.
//
// The dictionary is mined, not translated — see build-effect-strings.mjs. Only
// an exact whole-string hit is replaced: a prompt that merely CONTAINS a known
// term is a sentence of its own and substituting inside it would produce
// half-translated prose. A miss falls back to MDPro4's prompt for the same
// card and slot; with none to offer the Chinese stays, and a prompt is never
// blanked.

// CJK ideographs only. Fullwidth punctuation survives translation in some
// prompts, so it is not evidence that a field is still untranslated.
const CHINESE_CHARACTER = /[\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff]/;

/** The dictionary reduced to one language, dropping terms it has no entry for. */
export function termsForLanguage(effectStrings, language) {
	const terms = {};
	for (const [chinese, entry] of Object.entries(effectStrings)) {
		if (entry[language]) terms[chinese] = entry[language];
	}
	return terms;
}

// Every source label a prompt can report. `original` is a prompt that was
// never Chinese (a bare number) and ships as is; `zh` is a Chinese prompt no
// source could replace.
const STR_SOURCES = ["dictionary", "mdpro4", "mdpro4.en", "original", "zh"];

const readablePrompt = (text) => Boolean(text) && !CHINESE_CHARACTER.test(text);

/**
 * MDPro4's prompt for one slot, as `{ text, source }` or null. `candidates`
 * are `{ en, es }` pairs of MDPro4 str rows, the card's own first and its
 * alias's after. In es a Spanish prompt (readable, and not a copy of the
 * English one) outranks the English one across all candidates.
 */
function mdpro4Prompt(candidates, name, variant) {
	const pairs = candidates
		.filter(Boolean)
		.map(({ en, es }) => ({ en: en?.[name], es: es?.[name] }));
	const english = pairs.map(({ en }) => en).find(readablePrompt);
	if (variant !== "es") return english ? { text: english, source: "mdpro4" } : null;
	const spanish = pairs.find(({ en, es }) => readablePrompt(es) && es !== en)?.es;
	if (spanish) return { text: spanish, source: "mdpro4" };
	return english ? { text: english, source: "mdpro4.en" } : null;
}

/**
 * Every non-empty str field of one row with the text it ships and where that
 * came from: the dictionary, else — for a prompt still Chinese — MDPro4's
 * (`row.mdpro4`, the `{ en, es }` pairs for the card and its alias), else the
 * original.
 */
function resolveStrRow(row, terms, variant) {
	const prompts = [];
	for (const name of STR_NAMES) {
		const chinese = row[name];
		if (!chinese) continue;
		const translated = terms[chinese];
		let resolved;
		if (translated !== undefined && translated !== chinese) {
			resolved = { text: translated, source: "dictionary" };
		} else if (!CHINESE_CHARACTER.test(chinese)) {
			resolved = { text: chinese, source: "original" };
		} else {
			resolved = mdpro4Prompt(row.mdpro4 ?? [], name, variant) ?? { text: chinese, source: "zh" };
		}
		prompts.push({ name, ...resolved });
	}
	return prompts;
}

const isReplacement = ({ source }) => source !== "original" && source !== "zh";

/**
 * UPDATEs replacing every prompt a source can translate, one statement per row
 * that has at least one, plus the number of str fields replaced.
 */
export function buildEffectStringUpdates(rows, terms, variant = "en") {
	const statements = [];
	let replaced = 0;

	for (const row of rows) {
		const changes = resolveStrRow(row, terms, variant).filter(isReplacement);
		if (changes.length === 0) continue;
		replaced += changes.length;
		statements.push(
			`UPDATE texts SET ${changes.map(({ name, text }) => `${name}=${sqlQuote(text)}`).join(",")} ` +
				`WHERE id=${row.id};`,
		);
	}

	return { sql: statements.join("\n"), replaced };
}

/**
 * How many non-empty str fields the merged db holds, how many of them a
 * player would read in their own language once the prompts are resolved, and
 * how many fields each source supplied. Counted on the resulting text rather
 * than on the replacements: a field that was never Chinese to begin with (a
 * bare number) already reads fine.
 */
export function countStrCoverage(rows, terms, variant = "en") {
	let total = 0;
	let nonChinese = 0;
	const sources = Object.fromEntries(STR_SOURCES.map((source) => [source, 0]));

	for (const row of rows) {
		for (const { text, source } of resolveStrRow(row, terms, variant)) {
			total++;
			sources[source]++;
			if (!CHINESE_CHARACTER.test(text)) nonChinese++;
		}
	}

	return { total, nonChinese, sources };
}

// The TYPE_MAXIMUM texts rows, as JSON — descs are multi-line, which the CLI's
// default row format cannot round-trip.
function readMaximumRows(cdbPath) {
	const out = sqlite(
		cdbPath,
		"SELECT json_group_array(json_object('id',id,'name',name,'desc',\"desc\")) FROM " +
			`(SELECT t.id, t.name, t."desc" FROM datas d JOIN texts t ON t.id=d.id ` +
			`WHERE d.type & ${TYPE_MAXIMUM});`,
	).trim();
	return JSON.parse(out);
}

function readIds(cdbPath) {
	const out = sqlite(cdbPath, "SELECT id FROM datas ORDER BY id;").trim();
	return out === "" ? [] : out.split("\n").map(Number);
}

// One table of a cdb as JSON rows — descs are multi-line, which the CLI's
// default row format cannot round-trip.
function readJsonRows(cdbPath, columns, table) {
	const fields = columns.map((column) => `'${column}',"${column}"`).join(",");
	const out = sqlite(cdbPath, `SELECT json_group_array(json_object(${fields})) FROM ${table};`).trim();
	return JSON.parse(out);
}

/** id → { name, desc, str1..str16 } over one MDPro4 cdb. */
function readMdpro4Texts(cdbPath) {
	return new Map(
		readJsonRows(cdbPath, ["id", "name", "desc", ...STR_NAMES], "texts").map((row) => [row.id, row]),
	);
}

// Deterministic gzip of a raw cdb: node's zlib writes a zero mtime and no
// name, matching the `gzip -9 -n` the other cdb pipelines use.
function gzipTo(rawPath, gzPath) {
	writeFileSync(gzPath, gzipSync(readFileSync(rawPath), { level: 9 }));
}

/**
 * Put the file at `builtPath` in place at `targetPath` unless the bytes are
 * already there. Returns "changed" or "unchanged". Leaving an identical file
 * alone keeps its mtime and the git status clean on a no-op run.
 */
export function installIfChanged(builtPath, targetPath) {
	const built = readFileSync(builtPath);
	if (existsSync(targetPath) && built.equals(readFileSync(targetPath))) return "unchanged";
	// Written beside the target and renamed over it, so an interrupted run
	// never leaves a half-written database where the server loads it from.
	const staging = `${targetPath}.tmp`;
	writeFileSync(staging, built);
	renameSync(staging, targetPath);
	return "changed";
}

// MDPro4 ships a renumbered card with alias 0; the copied row must point at
// the mycard id it stands for. Alternate arts already carry their alias.
function aliasFixSql(renumbered) {
	if (renumbered.length === 0) return "";
	const cases = renumbered.map(({ id, alias }) => `WHEN ${id} THEN ${alias}`).join(" ");
	const ids = renumbered.map(({ id }) => id).join(",");
	return `UPDATE datas SET alias = CASE id ${cases} END WHERE id IN (${ids});`;
}

/**
 * Write the admitted alternate-art rows as a stand-alone cdb: `datas` verbatim
 * and `texts` cleaned like the plain unified cdb's, in id order so the bytes
 * depend only on the rows. The schema is the first source's, which keeps it
 * loadable exactly like the per-origin files.
 */
function writeAlternateCdb(path, schemaSource, mdpro4EnPath, aliasRows, renumbered) {
	const ids = aliasRows.map(({ id }) => id).join(",");
	const schema = execFileSync("sqlite3", [schemaSource, ".schema"], { encoding: "utf8" });
	execFileSync("sqlite3", [path], { input: schema, encoding: "utf8" });
	sqlite(
		path,
		`ATTACH ${sqlQuote(mdpro4EnPath)} AS m;` +
			`INSERT INTO datas SELECT * FROM m.datas WHERE id IN (${ids}) ORDER BY id;` +
			`INSERT INTO texts SELECT id, replace(name,'&quot;','"'), ` +
			`replace(replace("desc",'&quot;','"'),char(9)||char(10),char(10)), ${STR_NAMES.join(",")} ` +
			`FROM m.texts WHERE id IN (${ids}) ORDER BY id;` +
			aliasFixSql(renumbered),
	);
}

/**
 * Merge the source cdbs, plus the admitted MDPro4 alternate arts, into workDir
 * and gzip the three variants into outDir. Throws before anything lands in
 * outDir when a card id appears in more than one source. Returns the merge and
 * per-variant translation stats.
 *
 * `mdpro4` is `{ en, es }`, the paths of the MDPro4 cdbs; without it the build
 * is the plain mycard union with our translations only.
 *
 * With alternate arts admitted, the stand-alone alternate cdb is also written
 * into workDir (`stats.alternate.path`); placing it is the caller's job.
 */
export function buildRushCdbs({
	sources,
	translations,
	translationsBase = {},
	mdpro4 = null,
	effectStrings = {},
	outDir,
	workDir,
}) {
	const idLists = sources.map(readIds);
	const unionIds = new Set(idLists.flat());
	const mdpro4Datas = mdpro4
		? readJsonRows(mdpro4.en, ["id", "ot", "alias", ...MECHANICS_COLUMNS], "datas")
		: [];
	const mdpro4En = mdpro4 ? readMdpro4Texts(mdpro4.en) : new Map();
	const renumbered = mdpro4
		? selectRenumberedRows(
				mdpro4Datas.map((row) => ({
					...row,
					name: cleanMdpro4Text(mdpro4En.get(row.id)?.name),
				})),
				sources.flatMap((src) =>
					readJsonRows(src, ["id", ...MECHANICS_COLUMNS], "datas").map((row) => ({
						...row,
						name: translations[row.id]?.en,
					})),
				),
			)
		: { admitted: [], skipped: [] };
	const aliasRows = [...(mdpro4 ? selectAliasRows(mdpro4Datas, unionIds) : []), ...renumbered.admitted];
	const duplicates = findDuplicateIds([...idLists, aliasRows.map(({ id }) => id)]);
	if (duplicates.length > 0) {
		throw new Error(
			`duplicate card ids across source cdbs (precedence needs a human decision): ${duplicates.join(", ")}`,
		);
	}

	// Seed the schema from the first source, then insert the union in global id
	// order — insert order fixes the page layout, so output bytes are stable.
	const rawPath = join(workDir, "rush.cdb");
	const schema = execFileSync("sqlite3", [sources[0], ".schema"], { encoding: "utf8" });
	execFileSync("sqlite3", [rawPath], { input: schema, encoding: "utf8" });

	const attaches = sources.map((src, i) => `ATTACH ${sqlQuote(src)} AS s${i};`).join("");
	const selects = (table) => sources.map((_, i) => `SELECT * FROM s${i}.${table}`);
	// The alternate arts join the same ordered INSERT. Their texts are MDPro4's
	// English, cleaned the way cleanMdpro4Text cleans it: there is no Chinese
	// for them, and the translated variants overwrite name/desc anyway.
	const aliasIdList = aliasRows.map(({ id }) => id).join(",");
	const strColumns = STR_NAMES.join(",");
	const aliasSelects = aliasRows.length
		? {
				datas: [`SELECT * FROM m.datas WHERE id IN (${aliasIdList})`],
				texts: [
					`SELECT id, replace(name,'&quot;','"'), ` +
						`replace(replace("desc",'&quot;','"'),char(9)||char(10),char(10)), ${strColumns} ` +
						`FROM m.texts WHERE id IN (${aliasIdList})`,
				],
			}
		: { datas: [], texts: [] };
	const mdpro4Attach = aliasRows.length ? `ATTACH ${sqlQuote(mdpro4.en)} AS m;` : "";
	const union = (table) => [...selects(table), ...aliasSelects[table]].join(" UNION ALL ");
	// Plain INSERT (never OR REPLACE): a conflict the id pre-check missed must
	// still abort, not silently pick a winner.
	sqlite(
		rawPath,
		attaches +
			mdpro4Attach +
			`INSERT INTO datas SELECT * FROM (${union("datas")}) ORDER BY id;` +
			`INSERT INTO texts SELECT * FROM (${union("texts")}) ORDER BY id;` +
			aliasFixSql(renumbered.admitted),
	);

	const aliasById = new Map(aliasRows.map(({ id, alias }) => [id, alias]));
	// Read off the merged Chinese rows: the value only ever exists there. An
	// alternate art has no Chinese text and inherits its base card's value.
	const maximumAtk = classifyMaximumRows(
		readMaximumRows(rawPath).filter(({ id }) => !aliasById.has(id)),
	);
	const maximumById = new Map(maximumAtk.withValue.map(({ id, atk }) => [id, atk]));
	const strRows = readStrRows(rawPath);

	const mdpro4Es = mdpro4 ? readMdpro4Texts(mdpro4.es) : new Map();
	// The card each row reprints, from the merged `datas`: mycard's own alias
	// column as much as the MDPro4 arts'.
	const reprintOf = new Map(
		readJsonRows(rawPath, ["id", "alias"], "datas")
			.filter(({ id, alias }) => alias !== 0 && alias !== id)
			.map(({ id, alias }) => [id, alias]),
	);
	const cards = [...unionIds, ...aliasById.keys()]
		.sort((a, b) => a - b)
		.map((id) => {
			const alias = aliasById.get(id);
			const keys = alias === undefined ? [id] : [id, alias];
			const reprint = reprintOf.get(id);
			return {
				id,
				translations: keys.map((key) => translations[key]),
				bases: keys.map((key) => translationsBase[key]),
				mdpro4En: mdpro4En.get(id),
				mdpro4Es: mdpro4Es.get(id),
				aliasMdpro4En: mdpro4En.get(reprint),
				aliasMdpro4Es: mdpro4Es.get(reprint),
				maximumAtk: maximumById.get(alias ?? id),
			};
		});
	// The MDPro4 rows each prompt can fall back on: the card's own, then the
	// card it reprints.
	const promptRows = strRows.map((row) => ({
		...row,
		mdpro4: [row.id, reprintOf.get(row.id)].map((id) => ({ en: mdpro4En.get(id), es: mdpro4Es.get(id) })),
	}));

	const variants = {};
	const strCoverage = {};
	for (const variant of ["en", "es"]) {
		const variantPath = join(workDir, `rush.${variant}.cdb`);
		copyFileSync(rawPath, variantPath);
		const { sql, stats, telltales } = buildVariantUpdates(cards, variant);
		const terms = termsForLanguage(effectStrings, variant);
		const effectSql = buildEffectStringUpdates(promptRows, terms, variant);
		const coverage = countStrCoverage(promptRows, terms, variant);
		strCoverage[variant] = {
			replaced: effectSql.replaced,
			nonChinese: coverage.nonChinese,
			sources: coverage.sources,
		};
		const script = [sql, effectSql.sql].filter((part) => part !== "").join("\n");
		if (script !== "") {
			execFileSync("sqlite3", [variantPath], {
				input: `BEGIN;\n${script}\nCOMMIT;\n`,
				encoding: "utf8",
			});
		}
		variants[variant] = variant === "es" ? { ...stats, telltales: sampled(telltales, 10) } : stats;
	}

	let alternate = { rows: 0, path: null };
	if (aliasRows.length > 0) {
		const path = join(workDir, ALTERNATE_CDB_NAME);
		writeAlternateCdb(path, sources[0], mdpro4.en, aliasRows, renumbered.admitted);
		alternate = { rows: aliasRows.length, path };
	}

	gzipTo(rawPath, join(outDir, "rush.cdb.gz"));
	gzipTo(join(workDir, "rush.en.cdb"), join(outDir, "rush.en.cdb.gz"));
	gzipTo(join(workDir, "rush.es.cdb"), join(outDir, "rush.es.cdb.gz"));

	return {
		merged: {
			perSource: sources.map((src, i) => ({ name: basename(src), rows: idLists[i].length })),
			aliasRows: aliasRows.length,
			total: cards.length,
		},
		variants,
		alternate,
		renumbered,
		maximumAtk: {
			withValue: maximumAtk.withValue.length,
			sidePieces: maximumAtk.sidePieces.length,
			centreWithoutValue: maximumAtk.centreWithoutValue,
		},
		effectStrings: {
			total: countStrCoverage(strRows, {}).total,
			en: strCoverage.en,
			es: strCoverage.es,
		},
	};
}

/**
 * The run-report fragment for this step. The builder always rewrites the
 * gzips, so `changed` is decided by the caller from their bytes: a digest
 * taken before against one taken after the build.
 */
export function buildCdbFragment(stats, changed) {
	const alternateChanged = stats.alternate?.status === "changed";
	return {
		step: "build-cdb",
		status: changed || alternateChanged ? "changed" : "unchanged",
		merged: stats.merged,
		variants: stats.variants,
		maximumAtk: stats.maximumAtk,
		effectStrings: stats.effectStrings,
		...(stats.alternate ? { alternate: stats.alternate } : {}),
		...(stats.renumbered ? { renumbered: stats.renumbered } : {}),
	};
}

// sha256 per published gz, null before the first build — the before/after
// pair decides the fragment's changed/unchanged verdict.
function gzDigests() {
	const digests = {};
	for (const name of ["rush.cdb.gz", "rush.en.cdb.gz", "rush.es.cdb.gz"]) {
		const path = join(OUT_DIR, name);
		digests[path] = existsSync(path)
			? createHash("sha256").update(readFileSync(path)).digest("hex")
			: null;
	}
	return digests;
}

function main() {
	const translations = JSON.parse(readFileSync(TRANSLATIONS_PATH, "utf8"));
	const translationsBase = existsSync(TRANSLATIONS_BASE_PATH)
		? JSON.parse(readFileSync(TRANSLATIONS_BASE_PATH, "utf8"))
		: {};
	// Checked up front: the sqlite3 CLI would silently create an empty db for a
	// missing path, and the build would then ship without the MDPro4 tiers.
	for (const path of [MDPRO4_EN_PATH, MDPRO4_ES_PATH]) {
		if (!existsSync(path)) {
			console.error(`aborted, ${OUT_DIR}/ untouched: missing ${path}`);
			process.exit(1);
		}
	}
	const effectStrings = mergeEffectStrings(
		JSON.parse(readFileSync(EFFECT_STRINGS_PATH, "utf8")),
		JSON.parse(readFileSync(EFFECT_STRINGS_MANUAL_PATH, "utf8")),
	);
	const workDir = mkdtempSync(join(tmpdir(), "rush-cdb-"));
	const before = gzDigests();

	let stats;
	try {
		stats = buildRushCdbs({
			sources: RUSH_CDBS,
			translations,
			translationsBase,
			mdpro4: { en: MDPRO4_EN_PATH, es: MDPRO4_ES_PATH },
			effectStrings,
			outDir: OUT_DIR,
			workDir,
		});
		if (stats.alternate.path) {
			stats.alternate = {
				rows: stats.alternate.rows,
				status: installIfChanged(stats.alternate.path, ALTERNATE_CDB_PATH),
			};
		} else {
			stats.alternate = { rows: 0, status: "unchanged" };
		}
	} catch (err) {
		console.error(`aborted, ${OUT_DIR}/ untouched: ${err.message}`);
		process.exit(1);
	} finally {
		rmSync(workDir, { recursive: true, force: true });
	}

	for (const { name, rows } of stats.merged.perSource) console.error(`merged ${name}: ${rows} rows`);
	console.error(`MDPro4 alternate arts and renumbered cards: ${stats.merged.aliasRows} rows`);
	for (const { id, reason } of stats.renumbered.skipped) console.error(`not renumbered ${id}: ${reason}`);
	console.error(`total: ${stats.merged.total} rows`);
	console.error(
		`${ALTERNATE_CDB_PATH}: ${stats.alternate.rows} rows, ${stats.alternate.status}`,
	);
	// Counted against every card shipped, so the zh count is the gap left.
	const sourceCounts = (counts) =>
		Object.entries(counts)
			.map(([source, count]) => `${source} ${count}`)
			.join(", ");
	for (const variant of ["en", "es"]) {
		const { name, desc } = stats.variants[variant];
		console.error(`${variant} names: ${sourceCounts(name)}`);
		console.error(`${variant} descs: ${sourceCounts(desc)}`);
	}
	const { telltales } = stats.variants.es;
	if (telltales.count > 0) {
		console.error(
			`es: ${telltales.count} MDPro4 Spanish texts look machine translated ` +
				`(e.g. ${telltales.sample.join(", ")})`,
		);
	}

	const { withValue, sidePieces, centreWithoutValue } = stats.maximumAtk;
	console.error(
		`Maximum ATK: ${withValue} centre pieces lead en/es with the line ` +
			`(${sidePieces} [L]/[R] halves, ${centreWithoutValue.length} centre pieces declare none)`,
	);

	const { total, en: enStr, es: esStr } = stats.effectStrings;
	const share = (count) => (total === 0 ? "0%" : `${((100 * count) / total).toFixed(1)}%`);
	console.error(
		`effect strings: ${total} prompts, ` +
			`en ${enStr.nonChinese} readable (${share(enStr.nonChinese)}, ${enStr.replaced} replaced), ` +
			`es ${esStr.nonChinese} readable (${share(esStr.nonChinese)}, ${esStr.replaced} replaced)`,
	);
	console.error(`effect strings en: ${sourceCounts(enStr.sources)}`);
	console.error(`effect strings es: ${sourceCounts(esStr.sources)}`);

	const changed = JSON.stringify(gzDigests()) !== JSON.stringify(before);
	reportFragment(process.env, buildCdbFragment(stats, changed));
}

if (process.argv[1]?.endsWith("build-rush-cdb.mjs")) {
	main();
}

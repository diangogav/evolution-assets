import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { gunzipSync } from "node:zlib";

import {
	buildCdbFragment,
	buildEffectStringUpdates,
	buildRushCdbs,
	buildVariantUpdates,
	installIfChanged,
	classifyMaximumRows,
	cleanMdpro4Text,
	composeDesc,
	countStrCoverage,
	findDuplicateIds,
	hasMachineTranslationTelltale,
	isMaximumSidePiece,
	mergeEffectStrings,
	parseMaximumAtk,
	resolveCardTexts,
	selectAliasRows,
	termsForLanguage,
	withMaximumLine,
} from "./build-rush-cdb.mjs";

const SCHEMA =
	"CREATE TABLE datas(id integer primary key,ot integer,alias integer,setcode integer," +
	"type integer,atk integer,def integer,level integer,race integer,attribute integer,category integer);" +
	"CREATE TABLE texts(id integer primary key,name text,desc text,str1 text,str2 text,str3 text," +
	"str4 text,str5 text,str6 text,str7 text,str8 text,str9 text,str10 text,str11 text,str12 text," +
	"str13 text,str14 text,str15 text,str16 text);";

function makeCdb(path, cards) {
	execFileSync("sqlite3", [path], { input: SCHEMA, encoding: "utf8" });
	for (const { id, ot, alias, type, name, desc, str1 } of cards) {
		execFileSync("sqlite3", [
			path,
			`INSERT INTO datas(id,ot,alias,type) VALUES(${id},${ot ?? 1},${alias ?? 0},${type ?? 1});` +
				`INSERT INTO texts(id,name,desc,str1) VALUES(${id},'${name}','${desc ?? ""}','${str1 ?? ""}');`,
		]);
	}
}

function sha256(buf) {
	return createHash("sha256").update(buf).digest("hex");
}

// Decompress a variant gz into a raw cdb and query it with sqlite3.
function queryGz(dir, gzPath, sql) {
	const raw = join(dir, `q-${sha256(Buffer.from(gzPath)).slice(0, 8)}.cdb`);
	execFileSync("sh", ["-c", `gunzip -c '${gzPath}' > '${raw}'`]);
	return execFileSync("sqlite3", ["-separator", "\t", raw, sql], { encoding: "utf8" }).replace(
		/\n$/,
		"",
	);
}

test("findDuplicateIds is empty for disjoint sources", () => {
	assert.deepEqual(
		findDuplicateIds([
			[1, 2],
			[3, 4],
			[5],
		]),
		[],
	);
});

test("findDuplicateIds reports every id shared between sources, sorted", () => {
	assert.deepEqual(
		findDuplicateIds([
			[7, 1, 2],
			[2, 3],
			[3, 7],
		]),
		[2, 3, 7],
	);
});

// --- composeDesc: the two blocks a Rush card prints, in the printed order ---

test("composeDesc labels both blocks when the card has a requirement", () => {
	assert.equal(
		composeDesc(
			"Send 1 EARTH monster from your hand to the Graveyard.",
			"1 face-up monster on your opponent's field loses ATK.",
		),
		"[REQUIREMENT]\nSend 1 EARTH monster from your hand to the Graveyard.\n\n" +
			"[EFFECT]\n1 face-up monster on your opponent's field loses ATK.",
	);
});

test("composeDesc labels the Spanish blocks in Spanish", () => {
	assert.equal(
		composeDesc("Manda 1 monstruo de tu mano al Cementerio.", "Roba 1 carta.", "es"),
		"[REQUISITO]\nManda 1 monstruo de tu mano al Cementerio.\n\n[EFECTO]\nRoba 1 carta.",
	);
});

test("hasMachineTranslationTelltale needs the coin-flip words as labels, not substrings", () => {
	assert.equal(hasMachineTranslationTelltale("Cabezas: destruye todos monstruos"), true);
	assert.equal(hasMachineTranslationTelltale("Tails: destruye"), true);
	assert.equal(hasMachineTranslationTelltale("Las cabezas de la hidra"), false);
	assert.equal(hasMachineTranslationTelltale("Cocktails en la fiesta"), false);
});

test("composeDesc leaves a card with no requirement as its bare effect", () => {
	const effect = "A fast and lethal creature with very dangerous claws.";
	assert.equal(composeDesc("", effect), effect);
	assert.equal(composeDesc(undefined, effect), effect);
});

// --- resolveCardTexts: the per-locale fallback chain for one card ---

// A card as buildRushCdbs hands it over: translation entries in precedence
// order (its own id first, then the base card an alternate art aliases) and
// the MDPro4 rows for its own id.
function card({ translations = [], bases = [], mdpro4En, mdpro4Es } = {}) {
	return { translations, bases, mdpro4En, mdpro4Es };
}

test("resolveCardTexts en: translations.json fields apply only when non-empty", () => {
	const full = resolveCardTexts(card({ translations: [{ en: "Alpha", en_lore: "Lore", es: "x", es_lore: "y" }] }), "en");
	assert.deepEqual(full, {
		name: { text: "Alpha", source: "translations" },
		desc: { text: "Lore", source: "translations" },
	});

	const empty = resolveCardTexts(card({ translations: [{ en: "", en_lore: "", es: "x", es_lore: "y" }] }), "en");
	assert.deepEqual(empty, { name: null, desc: null });
});

test("resolveCardTexts en: MDPro4 English fills what translations.json lacks", () => {
	const texts = resolveCardTexts(
		card({
			translations: [{ en: "Alpha", en_lore: "" }],
			mdpro4En: { name: "Alpha MD", desc: "[REQUIREMENT]\t\nNone\t\n[EFFECT]\t\nDraw 1." },
		}),
		"en",
	);
	assert.deepEqual(texts, {
		name: { text: "Alpha", source: "translations" },
		// The MDPro4 line ends are tab+LF; the tab is dropped.
		desc: { text: "[REQUIREMENT]\nNone\n[EFFECT]\nDraw 1.", source: "mdpro4" },
	});
});

test("resolveCardTexts es: per-field fallback through the English chain, null at the end", () => {
	const es = resolveCardTexts(
		card({ translations: [{ en: "Alpha", en_lore: "Lore", es: "Alfa", es_lore: "" }] }),
		"es",
	);
	assert.deepEqual(es, {
		name: { text: "Alfa", source: "translations" },
		desc: { text: "Lore", source: "en.translations" },
	});

	const none = resolveCardTexts(card({ translations: [{ en: "", en_lore: "", es: "", es_lore: "" }] }), "es");
	assert.deepEqual(none, { name: null, desc: null });
});

test("resolveCardTexts es: translations.json, then the mined base, then MDPro4, then English", () => {
	const mdpro4En = { name: "Alpha MD", desc: "Effect MD." };
	const mdpro4Es = { name: "Alfa MD", desc: "Efecto MD." };

	// The fetched Spanish wins over the mined one.
	assert.deepEqual(
		resolveCardTexts(card({ translations: [{ es: "Alfa" }], bases: [{ es: "Alfa minada" }], mdpro4En, mdpro4Es }), "es").name,
		{ text: "Alfa", source: "translations" },
	);
	// An empty fetched field is a gap, so the mined value shows through.
	assert.deepEqual(
		resolveCardTexts(card({ translations: [{ es: "", es_lore: "" }], bases: [{ es: "Alfa minada", es_lore: "Efecto minado." }], mdpro4En, mdpro4Es }), "es"),
		{
			name: { text: "Alfa minada", source: "base" },
			desc: { text: "Efecto minado.", source: "base" },
		},
	);
	// MDPro4 Spanish outranks every English source.
	assert.deepEqual(
		resolveCardTexts(card({ translations: [{ en: "Alpha", en_lore: "Effect." }], mdpro4En, mdpro4Es }), "es"),
		{
			name: { text: "Alfa MD", source: "mdpro4" },
			desc: { text: "Efecto MD.", source: "mdpro4" },
		},
	);
});

test("resolveCardTexts es: a MDPro4 Spanish text identical to its English one is untranslated", () => {
	const texts = resolveCardTexts(
		card({
			mdpro4En: { name: "Alpha MD", desc: "Effect MD." },
			mdpro4Es: { name: "Alpha MD", desc: "" },
		}),
		"es",
	);
	assert.deepEqual(texts, {
		name: { text: "Alpha MD", source: "en.mdpro4" },
		desc: { text: "Effect MD.", source: "en.mdpro4" },
	});
});

test("resolveCardTexts unescapes &quot; in MDPro4 text", () => {
	const texts = resolveCardTexts(
		card({
			mdpro4En: { name: 'Harpie Lady 1 & 2', desc: "x" },
			mdpro4Es: { name: "Harpie Lady 1 &quot; 2", desc: "y" },
		}),
		"es",
	);
	assert.equal(texts.name.text, 'Harpie Lady 1 " 2');
});

test("resolveCardTexts falls back to the aliased base card's translations, own id first", () => {
	const own = { en: "Alt Name", en_lore: "" };
	const aliased = { en: "Base Name", en_lore: "Base effect.", es: "Nombre base", es_lore: "Efecto base." };
	const texts = resolveCardTexts(
		card({
			translations: [own, aliased],
			bases: [undefined, { es: "Minado" }],
			mdpro4En: { name: "MD", desc: "MD effect." },
		}),
		"en",
	);
	assert.deepEqual(texts, {
		name: { text: "Alt Name", source: "translations" },
		desc: { text: "Base effect.", source: "translations" },
	});
	assert.deepEqual(resolveCardTexts(card({ translations: [undefined, aliased] }), "es").name, {
		text: "Nombre base",
		source: "translations",
	});
});

test("resolveCardTexts en: the requirement leads the desc", () => {
	const { desc } = resolveCardTexts(
		card({ translations: [{ en: "Alpha", en_lore: "Effect.", en_req: "Requirement.", es: "", es_lore: "", es_req: "" }] }),
		"en",
	);
	assert.deepEqual(desc, {
		text: "[REQUIREMENT]\nRequirement.\n\n[EFFECT]\nEffect.",
		source: "translations",
	});
});

test("resolveCardTexts es: the desc takes both blocks from one language", () => {
	const both = resolveCardTexts(
		card({
			translations: [
				{ en: "Alpha", en_lore: "Effect.", en_req: "Requirement.", es: "Alfa", es_lore: "Efecto.", es_req: "Requisito." },
			],
		}),
		"es",
	);
	assert.deepEqual(both.desc, {
		text: "[REQUISITO]\nRequisito.\n\n[EFECTO]\nEfecto.",
		source: "translations",
	});

	// No Spanish effect: the desc falls back to English whole, requirement
	// included — a Spanish half glued to an English half is not a card text.
	const fallback = resolveCardTexts(
		card({
			translations: [
				{ en: "Alpha", en_lore: "Effect.", en_req: "Requirement.", es: "Alfa", es_lore: "", es_req: "Requisito." },
			],
		}),
		"es",
	);
	assert.deepEqual(fallback.desc, {
		text: "[REQUIREMENT]\nRequirement.\n\n[EFFECT]\nEffect.",
		source: "en.translations",
	});
});

// --- MDPro4 text hygiene ---

test("cleanMdpro4Text unescapes &quot; and drops the tab before each line end", () => {
	assert.equal(cleanMdpro4Text('Maximum ATK 3500\t\n"A" &quot;B&quot;'), 'Maximum ATK 3500\n"A" "B"');
	assert.equal(cleanMdpro4Text(""), "");
	assert.equal(cleanMdpro4Text(null), "");
});

test("hasMachineTranslationTelltale matches the known telltales case-insensitively", () => {
	for (const text of [
		"Invoca de Modo Especial 1 monstruo.",
		"no puedes seleccionar",
		"Puedes tomar el daño",
		"Destruye todos monstruos",
		"Lanza una moneda. Tails: destruye",
		"CABEZAS: roba 1 carta",
		"Harpie Lady 1 &quot; 2",
	]) {
		assert.equal(hasMachineTranslationTelltale(text), true, text);
	}
	assert.equal(hasMachineTranslationTelltale("Invoca de Forma Especial 1 monstruo."), false);
	assert.equal(hasMachineTranslationTelltale(""), false);
	assert.equal(hasMachineTranslationTelltale(undefined), false);
});

// --- withMaximumLine: the Maximum ATK line appears exactly once ---

test("withMaximumLine prepends the line only when the desc does not lead with one", () => {
	assert.equal(withMaximumLine("Effect.", 3500), "Maximum ATK 3500\nEffect.");
	assert.equal(withMaximumLine("Maximum ATK 3500\nEfecto.", 3500), "Maximum ATK 3500\nEfecto.");
	assert.equal(withMaximumLine("\nMaximum ATK 3500\nEfecto.", 3500), "\nMaximum ATK 3500\nEfecto.");
	assert.equal(withMaximumLine("Effect.", null), "Effect.");
	assert.equal(withMaximumLine("Effect.", undefined), "Effect.");
});

// --- selectAliasRows: which MDPro4 alternate arts join the union ---

test("selectAliasRows admits alternate arts of union cards, never of anime customs", () => {
	const union = new Set([1001, 2001]);
	const rows = [
		{ id: 1001, ot: 1, alias: 0 },
		{ id: 128000001, ot: 4, alias: 0 },
		{ id: 1500, ot: 4, alias: 0 },
		{ id: 129000003, ot: 4, alias: 2001 },
		{ id: 129000001, ot: 4, alias: 1001 },
		// The alias of an anime custom, whatever range the custom sits in.
		{ id: 129000002, ot: 4, alias: 128000001 },
		{ id: 129000005, ot: 4, alias: 1500 },
		// Its base card is not in the union.
		{ id: 129000004, ot: 4, alias: 5555 },
		// No alias at all.
		{ id: 129000006, ot: 4, alias: 0 },
		// Below the alternate-art range.
		{ id: 120000009, ot: 4, alias: 1001 },
	];
	assert.deepEqual(selectAliasRows(rows, union), [
		{ id: 129000001, alias: 1001 },
		{ id: 129000003, alias: 2001 },
	]);
	// A custom that somehow sits in the union by id range is still excluded.
	assert.deepEqual(selectAliasRows(rows, new Set([128000001])), []);
});

function fixture(dir) {
	const srcDir = join(dir, "src");
	mkdirSync(srcDir);
	const sources = [join(srcDir, "A.cdb"), join(srcDir, "B.cdb"), join(srcDir, "C.cdb")];
	makeCdb(sources[0], [
		{ id: 1001, name: "中文一", desc: "中说明一", str1: "S1" },
		{ id: 1003, name: "中文三", desc: "中说明三" },
	]);
	makeCdb(sources[1], [{ id: 1002, ot: 2, name: "中文二", desc: "中说明二" }]);
	makeCdb(sources[2], [{ id: 1004, name: "中文四", desc: "中说明四" }]);

	const translations = {
		1001: { en: "Alpha", en_lore: "Alpha lore", es: "Alfa", es_lore: "" },
		1002: { en: "Beta", en_lore: "", es: "", es_lore: "" },
		// 1003 intentionally absent — must keep Chinese everywhere.
		1004: { en: "D'Artagnan", en_lore: "It's fine", es: "", es_lore: "" },
		9999: { en: "NotOurs", en_lore: "x", es: "y", es_lore: "z" },
	};
	return { sources, translations };
}

test("buildRushCdbs merges disjoint sources and writes only the three gz files", () => {
	const dir = mkdtempSync(join(tmpdir(), "rush-cdb-"));
	try {
		const { sources, translations } = fixture(dir);
		const outDir = join(dir, "out");
		const workDir = join(dir, "work");
		mkdirSync(outDir);
		mkdirSync(workDir);

		const before = sources.map((s) => sha256(readFileSync(s)));
		const stats = buildRushCdbs({ sources, translations, outDir, workDir });

		assert.deepEqual(readdirSync(outDir).sort(), ["rush.cdb.gz", "rush.en.cdb.gz", "rush.es.cdb.gz"]);
		assert.deepEqual(
			stats.merged.perSource.map(({ rows }) => rows),
			[2, 1, 1],
		);
		assert.equal(stats.merged.total, 4);

		// Sources are consumed read-only.
		assert.deepEqual(
			sources.map((s) => sha256(readFileSync(s))),
			before,
		);
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("buildRushCdbs variants apply translations with per-field fallback, zh otherwise", () => {
	const dir = mkdtempSync(join(tmpdir(), "rush-var-"));
	try {
		const { sources, translations } = fixture(dir);
		const outDir = join(dir, "out");
		const workDir = join(dir, "work");
		mkdirSync(outDir);
		mkdirSync(workDir);

		const stats = buildRushCdbs({ sources, translations, outDir, workDir });
		const texts = (gz) => queryGz(dir, join(outDir, gz), "SELECT id, name, \"desc\", str1 FROM texts ORDER BY id;");

		assert.equal(
			texts("rush.cdb.gz"),
			["1001\t中文一\t中说明一\tS1", "1002\t中文二\t中说明二\t", "1003\t中文三\t中说明三\t", "1004\t中文四\t中说明四\t"].join("\n"),
		);
		assert.equal(
			texts("rush.en.cdb.gz"),
			["1001\tAlpha\tAlpha lore\tS1", "1002\tBeta\t中说明二\t", "1003\t中文三\t中说明三\t", "1004\tD'Artagnan\tIt's fine\t"].join("\n"),
		);
		assert.equal(
			texts("rush.es.cdb.gz"),
			["1001\tAlfa\tAlpha lore\tS1", "1002\tBeta\t中说明二\t", "1003\t中文三\t中说明三\t", "1004\tD'Artagnan\tIt's fine\t"].join("\n"),
		);

		// datas identical across the three variants.
		const datas = (gz) => queryGz(dir, join(outDir, gz), "SELECT * FROM datas ORDER BY id;");
		assert.equal(datas("rush.en.cdb.gz"), datas("rush.cdb.gz"));
		assert.equal(datas("rush.es.cdb.gz"), datas("rush.cdb.gz"));

		// 9999 is not shipped, so it never counts nor appears.
		assert.deepEqual(stats.variants.en, {
			name: { translations: 3, mdpro4: 0, zh: 1 },
			desc: { translations: 2, mdpro4: 0, zh: 2 },
		});
		assert.deepEqual(stats.variants.es, {
			name: { translations: 1, base: 0, mdpro4: 0, "en.translations": 2, "en.mdpro4": 0, zh: 1 },
			desc: { translations: 0, base: 0, mdpro4: 0, "en.translations": 2, "en.mdpro4": 0, zh: 2 },
			telltales: { count: 0, sample: [] },
		});
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

// Per source, how many names and descs a variant took, zh included, so the
// counts always add up to the cards shipped.
test("buildVariantUpdates counts every card against the source its text came from", () => {
	const cards = [
		{ id: 1001, ...card({ translations: [{ en: "Alpha", en_lore: "Effect.", es: "", es_lore: "" }] }) },
		{ id: 1002, ...card({ mdpro4En: { name: "Beta", desc: "Effect." }, mdpro4Es: { name: "Beta", desc: "Efecto Invoca de Modo." } }) },
		{ id: 1003, ...card() },
	];

	const en = buildVariantUpdates(cards, "en");
	assert.deepEqual(en.stats, {
		name: { translations: 1, mdpro4: 1, zh: 1 },
		desc: { translations: 1, mdpro4: 1, zh: 1 },
	});
	assert.deepEqual(en.telltales, []);

	const es = buildVariantUpdates(cards, "es");
	assert.deepEqual(es.stats, {
		name: { translations: 0, base: 0, mdpro4: 0, "en.translations": 1, "en.mdpro4": 1, zh: 1 },
		desc: { translations: 0, base: 0, mdpro4: 1, "en.translations": 1, "en.mdpro4": 0, zh: 1 },
	});
	// Only MDPro4 Spanish actually used is screened.
	assert.deepEqual(es.telltales, [1002]);
	assert.equal(es.sql.includes("WHERE id=1003"), false);
});

test("buildVariantUpdates prepends the Maximum ATK line once, whatever the desc source", () => {
	const cards = [
		{ id: 1, maximumAtk: 3500, ...card({ translations: [{ en: "A", en_lore: "Effect." }] }) },
		{ id: 2, maximumAtk: 3000, ...card({ mdpro4En: { name: "B", desc: "Maximum ATK 3000\t\nEffect." } }) },
		{ id: 3, maximumAtk: 4000, ...card() },
	];
	const { sql } = buildVariantUpdates(cards, "en");
	assert.equal(
		sql,
		[
			`UPDATE texts SET name='A',"desc"='Maximum ATK 3500\nEffect.' WHERE id=1;`,
			`UPDATE texts SET name='B',"desc"='Maximum ATK 3000\nEffect.' WHERE id=2;`,
			// No text resolved: the line goes on top of the Chinese desc.
			`UPDATE texts SET "desc"='Maximum ATK 4000' || char(10) || "desc" WHERE id=3;`,
		].join("\n"),
	);
});

test("buildRushCdbs fails loudly on a duplicated id and writes nothing", () => {
	const dir = mkdtempSync(join(tmpdir(), "rush-dup-"));
	try {
		const srcDir = join(dir, "src");
		mkdirSync(srcDir);
		const a = join(srcDir, "A.cdb");
		const b = join(srcDir, "B.cdb");
		makeCdb(a, [{ id: 1001, name: "One" }]);
		makeCdb(b, [{ id: 1001, name: "AlsoOne" }]);

		const outDir = join(dir, "out");
		const workDir = join(dir, "work");
		mkdirSync(outDir);
		mkdirSync(workDir);

		assert.throws(
			() => buildRushCdbs({ sources: [a, b], translations: {}, outDir, workDir }),
			/duplicate/,
		);
		assert.deepEqual(readdirSync(outDir), []);
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("buildRushCdbs is deterministic: two runs produce byte-identical gz files", () => {
	const dir = mkdtempSync(join(tmpdir(), "rush-det-"));
	try {
		const { sources, translations } = fixture(dir);
		const outs = ["out1", "out2"].map((d) => {
			const outDir = join(dir, d);
			const workDir = join(dir, `work-${d}`);
			mkdirSync(outDir);
			mkdirSync(workDir);
			buildRushCdbs({ sources, translations, outDir, workDir });
			return outDir;
		});

		for (const gz of ["rush.cdb.gz", "rush.en.cdb.gz", "rush.es.cdb.gz"]) {
			assert.equal(sha256(readFileSync(join(outs[0], gz))), sha256(readFileSync(join(outs[1], gz))));
		}

		// gzip -n semantics: no mtime in the member header (bytes 4..8 are zero).
		const head = readFileSync(join(outs[0], "rush.cdb.gz")).subarray(4, 8);
		assert.deepEqual([...head], [0, 0, 0, 0]);

		// The gz really decompresses back to a queryable cdb.
		const raw = gunzipSync(readFileSync(join(outs[0], "rush.cdb.gz")));
		assert.equal(raw.subarray(0, 15).toString(), "SQLite format 3");
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

// --- buildCdbFragment: the run-report fragment for this step ---

test("carries the merge and variant stats with the changed verdict", () => {
	const stats = {
		merged: { perSource: [{ name: "RD Standard.cdb", rows: 2 }], aliasRows: 1, total: 3 },
		variants: {
			en: { name: { en: 1 }, desc: { en: 0 } },
			es: { name: { es: 0, en: 1 }, desc: { es: 0, en: 0 } },
		},
		maximumAtk: { withValue: 1, sidePieces: 0, centreWithoutValue: [] },
		effectStrings: { total: 4, en: { replaced: 2, nonChinese: 2 }, es: { replaced: 0, nonChinese: 0 } },
	};

	assert.deepEqual(buildCdbFragment(stats, true), {
		step: "build-cdb",
		status: "changed",
		merged: stats.merged,
		variants: stats.variants,
		maximumAtk: stats.maximumAtk,
		effectStrings: stats.effectStrings,
	});
	assert.equal(buildCdbFragment(stats, false).status, "unchanged");
});

// --- Maximum ATK: the line MDPro3 needs to draw the Maximum ATK box ---

test("parseMaximumAtk reads the value out of a CRLF Chinese desc", () => {
	const desc = "RD/MAX1-JP002\r\n极大攻击 3500\r\n可以和「…」集齐作极大召唤。\r\n";
	assert.equal(parseMaximumAtk(desc), 3500);
});

test("parseMaximumAtk accepts LF and a fullwidth space, and ignores later digits", () => {
	assert.equal(parseMaximumAtk("RD/MAX1-JP001\n极大攻击　3000\n攻击力 1900 的怪兽。"), 3000);
});

test("parseMaximumAtk is null when no line declares one", () => {
	assert.equal(parseMaximumAtk("RD/SD0P-JP001\r\n攻击力 3500 以上的怪兽。\r\n"), null);
	assert.equal(parseMaximumAtk(""), null);
	assert.equal(parseMaximumAtk(null), null);
});

test("parseMaximumAtk ignores a 极大攻击 mention that is not its own line", () => {
	assert.equal(parseMaximumAtk("RD/X\r\n这张卡的极大攻击 3500 不会变化。\r\n"), null);
});

test("isMaximumSidePiece keys on the FULLWIDTH brackets upstream uses", () => {
	assert.equal(isMaximumSidePiece("超魔机神 大螺旋道王［L］"), true);
	assert.equal(isMaximumSidePiece("超魔机神 大螺旋道王［R］"), true);
	assert.equal(isMaximumSidePiece("超魔机神 大螺旋道王"), false);
	// Halfwidth brackets are a different string and never appear in the source.
	assert.equal(isMaximumSidePiece("超魔机神 大螺旋道王[L]"), false);
});

test("classifyMaximumRows splits side pieces, valued centres and valueless centres", () => {
	const result = classifyMaximumRows([
		{ id: 3, name: "中央二", desc: "RD/B\r\n极大攻击 4000\r\n" },
		{ id: 1, name: "中央一", desc: "RD/A\r\n极大攻击 3500\r\n" },
		{ id: 2, name: "中央一［L］", desc: "RD/A\r\n效果。\r\n" },
		{ id: 4, name: "自称侧翼", desc: "RD/C\r\n这张卡在手卡时名字当作「…［L］」。\r\n" },
	]);

	assert.deepEqual(result, {
		withValue: [
			{ id: 1, atk: 3500 },
			{ id: 3, atk: 4000 },
		],
		sidePieces: [2],
		centreWithoutValue: [4],
	});
});

// Maximum cards, mixed: a valued centre, its [L] half, and a centre with no
// declared value. Kept apart from `fixture` so the translation assertions above
// stay about translation.
function maximumFixture(dir) {
	const srcDir = join(dir, "max-src");
	mkdirSync(srcDir);
	const source = join(srcDir, "M.cdb");
	makeCdb(source, [
		{ id: 2001, type: 0x8000 | 1, name: "极大一", desc: "RD/A-JP001\r\n极大攻击 3500\r\n中说明一\r\n" },
		{ id: 2002, type: 0x8000 | 1, name: "极大一［L］", desc: "RD/A-JP002\r\n中说明二\r\n" },
		{ id: 2003, type: 0x8000 | 1, name: "极大二", desc: "RD/A-JP003\r\n中说明三\r\n" },
		{ id: 2004, type: 1, name: "普通", desc: "RD/A-JP004\r\n中说明四\r\n" },
	]);

	const translations = {
		2001: { en: "Maximum One", en_lore: "English lore one.", es: "", es_lore: "Texto uno." },
		2003: { en: "Maximum Two", en_lore: "English lore three.", es: "", es_lore: "" },
	};
	return { sources: [source], translations };
}

test("buildRushCdbs prepends Maximum ATK to en/es and leaves the base untouched", () => {
	const dir = mkdtempSync(join(tmpdir(), "rush-max-"));
	try {
		const { sources, translations } = maximumFixture(dir);
		const outDir = join(dir, "out");
		const workDir = join(dir, "work");
		mkdirSync(outDir);
		mkdirSync(workDir);

		const stats = buildRushCdbs({ sources, translations, outDir, workDir });
		const desc = (gz, id) => queryGz(dir, join(outDir, gz), `SELECT "desc" FROM texts WHERE id=${id};`);

		// The valued centre piece leads with the line MDPro3 parses, and the body
		// follows on the next line — no print code, which only zh-CN/zh-TW strip.
		assert.equal(desc("rush.en.cdb.gz", 2001), "Maximum ATK 3500\nEnglish lore one.");
		assert.equal(desc("rush.es.cdb.gz", 2001), "Maximum ATK 3500\nTexto uno.");

		// The base variant keeps its own 极大攻击 line and gains nothing.
		assert.equal(desc("rush.cdb.gz", 2001), "RD/A-JP001\r\n极大攻击 3500\r\n中说明一\r\n");

		// A side piece and a centre piece with no declared value are both left alone.
		assert.equal(desc("rush.en.cdb.gz", 2002), "RD/A-JP002\r\n中说明二\r\n");
		assert.equal(desc("rush.en.cdb.gz", 2003), "English lore three.");
		// A non-Maximum card is never touched either.
		assert.equal(desc("rush.en.cdb.gz", 2004), "RD/A-JP004\r\n中说明四\r\n");

		assert.deepEqual(stats.maximumAtk, {
			withValue: 1,
			sidePieces: 1,
			centreWithoutValue: [2003],
		});
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

// The Maximum ATK line and the requirement block meet on the same card: the
// line MDPro3 parses has to stay first, since it only ever reads line 1.
test("buildRushCdbs keeps Maximum ATK first on a card that also has a requirement", () => {
	const dir = mkdtempSync(join(tmpdir(), "rush-max-req-"));
	try {
		const srcDir = join(dir, "src");
		mkdirSync(srcDir);
		const source = join(srcDir, "M.cdb");
		makeCdb(source, [
			{ id: 2101, type: 0x8000 | 1, name: "极大", desc: "RD/A-JP101\r\n极大攻击 3500\r\n中说明\r\n" },
		]);
		const translations = {
			2101: {
				en: "Maximum One",
				en_lore: "Effect.",
				en_req: "Requirement.",
				es: "Máximo Uno",
				es_lore: "Efecto.",
				es_req: "Requisito.",
			},
		};
		const outDir = join(dir, "out");
		const workDir = join(dir, "work");
		mkdirSync(outDir);
		mkdirSync(workDir);

		buildRushCdbs({ sources: [source], translations, outDir, workDir });
		const desc = (gz) => queryGz(dir, join(outDir, gz), 'SELECT "desc" FROM texts WHERE id=2101;');

		assert.equal(
			desc("rush.en.cdb.gz"),
			"Maximum ATK 3500\n[REQUIREMENT]\nRequirement.\n\n[EFFECT]\nEffect.",
		);
		assert.equal(
			desc("rush.es.cdb.gz"),
			"Maximum ATK 3500\n[REQUISITO]\nRequisito.\n\n[EFECTO]\nEfecto.",
		);
		assert.equal(desc("rush.en.cdb.gz").split("\n")[0], "Maximum ATK 3500");
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

// --- Effect strings: the duel-time UI prompts in texts.str1..str16 ---

test("termsForLanguage keeps only the terms that language actually has", () => {
	const dictionary = {
		特殊召唤: { en: "Special Summon", es: "Invocación Especial" },
		破坏: { en: "Destroy" },
	};

	assert.deepEqual(termsForLanguage(dictionary, "en"), {
		特殊召唤: "Special Summon",
		破坏: "Destroy",
	});
	assert.deepEqual(termsForLanguage(dictionary, "es"), { 特殊召唤: "Invocación Especial" });
	assert.deepEqual(termsForLanguage({}, "en"), {});
});

test("buildEffectStringUpdates replaces only exact dictionary hits, one statement per row", () => {
	const terms = { 特殊召唤: "Special Summon", 破坏: "Destroy" };
	const { sql, replaced } = buildEffectStringUpdates(
		[
			// str2 is not in the dictionary; str3 only contains a term, it is not one.
			{ id: 1, str1: "特殊召唤", str2: "未知的提示", str3: "把这张卡特殊召唤" },
			{ id: 2, str1: "破坏", str16: "特殊召唤" },
			{ id: 3, str1: "未知的提示" },
		],
		terms,
	);

	assert.equal(
		sql,
		[
			"UPDATE texts SET str1='Special Summon' WHERE id=1;",
			"UPDATE texts SET str1='Destroy',str16='Special Summon' WHERE id=2;",
		].join("\n"),
	);
	assert.equal(replaced, 3);
});

test("buildEffectStringUpdates handles all 16 columns and skips empty ones", () => {
	const terms = Object.fromEntries(
		Array.from({ length: 16 }, (_, i) => [`中${i + 1}`, `Term ${i + 1}`]),
	);
	const row = { id: 1 };
	for (let i = 1; i <= 16; i++) row[`str${i}`] = i === 5 ? "" : `中${i}`;

	const { sql, replaced } = buildEffectStringUpdates([row], terms);

	assert.equal(replaced, 15);
	assert.equal(sql.includes("str5="), false);
	assert.equal(sql.includes("str16='Term 16'"), true);
});

test("buildEffectStringUpdates escapes quotes and yields nothing without a hit", () => {
	assert.equal(
		buildEffectStringUpdates([{ id: 1, str1: "检索" }], { 检索: "Add to it's hand" }).sql,
		"UPDATE texts SET str1='Add to it''s hand' WHERE id=1;",
	);
	assert.deepEqual(buildEffectStringUpdates([{ id: 1, str1: "检索" }], {}), {
		sql: "",
		replaced: 0,
	});
});

test("countStrCoverage counts non-empty str fields and how many end up non-Chinese", () => {
	const rows = [
		{ id: 1, str1: "特殊召唤", str2: "未知的提示", str3: "" },
		{ id: 2, str1: "1000", str2: "破坏" },
	];

	// Nothing translated: only the field that was never Chinese counts.
	assert.deepEqual(countStrCoverage(rows, {}), { total: 4, nonChinese: 1 });
	assert.deepEqual(countStrCoverage(rows, { 特殊召唤: "Special Summon", 破坏: "Destroy" }), {
		total: 4,
		nonChinese: 3,
	});
});

// A merged db whose prompts are partly covered by the dictionary, so the
// variants can be checked for both outcomes: replaced and left Chinese.
function effectStringFixture(dir) {
	const srcDir = join(dir, "eff-src");
	mkdirSync(srcDir);
	const source = join(srcDir, "E.cdb");
	execFileSync("sqlite3", [source], { input: SCHEMA, encoding: "utf8" });
	execFileSync("sqlite3", [
		source,
		"INSERT INTO datas(id,ot,type) VALUES(3001,1,1);" +
			"INSERT INTO texts(id,name,desc,str1,str2,str16) VALUES" +
			"(3001,'中文一','中说明一','特殊召唤','未知的提示','破坏');" +
			"INSERT INTO datas(id,ot,type) VALUES(3002,1,1);" +
			"INSERT INTO texts(id,name,desc,str1) VALUES(3002,'中文二','中说明二','');",
	]);

	const effectStrings = {
		特殊召唤: { en: "Special Summon", es: "Invocación Especial" },
		破坏: { en: "Destroy" },
	};
	return { sources: [source], effectStrings };
}

test("buildRushCdbs translates str columns in en/es and leaves the base variant Chinese", () => {
	const dir = mkdtempSync(join(tmpdir(), "rush-eff-"));
	try {
		const { sources, effectStrings } = effectStringFixture(dir);
		const outDir = join(dir, "out");
		const workDir = join(dir, "work");
		mkdirSync(outDir);
		mkdirSync(workDir);

		const stats = buildRushCdbs({
			sources,
			translations: {},
			effectStrings,
			outDir,
			workDir,
		});
		const strs = (gz) =>
			queryGz(dir, join(outDir, gz), "SELECT str1, str2, str16 FROM texts WHERE id=3001;");

		assert.equal(strs("rush.cdb.gz"), "特殊召唤\t未知的提示\t破坏");
		// An unknown prompt stays Chinese, and es keeps 破坏 for lack of an entry.
		assert.equal(strs("rush.en.cdb.gz"), "Special Summon\t未知的提示\tDestroy");
		assert.equal(strs("rush.es.cdb.gz"), "Invocación Especial\t未知的提示\t破坏");

		// An empty str is never written to, in any variant.
		const empty = (gz) => queryGz(dir, join(outDir, gz), "SELECT str1 FROM texts WHERE id=3002;");
		assert.equal(empty("rush.en.cdb.gz"), "");
		assert.equal(empty("rush.es.cdb.gz"), "");

		assert.deepEqual(stats.effectStrings, {
			total: 3,
			en: { replaced: 2, nonChinese: 2 },
			es: { replaced: 1, nonChinese: 1 },
		});
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("mergeEffectStrings lets a mined term overrule the hand-written one", () => {
	// The mined wording comes from mycard's own translators, so a Rush card reads
	// the way its OCG counterpart already does.
	const merged = mergeEffectStrings(
		{ 破坏: { en: "Destroy" } },
		{ 破坏: { en: "Destroy it" }, 盲堆: { en: "Mill" } },
	);

	assert.deepEqual(merged, {
		破坏: { en: "Destroy" },
		盲堆: { en: "Mill" },
	});
});

test("mergeEffectStrings keeps a hand-written language the mined entry lacks", () => {
	const merged = mergeEffectStrings({ 破坏: { en: "Destroy" } }, { 破坏: { es: "Destruir" } });

	assert.deepEqual(merged, { 破坏: { en: "Destroy", es: "Destruir" } });
});

// --- MDPro4: alias rows and the extra text tiers, end to end ---

// A union with a plain card and a Maximum centre piece, and MDPro4 copies
// holding the same two cards plus an anime custom and four alternate arts:
// two of union cards, one of the custom, one of a card the union lacks.
function mdpro4Fixture(dir) {
	const srcDir = join(dir, "md-src");
	mkdirSync(srcDir);
	const source = join(srcDir, "U.cdb");
	makeCdb(source, [
		{ id: 1001, name: "中文一", desc: "中说明一" },
		{ id: 2001, type: 0x8000 | 1, name: "极大一", desc: "RD/A-JP001\r\n极大攻击 3500\r\n中说明\r\n" },
	]);
	const en = join(srcDir, "md.en.cdb");
	const es = join(srcDir, "md.es.cdb");
	makeCdb(en, [
		{ id: 1001, name: "One MD", desc: "One effect.", str1: "S1" },
		{ id: 2001, type: 0x8000 | 1, name: "Max MD", desc: "Maximum ATK 3500\t\nMax effect." },
		{ id: 128000001, ot: 4, name: "Anime", desc: "Anime effect." },
		{ id: 129000001, ot: 4, alias: 1001, name: "One MD", desc: "One effect.", str1: "Alt S1" },
		{ id: 129000002, ot: 4, alias: 128000001, name: "Anime", desc: "Anime effect." },
		{ id: 129000003, ot: 4, alias: 2001, type: 0x8000 | 1, name: "Max MD", desc: "Maximum ATK 3500\t\nMax effect." },
		{ id: 129000004, ot: 4, alias: 5555, name: "Stray", desc: "Stray effect." },
	]);
	makeCdb(es, [
		// Identical to the English row: untranslated.
		{ id: 1001, name: "One MD", desc: "One effect." },
		{ id: 2001, type: 0x8000 | 1, name: "Max ES", desc: "Maximum ATK 3500\t\nInvoca de Modo Especial." },
		{ id: 128000001, ot: 4, name: "Anime ES", desc: "Efecto anime." },
		{ id: 129000001, ot: 4, alias: 1001, name: "One MD", desc: "One effect." },
		{ id: 129000002, ot: 4, alias: 128000001, name: "Anime ES", desc: "Efecto anime." },
		{ id: 129000003, ot: 4, alias: 2001, type: 0x8000 | 1, name: "Max ES", desc: "Maximum ATK 3500\t\nInvoca de Modo Especial." },
		{ id: 129000004, ot: 4, alias: 5555, name: "Stray ES", desc: "Efecto." },
	]);
	const translations = {
		1001: { en: "One", en_lore: "One lore.", es: "", es_lore: "" },
		2001: { en: "Max One", en_lore: "Max lore.", es: "", es_lore: "" },
	};
	const translationsBase = { 1001: { es: "Uno" } };
	return { sources: [source], translations, translationsBase, mdpro4: { en, es } };
}

test("buildRushCdbs appends the admitted MDPro4 alternate arts and resolves their texts", () => {
	const dir = mkdtempSync(join(tmpdir(), "rush-md-"));
	try {
		const inputs = mdpro4Fixture(dir);
		const outDir = join(dir, "out");
		const workDir = join(dir, "work");
		mkdirSync(outDir);
		mkdirSync(workDir);

		const stats = buildRushCdbs({ ...inputs, outDir, workDir });
		const q = (gz, sql) => queryGz(dir, join(outDir, gz), sql);
		const texts = (gz) => q(gz, 'SELECT id, name, "desc", str1 FROM texts ORDER BY id;');

		// datas copied verbatim, alias included, identical across variants.
		const datas = q("rush.cdb.gz", "SELECT id, ot, alias FROM datas ORDER BY id;");
		assert.equal(datas, ["1001\t1\t0", "2001\t1\t0", "129000001\t4\t1001", "129000003\t4\t2001"].join("\n"));
		const allDatas = (gz) => q(gz, "SELECT * FROM datas ORDER BY id;");
		assert.equal(allDatas("rush.en.cdb.gz"), allDatas("rush.cdb.gz"));
		assert.equal(allDatas("rush.es.cdb.gz"), allDatas("rush.cdb.gz"));

		// The plain variant has no Chinese for the alternate arts: MDPro4 English.
		assert.equal(
			texts("rush.cdb.gz"),
			[
				"1001\t中文一\t中说明一\t",
				"2001\t极大一\tRD/A-JP001\r\n极大攻击 3500\r\n中说明\r\n\t",
				"129000001\tOne MD\tOne effect.\tAlt S1",
				"129000003\tMax MD\tMaximum ATK 3500\nMax effect.\t",
			].join("\n"),
		);
		// An alternate art reads its base card's translation.
		assert.equal(
			texts("rush.en.cdb.gz"),
			[
				"1001\tOne\tOne lore.\t",
				"2001\tMax One\tMaximum ATK 3500\nMax lore.\t",
				"129000001\tOne\tOne lore.\tAlt S1",
				"129000003\tMax One\tMaximum ATK 3500\nMax lore.\t",
			].join("\n"),
		);
		assert.equal(
			texts("rush.es.cdb.gz"),
			[
				"1001\tUno\tOne lore.\t",
				"2001\tMax ES\tMaximum ATK 3500\nInvoca de Modo Especial.\t",
				"129000001\tUno\tOne lore.\tAlt S1",
				"129000003\tMax ES\tMaximum ATK 3500\nInvoca de Modo Especial.\t",
			].join("\n"),
		);

		assert.equal(stats.merged.total, 4);
		assert.deepEqual(stats.merged.aliasRows, 2);
		assert.deepEqual(stats.variants.es.telltales, { count: 2, sample: [2001, 129000003] });
		assert.deepEqual(stats.variants.es.desc, {
			translations: 0,
			base: 0,
			mdpro4: 2,
			"en.translations": 2,
			"en.mdpro4": 0,
			zh: 0,
		});
		assert.deepEqual(stats.maximumAtk, { withValue: 1, sidePieces: 0, centreWithoutValue: [] });
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("buildRushCdbs aborts when a MDPro4 alternate art id is already in the union", () => {
	const dir = mkdtempSync(join(tmpdir(), "rush-md-dup-"));
	try {
		const inputs = mdpro4Fixture(dir);
		const clash = join(dir, "md-src", "Clash.cdb");
		makeCdb(clash, [{ id: 129000001, name: "冲突" }]);
		const outDir = join(dir, "out");
		const workDir = join(dir, "work");
		mkdirSync(outDir);
		mkdirSync(workDir);

		assert.throws(
			() => buildRushCdbs({ ...inputs, sources: [...inputs.sources, clash], outDir, workDir }),
			/duplicate.*129000001/,
		);
		assert.deepEqual(readdirSync(outDir), []);
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

// --- The alternate-art cdb the duel server loads ---

const ALTERNATE_CDB = "RD MDPro4 Alternate.cdb";

test("buildRushCdbs writes the admitted alternate arts as a raw cdb in the per-origin schema", () => {
	const dir = mkdtempSync(join(tmpdir(), "rush-alt-"));
	try {
		const inputs = mdpro4Fixture(dir);
		const outDir = join(dir, "out");
		const workDir = join(dir, "work");
		mkdirSync(outDir);
		mkdirSync(workDir);

		const stats = buildRushCdbs({ ...inputs, outDir, workDir });
		const alt = join(workDir, ALTERNATE_CDB);
		const q = (sql) =>
			execFileSync("sqlite3", ["-separator", "\t", alt, sql], { encoding: "utf8" }).replace(/\n$/, "");

		assert.equal(stats.alternate.path, alt);
		assert.equal(stats.alternate.rows, 2);
		assert.equal(q("SELECT id, ot, alias FROM datas ORDER BY id;"), "129000001\t4\t1001\n129000003\t4\t2001");
		assert.equal(
			q('SELECT id, name, "desc", str1 FROM texts ORDER BY id;'),
			"129000001\tOne MD\tOne effect.\tAlt S1\n129000003\tMax MD\tMaximum ATK 3500\nMax effect.\t",
		);
		const schemaOf = (path) =>
			execFileSync("sqlite3", [path, ".schema"], { encoding: "utf8" });
		assert.equal(schemaOf(alt), schemaOf(inputs.sources[0]));
		// An output of the build, never one of its inputs: nothing in outDir.
		assert.deepEqual(readdirSync(outDir).sort(), ["rush.cdb.gz", "rush.en.cdb.gz", "rush.es.cdb.gz"]);
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("buildRushCdbs writes no alternate cdb without MDPro4 rows, and the same bytes twice", () => {
	const dir = mkdtempSync(join(tmpdir(), "rush-alt-det-"));
	try {
		const inputs = mdpro4Fixture(dir);
		const run = (name, withMdpro4) => {
			const outDir = join(dir, `out-${name}`);
			const workDir = join(dir, `work-${name}`);
			mkdirSync(outDir);
			mkdirSync(workDir);
			buildRushCdbs({ ...inputs, mdpro4: withMdpro4 ? inputs.mdpro4 : null, outDir, workDir });
			return join(workDir, ALTERNATE_CDB);
		};
		assert.equal(existsSync(run("none", false)), false);
		assert.equal(sha256(readFileSync(run("a", true))), sha256(readFileSync(run("b", true))));
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("installIfChanged replaces the target only when the bytes differ", () => {
	const dir = mkdtempSync(join(tmpdir(), "rush-install-"));
	try {
		const built = join(dir, "built.cdb");
		const target = join(dir, "target.cdb");
		writeFileSync(built, "one");

		assert.equal(installIfChanged(built, target), "changed");
		assert.equal(readFileSync(target, "utf8"), "one");

		assert.equal(installIfChanged(built, target), "unchanged");

		writeFileSync(built, "two");
		assert.equal(installIfChanged(built, target), "changed");
		assert.equal(readFileSync(target, "utf8"), "two");
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("the fragment reports the alternate cdb and counts it in the changed verdict", () => {
	const stats = {
		merged: { perSource: [], aliasRows: 1, total: 1 },
		variants: {},
		maximumAtk: { withValue: 0, sidePieces: 0, centreWithoutValue: [] },
		effectStrings: { total: 0, en: { replaced: 0, nonChinese: 0 }, es: { replaced: 0, nonChinese: 0 } },
		alternate: { rows: 1, status: "unchanged" },
	};
	assert.deepEqual(buildCdbFragment(stats, false).alternate, { rows: 1, status: "unchanged" });
	assert.equal(buildCdbFragment(stats, false).status, "unchanged");
	assert.equal(
		buildCdbFragment({ ...stats, alternate: { rows: 1, status: "changed" } }, false).status,
		"changed",
	);
});

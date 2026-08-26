import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { mkdirSync, mkdtempSync, readdirSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { gunzipSync } from "node:zlib";

import {
	buildCdbFragment,
	buildMaximumAtkUpdates,
	buildRushCdbs,
	classifyMaximumRows,
	findDuplicateIds,
	isMaximumSidePiece,
	parseMaximumAtk,
	resolveVariantTexts,
} from "./build-rush-cdb.mjs";

const SCHEMA =
	"CREATE TABLE datas(id integer primary key,ot integer,alias integer,setcode integer," +
	"type integer,atk integer,def integer,level integer,race integer,attribute integer,category integer);" +
	"CREATE TABLE texts(id integer primary key,name text,desc text,str1 text,str2 text,str3 text," +
	"str4 text,str5 text,str6 text,str7 text,str8 text,str9 text,str10 text,str11 text,str12 text," +
	"str13 text,str14 text,str15 text,str16 text);";

function makeCdb(path, cards) {
	execFileSync("sqlite3", [path], { input: SCHEMA, encoding: "utf8" });
	for (const { id, ot, type, name, desc, str1 } of cards) {
		execFileSync("sqlite3", [
			path,
			`INSERT INTO datas(id,ot,type) VALUES(${id},${ot ?? 1},${type ?? 1});` +
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

test("resolveVariantTexts en: en/en_lore apply only when non-empty", () => {
	const full = resolveVariantTexts({ en: "Alpha", en_lore: "Lore", es: "x", es_lore: "y" }, "en");
	assert.deepEqual(full, {
		name: { text: "Alpha", source: "en" },
		desc: { text: "Lore", source: "en" },
	});

	const empty = resolveVariantTexts({ en: "", en_lore: "", es: "x", es_lore: "y" }, "en");
	assert.deepEqual(empty, { name: null, desc: null });
});

test("resolveVariantTexts es: per-field fallback es → en → null", () => {
	const es = resolveVariantTexts(
		{ en: "Alpha", en_lore: "Lore", es: "Alfa", es_lore: "" },
		"es",
	);
	assert.deepEqual(es, {
		name: { text: "Alfa", source: "es" },
		desc: { text: "Lore", source: "en" },
	});

	const none = resolveVariantTexts({ en: "", en_lore: "", es: "", es_lore: "" }, "es");
	assert.deepEqual(none, { name: null, desc: null });
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
		assert.deepEqual(stats.variants.en, { name: { en: 3 }, desc: { en: 2 } });
		assert.deepEqual(stats.variants.es, { name: { es: 1, en: 2 }, desc: { es: 0, en: 2 } });
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
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
		merged: { perSource: [{ name: "RD Standard.cdb", rows: 2 }], total: 2 },
		variants: {
			en: { name: { en: 1 }, desc: { en: 0 } },
			es: { name: { es: 0, en: 1 }, desc: { es: 0, en: 0 } },
		},
		maximumAtk: { withValue: 1, sidePieces: 0, centreWithoutValue: [] },
	};

	assert.deepEqual(buildCdbFragment(stats, true), {
		step: "build-cdb",
		status: "changed",
		merged: stats.merged,
		variants: stats.variants,
		maximumAtk: stats.maximumAtk,
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

test("buildMaximumAtkUpdates prepends the English line, one statement per id", () => {
	assert.equal(
		buildMaximumAtkUpdates([
			{ id: 1, atk: 3500 },
			{ id: 3, atk: 4000 },
		]),
		[
			`UPDATE texts SET "desc"='Maximum ATK 3500' || char(10) || "desc" WHERE id=1;`,
			`UPDATE texts SET "desc"='Maximum ATK 4000' || char(10) || "desc" WHERE id=3;`,
		].join("\n"),
	);
	assert.equal(buildMaximumAtkUpdates([]), "");
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

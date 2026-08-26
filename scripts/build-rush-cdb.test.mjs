import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { mkdirSync, mkdtempSync, readdirSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { gunzipSync } from "node:zlib";

import { buildRushCdbs, findDuplicateIds, resolveVariantTexts } from "./build-rush-cdb.mjs";

const SCHEMA =
	"CREATE TABLE datas(id integer primary key,ot integer,alias integer,setcode integer," +
	"type integer,atk integer,def integer,level integer,race integer,attribute integer,category integer);" +
	"CREATE TABLE texts(id integer primary key,name text,desc text,str1 text,str2 text,str3 text," +
	"str4 text,str5 text,str6 text,str7 text,str8 text,str9 text,str10 text,str11 text,str12 text," +
	"str13 text,str14 text,str15 text,str16 text);";

function makeCdb(path, cards) {
	execFileSync("sqlite3", [path], { input: SCHEMA, encoding: "utf8" });
	for (const { id, ot, name, desc, str1 } of cards) {
		execFileSync("sqlite3", [
			path,
			`INSERT INTO datas(id,ot) VALUES(${id},${ot ?? 1});` +
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

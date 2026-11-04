#!/usr/bin/env node
/**
 * Apply pre-errata card rows to the bilingual overlay databases.
 *
 * Reads a JSON list of copies ({ code, alias, name_en, name_es, desc_en,
 * desc_es }) and writes one row per copy into cdb/pre-errata.en.cdb and
 * cdb/pre-errata.es.cdb: `datas` is the official card's row with id = code
 * and alias = official code; `texts` carries the era name (with the marker)
 * and the era text, and the official card's str1..str16 in each language.
 * Idempotent: rows are replaced.
 *
 * Usage:
 *   node scripts/apply-pre-errata-rows.mjs --rows cdb/pre-errata-goat.json --marker GOAT \
 *     [--official-en cdb/base.en.cdb] [--official-es cdb/base.es.cdb] \
 *     [--out-en cdb/pre-errata.en.cdb] [--out-es cdb/pre-errata.es.cdb]
 */
import { readFileSync } from "node:fs";
import { DatabaseSync } from "node:sqlite";

const STR_COLUMNS = Array.from({ length: 16 }, (_, i) => `str${i + 1}`);
const DATAS_COLUMNS = ["id", "ot", "alias", "setcode", "type", "atk", "def", "level", "race", "attribute", "category"];

export function parseArgs(argv) {
	const opts = {
		rows: "cdb/pre-errata-goat.json",
		marker: "GOAT",
		officialEn: "cdb/base.en.cdb",
		officialEs: "cdb/base.es.cdb",
		outEn: "cdb/pre-errata.en.cdb",
		outEs: "cdb/pre-errata.es.cdb",
	};
	const keys = { "--rows": "rows", "--marker": "marker", "--official-en": "officialEn", "--official-es": "officialEs", "--out-en": "outEn", "--out-es": "outEs" };
	for (let i = 0; i < argv.length; i += 2) {
		const key = keys[argv[i]];
		if (!key || argv[i + 1] === undefined) throw new Error(`unknown or incomplete option: ${argv[i]}`);
		opts[key] = argv[i + 1];
	}
	return opts;
}

export function applyRows({ rows, marker, officialPath, outPath, lang }) {
	const official = new DatabaseSync(officialPath, { readOnly: true });
	const out = new DatabaseSync(outPath);
	const getDatas = official.prepare(`SELECT ${DATAS_COLUMNS.join(", ")} FROM datas WHERE id = ?`);
	const getTexts = official.prepare(`SELECT ${STR_COLUMNS.join(", ")} FROM texts WHERE id = ?`);
	const putDatas = out.prepare(`INSERT OR REPLACE INTO datas (${DATAS_COLUMNS.join(", ")}) VALUES (${DATAS_COLUMNS.map(() => "?").join(", ")})`);
	const putTexts = out.prepare(`INSERT OR REPLACE INTO texts (id, name, desc, ${STR_COLUMNS.join(", ")}) VALUES (?, ?, ?, ${STR_COLUMNS.map(() => "?").join(", ")})`);
	const applied = [];
	try {
		out.exec("BEGIN");
		for (const row of rows) {
			const datas = getDatas.get(row.alias);
			if (!datas) throw new Error(`official card ${row.alias} (${row.name_en}) not found in ${officialPath}`);
			const texts = getTexts.get(row.alias) ?? {};
			putDatas.run(...DATAS_COLUMNS.map((c) => (c === "id" ? row.code : c === "alias" ? row.alias : datas[c])));
			const name = `${lang === "es" ? row.name_es : row.name_en} (${marker})`;
			const desc = lang === "es" ? row.desc_es : row.desc_en;
			putTexts.run(row.code, name, desc, ...STR_COLUMNS.map((c) => texts[c] ?? ""));
			applied.push({ code: row.code, name });
		}
		out.exec("COMMIT");
	} catch (error) {
		out.exec("ROLLBACK");
		throw error;
	} finally {
		official.close();
		out.close();
	}
	return applied;
}

export function main(argv) {
	const opts = parseArgs(argv);
	const rows = JSON.parse(readFileSync(opts.rows, "utf8"));
	for (const row of rows) {
		for (const key of ["code", "alias", "name_en", "name_es", "desc_en", "desc_es"]) {
			if (row[key] === undefined || row[key] === "") throw new Error(`row ${row.code ?? "?"} is missing ${key}`);
		}
	}
	const en = applyRows({ rows, marker: opts.marker, officialPath: opts.officialEn, outPath: opts.outEn, lang: "en" });
	const es = applyRows({ rows, marker: opts.marker, officialPath: opts.officialEs, outPath: opts.outEs, lang: "es" });
	return { en, es };
}

if (process.argv[1] && import.meta.url === new URL(`file://${process.argv[1]}`).href) {
	const { en, es } = main(process.argv.slice(2));
	console.log(`applied ${en.length} rows (en) and ${es.length} rows (es)`);
	for (const r of en) console.log(`  ${r.code} ${r.name}`);
}

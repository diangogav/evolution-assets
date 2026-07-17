// Merges the per-set pre-release .cdb files (mirrored from mycard via
// evolutionygo/pre-release-database-cdb) into a single prerelease.cdb the client
// can overlay on top of the base card pool.
//
// Only the .cdb card DATA is merged — the lua scripts in that repo are the duel
// engine's concern (server-side) and are not needed by the client deck builder.
// `test-*` cdbs are development fixtures upstream and are excluded.
//
// The merge itself is a straight sqlite3 ATTACH + INSERT OR REPLACE, so a card
// present in two sets keeps the last one seen. Card ids are unique per real set,
// so collisions are effectively only the intended re-imports.

import { execFileSync } from "node:child_process";
import { readdirSync } from "node:fs";

// Pure: pick the real per-set cdbs to merge, in a stable order. Excludes non-cdb
// files and the upstream `test-*` development fixtures.
export function selectSourceCdbs(files) {
	return files
		.filter((name) => name.endsWith(".cdb"))
		.filter((name) => !name.startsWith("test-"))
		.sort();
}

function sqlite(dbPath, sql) {
	execFileSync("sqlite3", [dbPath, sql], { encoding: "utf8" });
}

export function buildPrereleaseCdb(srcDir, outPath) {
	const sources = selectSourceCdbs(readdirSync(srcDir));
	if (sources.length === 0) {
		throw new Error(`no source .cdb files found in ${srcDir}`);
	}

	// Seed the output schema from the first source, then merge every source in.
	const schema = execFileSync("sqlite3", [`${srcDir}/${sources[0]}`, ".schema"], {
		encoding: "utf8",
	});
	execFileSync("sqlite3", [outPath], { input: schema, encoding: "utf8" });

	for (const name of sources) {
		const src = `${srcDir}/${name}`;
		sqlite(
			outPath,
			`ATTACH '${src}' AS src;` +
				"INSERT OR REPLACE INTO datas SELECT * FROM src.datas;" +
				"INSERT OR REPLACE INTO texts SELECT * FROM src.texts;" +
				"DETACH src;",
		);
	}

	// Upstream (mycard) publishes these cards with plain ot=1/2 and no pre-release
	// marker. Stamp the EDOPro SCOPE_PRERELEASE bit (0x100) so clients can filter
	// "pre-release only" by the established ot convention. The OCG/TCG bits are
	// preserved (0x101 is still OCG), and the server never reads this merged file.
	sqlite(outPath, "UPDATE datas SET ot = ot | 256;");

	const count = execFileSync("sqlite3", [outPath, "SELECT count(*) FROM datas;"], {
		encoding: "utf8",
	}).trim();
	return { sources, cards: Number(count) };
}

/**
 * Overwrites the texts of `cdbPath` with the rows from `translationCdbPath`
 * (TransSuperpre per-language bundle) for every card id present in BOTH files.
 *
 * Guarantees:
 *   - datas are never touched — mycard stays the authority for ids/stats.
 *   - cards without a translation keep their zh-CN text (per-card fallback).
 *   - translation rows for cards we don't ship are NOT added.
 *
 * Returns the number of translated rows.
 */
export function applyTranslations(cdbPath, translationCdbPath) {
	const overlap = execFileSync(
		"sqlite3",
		[
			cdbPath,
			`ATTACH '${translationCdbPath}' AS tr; SELECT count(*) FROM texts WHERE id IN (SELECT id FROM tr.texts);`,
		],
		{ encoding: "utf8" },
	).trim();

	sqlite(
		cdbPath,
		`ATTACH '${translationCdbPath}' AS tr;` +
			"INSERT OR REPLACE INTO texts SELECT * FROM tr.texts WHERE id IN (SELECT id FROM texts);" +
			"DETACH tr;",
	);
	return Number(overlap);
}

function main() {
	const [srcDir, outPath] = process.argv.slice(2);
	if (!srcDir || !outPath) {
		console.error("usage: node scripts/build-prerelease-cdb.mjs <srcDir> <outCdb>");
		process.exit(1);
	}
	const { sources, cards } = buildPrereleaseCdb(srcDir, outPath);
	console.log(`Merged ${sources.length} cdbs (${sources.join(", ")}) → ${cards} cards in ${outPath}`);
}

if (process.argv[1]?.endsWith("build-prerelease-cdb.mjs")) {
	main();
}

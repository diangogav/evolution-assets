import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { gzipSync } from "node:zlib";

import {
	PACK_LANGS,
	buildRushPack,
	lflistFileName,
	packLayout,
	renderInstallReadme,
} from "./build-rush-pack.mjs";

const SCHEMA =
	"CREATE TABLE datas(id integer primary key,ot integer,alias integer,setcode integer," +
	"type integer,atk integer,def integer,level integer,race integer,attribute integer,category integer);" +
	"CREATE TABLE texts(id integer primary key,name text,desc text);";

/** A tiny gzipped Rush cdb standing in for cdb/rush.<lang>.cdb.gz. */
function makeSourceGz(dir, gzName, cards) {
	const raw = join(dir, "src.cdb");
	rmSync(raw, { force: true });
	execFileSync("sqlite3", [raw], { input: SCHEMA, encoding: "utf8" });
	for (const { id, name } of cards) {
		execFileSync("sqlite3", [
			raw,
			`INSERT INTO datas(id,ot,type) VALUES(${id},1,1);` +
				`INSERT INTO texts(id,name,desc) VALUES(${id},'${name}','');`,
		]);
	}
	const gzPath = join(dir, gzName);
	writeFileSync(gzPath, gzipSync(readFileSync(raw), { level: 9 }));
	return gzPath;
}

/**
 * The archive's FILE tree, sorted. `unzip -Z1` lists one entry per line and
 * includes the parent directory entries, which zip stores so a GUI extract
 * recreates the folders — they are not part of the manifest.
 */
function archiveFiles(zipPath) {
	return execFileSync("unzip", ["-Z1", zipPath], { encoding: "utf8" })
		.trim()
		.split("\n")
		.filter((entry) => !entry.endsWith("/"))
		.sort();
}

test("PACK_LANGS maps our variant names onto MDPro3's own locale directories", () => {
	// Verified against a real MDPro3 install: Data/locales/ holds en-US, es-ES
	// and zh-CN among others.
	assert.deepEqual(PACK_LANGS, { en: "en-US", es: "es-ES", zh: "zh-CN" });
});

test("packLayout drops the cdb in MDPro3's own per-language Rush slot", () => {
	// CardsManager.TryLoadCardsForLanguage loads Data/locales/<lang>/rush_cards.cdb
	// right after cards.cdb. MDPro3 ships no such file, so the slot is free.
	assert.deepEqual(packLayout("en"), {
		archiveExtension: ".zip",
		locale: "en-US",
		sourceGz: "cdb/rush.en.cdb.gz",
		cdbPath: "Data/locales/en-US/rush_cards.cdb",
		lflistPath: "Expansions/evolution-rush.lflist.conf",
		readmeName: "README.txt",
		archiveName: "evolution-rush-en.zip",
	});
});

test("packLayout ships the untranslated union for zh", () => {
	const layout = packLayout("zh");
	// rush.cdb.gz is upstream's own Chinese text — there is no rush.zh.cdb.gz.
	assert.equal(layout.sourceGz, "cdb/rush.cdb.gz");
	assert.equal(layout.cdbPath, "Data/locales/zh-CN/rush_cards.cdb");
});

test("packLayout refuses a language MDPro3 has no locale directory for", () => {
	assert.throws(() => packLayout("fr"), /fr/);
});

test("lflistFileName ends in lflist.conf and namespaces itself", () => {
	// BanlistManager.Initialize -> ResourceManager.GetTextsByExtensions(["lflist.conf"])
	// -> FileManager matches on EndsWith, so the suffix is the whole contract.
	// The file lands LOOSE in Expansions/, where a bare "lflist.conf" would
	// collide with any other pack that extracts one there.
	assert.ok(lflistFileName().endsWith("lflist.conf"));
	assert.notEqual(lflistFileName(), "lflist.conf");
	assert.match(lflistFileName(), /evolution/);
});

test("renderInstallReadme names both destinations and the card count", () => {
	const readme = renderInstallReadme({ lang: "en", cards: 3463 });
	assert.match(readme, /3463 cards/);
	assert.match(readme, /Data\/locales\/en-US\/rush_cards\.cdb/);
	assert.match(readme, /Expansions\/evolution-rush\.lflist\.conf/);
});

test("renderInstallReadme points at upstream's art pack instead of bundling art", () => {
	// MDPro3 applies its OWN Rush art crop, and upstream already publishes the
	// full 624 MB art .ypk — shipping our own crop would be both wrong and huge.
	const readme = renderInstallReadme({ lang: "en", cards: 3463 });
	assert.match(readme, /ygopro-rush-duel-master\.ypk/);
});

test("renderInstallReadme does not promise MDPro3 downloads the art itself", () => {
	// Its card-pack downloader only carries ygopro-super-pre URLs (Settings.cs
	// PrereleasePackUrl*), and card images are read off disk rather than fetched
	// per card — a player who waits for an automatic download waits forever.
	const readme = renderInstallReadme({ lang: "en", cards: 3463 });
	assert.doesNotMatch(readme, /Download Card Pack/);
	assert.match(readme, /will not fetch it for you/);
});

test("renderInstallReadme warns that the deck editor does not enforce Legend limits", () => {
	// Banlist.GetCredit(cardId) only ever consults CreditLimits.FirstOrDefault().Key,
	// so $legend_spell and $legend_trap are parsed and then never charged.
	const readme = renderInstallReadme({ lang: "en", cards: 3463 });
	assert.match(readme, /Legend/);
	assert.match(readme, /server/i);
});

test("renderInstallReadme flags the bundled local server as a caveat, not a blocker", () => {
	// YGOSharp/BanlistManager.Init int.Parse(data[1]) throws on "$legend_monster".
	// Joining our rooms never touches that parser.
	const readme = renderInstallReadme({ lang: "en", cards: 3463 });
	assert.match(readme, /local/i);
	assert.doesNotMatch(readme, /cannot join|does not work online/i);
});

test("renderInstallReadme is English for every language pack", () => {
	// Same reason as the Edison pack: it goes to players whose community
	// language is not ours.
	for (const lang of Object.keys(PACK_LANGS)) {
		assert.match(renderInstallReadme({ lang, cards: 1 }), /Install/);
	}
});

function packFixture(dir) {
	const gz = makeSourceGz(dir, "rush.en.cdb.gz", [
		{ id: 120150002, name: "Supreme Machine Magnum Overlord" },
		{ id: 120120000, name: "Blue-Eyes White Dragon" },
	]);
	const lflist = join(dir, "lflist.conf");
	writeFileSync(lflist, "#[RD]\n!RD\n$legend_monster 1\n120120000 $legend_monster 1\n");
	return { gz, lflist };
}

test("buildRushPack lays the archive out as an MDPro3 folder overlay", () => {
	const dir = mkdtempSync(join(tmpdir(), "rush-pack-"));
	try {
		const { gz, lflist } = packFixture(dir);
		const outDir = join(dir, "out");
		mkdirSync(outDir);

		const result = buildRushPack("en", outDir, { sourceGz: gz, lflist });

		assert.equal(result.lang, "en");
		assert.equal(result.locale, "en-US");
		assert.equal(result.cards, 2);
		assert.deepEqual(result.entries, [
			"Data/locales/en-US/rush_cards.cdb",
			"Expansions/evolution-rush.lflist.conf",
			"README.txt",
		]);
		assert.deepEqual(archiveFiles(result.zipPath), result.entries);
		assert.ok(result.bytes > 0);
		assert.match(result.sha256, /^[0-9a-f]{64}$/);
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("buildRushPack ships the ban list byte-identical and the cdb queryable", () => {
	const dir = mkdtempSync(join(tmpdir(), "rush-pack-body-"));
	try {
		const { gz, lflist } = packFixture(dir);
		const outDir = join(dir, "out");
		mkdirSync(outDir);

		const { zipPath } = buildRushPack("en", outDir, { sourceGz: gz, lflist });
		const unpacked = join(dir, "unpacked");
		execFileSync("unzip", ["-q", zipPath, "-d", unpacked]);

		assert.deepEqual(
			readFileSync(join(unpacked, "Expansions/evolution-rush.lflist.conf")),
			readFileSync(lflist),
		);

		// The cdb must land DECOMPRESSED: MDPro3 opens it with SqliteConnection.
		const names = execFileSync(
			"sqlite3",
			[join(unpacked, "Data/locales/en-US/rush_cards.cdb"), "SELECT name FROM texts ORDER BY id;"],
			{ encoding: "utf8" },
		).trim();
		assert.equal(names, "Blue-Eyes White Dragon\nSupreme Machine Magnum Overlord");
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("buildRushPack refuses to publish a pack with no cards", () => {
	const dir = mkdtempSync(join(tmpdir(), "rush-pack-empty-"));
	try {
		const gz = makeSourceGz(dir, "rush.en.cdb.gz", []);
		const lflist = join(dir, "lflist.conf");
		writeFileSync(lflist, "!RD\n");
		const outDir = join(dir, "out");
		mkdirSync(outDir);

		assert.throws(() => buildRushPack("en", outDir, { sourceGz: gz, lflist }), /no cards/);
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("buildRushPack works when outDir is a relative path", () => {
	// `zip` runs with cwd set to the staging dir, so a relative output path would
	// resolve against staging instead of the caller's cwd.
	const dir = mkdtempSync(join(tmpdir(), "rush-pack-rel-"));
	const cwd = process.cwd();
	try {
		const { gz, lflist } = packFixture(dir);
		process.chdir(dir);

		const result = buildRushPack("en", "out", { sourceGz: gz, lflist });
		assert.equal(result.cards, 2);
		assert.deepEqual(archiveFiles(result.zipPath), result.entries);
	} finally {
		process.chdir(cwd);
		rmSync(dir, { recursive: true, force: true });
	}
});

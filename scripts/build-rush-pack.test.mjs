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
	packLayout,
	packUrlFor,
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
 * Every entry the archive stores, in the order it stores them. Nothing is
 * filtered: a directory entry appearing here is itself the failure, because
 * the archive is what the client MOUNTS and its root is the mount point.
 */
function archiveEntries(zipPath) {
	return execFileSync("unzip", ["-Z1", zipPath], { encoding: "utf8" }).trim().split("\n");
}

test("PACK_LANGS maps our variant names onto MDPro3's own locale directories", () => {
	// Verified against a real MDPro3 install: Data/locales/ holds en-US, es-ES
	// and zh-CN among others. The mount no longer uses those directories, but
	// they still name the text a pack carries.
	assert.deepEqual(PACK_LANGS, { en: "en-US", es: "es-ES", zh: "zh-CN" });
});

test("packLayout keeps every payload file flat at the archive root", () => {
	// The archive IS the mount point: MDPro3 reads the files it finds inside a
	// mounted .ypk, so a Data/ or Expansions/ prefix would bury them.
	assert.deepEqual(packLayout("en"), {
		archiveExtension: ".ypk",
		locale: "en-US",
		sourceGz: "cdb/rush.en.cdb.gz",
		cdbName: "evolution-rush.cdb",
		lflistName: "evolution-rush.lflist.conf",
		readmeName: "README.txt",
		archiveName: "evolution-rush-en.ypk",
	});
	for (const name of ["cdbName", "lflistName", "readmeName"]) {
		assert.doesNotMatch(packLayout("en")[name], /\//);
	}
});

test("packLayout ships a .ypk, never a .zip", () => {
	// A .zip invites a double-click and an extract, which is the one action that
	// breaks a mounted pack.
	for (const lang of Object.keys(PACK_LANGS)) {
		assert.equal(packLayout(lang).archiveExtension, ".ypk");
		assert.ok(packLayout(lang).archiveName.endsWith(".ypk"));
	}
});

test("packLayout ships the untranslated union for zh", () => {
	const layout = packLayout("zh");
	// rush.cdb.gz is upstream's own Chinese text — there is no rush.zh.cdb.gz.
	assert.equal(layout.sourceGz, "cdb/rush.cdb.gz");
	assert.equal(layout.locale, "zh-CN");
});

test("packLayout refuses a language MDPro3 has no locale directory for", () => {
	assert.throws(() => packLayout("fr"), /fr/);
});

test("packLayout names the ban list so it ends in lflist.conf and namespaces itself", () => {
	// BanlistManager.Initialize -> ResourceManager.GetTextsByExtensions(["lflist.conf"])
	// -> FileManager matches on EndsWith, so the suffix is the whole contract.
	// Entries from every mounted archive land in one merged list, so the prefix
	// says whose list this is.
	const { lflistName } = packLayout("en");
	assert.ok(lflistName.endsWith("lflist.conf"));
	assert.notEqual(lflistName, "lflist.conf");
	assert.match(lflistName, /evolution/);
});

test("packUrlFor addresses the rush-pack release slot per language", () => {
	assert.equal(
		packUrlFor("en"),
		"https://github.com/diangogav/evolution-assets/releases/download/rush-pack/evolution-rush-en.ypk",
	);
	for (const lang of Object.keys(PACK_LANGS)) {
		const url = packUrlFor(lang);
		assert.ok(url.endsWith(`/evolution-rush-${lang}.ypk`));
		// The client validates the extension and names the saved file after the
		// URL, so it must end clean with no query string.
		assert.doesNotMatch(url, /[?#]/);
	}
});

test("renderInstallReadme leads with the download-by-URL install", () => {
	const readme = renderInstallReadme({ lang: "en", cards: 3463, packUrl: packUrlFor("en") });
	assert.match(readme, /3463 cards/);
	assert.match(readme, /Settings/);
	assert.ok(readme.includes(packUrlFor("en")));
	// Extracting the archive is what breaks a mounted pack.
	assert.doesNotMatch(readme, /[Ee]xtract this archive/);
});

test("renderInstallReadme offers the manual drop into Expansions as the fallback", () => {
	const readme = renderInstallReadme({ lang: "en", cards: 3463, packUrl: packUrlFor("en") });
	assert.match(readme, /Expansions/);
	// Note the capital E: ygopro-family clients use a lowercase expansions/,
	// which matters on a case-sensitive filesystem.
	assert.doesNotMatch(readme, /\/expansions\//);
});

test("renderInstallReadme names the ban list entry and where the client files it", () => {
	const readme = renderInstallReadme({ lang: "en", cards: 3463, packUrl: packUrlFor("en") });
	assert.match(readme, /"RD"/);
	assert.match(readme, /Genesys/);
});

test("renderInstallReadme tells the player to install exactly one language pack", () => {
	// A mounted pack is loaded for EVERY client language — the per-language slot
	// the old folder overlay used does not exist inside an archive. Two installed
	// packs mean whichever the client happens to load last wins.
	const readme = renderInstallReadme({ lang: "en", cards: 3463, packUrl: packUrlFor("en") });
	assert.match(readme, /\bONE\b/);
	assert.match(readme, /every language|any language|whatever language/i);
	assert.doesNotMatch(readme, /client language must be/i);
});

test("renderInstallReadme requires deleting the databases inside upstream's art pack", () => {
	// ygopro-rush-duel-master.ypk carries RD Alternate.cdb, RD Patch.cdb and
	// RD Standard.cdb — upstream's UNTRANSLATED Chinese databases. CardsManager
	// reads cdbs out of mounted archives via ZipManager.GetAllFilesByExtensions,
	// which enumerates a dictionary's keys, and LoadCard does
	// targetCards[card.Id] = card. Order is not guaranteed and last write wins.
	const readme = renderInstallReadme({ lang: "en", cards: 3463, packUrl: packUrlFor("en") });
	assert.match(readme, /ygopro-rush-duel-master\.ypk/);
	assert.match(readme, /RD Alternate\.cdb/);
	assert.match(readme, /RD Patch\.cdb/);
	assert.match(readme, /RD Standard\.cdb/);
	assert.match(readme, /delete/i);
	// Stated as required, with the reason, not as a suggestion.
	assert.doesNotMatch(readme, /optional|if you like|you may want to delete/i);
	assert.match(readme, /overwrite/i);
	assert.match(readme, /pics\//);
});

test("renderInstallReadme does not promise MDPro3 downloads the art itself", () => {
	// Its card-pack downloader only carries ygopro-super-pre URLs (Settings.cs
	// PrereleasePackUrl*), and card images are read off disk rather than fetched
	// per card — a player who waits for an automatic download waits forever.
	const readme = renderInstallReadme({ lang: "en", cards: 3463, packUrl: packUrlFor("en") });
	assert.match(readme, /will not fetch it for you/);
});

test("renderInstallReadme warns that the deck editor does not enforce Legend limits", () => {
	// Banlist.GetCredit(cardId) only ever consults CreditLimits.FirstOrDefault().Key,
	// so $legend_spell and $legend_trap are parsed and then never charged.
	const readme = renderInstallReadme({ lang: "en", cards: 3463, packUrl: packUrlFor("en") });
	assert.match(readme, /Legend/);
	assert.match(readme, /server/i);
});

test("renderInstallReadme flags the bundled local server as a caveat, not a blocker", () => {
	// YGOSharp/BanlistManager.Init int.Parse(data[1]) throws on "$legend_monster".
	// Joining our rooms never touches that parser.
	const readme = renderInstallReadme({ lang: "en", cards: 3463, packUrl: packUrlFor("en") });
	assert.match(readme, /local/i);
	assert.doesNotMatch(readme, /cannot join|does not work online/i);
});

test("renderInstallReadme falls back to the manual install when there is no pack URL", () => {
	// A local or test build has no published address to paste.
	const readme = renderInstallReadme({ lang: "en", cards: 1, packUrl: null });
	assert.match(readme, /Expansions/);
	assert.doesNotMatch(readme, /https:\/\/github\.com/);
});

test("renderInstallReadme is English for every language pack", () => {
	// Same reason as the Edison pack: it goes to players whose community
	// language is not ours.
	for (const lang of Object.keys(PACK_LANGS)) {
		assert.match(renderInstallReadme({ lang, cards: 1, packUrl: packUrlFor(lang) }), /Install/);
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

test("buildRushPack produces a flat .ypk holding exactly the three payload files", () => {
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
			"README.txt",
			"evolution-rush.cdb",
			"evolution-rush.lflist.conf",
		]);
		// No directory entries and no nesting: the archive root is the mount point.
		assert.deepEqual(archiveEntries(result.zipPath), result.entries);
		assert.ok(result.zipPath.endsWith("evolution-rush-en.ypk"));
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
			readFileSync(join(unpacked, "evolution-rush.lflist.conf")),
			readFileSync(lflist),
		);

		// The cdb must land DECOMPRESSED: MDPro3 opens it with SqliteConnection.
		const names = execFileSync(
			"sqlite3",
			[join(unpacked, "evolution-rush.cdb"), "SELECT name FROM texts ORDER BY id;"],
			{ encoding: "utf8" },
		).trim();
		assert.equal(names, "Blue-Eyes White Dragon\nSupreme Machine Magnum Overlord");
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("buildRushPack embeds the published pack URL in the README it ships", () => {
	const dir = mkdtempSync(join(tmpdir(), "rush-pack-readme-"));
	try {
		const { gz, lflist } = packFixture(dir);
		const outDir = join(dir, "out");
		mkdirSync(outDir);

		const { zipPath } = buildRushPack("en", outDir, { sourceGz: gz, lflist });
		const readme = execFileSync("unzip", ["-p", zipPath, "README.txt"], { encoding: "utf8" });
		assert.ok(readme.includes(packUrlFor("en")));
		assert.match(readme, /2 cards/);
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("buildRushPack is deterministic: two runs produce byte-identical archives", () => {
	// The published asset is replaced in place under a fixed release tag, so a
	// rebuild that changed nothing must not look like a new file.
	const dir = mkdtempSync(join(tmpdir(), "rush-pack-det-"));
	try {
		const { gz, lflist } = packFixture(dir);
		const first = buildRushPack("en", join(dir, "out1"), { sourceGz: gz, lflist });
		const second = buildRushPack("en", join(dir, "out2"), { sourceGz: gz, lflist });
		assert.equal(first.sha256, second.sha256);
		assert.equal(first.bytes, second.bytes);
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
		assert.deepEqual(archiveEntries(result.zipPath), result.entries);
	} finally {
		process.chdir(cwd);
		rmSync(dir, { recursive: true, force: true });
	}
});

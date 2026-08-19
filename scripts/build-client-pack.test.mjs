import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { existsSync, mkdtempSync, readFileSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";

import {
	buildClientPack,
	buildPackCdb,
	downloadPics,
	packLayout,
	packUrlFor,
	picJobs,
	readPoolRows,
	renderInstallReadme,
} from "./build-client-pack.mjs";

const SCHEMA =
	"CREATE TABLE datas(id integer primary key,ot integer,alias integer,setcode integer," +
	"type integer,atk integer,def integer,level integer,race integer,attribute integer,category integer);" +
	"CREATE TABLE texts(id integer primary key,name text,desc text,str1 text,str2 text,str3 text," +
	"str4 text,str5 text,str6 text,str7 text,str8 text,str9 text,str10 text,str11 text,str12 text," +
	"str13 text,str14 text,str15 text,str16 text);";

function makeCdb(path, cards) {
	execFileSync("sqlite3", [path], { input: SCHEMA, encoding: "utf8" });
	for (const { id, alias, name } of cards) {
		execFileSync("sqlite3", [
			path,
			`INSERT INTO datas(id,ot,alias) VALUES(${id},11,${alias}); ` +
				`INSERT INTO texts(id,name) VALUES(${id},'${name}');`,
		]);
	}
}

test("picJobs downloads the alias art and stores it under the pre-errata code", () => {
	const jobs = picJobs([
		{ id: 910003001, alias: 37742478 },
		{ id: 511002997, alias: 77565204 },
	]);
	assert.deepEqual(jobs, [
		{ code: 511002997, sourceCode: 77565204 },
		{ code: 910003001, sourceCode: 37742478 },
	]);
});

test("picJobs falls back to the card's own code when it has no alias", () => {
	assert.deepEqual(picJobs([{ id: 910003099, alias: 0 }]), [
		{ code: 910003099, sourceCode: 910003099 },
	]);
});

test("picJobs is deduplicated by destination code", () => {
	const jobs = picJobs([
		{ id: 910003001, alias: 37742478 },
		{ id: 910003001, alias: 37742478 },
	]);
	assert.equal(jobs.length, 1);
});

test("buildPackCdb copies every pool row into a fresh cdb", () => {
	const dir = mkdtempSync(join(tmpdir(), "pack-cdb-"));
	try {
		const src = join(dir, "pre-errata.en.cdb");
		makeCdb(src, [
			{ id: 910003001, alias: 37742478, name: "Honest" },
			{ id: 511002997, alias: 77565204, name: "Future Fusion" },
		]);

		const out = join(dir, "evolution-edison.cdb");
		assert.equal(buildPackCdb(src, out), 2);

		const rows = execFileSync("sqlite3", [out, "SELECT id,alias FROM datas ORDER BY id;"], {
			encoding: "utf8",
		})
			.trim()
			.split("\n");
		assert.deepEqual(rows, ["511002997|77565204", "910003001|37742478"]);

		const names = execFileSync("sqlite3", [out, "SELECT name FROM texts ORDER BY id;"], {
			encoding: "utf8",
		})
			.trim()
			.split("\n");
		assert.deepEqual(names, ["Future Fusion", "Honest"]);
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("buildPackCdb refuses to publish an empty pool", () => {
	const dir = mkdtempSync(join(tmpdir(), "pack-empty-"));
	try {
		const src = join(dir, "pre-errata.en.cdb");
		makeCdb(src, []);
		assert.throws(() => buildPackCdb(src, join(dir, "out.cdb")), /no cards/);
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("readPoolRows returns id and alias for every card in the pool", () => {
	const dir = mkdtempSync(join(tmpdir(), "pack-rows-"));
	try {
		const src = join(dir, "pool.cdb");
		makeCdb(src, [
			{ id: 910003002, alias: 71645242, name: "B" },
			{ id: 910003001, alias: 37742478, name: "A" },
		]);
		assert.deepEqual(readPoolRows(src), [
			{ id: 910003001, alias: 37742478 },
			{ id: 910003002, alias: 71645242 },
		]);
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("downloadPics writes one jpg per job, named by the pre-errata code", async () => {
	const dir = mkdtempSync(join(tmpdir(), "pack-pics-"));
	try {
		const asked = [];
		const fetchImpl = async (url) => {
			asked.push(url);
			return { ok: true, status: 200, arrayBuffer: async () => new TextEncoder().encode(`img:${url}`).buffer };
		};

		const written = await downloadPics(
			[
				{ code: 910003001, sourceCode: 37742478 },
				{ code: 511002997, sourceCode: 77565204 },
			],
			dir,
			{ fetchImpl, cdnBase: "https://cdn.test/pics" },
		);

		assert.equal(written, 2);
		assert.deepEqual(asked, [
			"https://cdn.test/pics/37742478.jpg",
			"https://cdn.test/pics/77565204.jpg",
		]);
		assert.deepEqual(readdirSync(dir).sort(), ["511002997.jpg", "910003001.jpg"]);
		assert.match(readFileSync(join(dir, "910003001.jpg"), "utf8"), /37742478\.jpg$/);
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("downloadPics fails loudly instead of shipping a card with no art", async () => {
	const dir = mkdtempSync(join(tmpdir(), "pack-pics-fail-"));
	try {
		const fetchImpl = async () => ({ ok: false, status: 404 });
		await assert.rejects(
			() => downloadPics([{ code: 910003001, sourceCode: 37742478 }], dir, { fetchImpl }),
			/910003001.*404/,
		);
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("packUrlFor points at the permanent latest-release address", () => {
	// /releases/latest/download/ never changes across releases, so a link pasted
	// in Discord today still installs the pool after it grows to 50 cards.
	assert.equal(
		packUrlFor("en"),
		"https://github.com/diangogav/evolution-assets/releases/latest/download/evolution-edison-en.ypk",
	);
	assert.match(packUrlFor("es"), /evolution-edison-es\.ypk$/);
});

test("packUrlFor stays free of a query string", () => {
	// MDPro3 saves the file as Path.GetFileName(url), so a query would end up
	// baked into the filename inside Expansions/.
	assert.doesNotMatch(packUrlFor("en"), /\?/);
});

test("renderInstallReadme leads with the in-client URL install when a URL is known", () => {
	// SettingServant.DownloadYPK: the player pastes a URL, MDPro3 downloads it to
	// Expansions/ and calls InitializeForDataChange() — no file manager, no restart.
	const readme = renderInstallReadme({ lang: "en", cards: 28, packUrl: "https://x.test/p.ypk" });
	assert.match(readme, /https:\/\/x\.test\/p\.ypk/);
	assert.match(readme, /without restarting|no restart/i);
});

test("renderInstallReadme falls back to the manual drop when no URL is configured", () => {
	const readme = renderInstallReadme({ lang: "en", cards: 28, packUrl: null });
	assert.doesNotMatch(readme, /https:\/\//);
	assert.match(readme, /Expansions/);
});

test("renderInstallReadme is a single MDPro3 drop with the card count", () => {
	const readme = renderInstallReadme({ lang: "en", cards: 28 });
	assert.match(readme, /28 cards/);
	assert.match(readme, /Expansions/);
	assert.match(readme, /MDPro3/);
});

test("renderInstallReadme says why the other clients are not supported yet", () => {
	// Classic YGOPro and YGOMobile have no $whitelist support and drop every
	// count>2 entry, so they cannot enforce the pool at all. Saying so stops the
	// "does this work on X?" thread before it starts.
	assert.match(renderInstallReadme({ lang: "en", cards: 28 }), /YGOPro|YGOMobile/);
});

test("packLayout ships a .ypk, the extension that reads as do-not-extract", () => {
	// MDPro3 mounts .zip and .ypk alike (FileGroupConfig zipExtensions), but a
	// .zip invites the player to extract it — which is the one action that
	// breaks the install.
	assert.equal(packLayout().archiveExtension, ".ypk");
});

test("packLayout is one archive the client mounts, nothing loose", () => {
	// MDPro3 FileGroupConfig.cs: Expansions = { Paths: ["Expansions/"],
	// Extensions: [".zip", ".ypk"] } and CardPicture = { Paths: ["pics/"] }.
	// BanlistManager matches any file whose name ends in "lflist.conf".
	assert.deepEqual(packLayout(), {
		archiveExtension: ".ypk",
		cdbName: "evolution-edison.cdb",
		picsDir: "pics",
		lflistName: "edison.lflist.conf",
		readmeName: "README.txt",
	});
});

test("buildClientPack works when outDir is a relative path", async () => {
	// `zip` runs with cwd set to the staging dir, so a relative output path would
	// resolve against staging instead of the caller's cwd and fail. Regression:
	// every earlier manual build happened to use an absolute outDir.
	const dir = mkdtempSync(join(tmpdir(), "pack-rel-"));
	const cwd = process.cwd();
	try {
		makeCdb(join(dir, "pool.cdb"), [{ id: 910003001, alias: 37742478, name: "Honest" }]);
		writeFileSync(join(dir, "lf.conf"), "!Test\n");
		process.chdir(dir);

		const fetchImpl = async () => ({
			ok: true,
			status: 200,
			arrayBuffer: async () => new TextEncoder().encode("img").buffer,
		});
		const result = await buildClientPack("en", "out", {
			srcCdb: "pool.cdb",
			lflist: "lf.conf",
			fetchImpl,
			packUrl: null,
		});

		assert.equal(result.cards, 1);
		assert.ok(existsSync(result.zipPath), `expected ${result.zipPath} to exist`);
	} finally {
		process.chdir(cwd);
		rmSync(dir, { recursive: true, force: true });
	}
});

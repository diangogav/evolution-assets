import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";

import { buildPrereleaseCdb, selectSourceCdbs } from "./build-prerelease-cdb.mjs";

const SCHEMA =
	"CREATE TABLE datas(id integer primary key,ot integer,alias integer,setcode integer," +
	"type integer,atk integer,def integer,level integer,race integer,attribute integer,category integer);" +
	"CREATE TABLE texts(id integer primary key,name text,desc text,str1 text,str2 text,str3 text," +
	"str4 text,str5 text,str6 text,str7 text,str8 text,str9 text,str10 text,str11 text,str12 text," +
	"str13 text,str14 text,str15 text,str16 text);";

function makeCdb(path, cards) {
	execFileSync("sqlite3", [path], { input: SCHEMA, encoding: "utf8" });
	for (const { id, ot, name } of cards) {
		execFileSync("sqlite3", [
			path,
			`INSERT INTO datas(id,ot) VALUES(${id},${ot}); INSERT INTO texts(id,name) VALUES(${id},'${name}');`,
		]);
	}
}

test("selectSourceCdbs keeps real cdbs, drops non-cdb and test- fixtures, sorted", () => {
	const picked = selectSourceCdbs(["BETB.cdb", "test-update.cdb", "README.md", "CORI-EN.cdb", "a.lua"]);
	assert.deepEqual(picked, ["BETB.cdb", "CORI-EN.cdb"]);
});

test("buildPrereleaseCdb merges every real set and excludes test- fixtures", () => {
	const dir = mkdtempSync(join(tmpdir(), "pre-"));
	try {
		makeCdb(join(dir, "SET1.cdb"), [
			{ id: 1001, ot: 1, name: "Alpha" },
			{ id: 1002, ot: 1, name: "Beta" },
		]);
		makeCdb(join(dir, "SET2.cdb"), [{ id: 2001, ot: 2, name: "Gamma" }]);
		makeCdb(join(dir, "test-junk.cdb"), [{ id: 9999, ot: 1, name: "ShouldNotAppear" }]);

		const out = join(dir, "prerelease.cdb");
		const result = buildPrereleaseCdb(dir, out);

		assert.deepEqual(result.sources, ["SET1.cdb", "SET2.cdb"]);
		assert.equal(result.cards, 3);

		const names = execFileSync("sqlite3", [out, "SELECT name FROM texts ORDER BY id;"], {
			encoding: "utf8",
		})
			.trim()
			.split("\n");
		assert.deepEqual(names, ["Alpha", "Beta", "Gamma"]);
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("buildPrereleaseCdb throws when no source cdbs are present", () => {
	const dir = mkdtempSync(join(tmpdir(), "pre-empty-"));
	try {
		assert.throws(() => buildPrereleaseCdb(dir, join(dir, "out.cdb")), /no source \.cdb/);
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

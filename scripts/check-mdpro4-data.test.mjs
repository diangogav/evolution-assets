import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import test from "node:test";

import {
	MECHANIC_COLUMNS,
	checkLflistShape,
	countRegressions,
	diffIds,
	evaluateCandidate,
	findMechanicMismatches,
	hasSqliteHeader,
	readCandidateCdb,
} from "./check-mdpro4-data.mjs";

const card = (id, overrides = {}) => ({
	id,
	type: 1,
	atk: 1000,
	def: 1000,
	level: 4,
	race: 1,
	attribute: 1,
	setcode: 0,
	alias: 0,
	...overrides,
});

// --- hasSqliteHeader ---

test("recognises the SQLite file header and nothing else", () => {
	assert.equal(hasSqliteHeader(Buffer.from("SQLite format 3\0rest-of-page")), true);
	assert.equal(hasSqliteHeader(Buffer.from("<!DOCTYPE html>")), false);
	assert.equal(hasSqliteHeader(Buffer.alloc(0)), false);
});

// --- findMechanicMismatches ---

test("compares exactly the eight mechanic columns", () => {
	assert.deepEqual(MECHANIC_COLUMNS, [
		"type",
		"atk",
		"def",
		"level",
		"race",
		"attribute",
		"setcode",
		"alias",
	]);
});

test("reports shared ids whose mechanics differ, naming the columns", () => {
	const union = [card(1), card(2), card(3)];
	const candidate = [card(3, { atk: 1500, level: 5 }), card(1), card(2, { alias: 9 })];

	assert.deepEqual(findMechanicMismatches(candidate, union), [
		{ id: 2, columns: ["alias"] },
		{ id: 3, columns: ["atk", "level"] },
	]);
});

test("ignores ids only one side carries", () => {
	const union = [card(1), card(2)];
	const candidate = [card(1), card(129000001, { alias: 1 })];

	assert.deepEqual(findMechanicMismatches(candidate, union), []);
});

// --- countRegressions ---

test("flags a table that shrank against the committed copy", () => {
	assert.deepEqual(
		countRegressions("en", { datas: 9, texts: 10 }, { datas: 10, texts: 10 }),
		["en: datas has 9 rows, fewer than the committed 10"],
	);
	assert.deepEqual(countRegressions("en", { datas: 11, texts: 11 }, { datas: 10, texts: 10 }), []);
});

test("has nothing to compare against on the first mirror", () => {
	assert.deepEqual(countRegressions("en", { datas: 1, texts: 1 }, null), []);
});

// --- checkLflistShape ---

test("accepts one section with entries", () => {
	assert.deepEqual(checkLflistShape("# header\n!2026.10 Rush Duel\n#Forbidden\n120226013 0 --x\n"), []);
});

test("rejects zero or several sections and an empty list", () => {
	assert.match(checkLflistShape("120226013 0\n").join(), /exactly one "!" section, found 0/);
	assert.match(checkLflistShape("!A\n1 0\n!B\n2 0\n").join(), /exactly one "!" section, found 2/);
	assert.match(checkLflistShape("!A\n#Forbidden\n").join(), /no card entries/);
});

// --- diffIds ---

test("lists added and removed ids in numeric order", () => {
	assert.deepEqual(diffIds([3, 1, 20], [20, 100, 3, 4]), { added: [4, 100], removed: [1] });
});

// --- evaluateCandidate ---

function goodCdb(label, rows) {
	return {
		label,
		header: true,
		tables: ["datas", "texts"],
		counts: { datas: rows.length, texts: rows.length },
		rows,
	};
}

function inputs(overrides = {}) {
	const rows = [card(1), card(2), card(129000001, { alias: 1 })];
	return {
		cdbs: [goodCdb("en", rows), goodCdb("es", rows)],
		committed: { en: { counts: { datas: 2, texts: 2 }, ids: [1, 2] }, es: null },
		unionRows: [card(1), card(2), card(5)],
		lflistText: "!2026.10 Rush Duel\n1 0 --x\n",
		upstreamCommit: "b".repeat(40),
		previousCommit: "a".repeat(40),
		contentChanged: true,
		...overrides,
	};
}

test("a sound candidate passes with a fragment describing the refresh", () => {
	const { errors, fragment } = evaluateCandidate(inputs());

	assert.deepEqual(errors, []);
	assert.deepEqual(fragment, {
		step: "check-mdpro4",
		status: "changed",
		upstreamCommit: "b".repeat(40),
		previousCommit: "a".repeat(40),
		counts: { en: { datas: 3, texts: 3 }, es: { datas: 3, texts: 3 } },
		idsAdded: { count: 1, sample: [129000001] },
		idsRemoved: { count: 0, sample: [] },
	});
});

test("an unchanged candidate reports unchanged", () => {
	assert.equal(evaluateCandidate(inputs({ contentChanged: false })).fragment.status, "unchanged");
});

test("a file that is not SQLite stops that cdb's other checks", () => {
	const broken = { label: "es", header: false, tables: [], counts: null, rows: [] };
	const { errors } = evaluateCandidate(inputs({ cdbs: [inputs().cdbs[0], broken] }));

	assert.deepEqual(errors, ["es: not a SQLite database"]);
});

test("a missing table is an error", () => {
	const cdb = { ...inputs().cdbs[0], tables: ["datas"] };
	assert.deepEqual(evaluateCandidate(inputs({ cdbs: [cdb] })).errors, ["en: missing table texts"]);
});

test("a mechanic drift aborts with at most ten offending ids", () => {
	const union = Array.from({ length: 12 }, (_, i) => card(i + 1));
	const drifted = union.map((row) => ({ ...row, atk: 0 }));
	const { errors } = evaluateCandidate(
		inputs({ cdbs: [goodCdb("en", drifted)], unionRows: union, committed: { en: null } }),
	);

	assert.equal(errors.length, 1);
	assert.match(errors[0], /^en: 12 shared ids differ from the mycard union/);
	assert.match(errors[0], /1 \(atk\), 2 \(atk\)/);
	assert.match(errors[0], /10 \(atk\)$/);
	assert.doesNotMatch(errors[0], /11 \(atk\)/);
});

test("a shrunken table and a malformed ban list are both reported", () => {
	const { errors } = evaluateCandidate(
		inputs({
			committed: { en: { counts: { datas: 5, texts: 5 }, ids: [1] }, es: null },
			lflistText: "#nothing\n",
		}),
	);

	assert.deepEqual(errors, [
		"en: datas has 3 rows, fewer than the committed 5",
		"en: texts has 3 rows, fewer than the committed 5",
		'Rush_lflist.conf: expected exactly one "!" section, found 0',
		"Rush_lflist.conf: no card entries",
	]);
});

// --- readCandidateCdb: the sqlite3 reader over a real file ---

test("reads header, tables, counts and mechanic rows from a cdb", (t) => {
	const dir = mkdtempSync(join(tmpdir(), "mdpro4-check-"));
	t.after(() => rmSync(dir, { recursive: true, force: true }));
	const path = join(dir, "cards.cdb");
	execFileSync("sqlite3", [
		path,
		"CREATE TABLE datas(id integer primary key,ot integer,alias integer,setcode integer," +
			"type integer,atk integer,def integer,level integer,race integer,attribute integer,category integer);" +
			"CREATE TABLE texts(id integer primary key,name text,desc text);" +
			"INSERT INTO datas VALUES(7,1,0,0,17,1200,800,4,2,16,0);" +
			"INSERT INTO texts VALUES(7,'Seven','');",
	]);
	const notSqlite = join(dir, "page.cdb");
	writeFileSync(notSqlite, "<html>rate limited</html>");

	assert.deepEqual(readCandidateCdb("en", path), {
		label: "en",
		header: true,
		tables: ["datas", "texts"],
		counts: { datas: 1, texts: 1 },
		rows: [card(7, { type: 17, atk: 1200, def: 800, race: 2, attribute: 16 })],
	});
	assert.deepEqual(readCandidateCdb("es", notSqlite), {
		label: "es",
		header: false,
		tables: [],
		counts: null,
		rows: [],
	});
});

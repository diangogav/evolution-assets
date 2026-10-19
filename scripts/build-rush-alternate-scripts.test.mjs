import assert from "node:assert/strict";
import { test } from "node:test";

import { GENERATED_MARKER, alternateStubs } from "./build-rush-alternate-scripts.mjs";

const row = { id: 129020166, alias: 120260039, name: "All Lovely Goddess" };

test("a row becomes a stub that delegates to its alias's script", () => {
	const { stubs, skipped, stale } = alternateStubs([row], new Map([["c120260039.lua", "local cm,m=GetID()"]]));
	assert.deepEqual(skipped, []);
	assert.deepEqual(stale, []);
	assert.equal(stubs.length, 1);
	assert.equal(stubs[0].fileName, "c129020166.lua");
	const lines = stubs[0].contents.split("\n");
	assert.equal(lines[0], GENERATED_MARKER);
	assert.ok(lines.includes("-- Alternate artwork of All Lovely Goddess (120260039)"));
	assert.ok(lines.includes("RD.AlternateCard(120260039)"));
});

test("a row whose base script does not exist is skipped and reported", () => {
	const { stubs, skipped } = alternateStubs([row], new Map());
	assert.deepEqual(stubs, []);
	assert.deepEqual(skipped, [{ id: 129020166, alias: 120260039, reason: "missing-base-script" }]);
});

test("a hand-written script is never overwritten", () => {
	const existing = new Map([
		["c120260039.lua", "base"],
		["c129020166.lua", "local cm,m=GetID()\n-- hand written"],
	]);
	const { stubs, skipped, stale } = alternateStubs([row], existing);
	assert.deepEqual(stubs, []);
	assert.deepEqual(skipped, [{ id: 129020166, alias: 120260039, reason: "hand-written-script" }]);
	assert.deepEqual(stale, []);
});

test("generated stubs whose row disappeared are reported stale, hand-written ones kept", () => {
	const existing = new Map([
		["c120260039.lua", "base"],
		["c129000001.lua", `${GENERATED_MARKER}\nRD.AlternateCard(120260039)`],
		["c129000002.lua", "local cm,m=GetID()"],
	]);
	const { stale } = alternateStubs([row], existing);
	assert.deepEqual(stale, ["c129000001.lua"]);
});

test("an existing generated stub for a live row is regenerated, not stale", () => {
	const existing = new Map([
		["c120260039.lua", "base"],
		["c129020166.lua", `${GENERATED_MARKER}\nold`],
	]);
	const { stubs, stale } = alternateStubs([row], existing);
	assert.equal(stubs.length, 1);
	assert.deepEqual(stale, []);
});

test("a row aliasing another generated row resolves once its base exists", () => {
	const rows = [
		{ id: 129000100, alias: 129000009, name: "B" },
		{ id: 129000009, alias: 120000001, name: "A" },
	];
	const { stubs, skipped } = alternateStubs(rows, new Map([["c120000001.lua", "base"]]));
	assert.deepEqual(skipped, []);
	assert.deepEqual(stubs.map((s) => s.fileName).sort(), ["c129000009.lua", "c129000100.lua"]);
});

test("rows without a distant alias are left to the engine", () => {
	const rows = [
		{ id: 120109001, alias: 0, name: "x" },
		{ id: 120109002, alias: 120109003, name: "y" },
	];
	const { stubs, skipped } = alternateStubs(rows, new Map([["c120109003.lua", "base"]]));
	assert.deepEqual(stubs, []);
	assert.deepEqual(skipped, []);
});

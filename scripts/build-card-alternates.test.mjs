import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { test } from "node:test";
import { fileURLToPath } from "node:url";

import { collectAlternates, listCdbs, renderAlternates } from "./build-card-alternates.mjs";

const CDB_DIR = join(dirname(fileURLToPath(import.meta.url)), "..", "cdb");
const committed = () => readFileSync(join(CDB_DIR, "alternates.json"), "utf8");

test("cdb/alternates.json matches a fresh render of every cdb", () => {
	assert.equal(
		committed(),
		renderAlternates(collectAlternates(listCdbs())),
		"run `npm run card-alternates` and commit the result",
	);
});

test("the Edison pre-errata alternates are mapped to their originals", () => {
	const { version, alternates } = JSON.parse(committed());
	assert.equal(version, 1);
	const pairs = [
		["29071332", "910003009"],
		["47355498", "910003011"],
		["20932152", "910003005"],
		["50321796", "511002993"],
		["7391448", "511002994"],
	];
	for (const [original, alternate] of pairs) {
		assert.ok(alternates[original]?.includes(alternate), `${original} → ${alternate}`);
	}
});

test("keys and alternate lists are sorted numerically, deduplicated, and never self-map", () => {
	const { alternates } = JSON.parse(committed());
	const byNumber = (a, b) => Number(a) - Number(b);
	const keys = Object.keys(alternates);
	assert.deepEqual(keys, [...keys].sort(byNumber));
	for (const [original, ids] of Object.entries(alternates)) {
		assert.ok(ids.length > 0, original);
		assert.deepEqual(ids, [...new Set(ids)].sort(byNumber), original);
		assert.ok(!ids.includes(original), `${original} maps to itself`);
	}
});

test("only uncompressed cdbs are read", () => {
	const names = listCdbs().map((path) => path.split("/").pop());
	assert.ok(names.length > 0);
	assert.ok(names.every((name) => name.endsWith(".cdb")), names.join(", "));
});

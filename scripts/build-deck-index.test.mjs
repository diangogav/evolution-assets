import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { test } from "node:test";
import { fileURLToPath } from "node:url";

import { listTemplates, renderIndex } from "./build-deck-index.mjs";

const DECKS_DIR = join(dirname(fileURLToPath(import.meta.url)), "..", "decks");

test("decks/index.json lists exactly the .ydk files in decks/", () => {
	const index = readFileSync(join(DECKS_DIR, "index.json"), "utf8");
	assert.equal(index, renderIndex(listTemplates()), "run `npm run deck-index` and commit the result");
});

test("the index keeps only .ydk files, sorted", () => {
	const { decks } = JSON.parse(renderIndex(["[JTP] B.ydk", "[2010.3 Edison] A.ydk"].sort()));
	assert.deepEqual(decks, ["[2010.3 Edison] A.ydk", "[JTP] B.ydk"]);
	assert.ok(listTemplates().every((name) => name.endsWith(".ydk")));
});

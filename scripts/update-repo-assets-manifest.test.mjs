import assert from "node:assert/strict";
import { existsSync } from "node:fs";
import { test } from "node:test";

import { REPO_ASSETS } from "./update-repo-assets-manifest.mjs";

// The manifest is the client's only update-detection channel for GitHub-hosted
// assets, and its probe matches entries by path. A stale path here would freeze
// that asset on every existing install, so pin each one to the repo.
test("every declared repo asset exists at its declared path", () => {
	for (const asset of REPO_ASSETS) {
		assert.ok(existsSync(asset.path), `missing file for ${asset.id}: ${asset.path}`);
	}
});

test("asset ids are unique", () => {
	const ids = REPO_ASSETS.map((a) => a.id);
	assert.equal(new Set(ids).size, ids.length);
});

test("asset paths are unique", () => {
	const paths = REPO_ASSETS.map((a) => a.path);
	assert.equal(new Set(paths).size, paths.length);
});

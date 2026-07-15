import assert from "node:assert/strict";
import { test } from "node:test";

import { buildManifest, contentSignature, upsertAsset } from "./build-version-manifest.mjs";

const moecubeAsset = {
	id: "cdb:base:en",
	path: "cdb/base.en.cdb.gz",
	sha256: "aaa",
	bytes: 100,
	upstreamUrl: "https://cdntx.moecube.com/ygopro-database/en-US/cards.cdb",
	upstreamLastModified: "Mon, 29 Jun 2026 07:53:27 GMT",
	mirroredAt: "2026-07-14T08:00:00.000Z",
	commitSha: null,
	commitDate: null,
};

const repoAsset = {
	id: "cdb:classic",
	path: "cdb/classic.cdb.gz",
	sha256: "bbb",
	bytes: 200,
	mirroredAt: "2026-07-14T08:00:00.000Z",
	commitSha: "e5f2a10abc",
	commitDate: "2026-07-13T22:14:00.000Z",
};

test("buildManifest sets schemaVersion 1 and the generatedAt timestamp", () => {
	const manifest = buildManifest([moecubeAsset], "2026-07-14T08:00:00.000Z");
	assert.equal(manifest.schemaVersion, 1);
	assert.equal(manifest.generatedAt, "2026-07-14T08:00:00.000Z");
});

test("buildManifest keys each asset by its ResourceId", () => {
	const manifest = buildManifest([moecubeAsset, repoAsset], "t");
	assert.deepEqual(Object.keys(manifest.assets).sort(), ["cdb:base:en", "cdb:classic"]);
});

test("every entry carries the full stable field set", () => {
	const { assets } = buildManifest([moecubeAsset], "t");
	const entry = assets["cdb:base:en"];
	for (const field of [
		"path",
		"sha256",
		"bytes",
		"upstreamUrl",
		"upstreamLastModified",
		"mirroredAt",
		"commitSha",
		"commitDate",
	]) {
		assert.ok(field in entry, `missing field ${field}`);
	}
});

test("repo-origin assets keep their git commit info", () => {
	const { assets } = buildManifest([repoAsset], "t");
	assert.equal(assets["cdb:classic"].commitSha, "e5f2a10abc");
	assert.equal(assets["cdb:classic"].commitDate, "2026-07-13T22:14:00.000Z");
});

test("moecube-origin assets have null commit info and carry upstream freshness instead", () => {
	const { assets } = buildManifest([moecubeAsset], "t");
	assert.equal(assets["cdb:base:en"].commitSha, null);
	assert.equal(assets["cdb:base:en"].commitDate, null);
	assert.equal(assets["cdb:base:en"].upstreamLastModified, "Mon, 29 Jun 2026 07:53:27 GMT");
});

test("upsertAsset adds a new entry without clobbering existing ones", () => {
	const base = buildManifest([moecubeAsset, repoAsset], "t");
	const genesysEntry = { path: "lflist/genesys.lflist.conf", sha256: "ccc", bytes: 42 };

	const merged = upsertAsset(base, "lflist:evolution:genesys", genesysEntry);

	assert.deepEqual(Object.keys(merged.assets).sort(), [
		"cdb:base:en",
		"cdb:classic",
		"lflist:evolution:genesys",
	]);
	assert.equal(merged.assets["cdb:base:en"].sha256, "aaa"); // untouched
});

test("upsertAsset is idempotent — a second merge replaces, never duplicates", () => {
	const base = buildManifest([moecubeAsset], "t");
	const once = upsertAsset(base, "lflist:evolution:genesys", { sha256: "v1" });
	const twice = upsertAsset(once, "lflist:evolution:genesys", { sha256: "v2" });

	assert.equal(Object.keys(twice.assets).length, 2); // base + genesys, not 3
	assert.equal(twice.assets["lflist:evolution:genesys"].sha256, "v2");
});

test("contentSignature ignores timestamps so no-op runs don't rewrite the file", () => {
	const a = buildManifest([moecubeAsset], "2026-07-14T08:00:00.000Z");
	const b = buildManifest([{ ...moecubeAsset, mirroredAt: "2026-07-14T10:00:00.000Z" }], "2026-07-14T10:00:00.000Z");

	assert.equal(contentSignature(a), contentSignature(b)); // only timestamps differ
});

test("contentSignature changes when real content changes", () => {
	const a = buildManifest([moecubeAsset], "t");
	const b = buildManifest([{ ...moecubeAsset, sha256: "different" }], "t");

	assert.notEqual(contentSignature(a), contentSignature(b));
});

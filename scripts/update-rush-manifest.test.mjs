import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import test from "node:test";
import { gzipSync } from "node:zlib";

import {
	RUSH_VARIANTS,
	applyRushEntries,
	rawContentStats,
	updateManifestFragment,
} from "./update-rush-manifest.mjs";

const NOW = "2026-08-26T00:00:00.000Z";

function baseManifest() {
	return {
		schemaVersion: 1,
		generatedAt: "2026-01-01T00:00:00.000Z",
		assets: {
			"cdb:classic": { path: "cdb/classic.cdb.gz", sha256: "abc", bytes: 1 },
		},
	};
}

function resolver(stats) {
	return {
		exists: (gzPath) => gzPath in stats,
		rawStats: (gzPath) => stats[gzPath],
		commit: () => ({ commitSha: "c0ffee", commitDate: NOW }),
	};
}

function statsFor(variants) {
	return Object.fromEntries(
		variants.map((v, i) => [v.gzPath, { sha256: `sha-${v.id}`, bytes: 100 + i }]),
	);
}

test("publishes the unified db and both language overlays", () => {
	assert.deepEqual(
		RUSH_VARIANTS.map((v) => [v.id, v.gzPath]),
		[
			["cdb:rush", "cdb/rush.cdb.gz"],
			["cdb:rush:en", "cdb/rush.en.cdb.gz"],
			["cdb:rush:es", "cdb/rush.es.cdb.gz"],
		],
	);
});

test("rawContentStats hashes the decompressed cdb, not the gzip", () => {
	const raw = Buffer.from("SQLite format 3\0pretend-card-database");
	const { sha256, bytes } = rawContentStats(gzipSync(raw));

	assert.equal(sha256, createHash("sha256").update(raw).digest("hex"));
	assert.equal(bytes, raw.length);
});

test("upserts one entry per variant pointing at its gz path", () => {
	const stats = statsFor(RUSH_VARIANTS);
	const { manifest, applied } = applyRushEntries(baseManifest(), RUSH_VARIANTS, NOW, resolver(stats));

	assert.deepEqual(applied, RUSH_VARIANTS.map((v) => v.id));
	for (const variant of RUSH_VARIANTS) {
		const entry = manifest.assets[variant.id];
		assert.equal(entry.path, variant.gzPath);
		assert.equal(entry.sha256, stats[variant.gzPath].sha256);
		assert.equal(entry.bytes, stats[variant.gzPath].bytes);
		assert.equal(entry.commitSha, "c0ffee");
		assert.equal(entry.mirroredAt, NOW);
	}
	assert.equal(manifest.generatedAt, NOW);
});

test("leaves unrelated assets untouched", () => {
	const variant = RUSH_VARIANTS[0];
	const { manifest } = applyRushEntries(
		baseManifest(),
		[variant],
		NOW,
		resolver(statsFor([variant])),
	);

	assert.deepEqual(manifest.assets["cdb:classic"], baseManifest().assets["cdb:classic"]);
});

test("skips a variant whose gz is absent instead of failing the run", () => {
	const [first, ...rest] = RUSH_VARIANTS;
	const { manifest, applied } = applyRushEntries(
		baseManifest(),
		RUSH_VARIANTS,
		NOW,
		resolver(statsFor(rest)),
	);

	assert.equal(applied.includes(first.id), false);
	assert.equal(manifest.assets[first.id], undefined);
	for (const variant of rest) {
		assert.ok(manifest.assets[variant.id]);
	}
});

// --- updateManifestFragment: the run-report fragment for this step ---

test("reports the applied variant ids with the rewrite verdict", () => {
	assert.deepEqual(updateManifestFragment(["cdb:rush", "cdb:rush:en"], true), {
		step: "update-manifest",
		status: "changed",
		applied: ["cdb:rush", "cdb:rush:en"],
	});
	assert.equal(updateManifestFragment([], false).status, "unchanged");
});

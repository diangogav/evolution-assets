// Upserts the Rush Duel cdb entries into version-manifest.json without
// clobbering the other assets. Run by mirror-rush-pack.yml after
// build-rush-cdb.mjs regenerates the unified databases.
//
// Three variants are published, mirroring the prerelease family: the unified
// untranslated db (zh-CN, as upstream ships it) and the en/es overlays whose
// texts come from rush/translations.json.
//
// The manifest's sha256/bytes describe the RAW cdb — the bytes the client
// holds after decompressing — so its downloaded-content hash matches directly.
// The builder never leaves a raw unified cdb on disk (only the gzips are
// published), so both values are derived by gunzipping the published gz in
// memory and hashing the result.

import { createHash } from "node:crypto";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { gunzipSync } from "node:zlib";

import {
	contentSignature,
	gitCommitInfo,
	upsertAsset,
} from "./build-version-manifest.mjs";
import { reportFragment } from "./run-report.mjs";

const MANIFEST_PATH = "version-manifest.json";

export const RUSH_VARIANTS = [
	{ id: "cdb:rush", gzPath: "cdb/rush.cdb.gz" },
	{ id: "cdb:rush:en", gzPath: "cdb/rush.en.cdb.gz" },
	{ id: "cdb:rush:es", gzPath: "cdb/rush.es.cdb.gz" },
];

/** sha256/bytes of the raw cdb inside a gzip, without touching disk. */
export function rawContentStats(gzBytes) {
	const raw = gunzipSync(gzBytes);
	return { sha256: createHash("sha256").update(raw).digest("hex"), bytes: raw.length };
}

const FS_RESOLVER = {
	exists: existsSync,
	rawStats: (gzPath) => rawContentStats(readFileSync(gzPath)),
	commit: gitCommitInfo,
};

/**
 * Pure: fold the given variants into a manifest and report which ones landed.
 * A variant whose gz is absent is skipped — a partial build must not fail the
 * whole manifest update, nor publish an entry with no file behind it.
 */
export function applyRushEntries(manifest, variants, now, resolver = FS_RESOLVER) {
	let updated = { ...manifest, generatedAt: now };
	const applied = [];

	for (const variant of variants) {
		if (!resolver.exists(variant.gzPath)) {
			console.warn(`${variant.id}: gz missing at ${variant.gzPath} — skipping`);
			continue;
		}
		const { sha256, bytes } = resolver.rawStats(variant.gzPath);
		const commit = resolver.commit(variant.gzPath);
		updated = upsertAsset(updated, variant.id, {
			path: variant.gzPath,
			sha256,
			bytes,
			upstreamUrl: null,
			upstreamLastModified: null,
			mirroredAt: now,
			commitSha: commit.commitSha,
			commitDate: commit.commitDate,
		});
		applied.push(variant.id);
	}

	return { manifest: updated, applied };
}

/**
 * The run-report fragment for this step: which variant ids landed, and
 * whether the manifest file was actually rewritten.
 */
export function updateManifestFragment(applied, changed) {
	return {
		step: "update-manifest",
		status: changed ? "changed" : "unchanged",
		applied,
	};
}

function main() {
	const now = new Date().toISOString();
	const existing = existsSync(MANIFEST_PATH)
		? JSON.parse(readFileSync(MANIFEST_PATH, "utf8"))
		: { schemaVersion: 1, generatedAt: now, assets: {} };

	const { manifest, applied } = applyRushEntries(existing, RUSH_VARIANTS, now);

	if (existsSync(MANIFEST_PATH) && contentSignature(existing) === contentSignature(manifest)) {
		console.log("Rush entries unchanged — not rewriting version-manifest.json");
		reportFragment(process.env, updateManifestFragment(applied, false));
		return;
	}

	writeFileSync(MANIFEST_PATH, `${JSON.stringify(manifest, null, 2)}\n`);
	console.log(`Updated ${applied.join(", ")} in ${MANIFEST_PATH}`);
	reportFragment(process.env, updateManifestFragment(applied, true));
}

if (process.argv[1]?.endsWith("update-rush-manifest.mjs")) {
	main();
}

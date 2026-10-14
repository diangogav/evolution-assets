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
//
// Each entry also names the ElderLich/MDPro4_Data commit its texts and
// alternate arts came from (`upstreamCommits`), read from the SOURCE_COMMIT
// the mirror writes next to the copied inputs. The cdb bytes alone cannot say
// which snapshot fed them, and that is the first question when a text looks
// wrong.

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
const MDPRO4_REPO = "ElderLich/MDPro4_Data";
const MDPRO4_SOURCE_COMMIT_PATH = "rush/mdpro4/SOURCE_COMMIT";

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

/** The full sha a SOURCE_COMMIT file holds; anything else is a broken mirror. */
export function parseSourceCommit(text) {
	const sha = text.trim();
	if (!/^[0-9a-f]{40}$/.test(sha)) {
		throw new Error(`${MDPRO4_SOURCE_COMMIT_PATH} does not hold a full commit sha: "${sha}"`);
	}
	return sha;
}

const FS_RESOLVER = {
	exists: existsSync,
	rawStats: (gzPath) => rawContentStats(readFileSync(gzPath)),
	commit: gitCommitInfo,
	upstreamCommits: () =>
		existsSync(MDPRO4_SOURCE_COMMIT_PATH)
			? { [MDPRO4_REPO]: parseSourceCommit(readFileSync(MDPRO4_SOURCE_COMMIT_PATH, "utf8")) }
			: null,
};

/**
 * Pure: fold the given variants into a manifest and report which ones landed.
 * A variant whose gz is absent is skipped — a partial build must not fail the
 * whole manifest update, nor publish an entry with no file behind it.
 */
export function applyRushEntries(manifest, variants, now, resolver = FS_RESOLVER) {
	let updated = { ...manifest, generatedAt: now };
	const applied = [];
	const upstreamCommits = resolver.upstreamCommits?.() ?? null;

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
			...(upstreamCommits ? { upstreamCommits } : {}),
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

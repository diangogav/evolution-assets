// Adds or refreshes the hand-maintained repo assets (edison/jtp lflists and the
// pre-errata overlay cdbs) in version-manifest.json without clobbering the
// entries written by the other workflows (cdb mirror, prerelease, genesys).
//
// These files are edited by regular commits, not by a scheduled mirror, so no
// other workflow ever hashed them into the manifest. The game client can only
// detect updates for GitHub-hosted assets through this manifest
// (raw.githubusercontent.com exposes no CORS-readable validators), so an asset
// missing here is frozen forever on existing installs.

import { existsSync, readFileSync, writeFileSync } from "node:fs";

import {
	contentSignature,
	gitCommitInfo,
	sha256File,
	upsertAsset,
} from "./build-version-manifest.mjs";

const MANIFEST_PATH = "version-manifest.json";

// Keys match the client's ResourceId strings (evolution-card-game
// sources.config.ts); paths are the exact repo paths the client downloads, so
// its ManifestProbe can match entries by path. All of these are served raw
// (no .gz), so the published sha256 is the hash of the file itself.
export const REPO_ASSETS = [
	{ id: "lflist:evolution:edison", path: "lflist/edison.lflist.conf" },
	{ id: "lflist:evolution:jtp", path: "lflist/jtp.lflist.conf" },
	{ id: "lflist:evolution:jtp-adv-2007-03", path: "lflist/jtp-advanced-marzo-2007.lflist.conf" },
	{ id: "cdb:pre-errata:en", path: "cdb/pre-errata.en.cdb" },
	{ id: "cdb:pre-errata:es", path: "cdb/pre-errata.es.cdb" },
];

function main() {
	const now = new Date().toISOString();
	const manifest = existsSync(MANIFEST_PATH)
		? JSON.parse(readFileSync(MANIFEST_PATH, "utf8"))
		: { schemaVersion: 1, generatedAt: now, assets: {} };

	let updated = { ...manifest, generatedAt: now };
	for (const asset of REPO_ASSETS) {
		if (!existsSync(asset.path)) {
			// A missing file means a rename this script was not updated for — fail
			// loudly instead of silently dropping the asset from freshness checks.
			throw new Error(`asset file not found: ${asset.path} (${asset.id})`);
		}
		const commit = gitCommitInfo(asset.path);
		updated = upsertAsset(updated, asset.id, {
			path: asset.path,
			sha256: sha256File(asset.path),
			bytes: readFileSync(asset.path).length,
			upstreamUrl: null,
			upstreamLastModified: null,
			mirroredAt: now,
			commitSha: commit.commitSha,
			commitDate: commit.commitDate,
		});
	}

	if (existsSync(MANIFEST_PATH) && contentSignature(manifest) === contentSignature(updated)) {
		console.log("repo assets unchanged — not rewriting version-manifest.json");
		return;
	}

	writeFileSync(MANIFEST_PATH, `${JSON.stringify(updated, null, 2)}\n`);
	console.log(`Updated ${REPO_ASSETS.length} repo asset entries in ${MANIFEST_PATH}`);
}

if (process.argv[1]?.endsWith("update-repo-assets-manifest.mjs")) {
	main();
}

// Upserts the cdb:prerelease entry into version-manifest.json without clobbering
// the other assets. Run by mirror-prerelease-cdb.yml after the merged cdb is built.
//
// The sha256 is taken over the RAW merged cdb (the bytes the client gets after
// decompressing the .gz), so the client's downloaded-content hash matches directly.

import { existsSync, readFileSync, statSync, writeFileSync } from "node:fs";

import {
	contentSignature,
	gitCommitInfo,
	sha256File,
	upsertAsset,
} from "./build-version-manifest.mjs";

const MANIFEST_PATH = "version-manifest.json";
const GZ_PATH = "cdb/prerelease.cdb.gz";
const ID = "cdb:prerelease";
// The merged raw cdb the workflow produced (before gzip); env-overridable for CI.
const RAW_CDB = process.env.PRERELEASE_RAW_CDB ?? "/tmp/prerelease.cdb";

function main() {
	const now = new Date().toISOString();
	const manifest = existsSync(MANIFEST_PATH)
		? JSON.parse(readFileSync(MANIFEST_PATH, "utf8"))
		: { schemaVersion: 1, generatedAt: now, assets: {} };

	const commit = gitCommitInfo(GZ_PATH);
	const entry = {
		path: GZ_PATH,
		sha256: sha256File(RAW_CDB),
		bytes: statSync(RAW_CDB).size,
		upstreamUrl: null,
		upstreamLastModified: null,
		mirroredAt: now,
		commitSha: commit.commitSha,
		commitDate: commit.commitDate,
	};

	const updated = upsertAsset({ ...manifest, generatedAt: now }, ID, entry);

	if (existsSync(MANIFEST_PATH) && contentSignature(manifest) === contentSignature(updated)) {
		console.log(`${ID} unchanged — not rewriting version-manifest.json`);
		return;
	}

	writeFileSync(MANIFEST_PATH, `${JSON.stringify(updated, null, 2)}\n`);
	console.log(`Updated ${ID} in ${MANIFEST_PATH}`);
}

if (process.argv[1]?.endsWith("update-prerelease-manifest.mjs")) {
	main();
}

// Adds or refreshes the genesys lflist entry in version-manifest.json without
// clobbering the cdb entries written by the mirror workflow. Run by genesys.yml
// after it regenerates lflist/genesys.lflist.conf.

import { existsSync, readFileSync, writeFileSync } from "node:fs";

import {
	contentSignature,
	gitCommitInfo,
	sha256File,
	upsertAsset,
} from "./build-version-manifest.mjs";

const MANIFEST_PATH = "version-manifest.json";
const GENESYS_PATH = "lflist/genesys.lflist.conf";
const GENESYS_ID = "lflist:evolution:genesys";

function main() {
	const now = new Date().toISOString();
	const manifest = existsSync(MANIFEST_PATH)
		? JSON.parse(readFileSync(MANIFEST_PATH, "utf8"))
		: { schemaVersion: 1, generatedAt: now, assets: {} };

	const commit = gitCommitInfo(GENESYS_PATH);
	const entry = {
		path: GENESYS_PATH,
		sha256: sha256File(GENESYS_PATH),
		bytes: readFileSync(GENESYS_PATH).length,
		upstreamUrl: null,
		upstreamLastModified: null,
		mirroredAt: now,
		commitSha: commit.commitSha,
		commitDate: commit.commitDate,
	};

	const updated = upsertAsset({ ...manifest, generatedAt: now }, GENESYS_ID, entry);

	if (existsSync(MANIFEST_PATH) && contentSignature(manifest) === contentSignature(updated)) {
		console.log(`${GENESYS_ID} unchanged — not rewriting version-manifest.json`);
		return;
	}

	writeFileSync(MANIFEST_PATH, `${JSON.stringify(updated, null, 2)}\n`);
	console.log(`Updated ${GENESYS_ID} in ${MANIFEST_PATH}`);
}

if (process.argv[1]?.endsWith("update-genesys-manifest.mjs")) {
	main();
}

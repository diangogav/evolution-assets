// Upserts the pre-release entries into version-manifest.json without clobbering
// the other assets. Run by mirror-prerelease-cdb.yml after the merged cdbs are built.
//
// Three variants are published: the language-agnostic zh-CN overlay (kept for
// clients that predate per-language overlays) and the en/es variants whose texts
// come from TransSuperpre. The sha256 is taken over the RAW merged cdb (the bytes
// the client gets after decompressing the .gz), so the client's downloaded-content
// hash matches directly.

import { existsSync, readFileSync, statSync, writeFileSync } from "node:fs";

import {
	contentSignature,
	gitCommitInfo,
	sha256File,
	upsertAsset,
} from "./build-version-manifest.mjs";

const MANIFEST_PATH = "version-manifest.json";

// Raw paths are env-overridable for CI. A variant whose raw file is absent is
// skipped (partial runs must not fail the whole manifest update).
const VARIANTS = [
	{
		id: "cdb:prerelease",
		gzPath: "cdb/prerelease.cdb.gz",
		raw: process.env.PRERELEASE_RAW_CDB ?? "/tmp/prerelease.cdb",
	},
	{
		id: "cdb:prerelease:en",
		gzPath: "cdb/prerelease.en.cdb.gz",
		raw: process.env.PRERELEASE_RAW_CDB_EN ?? "/tmp/prerelease.en.cdb",
	},
	{
		id: "cdb:prerelease:es",
		gzPath: "cdb/prerelease.es.cdb.gz",
		raw: process.env.PRERELEASE_RAW_CDB_ES ?? "/tmp/prerelease.es.cdb",
	},
];

function main() {
	const now = new Date().toISOString();
	const manifest = existsSync(MANIFEST_PATH)
		? JSON.parse(readFileSync(MANIFEST_PATH, "utf8"))
		: { schemaVersion: 1, generatedAt: now, assets: {} };

	let updated = { ...manifest, generatedAt: now };
	const applied = [];
	for (const variant of VARIANTS) {
		if (!existsSync(variant.raw)) {
			console.warn(`${variant.id}: raw cdb missing at ${variant.raw} — skipping`);
			continue;
		}
		const commit = gitCommitInfo(variant.gzPath);
		updated = upsertAsset(updated, variant.id, {
			path: variant.gzPath,
			sha256: sha256File(variant.raw),
			bytes: statSync(variant.raw).size,
			upstreamUrl: null,
			upstreamLastModified: null,
			mirroredAt: now,
			commitSha: commit.commitSha,
			commitDate: commit.commitDate,
		});
		applied.push(variant.id);
	}

	if (existsSync(MANIFEST_PATH) && contentSignature(manifest) === contentSignature(updated)) {
		console.log("pre-release entries unchanged — not rewriting version-manifest.json");
		return;
	}

	writeFileSync(MANIFEST_PATH, `${JSON.stringify(updated, null, 2)}\n`);
	console.log(`Updated ${applied.join(", ")} in ${MANIFEST_PATH}`);
}

if (process.argv[1]?.endsWith("update-prerelease-manifest.mjs")) {
	main();
}

// Builds version-manifest.json: a small file the game client polls to learn the
// current published version of each asset without downloading it. Keys match the
// client's ResourceId strings so it can map a manifest entry straight to its cache.
//
// The hash is taken over the RAW (uncompressed) bytes so it is reproducible and
// independent of the gzip tool version. For assets that originate in this repo
// (classic, jtp) we also record the last git commit that touched the file, so the
// client can show "last updated: <date>". Assets mirrored from moecube have no git
// history for their content, so their commit fields are null and freshness comes
// from upstreamLastModified instead.

import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { existsSync, readFileSync, statSync, writeFileSync } from "node:fs";

const MANIFEST_PATH = "version-manifest.json";

// Pure: assemble a manifest object from already-resolved asset descriptors.
export function buildManifest(assets, generatedAt) {
	const manifest = { schemaVersion: 1, generatedAt, assets: {} };
	for (const asset of assets) {
		manifest.assets[asset.id] = toEntry(asset);
	}
	return manifest;
}

// Pure: add or replace a single asset entry, leaving every other entry untouched.
// Used both by the cdb mirror (to preserve genesys/edison entries) and by genesys.yml.
export function upsertAsset(manifest, id, entry) {
	return {
		schemaVersion: 1,
		generatedAt: manifest.generatedAt,
		assets: { ...manifest.assets, [id]: entry },
	};
}

// A signature of the meaningful content, ignoring the per-run timestamps. Lets the CLI
// avoid rewriting (and committing) the manifest when only mirroredAt/generatedAt would
// differ — otherwise every scheduled run would produce a spurious timestamp-only commit.
export function contentSignature(manifest) {
	const stripped = {};
	for (const [id, entry] of Object.entries(manifest.assets ?? {})) {
		const { mirroredAt, ...rest } = entry;
		stripped[id] = rest;
	}
	return JSON.stringify(stripped);
}

function toEntry(asset) {
	return {
		path: asset.path,
		sha256: asset.sha256,
		bytes: asset.bytes,
		upstreamUrl: asset.upstreamUrl ?? null,
		upstreamLastModified: asset.upstreamLastModified ?? null,
		mirroredAt: asset.mirroredAt,
		commitSha: asset.commitSha ?? null,
		commitDate: asset.commitDate ?? null,
	};
}

export function sha256File(path) {
	return createHash("sha256").update(readFileSync(path)).digest("hex");
}

// Last commit that touched `path`, or nulls when the file has no git history.
export function gitCommitInfo(path) {
	try {
		const out = execFileSync("git", ["log", "-1", "--format=%H %aI", "--", path], {
			encoding: "utf8",
		}).trim();
		if (!out) return { commitSha: null, commitDate: null };
		const [commitSha, commitDate] = out.split(" ");
		return { commitSha, commitDate };
	} catch {
		return { commitSha: null, commitDate: null };
	}
}

// The cdb assets this repo publishes, mapped to the client's ResourceId keys.
// `raw` is the uncompressed file we hash; `path` is the gzip the client downloads.
const CDB_ASSETS = [
	{
		id: "cdb:base:en",
		raw: "/tmp/base.en.cdb",
		path: "cdb/base.en.cdb.gz",
		upstreamUrl: "https://cdntx.moecube.com/ygopro-database/en-US/cards.cdb",
		lastModifiedEnv: "MOECUBE_EN_LAST_MODIFIED",
		origin: "moecube",
	},
	{
		id: "cdb:base:es",
		raw: "/tmp/base.es.cdb",
		path: "cdb/base.es.cdb.gz",
		upstreamUrl: "https://cdntx.moecube.com/ygopro-database/es-ES/cards.cdb",
		lastModifiedEnv: "MOECUBE_ES_LAST_MODIFIED",
		origin: "moecube",
	},
	{ id: "cdb:classic", raw: "cdb/classic.cdb", path: "cdb/classic.cdb.gz", origin: "repo" },
	{ id: "cdb:jtp:en", raw: "cdb/jtp.en.cdb", path: "cdb/jtp.en.cdb.gz", origin: "repo" },
	{ id: "cdb:jtp:es", raw: "cdb/jtp.es.cdb", path: "cdb/jtp.es.cdb.gz", origin: "repo" },
];

function resolveCdbAssets(mirroredAt, env) {
	const assets = [];
	for (const def of CDB_ASSETS) {
		if (!existsSync(def.raw)) {
			continue; // a raw file may be absent on a partial run — skip, do not fail the whole manifest
		}
		const commit =
			def.origin === "repo" ? gitCommitInfo(def.raw) : { commitSha: null, commitDate: null };
		assets.push({
			id: def.id,
			path: def.path,
			sha256: sha256File(def.raw),
			bytes: statSync(def.raw).size,
			upstreamUrl: def.upstreamUrl ?? null,
			// `|| null` (not `??`) so an empty string from a missing header becomes null.
			upstreamLastModified: def.lastModifiedEnv ? env[def.lastModifiedEnv] || null : null,
			mirroredAt,
			...commit,
		});
	}
	return assets;
}

function main() {
	const now = new Date().toISOString();
	// Preserve entries written by other workflows (genesys, etc.): read the existing
	// manifest and upsert only the cdb entries this run is responsible for.
	const existing = existsSync(MANIFEST_PATH)
		? JSON.parse(readFileSync(MANIFEST_PATH, "utf8"))
		: { schemaVersion: 1, generatedAt: now, assets: {} };

	let manifest = { ...existing, generatedAt: now };
	for (const asset of resolveCdbAssets(now, process.env)) {
		manifest = upsertAsset(manifest, asset.id, toEntry(asset));
	}

	if (existsSync(MANIFEST_PATH) && contentSignature(existing) === contentSignature(manifest)) {
		console.log("version-manifest.json unchanged (content identical) — not rewriting");
		return;
	}

	writeFileSync(MANIFEST_PATH, `${JSON.stringify(manifest, null, 2)}\n`);
	console.log(`Wrote ${MANIFEST_PATH} with ${Object.keys(manifest.assets).length} assets`);
}

// Run main() only when invoked as a CLI, not when imported by tests.
if (process.argv[1] && process.argv[1].endsWith("build-version-manifest.mjs")) {
	main();
}

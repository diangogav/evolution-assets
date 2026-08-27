// Checks that every version-manifest.json entry describes the file it points at.
//
// The manifest is what every client compares against to decide whether its copy
// is current, and it stores the sha256 of the RAW bytes — the ones the client
// holds after decompressing a .gz. When an artifact is rebuilt and the manifest
// is not, that hash describes bytes nobody has: the client downloads, fails to
// match, and is offered the same update forever. It has happened twice, because
// nothing watches those paths — mirror-rush-pack.yml regenerates the manifest
// only on its daily cron, and repo-assets-manifest.yml triggers on the lflist
// and pre-errata paths alone.
//
// This only reports; it never rewrites. Regenerating the manifest here would
// hide the very mismatch a reviewer needs to see, and the manifest decides what
// thousands of clients download.
//
// usage: node scripts/verify-manifest.mjs

import { createHash } from "node:crypto";
import { existsSync, readFileSync } from "node:fs";
import { gunzipSync } from "node:zlib";

const MANIFEST_PATH = "version-manifest.json";

/** The sha256 a client ends up with: gz entries are hashed after decompression. */
export function rawDigest(path, bytes) {
	const raw = path.endsWith(".gz") ? gunzipSync(bytes) : bytes;
	return { sha256: createHash("sha256").update(raw).digest("hex"), bytes: raw.length };
}

/**
 * Compare one manifest entry against the file on disk.
 *
 * An entry with no `path` is not ours to check — the manifest also carries
 * assets mirrored from elsewhere, and only a path makes one verifiable here.
 */
export function checkEntry(id, entry, { exists, read }) {
	const path = entry?.path;
	if (!path) return { id, status: "skipped", reason: "no path" };
	if (!exists(path)) return { id, status: "missing", path };

	const actual = rawDigest(path, read(path));
	if (actual.sha256 !== entry.sha256) {
		return { id, status: "mismatch", path, declared: entry.sha256, actual: actual.sha256 };
	}
	// `bytes` is the same raw measurement, so a drift there means the same defect.
	if (entry.bytes !== undefined && entry.bytes !== actual.bytes) {
		return { id, status: "size", path, declared: entry.bytes, actual: actual.bytes };
	}
	return { id, status: "ok", path };
}

/** Every entry checked, in manifest order. */
export function checkManifest(manifest, io) {
	return Object.entries(manifest.assets ?? {}).map(([id, entry]) => checkEntry(id, entry, io));
}

/** The lines a run prints, and whether it passed. */
export function renderReport(results) {
	const bad = results.filter((r) => r.status !== "ok" && r.status !== "skipped");
	const lines = [];

	for (const r of bad) {
		if (r.status === "missing") lines.push(`${r.id}: no file at ${r.path}`);
		else if (r.status === "size") {
			lines.push(`${r.id}: ${r.path} is ${r.actual} bytes, manifest says ${r.declared}`);
		} else {
			lines.push(
				`${r.id}: ${r.path} hashes to ${r.actual.slice(0, 12)}, ` +
					`manifest says ${r.declared?.slice(0, 12)}`,
			);
		}
	}

	if (bad.length > 0) {
		lines.push("");
		lines.push(
			"The artifact was rebuilt without regenerating the manifest. Run the " +
				"updater for that family (e.g. scripts/update-rush-manifest.mjs) and commit the result.",
		);
	}

	const checked = results.filter((r) => r.status !== "skipped").length;
	lines.push(`${checked - bad.length}/${checked} manifest entries match their file`);
	return { lines, ok: bad.length === 0 };
}

function main() {
	const manifest = JSON.parse(readFileSync(MANIFEST_PATH, "utf8"));
	const results = checkManifest(manifest, {
		exists: existsSync,
		read: (path) => readFileSync(path),
	});
	const { lines, ok } = renderReport(results);
	for (const line of lines) console[ok ? "log" : "error"](line);
	if (!ok) process.exit(1);
}

if (process.argv[1]?.endsWith("verify-manifest.mjs")) {
	main();
}

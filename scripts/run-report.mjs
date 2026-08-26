// The run-report v1 fragment contract shared by the pipeline scripts. When a
// script runs with REPORT_PATH set, it ALSO drops a JSON fragment there —
// `{ "step": "<id>", "status": "changed"|"unchanged", ...step data }` — for
// the per-pipeline composer (scripts/report-rush.mjs) to merge. Without
// REPORT_PATH the scripts behave exactly as before: stderr stats only.
//
// The fragment is bookkeeping around the script's real job: it is written
// only after the main outputs are safely on disk, and a failed write flips
// the exit code instead of throwing so the outputs survive while the run
// still fails loudly enough for CI to notice the missing fragment.

import { mkdirSync, writeFileSync } from "node:fs";
import { dirname } from "node:path";

/** A long id list as report data: full count, at most `limit` sample ids. */
export function sampled(list, limit = 20) {
	return { count: list.length, sample: list.slice(0, limit) };
}

/**
 * One fragment file, parent directories included — same rendering as every
 * committed JSON in this repo: 2-space indent, trailing newline.
 */
export function writeReportFragment(path, fragment) {
	mkdirSync(dirname(path), { recursive: true });
	writeFileSync(path, `${JSON.stringify(fragment, null, 2)}\n`);
}

/**
 * The REPORT_PATH contract: a no-op when the env does not ask for a
 * fragment; a non-zero exit (not a throw) when it asks and the write fails.
 */
export function reportFragment(env, fragment) {
	if (!env.REPORT_PATH) return;
	try {
		writeReportFragment(env.REPORT_PATH, fragment);
	} catch (err) {
		console.error(`failed to write report fragment ${env.REPORT_PATH}: ${err.message}`);
		process.exitCode = 1;
	}
}

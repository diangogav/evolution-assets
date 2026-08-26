import assert from "node:assert/strict";
import { existsSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";

import { reportFragment, sampled, writeReportFragment } from "./run-report.mjs";

// --- sampled: gap lists ship as a count plus a bounded sample ---

test("keeps the full count but at most 20 sample entries", () => {
	const ids = Array.from({ length: 30 }, (_, i) => String(120100001 + i));
	assert.deepEqual(sampled(ids), { count: 30, sample: ids.slice(0, 20) });
});

test("passes a short list through whole", () => {
	assert.deepEqual(sampled(["120100001"]), { count: 1, sample: ["120100001"] });
});

// --- writeReportFragment: one JSON fragment file per pipeline step ---

test("writes the fragment as 2-space JSON with a trailing newline, creating parents", () => {
	const dir = mkdtempSync(join(tmpdir(), "run-report-"));
	try {
		const path = join(dir, "report", "resolve-pages.json");
		writeReportFragment(path, { step: "resolve-pages", status: "unchanged" });
		assert.equal(
			readFileSync(path, "utf8"),
			'{\n  "step": "resolve-pages",\n  "status": "unchanged"\n}\n',
		);
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

// --- reportFragment: the REPORT_PATH contract used by every pipeline script ---

test("writes nothing when REPORT_PATH is unset", () => {
	const dir = mkdtempSync(join(tmpdir(), "run-report-"));
	try {
		reportFragment({}, { step: "build-cdb", status: "changed" });
		assert.deepEqual(existsSync(join(dir, "build-cdb.json")), false);
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("writes the fragment where REPORT_PATH points", () => {
	const dir = mkdtempSync(join(tmpdir(), "run-report-"));
	try {
		const path = join(dir, "build-cdb.json");
		reportFragment({ REPORT_PATH: path }, { step: "build-cdb", status: "changed" });
		assert.deepEqual(JSON.parse(readFileSync(path, "utf8")), {
			step: "build-cdb",
			status: "changed",
		});
		assert.notEqual(process.exitCode, 1);
	} finally {
		rmSync(dir, { recursive: true, force: true });
	}
});

test("flips the exit code instead of throwing when the fragment cannot land", () => {
	const dir = mkdtempSync(join(tmpdir(), "run-report-"));
	const previous = process.exitCode;
	try {
		// A plain file where a directory is needed makes the write fail.
		writeFileSync(join(dir, "blocker"), "not a directory");
		reportFragment(
			{ REPORT_PATH: join(dir, "blocker", "step.json") },
			{ step: "update-manifest", status: "changed" },
		);
		assert.equal(process.exitCode, 1);
	} finally {
		process.exitCode = previous;
		rmSync(dir, { recursive: true, force: true });
	}
});

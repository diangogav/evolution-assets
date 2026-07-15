// Structural validation for the hand-maintained lflist files (edison, jtp).
// These have no upstream machine source, so a typo can only be caught here — a bad
// entry would otherwise ship and break the server's ban-list parsing at runtime.
//
// A .lflist.conf looks like:
//   #[2010.3 Edison]        ← comment / display header
//   !2010.3 Edison          ← the banlist declaration (required)
//   $whitelist              ← mode flag
//   #forbidden              ← section comment
//   72989439 0 --Card name  ← entry: <cardId> <count> [-- comment]
//
// Rules enforced:
//   1. a banlist header (a "!name" line) is present
//   2. at least one card entry exists (non-empty)
//   3. no card id appears twice within the same file

import { readFileSync } from "node:fs";

const LFLISTS = ["lflist/edison.lflist.conf", "lflist/jtp.lflist.conf"];

// Pure: returns a list of human-readable error strings (empty = valid).
export function validateLflist(text, label) {
	const errors = [];
	const lines = text.split("\n");
	const seen = new Map(); // cardId → 1-based line number of first occurrence
	let hasHeader = false;
	let entryCount = 0;

	for (let i = 0; i < lines.length; i++) {
		const line = lines[i].trim();
		if (line === "") continue;
		if (line.startsWith("!")) {
			hasHeader = true;
			continue;
		}
		// comments, section markers, mode flags, and metadata
		if (line.startsWith("#") || line.startsWith("$") || line.startsWith("--")) continue;

		// entry: <cardId> <count> [ -- comment | points ]
		const match = line.match(/^(\d+)\s+(-?\d+)(?:\s+.*)?$/);
		if (!match) {
			errors.push(`${label}:${i + 1}: unparseable line: "${lines[i]}"`);
			continue;
		}

		const cardId = match[1];
		entryCount++;
		const firstLine = seen.get(cardId);
		if (firstLine !== undefined) {
			errors.push(`${label}: duplicate card id ${cardId} (lines ${firstLine} and ${i + 1})`);
		} else {
			seen.set(cardId, i + 1);
		}
	}

	if (!hasHeader) errors.push(`${label}: missing banlist header (a "!name" line)`);
	if (entryCount === 0) errors.push(`${label}: no card entries found (empty banlist)`);

	return errors;
}

function main() {
	const allErrors = [];
	for (const path of LFLISTS) {
		let text;
		try {
			text = readFileSync(path, "utf8");
		} catch (error) {
			allErrors.push(`${path}: cannot read file (${error.message})`);
			continue;
		}
		allErrors.push(...validateLflist(text, path));
	}

	if (allErrors.length > 0) {
		console.error("lflist validation failed:");
		for (const err of allErrors) console.error(`  - ${err}`);
		process.exit(1);
	}
	console.log(`lflist validation passed (${LFLISTS.join(", ")})`);
}

if (process.argv[1]?.endsWith("validate-lflist.mjs")) {
	main();
}

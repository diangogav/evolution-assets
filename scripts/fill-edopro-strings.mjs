#!/usr/bin/env node
/**
 * Fills the gaps of a translated EDOPro strings.conf from a second translation.
 *
 * EDOPro's own Spanish strings.conf leaves many entries untranslated, and a
 * client that reads it falls back to English for those. A community file
 * covers most of them. The output is the base file unchanged, followed by the
 * entries of the fill file the base lacks.
 *
 * An entry is taken from the fill file only when the reference file (EDOPro's
 * English strings.conf) defines the same kind and id, and with the same
 * placeholders: the fill file is edited by hand and updated rarely, so an id
 * the reference no longer has, or a sentence whose placeholders drifted, is
 * left to the English fallback instead of being shown wrong.
 *
 * Usage:
 *   node scripts/fill-edopro-strings.mjs --base <es.conf> --fill <other-es.conf> \
 *     --reference <en.conf> --out <merged.conf>
 */
import { readFileSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

const ENTRY = /^!(system|victory|counter|setname)\s+(\S+)\s+(.*\S)\s*$/;
const PLACEHOLDER = /%l?[sdux]|%X|\{\}/g;

export function parseArgs(argv) {
	const opts = { base: null, fill: null, reference: null, out: null };
	const keys = { "--base": "base", "--fill": "fill", "--reference": "reference", "--out": "out" };
	for (let i = 0; i < argv.length; i += 2) {
		const key = keys[argv[i]];
		if (!key || argv[i + 1] === undefined) throw new Error(`unknown or incomplete option: ${argv[i]}`);
		opts[key] = argv[i + 1];
	}
	for (const [flag, key] of Object.entries(keys)) {
		if (!opts[key]) throw new Error(`${flag} <file> is required`);
	}
	return opts;
}

/** `kind:id` with the id as a number, so `0x1b` and `27` are the same entry. */
function entryKey(kind, id) {
	return `${kind}:${Number(id)}`;
}

/** The entries of a strings.conf, in file order: key → { line, text }. */
export function parseEntries(text) {
	const entries = new Map();
	for (const line of text.split(/\r?\n/)) {
		const match = ENTRY.exec(line.trim());
		if (!match || Number.isNaN(Number(match[2]))) continue;
		entries.set(entryKey(match[1], match[2]), { line: line.trim(), text: match[3] });
	}
	return entries;
}

function placeholders(text) {
	return (text.match(PLACEHOLDER) ?? []).sort().join(" ");
}

/**
 * The lines of `fill` that complete `base`: entries the base lacks, that the
 * reference defines, with the placeholders the reference has. In the order
 * of the fill file.
 */
export function missingEntries(base, fill, reference) {
	const lines = [];
	for (const [key, entry] of fill) {
		const known = reference.get(key);
		if (base.has(key) || !known) continue;
		if (placeholders(entry.text) !== placeholders(known.text)) continue;
		lines.push(entry.line);
	}
	return lines;
}

export function fillStrings(baseText, fillText, referenceText) {
	const lines = missingEntries(parseEntries(baseText), parseEntries(fillText), parseEntries(referenceText));
	if (lines.length === 0) return { text: baseText, added: 0 };
	const separator = baseText.endsWith("\n") ? "" : "\n";
	return { text: `${baseText}${separator}${lines.join("\n")}\n`, added: lines.length };
}

function main() {
	const opts = parseArgs(process.argv.slice(2));
	const read = (path) => readFileSync(path, "utf8");
	const { text, added } = fillStrings(read(opts.base), read(opts.fill), read(opts.reference));
	writeFileSync(opts.out, text);
	process.stdout.write(`${opts.out}: ${added} entries added to the base file\n`);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) main();

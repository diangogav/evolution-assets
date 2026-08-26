// Reads rush/sets.md — upstream's table mapping each card-id block to the set it
// was printed in — and turns a ygopro card id into the print codes that identify
// the card outside this pack.
//
// A Rush id is `120` + a three-digit set block + the card's number inside that
// set, so 120281007 is card 007 of whichever set claims block 120281. That is the
// only bridge from an id to a card's identity: nothing in the cdb carries a print
// code, and Yugipedia indexes Rush cards by print code.
//
// One block can name more than one set — a card number reused across two packs
// released the same day — so a lookup yields candidates rather than an answer.
// Resolving them is the caller's job: only one candidate exists in the set lists.

/** `(RD/B221-JP)`, `(RD/5THS-JPA)` or a bare `(RD/VC24)`. */
const SET_RE = /\(RD\/([A-Za-z0-9]+)(?:-([A-Za-z]+))?\)/g;
const BLOCK_RE = /`(120\d{3})XXX`/;

/**
 * Parse the whole file into `{ '120281': [{ set, region }] }`.
 *
 * Lines vary in punctuation across five years of edits, so a line is read by
 * picking out its two meaningful tokens rather than by matching a line shape.
 * Repeats of the same set collapse; genuinely different sets are both kept.
 */
export function parseSetBlocks(text) {
	const blocks = {};

	for (const line of text.split("\n")) {
		const block = BLOCK_RE.exec(line);
		if (!block) continue;

		const candidates = (blocks[block[1]] ??= []);
		for (const [, set, region] of line.matchAll(SET_RE)) {
			const entry = { set: `RD/${set}`, region: region ?? "JP" };
			const seen = candidates.some((c) => c.set === entry.set && c.region === entry.region);
			if (!seen) candidates.push(entry);
		}
	}

	return blocks;
}

/** The print codes a ygopro id could carry, in the order the sets were declared. */
export function printCodeCandidates(cardId, blocks) {
	const id = String(cardId);
	const number = id.slice(6);
	return (blocks[id.slice(0, 6)] ?? []).map(({ set, region }) => `${set}-${region}${number}`);
}

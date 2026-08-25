import * as cheerio from "cheerio";

const POST_URL_PATTERN = /https:\/\/yugiohblog\.konami\.com\/\d{4}\/genesys\/[^/"'\s]+\//g;

/**
 * Extracts Genesys post URLs (`/<year>/genesys/<slug>/`) from a blog page,
 * deduplicated in document order. Category, tag, and other-section links do
 * not match.
 *
 * @param {string} html
 * @returns {string[]}
 */
export function extractGenesysPostUrls(html) {
	return [...new Set(html.match(POST_URL_PATTERN) ?? [])];
}

// Adjustment lines carry the previous cost: `Name OLD->NEW` (no space between
// the old cost and the arrow, e.g. `D.D. Crow 1->2`). The old cost must be a
// standalone number, so trailing digits inside a name (`... LV10 -> 7`) never
// match. New-card lines are `Name -> N` with no old cost.
const ADJUSTMENT_LINE = /^(.+?)\s+(\d+)\s*->\s*(\d+)$/;
const NEW_CARD_LINE = /^(.+?)\s*->\s*(\d+)$/;

/**
 * Parses a Konami blog post into point deltas. Point lines live in paragraph
 * blocks separated by `<br>`; prose lines in the same paragraph are ignored.
 * `oldPoints` is null for new-card lines that carry no previous cost.
 *
 * @param {string} html
 * @returns {Array<{ name: string, oldPoints: number | null, newPoints: number }>}
 */
export function parseGenesysBlogPost(html) {
	const $ = cheerio.load(html.replace(/<br\s*\/?>/gi, "\n"));
	const deltas = [];

	$("p").each((_, el) => {
		for (const raw of $(el).text().split("\n")) {
			const line = raw.trim();
			const adjustment = line.match(ADJUSTMENT_LINE);

			if (adjustment) {
				deltas.push({
					name: adjustment[1].trim(),
					oldPoints: Number(adjustment[2]),
					newPoints: Number(adjustment[3]),
				});
				continue;
			}

			const fresh = line.match(NEW_CARD_LINE);

			if (fresh) {
				deltas.push({ name: fresh[1].trim(), oldPoints: null, newPoints: Number(fresh[2]) });
			}
		}
	});

	return deltas;
}

/**
 * Applies pending blog deltas on top of the table-scraped base list. The table
 * stays the source of truth: a delta only applies while the table has not
 * caught up, and conflicts (the table holds a value the delta does not
 * expect) always resolve in the table's favor. A post whose deltas have all
 * converged is marked `spent` in the returned state.
 *
 * Neither input is mutated.
 *
 * @param {Array<{ name: string, points: number, code: number }>} baseCards
 * @param {Array<{ url: string, status: string, deltas: Array<{ name: string, code: number | null, oldPoints: number | null, newPoints: number }> }>} stateEntries
 * @returns {{ cards: typeof baseCards, state: typeof stateEntries, conflicts: object[], applied: object[] }}
 */
export function applyBlogDeltas(baseCards, stateEntries) {
	const cards = baseCards.map((card) => ({ ...card }));
	const byCode = new Map(cards.map((card) => [card.code, card]));
	const conflicts = [];
	const applied = [];

	const state = stateEntries.map((entry) => {
		const copy = { ...entry, deltas: (entry.deltas ?? []).map((delta) => ({ ...delta })) };

		if (copy.status !== "pending") {
			return copy;
		}

		let allConverged = true;

		for (const delta of copy.deltas) {
			// Unresolved names can never be applied nor converge; they are inert.
			if (delta.code == null) {
				continue;
			}

			const base = byCode.get(delta.code);

			if (base === undefined) {
				// Zero-cost cards are unlisted by design, so absence already is
				// convergence for a zero-point delta.
				if (delta.newPoints === 0) {
					continue;
				}

				const card = { name: delta.name, points: delta.newPoints, code: delta.code };
				cards.push(card);
				byCode.set(delta.code, card);
				applied.push({ url: copy.url, ...delta });
				allConverged = false;
				continue;
			}

			if (base.points === delta.newPoints) {
				continue;
			}

			if (delta.oldPoints != null && base.points === delta.oldPoints) {
				base.points = delta.newPoints;
				applied.push({ url: copy.url, ...delta });
				allConverged = false;
				continue;
			}

			conflicts.push({
				url: copy.url,
				name: delta.name,
				code: delta.code,
				basePoints: base.points,
				oldPoints: delta.oldPoints,
				newPoints: delta.newPoints,
			});
		}

		return { ...copy, status: allConverged ? "spent" : "pending" };
	});

	return { cards, state, conflicts, applied };
}

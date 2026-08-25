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

/**
 * Extracts a post's publication date. The blog's theme stores the human date
 * in the `itemprop` attribute of the entry-date tag
 * (`<time itemprop="August 24, 2026" class="entry-date">`).
 *
 * @param {string} html
 * @returns {string | null} `YYYY-MM-DD`, or null when missing/unparseable
 */
export function extractPostDate(html) {
	const $ = cheerio.load(html);
	const raw = $("time.entry-date").attr("itemprop");
	const parsed = raw === undefined ? NaN : Date.parse(raw);

	if (Number.isNaN(parsed)) {
		return null;
	}

	// Format from local date components: the source carries a plain calendar
	// date, so a UTC round-trip could shift it by a day.
	const date = new Date(parsed);
	const pad = (part) => String(part).padStart(2, "0");

	return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
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

// How long a post may add table-absent cards. Past this window, absence means
// Konami removed the points, not that the table is lagging.
const FRESH_WINDOW_MS = 30 * 24 * 60 * 60 * 1000;

/**
 * Applies pending blog deltas on top of the table-scraped base list. The table
 * stays the source of truth: a delta only applies while the table has not
 * caught up, and conflicts (the table holds a value the delta does not
 * expect) always resolve in the table's favor. A post whose deltas have all
 * converged is marked `spent` in the returned state.
 *
 * Cards absent from the table are only added while the post is fresh
 * (`publishedAt` within 30 days of `now`); for older or undated posts,
 * absence means the points were since removed and counts as convergence.
 *
 * Newer posts supersede older ones per card: Konami republishes a card's cost
 * in later updates (including removals to 0), so only the most recently
 * published delta for each card may act — earlier ones count as converged,
 * even when the newer post is already spent. A card whose value was applied
 * from a post carries that post's URL as `sourceUrl`.
 *
 * Neither input is mutated.
 *
 * @param {Array<{ name: string, points: number, code: number }>} baseCards
 * @param {Array<{ url: string, status: string, publishedAt?: string | null, deltas: Array<{ name: string, code: number | null, oldPoints: number | null, newPoints: number }> }>} stateEntries
 * @param {{ now?: number }} [options] epoch ms used for the freshness rule
 * @returns {{ cards: typeof baseCards, state: typeof stateEntries, conflicts: object[], applied: object[] }}
 */
export function applyBlogDeltas(baseCards, stateEntries, { now } = {}) {
	const cards = baseCards.map((card) => ({ ...card }));
	const byCode = new Map(cards.map((card) => [card.code, card]));
	const conflicts = [];
	const applied = [];

	const state = stateEntries.map((entry) => ({
		...entry,
		deltas: (entry.deltas ?? []).map((delta) => ({ ...delta })),
	}));

	// The latest published delta wins each card (missing dates rank lowest,
	// ties break toward later array position). Built over every entry with
	// deltas, whatever its status: a spent newer post still supersedes.
	const winners = new Map(); // code → { rank, index, delta }

	state.forEach((entry, index) => {
		const publishedMs = entry.publishedAt == null ? NaN : Date.parse(entry.publishedAt);
		const rank = Number.isNaN(publishedMs) ? -Infinity : publishedMs;

		for (const delta of entry.deltas) {
			if (delta.code == null) {
				continue;
			}

			const current = winners.get(delta.code);

			if (
				current === undefined ||
				rank > current.rank ||
				(rank === current.rank && index > current.index)
			) {
				winners.set(delta.code, { rank, index, delta });
			}
		}
	});

	for (const entry of state) {
		if (entry.status !== "pending") {
			continue;
		}

		const publishedMs = entry.publishedAt == null ? NaN : Date.parse(entry.publishedAt);
		const fresh =
			Number.isFinite(now) && !Number.isNaN(publishedMs) && now - publishedMs <= FRESH_WINDOW_MS;

		let allConverged = true;

		for (const delta of entry.deltas) {
			// Unresolved names can never be applied nor converge; they are inert.
			if (delta.code == null) {
				continue;
			}

			// A newer post republished this card's cost; this older delta is
			// superseded and counts as converged.
			if (winners.get(delta.code).delta !== delta) {
				continue;
			}

			const base = byCode.get(delta.code);

			if (base === undefined) {
				// Zero-cost cards are unlisted by design, so absence already is
				// convergence for a zero-point delta.
				if (delta.newPoints === 0) {
					continue;
				}

				// A stale (or undated) post can no longer explain absence as table
				// lag: the points were removed since. Converged.
				if (!fresh) {
					continue;
				}

				const card = {
					name: delta.name,
					points: delta.newPoints,
					code: delta.code,
					sourceUrl: entry.url,
				};
				cards.push(card);
				byCode.set(delta.code, card);
				applied.push({ url: entry.url, ...delta });
				allConverged = false;
				continue;
			}

			if (base.points === delta.newPoints) {
				continue;
			}

			if (delta.oldPoints != null && base.points === delta.oldPoints) {
				base.points = delta.newPoints;
				base.sourceUrl = entry.url;
				applied.push({ url: entry.url, ...delta });
				allConverged = false;
				continue;
			}

			conflicts.push({
				url: entry.url,
				name: delta.name,
				code: delta.code,
				basePoints: base.points,
				oldPoints: delta.oldPoints,
				newPoints: delta.newPoints,
			});
		}

		entry.status = allConverged ? "spent" : "pending";
	}

	return { cards, state, conflicts, applied };
}

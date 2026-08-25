const HEADER = "#[Genesys]\n!Genesys";

/**
 * Renders a Genesys point list as an EDOPro lflist.conf using the three-column
 * format `<code> <max copies> <points>`. Every Genesys card allows the standard
 * 3 copies, so the middle column is always 3; the point cost lives in the third
 * column. Unlisted cards mean zero points, so zero/negative entries are dropped.
 * The trailing `--name` is a human-readable comment ignored by the parser; a
 * card whose value came from a blog post ahead of the official table carries
 * that post's URL after the name (`--name | url`).
 *
 * @param {Array<{ code: number, points: number, name: string, sourceUrl?: string }>} cards
 * @returns {string}
 */
export function formatGenesysLflist(cards) {
	const lines = cards
		.filter((card) => card.points > 0)
		.sort((a, b) => a.code - b.code)
		.map((card) => {
			const line = `${card.code} 3 ${card.points} --${card.name}`;

			return card.sourceUrl === undefined ? line : `${line} | ${card.sourceUrl}`;
		});

	return `${HEADER}\n${lines.join("\n")}\n`;
}

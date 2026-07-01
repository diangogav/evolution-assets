const HEADER = "#[Genesys]\n!Genesys";

/**
 * Renders a Genesys point list as an EDOPro lflist.conf using the three-column
 * format `<code> <max copies> <points>`. Every Genesys card allows the standard
 * 3 copies, so the middle column is always 3; the point cost lives in the third
 * column. Unlisted cards mean zero points, so zero/negative entries are dropped.
 * The trailing `--name` is a human-readable comment ignored by the parser.
 *
 * @param {Array<{ code: number, points: number, name: string }>} cards
 * @returns {string}
 */
export function formatGenesysLflist(cards) {
	const lines = cards
		.filter((card) => card.points > 0)
		.sort((a, b) => a.code - b.code)
		.map((card) => `${card.code} 3 ${card.points} --${card.name}`);

	return `${HEADER}\n${lines.join("\n")}\n`;
}

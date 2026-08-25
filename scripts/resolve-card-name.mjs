/**
 * Name-level fixes for cards that Konami's Genesys sources render differently
 * from the card database: preliminary blog translations, the table's lossy
 * typography (Ω → O), and one cell served as Latin-1 bytes inside a UTF-8
 * page. Lookups run on normalized names so the table and blog variants of the
 * same name share one entry.
 */

/**
 * Normalizes a scraped card name: trims, collapses whitespace, and replaces
 * en/em dashes with the plain hyphen the card database uses.
 *
 * @param {string} name
 * @returns {string}
 */
export function normalizeCardName(name) {
	return name.replace(/[–—]/g, "-").replace(/\s+/g, " ").trim();
}

// Keys are normalized names as the Genesys table/blog renders them; values are
// card database ids. The comment on each entry is the database name.
const CARD_NAME_OVERRIDES = new Map([
	// Hamon, Lord of Striking Thunder - Sacred Beast of Sinful Catastrophe
	["Calamity of the Sacred Beasts - Hamon, Lord of Striking Thunder", 50251045],
	// Raviel, Lord of Phantasms - Sacred Beast of Endless Eternity
	["Infinity of the Sacred Beasts - Raviel, Lord of Phantasms", 96345184],
	// Exstellarknight Constellar Ptolemy Ω7 (the table flattens Ω to O)
	["Exstellarknight Constellar Ptolemy O7", 6195332],
	// K9-ØØ Lupis (the table serves the ØØ as Latin-1, decoded as U+FFFD)
	["K9-�� Lupis", 91025875],
	// Stellarnova Bonds
	["Stellarnova Binding", 69678646],
	// The Three Brave Swordsouls
	["The Three Champions of Swordsoul", 74405783],
]);

/**
 * Returns the card id for a scraped name with a known override, or null when
 * the name should be resolved through the card database instead.
 *
 * @param {string} name
 * @returns {number | null}
 */
export function overrideCardCode(name) {
	return CARD_NAME_OVERRIDES.get(normalizeCardName(name)) ?? null;
}

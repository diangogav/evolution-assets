/**
 * Name-level fixes for cards that Konami's Genesys sources render differently
 * from the card database: preliminary blog translations, the table's lossy
 * typography (Ω → O), and one cell served as Latin-1 bytes inside a UTF-8
 * page. Lookups run on normalized names so the table and blog variants of the
 * same name share one entry.
 */

/**
 * Normalizes a scraped card name: trims, collapses whitespace, and replaces
 * en/em dashes and curly quotes with the plain ASCII forms the card database
 * uses.
 *
 * @param {string} name
 * @returns {string}
 */
export function normalizeCardName(name) {
	return name
		.replace(/[’‘]/g, "'")
		.replace(/[“”]/g, '"')
		.replace(/[–—]/g, "-")
		.replace(/\s+/g, " ")
		.trim();
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
	// Nibiru, the Primal Being (the blog drops the comma)
	["Nibiru the Primal Being", 27204311],
	// Union Hangar (blog typo)
	["Union Hanger", 66399653],
	// Sky Striker Mobilize - Engage! (the blog drops the exclamation mark)
	["Sky Striker Mobilize - Engage", 63166095],
	// Blitzclique - Breakaway (the blog drops the dash)
	["Blitzclique Breakaway", 64049762],
	// Clown Crew Matinee Operatics (blog typo)
	["Clown Crew Matinee Operactics", 57847269],
	// Magicians' Souls (apostrophe placement)
	["Magician's Souls", 97631303],
	// Artmage Vandalism -Assault- (the blog spaces the inner dashes)
	["Artmage Vandalism - Assault -", 1122030],
	// Artmage Varnish -Alteration- (the blog spaces the inner dashes)
	["Artmage Varnish - Alteration -", 74011784],
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

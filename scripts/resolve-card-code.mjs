/**
 * Card id lookup against the YGOPRODeck API.
 *
 * A network failure and a card the API does not know are different facts and
 * must stay distinguishable: the first is retried and finally surfaced as
 * `CardLookupUnavailableError`, the second returns `null`. Treating both as
 * `null` once made the generator silently drop table rows on a transient
 * ECONNRESET (commit 4113fff).
 */

const API_URL = "https://db.ygoprodeck.com/api/v7/cardinfo.php?name=";
const DEFAULT_RETRIES = 3;
const DEFAULT_DELAY_MS = 500;

export class CardLookupUnavailableError extends Error {
	constructor(name, cause) {
		super(`Card lookup unavailable for ${name}: ${cause?.message ?? cause}`);
		this.name = "CardLookupUnavailableError";
		this.cause = cause;
		this.cardName = name;
	}
}

const defaultSleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

/**
 * @param {string} name
 * @param {{ fetch?: typeof fetch, retries?: number, delayMs?: number, sleep?: (ms: number) => Promise<void> }} [options]
 * @returns {Promise<number | null>} the card id, or null when the API knows no such card
 * @throws {CardLookupUnavailableError} when every attempt failed on transport
 */
export async function fetchCardId(
	name,
	{ fetch: doFetch = fetch, retries = DEFAULT_RETRIES, delayMs = DEFAULT_DELAY_MS, sleep = defaultSleep } = {},
) {
	let lastError;

	for (let attempt = 1; attempt <= retries; attempt += 1) {
		try {
			const response = await doFetch(`${API_URL}${encodeURIComponent(name)}`);
			const { data } = await response.json();

			return data?.[0]?.id ?? null;
		} catch (error) {
			lastError = error;

			if (attempt < retries) {
				await sleep(delayMs * 2 ** (attempt - 1));
			}
		}
	}

	throw new CardLookupUnavailableError(name, lastError);
}

/**
 * Reads `code 3 points --name [| url]` lines from a previously generated list
 * so a card whose lookup is temporarily unavailable can keep its known code.
 *
 * @param {string} text
 * @returns {Map<string, number>} name → code
 */
export function parsePreviousCodes(text) {
	const codes = new Map();

	for (const line of text.split("\n")) {
		const match = line.match(/^(\d+) 3 \d+ --(.+?)(?: \| \S+)?$/);

		if (match) {
			codes.set(match[2], Number(match[1]));
		}
	}

	return codes;
}

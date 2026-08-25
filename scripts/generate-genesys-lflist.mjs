import { readFile, writeFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

import * as cheerio from "cheerio";

import { formatGenesysLflist } from "./format-genesys-lflist.mjs";
import {
	applyBlogDeltas,
	extractGenesysPostUrls,
	extractPostDate,
	parseGenesysBlogPost,
} from "./parse-genesys-blog.mjs";
import { normalizeCardName, overrideCardCode } from "./resolve-card-name.mjs";

const __dirname = dirname(fileURLToPath(import.meta.url));
const OUTPUT_PATH = join(__dirname, "..", "lflist", "genesys.lflist.conf");
const STATE_PATH = join(__dirname, "..", "lflist", "genesys-blog-state.json");

const SOURCE_URL = "https://www.yugioh-card.com/en/genesys/";
const BLOG_CATEGORY_URL = "https://yugiohblog.konami.com/category/genesys/";

async function fetchCardId(name) {
	const apiUrl = `https://db.ygoprodeck.com/api/v7/cardinfo.php?name=${encodeURIComponent(name)}`;

	try {
		const response = await fetch(apiUrl);
		const { data } = await response.json();

		return data?.[0]?.id ?? null;
	} catch (error) {
		console.error(`Error fetching card info for ${name}:`, error);

		return null;
	}
}

// Konami's sources typeset some names differently from the card database
// (en dashes, preliminary translations, mangled characters). Check the
// override table first, then the database, then the hyphen-normalized form.
async function resolveCardCode(name) {
	const override = overrideCardCode(name);

	if (override !== null) {
		return override;
	}

	const code = await fetchCardId(name);

	if (code !== null) {
		return code;
	}

	const normalized = normalizeCardName(name);

	return normalized === name ? null : fetchCardId(normalized);
}

async function readBlogState() {
	try {
		const state = JSON.parse(await readFile(STATE_PATH, "utf-8"));

		return Array.isArray(state.posts) ? state : { posts: [] };
	} catch {
		return { posts: [] };
	}
}

// Discovers new posts on the blog's genesys category page and parses their
// point deltas into the state. Already-seen URLs are never refetched, except
// to backfill a missing publication date on a still-pending entry.
async function syncBlogState(state) {
	const html = await fetch(BLOG_CATEGORY_URL).then((response) => response.text());
	const known = new Set(state.posts.map((post) => post.url));

	for (const url of extractGenesysPostUrls(html)) {
		if (known.has(url)) {
			continue;
		}

		console.log(`New blog post: ${url}`);
		const postHtml = await fetch(url).then((response) => response.text());
		const publishedAt = extractPostDate(postHtml);
		const parsed = parseGenesysBlogPost(postHtml);

		if (parsed.length === 0) {
			state.posts.push({ url, status: "no-deltas", publishedAt, deltas: [] });
			continue;
		}

		const deltas = [];

		for (const delta of parsed) {
			const code = await resolveCardCode(delta.name);

			if (code === null) {
				console.warn(`Blog card not found in API: ${delta.name}`);
			}

			deltas.push({ ...delta, code });
		}

		state.posts.push({ url, status: "pending", publishedAt, deltas });
	}

	await healPendingPosts(state);

	return state;
}

// Self-heals pending entries persisted by earlier runs: backfills publication
// dates recorded before the freshness rule existed, and retries card names
// that failed to resolve (typos fixed by new overrides, or cards the database
// has added since).
async function healPendingPosts(state) {
	for (const post of state.posts) {
		if (post.status !== "pending") {
			continue;
		}

		// A key that is absent was never extracted; a stored null means the
		// page was already checked and carries no usable date.
		if (!("publishedAt" in post)) {
			const postHtml = await fetch(post.url).then((response) => response.text());
			post.publishedAt = extractPostDate(postHtml);
			console.log(`Backfilled publication date for ${post.url}: ${post.publishedAt}`);
		}

		for (const delta of post.deltas) {
			if (delta.code !== null) {
				continue;
			}

			const code = await resolveCardCode(delta.name);

			if (code !== null) {
				delta.code = code;
				console.log(`Recovered card id for ${delta.name}: ${code}`);
			}
		}
	}
}

// Overlays pending blog deltas on the table-scraped list. The table stays the
// source of truth; any failure here falls back to the table-only list so the
// blog can never break generation.
async function applyBlogOverlay(cards) {
	try {
		const state = await syncBlogState(await readBlogState());
		const { cards: merged, state: posts, conflicts, applied } = applyBlogDeltas(cards, state.posts, {
			now: Date.now(),
		});

		for (const delta of applied) {
			console.log(`Blog delta applied: ${delta.name} -> ${delta.newPoints} (${delta.url})`);
		}
		for (const conflict of conflicts) {
			console.warn(
				`Blog delta conflict (table wins): ${conflict.name} table=${conflict.basePoints} post=${conflict.oldPoints}->${conflict.newPoints} (${conflict.url})`,
			);
		}
		for (const [index, post] of posts.entries()) {
			if (post.status === "spent" && state.posts[index].status !== "spent") {
				console.log(`Blog post fully converged with the table: ${post.url}`);
			}
		}

		await writeFile(STATE_PATH, `${JSON.stringify({ posts }, null, 2)}\n`);

		return merged;
	} catch (error) {
		console.warn("Blog overlay failed; falling back to the table-only list:", error);

		return cards;
	}
}

async function generate() {
	console.log("Starting Genesys lflist generation...");

	const html = await fetch(SOURCE_URL).then((response) => response.text());
	const $ = cheerio.load(html);
	const rows = $("#tablepress-genesys tbody tr").toArray();

	const cards = [];
	const notFound = [];

	for (const el of rows) {
		const name = $(el).find("td.column-1").text().trim();
		const points = Number($(el).find("td.column-2").text().trim()) || 0;

		if (!name) {
			continue;
		}

		const code = await resolveCardCode(name);

		if (code === null) {
			console.error(`Card not found in API: ${name}`);
			notFound.push(name);
			continue;
		}

		cards.push({ name, points, code });
	}

	if (cards.length === 0) {
		throw new Error("Scrape produced no cards — refusing to overwrite the list with an empty file.");
	}

	const merged = await applyBlogOverlay(cards);

	await writeFile(OUTPUT_PATH, formatGenesysLflist(merged), "utf-8");

	const pointed = merged.filter((card) => card.points > 0).length;
	console.log(`Wrote ${pointed} pointed cards to ${OUTPUT_PATH}`);
	if (notFound.length > 0) {
		console.warn(`${notFound.length} cards could not be resolved: ${notFound.join(", ")}`);
	}
}

generate()
	.then(() => console.log("Genesys lflist generation finished."))
	.catch((error) => {
		console.error("Genesys lflist generation failed:", error);
		process.exitCode = 1;
	});

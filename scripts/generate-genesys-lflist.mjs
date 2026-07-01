import { writeFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

import * as cheerio from "cheerio";

import { formatGenesysLflist } from "./format-genesys-lflist.mjs";

const __dirname = dirname(fileURLToPath(import.meta.url));
const OUTPUT_PATH = join(__dirname, "..", "lflist", "genesys.lflist.conf");

const SOURCE_URL = "https://www.yugioh-card.com/en/genesys/";

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

		const code = await fetchCardId(name);

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

	await writeFile(OUTPUT_PATH, formatGenesysLflist(cards), "utf-8");

	const pointed = cards.filter((card) => card.points > 0).length;
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

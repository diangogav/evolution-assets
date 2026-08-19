// Builds the MDPro3 client pack: the data-only patch that lets MDPro3 players
// join our Edison rooms and see the pre-errata pool correctly.
//
// Data only, on purpose. Card behaviour is resolved entirely on our server, so
// an outside client needs nothing but display and deck-building data. The pack
// is therefore inert on any other server and offline.
//
// The cdb is NOT cosmetic: the server matches decks by code, so a legal Edison
// deck must literally contain 910003001, and a client whose database does not
// know that code cannot even add the card in its deck editor.
//
// MDPro3 ONLY, deliberately. Classic YGOPro (Fluorohydride) and YGOMobile
// (cn-ko-en) were both checked against their sources and neither supports the
// `$whitelist` directive — `deck_manager.cpp` also drops every `count > 2` line,
// which is 3539 of our 3671 entries. On those clients the Edison list collapses
// to 132 forbidden/limited/semi restrictions and the pool gate disappears, so a
// pack would let players build decks the server then rejects. That is a client
// limitation no data we ship can fix. MDPro3 supports `$whitelist`
// (`BanlistManager.cs` -> `Banlist.EnableWhitelistMode()`), so it is the one
// client that enforces the pool the way our server does.
//
// One pack per language: a client merges every database it finds, so a single
// archive carrying both languages would have them overwrite each other in load
// order. The ~2 MB of duplicated art is the cheaper problem.
//
// usage: node scripts/build-client-pack.mjs <lang> [outDir] [packUrl]

import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { mkdirSync, readFileSync, rmSync, statSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";

const DEFAULT_CDN = "https://evolution-card-cdn.evolution-game-engine.workers.dev/pics";

// The pool's art is the official art — an errata rewrites text, never the
// illustration — so in a deck laid out as ~60px thumbnails a pre-errata copy is
// indistinguishable from the modern printing it replaces. The "(Pre-Errata)"
// suffix only shows once a card is selected, which is too late to notice you
// built with the wrong one.
//
// A border is the marker that survives that size: it covers no name, art, text
// or ATK/DEF, and carries no words, so the same treatment serves every language
// pack.
// The client renders a card from its ILLUSTRATION, not from the full card
// image. With no art/ entry it falls back to pics/ and crops to the art window
// itself, so a bar at the foot of the card or a border around it is discarded
// before anything reaches the screen — which is exactly what happened to the
// first two attempts. Shipping the crop ourselves under art/ skips that step and
// keeps whatever we drew on it.
//
// Geometry transcribed from CardImageLoader.GetArtFromCard. Its width/height
// arguments are END coordinates, not sizes, and Unity textures put the origin at
// the bottom left — so x runs 13%..87%, and y 30%..81% from the bottom is
// 19%..70% from the top.
const ART_CROP = { left: 0.13, top: 0.19, width: 0.74, height: 0.51 };

export function artCropBox(imageWidth, imageHeight) {
	return {
		x: Math.round(imageWidth * ART_CROP.left),
		y: Math.round(imageHeight * ART_CROP.top),
		width: Math.round(imageWidth * ART_CROP.width),
		height: Math.round(imageHeight * ART_CROP.height),
	};
}

// A gold frame around the illustration. Everything else tried was worse for a
// reason worth keeping written down:
//
//   - a bar at the foot of the card, or a border around it, never rendered at
//     all — the client crops to the art window before drawing, so both fell
//     outside the picture (see ART_CROP);
//   - a stripe across the art reads well but hides a slice of the subject;
//   - tinting the whole illustration hides nothing, and costs more: the pool
//     stops being distinguishable BY COLOUR from itself. Necrovalley is no
//     longer the orange one and Honest no longer the blue one.
//
// The frame touches only the perimeter, so palette, subject and silhouette all
// survive — a player still recognises the card at a glance and still sees that
// it is not the modern printing.
const MARK_COLOR = "#d4af37";

// Proportional to the crop: the mirrors return a mix of resolutions, and fixed
// pixels would put a hairline on one card and a slab on the next.
export function markFrameWidth(artWidth) {
	return Math.max(6, Math.round(artWidth * 0.054));
}

/** Crops one card image to its illustration and frames it. */
function renderMarkedArt(picFile, artFile) {
	const [width, height] = execFileSync("magick", ["identify", "-format", "%w %h", picFile], {
		encoding: "utf8",
	})
		.trim()
		.split(" ")
		.map(Number);

	const box = artCropBox(width, height);
	const frame = markFrameWidth(box.width);

	// Shaved before the border is drawn, so the art keeps the dimensions the
	// client expects from a crop of this card rather than growing by the frame.
	execFileSync("magick", [
		picFile,
		"-crop",
		`${box.width}x${box.height}+${box.x}+${box.y}`,
		"+repage",
		"-shave",
		`${frame}x${frame}`,
		"-bordercolor",
		MARK_COLOR,
		"-border",
		String(frame),
		artFile,
	]);
}

/**
 * Writes the marked illustration for every card already downloaded to picsDir.
 * Kept separate from the download so the network step stays retry-safe and the
 * tests can stub the renderer.
 */
export async function renderPackArt(codes, picsDir, artDir, { renderImpl = renderMarkedArt } = {}) {
	mkdirSync(artDir, { recursive: true });
	for (const code of codes) {
		renderImpl(join(picsDir, `${code}.jpg`), join(artDir, `${code}.jpg`));
	}
	return codes.length;
}

// The address a player pastes into the client's download box. It must be
// PERMANENT: it ends up in Discord posts, pinned messages, and the README of
// every copy already downloaded, so any URL that can change strands all of them.
//
// The tag is a SLOT, not a version — publish an update by replacing the asset in
// place (`gh release upload edison-pack <file> --clobber`), never by cutting a
// new tag. `/releases/latest/download/` would have been the obvious choice and is
// wrong: it resolves to whatever release in the repo is newest, so an unrelated
// release would break every link already published.
//
// It also ends clean in `.ypk` with no query string, which the client requires
// twice over: its installer validates the extension, and it names the saved file
// after the URL.
const PACK_URL_BASE = "https://github.com/diangogav/evolution-assets/releases/download/edison-pack";

export function packUrlFor(lang) {
	return `${PACK_URL_BASE}/evolution-edison-${lang}${packLayout().archiveExtension}`;
}
const LFLIST_SRC = "lflist/edison.lflist.conf";

// The pool ships as ONE archive that MDPro3 mounts. Its `FileGroupConfig.cs`
// declares Expansions = { Paths: ["Expansions/"], Extensions: [".zip", ".ypk"] }
// and CardPicture = { Paths: ["pics/"], Extensions: [".jpg"] } — it reads the
// pool from INSIDE an archive and never as loose files (its own note: "used to
// read card images from expansion packs"). `BanlistManager.Initialize()` picks
// up any entry whose name ends in "lflist.conf" and merges it with the others,
// so the ban list travels in the same archive. Nothing is shipped loose.
//
// Note the capital E in `Expansions/`: ygopro-family clients use a lowercase
// `expansions/`, which matters on a case-sensitive filesystem.
export function packLayout() {
	return {
		// MDPro3 mounts .zip and .ypk alike, but the extension is also a signal to
		// the player: a .zip invites a double-click and an extract, which is the
		// one action that breaks the install. .ypk is the ecosystem's convention
		// for "a pack the client opens, not you".
		archiveExtension: ".ypk",
		cdbName: "evolution-edison.cdb",
		picsDir: "pics",
		// The illustration the client actually renders. pics/ stays as the raw
		// card image; art/ is the crop carrying the mark.
		artDir: "art",
		lflistName: "edison.lflist.conf",
		readmeName: "README.txt",
	};
}

// Pure: the art to fetch for each pool card. Upstream mirrors only know the
// official printing, so we download the ALIAS art and store it under our
// pre-errata code — the client looks art up by the code it is told to render.
// Cards without an alias (a hypothetical original) fall back to their own code.
export function picJobs(rows) {
	const byCode = new Map();
	for (const { id, alias } of rows) {
		if (!byCode.has(id)) byCode.set(id, { code: id, sourceCode: alias || id });
	}
	return [...byCode.values()].sort((a, b) => a.code - b.code);
}

function sqliteQuery(dbPath, sql) {
	return execFileSync("sqlite3", [dbPath, sql], { encoding: "utf8" }).trim();
}

// The (id, alias) pairs of the published pool, in a stable order.
export function readPoolRows(cdbPath) {
	const out = sqliteQuery(cdbPath, "SELECT id, alias FROM datas ORDER BY id;");
	if (!out) return [];
	return out.split("\n").map((line) => {
		const [id, alias] = line.split("|");
		return { id: Number(id), alias: Number(alias) };
	});
}

// Copies the pool into a fresh cdb under the name the pack ships. A straight
// copy today, but it stays a seam: the pack may need to diverge from the
// client-facing overlay (extra rows, stripped columns) without touching the source.
export function buildPackCdb(srcCdb, outCdb) {
	rmSync(outCdb, { force: true });
	const schema = execFileSync("sqlite3", [srcCdb, ".schema"], { encoding: "utf8" });
	execFileSync("sqlite3", [outCdb], { input: schema, encoding: "utf8" });
	sqliteQuery(
		outCdb,
		`ATTACH '${srcCdb}' AS src;` +
			"INSERT OR REPLACE INTO datas SELECT * FROM src.datas;" +
			"INSERT OR REPLACE INTO texts SELECT * FROM src.texts;" +
			"DETACH src;",
	);
	// Alias is an INHERITANCE mechanism: an alternate artwork points at the
	// original so it takes the original's ban list entry, which is why no list
	// ever enumerates the thirty printings of Dark Magician. Our pool needs the
	// opposite. The Edison list carries the pre-errata codes and deliberately
	// omits the official ones, and the client resolves a card's entry through its
	// alias whenever one is set — never through the card's own code. An alias
	// pointing at the official printing therefore resolves to "not listed", which
	// under a whitelist means forbidden, and every card in the pack shows as
	// banned in the deck editor.
	//
	// So the alias is cleared HERE and only here. It stays in
	// cdb/pre-errata.*.cdb, which feeds the server, where it must keep making the
	// pre-errata card the same card for effects and copy limits. The two layers
	// want opposite things from one field and each reads its own database.
	//
	// Nothing is lost client-side: art is served per own code from pics/, and the
	// unified copy count the alias would provide guards a case that cannot occur,
	// because no official printing is on the Edison list to begin with.
	sqliteQuery(outCdb, "UPDATE datas SET alias = 0;");

	// The client reads every column with GetInt64/GetString, with ONE try/catch
	// around the whole read loop: a single NULL throws and silently discards the
	// entire database, so all 28 cards vanish with no error message anywhere.
	// The pre-errata source leaves str1..str16 NULL on cards that have no
	// counter/setname strings, which is valid SQLite and fatal here.
	for (const table of ["datas", "texts"]) {
		const columns = sqliteQuery(outCdb, `PRAGMA table_info(${table});`)
			.split("\n")
			.map((row) => row.split("|")[1])
			.filter((name) => name && name !== "id");
		const fallback = table === "datas" ? "0" : "''";
		const assignments = columns.map((c) => `"${c}" = COALESCE("${c}", ${fallback})`).join(", ");
		if (assignments) sqliteQuery(outCdb, `UPDATE ${table} SET ${assignments};`);
	}

	const cards = Number(sqliteQuery(outCdb, "SELECT count(*) FROM datas;"));
	if (cards === 0) {
		throw new Error(`refusing to publish a pack with no cards (source: ${srcCdb})`);
	}
	return cards;
}

// Fetches every job into `destDir` as `<code>.jpg`. A missing image is a build
// failure, not a warning: a pack that silently ships a card with no art looks
// like OUR bug to the player, on a client we cannot debug.
export async function downloadPics(jobs, destDir, { fetchImpl = fetch, cdnBase = DEFAULT_CDN } = {}) {
	mkdirSync(destDir, { recursive: true });
	for (const { code, sourceCode } of jobs) {
		const url = `${cdnBase}/${sourceCode}.jpg`;
		const response = await fetchImpl(url);
		if (!response.ok) {
			throw new Error(`art for ${code} (alias ${sourceCode}) failed: ${response.status} at ${url}`);
		}
		writeFileSync(join(destDir, `${code}.jpg`), Buffer.from(await response.arrayBuffer()));
	}
	return jobs.length;
}

// Ships inside the zip. English on purpose: the pack goes to players on clients
// whose community language is not ours.
export function renderInstallReadme({ lang, cards, packUrl }) {
	// The in-client download is the path worth leading with: SettingServant's
	// DownloadYPK takes a URL, saves it to Expansions/ under the URL's own file
	// name, and calls InitializeForDataChange() — which re-runs BanlistManager and
	// CardsManager, so the pool is usable without restarting. The manual drop is
	// the fallback for a player who already has the file.
	const install = packUrl
		? [
				"Install",
				"-------",
				"In MDPro3, open Game Settings -> Expansion Packs -> Download Card Pack,",
				"and paste this address:",
				"",
				`  ${packUrl}`,
				"",
				"The pack installs and loads without restarting the client.",
				"",
				"Already downloaded the file instead? Drop it into <MDPro3>/Expansions/.",
			]
		: [
				"Install",
				"-------",
				"Drop this .ypk file into:",
				"",
				"  <MDPro3 folder>/Expansions/",
				"",
				"Then restart MDPro3.",
			];

	return [
		"Evolution — Edison pre-errata pack for MDPro3",
		"=============================================",
		"",
		`${cards} cards, ${lang.toUpperCase()} text.`,
		"",
		"This pack only adds card data, art and the Edison ban list so MDPro3 can",
		"display and build decks with the pre-errata pool. The cards behave",
		"correctly because the rules run on the Evolution server — the pack does",
		"nothing on other servers or offline.",
		"",
		...install,
		"",
		"Pick \"2010.3 Edison\" in the ban list dropdown to build a deck.",
		"",
		"The pre-errata cards carry a \"(Pre-Errata)\" suffix so they are easy to",
		"tell apart from their modern printings. The Edison list only accepts the",
		"pre-errata copy of each card, never the modern printing.",
		"",
		"Other clients",
		"-------------",
		"MDPro3 only, for now. Classic YGOPro and YGOMobile do not support the",
		"whitelist ban lists this format is built on — they ignore the entries that",
		"define the card pool, so their deck editor would happily build decks the",
		"server rejects on join. That is a limitation of those clients, not",
		"something this pack can add.",
	].join("\n");
}

export function sha256File(path) {
	return createHash("sha256").update(readFileSync(path)).digest("hex");
}

export async function buildClientPack(lang, outDir, options = {}) {
	const srcCdb = options.srcCdb ?? `cdb/pre-errata.${lang}.cdb`;
	const layout = packLayout();
	const staging = join(outDir, `staging-${lang}`);
	rmSync(staging, { recursive: true, force: true });
	mkdirSync(staging, { recursive: true });

	const cards = buildPackCdb(srcCdb, join(staging, layout.cdbName));
	const jobs = picJobs(readPoolRows(srcCdb));
	const pics = await downloadPics(jobs, join(staging, layout.picsDir), options);
	await renderPackArt(
		jobs.map((job) => job.code),
		join(staging, layout.picsDir),
		join(staging, layout.artDir),
		options,
	);
	writeFileSync(join(staging, layout.lflistName), readFileSync(options.lflist ?? LFLIST_SRC));
	// MDPro3 only matches the extensions in FileGroupConfig, so a README riding
	// along in the archive is inert — and it is the only place a player who
	// downloaded the file months ago can still read the instructions.
	// `packUrl: null` opts out for a local/test build; omitting it uses the real one.
	const packUrl = options.packUrl === undefined ? packUrlFor(lang) : options.packUrl;
	const readme = renderInstallReadme({ lang, cards, packUrl });
	writeFileSync(join(staging, layout.readmeName), `${readme}\n`);

	const zipPath = join(outDir, `evolution-edison-${lang}${layout.archiveExtension}`);
	rmSync(zipPath, { force: true });
	// -j would flatten pics/ into the root, so zip runs from inside staging — which
	// makes the output path resolve against staging too. Absolute, or a relative
	// outDir silently points somewhere that does not exist.
	execFileSync("zip", ["-qr", resolve(zipPath), "."], { cwd: staging });
	rmSync(staging, { recursive: true, force: true });

	return { lang, cards, pics, zipPath, bytes: statSync(zipPath).size, sha256: sha256File(zipPath) };
}

async function main() {
	const [lang, outDir = "dist", packUrl] = process.argv.slice(2);
	if (!lang) {
		console.error("usage: node scripts/build-client-pack.mjs <lang> [outDir] [packUrl]");
		process.exit(1);
	}
	mkdirSync(outDir, { recursive: true });
	const result = await buildClientPack(lang, outDir, { packUrl });
	console.log(
		`Built ${result.zipPath} — ${result.cards} cards, ${result.pics} pics, ` +
			`${result.bytes} bytes, sha256 ${result.sha256}`,
	);
}

if (process.argv[1]?.endsWith("build-client-pack.mjs")) {
	await main();
}

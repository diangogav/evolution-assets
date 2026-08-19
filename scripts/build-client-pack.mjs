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

// The address a player pastes into MDPro3's "Download Card Pack" box. It must be
// PERMANENT: it ends up in Discord posts, pinned messages, and the README of
// every copy already downloaded, so a per-tag release URL would rot every old
// link on the next publish. GitHub's `/releases/latest/download/` never changes
// and always resolves to the newest release, and it ends clean in `.ypk` — no
// query string, which `Path.GetFileName(url)` would otherwise bake into the
// file name saved under Expansions/.
const PACK_URL_BASE = "https://github.com/diangogav/evolution-assets/releases/latest/download";

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
	const pics = await downloadPics(picJobs(readPoolRows(srcCdb)), join(staging, layout.picsDir), options);
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

// Builds the MDPro3 Rush Duel pack: the data-only overlay that lets MDPro3
// players join our Rush rooms with the right card database and ban list.
//
// Far smaller than the Edison pack (build-client-pack.mjs) because MDPro3
// already has FIRST-CLASS Rush support built for our exact id range —
// Card.IsRushDuelCard() is `Id >= 120000000 && Id < 130000000`, and the client
// carries Rush type/race constants, a Rush card renderer with its own art crop,
// a Maximum ATK box, and a Rush filter in the deck editor. It just never ships
// the card database. So the pack is that database, plus the ban list.
//
// Nothing else is bundled, each for a checked reason:
//   - no card art: MDPro3 applies its OWN Rush art crop, a different geometry
//     from the OCG one the Edison pack draws, so our crop would be wrong on
//     screen — and upstream already publishes the full Rush art .ypk (624 MB).
//   - no Lua scripts: a pack's script/ is only read for Solo, Puzzle, Windbot
//     and replays. Network duels resolve every card on our server.
//
// The archive is MOUNTED by the client, not extracted by the player, and that
// decides the whole layout. SettingServant.DownloadYPK takes a URL, writes the
// downloaded file into Program.PATH_EXPANSIONS UNEXTRACTED, and MDPro3 reads
// the files from inside it — so the payload has to sit flat at the archive
// root, which IS the mount point. The old Data/locales/<lang>/rush_cards.cdb
// slot is outside every directory MDPro3 mounts: a pack shaped that way can
// only ever be installed by hand, and installed by URL its database would land
// nowhere.
//
// usage: node scripts/build-rush-pack.mjs <lang> [outDir] [packUrl]

import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { mkdirSync, readFileSync, rmSync, statSync, utimesSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { gunzipSync } from "node:zlib";

const LFLIST_SRC = "rush/lflist.conf";

// Our variant names to MDPro3's own locale directory names, verified against a
// real install (Data/locales/ also holds de-DE, fr-FR, it-IT, ja-JP, ko-KR,
// pt-PT). The mount reads no locale directory, but the name still says which
// text a pack carries. zh ships too: the base variant is upstream's own Chinese
// text, and MDPro3 ships no Rush database for ANY language, so a Chinese-client
// player is missing it just like an English one. It also needs no Maximum ATK
// line — zh-CN is the one client language whose Rush description parser reads
// upstream's `极大攻击` directly.
export const PACK_LANGS = { en: "en-US", es: "es-ES", zh: "zh-CN" };

// The address a player pastes into the client's download box. It must be
// PERMANENT: it ends up in Discord posts, pinned messages, and the README of
// every copy already downloaded, so any URL that can change strands all of them.
//
// The tag is a SLOT, not a version — publish an update by replacing the asset in
// place (`gh release upload rush-pack <file> --clobber`), never by cutting a new
// tag. `/releases/latest/download/` would have been the obvious choice and is
// wrong: it resolves to whatever release in the repo is newest, so an unrelated
// release would break every link already published.
//
// It also ends clean in `.ypk` with no query string, which the client requires
// twice over: its installer validates the extension, and it names the saved file
// after the URL.
const PACK_URL_BASE = "https://github.com/diangogav/evolution-assets/releases/download/rush-pack";

export function packUrlFor(lang) {
	return `${PACK_URL_BASE}/${packLayout(lang).archiveName}`;
}

// zip stores a modification time per entry, so two builds from identical inputs
// would otherwise differ byte for byte and a republish of an unchanged pack
// would look like a new file. Every staged file is stamped with this instead.
// The value is arbitrary but must stay above the DOS epoch (1980-01-01) that
// the zip format's timestamp field starts at.
const ENTRY_MTIME = new Date("1990-01-01T00:00:00Z");

export function packLayout(lang) {
	const locale = PACK_LANGS[lang];
	if (!locale) {
		throw new Error(`no MDPro3 locale directory for language ${lang}`);
	}
	return {
		// MDPro3 mounts .zip and .ypk alike, but the extension is also a signal to
		// the player: a .zip invites a double-click and an extract, which is the
		// one action that breaks the install. .ypk is the ecosystem's convention
		// for "a pack the client opens, not you".
		archiveExtension: ".ypk",
		locale,
		// There is no rush.zh.cdb.gz — the base variant IS the Chinese one.
		sourceGz: lang === "zh" ? "cdb/rush.cdb.gz" : `cdb/rush.${lang}.cdb.gz`,
		// Flat, no directory part: the archive root is the mount point.
		// CardsManager picks up every .cdb inside a mounted archive, and
		// BanlistManager.Initialize every entry whose name ends in "lflist.conf".
		cdbName: "evolution-rush.cdb",
		// The suffix is the whole contract MDPro3 matches on, which leaves the
		// prefix free — entries from every mounted archive merge into one list, so
		// ours says whose it is rather than taking the bare `lflist.conf` name.
		lflistName: "evolution-rush.lflist.conf",
		readmeName: "README.txt",
		archiveName: `evolution-rush-${lang}.ypk`,
	};
}

// Ships inside the archive. English on purpose, like the Edison pack: it goes
// to players on clients whose community language is not ours.
export function renderInstallReadme({ lang, cards, packUrl }) {
	const { locale, lflistName } = packLayout(lang);

	// The in-client download is the path worth leading with: SettingServant's
	// DownloadYPK takes a URL, saves it to Expansions/ under the URL's own file
	// name, and calls InitializeForDataChange() — which re-runs BanlistManager
	// and CardsManager, so the pack is usable without restarting. The manual drop
	// is the fallback for a player who already has the file.
	// `packUrl: null` opts out for a local/test build.
	const install = packUrl
		? [
				"Install",
				"-------",
				"In MDPro3, open Game Settings -> Expansion Packs -> Download Card Pack,",
				"and paste this address:",
				"",
				`  ${packUrl}`,
				"",
				"That is the whole install — the client downloads the file and reads the",
				"cards straight out of it.",
				"",
				"Already downloaded the file instead? Drop it into <MDPro3>/Expansions/.",
				"Do not unzip it: MDPro3 opens the pack itself, and a pack that has been",
				"extracted is a pack it no longer finds.",
			]
		: [
				"Install",
				"-------",
				"Drop this .ypk file into:",
				"",
				"  <MDPro3 folder>/Expansions/",
				"",
				"Do not unzip it: MDPro3 opens the pack itself, and a pack that has been",
				"extracted is a pack it no longer finds.",
			];

	return [
		"Evolution — Rush Duel pack for MDPro3",
		"=====================================",
		"",
		`${cards} cards, ${lang.toUpperCase()} text (${locale}).`,
		"",
		"MDPro3 already knows how to play Rush Duel: it draws the Rush card frames,",
		"the Maximum ATK box and the Rush filter in the deck editor. What it does",
		"not ship is the card database. This pack is that database, plus our Rush",
		`ban list (${lflistName}).`,
		"",
		...install,
		"",
		"Then restart MDPro3 and pick \"RD\" in the ban list dropdown. You will find",
		"it grouped under Genesys — the client files any list carrying a credit",
		"line there, and the Rush Legend limits are credit lines.",
		"",
		"Install ONE of these packs, not several",
		"---------------------------------------",
		"This file is not extracted into a language folder; the client mounts it and",
		"reads it for every language it runs in. Two of these installed side by side",
		"means the cards come from whichever one the client loaded last, which is",
		"not something you can choose or predict. Pick the language you want and",
		"install that pack only.",
		"",
		"Card art",
		"--------",
		"Not included, and not missing by accident: the whole Rush illustration",
		"set is a 624 MB download, and MDPro3 crops Rush art to its own geometry,",
		"so art cropped by us would be wrong anyway.",
		"",
		"MDPro3 will not fetch it for you — its card-pack downloader only knows",
		"the pre-release set, and it reads card images from disk rather than",
		"per-card from the network. Until you install the art you will see the",
		"cards with a placeholder image; everything else works.",
		"",
		"Upstream publishes the full set here:",
		"",
		"  https://cdn02.moecube.com/ygopro-rush-duel/archive/ygopro-rush-duel-master.ypk",
		"",
		"Required: delete three files from that art pack first",
		"-----------------------------------------------------",
		"That art pack is a zip file, and next to the art it also carries upstream's",
		"own UNTRANSLATED Chinese card databases:",
		"",
		"  RD Alternate.cdb",
		"  RD Patch.cdb",
		"  RD Standard.cdb",
		"",
		"Once both packs sit in Expansions/, MDPro3 loads every database it finds",
		"inside them and, card by card, the last one loaded wins. Which one that is",
		"is not fixed — it depends on the order the client happens to walk the files",
		"in — so left in place those three can overwrite this pack's translated",
		"cards with Chinese text, on one launch and not the next.",
		"",
		"So open ygopro-rush-duel-master.ypk with any zip tool, delete those three",
		".cdb files, save it, and only then drop it into Expansions/. The art lives",
		"in pics/ inside the pack and is not touched by this.",
		"",
		"Legend limits are not enforced in the deck editor",
		"-------------------------------------------------",
		"Rush allows one Legend monster, one Legend Spell and one Legend Trap per",
		"deck. MDPro3 reads all three limits from the ban list but only ever",
		"charges the first one, so its deck editor will happily let you SAVE a deck",
		"with too many Legends.",
		"",
		"The Evolution server checks the real limits when you press Ready, and",
		"rejects the deck there, naming the card at fault. The wording it uses",
		"talks about a forbidden/limited card rather than a Legend — that is the",
		"only message the protocol has. Count your Legends yourself and you will",
		"never see it.",
		"",
		"Hosting a game locally",
		"----------------------",
		"MDPro3's own bundled offline server cannot read a ban list with Legend",
		"entries in it — it stops with an error on those lines. This does NOT",
		"affect joining Evolution rooms: online play sends the list through a",
		"different, working parser. It only matters if you try to host a purely",
		"local game against the bundled server using this ban list.",
	].join("\n");
}

export function sha256File(path) {
	return createHash("sha256").update(readFileSync(path)).digest("hex");
}

/**
 * Assembles the pack for one language into `outDir` and archives it. Returns the
 * archive's manifest — the entries it actually contains, plus its size and digest.
 */
export function buildRushPack(lang, outDir, options = {}) {
	const layout = packLayout(lang);
	const sourceGz = options.sourceGz ?? layout.sourceGz;

	mkdirSync(outDir, { recursive: true });
	const staging = join(outDir, `staging-${lang}`);
	rmSync(staging, { recursive: true, force: true });
	mkdirSync(staging, { recursive: true });

	// The published cdb is gzipped; MDPro3 opens it with SqliteConnection, so it
	// lands decompressed.
	const cdbFile = join(staging, layout.cdbName);
	writeFileSync(cdbFile, gunzipSync(readFileSync(sourceGz)));

	const cards = Number(
		execFileSync("sqlite3", [cdbFile, "SELECT count(*) FROM datas;"], { encoding: "utf8" }).trim(),
	);
	if (cards === 0) {
		rmSync(staging, { recursive: true, force: true });
		throw new Error(`refusing to publish a pack with no cards (source: ${sourceGz})`);
	}

	writeFileSync(join(staging, layout.lflistName), readFileSync(options.lflist ?? LFLIST_SRC));

	// MDPro3 only reads the extensions in FileGroupConfig, so a README riding
	// along inside the archive is inert — and it is the only place a player who
	// downloaded the file months ago can still read the instructions.
	const packUrl = options.packUrl === undefined ? packUrlFor(lang) : options.packUrl;
	writeFileSync(
		join(staging, layout.readmeName),
		`${renderInstallReadme({ lang, cards, packUrl })}\n`,
	);

	const entries = [layout.readmeName, layout.cdbName, layout.lflistName].sort();
	for (const entry of entries) {
		utimesSync(join(staging, entry), ENTRY_MTIME, ENTRY_MTIME);
	}

	const zipPath = join(outDir, layout.archiveName);
	rmSync(zipPath, { force: true });
	// Entries are named one by one, in sorted order, so the archive's own order is
	// fixed rather than whatever order the directory happens to be walked in.
	// -D stores no directory entries (there are none to store, and one would put a
	// folder at the mount point), -X drops the uid/gid and high-resolution
	// timestamp extra fields that would leak the build machine into the bytes, and
	// TZ is pinned because zip writes its timestamps in LOCAL time.
	// zip runs from inside staging, which makes the output path resolve against
	// staging too — hence resolve().
	execFileSync("zip", ["-qXD", resolve(zipPath), ...entries], {
		cwd: staging,
		env: { ...process.env, TZ: "UTC" },
	});
	rmSync(staging, { recursive: true, force: true });

	return {
		lang,
		locale: layout.locale,
		cards,
		entries,
		zipPath,
		bytes: statSync(zipPath).size,
		sha256: sha256File(zipPath),
	};
}

function main() {
	const [lang, outDir = "dist", packUrl] = process.argv.slice(2);
	if (!lang) {
		console.error(
			`usage: node scripts/build-rush-pack.mjs <${Object.keys(PACK_LANGS).join("|")}> [outDir] [packUrl]`,
		);
		process.exit(1);
	}
	const result = buildRushPack(lang, outDir, { packUrl });
	console.log(
		`Built ${result.zipPath} — ${result.cards} cards, ${result.locale}, ` +
			`${result.bytes} bytes, sha256 ${result.sha256}`,
	);
}

if (process.argv[1]?.endsWith("build-rush-pack.mjs")) {
	main();
}

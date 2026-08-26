// Builds the MDPro3 Rush Duel pack: the data-only overlay that lets MDPro3
// players join our Rush rooms with the right card database and ban list.
//
// Far smaller than the Edison pack (build-client-pack.mjs) because MDPro3
// already has FIRST-CLASS Rush support built for our exact id range —
// Card.IsRushDuelCard() is `Id >= 120000000 && Id < 130000000`, and the client
// carries Rush type/race constants, a Rush card renderer with its own art crop,
// a Maximum ATK box, and a Rush filter in the deck editor. It even keeps a
// per-language slot open for the database: TryLoadCardsForLanguage loads
// Data/locales/<lang>/rush_cards.cdb straight after cards.cdb. It just never
// ships that file. So the pack is the file for that slot, plus the ban list.
//
// Nothing else is bundled, each for a checked reason:
//   - no card art: MDPro3 applies its OWN Rush art crop, a different geometry
//     from the OCG one the Edison pack draws, so our crop would be wrong on
//     screen — and upstream already publishes the full Rush art .ypk (624 MB),
//     which the client downloads from its own settings screen.
//   - no Lua scripts: a pack's script/ is only read for Solo, Puzzle, Windbot
//     and replays. Network duels resolve every card on our server.
//
// The archive is a FOLDER OVERLAY the player extracts, not a pack the client
// mounts — hence .zip and not the Edison pack's .ypk. Data/locales/ is outside
// every directory MDPro3 mounts, so the payload cannot ride inside a mounted
// archive, and naming it .ypk would tell the player exactly the wrong thing.
//
// usage: node scripts/build-rush-pack.mjs <lang> [outDir]

import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { mkdirSync, readFileSync, rmSync, statSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { gunzipSync } from "node:zlib";

const LFLIST_SRC = "rush/lflist.conf";

// Our variant names to MDPro3's own locale directory names, verified against a
// real install (Data/locales/ also holds de-DE, fr-FR, it-IT, ja-JP, ko-KR,
// pt-PT). zh ships too: the base variant is upstream's own Chinese text, and
// MDPro3 ships no rush_cards.cdb for ANY language, so a Chinese-client player
// is missing the database just like an English one. It also needs no
// Maximum ATK line — zh-CN is the one client language whose Rush description
// parser reads upstream's `极大攻击` directly.
export const PACK_LANGS = { en: "en-US", es: "es-ES", zh: "zh-CN" };

// The ban list travels LOOSE in Expansions/, so its name is a real filename in
// a directory other packs also write to. BanlistManager.Initialize matches on
// EndsWith("lflist.conf"), which leaves the whole prefix free — so it carries
// ours, and a bare `lflist.conf` (which would also shadow nothing but collide
// with everything) is avoided.
export function lflistFileName() {
	return "evolution-rush.lflist.conf";
}

export function packLayout(lang) {
	const locale = PACK_LANGS[lang];
	if (!locale) {
		throw new Error(`no MDPro3 locale directory for language ${lang}`);
	}
	return {
		archiveExtension: ".zip",
		locale,
		// There is no rush.zh.cdb.gz — the base variant IS the Chinese one.
		sourceGz: lang === "zh" ? "cdb/rush.cdb.gz" : `cdb/rush.${lang}.cdb.gz`,
		cdbPath: `Data/locales/${locale}/rush_cards.cdb`,
		lflistPath: `Expansions/${lflistFileName()}`,
		readmeName: "README.txt",
		archiveName: `evolution-rush-${lang}.zip`,
	};
}

// Ships inside the archive. English on purpose, like the Edison pack: it goes
// to players on clients whose community language is not ours.
export function renderInstallReadme({ lang, cards }) {
	const { locale, cdbPath, lflistPath } = packLayout(lang);

	return [
		"Evolution — Rush Duel pack for MDPro3",
		"=====================================",
		"",
		`${cards} cards, ${lang.toUpperCase()} text, for the ${locale} client.`,
		"",
		"MDPro3 already knows how to play Rush Duel: it draws the Rush card frames,",
		"the Maximum ATK box and the Rush filter in the deck editor. What it does",
		"not ship is the card database — it looks for one in the language folder",
		"and finds nothing. This pack is that file, plus our Rush ban list.",
		"",
		"Install",
		"-------",
		"Extract this archive over your MDPro3 folder, keeping the folder",
		"structure, so the two files land here:",
		"",
		`  <MDPro3 folder>/${cdbPath}`,
		`  <MDPro3 folder>/${lflistPath}`,
		"",
		"Then restart MDPro3 and pick \"RD\" in the ban list dropdown.",
		"",
		`Your client language must be ${locale} — MDPro3 reads the Rush database`,
		"from the folder of the language it is set to, and no other.",
		"",
		"Card art",
		"--------",
		"Not included, and not missing by accident. Upstream publishes the whole",
		"Rush illustration set as one download, and MDPro3 fetches it itself:",
		"open Settings -> Download Card Pack. Bundling art here would add hundreds",
		"of megabytes and still be cropped wrong — MDPro3 crops Rush art to its own",
		"geometry, not the one the other packs use.",
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
 * Assembles the overlay for one language into `outDir` and zips it. Returns the
 * archive's manifest — the tree it actually contains, plus its size and digest.
 */
export function buildRushPack(lang, outDir, options = {}) {
	const layout = packLayout(lang);
	const sourceGz = options.sourceGz ?? layout.sourceGz;

	mkdirSync(outDir, { recursive: true });
	const staging = join(outDir, `staging-${lang}`);
	rmSync(staging, { recursive: true, force: true });

	// The published cdb is gzipped; MDPro3 opens it with SqliteConnection, so it
	// lands decompressed under the name the client looks for.
	const cdbFile = join(staging, layout.cdbPath);
	mkdirSync(dirname(cdbFile), { recursive: true });
	writeFileSync(cdbFile, gunzipSync(readFileSync(sourceGz)));

	const cards = Number(
		execFileSync("sqlite3", [cdbFile, "SELECT count(*) FROM datas;"], { encoding: "utf8" }).trim(),
	);
	if (cards === 0) {
		rmSync(staging, { recursive: true, force: true });
		throw new Error(`refusing to publish a pack with no cards (source: ${sourceGz})`);
	}

	const lflistFile = join(staging, layout.lflistPath);
	mkdirSync(dirname(lflistFile), { recursive: true });
	writeFileSync(lflistFile, readFileSync(options.lflist ?? LFLIST_SRC));

	writeFileSync(join(staging, layout.readmeName), `${renderInstallReadme({ lang, cards })}\n`);

	const zipPath = join(outDir, layout.archiveName);
	rmSync(zipPath, { force: true });
	// zip runs from inside staging so the archive root IS the MDPro3 folder,
	// which makes the output path resolve against staging too — hence resolve().
	execFileSync("zip", ["-qr", resolve(zipPath), "."], { cwd: staging });
	rmSync(staging, { recursive: true, force: true });

	return {
		lang,
		locale: layout.locale,
		cards,
		entries: [layout.cdbPath, layout.lflistPath, layout.readmeName].sort(),
		zipPath,
		bytes: statSync(zipPath).size,
		sha256: sha256File(zipPath),
	};
}

function main() {
	const [lang, outDir = "dist"] = process.argv.slice(2);
	if (!lang) {
		console.error(
			`usage: node scripts/build-rush-pack.mjs <${Object.keys(PACK_LANGS).join("|")}> [outDir]`,
		);
		process.exit(1);
	}
	const result = buildRushPack(lang, outDir);
	console.log(
		`Built ${result.zipPath} — ${result.cards} cards, ${result.locale}, ` +
			`${result.bytes} bytes, sha256 ${result.sha256}`,
	);
}

if (process.argv[1]?.endsWith("build-rush-pack.mjs")) {
	main();
}

// Reports when the YGOPro database (MoeCube) ships the TCG list that
// lflist/tcg.lflist.conf bridges. Until then the server and clients load the
// bridge so TCG rooms can use the current list; once MoeCube carries it, two
// copies would load and the bridge has to be removed (file, REPO_ASSETS entry,
// workflow paths and the server's formats/tcg assembly entry).
//
// Exit code 1 means "shipped upstream: remove the bridge", so a scheduled run
// turns red exactly when there is something to do.
import { readFileSync } from "node:fs";

const BRIDGE_PATH = "lflist/tcg.lflist.conf";
const UPSTREAM_URL = "https://cdntx.moecube.com/ygopro-database/zh-CN/lflist.conf";

// YGOPro writes "2026.9 TCG" where Evolution writes "2026.09 TCG".
function normalize(name) {
	return name.trim().replace(/^(\d{4})\.(\d{1,2})(?=\s|$)/, (_, year, month) => `${year}.${month.padStart(2, "0")}`);
}

export function bridgeListName(text) {
	const header = text.split("\n").find((line) => line.startsWith("!"));
	if (!header) throw new Error(`${BRIDGE_PATH}: no "!name" header`);
	return header.slice(1).trim();
}

export function isShippedUpstream(name, upstreamText) {
	const wanted = normalize(name);
	return upstreamText
		.split("\n")
		.filter((line) => line.startsWith("!"))
		.some((line) => normalize(line.slice(1)) === wanted);
}

async function main() {
	const name = bridgeListName(readFileSync(BRIDGE_PATH, "utf8"));
	const response = await fetch(UPSTREAM_URL);
	if (!response.ok) throw new Error(`${UPSTREAM_URL}: HTTP ${response.status}`);

	if (isShippedUpstream(name, await response.text())) {
		console.error(`MoeCube now ships "${name}": remove the ${BRIDGE_PATH} bridge.`);
		process.exit(1);
	}
	console.log(`MoeCube does not ship "${name}" yet; keep the ${BRIDGE_PATH} bridge.`);
}

if (process.argv[1]?.endsWith("check-tcg-bridge.mjs")) {
	await main();
}

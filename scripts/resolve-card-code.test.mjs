import assert from "node:assert/strict";
import { test } from "node:test";

import { CardLookupUnavailableError, fetchCardId, parsePreviousCodes } from "./resolve-card-code.mjs";

const ok = (id) => async () => ({ json: async () => ({ data: id === null ? undefined : [{ id }] }) });
const noSleep = async () => {};

test("returns the card id from the API payload", async () => {
	assert.equal(await fetchCardId("Planet Pathfinder", { fetch: ok(97526666), sleep: noSleep }), 97526666);
});

test("returns null when the API knows no such card", async () => {
	assert.equal(await fetchCardId("Nope", { fetch: ok(null), sleep: noSleep }), null);
});

test("retries a network failure and succeeds on a later attempt", async () => {
	let calls = 0;
	const flaky = async () => {
		calls += 1;
		if (calls < 3) {
			throw new TypeError("fetch failed");
		}
		return ok(43476205)();
	};
	assert.equal(await fetchCardId("Rank-Up-Magic Revolution Force", { fetch: flaky, retries: 3, sleep: noSleep }), 43476205);
	assert.equal(calls, 3);
});

test("throws CardLookupUnavailableError once retries are exhausted, never null", async () => {
	const dead = async () => {
		throw new TypeError("fetch failed");
	};
	await assert.rejects(
		fetchCardId("Planet Pathfinder", { fetch: dead, retries: 2, sleep: noSleep }),
		(error) => error instanceof CardLookupUnavailableError && /Planet Pathfinder/.test(error.message),
	);
});

test("backs off between retries", async () => {
	const delays = [];
	const dead = async () => {
		throw new TypeError("fetch failed");
	};
	await fetchCardId("X", { fetch: dead, retries: 3, delayMs: 100, sleep: async (ms) => delays.push(ms) }).catch(() => {});
	assert.deepEqual(delays, [100, 200]);
});

test("parsePreviousCodes maps names from an existing list to their codes", () => {
	const text = [
		"#[Genesys]",
		"!Genesys",
		"43476205 3 1 --Rank-Up-Magic Revolution Force",
		"2729965 3 11 --Hey, Space Trunade! | https://example.test/post/",
		"",
	].join("\n");
	const codes = parsePreviousCodes(text);
	assert.equal(codes.get("Rank-Up-Magic Revolution Force"), 43476205);
	assert.equal(codes.get("Hey, Space Trunade!"), 2729965);
	assert.equal(codes.size, 2);
});

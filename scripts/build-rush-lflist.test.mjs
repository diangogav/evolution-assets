import assert from "node:assert/strict";
import test from "node:test";

import {
	RUSH_SECTION,
	buildLflistFragment,
	countEntries,
	extractLegendBlock,
	findMissingIds,
	fuseRushLflist,
	fusedCardIds,
	listedIds,
	splitRegulation,
} from "./build-rush-lflist.mjs";

const MYCARD = `#[RD]
!RD

#Legend
$legend_monster 1
$legend_spell 1

120102002 $legend_monster 1 -- 时间魔术师
#120238008 $legend_monster 1 -- 虚无魔人
120247065 $legend_spell 1 -- 神鸟攻击
120247065 $legend_spell 1 -- 神鸟攻击

120000000 1 -- 怪兽传说卡 (Legend Monster)

#Forbidden
120226013 0 -- 业火之结界像
`;

const MDPRO4 = `# Japanese Rush Duel Forbidden & Limited List\r
# Effective 2026-10-01\r
!2026.10 Rush Duel\r
\r
#Forbidden\r
120226013 0 --Barrier Statue of the Inferno [CID 17958]\r
\r
#Limited\r
120102002 1 --Time Magician [CID 1]\r
\r
#Semi-Limited\r
120160004 2 --Some Card [CID 2]\r
\r
`;

// --- extractLegendBlock ---

test("keeps the legend declarations and active member lines, once each", () => {
	assert.deepEqual(extractLegendBlock(MYCARD), {
		declarations: ["$legend_monster 1", "$legend_spell 1"],
		entries: ["120102002 $legend_monster 1 -- 时间魔术师", "120247065 $legend_spell 1 -- 神鸟攻击"],
	});
});

test("a member of an undeclared legend group is refused", () => {
	assert.throws(
		() => extractLegendBlock("$legend_monster 1\n120 $legend_trap 1 -- x\n"),
		/120 names undeclared group \$legend_trap/,
	);
});

test("a mycard list without legend lines yields an empty block", () => {
	assert.deepEqual(extractLegendBlock("!RD\n1 0\n"), { declarations: [], entries: [] });
});

// --- splitRegulation ---

test("splits the regulation into preamble, section name and body", () => {
	const { preamble, name, body } = splitRegulation(MDPRO4);

	assert.deepEqual(preamble, ["# Japanese Rush Duel Forbidden & Limited List", "# Effective 2026-10-01"]);
	assert.equal(name, "2026.10 Rush Duel");
	assert.equal(body[0], "");
	assert.equal(body.at(-1), "120160004 2 --Some Card [CID 2]");
});

test("a regulation must hold exactly one section", () => {
	assert.throws(() => splitRegulation("1 0\n"), /exactly one "!" section, found 0/);
	assert.throws(() => splitRegulation("!A\n!B\n"), /exactly one "!" section, found 2/);
});

// --- fuseRushLflist ---

test("publishes the regulation under the section the client and server look up", () => {
	assert.equal(RUSH_SECTION, "RD");
});

test("fuses the regulation with the legend block under the Rush section", () => {
	const fused = fuseRushLflist({ regulationText: MDPRO4, mycardText: MYCARD });

	assert.equal(
		fused,
		[
			"# Japanese Rush Duel Forbidden & Limited List",
			"# Effective 2026-10-01",
			"# Regulation: 2026.10 Rush Duel",
			"#[RD]",
			"!RD",
			"",
			"#Legend",
			"$legend_monster 1",
			"$legend_spell 1",
			"",
			"120102002 $legend_monster 1 -- 时间魔术师",
			"120247065 $legend_spell 1 -- 神鸟攻击",
			"",
			"#Forbidden",
			"120226013 0 --Barrier Statue of the Inferno [CID 17958]",
			"",
			"#Limited",
			"120102002 1 --Time Magician [CID 1]",
			"",
			"#Semi-Limited",
			"120160004 2 --Some Card [CID 2]",
			"",
		].join("\n"),
	);
});

test("without legend lines the regulation is published as is", () => {
	const fused = fuseRushLflist({ regulationText: MDPRO4, mycardText: "!RD\n" });

	assert.doesNotMatch(fused, /#Legend/);
	assert.match(fused, /!RD\n\n#Forbidden\n/);
});

test("the fusion is deterministic", () => {
	const once = fuseRushLflist({ regulationText: MDPRO4, mycardText: MYCARD });
	assert.equal(fuseRushLflist({ regulationText: MDPRO4, mycardText: MYCARD }), once);
});

// --- listedIds / findMissingIds / countEntries ---

test("lists every card id an active line names, legend members included", () => {
	const fused = fuseRushLflist({ regulationText: MDPRO4, mycardText: MYCARD });
	assert.deepEqual(listedIds(fused), [120102002, 120160004, 120226013, 120247065]);
});

test("reports listed ids the card database lacks", () => {
	const fused = fuseRushLflist({ regulationText: MDPRO4, mycardText: MYCARD });
	const known = new Set([120102002, 120226013, 120247065]);

	assert.deepEqual(findMissingIds(fused, known), [120160004]);
	assert.deepEqual(findMissingIds(fused, new Set([...known, 120160004])), []);
});

test("counts limits and legend members separately", () => {
	const fused = fuseRushLflist({ regulationText: MDPRO4, mycardText: MYCARD });
	assert.deepEqual(countEntries(fused), { forbidden: 1, limited: 1, semiLimited: 1, legend: 2 });
});

// --- fusedCardIds ---

test("the fused id set is the union plus the admitted alternate arts", () => {
	const ids = fusedCardIds({
		unionIds: [120102002, 120226013],
		mdpro4Rows: [
			{ id: 120102002, ot: 4, alias: 0 },
			{ id: 129102002, ot: 4, alias: 120102002 },
			{ id: 129999999, ot: 4, alias: 120999999 },
		],
	});

	assert.deepEqual([...ids].sort(), [120102002, 120226013, 129102002]);
});

// --- buildLflistFragment ---

test("the report fragment carries the counts and the rewrite verdict", () => {
	const counts = { forbidden: 3, limited: 15, semiLimited: 18, legend: 126 };
	assert.deepEqual(buildLflistFragment(counts, "2026.10 Rush Duel", true), {
		step: "build-lflist",
		status: "changed",
		regulation: "2026.10 Rush Duel",
		counts,
	});
	assert.equal(buildLflistFragment(counts, "x", false).status, "unchanged");
});

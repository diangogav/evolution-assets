# Rush cdb and banlist fused with ElderLich/MDPro4_Data

**Objective**: keep mycard as the source of scripts and mechanics, and take from
ElderLich/MDPro4_Data what it does better: complete en/es card texts, the alternate
artwork rows (ids 129xxxxxx) whose images evolution-card-cdn already serves, and a Rush
banlist aligned with Konami's official regulation.

**Verified facts (2026-10-13/14)**: for every shared id, MDPro4's `datas` equals mycard's
byte for byte; MDPro4 lacks 177 mycard ids, so mycard stays the base. MDPro4 en/es texts
cover every card; es is partly machine translated (telltales: "Invoca de Modo", "no puedes se",
"tomar el daño", "Tails"/"Cabezas", `&quot;`). Our Yugipedia texts are official where present.
MDPro4 descs already carry the leading `Maximum ATK <n>` line on 43 Maximum monsters (same
convention as our en/es build). `Rush_lflist.conf` is one section `!2026.10 Rush Duel`
(3/15/18) without mycard's `$legend_*` lines. 681 alternate ids alias a base card; 8 of them
have no image; 6 anime customs 1280xxxxx and their variants stay out.

**Scope**: evolution-assets only. `rush/mdpro4/` holds the mirrored inputs
(`rush_cards.en.cdb`, `rush_cards.es.cdb`, `Rush_lflist.conf`, `SOURCE_COMMIT`).
Delivery strategy: ask-on-risk. Forecast ~500 authored lines over three tasks.
TDD strict: `npm test` (node --test), tests first for every pure function.

## Tasks
- [x] T1 `scripts/build-rush-cdb.mjs`: (a) add the 129xxxxxx alias rows from `rush/mdpro4/rush_cards.en.cdb` whose alias exists in the mycard union and whose alias is not an anime custom (ot=4 and id 1280xxxxx); `datas` copied as-is; (b) text chain per locale: en = translations.json en → MDPro4 en → zh; es = translations.json es → translations.base.json → MDPro4 es → en chain; a MDPro4 text is used only when non-empty and not identical to the en text when building es; never duplicate the `Maximum ATK` line; (c) report fragment listing es texts taken from MDPro4 that match the machine-translation telltales (count + sample ids), without failing the run. (route: delegated writer)
- [x] T2 `scripts/check-mdpro4-data.mjs` + workflow step: shallow-clone ElderLich/MDPro4_Data, verify sqlite headers, row count not lower than the committed copy, and that every shared id has identical type/atk/def/level/race/attribute/setcode/alias vs the mycard union (abort otherwise); copy the three inputs + SOURCE_COMMIT; record the commit in version-manifest.json. (route: delegated writer)
- [x] T3 banlist: `rush/lflist.conf` built from `rush/mdpro4/Rush_lflist.conf` plus mycard's `$legend_*` lines, every id validated against the fused cdb (`validate-lflist.mjs`), manifest entry refreshed. (route: delegated writer)

- [x] T4 server pool: `build-rush-cdb.mjs` also writes `rush/RD MDPro4 Alternate.cdb` (uncompressed, the admitted 129xxxxxx rows only, `datas` verbatim + MDPro4 en `texts`) so the duel server, which assembles its Rush pool from `rush/*.cdb`, knows the alternate arts; the mirror step must not delete it; workflow commits it; manifest entry added if the repo-assets manifest tracks rush cdbs. (route: delegated writer)

- [ ] T5 renumbered ids: MDPro4 rows absent from mycard, id < 128000000, alias 0, whose English name matches exactly one mycard card (via rush/translations.json `en`) with identical mechanics, enter the server and client cdbs as aliases of that mycard id; ambiguous or unmatched rows stay out and are reported. Today: 120109001→120100001, 120109002→120135002, 120109003→120186029, 120109006→120186007. Reason: MDPro4 decks with those ids were rejected by the server (UnknownCardError) and mycard ships scripts only under the new ids. (route: delegated writer)

## Evidence
T1: RED (missing exports) → GREEN `npm test` 332 tests, 328 pass, 4 skipped. Rebuilt cdb: 4237 rows (3562 before), 675 alias rows, es descs with [REQUISITO] 3574, with [REQUIREMENT] 30 (English fallbacks), CJK leftovers 136 (ids MDPro4 lacks). Decision: Spanish block labels for the es variant, superseding the English-label rule. Telltale report: 719 MDPro4 es texts flagged. Second build byte-identical.
T2/T3 (commit f22f4a6): RED 4 failures (missing modules/exports) → GREEN `npm test` 365 tests, 361 pass. check-mdpro4-data.mjs exits 0 on the live upstream (sparse blobless clone exercised locally: 6.4 MB, 0 ids added/removed at 6b277cc). Fused lflist keeps section `!RD` because evolution-card-game resolves the Rush list by that header (sources.config.ts sectionHeader 'RD'); 3/15/18 plus 125 legend members; mycard's three Token 'Legend Card' limit lines and one duplicate dropped. mycard's list captured at rush/lflist.mycard.conf. Manifest carries upstreamCommits for ElderLich/MDPro4_Data; refreshed in the following commit.
T4: RED (missing export installIfChanged) → GREEN `npm test` 369 tests, 365 pass. rush/RD MDPro4 Alternate.cdb: 675 datas/texts, ids 129016375..129024005, schema identical to RD Alternate.cdb, second build reports unchanged. Mirror step deletes only the three mycard cdbs by name; final commit paths carry the new file (bash array because of the spaces). Rebuilt client gz files differ only in sqlite page layout across sqlite versions (dumps identical), so the committed ones were kept.


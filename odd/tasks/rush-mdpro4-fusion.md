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
- [ ] T1 `scripts/build-rush-cdb.mjs`: (a) add the 129xxxxxx alias rows from `rush/mdpro4/rush_cards.en.cdb` whose alias exists in the mycard union and whose alias is not an anime custom (ot=4 and id 1280xxxxx); `datas` copied as-is; (b) text chain per locale: en = translations.json en → MDPro4 en → zh; es = translations.json es → translations.base.json → MDPro4 es → en chain; a MDPro4 text is used only when non-empty and not identical to the en text when building es; never duplicate the `Maximum ATK` line; (c) report fragment listing es texts taken from MDPro4 that match the machine-translation telltales (count + sample ids), without failing the run. (route: delegated writer)
- [ ] T2 `scripts/check-mdpro4-data.mjs` + workflow step: shallow-clone ElderLich/MDPro4_Data, verify sqlite headers, row count not lower than the committed copy, and that every shared id has identical type/atk/def/level/race/attribute/setcode/alias vs the mycard union (abort otherwise); copy the three inputs + SOURCE_COMMIT; record the commit in version-manifest.json. (route: delegated writer)
- [ ] T3 banlist: `rush/lflist.conf` built from `rush/mdpro4/Rush_lflist.conf` plus mycard's `$legend_*` lines, every id validated against the fused cdb (`validate-lflist.mjs`), manifest entry refreshed. (route: delegated writer)

## Evidence
(appended per task)

# Rush untranslated texts

## Objective
Stop shipping Chinese duel prompts and English reprint texts in the en/es Rush databases.

## Problem
- `texts.str1..str16` are translated only on exact hits in `rush/effect-strings*.json`. In `cdb/rush.es.cdb`, 974 prompts on 827 cards keep their Chinese text. MDPro4's mirror (`rush/mdpro4/rush_cards.{en,es}.cdb`) has a non-Chinese prompt for 920 of them.
- Reprints such as 120311057 (alias 120263008) and 120311059 (alias 120263005) ship English name/desc in es, even though their alias has Spanish text. MDPro4 text is looked up only by the row's own id.

## Scope
- `scripts/build-rush-cdb.mjs`, its tests, the regenerated `cdb/rush*.cdb(.gz)` and the header comment.
- Out of scope: hand-translating prompts; changing `datas`.

## Tasks
- [x] T1 str fallback: after a dictionary miss, take MDPro4's prompt for that card and slot (es: MDPro4 es when it differs from MDPro4 en, else MDPro4 en; en: MDPro4 en). Keep the Chinese only when no source has it. Report coverage per source. Route: delegated (writer trigger: build script + tests). Evidence: RED 12 failing tests, GREEN `npm test` 377/377; es prompts now dictionary 3678, mdpro4 937, mdpro4.en 0, original 1079, zh 37; en zh 36.
- [x] T2 alias fallback: for name/desc, when a row's own chain falls back to English (es) or Chinese, try the alias's MDPro4 tiers before that. Route: delegated, same writer. Evidence: es names of 120311057/120311059 are "HÉROE Elemental Avian"/"HÉROE Elemental Sparkman"; 120305012 str2 is Spanish.
- [x] T3 regenerate databases, run `npm test`, commit, open one PR.

## Acceptance
- 120305012 str2 in es is Spanish; 120311057/120311059 es names are "HÉROE Elemental Avian"/"HÉROE Elemental Sparkman".
- Remaining Chinese prompts in es ≤ 54.
- `datas` byte-identical across variants; `npm test` green.

## Checks
TDD: enabled (user global config, Strict TDD Mode). Runner: `npm test` (`node --test "scripts/*.test.mjs"`).

## Delivery
Single PR (user choice, 2026-10-14). Branch `fix/rush-untranslated-texts`.

## Progress
- 2026-10-14: document created.
- 2026-10-14: T1 and T2 implemented with tests; cdbs regenerated with `node scripts/build-rush-cdb.mjs` (gz only; raw cdb/rush*.cdb are untracked leftovers). Remaining Chinese prompts: es 37, en 36 (acceptance <= 54).
- 2026-10-14: native review (reliability lens) approved and acknowledged, lineage review-d540a8ef9a06da1e; 2 non-blocking notes (alias-not-reprint: 0 alias rows differ from their base mechanics; report helper untested). npm test 377/377. es Chinese prompts 974 -> 37. Single PR opened.

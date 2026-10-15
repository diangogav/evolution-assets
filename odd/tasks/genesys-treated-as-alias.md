# Genesys: "always treated as" cards are not alternate art

## Objective

Stop collapsing "always treated as" cards onto the card they are treated as
when building the Genesys point list and the Genesys card images.

## Problem

`datas.alias` carries two meanings in EDOPro databases:

- alternate art / tokens: same name as the base card;
- "This card is always treated as X": a different card with its own name.

Both `evolution-assets/scripts/resolve-card-identity.mjs` and
`genesys-card-generator/sync_alias.py` treat every non-zero alias as alternate
art. Result (user report): Fallen of the White Dragon (73819701, 30 pts) was
written under Fallen of Albaz's code 68468459, so Albaz costs 30 in the server
and White Dragon's image got Albaz's badge. Same for Crimson Blade Dragon
(3294539) -> Crimson Blader (80321197).

## Why name, not code distance

In `cdb/base.en.cdb`: 18 aliases have a different name than their base and all
are far codes; 0 near-code aliases differ in name. Far-code aliases with the
same name exist (tokens, `511001275`), so a `|code - alias| < 20` rule would
drop legitimate aliases.

## Scope

- In: `resolve-card-identity.mjs` (+ tests, regenerated `genesys.lflist.conf`);
  `genesys-card-generator/sync_alias.py` (+ tests, regenerated `alias.json` and
  affected images).
- Out: `EDOpro-server-ts` alias fallback hardening (step 3, not authorized).

## Acceptance criteria

- An alias row is an alternate art only when its name equals the base card's name.
- `genesys.lflist.conf` lists 73819701 (30) and no longer lists 68468459.
- `alias.json` no longer maps 73819701 under 68468459 nor 3294539 under 80321197.

## TDD

Strict TDD: enabled (source: user global config). Runners: `npm test`
(evolution-assets, `node --test`), `pytest` (genesys-card-generator).

## Tasks

- [x] T1 (delegated writer) evolution-assets: name-aware identity in
  `resolve-card-identity.mjs`, tests, regenerate the point list. Branch
  `fix/genesys-treated-as-identity`.
- [ ] T2 (delegated writer) genesys-card-generator: name-aware filter in
  `sync_alias.py`, tests, regenerate `alias.json` and affected images. Branch
  `fix/genesys-treated-as-alias`.

Route: delegated direct, one writer per repo (2+ non-trivial files each).

## Progress

- T2 done pending one decision: commits 68875dc, a51befd, fcf0b27 on
  `fix/genesys-treated-as-alias`; pytest 146 passed. Name compare ignores
  trailing "(Anime)/(Manga)" qualifiers, case, spacing, punctuation (exact
  equality would drop 81 legit anime/manga alts). Still wrongly drops
  170000116 "Linear Magnum ± (Anime)" from 44839512; needs allowlist or accept.
- Checked: "always treated as" in desc is NOT a usable discriminator (alt arts
  of treated-as cards carry the same text).
- Community PRs #31 (data-only, overwritten on regen) and #32 (disables identity
  correction, regresses alt-art fixes) are superseded by this fix.
- Follow-up: after T1 lands, `python3 generate.py --code 73819701,3294539`.

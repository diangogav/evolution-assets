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
- [x] T2 (delegated writer) genesys-card-generator: name-aware filter in
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

- T2 final: commits 68875dc, a51befd, fcf0b27, fdd6218 (revert qualifier
  tolerance), 64c51bd (skip non-official printings, ot & ~0x103), 06f89a8
  (resync). pytest 157 passed (parent re-ran). alias.json 151 -> 70 ids:
  2 treated-as + 79 anime/manga removed; 82 images pruned. 170000116 resolved
  by scope filter (anime), no allowlist.
- Review assess: evolution-assets medium/under_budget (no review due);
  genesys-card-generator high/high_risk -> consent requested from user.
- Generator review: granted, 4 lenses, approved and acknowledged (authority
  burned, lineage review-01bac13b3b1ae5bd). Non-blocking follow-ups: alias
  silently dropped when a name is missing/renamed (sync_alias.py:107-114),
  duplicated overlay readers (266-330), small comment/test-name nits.
- Next: push both branches and open PRs (user decision); close #31/#32 as
  superseded; after T1 lands run `python3 generate.py --code 73819701,3294539`.
- Branch rebased onto origin/main (local main was 4 commits behind; CI had
  refreshed the list in 8ee64c5). Manual list commit 4ad57f5 dropped; list
  regenerated with `NODE_EXTRA_CA_CERTS=scripts/certs/geotrust-tls-rsa-ca-g1.pem
  npm run genesys` (the blog serves no intermediate cert; CI sets this var).
  Diff vs origin/main is exactly the 4 lines (73819701, 3294539 in; 68468459,
  80321197 out). npm test 381 pass 0 fail. Backup: backup/genesys-treated-as-identity.

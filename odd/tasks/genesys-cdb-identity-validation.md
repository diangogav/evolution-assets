# Genesys cdb identity validation

## Objective

Make the repo's own card database the identity authority for the Genesys point
list, so a card's points land on the code the client actually ships.

## Problem

`resolveCardCode` in `scripts/generate-genesys-lflist.mjs` resolves names through
YGOPRODeck and takes `data[0].id`. That API sometimes returns an alternate-art
printing instead of the base card. An audit of the 792 current entries against
`cdb/base.en.cdb` found 8 wrong identities:

Alternate art instead of the base card (`datas.alias != 0`):

- `3294539` Crimson Blade Dragon -> base `80321197`
- `18144507` Harpie's Feather Duster -> base `18144506`
- `73819701` Fallen of the White Dragon -> base `68468459`
- `83764719` Monster Reborn -> base `83764718`

Absent from the database entirely:

- `89913287` Adamancipator Risen - Tiamite
- `101303084`
- `101402089` Chaospawn Bishop
- `101402090` Angelechy Castellan

## Why now

A 2026-08-25 decision declined this validation with an explicit reopening
condition: "YGOPRODeck is a resolver, not an authority - the operative identity
authority is the repo's cdb. Revisit if a wrong-id incident appears or the user
asks." Both halves of that condition are now met.

## Scope

In scope: correcting alternate-art codes to their base card, and reporting codes
the database does not know.

Out of scope: changing point values, changing name resolution, touching the blog
overlay's stored state, and rebuilding the list from a different source.

## Constraints

- Only `sqlite3` (CLI, already used at `scripts/build-rush-cdb.mjs:91`) and
  `node:zlib` are available. The repo tracks `cdb/base.en.cdb.gz`, not the
  uncompressed file, so CI must decompress before querying.
- The step must be fail-safe: if the database cannot be read, warn and emit the
  uncorrected list, mirroring how `applyBlogOverlay` falls back today. A
  generator that dies on a missing database is worse than one that lags.
- Correction runs after the blog overlay, immediately before formatting, so the
  overlay keeps matching the table's own codes.

## Decisions

- **Alternate art is corrected, not dropped.** `datas.alias` states the base card
  outright, so this is a lookup, not a guess.
- **Absent codes are reported and kept.** The database mirror lags new sets the
  same way the official table lags the blog. `89913287` is a real Beyond the
  Brave card that simply has not reached the mirror yet, so dropping it would
  discard valid points.
- **A correction that collides with an existing entry drops the corrected
  duplicate and reports it.** The entry that already carried the base code wins;
  a list cannot carry one card twice.

## Tasks

- [x] T1 `scripts/resolve-card-identity.mjs` + tests: read `(id, alias)` from a
      card database, and a pure function that corrects a card list, returning the
      corrected list plus corrections, unknown codes, and dropped duplicates.
- [x] T2 Wire into `scripts/generate-genesys-lflist.mjs` after the blog overlay
      and before `formatGenesysLflist`, with the fail-safe fallback and console
      reporting, plus tests.

## Acceptance criteria

- The four alternate-art codes above come out as their base codes.
- The four unknown codes survive in the output and are reported.
- An unreadable or missing database logs a warning and changes no points.
- `npm test` green.

## Checks

- `npm test` (strict TDD: RED before GREEN on every task)

## Route

- T1: delegated writer (2 non-trivial files) - writer trigger
- T2: delegated writer (2 non-trivial files) - writer trigger

## Progress

Both tasks done, strict TDD (RED observed before GREEN on T1).

Verified end-to-end against the real list through the `.gz` path CI uses, not
the uncompressed file that exists only locally:

```
identity map (from the .gz): 15019 cards
input: 792 -> output: 792
corrections: 4
    Crimson Blade Dragon       3294539  -> 80321197
    Harpie's Feather Duster    18144507 -> 18144506
    Fallen of the White Dragon 73819701 -> 68468459
    Monster Reborn             83764719 -> 83764718
unknown kept: 4   89913287, 101303084, 101402089, 101402090
dropped duplicates: 0
```

`npm test`: 325 tests, 321 pass, 0 fail, 4 skipped (baseline 315/311/0/4; the
+10 is the new test file).

Not pushed. Landing the branch is the user's call.

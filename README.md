# evolution-assets

Static game assets for the Evolution YGO server (card databases, sample decks,
ban lists), plus the generators that produce them.

## Layout

```
cdb/        card databases (.cdb)
edopro/     prompt strings for rooms run by the EDOPro core
decks/      sample decks (.ydk) and index.json, the template list the client reads
lflist/     ban lists (.lflist.conf) — including the generated genesys list
scripts/    generators that produce assets
```

## TCG bridge list

`lflist/tcg.lflist.conf` carries the current TCG list while the YGOPro database
(MoeCube) has not shipped it yet. The server loads it from `formats/tcg` and its
TCG rooms use the most recent dated TCG list, so this file takes over without
moving any other list. Copy the block from a source whose hash matches the
YGOPro-family clients (MDPro4's `Data/Banlists/lflist.conf`), so they recognize
the room's list.

`scripts/check-tcg-bridge.mjs` runs daily and fails once MoeCube declares the
same list. Then remove the bridge: this file, its `REPO_ASSETS` entry, the
`paths` entry in `repo-assets-manifest.yml`, and the server's `formats/tcg`
assembly entry and `runtime.ygopro.standard` member.

## EDOPro prompt strings and cards

A client of the YGOPro server can sit in a room run by the EDOPro core. The
scripts of that core name their prompts by position, and the two card databases
number the prompts of a card independently, so the client needs EDOPro's own
labels for the duration of that room. The room also puts EDOPro's card codes on
the wire, and some of them (pre-errata copies, alternate artworks, unreleased
cards under a temporary number) are not in the client's database:

- `edopro/prompts.cdb` holds `texts (id, str1..str16)` for every card with at
  least one prompt, and nothing else. It is built from
  [ProjectIgnis/BabelCDB](https://github.com/ProjectIgnis/BabelCDB), the
  repository the server loads its EDOPro databases from:

  ```sh
  node scripts/build-edopro-prompts.mjs --databases <BabelCDB checkout>
  gzip -9 -n -k -f edopro/prompts.cdb
  ```

- `edopro/cards.cdb` holds the cards of those same databases that
  `cdb/base.en.cdb.gz` lacks, in the layout of any card database, with the
  prompts left empty. Names and text are English only:

  ```sh
  node scripts/build-edopro-cards.mjs --databases <BabelCDB checkout>
  gzip -9 -n -k -f edopro/cards.cdb
  ```

- `edopro/strings.{en,es}.conf` are EDOPro's `strings.conf` and its Spanish
  copy, taken unchanged from
  [ProjectIgnis/Distribution](https://github.com/ProjectIgnis/Distribution)
  (`config/strings.conf` and `config/languages/Español/strings.conf`, AGPL-3.0).

`mirror-edopro-prompts.yml` refreshes all of them daily and commits only when
they change, so none of them is edited by hand.

## Goat Format list and pre-errata overlay

`lflist/goat.lflist.conf` is the Goat Format whitelist (TCG April 2005 list,
card pool legal on 2005-08-17 per goatformat.com), derived from ProjectIgnis'
`GOAT.lflist.conf`. Pre-errata copies already ported to the pool keep EDOPro's
`504700xxx` / `511*` codes (`alias` = official code); copies not yet ported are
listed under their official code and play with modern text until they are.

The copies' rows live in `cdb/pre-errata.{es,en}.cdb`, written from
`cdb/pre-errata-goat.json` by:

```
node scripts/apply-pre-errata-rows.mjs --rows cdb/pre-errata-goat.json --marker GOAT
```

The script copies the official `datas` row under the new code, sets the alias,
and writes the era name (`<name> (GOAT)`) and 2005 text in each language. It is
idempotent, so re-run it after editing the JSON. The scripts themselves live in
the private pre-errata repository, which also holds the registry with each
card's source, ruling and first-print date.

## Genesys ban list

`lflist/genesys.lflist.conf` is generated, not hand-edited. It encodes the
official Genesys point costs in EDOPro's three-column lflist format:

```
#[Genesys]
!Genesys
<card id> 3 <points> --<card name>
```

Every Genesys card allows the standard 3 copies (middle column), and the third
column is the point cost. Cards with no cost are omitted (unlisted means zero).

### Regenerating

```
npm install
npm run genesys   # scrapes the official point list and rewrites the file
npm test          # unit tests for the formatter
```

The `Update Genesys ban list` GitHub Action runs the generator every 6 hours and
commits the file when the point costs change, so the list stays in sync with
Konami without manual work.

### Blog overlay

Konami announces point changes on [the official blog](https://yugiohblog.konami.com/category/genesys/)
days before the table page catches up. The generator scrapes new blog posts and
applies their point deltas on top of the table-scraped list, tracking them in
`lflist/genesys-blog-state.json`. The table stays the source of truth: a delta
only applies while the table still holds the pre-change value (or lacks the
card), conflicts resolve in the table's favor, and a post whose deltas have all
converged with the table is marked spent. A post may only add cards the table
lacks within 30 days of publication — past that, absence means the points were
removed, not that the table is lagging. Newer posts supersede older ones per
card, so a later republished cost (including a removal to 0) always wins over
an earlier one. Cards whose value came from a blog post ahead of the table
carry that post's URL in their `--name | url` comment; once the table
converges, the entry reverts to a plain table-sourced line and the link
disappears. Any blog failure falls back to the table-only list.

## Deck templates

The web client offers every `.ydk` in `decks/` as a template, named `[<Format>] <Name>.ydk`.
It reads the list from `decks/index.json`, so after adding, renaming or removing a deck run:

```
npm run deck-index
```

and commit `decks/index.json` with the deck. `npm test` fails while the index is out of date.

## Card alternates

`cdb/alternates.json` maps a card's original passcode to the ids whose cdb `alias` points at it
(pre-errata versions such as Edison's Armory Arm `29071332` → `910003009`). Consumers use it to
swap a card a ban list does not allow for an alternate the list does allow. It is generated from
every uncompressed `cdb/*.cdb`, so after adding, changing or removing any of them run:

```
npm run card-alternates
```

and commit `cdb/alternates.json` with the cdb. `npm test` fails while the map is out of date.


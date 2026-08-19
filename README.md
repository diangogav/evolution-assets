# evolution-assets

Static game assets for the Evolution YGO server (card databases, sample decks,
ban lists), plus the generators that produce them.

## Layout

```
cdb/        card databases (.cdb)
decks/      sample decks (.ydk)
lflist/     ban lists (.lflist.conf) — including the generated genesys list
scripts/    generators that produce assets
```

## Edison card pack

`scripts/build-client-pack.mjs` builds the card pack that lets players on an
outside client see and deck-build the Edison pre-errata pool. It bundles the
28-card cdb, the Edison ban list and the card art — data only. Card behaviour is
resolved on the server, so the pack does nothing on any other server or offline.

### Building

```
npm run pack -- en dist
npm run pack -- es dist
npm test                  # unit tests for the generator
```

One pack per language, because a client merges every database it finds: a single
archive carrying both would have them overwrite each other in load order.

### Publishing

Replace the assets on the existing release. Do **not** create a new tag:

```
gh release upload edison-pack dist/*.ypk --clobber
```

The download address is baked into each pack's README and gets pasted into
Discord posts and pinned messages:

```
https://github.com/diangogav/evolution-assets/releases/download/edison-pack/evolution-edison-{en,es}.ypk
```

`edison-pack` is a **slot, not a version**. Cutting an `edison-pack-v2` would
404 every link already published, including the one inside every pack a player
has already downloaded. `--clobber` keeps the address stable and creates no git
objects, which is why the `.ypk` files are not committed to the repo.

`/releases/latest/download/` looks like the same thing and is not: it resolves
to whatever release in this repo is newest, so cutting a release here for
anything else would break every published link.

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

The `Update Genesys ban list` GitHub Action runs the generator daily and commits
the file when the point costs change, so the list stays in sync with Konami
without manual work.

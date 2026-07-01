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

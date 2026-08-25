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

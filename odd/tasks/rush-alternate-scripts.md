# Rush alternate-art scripts on the YGOPro side

Branch: fix/rush-alternate-scripts. TDD: strict (node --test). Route: delegated writer.

## Problem
`rush/RD MDPro4 Alternate.cdb` holds 679 MDPro4 alternate/renumbered rows (ids 129xxxxxx and others) aliased to their mycard ids. The YGOPro ocgcore only reuses the alias's script when the two ids are within the artwork offset, so for these far aliases it looks for `c<altid>.lua`, which does not exist: the cards play as vanilla. Seen 2026-10-19 (All Lovely Goddess 129020166 → 120260039 lost a game for its player).

## Tasks
- [ ] T1 Generate one stub `rush/script/c<altid>.lua` per aliased row whose alias has a script, reusing the original's effects; generator + tests in scripts/; wire it into the existing Rush build so new rows get stubs automatically.
- [ ] T2 Verify in the engine (koishipro-core in EDOpro-server-ts) that an alternate id now loads its effects.

## Evidence
(pending)

# Rush alternate-art scripts on the YGOPro side

Branch: fix/rush-alternate-scripts. TDD: strict (node --test). Route: delegated writer.

## Problem
`rush/RD MDPro4 Alternate.cdb` holds 679 MDPro4 alternate/renumbered rows (ids 129xxxxxx and others) aliased to their mycard ids. The YGOPro ocgcore only reuses the alias's script when the two ids are within the artwork offset, so for these far aliases it looks for `c<altid>.lua`, which does not exist: the cards play as vanilla. Seen 2026-10-19 (All Lovely Goddess 129020166 → 120260039 lost a game for its player).

## Tasks
- [x] T1 Generate one stub `rush/script/c<altid>.lua` per aliased row whose alias has a script, reusing the original's effects; generator + tests in scripts/; wire it into the existing Rush build so new rows get stubs automatically.
- [x] T2 Verify in the engine (koishipro-core in EDOpro-server-ts) that an alternate id now loads its effects.

## Evidence
adab83d generator + tests + mirror workflow wiring; 0f93eff 646 generated stubs (`RD.AlternateCard(<base>)`, the pattern mycard already uses). 33 rows skipped: all vanilla normal monsters (no script needed). npm test 388 pass 0 fail. Engine check with koishipro-core 1.5.3: 129020166 loads c120260039 and gets its continuous ATK effect (1000 with one 0-ATK monster); without the stub ATK 0 and a ScriptError. Gentle AI review of the generator slice (adab83d, 4 lenses): approved and acknowledged; the full candidate exceeded the reviewer context budget because of the 646 generated stubs. Server picks scripts up without restart via the resources updater sidecar (default 600 s) and per-duel script readers.

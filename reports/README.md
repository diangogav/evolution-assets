# Run reports (run-report v1)

Machine-readable summaries of the scheduled pipelines, one JSON file per
pipeline (`reports/rush.json`, …). Downstream automation — e.g. a Discord
announcer — triggers on changes to these files and reads typed events instead
of scraping workflow logs; humans get the same content rendered into the
Actions run summary.

## The contract

**Fragments.** Every pipeline script accepts the env var `REPORT_PATH`. When
set, the script *also* writes a JSON fragment there:

```json
{ "step": "<step-id>", "status": "changed" | "unchanged", ...step-specific data }
```

`changed` means the step actually rewrote its output this run. When
`REPORT_PATH` is unset the script behaves exactly as before (stderr stats
only). The fragment is written only after the script's real outputs are safely
on disk; a failed fragment write exits non-zero without undoing those outputs.
The shared helper lives in `scripts/run-report.mjs`.

**Composer.** A per-pipeline composer (`scripts/report-rush.mjs`) merges the
fragments into `reports/<pipeline>.json` and renders a markdown summary to
`$GITHUB_STEP_SUMMARY` when that env var exists. It runs `if: always()`, so a
failed pipeline still gets a summary: a step that never wrote its fragment
appears as `"status": "missing"`.

**Persistence.** Only the latest report is kept — history is the git log of
the file. The workflow commits it only on successful runs, and the composer
rewrites it only when the run produced notable events (cards added/removed,
translations added, ambiguities, or moved gap counts) and the content really
differs from the previous report ignoring `generatedAt`/`runUrl` — so
scheduled no-op runs never produce a timestamp-only commit.

## Schema (`reports/rush.json`, schemaVersion 1)

```json
{
  "schemaVersion": 1,
  "pipeline": "rush",
  "generatedAt": "2026-08-26T06:04:00.000Z",
  "runUrl": "https://github.com/<owner>/<repo>/actions/runs/<id>",
  "steps": [
    { "step": "resolve-pages", "status": "changed", "...": "step-specific data" },
    { "step": "fetch-translations", "status": "unchanged" },
    { "step": "build-cdb", "status": "unchanged" },
    { "step": "update-manifest", "status": "missing" }
  ],
  "events": {
    "cardsAdded": [{ "id": "120310001", "zh": "...", "en": "..." , "es": null }],
    "cardsRemoved": ["120250001"],
    "translationsAdded": [{ "id": "120200001", "zh": "...", "en": "...", "es": "..." }],
    "unresolved": { "count": 116, "sample": ["..."] },
    "noBlock": { "count": 49, "sample": ["..."] },
    "ambiguous": [
      { "id": "...", "zh": "...", "candidates": [{ "code": "RD/B221-JP006", "title": "..." }] }
    ]
  }
}
```

`runUrl` is `null` outside GitHub Actions. `en`/`es` are `null` while the wiki
does not document the card. `unresolved`/`noBlock` samples cap at 20 ids;
`cardsAdded` is diffed against a pre-refresh id dump the workflow passes via
`OLD_IDS_FILE` — without that dump the composer reports no additions rather
than fabricating them.

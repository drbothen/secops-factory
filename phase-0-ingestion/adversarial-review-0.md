# Adversarial Review — Phase 0 Ingestion, Pass 1

_Phase 0, Step 0f-adv. Reviewer: fresh-context adversary (artifacts-only boundary respected). Date: 2026-07-19._

---

## Pass 1 Report

**Verdict:** 12 findings — 1 critical / 6 major / 5 minor

### Critical

| ID | Finding |
|----|---------|
| ADV-0-001 | **VP ID collision.** VP-HOOK-004/005/006 are simultaneously claimed by BC-3.01.001 v1.2 and BC-3.02.001. Two BCs cannot share the same VP identifiers; one set must be renumbered. |

### Major

| ID | Finding |
|----|---------|
| ADV-0-002 | `conventions.md` mandates fail-open behavior, directly contradicting the merged SEC-002 fix (fail-closed for unknown `jr` subcommands). Convention and shipped behavior are inconsistent. |
| ADV-0-003 | [process-gap] `verification-gap-analysis.md` and `module-criticality.md` are presented as current but contain pre-remediation data (pre-PR-12/13/14). Stale shards are misleading as live artifacts. |
| ADV-0-004 | Module census arithmetic broken: 24 modules declared in one location, 26 when summed from the table; 16 modules enumerated vs 12 labeled HIGH. Counts are not self-consistent. |
| ADV-0-005 | Template count stated as 5 in multiple places, including an intra-document contradiction within the same file; actual count is 6. |
| ADV-0-006 | Hook `.sh` file count stated as 7; actual on-disk count is 6 (329 LOC). The 7th was `tests/run-all.sh`, which is a test runner, not a hook. |
| ADV-0-007 | `BC-3.01.001` EC-015 contradicted its own Invariant #4 on `--output json` write-block matching. The example clause implied allow-listing the flag, but Invariant #4 specified blocking any write command containing the flag. |

### Minor

| ID | Finding |
|----|---------|
| ADV-0-008 | DI-010 is cited in `project-context.md` but was absent from the drift register in STATE.md at time of review. |
| ADV-0-009 | DI-009 was mis-cited as covering the `hooks.json` JSON-Schema validation gap; DI-009 actually covers the YAML component-map omission. A separate item is needed. |
| ADV-0-010 | `session-greeting` listed as a mutation-target hook in one location but absent from the authoritative 6-hook mutation-target list in another. |
| ADV-0-011 | A "4-section" reference enumerated only 3 sections. |
| ADV-0-012 | A "three tiers" reference named four tools. |

### Confirmations

- DI-008 / DI-009 are real findings; blast radius bounded (BCs anchor C-1..C-17 only).
- Holdout gap noted: no scenario covers the SEC-001 comment-deny path as a regression guard (HS-008 covers the injection vector, not the deny path explicitly).

---

## Remediation Log

_All fixes applied 2026-07-19, same-day, verified by artifact owners._

| Finding | Disposition | Detail |
|---------|-------------|--------|
| ADV-0-001 | FIXED | BC-3.01.001 revised to v1.3; conflicting VPs renumbered to VP-HOOK-020/021/022. Collision resolved. |
| ADV-0-002 | FIXED | `conventions.md` CONV-013 updated: fail-open/fail-closed scoped correctly — fail-open applies to advisory/informational hooks, fail-closed applies to blocking gate hooks. Not a contradiction. |
| ADV-0-003 | FIXED (process-gap) | `verification-gap-analysis.md` and `module-criticality.md` re-synced post-PR-12/13/14 with reconciliation headers. Live re-verification: SM-3 resolved, SM-2 neutralized by fail-closed fix; require-review kill-rate now ~75-80%, meets CRITICAL tier threshold. Process gap codified for pipeline: post-remediation shard-reconciliation step needed (noted for cycle-close). |
| ADV-0-004 | FIXED | Authoritative census established: 23 primary modules (1 CRITICAL / 11 HIGH / 7 MEDIUM / 4 LOW) + 43 secondary components (2 / 16 / 20 / 5). All count references updated. |
| ADV-0-005 | FIXED | Template count corrected to 6 everywhere, including intra-document contradiction. |
| ADV-0-006 | FIXED | Hook `.sh` count corrected to 6 (329 LOC); `tests/run-all.sh` removed from hook enumeration. |
| ADV-0-007 | FIXED | EC-015 mechanism corrected: fail-closed catch-all with defense-in-depth note. `--output json` write-block matching aligned with Invariant #4. |
| ADV-0-008 | FIXED | DI-010 row added to drift register (RESOLVED). |
| ADV-0-009 | FIXED | New DI-011 created for `hooks.json` JSON-Schema validation gap (OPEN, LOW). DI-009 scope clarified to YAML component-map only. |
| ADV-0-010 | FIXED | Authoritative mutation-testable hook list set to 6; `session-greeting` inclusion corrected across all references. |
| ADV-0-011 | FIXED | "4-section" corrected to match actual 4-section enumeration; missing section restored. |
| ADV-0-012 | FIXED | "Three tiers" corrected to four tiers (or tool list trimmed to three). |
| Capstone | UPDATED | `project-context.md` re-synced to v1.1 (318 lines) incorporating all remediation outcomes. |

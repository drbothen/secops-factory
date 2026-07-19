# Adversarial Review — Phase 0 Ingestion, Pass 6

_Phase 0, Step 0f-adv. Reviewer: fresh-context adversary. Date: 2026-07-19._

---

## Pass 6 Report

**Verdict:** 6 findings — 0 critical / 2 major / 4 minor. Novelty: MEDIUM — new boundary crossed: CRITICAL-hook contract vs its consumer BCs.

**Finding decay:** 12 → 11 → 7 → 8(1FP) → 6 → 6. Zero criticals for four consecutive passes.

### Verified GREEN Axes (no findings)

- Census: 24 primary / 43 secondary + derivation formula — PASS
- DAG acyclicity (DFS re-verified) — PASS
- VP namespace uniqueness across all 13 BCs — PASS
- Template count 6, hook count 6, agent count 6 — PASS
- Holdout distribution (25 scenarios: 4+4C / 16H / 1M) — PASS
- DI-001..DI-012 status fields — PASS
- BC titles and versions — PASS
- Security roll-up (0C/0H/1M/4L/3I, SEC-001..007) — PASS
- Holdout tally distribution — PASS

### Major

| ID | Finding |
|----|---------|
| ADV-0-601 | **SEC-001 comment-deny never propagated to consumer BCs.** The `require-review` hook (BC-3.01.001) now unconditionally DENIES the `jr issue comment` operation. However, `BC-4.02.001` (investigate-event skill) and `BC-5.01.001` (orchestration) both contain steps that instruct the agent to issue `jr issue comment` — an operation that will always fail at runtime under the current hook. Additionally, `arch-recov-integrations.md` claimed a "marker-override" mechanism where a prior APPROVED marker would allow the comment through. Ground truth: no such mechanism exists — the hook is unconditional; the only valid path is human permission-override of the hook. All three artifacts must be corrected. Resolution: BC-4.02.001 v1.1 updated with DENY-path handling; BC-5.01.001 v1.2 updated; integrations corrected to unconditional DENY + override-path only. Workflow friction decision opened as DI-013 (PENDING HUMAN DECISION: accept friction / implement marker mechanism / add dedicated non-blocked command). |
| ADV-0-602 | **HS-014 must-pass scenario encodes post-fix behavior that HEAD fails.** HS-014 tests the disposition-guard false-pass (DI-004) using the post-fix expected behavior — DENY on body-text-only. However DI-004 remains open (no fix landed); HEAD still exhibits the false-pass behavior. HS-014 as a must-pass scenario would therefore fail against the current codebase, invalidating the holdout baseline. Resolution: HS-014 reclassified from must-pass to fix-target in HS-INDEX.md. Holdout baseline updated: 24 must-pass / 1 fix-target. |

### Minor

| ID | Finding |
|----|---------|
| ADV-0-603 | `conventions.md` `require-review` section anchor references are stale — citations point to old header text from a pre-pass-2 revision. Ground truth from current document: correct section header is `## Blocked Operations (fail-closed)`. Resolution: re-anchored to current header with ground-truth verification. |
| ADV-0-604 | Input-hash changelog attribution gaps in 3 BCs — the `changelog` section notes the input-hash addition but does not credit the originating pass (pass 4) or date. Inconsistent with other changelog entries. Resolution: attribution filled in (pass 4, 2026-07-19) for all affected BCs. |
| ADV-0-605 | DI-004 (disposition-guard body-text false-pass) is tracked as a drift item but not yet elevated to a first-class EC in `BC-3.03.001`. An EC entry with a canonical mutation vector would make the gap machine-verifiable and linkable to a holdout scenario. Resolution: EC-009 added to BC-3.03.001 v1.3 with canonical vector and NOT-YET-FIXED annotation. HS-014 cross-referenced. |
| ADV-0-606 | Co-fire wiring between disposition-guard hook and enrichment-completeness hook was described as "inferred" in the integration notes. Orchestrator confirmed: both hooks appear in the same `PreToolUse/Write` array in `hooks.json`. Resolution: wiring status upgraded from "inferred" to VERIFIED in `arch-recov-integrations.md` and `recovered-architecture.md`-adjacent notes. |

---

## Remediation Log

_All 6 findings addressed 2026-07-19, same-day, verified by artifact owners._

| Finding | Disposition | Detail |
|---------|-------------|--------|
| ADV-0-601 | FIXED | `BC-4.02.001` revised to v1.1: `jr issue comment` step annotated with DENY-path handling and human permission-override path. `BC-5.01.001` revised to v1.2: same annotation propagated to orchestration BC. `arch-recov-integrations.md` corrected: marker-override claim removed, replaced with unconditional DENY + human permission-override only. DI-013 opened (PENDING HUMAN DECISION: comment-gate friction — accept / marker mechanism / dedicated command). |
| ADV-0-602 | FIXED | HS-014 reclassified fix-target in `HS-INDEX.md`. Holdout baseline updated: 24/25 must-pass + 1 fix-target. |
| ADV-0-603 | FIXED | `conventions.md` require-review section anchor re-anchored to `## Blocked Operations (fail-closed)`. Ground-truth verification documented. |
| ADV-0-604 | FIXED | Changelog attribution gaps filled: input-hash entries in affected BCs now credit pass 4, 2026-07-19. |
| ADV-0-605 | FIXED | `BC-3.03.001` v1.3: EC-009 added (disposition-guard body-text false-pass, canonical mutation vector, NOT-YET-FIXED annotation, HS-014 cross-reference). |
| ADV-0-606 | FIXED | Co-fire wiring upgraded to VERIFIED in integration shard. `hooks.json` array confirmed as source of truth by orchestrator. |

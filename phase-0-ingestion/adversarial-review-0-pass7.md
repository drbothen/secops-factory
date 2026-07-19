# Adversarial Review — Phase 0 Ingestion, Pass 7

_Phase 0, Step 0f-adv. Reviewer: fresh-context adversary. Date: 2026-07-19._

---

## Pass 7 Report

**Verdict:** 6 findings — 0 critical / 2 major / 4 minor. Novelty: MODERATE — single root cause: incomplete fan-out of PR#13/SEC-001/DI-013 fixes to sibling shards.

**Finding decay:** 12 → 11 → 7 → 8(1FP) → 6 → 6 → 6. Zero criticals for five consecutive passes.

### Verified GREEN Axes (no findings)

- Census: 24 primary / 43 secondary + derivation — PASS
- DAG acyclicity — PASS
- VP namespace uniqueness — PASS
- Template count 6, hook count 6, agent count 6, test count 138 — PASS
- Kill-rate attribution (~75-80% current, superseded baseline labeled) — PASS
- Mutation vectors (6 hooks, SM-1..SM-8b defined) — PASS
- Holdout distribution (25 scenarios: 4+4C / 16H / 1M; 24 must-pass + 1 fix-target) — PASS
- DI-001..DI-013 status fields — PASS
- Iron-Law attributions — PASS
- Security roll-up (0C/0H/1M/4L/3I) — PASS

### Major

| ID | Finding |
|----|---------|
| ADV-0-701 | **`recovered-architecture.md` C-12 still describes the pre-PR#13 4-verb gate.** C-12 (require-review hook) prose states it gates 4 operations; the YAML entry also lists 4 verbs including `comment`. Post-PR#13, `comment` is fail-closed (unconditionally DENIED) — it is not a gated verb in the same sense as the others; C-12 must distinguish between gated-with-approval-check verbs and unconditionally-denied verbs. Fan-out from SEC-001 fix did not reach this component entry. |
| ADV-0-702 | **`BC-5.01.001` PC#3 mis-attributes "≥2 alternatives structurally enforced" to disposition-guard.** The postcondition claims that disposition-guard enforces the requirement that ≥2 meaningful alternatives exist in the disposition section. In fact, the hook only checks heading presence (DI-004 caveat: body-text check is false-passable). The structural enforcement claim overstates what the hook actually verifies. |

### Minor

| ID | Finding |
|----|---------|
| ADV-0-703 | `BC-3.04.001` (enrichment-completeness hook) still describes the `hooks.json` registration wiring as "inferred." Pass 6 (ADV-0-606) confirmed co-fire wiring as VERIFIED, but BC-3.04.001 was not updated to reflect the upgrade. |
| ADV-0-704 | `arch-recov-api-surface.md` pipelines section shows `jr issue comment` as unblocked in the skill invocation chain diagram. Post-SEC-001, this call is unconditionally denied. The diagram was not updated when integrations.md was corrected. |
| ADV-0-705 | "Deny from either wins" (co-fire aggregate behavior) was stated in one shard in a way that implies both hooks fire on every Write event. Clarification needed: the Bash path does not trigger the co-fire; co-fire applies only to the Claude tool-use path via PreToolUse/Write. |
| ADV-0-706 | Write-block line anchor cited as `88-93` in two documents (project-context.md, conventions.md). Canonical range is `88-94`; the DENY instruction fires at line :93 but the block ends at :94. Minor but inconsistent. |

### Process Gap (flagged, not counted as finding)

**Process-gap #6 (fan-out discipline):** Every SEC-*/DI-* fix must include a grep sweep across all shards for the old value before the capstone claims consistency. The recurrence of partial-fix propagation findings (present in passes 2, 4, 5, 6, and now 7) confirms this is a systemic gap, not an oversight. Codification candidate for cycle-close checklist.

---

## Remediation Log

_All 6 findings fixed 2026-07-19 via SYSTEMATIC grep sweep (not spot fixes). 12 hits across shards including 4 unreported security-audit snapshot-body annotations._

| Finding | Disposition | Detail |
|---------|-------------|--------|
| ADV-0-701 | FIXED | `recovered-architecture.md` C-12 YAML and prose updated: gated-with-approval-check verbs (4) vs unconditionally-denied verbs (comment) now distinguished. Canonical write-block citation standardized across all 12 grep hits. |
| ADV-0-702 | FIXED | `BC-5.01.001` v1.3 PC#3 corrected: claim scoped to "heading presence verified by disposition-guard; structural completeness of alternatives is not mechanically enforced (DI-004 open)." `BC-4.02.001` v1.2 updated for consistency. |
| ADV-0-703 | FIXED | `BC-3.01.001` v1.6 and `BC-3.04.001` v1.3 updated: hooks.json wiring marked VERIFIED (pass 6 ADV-0-606 confirmation). |
| ADV-0-704 | FIXED | `arch-recov-api-surface.md` pipelines diagram corrected: `jr issue comment` marked DENIED (SEC-001). |
| ADV-0-705 | FIXED | Co-fire aggregate behavior note clarified: Bash path excluded; co-fire applies to Claude tool-use PreToolUse/Write path only. Updated in integrations shard and capstone. |
| ADV-0-706 | FIXED | Write-block anchor standardized to `88-94` everywhere. `security-audit.md` snapshot-body annotations updated (4 hits from grep sweep). `HS-INDEX.md` v1.2/active updated with pass-7 sweep record. |
| Capstone | UPDATED | `project-context.md` v1.7 (400 lines): honestly-rewritten sweep-backed cross-reference checkbox; all pass-7 remediation outcomes reflected; DI-013 workflow-friction summary updated. |

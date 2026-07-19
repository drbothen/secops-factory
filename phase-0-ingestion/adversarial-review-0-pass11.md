# Adversarial Review — Phase 0 Ingestion, Pass 11

_Phase 0, Step 0f-adv. Reviewer: fresh-context adversary (explicitly instructed to grade honestly and not manufacture findings). Date: 2026-07-19._

---

## Pass 11 Report

**Verdict:** 2 findings — 0 critical / 0 major / 2 minor + 4 observations. Novelty: LOW.

**Adversary judgment:** "Converged and honest." The adversary re-derived all primary axes independently and found them clean.

**Finding decay:** 12 → 11 → 7 → 8(1FP) → 6 → 6 → 6 → 6(1 real code bug) → 4 → 5 → 2.

**Both minors are the same residual class:** stale `hooks.bats` LINE anchors in BCs and `conventions.md`, desynced by PR #15's +12 in-block test insertion. A different file than `require-review.sh` — this class was not yet covered by the construct-name conversion of the prior pass.

### Verified GREEN Axes (re-derived, all CLEAN, no mis-anchoring found)

- Census 24 primary / 43 secondary + derivation — re-derived PASS
- DAG acyclicity — PASS
- VP namespace uniqueness (VP-HOOK-020..VP-HOOK-023) — PASS
- Template count 6, hook count 6, agent count 6, test count 150 — PASS
- DI-001..DI-014 status fields — PASS
- BC title/version consistency — PASS
- Holdout distribution (26 scenarios: 4+4C / 16H / 1M; 24 must-pass + 1 fix-target + 1 bypass-guard) — PASS
- Security-finding arithmetic (SEC-001..009) — PASS
- Gate-status honesty — PASS (explicitly noted as genuinely good)
- No architecture or security gaps identified

### Minor

| ID | Finding |
|----|---------|
| ADV-0-B01 | `BC-3.01.001` contains a citation "hooks.bats:9-93 all documented paths." After PR #15's insertion of 12 new in-block tests, the require-review test section runs from line 9 through line 177 (26 tests). The cited range `9-93` is stale and significantly understates the coverage; `:93` now falls mid-section. |
| ADV-0-B02 | Downstream hook-BC group-header anchors and `conventions.md` section references that point into `hooks.bats` are off by approximately +72 lines (the aggregate shift from PR #15's insertions into the require-review block). Affected: BC-3.02.001 through BC-3.06.001, and `conventions.md` group-header line references. |

### Observations (not graded findings)

1. Capstone statement "zero live anchors remain" is a slight overclaim — it is accurate for `require-review.sh`-sourced anchors but the `hooks.bats`-sourced anchors (this pass's finding class) were not yet converted. The claim should read "zero line-number-only anchors for hook source files."
2. SEC-009 does not appear in the final human-approved disposition table in `security-audit.md`. This is expected — SEC-009 was discovered post-audit, after the human gate had already passed. The disposition table is a point-in-time snapshot. No defect; observation noted for completeness.
3. PR #12 SHA symmetry: the security-audit's PR #12 SHA reference is consistent across all shards. No discrepancy.
4. `jr issue transitions` allowlist entry provenance: the transitions subcommand is in the allowlist; its original addition rationale is undocumented. Low-impact; noted for future audit trail completeness.

---

## Remediation Log

_All 2 findings fixed 2026-07-19 via grep -n "^@test" ground-truth verification._

| Finding | Disposition | Detail |
|---------|-------------|--------|
| ADV-0-B01 | FIXED | Ground truth verified: `grep -n "^@test"` on `hooks.bats` — require-review section: 26 tests, lines 9-177. `BC-3.01.001` citation converted to `@test`-NAME form (stable test name + line as secondary locator). BC-3.01.001 revised to v1.9. Bonus catch: BC-3.01.001 PC#3 cited a renamed test — fixed to current name. |
| ADV-0-B02 | FIXED | ALL `hooks.bats` anchors in BC-3.02.001 through BC-3.06.001 and `conventions.md` converted to `@test`-NAME references (name-first; line number as secondary hint only). Verified ground-truth positions for enrichment-completeness (line 185), disposition-guard, deactivate-session, session-greeting, and bias-check blocks. BC versions: BC-3.02.001 v1.5, BC-3.03.001 v1.4, BC-3.04.001 v1.4, BC-3.05.001 v1.3, BC-3.06.001 v1.3. The `@test`-name form makes the hook-subsystem test references churn-resilient — readers key on stable test names, not fragile line numbers. |
| Observation 1 | CLARIFIED | Capstone anchor-churn statement updated: "zero line-number-ONLY anchors; trailing line numbers are secondary locators alongside the stable construct name." Accurate for both `require-review.sh`-sourced and `hooks.bats`-sourced anchors. |
| Capstone | UPDATED | `project-context.md` v1.11 with honest anchor-note wording and observation clarifications. |

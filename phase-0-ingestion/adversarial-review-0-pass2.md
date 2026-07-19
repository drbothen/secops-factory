# Adversarial Review — Phase 0 Ingestion, Pass 2

_Phase 0, Step 0f-adv. Reviewer: fresh-context adversary (blind to pass 1). Date: 2026-07-19._

---

## Pass 2 Report

**Verdict:** 11 findings — 2 critical / 5 major / 4 minor. Novelty: HIGH. Convergence status: NOT CONVERGED.

**Root cause pattern:** Partial-fix propagation — pass-1 fixes reached some artifacts but not all sibling artifacts that share the same counts and claims. Cross-artifact census synchronization was not enforced.

### Critical

| ID | Finding |
|----|---------|
| ADV-0-201 | **Capstone census self-contradiction.** `project-context.md` simultaneously declares 23 modules in one section, lists component IDs through C-24 in another, and has a counted 18 members labeled HIGH (vs declared 12 HIGH). No single census is internally consistent. |
| ADV-0-202 | **`module-criticality.md` C-IDs off-by-one from C-18; census stale at 23.** Component IDs in the criticality register diverge from the capstone and from each other at C-18 onward. Census figure still reads 23 despite pass-1 remediation having established 24 as authoritative in other artifacts. |

### Major

| ID | Finding |
|----|---------|
| ADV-0-203 | DI-008 and DI-009 are marked RESOLVED in STATE.md, but `module-criticality.md` still carries stale reconciliation notes that imply they are open. Status contradiction across artifacts. |
| ADV-0-204 | `create-advisory` Iron Law entry in `arch-recov-api-surface.md` reads "(none)" for external API surface. This is wrong: `SKILL.md` line 14 specifies an external API dependency. The table omits a real integration. |
| ADV-0-205 | require-review kill-rate claim of ">=95% assurance" is an overclaim. The stated figure is an aggregate across all hooks, not a per-hook verified measurement for require-review specifically. Kill-rate for require-review individually is unmeasured. |
| ADV-0-206 | `arch-recov-integrations.md` still presents the DI-001 secrets-exposure issue as a live finding. PR #12 resolved this; the shard was not annotated as resolved. |
| ADV-0-207 | C-22 (test-suite component) entry states "all 5 hooks" in its mutation-coverage note. Authoritative hook count is 6 (C-17 session-greeting is the sixth). C-17 is omitted from C-22's coverage scope. |

### Minor

| ID | Finding |
|----|---------|
| ADV-0-208 | Test delta stated as "9 new BATS tests" in one shard; other shards report "8 new tests." Count is inconsistent across documents. |
| ADV-0-209 | Git commit statistics in `project-discovery.md` are stale — reflect pre-PR-12/13/14 state (38 commits, PRs #1-#11). Actual state: 41 commits, PRs #1-#14. |
| ADV-0-210 | `BC-3.03.001` invariant anchor references a general-analysis invariant. The correct anchor should be the anti-confirmation-bias invariant. Mis-anchored BC. |
| ADV-0-211 | Agent count description uses additive wording that implies the agent list grows with each item, producing an inflated perceived count vs actual 6 agents. |

### Clean Checks (confirmed correct)

- VP uniqueness across all 13 BCs: PASS (no collisions after pass-1 renumbering)
- Holdout scenario tallies: PASS (25 scenarios, counts correct)
- Security-finding tallies: PASS (0 crit / 0 high / 1 med / 4 low / 3 info, SEC-001..007 disposition correct)
- BC C-anchor stability C-1..C-17: PASS

### Process Gap (flagged, not counted as finding)

No cross-artifact census-sync gate exists. When a component is added, there is no enforced step requiring count fields, C-ID sequences, and tier tallies to be regenerated consistently across all shards that reference them. This is a pipeline gap, not an artifact defect. Recommend adding a census-sync assertion to the pipeline: `component_count == criticality_count == capstone_census`.

### Coverage Observation → New Drift Item

`create-advisory`, `analyze-ticket-effort`, and the read-ticket injection entry point have no behavioral contracts. These are behavioral surfaces with no BC coverage. Flagged as DI-012.

---

## Remediation Log

_All 11 findings fixed same-day, 2026-07-19, verified by artifact owners._

| Finding | Disposition | Detail |
|---------|-------------|--------|
| ADV-0-201 | FIXED | Census now authoritative at 24 modules (1 CRITICAL / 12 HIGH / 7 MEDIUM / 4 LOW) everywhere in capstone. C-IDs run C-1..C-24 consistently. HIGH count reconciled to 12. |
| ADV-0-202 | FIXED | `module-criticality.md` C-IDs realigned at C-18..C-24; census updated to 24. All tier tallies (1/12/7/4) consistent with capstone. |
| ADV-0-203 | FIXED | `module-criticality.md` stale DI-008/DI-009 notes struck through with resolution date annotation; status consistent with STATE.md. |
| ADV-0-204 | FIXED | `arch-recov-api-surface.md` `create-advisory` Iron-Law table corrected to include actual external dependency from `SKILL.md:14`. Bonus fix applied: `generate-metrics` row had wrongly inherited `analyze-ticket-effort`'s Iron Law entry — corrected. |
| ADV-0-205 | FIXED | Assurance overclaim replaced with: ">=95% kill-rate target NOT yet demonstrated met; per-hook kill-rate for require-review is unmeasured." Aggregate figure removed from require-review attribution. |
| ADV-0-206 | FIXED | `arch-recov-integrations.md` DI-001 entry annotated as RESOLVED (PR #12, 2026-07-19); no longer presented as live exposure. |
| ADV-0-207 | FIXED | C-22 entry updated: "all 6 hooks (C-11..C-16 + C-17 session-greeting)." session-greeting now included in mutation-coverage scope. |
| ADV-0-208 | FIXED | Test delta corrected to 8 new BATS tests everywhere (138 total). Nine-occurrence removed. |
| ADV-0-209 | FIXED | Git stats updated: 41 commits, PRs #1-#14 incorporated. |
| ADV-0-210 | FIXED | `BC-3.03.001` re-anchored to anti-confirmation-bias invariant. |
| ADV-0-211 | FIXED | Agent count wording made non-additive; 6 agents stated directly. |
| Capstone | UPDATED | `project-context.md` re-synced to v1.2 (334 lines) incorporating all remediation outcomes and DI-012. |

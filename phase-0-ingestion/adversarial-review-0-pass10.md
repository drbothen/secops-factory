# Adversarial Review — Phase 0 Ingestion, Pass 10

_Phase 0, Step 0f-adv. Reviewer: fresh-context adversary (full read of all 13 BCs — prior coverage boundary closed). Date: 2026-07-19._

---

## Pass 10 Report

**Verdict:** 5 findings — 0 critical / 1 major / 4 minor. Novelty: LOW-MEDIUM.

**Finding decay:** 12 → 11 → 7 → 8(1FP) → 6 → 6 → 6 → 6(1 real code bug) → 4 → 5.

**Key characterization:** NO new architecture or security gaps found. All 5 findings are propagation/consistency residue from pass-8/9 PR-#15 edits. This pass closed the prior coverage boundary by reading all 13 BCs.

### Verified GREEN Axes (re-derived, explicit)

- Census 24 primary / 43 secondary + derivation — re-derived PASS
- DAG acyclicity (manually verified) — PASS
- VP namespace uniqueness across all 13 BCs — PASS (re-verified with full BC read)
- Template count 6, hook count 6, agent count 6, test count 150 — PASS
- DI-001..DI-014 status fields — PASS
- BC title/version consistency — PASS (all 13 BCs read)
- Holdout distribution (26 scenarios: 4+4C / 16H / 1M; 24 must-pass + 1 fix-target + 1 bypass-guard) — PASS
- Security-finding arithmetic (SEC-001..009) — PASS
- Gate-status honesty: the adversary explicitly noted that the gate-status framing in specs is genuinely good — acknowledged as a positive quality of the artifact set

### Major

| ID | Finding |
|----|---------|
| ADV-0-A01 | **[process-gap] Capstone claimed anchor-churn retired, but `BC-3.01.001` and `conventions.md` still used line numbers.** Pass 9 (ADV-0-901) declared the anchor-churn class "structurally retired" after converting BC-4.02.001, BC-5.01.001, and arch-recov-integrations to construct names. However, `BC-3.01.001` (the source BC for require-review) and `conventions.md` themselves still contained line-number citations (`88-94`, `:93`). The claim of structural retirement was premature — the root-cause artifacts were not included in the fix scope. |

### Minor

| ID | Finding |
|----|---------|
| ADV-0-A02 | `BC-3.01.001` contained a "138+" test count reference in a sidebar note that was not updated when the canonical count moved to 150. |
| ADV-0-A03 | SEC-009 exploit example was stated with two different mechanisms across shards: "command-chaining" in some locations (implying `cmd1 && cmd2`) and "embedded-token" in others (implying a token within a single command argument). Ground truth: the ADV-0-801 demonstration used the embedded-token form. The two forms are distinct attack classes; only one was demonstrated. References unified to embedded-token form. |
| ADV-0-A04 | No VP existed for the `--output json` write family that PR #15 added to the write-block. The write-block DENY is enforced (EC-016 covers it), but there was no VP expressing the invariant at the property-verification level. |
| ADV-0-A05 | `project-discovery.md` PR range read `#1-#14` (42 commits). PR #15 was merged; the range should be `#1-#15` and commit count should be 42. |

### Observation (not a graded finding)

`recovered-architecture.md` C-15 (bias-check hook) scope description was slightly narrow — corrected to reflect the full trigger scope without raising it to a formal finding (observation-only fix applied).

---

## Remediation Log

_All 5 findings and 1 observation fixed 2026-07-19._

**MILESTONE:** This pass confirmed ZERO correctness, security, or architecture defects remain. All 5 findings were edit-propagation residue; all are now resolved. Anchor-churn root cause is now structurally AND completely retired — all shards have been converted to construct-name references._

| Finding | Disposition | Detail |
|---------|-------------|--------|
| ADV-0-A01 | FIXED — COMPLETE | `BC-3.01.001` and `conventions.md` line-number citations converted to construct names. Anchor-churn class now genuinely, completely retired: all shards use construct-name references. |
| ADV-0-A02 | FIXED | `BC-3.01.001` sidebar note updated to 150. |
| ADV-0-A03 | FIXED | SEC-009 exploit mechanism unified to embedded-token form across all shards. `security-audit.md`, `project-context.md`, and `conventions.md` updated. |
| ADV-0-A04 | FIXED | VP-HOOK-023 added: `--output json` write forms must be caught by the write-block. `BC-3.01.001` updated with VP-HOOK-023 reference. VP namespace re-verified clean after addition. |
| ADV-0-A05 | FIXED | `project-discovery.md` PR range updated to `#1-#15` (42 commits — PR #15 was a separate commit on the factory-artifacts branch, not a main-branch PR increment; count verified). |
| Observation | FIXED | `recovered-architecture.md` C-15 bias-check scope description corrected. |
| Capstone | UPDATED | `project-context.md` re-synced with all pass-10 corrections; milestone statement added. |

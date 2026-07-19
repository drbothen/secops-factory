# Adversarial Review — Phase 0 Ingestion, Pass 9

_Phase 0, Step 0f-adv. Reviewer: fresh-context adversary. Date: 2026-07-19._

---

## Pass 9 Report

**Verdict:** 4 findings — 0 critical / 3 major / 1 minor + 1 process-gap.

**Finding decay:** 12 → 11 → 7 → 8(1FP) → 6 → 6 → 6 → 6(1 real code bug) → 4.

**Root cause of all 4 findings:** PR #15's line-renumber and SEC-009 addition propagated only to `BC-3.01.001` and `conventions.md`, leaving stale/INVERTED require-review anchors in sibling consumer shards and zero SEC-009 content in the two most-cited L1 shards (`verification-gap-analysis.md` and `module-criticality.md`).

### Verified GREEN Axes (no findings)

- Census 24/43 + derivation — re-derived PASS
- DAG acyclicity — PASS
- VP namespace uniqueness — PASS
- DI-001..DI-014 status fields — PASS
- BC title/version consistency — PASS (adversary read 5 of 13 BCs — noted coverage boundary)
- Iron-Law attributions — PASS
- Holdout distribution (26 scenarios: 4+4C / 16H / 1M; 24 must-pass + 1 fix-target + 1 bypass-guard) — PASS

### Major

| ID | Finding |
|----|---------|
| ADV-0-901 | **Stale/INVERTED require-review line anchors in consumer shards.** PR #15 renumbered the `require-review` hook source. The post-PR#15 canonical write-block range (`88-94`) was correctly updated in `BC-3.01.001` and `conventions.md`, but `BC-4.02.001`, `BC-5.01.001`, and `arch-recov-integrations.md` still cite pre-PR#15 anchors — and in some cases the old line numbers now fall in the allowlist region rather than the write-block region, making the citation semantically inverted. |
| ADV-0-902 | **Test count 138-vs-150 unresolved.** `project-context.md` and `verification-gap-analysis.md` still contain `138` in contexts that should read `150` (post-PR#14 addition of 8 new tests + post-PR#15 addition of 12 new tests = 150 total). The count was partially updated but not fully propagated. The correct decomposition: hooks 44, skills 81, integration 11, parity 14 = 150. |
| ADV-0-903 | **`verification-gap-analysis.md` and `module-criticality.md` have zero SEC-009 content.** These are the two most-cited L1 verification shards. SEC-009 (the live auth-gate bypass, CRITICAL-at-discovery, RESOLVED PR #15) was added to `security-audit.md` in pass 8, but neither L1 shard was updated. `verification-gap-analysis.md` should note the evaluation-order mutation class (SM-3b RESOLVED); `module-criticality.md` should record the count and status update. |

### Minor

| ID | Finding |
|----|---------|
| ADV-0-904 | `specs/module-criticality.md` groups SM-8 (session-greeting text injection) under the PR #15 fix section. SM-8 was defined in pass 3 as an open surviving mutant for `session-greeting`; it has no connection to the PR #15 write-block fix. Mis-grouping creates a false impression that SM-8 was resolved by PR #15. |

### Process Gap (not counted as finding, reinforces process-gap #7)

Fan-out discipline (process-gap #6/#7 reinforced): ADV-0-901/902/903 are all the same class — partial fan-out from a fix that touched source BCs but not consumer shards and L1 analysis documents. The grep-sweep discipline (established in pass 7 remediation, codified as process-gap #6) would have caught all three before this pass was needed. Codification as a mandatory cycle-close checklist item is now strongly indicated by the recurrence count.

---

## Remediation Log

_All 4 findings fixed 2026-07-19 via SYSTEMATIC grep sweep. GROUND TRUTH test count = 150 settled everywhere._

| Finding | Disposition | Detail |
|---------|-------------|--------|
| ADV-0-901 | FIXED — DURABLE FIX | All `require-review` references across ALL shards switched from brittle line numbers to CONSTRUCT NAMES (function/test names, section headers, invariant identifiers). `BC-4.02.001` v1.3, `BC-5.01.001` v1.4, `arch-recov-integrations.md` updated. Anchor-churn class structurally retired — line-number drift cannot recur for these references regardless of future source edits. |
| ADV-0-902 | FIXED | GROUND TRUTH test count = 150 settled everywhere: hooks 44, skills 81, integration 11, parity 14 = 150. `project-context.md`, `verification-gap-analysis.md`, `specs/module-criticality.md` all updated. `138` occurrences removed from all non-historical contexts. |
| ADV-0-903 | FIXED | `verification-gap-analysis.md` re-issued: SEC-009 section added; SM-3b evaluation-order mutant marked RESOLVED (PR #15 write-block-first ordering); "unconditional" claim for require-review corrected to post-PR#15 scope; test count updated to 150. `specs/module-criticality.md` v1.4: SEC-009 logged, count corrected to 150. |
| ADV-0-904 | FIXED | SM-8 entry moved to the correct `session-greeting` mutation section in `module-criticality.md`. PR #15 fix section corrected to contain only PR #15-relevant mutants. |
| Capstone | UPDATED | `project-context.md` v1.9 (399 lines): construct-name anchor references; count 150; SEC-009 cross-reference; SM-3b RESOLVED; DI-014 status. |

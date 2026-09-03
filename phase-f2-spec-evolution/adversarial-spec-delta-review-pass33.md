---
document_type: adversarial-review-report
level: L3
version: "1.0"
status: remediated
producer: adversary
timestamp: 2026-09-03T00:00:00Z
phase: F2
pass: 33
cycle: v0.10.0-feature-prism-integration
inputs: [phase-f2-spec-evolution/]
input-hash: "[live-state]"
traces_to: STATE.md
---

# F2 Adversarial Spec Review — Pass 33

**Date:** 2026-09-03
**Verdict:** PASS 33 — 0C / 0M / 2med / 1min / 2obs — NOT CLEAN
**Fifth consecutive 0C/0M pass. Both MEDIUMs were gaps left by the burst-29 coherence sweep itself.**
**Status:** REMEDIATED — burst-30 coherence-sweep tail cleanup

---

## Summary

| Severity | Count | IDs |
|----------|-------|-----|
| CRITICAL | 0 | — |
| MAJOR | 0 | — |
| MEDIUM | 2 | P33-001, P33-002 |
| MINOR | 1 | P33-003 |
| OBS | 2 | P33-OBS-1, P33-OBS-2 |
| **Total** | **5** | |

**Novelty:** LOW — all findings are coherence/version-drift or annotation gaps. No new behavioral logic defects.

**Consecutive 0C/0M passes:** 5 (passes 29, 30, 31, 32, 33) — deeply converged but NOT clean (MED+MIN remain).

**Clean streak:** 0/3 — pass 33 has 2med + 1min (NOT clean per 0C/0M/0med/0min criterion).

---

## Findings

### P33-001 (MEDIUM) — prd-delta §5 cells for BC-4.02.001 and BC-5.01.001 not synced by burst-29

**Location:** prd-delta.md §5 "New Versions in this Cycle" tracking table

**Finding:** The burst-29 comprehensive coherence sweep (P32-001 remediation) updated the §5 tracking-table cells for BC-3.03.001 and BC-10.01.001 but did not update the cells for BC-4.02.001 and BC-5.01.001. Both BCs were bumped during burst-29 as side-effects of the Group H and Group I sweeps:

- BC-4.02.001: v1.20 → v1.21 (burst-29 Group H live cross-reference updates). The §5 cell still showed v1.20.
- BC-5.01.001: v1.14 → v1.15 (burst-29 Group I live cross-reference updates). The §5 cell still showed v1.14.

The burst-29 sweep patched individual cells for the BCs it directly targeted (Groups G-directed: BC-3.03.001 and BC-10.01.001) but did not re-derive the FULL §5 table from current BC frontmatter versions. BCs bumped as side-effects were missed.

**Root cause:** A coherence sweep that patches individual §5 cells is SELECTIVE, not exhaustive (Lesson 51). The true exhaustive check re-derives the FULL §5 table from current BC frontmatter, classifying every cell as live or frozen.

**Status:** REMEDIATED — burst-30 product-owner updated §5 cells: BC-4.02.001 v1.20→v1.21, BC-5.01.001 v1.14→v1.15. prd-delta remains at v1.33 (content update within same version). input-hash updated to 247135e (reflecting BC-10.01.001 content change in burst-30).

---

### P33-002 (MEDIUM) — BC-10.01.001 L119 as-of-introduction annotation cited wrong version

**Location:** BC-10.01.001.md L116/L119 (Precondition #8) — as-of-introduction annotation for JSON-first dispatch

**Finding:** BC-10.01.001 Precondition #8 carried the annotation "JSON-first dispatch introduced at v1.24". This is incorrect: JSON-first dispatch (P4-001) was introduced in BC-3.03.001 v1.12, not v1.24. The annotation was a propagation error from P30-004 (burst-27), which used v1.24 as the "as-of-introduction" version for a DIFFERENT annotation (stale cross-ref pins in BC-10.01.001 citing BC-3.03.001 at v1.24). The v1.24 date was then incorrectly carried forward into the new annotation at L119.

Corroborating evidence: BC-10.01.001 Previous block at L121 states "P4-001 JSON-first dispatch in BC-3.03.001 v1.12"; prd-delta §5 L125 states "Pass 4→v1.12 (P4-001)" — both agree the introduction was v1.12 at P4-001.

**Status:** REMEDIATED — burst-30 product-owner corrected annotation to "JSON-first dispatch introduced at v1.12 (P4-001)". BC-10.01.001 remains at v1.32 (no-bump — annotation correction, no behavioral change). prd-delta §5 also carried the same error at PC#8 row annotation and was corrected in parallel.

---

### P33-003 (MINOR) — prd-delta Document Changelog missing v1.33 row

**Location:** prd-delta.md Document Changelog section

**Finding:** The burst-29 version bump (v1.32 → v1.33 for the P32-001 §5 cell corrections and P32-002/P32-003 coherence sweep) did not add a v1.33 changelog row. The changelog jumped from v1.32 directly to no entry for v1.33. A missing changelog row makes the version history incomplete — a reader auditing the changelog cannot determine which changes were made at v1.33 vs the prior state.

**Status:** REMEDIATED — burst-30 product-owner added the v1.33 changelog row documenting the comprehensive P32-coherence-sweep changes (§5 BC-version cells, EC footer, §1 VP totals), the P33-002 PC#8 annotation correction, and the P33-001/P33-003 resolutions. prd-delta remains at v1.33.

---

### P33-OBS-1 (OBS) — dtu-assessment scenario count stale: 7 stated, 10 actual

**Location:** dtu-assessment.md §3 mock scenarios / scenario count statement

**Finding:** The dtu-assessment stated a scenario count of 7 (the original 7 from the initial assessment). The actual total set is 10: the original 7 (`duplicate-open`, `related-open`, `resolved-same`, `closed-same`, `no-match`, `blind-spot-open`, `blind-spot-absent`) plus 3 NEW additions added in later versions (`fp-auto-close` [v1.2], `blind-spot-closed-compound` [v1.4], `tp-close-denied` [v1.4]). Two stale "7" counts in the document body did not reflect the additions. Adjudicated as OBS (not MED) because the scenarios themselves were correctly documented; only the count header was stale.

**Adjudication:** Total set = 10 (accepted). Two "7" count occurrences updated to "10".

**Status:** REMEDIATED — burst-30 product-owner updated dtu-assessment: scenario count 7→10 in affected prose locations + template-drift structural cleanup. dtu-assessment bumped to v1.6. input-hash: 3cf5746 (resolved).

---

### P33-OBS-2 (OBS) — verification-delta §5 deferral note overly broad post-v1.34 reconciliation

**Location:** verification-delta.md §5 test-count section, deferral note (~L1509)

**Finding:** The §5 deferral note at L1509 asserted a BLANKET deferral for ALL per-BC rows: "the per-BC rows below likewise reflect the v1.20 burst-15 baseline and their granular reconciliation is DEFERRED …". This was stale after the v1.34 P32-coherence sweep, which granularly reconciled the two largest rows (BC-3.03.001 → 129, BC-10.01.001 → 113, each carrying an embedded `[v1.34 P32-coherence recount …]` annotation). The blanket deferral note gave the false impression that ALL per-BC rows were still unreconciled, when the two largest had been corrected.

**Status:** REMEDIATED — burst-30 formal-verifier narrowed the deferral note to scope it to the REMAINING small-BC rows only, acknowledging the two reconciled rows. No count or tally change. verification-delta remains at v1.34 (no-bump — clarification edit only). VP count UNCHANGED at 41 / SM UNCHANGED at 74 alloc 73 live.

---

## Note on Meta-Pattern: §5 Full-Table Re-Derivation

Pass-33 P33-001 illustrates a specific sub-class of Lesson 51's version-agnostic sweep rule: when a burst bumps a BC as a SIDE-EFFECT of a larger coherence sweep, the §5 tracking table in prd-delta (or any cross-document version index) must be re-derived from ALL current BC frontmatter versions — not just the BCs that were the direct targets of the sweep. Lesson 51 covers this class: the exhaustive method extracts ALL `BC-<id> v<N.NN>` occurrences and compares each against source-of-truth frontmatter. Had burst-29 applied that method to the §5 table cells (not just the body pins), P33-001 would not have survived.

---

## Tallies (Unchanged)

| Metric | Value |
|--------|-------|
| VPs | 41 (VP-HOOK 024–036, VP-SKILL 001–077) |
| SMs allocated | 74 |
| SMs live | 73 (SM-50 retired-in-place, SM-55 reserved-skipped) |
| BATS (new, hooks/skills) | ~336 |

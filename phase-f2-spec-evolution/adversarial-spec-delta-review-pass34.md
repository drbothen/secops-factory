---
document_type: adversarial-review-report
level: L3
version: "1.0"
status: remediated
producer: adversary
timestamp: 2026-09-03T06:00:00Z
phase: F2
pass: 34
cycle: v0.10.0-feature-prism-integration
inputs: [phase-f2-spec-evolution/]
input-hash: "[live-state]"
traces_to: STATE.md
---

# F2 Adversarial Spec Review — Pass 34

**Date:** 2026-09-03
**Verdict:** PASS 34 — 0C / 0M / 2med / 0min / 1obs — NOT CLEAN
**Sixth consecutive 0C/0M pass. SUBSTANTIVE surface (kill-switch/hard-floor/STEP-ordering/D-029/12-18-split/NORMALIZE_SEVERITY/marker) independently re-derived and confirmed correct — zero logic defects.**
**Status:** REMEDIATED — burst-31 exhaustive count re-derivation

---

## Summary

| Severity | Count | IDs |
|----------|-------|-----|
| CRITICAL | 0 | — |
| MAJOR | 0 | — |
| MEDIUM | 2 | P34-001, P34-002 |
| MINOR | 0 | — |
| OBS | 1 | P34-OBS |
| **Total** | **3** | |

**Novelty:** LOW — both MEDs are mechanical count drift (EC/invariant tallies in prd-delta §1/§3/§8 stale for sub-burst-1 BCs). No new behavioral logic defects.

**Consecutive 0C/0M passes:** 6 (passes 29, 30, 31, 32, 33, 34) — deeply converged; blockers are mechanical coherence/count drift only.

**Clean streak:** 0/3 — pass 34 has 2med + 1obs (NOT clean per 0C/0M/0med/0min criterion).

---

## Findings

### P34-001 (MEDIUM) — prd-delta §1/§3/§8 EC counts stale for sub-burst-1 BCs

**Location:** prd-delta.md §1 "New Behavioral Contracts" table (per-BC EC column), §3 "Edge Case Catalog" footer (total EC count), §8 "Sub-Burst-1 Totals" table

**Finding:** The prd-delta EC counts for two sub-burst-1 BCs were stale after later remediation-pass additions:

- BC-6.01.003: §1 table EC count showed 8; actual count from BC file = 10 (EC-001..EC-010 confirmed). Delta: +2 ECs added in later remediation passes.
- BC-10.01.001: §1 table EC count showed 21; actual count from BC file = 22 (EC-001..EC-022 confirmed). Delta: +1 EC added (EC-022) in a later remediation pass.

Cascading effects:
- §1 Totals: EC total 51 → 54 (3 additional ECs).
- §3 edge-case footer: 51 → 54 (same 3 ECs).
- §8 sub-burst-1 EC total: 51 → 54.
- §8 cycle grand total: 75 → 78 (sub-burst-1 54 new + 24 pre-existing).

**Root cause:** §1/§3/§8 EC counts were not re-derived from the actual BC files when EC additions were made to sub-burst-1 BCs in later remediation passes. The §8 "sub-burst-1 totals" section only tracks additions to pre-existing modified BCs; NEW sub-burst-1 BCs that receive additional ECs during later adversary remediation passes fall into a tracking gap.

**Status:** REMEDIATED — burst-31 product-owner performed exhaustive per-BC recount from BC files. All §1/§3/§8 EC totals reconciled. prd-delta bumped to v1.34.

---

### P34-002 (MEDIUM) — prd-delta §1 invariant count stale for BC-6.01.003

**Location:** prd-delta.md §1 "New Behavioral Contracts" table (Invariants column for BC-6.01.003), §1 Totals row

**Finding:** The §1 invariant count for BC-6.01.003 showed 5; actual count from BC file = 6 (6 numbered list items in the ## Invariants section confirmed). Delta: +1 invariant added in a later remediation pass.

Cascading effects:
- §1 Totals: invariant total 36 → 37.

All other sub-burst-1 BC invariant counts confirmed correct: BC-6.01.004 6 inv ✓, BC-8.02.001 4 inv ✓, BC-9.01.001 5 inv ✓, BC-10.01.001 16 inv ✓.

**Root cause:** Same class as P34-001 — invariant count not re-derived from the actual BC file when an invariant was added to BC-6.01.003 in a later remediation pass.

**Status:** REMEDIATED — burst-31 product-owner corrected BC-6.01.003 invariant count 5→6. §1 Totals invariants 36→37. prd-delta bumped to v1.34.

---

### P34-OBS (OBS) — [process-gap] No automated recount gate re-derives §1/§3 per-BC EC/invariant counts from BC files for NEW BCs receiving later-pass additions

**Location:** Process — prd-delta §1/§3/§8 update workflow

**Observation:** The coherence-sweep discipline (Lesson 51) covers re-deriving version pins and §5 tracking-table cells from BC frontmatter. It does NOT cover re-deriving §1/§3 per-BC EC/invariant COUNTS from the actual BC files for sub-burst-1 BCs that receive EC or invariant additions in later remediation passes.

The §8 "sub-burst-1 totals" section only covers additions to pre-existing modified BCs (those present before the feature cycle). Sub-burst-1 BCs (NEW BCs authored during F2) that receive additional ECs/invariants during later adversary remediation passes are NOT reflected in §8's "additions" tracking; they are visible only by grep-counting from the BC file.

This process-gap has recurred 3× across the convergence run: EC-021 (v1.7 prd-delta), then EC-022 + EC-009/EC-010 additions, then Inv#6 for BC-6.01.003 (this pass, P34-002). The root cause is structural: the §8 addition-tracking mechanism was designed for modifications to pre-existing BCs, not for newly authored sub-burst-1 BCs.

**Standing rule (process codification, Lesson 52):** A full recount MUST grep-count EC rows and invariant headings from every BC file listed in §1 and reconcile ALL of §1/§3/§8 — not patch flagged cells. This is the count-analog of Lesson 51's version-agnostic sweep rule.

---

## Note on Substantive Convergence

Pass 34 is the sixth consecutive 0C/0M pass. The adversary independently re-derived and confirmed correct all substantive design elements: kill-switch/hard-floor gating, STEP ordering (STEP 3b → STEP 4 → STEP 4b → STEP 5 → STEP 6), D-029 markdown Document-Before-Action principle, 12-field vs 18-field path split, NORMALIZE_SEVERITY consistency check, marker anti-fungibility. Zero logic defects found.

All remaining findings are mechanical coherence/count drift — EC/invariant tallies in tracking tables not updated when BC content changes. The substantive design surface is confirmed converged.

**Human decision (2026-09-03): CONTINUE GRINDING.** DI-018 stays deferred to F3 boundary; no substantive-convergence shortcut invoked. Grinding continues until 3 consecutive clean passes (0C/0M/0med/0min).

---

## Tallies (Unchanged)

| Metric | Value |
|--------|-------|
| VPs | 41 (VP-HOOK 024–036, VP-SKILL 001–077) |
| SMs allocated | 74 |
| SMs live | 73 (SM-50 retired-in-place, SM-55 reserved-skipped) |
| BATS (new, hooks/skills) | ~336 |

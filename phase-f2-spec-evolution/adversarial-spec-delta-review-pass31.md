---
document_type: adversarial-spec-delta-review
pass: 31
producer: adversary
version: "1.0"
date: 2026-09-02
cycle: v0.10.0-feature-prism-integration
phase: f2
verdict: NOT-CLEAN
findings_summary: "0C / 0M / 1med / 1min / 3obs"
novelty: LOW-MEDIUM
clean_streak: "0/3 (third consecutive 0C/0M pass; deeply converged)"
status: REMEDIATED
remediation_burst: burst-28
---

# Adversarial Spec Delta Review — Pass 31

**Cycle:** v0.10.0-feature-prism-integration
**Phase:** F2 — Spec Evolution
**Date:** 2026-09-02
**Verdict:** NOT CLEAN — 0C / 0M / 1med / 1min / 3obs
**Novelty:** LOW–MEDIUM
**Status:** REMEDIATED — burst-28 complete; awaiting pass-32
**Note:** Third consecutive 0C/0M pass. Package is deeply converged; remaining
findings are enum-coherence propagation and documentation clarity only.

---

## Summary

Pass 31 found no Critical or Major findings. One Medium finding (VP-HOOK-025
`validate_enums()` prose cited a stale 6-member `ticket_action_type` enum;
authoritative BC-3.03.001 `ACTION_ENUM` has 8 members since D-020/D-021) and
one Minor finding (`autonomy_enabled` ALWAYS-PRESENT label vs tolerated-absent
at consumer — undocumented distinction from `org_slug` presence-deny semantics).
Three observations are positive coherence notes requiring no action. All
actionable findings remediated in burst-28.

---

## Findings

### P31-001 (MEDIUM): VP-HOOK-025 `ticket_action_type` membership enum stale

**Location:** verification-delta.md §3(a) `validate_enums()` mechanism prose (3 sites);
§2 VP-HOOK-025 row
**Severity:** MEDIUM
**Status:** REMEDIATED — burst-28 (verification-delta v1.33; 3 enforced-enum sites
reconciled to 8 members)

The `ticket_action_type` membership set in VP-HOOK-025's `validate_enums()`
prose and §2 mechanism cell enumerated only 6 members:
`{comment, create, assign, none, create-review, comment-review}`.
The authoritative `ACTION_ENUM` in BC-3.03.001 (~L190) includes `link` and
`close` (added at D-020/D-021, burst-15). BC-10.01.001 Invariant #9 field-15
and prd-delta field-15 also mirror the 8-member set.

**Impact:** An FV building the STEP-1 membership check from the stale 6-member
prose would fail-closed-DENY every legitimate autonomous `link`/`close` verdict.
This would make the D-020/D-021 close path and the D-026/D-027 orphan-link path
structurally unreachable — contradicting VP-HOOK-033/034/035/036 and
SM-61/72/74/75 kill vectors that presume both paths are reachable.

**Historical note:** Historical rows in verification-delta that cited the
4-member pre-D-020 subset (e.g., version annotations describing the enum as it
existed at v1.5) were intentionally left unchanged; only the three
enforced-membership enumeration sites were corrected.

**Remediation:** verification-delta v1.33 — three sites fixed:
1. §3(a) field-15 type-assertion evolution note: updated to record the D-020/D-021
   extension to the 8-member set with member names.
2. §3(a) `validate_enums()` membership-gate prose: `ticket_action_type ∈ {...}`
   corrected from 6 to 8 members.
3. §2 VP-HOOK-025 row `validate_enums()` mechanism cell: corrected to 8 members.

VP/SM tallies unchanged: VP 41 / SM 74 alloc, 73 live. VP-HOOK-033/034/035/036
confirmed to cover `link`/`close` paths.

---

### P31-002 (MINOR): `autonomy_enabled` ALWAYS-PRESENT label vs tolerated-absent at consumer

**Location:** BC-3.03.001 field-presence table; BC-10.01.001 Invariant #9;
prd-delta Verdict Schema Summary
**Severity:** MINOR
**Status:** REMEDIATED — burst-28 (BC-3.03.001 v1.41 ~L994; BC-10.01.001 v1.32
Inv#9 roster; prd-delta v1.32 presence-split annotation)

`autonomy_enabled` is labeled ALWAYS-PRESENT in the verdict schema summary across
prd-delta and BC field-presence tables. At the consumer (BC-3.03.001), absent
`autonomy_enabled` defaults to `false` — the field is tolerated-absent with a
safe default. This contrasts with `org_slug` (added in burst-26 as ALWAYS-PRESENT),
which is presence-denied at the consumer: missing `org_slug` → DENY, no fallback.

The distinction between:
- **Producer-obligation / consumer-default**: ALWAYS-PRESENT per schema completeness;
  consumer applies a safe default if absent
- **Producer-obligation / consumer-deny**: ALWAYS-PRESENT per schema completeness;
  consumer denies if absent (no fallback)

was undocumented. The label "ALWAYS-PRESENT" alone does not convey which enforcement
model applies at the consumer boundary.

**Remediation:** A producer-obligation-vs-consumer-enforcement clause was added to:
- BC-3.03.001 v1.41 (~L994): clarifies `autonomy_enabled` uses default-to-false fallback;
  `org_slug` uses presence-deny; no behavioral change
- BC-10.01.001 v1.32 Invariant #9 roster: annotation distinguishing the two ALWAYS-PRESENT
  fields' consumer-side enforcement models
- prd-delta v1.32 Verdict Schema Summary: presence-split annotation distinguishing
  default-fallback vs deny-on-absent ALWAYS-PRESENT fields

No behavioral change in any BC or VP. Existing code correctly implements both
semantics; documentation now makes the distinction explicit.

---

### P31-003 (OBSERVATION): `validate_enums()` coverage spans all 5 enum fields consistently

**Location:** verification-delta §3(a) VP-HOOK-025 coverage matrix
**Severity:** OBSERVATION
**Status:** No action required

`validate_enums()` covers all five enum fields (`ticket_action_type`, `disposition`,
`sensor_status`, `technique`, `scored_priority`) consistently. Each field has at
least one SM kill-vector (SM-1..SM-81 roster). No gaps detected. Positive coherence
note.

---

### P31-004 (OBSERVATION): D-020/D-021 `link`/`close` decision chain traceable end-to-end

**Location:** Decisions Log D-020/D-021 through D-028; BC-3.03.001; VP-HOOK-033..036
**Severity:** OBSERVATION
**Status:** No action required

The decision chain D-020 (link marker scope) → D-021 (close/move marker scope) →
D-022 (compound two-Write model) → D-023/D-025 (close-disposition gate) → D-026
(orphan-link recovery) → D-027 (two-tier link) → D-028 (defensive half) is fully
traceable from the Decisions Log through BCs through verification properties. No
traceability gaps. Positive coherence note.

---

### P31-005 (OBSERVATION): SM ledger at SM-81 well-organized; no orphaned entries

**Location:** verification-delta §3(a) SM roster
**Severity:** OBSERVATION
**Status:** No action required

SM roster SM-1..SM-81 (74 allocated, 73 live; SM-55 skipped, SM-50 retired-in-place)
is dense and well-organized. Each SM has a clear behavioral description and explicit
VP pairing. No orphaned, duplicated, or ambiguously-scoped entries. Positive
coherence note.

---

## Convergence Assessment

| Metric | Value |
|--------|-------|
| Total findings | 5 (1 med + 1 min + 3 obs) |
| Actionable findings | 2 (P31-001 medium, P31-002 minor) |
| Remediated | 2 (burst-28) |
| Clean pass? | NO — 2 actionable findings (med + minor) |
| Consecutive 0C/0M passes | 3 (passes 29, 30, 31) |
| Clean streak toward goal | 0/3 (no fully clean pass yet) |

**Note:** A pass qualifies as "clean" for the 3-of-3 convergence goal when it
has zero actionable findings (0C/0M/0med/0min). Observations only are allowed.
Pass 31 is 0C/0M but has 1med + 1min, so it does NOT count as a clean pass.

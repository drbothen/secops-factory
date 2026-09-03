---
document_type: adversarial-spec-delta-review
level: L3
version: "1.0"
status: closed
producer: adversary
timestamp: 2026-09-03T00:00:00Z
phase: f2
pass: 41
cycle: v0.10.0-feature-prism-integration
verdict: NOT CLEAN
findings_summary: "0C / 1M / 2med / 0min / 0obs"
clean_streak: 0/3
traces_to: STATE.md
---

# F2 Adversarial Spec Delta Review — Pass 41

**Verdict:** NOT CLEAN — 0 CRITICAL / 1 MAJOR / 2 MEDIUM / 0 MINOR / 0 OBS  
**Clean streak:** 0/3 (streak did not advance — P41-001 MAJOR blocks)  
**Date:** 2026-09-03  
**Spec content:** Frozen post-burst-39 (per-session spec-freeze policy); burst-40 remediates findings from this pass  
**Substance re-derivation:** all substance dimensions confirmed clean (5th consecutive 0C/0M pass)

---

## Summary of Findings

| ID | Severity | Category | Summary | Disposition |
|----|----------|----------|---------|-------------|
| P41-001 | MAJOR | PARTIAL-FIX PROPAGATION MISS | verification-delta §6 (L1949 strategy note + L1952 BATS-vector desc) still stated old unreachable watermark−GRACE threshold — internal contradiction vs corrected §1 row | REMEDIATED burst-40 |
| P41-002 | MEDIUM | PRE-EXISTING RESIDUAL (P12-003) | prd-delta field-18 known-FP fast-path: scored_priority set to raw NORMALIZE_SEVERITY output (SEVERITY_ENUM) — would fail validate_enums; must map via SEVERITY_TO_SCORED_PRIORITY_MAP | REMEDIATED burst-40 |
| P41-003 | MEDIUM | MISSING VALIDATION GUARD | DETECT_LATE_EVENT read raw watermark without READ_WATERMARK's RFC3339/future-date validation → corrupt/future watermark → LATE_EVENT_DETECTED flood (EC-002/EC-003 false-positive) | REMEDIATED burst-40 |

---

## P41-001 — MAJOR: verification-delta §6 Partial-Fix Propagation Miss

**Severity:** MAJOR (internal contradiction in a normative verification document — VP-SKILL-073 BATS vector consistency between §1 and §6)

**Root cause:** The burst-39/40 DETECT_LATE_EVENT threshold correction (`watermark−GRACE` → raw `stored_watermark`) was applied to verification-delta §1 (VP-SKILL-073 row and BC-10.01.001 version pins) but NOT propagated to §6. Specifically:

- **L1949** (§6 strategy note): still described the late-event detection condition as `event_time < stored_watermark − WATERMARK_GRACE_SECONDS` (old dead-code threshold)
- **L1952** (§6 BATS-vector description): still described the B-INT vector as injecting an event that satisfies `event_time < stored_watermark − GRACE` — the same unreachable condition that pass-40 identified as provably dead code

Both lines were internally contradicted by the corrected §1 VP-SKILL-073 row (which already stated the corrected `event_time < stored_watermark` threshold as of burst-39).

**Impact:** A BATS implementer reading §6 would execute a test vector that cannot fire the detector (the same false-green that P40-001 identified). The §1 fix was partial — §6 retained the defect verbatim.

**Fail-safe:** no runtime regression introduced (the live behavior was already corrected in BC-10.01.001 v1.34 by burst-39); §6 is a verification description, not an implementation spec. Risk: test vectors written from §6 would silently pass vacuously.

**REMEDIATED burst-40:** FV updated verification-delta v1.36→v1.37 — §6 L1949 strategy note and L1952 BATS-vector description corrected to reachable `event_time < stored_watermark` threshold. Additionally VP-SKILL-073 expanded with EC-002/EC-003 suppression vectors + SM-82/SM-83 for new EC-024.

---

## P41-002 — MEDIUM: prd-delta Field-18 Known-FP Fast-Path SEVERITY_ENUM → scored_priority Type Mismatch (P12-003 Residual)

**Severity:** MEDIUM (pre-existing P12-003 residual; not a new regression; bounded to the known-FP fast-path only)

**Root cause:** prd-delta field-18 description (`scored_priority`) specified that the known-FP fast-path sets `scored_priority` to the raw output of `NORMALIZE_SEVERITY` (which produces a `SEVERITY_ENUM` value: `{critical, high, medium, low, informational}`). However, `validate_enums()` checks `scored_priority` against `SCORED_PRIORITY_ENUM` = `{CRIT, HIGH, MED, LOW}` (uppercase, no `informational`). A raw `SEVERITY_ENUM` value would fail `validate_enums()` on every subsequent processing step that sees the field.

The correct mapping is via `SEVERITY_TO_SCORED_PRIORITY_MAP`: `critical→CRIT, high→HIGH, medium→MED, low→LOW, informational→LOW`. This map was already defined in D-011's two-field severity model but was not applied in the field-18 fast-path description.

**Impact:** prd-delta field-18 fast-path description, if implemented as written, would produce a `scored_priority` value that fails `validate_enums()` on the known-FP path — creating an unexpected ENUM_INVALID error condition on a path that is supposed to auto-close cleanly.

**REMEDIATED burst-40:** PO updated prd-delta v1.37→v1.38 — field-18 description corrected to specify `SEVERITY_TO_SCORED_PRIORITY_MAP` application on the known-FP fast-path.

---

## P41-003 — MEDIUM: DETECT_LATE_EVENT Missing Watermark Validation Guard

**Severity:** MEDIUM (new gap; bounded to corrupt/future-dated watermark scenarios)

**Root cause:** The burst-39/40 DETECT_LATE_EVENT implementation read `stored_watermark` directly for the comparison `event_time < stored_watermark` without first applying `READ_WATERMARK`'s RFC3339 format validation and future-date guard. Specifically:

- `READ_WATERMARK` validates that the watermark is RFC3339-parseable and not in the future before returning it for query use
- `DETECT_LATE_EVENT` bypassed this validation by reading the raw watermark field directly (or reusing a cached value without re-validating)
- A corrupt watermark (non-RFC3339) or a future-dated watermark (clock skew / initialization artifact) would cause:
  - **Corrupt:** comparison to an unparseable value → undefined behavior / exception, silently treating all events as late → LATE_EVENT_DETECTED flood (EC-002/EC-003 false-positive storm)
  - **Future-dated:** `event_time < stored_watermark` fires for ALL events (every real event is in the past relative to a future watermark) → EC-002/EC-003 flood

**Impact:** A corrupt or uninitialized watermark floods downstream consumers with false LATE_EVENT_DETECTED signals on every ingested event. EC-002/EC-003 are both alert-suppression paths — a flood could suppress legitimate security alerts.

**REMEDIATED burst-40:** Architect updated architecture-delta v1.32→v1.33 — DETECT_LATE_EVENT now reuses `READ_WATERMARK`'s RFC3339 + future-date validation; on validation failure returns early with `DETECT_LATE_EVENT_SUPPRESSED(WATERMARK_INVALID)` or `DETECT_LATE_EVENT_SUPPRESSED(WATERMARK_FUTURE)`. New error code EC-024 added (BC-10.01.001 v1.34→v1.35: Inv#14 validation guard, EC 23→24). VP-SKILL-073 expanded in verification-delta v1.37 with suppression vectors.

---

## Independent Re-derivation (Substance)

All spec substance confirmed clean (5th consecutive 0C/0M pass):
- STEP ordering (1a SEVERITY-MISMATCH → STEP 2 validate_enums → STEP 3b link-hard-floor → STEP 4 hard-floor-deny → STEP 4b close-disposition → STEP 5 kill-switch → STEP 6 scope-branch): CORRECT
- Kill-switch (autonomy_enabled) semantics and placement: CORRECT
- Hard-floor (HIGH/CRIT scored_priority) fail-loud deny: CORRECT
- Marker anti-fungibility and scope enumeration: CORRECT
- D-029 markdown hard-floor route-to-review-never-deny: CORRECT
- §3.4 correlation rules (1 comment, 2 create+link, 3 comment, 4 create+link): CORRECT
- NORMALIZE_SEVERITY per-sensor-family table completeness: CORRECT
- 12-field ICD-203 vs 18-field verdict split: CORRECT
- D-025 close-disposition gate at STEP 4b before kill switch: CORRECT
- D-028 hard-floor link review-class STEP 3b exemption: CORRECT
- BC-10.01.001 EC-001 through EC-023 internal consistency: CORRECT (post-burst-40 verification: EC-024 added)

---

## Versions After Burst-40 (Remediation)

**arch-delta v1.33** (DETECT_LATE_EVENT validation guard + DETECT_LATE_EVENT_SUPPRESSED; input-hash d7bcab4),
**BC-10.01.001 v1.35** (Inv#14 validation guard + EC-024; EC 23→24; input-hash a9a1c5c),
**prd-delta v1.38** (field-18 map fix; EC counts §1/§3 24, totals 56, §8 grand 80; §5 pin→v1.35; input-hash 3eaba2b),
**verification-delta v1.37** (§6 threshold corrected; VP-SKILL-073 expanded — EC-002/EC-003 suppression + 3 BATS vectors + SM-82/SM-83; SM tally 74→76 alloc, 73→75 live; 15 BC pins v1.34→v1.35),
BC-3.03.001 v1.42 (cross-ref pin → v1.35; no bump; input-hash de1ff1d),
BC-3.01.001 v1.25, BC-4.02.001 v1.21, BC-5.01.001 v1.15, dtu-assessment v1.7.
VP total **41** (21 FIN + 6 PROP = 27 scoped; §5 FINALIZED BATS unchanged);
SM **76 alloc / 75 live** (SM-82/SM-83 added — PROPOSED P1, NOT P0-counting).

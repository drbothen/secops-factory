---
document_type: adversarial-spec-delta-review
level: L3
version: "1.0"
status: closed
producer: adversary
timestamp: 2026-09-03T00:00:00Z
phase: f2
pass: 42
cycle: v0.10.0-feature-prism-integration
verdict: NOT CLEAN
findings_summary: "0C / 1M / 0med / 1min / 0obs"
clean_streak: 0/3
traces_to: STATE.md
---

# F2 Adversarial Spec Delta Review — Pass 42

**Verdict:** NOT CLEAN — 0 CRITICAL / 1 MAJOR / 0 MEDIUM / 1 MINOR / 0 OBS
**Clean streak:** 0/3 (streak did not advance — P42-001 MAJOR blocks)
**Date:** 2026-09-03
**Spec content:** Frozen post-burst-40; burst-41 remediates findings from this pass
**Substance re-derivation:** all substantive + coherence axes (EC counts 24/56/80, pins v1.35, field-18 SEVERITY_TO_SCORED_PRIORITY_MAP, §6 reachability, VP/SM) confirmed clean; 6th consecutive 0C/0M substance pass

---

## Summary of Findings

| ID | Severity | Category | Summary | Disposition |
|----|----------|----------|---------|-------------|
| P42-001 | MAJOR | INTRA-BC CONTRADICTION (absent-watermark coherence) | BC-10.01.001 burst-40 guard folded ABSENT watermark into DETECT_LATE_EVENT_SUPPRESSED trigger set (Inv#14 L625 + EC-024), contradicting EC-023's first-run early-return (which produces return-0-no-entry for absent — no audit entry of any kind) | REMEDIATED burst-41 |
| P42-002 | MINOR | CROSS-REF LABEL ERROR | EC-024 cross-reference label described EC-003 as "first-run" — EC-003 is the future-dated-watermark suppression path, not first-run | REMEDIATED burst-41 |

---

## P42-001 — MAJOR: BC-10.01.001 Absent-Watermark Coherence Contradiction

**Severity:** MAJOR (intra-BC logical contradiction on a normative precondition; the BC was the sole outlier across all artifacts)

**Root cause:** The burst-40 architect propagation prose for the P41-003 remediation stated the DETECT_LATE_EVENT_SUPPRESSED trigger set as "absent, non-RFC3339, or future-dated watermark." This prose was applied verbatim to BC-10.01.001 Inv#14 (line L625) and EC-024. However, the absent-watermark case is already handled by the first-run early-return at Inv#14 L624 / EC-023 (return 0, no audit entry of any kind). Including "absent" in the DETECT_LATE_EVENT_SUPPRESSED set creates a logical contradiction within the same invariant:

- **EC-023** (Inv#14 L624): absent watermark → first-run branch → return 0, no audit entry
- **EC-024** (Inv#14 L625, as written in burst-40): absent watermark → DETECT_LATE_EVENT_SUPPRESSED audit entry

Both outcomes cannot apply to the same absent-watermark input. The two ECs are mutually exclusive preconditions within the same invariant block; the absent branch fires first and returns — execution never reaches the validation guard block.

**Cross-artifact check:** All other artifacts were consistent:
- arch-delta pseudocode (L831 / EC-023): absent → first-run return-0-no-entry (no suppressed entry)
- prd-delta §3: validation guard applies to non-RFC3339 and future-dated only
- verification-delta SM-82/SM-83: DETECT_LATE_EVENT_SUPPRESSED triggered by EC-002/EC-003 only (non-RFC3339 or future-dated)

BC-10.01.001 was the sole outlier introduced by the burst-40 prose propagation.

**Impact:** A BC implementer reading Inv#14 would need to decide which of the two contradictory ECs governs the absent-watermark path. The contradiction introduces implementation uncertainty and could produce an audit log with an erroneous DETECT_LATE_EVENT_SUPPRESSED entry on first-run (where no entry is correct per EC-023 semantics and the arch-delta design intent).

**REMEDIATED burst-41:** product-owner removed "absent" from the DETECT_LATE_EVENT_SUPPRESSED trigger set at Inv#14 L625 + EC-024. Version stays v1.35 (text correction — no behavioral addition; the burst-40 addition was ill-formed). Input-hash unchanged (a9a1c5c — upstream source files arch-delta/prd-delta/verification-delta unchanged; burst-41 corrects a BC transcription error).

---

## P42-002 — MINOR: EC-024 Cross-Reference Label Error (EC-003 Mislabeled as "first-run")

**Severity:** MINOR (label error in a cross-reference annotation; does not affect the normative trigger condition)

**Root cause:** The EC-024 cross-reference annotation labeled EC-003 as "first-run." EC-003 is the future-dated-watermark suppression path. The first-run path is EC-023. EC-003 and EC-023 are distinct:
- EC-023: absent watermark → first-run return (no audit entry)
- EC-003: future-dated watermark → DETECT_LATE_EVENT_SUPPRESSED audit entry

A reader following the cross-reference would land on EC-023 (first-run) while the label said EC-003 was "first-run" — creating confusion about which EC governs future-dated behavior.

**Impact:** Label-only; the normative condition in EC-024 was otherwise correct (modulo P42-001). A reader relying on the label annotation for orientation could misroute their understanding of the future-dated path.

**REMEDIATED burst-41:** product-owner corrected the cross-reference label from "first-run" to "future-dated" within EC-024. No version bump.

---

## Substance Re-Derivation (6th Consecutive 0C/0M)

All substantive and coherence dimensions were independently verified clean:

- **EC counts:** BC-10.01.001 §1 24, §3 24, §8 total 56, grand 80 — consistent across all sites
- **Version pins:** arch-delta v1.33, prd-delta v1.38, verif-delta v1.37, BC-3.03.001 v1.42 — all cross-refs consistent
- **Field-18 SEVERITY_TO_SCORED_PRIORITY_MAP:** confirmed applied correctly in prd-delta §3 post-burst-40
- **§6 reachability:** verif-delta §6 BATS vectors confirmed reachable post-burst-40 correction
- **VP/SM tallies:** VP 41 in registry (21 FIN P0 + 6 PROP P1 = 27 active); SM 76 alloc / 75 live — unchanged
- **STEP ordering, kill-switch, hard-floor, marker mechanism, D-029, §3.4, NORMALIZE_SEVERITY, 12/18-split:** all clean

Findings P42-001 and P42-002 are both coherence-class (intra-BC contradiction and label error), not substance-class. The underlying design intent (absent→first-run-no-entry, non-RFC3339/future-dated→suppressed) was correct in all artifacts except BC-10.01.001.

---

## Versions After Burst-41 (Remediation)

**BC-10.01.001 v1.35** (text correction: absent removed from DETECT_LATE_EVENT_SUPPRESSED trigger set; EC-024 EC-003 label fixed to "future-dated"; no-bump; input-hash a9a1c5c — unchanged, upstream source files unmodified).

All other artifact versions unchanged: arch-delta v1.33, prd-delta v1.38, verification-delta v1.37, BC-3.03.001 v1.42, BC-3.01.001 v1.25, BC-4.02.001 v1.21, BC-5.01.001 v1.15, dtu-assessment v1.7.

VP **21 FIN + 6 PROP = 27** (41 in registry); SM **76 alloc / 75 live**. BATS: 113 (unchanged).

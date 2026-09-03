---
document_type: adversarial-spec-delta-review
level: L3
version: "1.0"
status: closed
producer: adversary
timestamp: 2026-09-03T00:00:00Z
phase: f2
pass: 43
cycle: v0.10.0-feature-prism-integration
verdict: NOT CLEAN
findings_summary: "0C / 0M / 3med / 0min / 2obs"
clean_streak: 0/3
traces_to: STATE.md
---

# F2 Adversarial Spec Delta Review — Pass 43

**Verdict:** NOT CLEAN — 0 CRITICAL / 0 MAJOR / 3 MEDIUM / 0 MINOR / 2 OBS
**Clean streak:** 0/3 (streak did not advance — 3 MEDIUM findings block)
**Date:** 2026-09-03
**Spec content reviewed:** burst-41 state (arch-delta v1.33, BC-10.01.001 v1.35, prd-delta v1.38, verification-delta v1.37, BC-3.03.001 v1.42)
**Substance re-derivation:** all substantive + coherence axes (STEP ordering, kill-switch, hard-floor, marker mechanism, D-029, §3.4, field-18 map, EC counts 24/56/80, VP/SM tallies) confirmed clean; 7th consecutive 0C/0M substance pass

---

## Summary of Findings

| ID | Severity | Category | Summary | Disposition |
|----|----------|----------|---------|-------------|
| P43-001 | MEDIUM | VP @TEST-NAME ENCODING STALE BOUNDARY | VP-SKILL-073 BATS vectors in verification-delta retained `@test-name` strings encoding the retired `watermark−GRACE` boundary — false-green re-encode risk for any implementer extracting test names | REMEDIATED burst-42 |
| P43-002 | MEDIUM | PER-EVENT SUPPRESSION FLOOD (P41-003 RELABELED) | DETECT_LATE_EVENT_SUPPRESSED audit entry was still emitted once per fetched event inside the per-event loop — P41-003 validation-guard was added but the cardinality of audit writes remained O(events-per-run) rather than the promised singular-per-run | REMEDIATED burst-42 (once-per-run VALIDATE_WATERMARK_FOR_RUN gate) |
| P43-003 | MEDIUM | VERSION-TRAIL INCOHERENCE (NO-BUMP ACCUMULATION DEBT) | EC-024 burst changelog tagged P42 but BC was still v1.35 with no modified-entry; burst-41 text correction produced no distinguishable version record; combined with burst-40's original EC-024 introduction, the version trail no longer permitted attribution of P42-001/P42-002 corrections | REMEDIATED burst-42 (clean v1.36 bump consolidating P42-001/P42-002 + P43-001/P43-002 with reconciled attributions) |
| P43-OBS-1 | OBS | DETECT_LATE_EVENT SHAKE-OUT PATTERN | Five consecutive passes (39→43) each found incremental hardening gaps in the once-per-run DETECT_LATE_EVENT gate; suggests that genuinely new multi-step behaviors warrant a pre-propagation completeness checklist (once-per-run cardinality, @test-name currency, version-trail debt) | NOTED |
| P43-OBS-2 | OBS | NO-BUMP ACCUMULATION PRACTICE | Consecutive text-only no-bump corrections (burst-41) followed by a substantive burst (burst-42) with no interim version record make attribution harder; a no-bump journal annotation or a deliberate bump at the second correction prevents version-trail debt of P43-003 class | NOTED |

---

## P43-001 — MEDIUM: VP-SKILL-073 @test Names Encoding Retired watermark−GRACE Boundary

**Severity:** MEDIUM (false-green re-encode risk; a BATS implementer extracting test names would produce vacuous tests targeting an unreachable condition)

**Root cause:** The burst-39 VP-SKILL-073 expansion added four BATS vectors to verification-delta with `@test-name` annotations. The original vector descriptions correctly stated the `event_time < stored_watermark` reachability correction (P40-001). However the `@test` name strings themselves still encoded `watermark-grace` in the test identifier — e.g., `@test "detect-late-event-below-grace"` — reflecting the retired `event_time < stored_watermark−GRACE` threshold that was unreachable. A BATS implementer following `@test` names would produce vacuous test cases that never fire (the grace-floor boundary is the INGEST query floor, not reachable from ingested events).

The body text of each vector correctly described the reachable condition; only the `@test` name strings embedded the stale boundary label. This created an inconsistency between the descriptive name and the normative condition.

**Cross-artifact check:** arch-delta pseudocode (v1.33/v1.34) consistently used `stored_watermark` as the DETECT_LATE_EVENT threshold. prd-delta EC-023 and BC-10.01.001 Inv#14 both stated `stored_watermark`. The inconsistency was isolated to `@test` name strings in verification-delta BATS vector annotations.

**Impact:** Any BATS test suite mechanically named from `@test` strings in VP-SKILL-073 would target `stored_watermark−GRACE` (unreachable) rather than `stored_watermark` (reachable). The resulting test suite would be vacuously green on any correct implementation — a false-green re-encode of the P40-001 bug that the vectorwas designed to prevent.

**REMEDIATED burst-42:** formal-verifier corrected VP-SKILL-073 `@test` name strings from `watermark-grace`-style identifiers to `stored-watermark`-style identifiers aligned with the normative `event_time < stored_watermark` condition. VP-SKILL-073 remains PROPOSED P1 (no status change; no P0-count change). 4 BATS vectors updated (PROPOSED, not finalized into BATS count).

---

## P43-002 — MEDIUM: DETECT_LATE_EVENT_SUPPRESSED Emitted Per-Event (P41-003 Relabeled, Not Eliminated)

**Severity:** MEDIUM (audit log corruption under corrupt/future watermark; O(events-per-run) suppression entries rather than one per run; flood persists indefinitely per D-DEC-002 monotonic-write guard)

**Root cause:** The burst-40 arch-delta v1.33 P41-003 remediation added a validation guard inside DETECT_LATE_EVENT() that early-returned with a DETECT_LATE_EVENT_SUPPRESSED audit entry when the watermark was non-RFC3339 or future-dated. This fixed the flood in the sense that events were no longer logged as LATE_EVENT_DETECTED — but the DETECT_LATE_EVENT_SUPPRESSED audit entry itself was written inside the per-event loop body. Under a corrupt or future-dated watermark, READ_WATERMARK falls back to 24h and returns up to 24h of events. DETECT_LATE_EVENT() is then called once per fetched event, emitting one DETECT_LATE_EVENT_SUPPRESSED entry per event per run.

The EC-024 wording ("an audit entry … for that run") and arch-delta prose both implied a singular entry per run. The pseudocode placed the write inside the per-event loop. This is a design-prose-vs-pseudocode cardinality contradiction: the prose promised singular; the pseudocode delivered O(events/run). P41-003 eliminated the LATE_EVENT_DETECTED flood but substituted a DETECT_LATE_EVENT_SUPPRESSED flood of the same O(events/run) magnitude.

**Cross-artifact check:** BC-10.01.001 EC-024 stated "emits audit entry DETECT_LATE_EVENT_SUPPRESSED" without cardinality qualifier. prd-delta §3 similarly unqualified. verification-delta SM-82 stated "emits exactly one DETECT_LATE_EVENT_SUPPRESSED" — the SM was CORRECT and in contradiction with the arch-delta pseudocode. This cross-artifact inconsistency is the defining symptom of P43-002.

**Impact:** A corrupt or future-dated watermark scenario causes indefinite DETECT_LATE_EVENT_SUPPRESSED audit flooding (O(events) per run × indefinite runs, since D-DEC-002 prevents overwrite of the corrupt watermark). Audit log grows without bound; audit consumers reading suppression entries would see thousands of entries for a single watermark corruption event. The SM-82 specification intent (one entry / diagnostic signal) is defeated.

**REMEDIATED burst-42:** architect hoisted watermark validation to VALIDATE_WATERMARK_FOR_RUN() — a once-per-run gate called before the per-event ingest loop. VALIDATE_WATERMARK_FOR_RUN reads and validates the stored watermark, sets a run-scoped `late_event_enabled` flag and `late_event_threshold`, and on invalid/future watermark emits exactly ONE DETECT_LATE_EVENT_SUPPRESSED entry (reason=WATERMARK_INVALID or WATERMARK_FUTURE). DETECT_LATE_EVENT() is now a pure per-event comparator: if `late_event_enabled=false` → return 0 (no-op, no write); if true → compare and log only if below threshold. First-run (no watermark file) → `late_event_enabled=false` with NO suppressed entry (P42-001 preserved). PO propagated to BC-10.01.001 Inv#14 + EC-024 (once-per-run cardinality clause). FV propagated to VP-SKILL-073 + SM-82/SM-83 (cardinality addendum).

---

## P43-003 — MEDIUM: Version-Trail Incoherence (No-Bump Accumulation Debt)

**Severity:** MEDIUM (version-trail incoherence; EC-024 in BC-10.01.001 does not have a distinguishable modification record; attribution of P42-001/P42-002 corrections is unrecoverable from version history alone)

**Root cause:** burst-40 introduced EC-024 and set BC-10.01.001 to v1.35. burst-41 made a text-only correction (removed "absent" from trigger set, corrected EC-003 label) with an explicit no-bump decision — "text correction — no behavioral addition." By pass-43, BC-10.01.001 was still v1.35 with a single changelog entry for both the original introduction (burst-40) and the correction (burst-41 no-bump). The version trail showed no distinct "modified" record for the P42-001/P42-002 corrections.

This created two problems:
1. EC-024 in v1.35 had been substantively corrected (absent removed) with no distinguishable record — a future reader of the v1.35 changelog would not know that EC-024's original burst-40 text was incorrect and was later fixed.
2. P43-001 (once-per-run cardinality) and P43-002 (per-event flood) were both additional EC-024-adjacent corrections requiring another round of BC changes — performing these as another no-bump would make the version trail completely opaque about which change was introduced when.

**Impact:** Version trail opacity complicates incident review and specification audit. EC-024 appears stable in v1.35 but carries two rounds of corrections that are invisible from version history.

**REMEDIATED burst-42:** PO performed a clean v1.36 bump consolidating P42-001/P42-002 (burst-41 no-bump text corrections) + P43-001/P43-002 (once-per-run cardinality) into a single attributable changelog entry with full attribution. The input-hash was recomputed to 742b491 reflecting the substantive once-per-run cardinality change (arch-delta v1.34 as source). Version-trail debt eliminated; all four corrections attributable to the v1.35→v1.36 transition.

---

## P43-OBS-1 — OBS: DETECT_LATE_EVENT Shake-Out Pattern (5 Consecutive Passes)

**Category:** PROCESS OBSERVATION

The DETECT_LATE_EVENT feature was added in pass 39 (burst-38) and required incremental hardening over 5 consecutive adversarial passes (39→43). Each pass found a distinct class of gap:

| Pass | Finding class | Corrected |
|------|--------------|-----------|
| 39 | Feature entirely absent from BC | burst-38 added |
| 40 | Double-GRACE dead code + false-green VP-073 vector | burst-39 corrected threshold |
| 41 | Missing validation guard → flood | burst-40 added DETECT_LATE_EVENT_SUPPRESSED |
| 42 | Absent-watermark intra-BC contradiction | burst-41 no-bump removed absent |
| 43 | @test-name stale boundary + per-event flood (P41-003 relabeled) + version-trail debt | burst-42 once-per-run gate + v1.36 bump |

This pattern suggests that genuinely new multi-step behaviors warrant a pre-propagation completeness checklist: (a) once-per-run vs per-event cardinality verified in arch-delta pseudocode AND BC prose AND VP/SM tally; (b) `@test` name strings verified against the normative condition, not the textual description; (c) version-trail discipline assessed before choosing no-bump.

---

## P43-OBS-2 — OBS: No-Bump Accumulation Practice

**Category:** PROCESS OBSERVATION

Burst-41 used a no-bump text correction. Burst-42's once-per-run cardinality changes are substantive, warranting a clean bump. The burst-41 no-bump was appropriate at the time (transcription-error correction of an upstream source file that had not changed). However the combination — burst-40 original EC-024 introduction + burst-41 no-bump correction — means v1.35 is effectively a "composite" version whose changelog entry describes the original intent rather than the corrected state.

Practice note: when a no-bump text correction is made, annotate the single changelog entry with a `[text correction: burst-NNN]` suffix to preserve attribution without inflating the version counter.

---

## Substance Re-Derivation (7th Consecutive 0C/0M)

All substantive and coherence dimensions were independently verified clean at the burst-41 spec state:

- **EC counts:** BC-10.01.001 §1 24, §3 24, §8 total 56, grand 80 — consistent
- **Version pins (at review time):** arch-delta v1.33, prd-delta v1.38, verif-delta v1.37, BC-3.03.001 v1.42 — consistent
- **field-18 SEVERITY_TO_SCORED_PRIORITY_MAP:** applied correctly in prd-delta §3 (P41-002 remediation verified intact)
- **§6 reachability:** verif-delta §6 BATS vectors confirmed reachable (P41-001 remediation verified intact)
- **VP/SM tallies:** VP 41 in registry (21 FIN P0 + 6 PROP P1 = 27 active); SM 76 alloc / 75 live — unchanged
- **STEP ordering, kill-switch, hard-floor, marker mechanism, D-029, §3.4, NORMALIZE_SEVERITY, 12/18-split:** all clean
- **DETECT_LATE_EVENT design intent:** absent→first-run-no-entry (EC-023), non-RFC3339/future-dated→suppressed (EC-024) — correct across arch-delta and prd-delta; BC-10.01.001 corrected by burst-41

P43-001/002/003 are all class: DETECT_LATE_EVENT once-per-run hardening + version-trail discipline. Substance (security model, invariant logic, marker authorization, verification properties) is 7th consecutive 0C/0M.

---

## Versions After Burst-42 (Remediation)

**arch-delta v1.34** (once-per-run VALIDATE_WATERMARK_FOR_RUN gate; per-event DETECT_LATE_EVENT no-op when late_event_enabled=false; exactly ONE DETECT_LATE_EVENT_SUPPRESSED per run on invalid/future watermark; input-hash d7bcab4).

**BC-10.01.001 v1.36** (Inv#14 once-per-run VALIDATE_WATERMARK_FOR_RUN propagated; EC-024 singular-per-run cardinality clause; @test names corrected P43-001; version-trail consolidation P43-003; EC count UNCHANGED at 24; input-hash 742b491).

**prd-delta v1.39** (§5 BC-10.01.001 "New Version" v1.35→v1.36; no §1/§3/§8 count changes; input-hash 1c4be4c).

**verification-delta v1.38** (VP-SKILL-073 cardinality addendum; 4 BATS vectors @test names corrected P43-001 — PROPOSED P1; SM-82/SM-83 REDEFINED once-per-run cardinality, ids retained, tally 76 alloc / 75 live UNCHANGED; 15 BC-10.01.001 pins v1.35→v1.36; no input-hash frontmatter field — DI-018).

**BC-3.03.001 v1.42** (cross-ref pin updated to v1.36; no version bump; input-hash 95fcec5).

VP **21 FIN + 6 PROP = 27** (41 in registry); SM **76 alloc / 75 live** (SM-82/SM-83 PROPOSED P1, NOT P0-counting). BATS: 113 (unchanged — VP-SKILL-073 PROPOSED P1; §5 FINALIZED BATS unchanged).

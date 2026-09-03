---
document_type: adversarial-spec-delta-review
level: L3
version: "1.0"
status: closed
producer: adversary
timestamp: 2026-09-03T00:00:00Z
phase: f2
pass: 40
cycle: v0.10.0-feature-prism-integration
verdict: NOT CLEAN
findings_summary: "0C / 1M / 1med / 0min / 2obs"
clean_streak: 0/3
traces_to: STATE.md
---

# F2 Adversarial Spec Delta Review — Pass 40

**Verdict:** NOT CLEAN — 0 CRITICAL / 1 MAJOR / 1 MEDIUM / 0 MINOR / 2 OBS  
**Clean streak:** 0/3 (streak did not advance)  
**Date:** 2026-09-03  
**Spec content:** FROZEN post-burst-38 (per-session spec-freeze policy)  
**Substance re-derivation:** all substance dimensions confirmed clean (4th consecutive 0C/0M pass)

---

## Summary of Findings

| ID | Severity | Category | Summary | Disposition |
|----|----------|----------|---------|-------------|
| P40-001 | MAJOR | GENUINE LOGIC DEFECT | DETECT_LATE_EVENT threshold provably unreachable — double-GRACE dead code | REMEDIATED burst-39 |
| P40-002 | MEDIUM | COUNT PROPAGATION MISS | prd-delta §1 EC cell stale at 22 (vs 23 in §3/§8/totals/BC); §1 sum 54≠Totals 55 | REMEDIATED burst-39 |
| OBS-1 | OBS | PROCESS GAP | New review axis identified: predicate reachability vs upstream query/filter | Codified Lesson 56 |
| OBS-2 | OBS | PROCESS GAP | Pass-40 confirms all 5 prior coherence dimensions clean; reachability is the 6th axis | Codified Lesson 56 |

---

## P40-001 — MAJOR: DETECT_LATE_EVENT Threshold PROVABLY UNREACHABLE (Double-GRACE Dead Code)

**Severity:** MAJOR (not CRITICAL — fail-safe: events are never dropped; only the late-event signal is dead)

**Root cause:** The burst-38 DETECT_LATE_EVENT implementation (BC-10.01.001 Inv#14, EC-023, VP-SKILL-073) used the threshold:

```
event_time < stored_watermark − WATERMARK_GRACE_SECONDS
```

But the Stage-1 INGEST query floor (D-DEC-002, architecture-delta §8.14) reads:

```
SELECT * FROM events WHERE _time > stored_watermark − WATERMARK_GRACE_SECONDS
```

These two conditions are the COMPLEMENT of each other on the same `WATERMARK_GRACE_SECONDS` term. An ingested event satisfies:

```
event_time > stored_watermark − GRACE   (INGEST query floor — required to appear in results)
```

The DETECT_LATE_EVENT detector fired on:

```
event_time < stored_watermark − GRACE   (fire condition)
```

The intersection of these two sets is empty. No event that passes the INGEST query floor can ever satisfy the DETECT_LATE_EVENT fire condition. LATE_EVENT_DETECTED was **provably dead code** — the signal could never fire. VP-SKILL-073's BATS vector (which tested `event_time < stored_watermark − GRACE`) was **vacuous/false-green**: it could never inject a real late-event from the ingest path.

**Why it survived 40 passes:** Prior passes reconciled the late-event SITES to each other (within BC, architecture-delta, and verification-delta) but never validated the fire condition against the upstream INGEST query floor. The coherence axes in Lessons 51–55 reconcile site-to-site within the spec corpus; none prescribes a reachability check against the query/filter that produces the events being evaluated.

**Root bug:** D-DEC-002 in architecture-delta.md — the DETECT_LATE_EVENT threshold was specified incorrectly from the start.

**Fail-safe:** Events are never dropped (log-not-drop semantics from D-DEC-002). The dead code means late events pass silently without a log entry — an observability gap, not a data loss event. Degraded to MAJOR from potential CRITICAL on this basis.

**REMEDIATED burst-39:**
- architecture-delta v1.31→v1.32: D-DEC-002 threshold corrected to raw watermark (`event_time < stored_watermark`). Fire set = `(stored_watermark−GRACE, stored_watermark)` — the grace re-fetch window — non-empty and reachable for every genuine late arrival.
- BC-10.01.001 v1.33→v1.34: Inv#14 sub-step and EC-023 threshold updated (`event_time < stored_watermark`).
- verification-delta v1.35→v1.36: VP-SKILL-073 vector corrected — the B-INT vector now injects an event in the grace re-fetch window (`event_time < stored_watermark` AND `event_time ≥ stored_watermark−GRACE`), which is genuinely reachable from the INGEST query. False-green retired.

---

## P40-002 — MEDIUM: prd-delta §1 EC Cell Stale at 22 (Count Propagation Miss from Burst-38)

**Severity:** MEDIUM (count inconsistency; no behavioral consequence)

**Finding:** prd-delta §1 BC-10.01.001 EC cell showed 22 while:
- §3 EC row for BC-10.01.001: 23 (correct — reflects EC-023 added in burst-38)
- §8 sub-burst-1 EC total: 55 (correct)
- §8 Totals row: 55 (correct)
- BC-10.01.001 itself: 23 ECs (correct)

Burst-38 (which added EC-023) updated §3 and §8 but missed the §1 EC cell. The §1 sum was 54 (= Totals 55 − 1 propagation miss).

**REMEDIATED burst-39:** prd-delta v1.36→v1.37 — §1 EC cell 22→23, §1 EC sum corrected to 55=55 (all sections now agree).

---

## OBS-1 [process-gap] — NEW REVIEW AXIS: Predicate Reachability vs Upstream Query/Filter

P40-001 survived 40 passes because the coherence axes (Lessons 51–55) reconcile spec SITES to each other. None prescribes a **reachability check**: for any per-event predicate/detector/guard, verify that its trigger condition is satisfiable given the upstream query's WHERE clause that produces its input events.

The specific pattern: if an upstream query selects events satisfying `condition_A`, and a downstream detector fires on `NOT condition_A` (the complement), the detector is dead code. This is not a contradiction detectable by version-pin sweeps, EC count audits, VP attribution checks, VP-lifecycle-status checks, or architecture→BC propagation checks — it requires reasoning about the SATISFIABILITY of the fire condition against the input domain.

**Codified as Lesson 56** (6th coherence/verification axis, extending Lessons 51–55).

---

## OBS-2 [process-gap] — All 5 Prior Coherence Dimensions Confirmed Clean

Independent re-derivation confirms all 5 prior coherence axes clean post-burst-38:
1. Version pins (Lesson 51): all BC pins in prd-delta/verif-delta at v1.33 — CLEAN (after verif-delta v1.35 cascade)
2. EC/invariant counts (Lesson 52): BC-10.01.001 EC count 23 confirmed — CLEAN (§3/§8 correct)
3. VP attribution (Lesson 53): VP-SKILL-073/074 ownership anchored in BC-10.01.001 — CLEAN (burst-38)
4. VP lifecycle status (Lesson 54): VP-SKILL-073/074 PROPOSED P1 in all sites — CLEAN
5. Architecture→BC propagation (Lesson 55): D-DEC-002 DETECT_LATE_EVENT behavior now in BC-10.01.001 Inv#14 — CLEAN (burst-38)

The only finding is the reachability defect (6th axis) + one count-propagation miss (§1 EC cell).

Substance dimensions: STEP ordering, kill-switch/hard-floor/marker mechanism, D-029 routing, §3.4 rules, NORMALIZE_SEVERITY, 12/18-split, spec-vs-intent — all confirmed clean (4th consecutive 0C/0M pass).

---

## Versions at Pass-40 (pre-burst-39)

| Artifact | Version | Notes |
|----------|---------|-------|
| architecture-delta | v1.31 | D-DEC-002 threshold still at double-GRACE (root bug) |
| BC-10.01.001 | v1.33 | DETECT_LATE_EVENT sub-step at double-GRACE threshold |
| prd-delta | v1.36 | §1 EC cell stale at 22; §3/§8 correct at 23/55 |
| verification-delta | v1.35 | VP-SKILL-073 vector at double-GRACE (false-green) |

## Versions After Burst-39 (remediation)

| Artifact | Version | Notes |
|----------|---------|-------|
| architecture-delta | v1.32 | D-DEC-002 threshold corrected: raw watermark |
| BC-10.01.001 | v1.34 | Inv#14/EC-023 threshold corrected; input-hash 650e111 |
| prd-delta | v1.37 | §1 EC cell 23; §1 sum 55=Totals 55; input-hash 6908b94 |
| verification-delta | v1.36 | VP-SKILL-073 vector corrected; 15 BC pins v1.33→v1.34 |
| BC-3.03.001 | v1.42 | Cross-ref pin to BC-10.01.001 v1.34 (no semantic bump) |
| BC-3.01.001 | v1.25 | UNCHANGED |
| BC-4.02.001 | v1.21 | UNCHANGED |
| BC-5.01.001 | v1.15 | UNCHANGED |
| dtu-assessment | v1.7 | UNCHANGED |

VP tallies: **21 FINALIZED P0 + 6 PROPOSED P1 = 27 total** (41 in registry)  
SM tallies: 74 allocated / 73 live  
BATS: 113 (unchanged — VP-SKILL-073 is PROPOSED P1, not FINALIZED; no new test added)  
Convergence-gate (P0 FINALIZED) count: **21 UNCHANGED**

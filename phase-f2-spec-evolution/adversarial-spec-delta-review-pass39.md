---
document_type: adversarial-spec-delta-review
pass: 39
result: NOT CLEAN
date: 2026-09-03
producer: adversary
cycle: v0.10.0-feature-prism-integration
phase: F2
findings_total: 5
findings_critical: 0
findings_major: 0
findings_medium: 1
findings_minor: 0
findings_obs: 4
novelty: MEDIUM
clean_streak: "0/3"
input-hash: "[live-state]"
---

# Adversarial Spec Delta Review — Pass 39

**Verdict: PASS 39 — 0C / 0M / 1med / 0min / 4obs — NOT CLEAN**
**Clean streak: 0/3 — RESET (P39-001 MEDIUM breaks streak attempt)**
**Novelty: MEDIUM — P39-001 is a SUBSTANTIVE spec gap (missing behavior), not a coherence defect**

---

## Summary

Pass 39 reviews the spec corpus after burst-37's comprehensive VP-status-agreement
sweep (prd-delta v1.35, verif-delta v1.34, BC-10.01.001 v1.32, BC-3.03.001 v1.42,
BC-3.01.001 v1.25). Spec substance independently re-derived from source-of-truth
BCs and architecture-delta: STEP ordering, kill-switch/hard-floor, marker mechanism,
D-029 routing, §3.4 correlation rules, NORMALIZE_SEVERITY, 12/18-field split,
all confirmed correct.

One MEDIUM finding identified: VP-SKILL-073 and VP-SKILL-074 are assigned to
BC-10.01.001 in verification-delta §1 as the owning BC, but the DETECT_LATE_EVENT
behavior that VP-SKILL-073 covers (and the per-sensor-family normalization behavior
that VP-SKILL-074 covers) are either absent or not properly anchored in
BC-10.01.001. The sharper diagnosis: VP-SKILL-073's DETECT_LATE_EVENT
late-event-detection behavior (D-DEC-002 RESOLVED, ADV-F2-P6-007 MINOR) is
entirely MISSING from BC-10.01.001's invariant/EC set — the behavior was allocated
in architecture-delta and registered in verification-delta §1 but never propagated
into the owning BC's behavior specification. This is a 25+ pass oversight in the
§8.14.3 PO propagation list.

Architect adjudicated IN-SCOPE (no human escalation required). **REMEDIATED burst 38.**

---

## Finding: P39-001

**ID:** P39-001
**Severity:** MEDIUM — SUBSTANTIVE (not a coherence defect)
**Title:** VP-SKILL-073/074 orphaned — DETECT_LATE_EVENT behavior missing from BC-10.01.001

### Description

Verification-delta §1 assigns VP-SKILL-073 (DETECT_LATE_EVENT late-event-detection)
and VP-SKILL-074 (NORMALIZE_SEVERITY per-sensor-family anchor) to BC-10.01.001 as
their owning BC. Both VPs are marked PROPOSED P1.

**VP-SKILL-073 (sharper diagnosis):** The DETECT_LATE_EVENT behavior that
VP-SKILL-073 is intended to verify is ENTIRELY ABSENT from BC-10.01.001's
behavioral specification:
- Inv#14 (Stage-1 INGEST sub-steps) has no sub-step for late-event detection.
- The BC has no EC covering the "event older than watermark minus GRACE" case.
- The VP Anchors footer for BC-10.01.001 does not list VP-SKILL-073.

This is not a traceability gap — it is a missing behavior. D-DEC-002 (architecture-
delta) specifies the DETECT_LATE_EVENT design obligation, and ADV-F2-P6-007 MINOR
recorded that VP-SKILL-073 was allocated to cover it. But the §8.14.3 PO
propagation list that should have added the behavior to BC-10.01.001 omitted
VP-SKILL-073 while including VP-SKILL-074 (its sibling from the same pass-6
resolution cycle). The behavior has lived only in architecture-delta for 25+
adversarial passes.

**VP-SKILL-074:** Similarly not anchored in BC-10.01.001's VP table or VP Anchors
footer, though the NORMALIZE_SEVERITY behavior it covers is substantively present
in Inv#9.

**Why MEDIUM (not CRITICAL/MAJOR):** D-DEC-002 is RESOLVED status (architecture
decision made, design documented). The missing behavior is in the BC specification
only, not an unrecognized design gap. The DETECT_LATE_EVENT behavior is well-defined
in architecture-delta; adding it to BC-10.01.001 is a propagation task, not a
new design decision.

### Remediation

Architect adjudicated IN-SCOPE. **REMEDIATED burst 38:**
- BC-10.01.001 v1.32 → v1.33: DETECT_LATE_EVENT sub-step added to Inv#14 Stage-1
  INGEST (log-not-drop events older than watermark−GRACE; first-run early-return;
  D-DEC-002 reference); EC-023 added (late-event-below-grace → logged-not-dropped);
  VP-SKILL-073 + VP-SKILL-074 anchored in Verification Properties table + VP
  Anchors footer.
- prd-delta v1.35 → v1.36: §1 VP total 25→27 (21 FIN + 6 PROP; BC-10.01.001
  now carries 13 FIN + 4 PROP); §3 BC-10.01.001 EC count 22→23; §3 footer 54→55;
  §8 grand total 78→79; §5 BC-10.01.001 tracking cell → v1.33.
- verification-delta v1.34 → v1.35: 15 live BC-10.01.001 version pins v1.32→v1.33;
  VP/SM tallies UNCHANGED (41 / 74 alloc / 73 live — VP-073/074 already counted;
  PROPOSED P1 not included in P0-counting); §5 BATS count unchanged (113).

**Input-hashes after burst 38 (verified):**
- BC-10.01.001: `28e1a97` (UNCHANGED — input files unchanged; BC own-content changed)
- prd-delta: `fc9285c` (recomputed — BC-10.01.001 is an input to prd-delta and changed)
- BC-3.03.001: `0929570` (UNCHANGED — no input file changes)

---

## Observations (non-blocking process notes)

**OBS-1:** This is the first burst in the pass-29–39 sequence to add REAL behavior
to a spec (not a coherence correction). The 29–38 sequence was exclusively
coherence/traceability fixes (version pins, EC counts, VP attribution, VP status).
Burst 38 is a genuine spec improvement — DETECT_LATE_EVENT was an omitted behavior.

**OBS-2:** The root cause pattern is identical to Lessons 51–54 (re-deriving from
summary rather than source of truth) but in the architecture→BC dimension: the
§8.14.3 propagation list serves as a SUMMARY of architecture decisions requiring
BC propagation; the SOURCE OF TRUTH is the architecture-delta D-DEC entries
themselves plus their associated VP allocations. The propagation list omitted
VP-SKILL-073 while the architecture-delta D-DEC-002 entry was present and marked
RESOLVED.

**OBS-3:** A VP with an assigned owning-BC in verification-delta §1 MUST have its
behavior present in that BC. The two-part test: (a) the VP's property description
must correspond to a named invariant/EC/postcondition in the BC, AND (b) the VP
ID must appear in the BC's VP Anchors footer. Neither was satisfied for VP-SKILL-073
prior to burst 38.

**OBS-4:** The coherence dimensions swept since pass-29 (version pins, EC/invariant
counts, VP-ownership, VP-lifecycle-status) are all CLEAN post-burst-37/38. This
burst adds a fifth dimension: architecture-delta D-DEC behavior-propagation
completeness. Codified as Lesson 55.

---

## Substance Re-derivation (independent of P39-001)

All spec substance independently re-derived CLEAN:

- **STEP ordering** (STEP 0 file-type → STEP 1 markdown path → STEP 1a SEVERITY-MISMATCH → STEP 2 stale-marker → STEP 3 hard-floor-link → STEP 3b STEP4b STEP5 STEP6): correct.
- **Kill-switch / hard-floor gate**: autonomy_enabled absent/≠true → allow-without-marker (STEP 5); hard_floor_applies() → deny (STEP 4, hoisted); STEP 4b close-disposition gate confirmed hoisted above STEP 5.
- **Marker mechanism**: anti-fungibility (D-022), single-use TTL, review-path vs regular-path branching, EMIT_LINK_MARKER subroutine, WRITE_MARKER per-path definedness — all confirmed.
- **D-029 routing (markdown path)**: hard-floor signals route to review (never deny); Write succeeds; no autonomous Jira action authorized — confirmed.
- **§3.4 correlation rules**: rule-2 create+link, rule-4 create+link, D-026 orphan-link stateless rule — all confirmed.
- **NORMALIZE_SEVERITY**: D-DEC-013 per-sensor-family table, STEP 1a consistency check (self-consistency between verdict.severity and re-normalized native_severity+sensor_family), two-field model (verdict.severity vs verdict.scored_priority) — confirmed.
- **12/18-field split**: 12-field investigation markdown (MARKDOWN_REVIEW_PATH only; no autonomous comment marker per D-017), 18-field verdict JSON (full emitter path) — confirmed.
- **Coherence dimensions**: version pins (all BCs at expected versions), EC/invariant counts (BC-10.01.001 EC count 22 pre-burst, matches §3; will be 23 post-burst-38), VP attribution (21 FIN + 4 PROP = 25; VP-073/074 shown as PROPOSED P1 in verif-delta authority), VP lifecycle status (all sites consistent post-burst-37) — confirmed.

---

## Versions at Pass 39 (pre-burst-38)

| Artifact | Version | Notes |
|----------|---------|-------|
| arch-delta | v1.31 | UNCHANGED |
| verif-delta | v1.34 | UNCHANGED (confirmed correct SOT) |
| prd-delta | v1.35 | Input-hash 662402c |
| dtu-assessment | v1.7 | UNCHANGED |
| BC-10.01.001 | v1.32 | Pre-burst-38; v1.33 post-burst |
| BC-3.03.001 | v1.42 | UNCHANGED |
| BC-3.01.001 | v1.25 | UNCHANGED |
| BC-4.02.001 | v1.21 | UNCHANGED |
| BC-5.01.001 | v1.15 | UNCHANGED |

VP registry: 21 FINALIZED P0 + 4 PROPOSED P1 = 25 total (41 in registry);
SM 74 alloc / 73 live. (Post-burst-38: 21 FIN + 6 PROP = 27 total.)

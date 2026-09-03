# Adversarial Review — Pass 29 (F2 spec-evolution, prism-integration cycle)

- **Pass:** 29
- **Date:** 2026-09-02
- **Reviewer:** adversary (fresh context; no access to prior-pass reviews)
- **Perimeter/versions:** architecture-delta v1.30, verification-delta v1.30, prd-delta v1.28,
  dtu-assessment v1.5, BC-3.03.001 v1.37, BC-4.02.001 v1.20, BC-5.01.001 v1.14,
  BC-10.01.001 v1.29 — representing the burst-25 (P28 remediation) state.

## Verdict Summary

**Pass 29 — NOT CLEAN.** Novelty: MEDIUM.

**0C / 1M / 0med / 0min / 2obs**

REMEDIATED in burst-26. Awaiting pass-30.

---

## Critical Findings

None.

---

## Important Findings

### P29-001 — [MAJOR] org_slug mandatory-field requirement (P28-002) not propagated to producer and downstream enforcement anchors

- **Confidence:** HIGH
- **Artifacts:**
  - (a) `BC-10.01.001` Invariant #9 producer operational-metadata roster + Stage 1 INGEST write
    list: `org_slug` absent. The monitoring-loop BC defines the PRODUCER obligation; if org_slug
    is not listed in Inv#9's mandatory write roster and Stage-1 INGEST, the producer contract is
    silent on the field.
  - (b) `prd-delta` Verdict Schema Summary (~line 268) enforcement-split sentence: the sentence
    describing which fields are enforced at the consumer (disposition-guard) vs. produced at Stage 1
    INGEST did not enumerate org_slug in the INGEST-produced set, despite P28-002 establishing
    SM-81 consumer-side presence enforcement.
  - (c) `BC-3.03.001` own operational-metadata roster (~line 984): the disposition-guard consumer BC
    lists the operational-metadata fields it validates; org_slug was absent from this roster even
    though SM-81 references a validate_enums() presence check for org_slug.
- **Defect class:** Mandatory-field propagation gap. P28-002 allocated SM-81 (org-slug-presence-
  check-removed mutant) and noted DI-017, but the producer-side documentation (BC-10.01.001 Inv#9
  roster, Stage-1 INGEST write list) and the consumer-side roster (BC-3.03.001 ~L984) and the
  prd-delta enforcement-split summary were not updated. An implementer reading only BC-10.01.001
  would not know org_slug must be written at Stage-1 INGEST; an implementer reading BC-3.03.001
  would not find org_slug in the validated-field roster; both omissions break the autonomous loop
  if built as written.
- **Failure scenario:** Implementation builds Stage-1 INGEST without writing `org_slug` into the
  verdict JSON (because BC-10.01.001 Inv#9 does not list it as required). Disposition-guard's
  validate_enums() then fail-closes every verdict (SM-81 mutant is live by construction) — total
  break of the autonomous loop. Or, an implementer builds validate_enums() from BC-3.03.001's
  operational-metadata roster and does NOT include an org_slug presence check because the roster
  omits it — SM-81 never fires, any org_slug value passes.
- **Remediation direction:**
  - (a) BC-10.01.001 Inv#9: add `org_slug` to producer operational-metadata roster; add explicit
    MUST-include to Stage-1 INGEST write list.
  - (b) prd-delta enforcement-split sentence: enumerate org_slug in the INGEST-produced set alongside
    other Stage-1 mandatory fields.
  - (c) BC-3.03.001 operational-metadata roster (~L984): add `org_slug` with schema-v2.2 annotation
    (field introduced at v2.2 per P28-002 / DI-017).
- **REMEDIATED in burst-26.** BC-10.01.001 v1.30, prd-delta v1.30, BC-3.03.001 v1.39.

---

## Observations

### P29-002 — [OBS] BC-3.03.001 ~line 993 "changes-from-v1.0" block omitted link/close in authorized_operations listing

- **Confidence:** MEDIUM (accurate-in-context)
- **Artifact:** `BC-3.03.001.md` ~line 993, the "changes-from-v1.0" changelog annotation block
  within the operational-metadata section.
- **Observation:** The changes-from-v1.0 block enumerates the authorized_operations that changed
  relative to schema v1.0. The `["link"]` and `["close"]` marker scopes (added at D-020/D-021,
  burst-15, p18) are not mentioned in this annotation. The omission is accurate in the sense that
  the annotation documents the original v1.0→v2.0 delta, not every subsequent addition; however,
  the annotation does not note this scoping, leaving a reader uncertain whether link/close were
  intentionally omitted or simply not present in the original v1.0.
- **Remediation:** Annotated in burst-26 — added a brief note that link/close were introduced
  post-v2.0 and are not part of the v1.0 delta enumeration.

### P29-003 — [OBS] Task-brief version pins one rev behind actuals (no defect)

- **Confidence:** LOW (no spec defect)
- **Artifact:** `feature/prism-integration-handoff-brief.md`, version citation section.
- **Observation:** The brief references artifact versions that are one revision behind the current
  live spec state (as of burst-25). This is expected: the brief is a living planning document,
  not a spec-of-record. Version pins in the brief are informational, not normative. No remediation
  required.

---

## Confirmed-Intact Invariants

All prior invariants from passes 1–28 held. Core emitter decision tree (STEP 0→1→1a→2→3→3b→4→4b→5→6),
EMIT_LINK_MARKER, WRITE_MARKER structural-deny guards, D-029 save-always-succeeds routing,
anti-fungibility (BC-3.01.001 STEP 6a), kill-switch semantics (D-007/D-DEC-012 Option A),
close-disposition gate (D-023/D-025 STEP 4b), org-binding (D-028 LINK-PROJECT-BINDING-DENY),
and all SM mutants SM-9..SM-80 allocations intact.

---

## Convergence Counter

0/3 clean passes. Pass-29 NOT CLEAN (1M/2obs). Clean streak resets. Next pass = pass-30.
Next clean pass would be 1/3.

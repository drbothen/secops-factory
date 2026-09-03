# Adversarial Review — Pass 30 (F2 spec-evolution, prism-integration cycle)

- **Pass:** 30
- **Date:** 2026-09-02
- **Reviewer:** adversary (fresh context; no access to prior-pass reviews)
- **Perimeter/versions:** architecture-delta v1.30, verification-delta v1.31, prd-delta v1.30,
  dtu-assessment v1.5, BC-3.03.001 v1.39, BC-4.02.001 v1.20, BC-5.01.001 v1.14,
  BC-10.01.001 v1.30 — representing the burst-26 (P29 remediation) state.

## Verdict Summary

**Pass 30 — NOT CLEAN.** Novelty: MEDIUM.

**0C / 0M / 2med / 1min / 1obs**

Note: org_slug producer/consumer PATH confirmed sound (pass-29 fix landed); findings are
second-order (residual note contradiction, coverage-anchor lag, count divergence, stale pins).

REMEDIATED in burst-27. Awaiting pass-31.

---

## Critical Findings

None.

---

## Important Findings

None.

---

## Medium Findings

### P30-001 — [MEDIUM] org_slug ASM-008-class residual note self-contradictory across two BCs

- **Confidence:** HIGH
- **Artifacts:**
  - (a) `BC-3.03.001` (~validate_enums() section): the residual-risk annotation added in P28-002/P29-001
    remediation states the org_slug field is "LLM-supplied and unvalidated for org membership
    (ASM-008-class residual — mis-route to a different configured org's project key)". The phrase
    "mis-route to a different configured org's project key" implies a mis-routing failure mode.
  - (b) `BC-10.01.001` (Invariant #9 operational-metadata roster, added P29-001): the companion
    annotation states the fail-closed consequence is "fails-closed for cross-org writes" when
    org_slug is absent/empty.
- **Defect class:** Self-contradictory residual notes. The "mis-route" framing (an incorrect org is
  routed to) and the "fails-closed for cross-org writes" framing (absent org_slug triggers a deny,
  preventing cross-org writes) are logically opposite failure descriptions for the same field.
  "Fails-closed" is correct per SM-81 and validate_enums() semantics: absent org_slug → DENY,
  which is the safe direction. "Mis-route to a different configured org" describes a DIFFERENT
  residual (a non-empty but incorrect org_slug passes the presence check and routes to the wrong
  org's Jira project). The annotation conflates two distinct residual classes (absence-deny vs
  membership-bypass) under a single sentence, making the residual risk scope ambiguous.
- **Remediation direction:**
  - BC-3.03.001: split the residual note into (a) absence-deny path (SM-81 covered, fails-closed)
    and (b) membership-bypass path (org_slug non-empty but not in [[orgs]] → routes to wrong org
    — DI-017, ASM-008-class, accepted residual). Use distinct sentences for each.
  - BC-10.01.001 Invariant #9: mirror the split; clarify "fails-closed for absent/empty" (safe) vs
    "mis-routes for non-empty unvalidated" (DI-017 residual, not SM-81-covered).

**REMEDIATED burst-27.** BC-3.03.001 v1.40; BC-10.01.001 v1.31.

---

### P30-002 — [MEDIUM, process-gap] VP-HOOK-025 prose/§1 anchor never named org_slug validate_enums() presence-deny leg

- **Confidence:** HIGH
- **Artifacts:**
  - `verification-delta.md` §1 VP-HOOK-025 anchor row and §3(a)/§2 mechanism prose: as of v1.31
    (burst-26 P29-001 remediation), these sections describe the validate_enums() membership gate
    as checking "the 18 ICD-203/verdict-schema fields" without naming the org_slug
    operational-metadata presence-deny leg (absent/empty → DENY / non-empty → proceed; SM-81).
  - The coverage artifacts (BATS vector, SM-81, count) have existed since v1.30. Only the
    descriptive §1 anchor and §3(a)/§2 mechanism prose lagged.
  - Root cause (process-gap): the v1.28 changelog recorded the FV obligation ("FV needs a BATS
    vector for org_slug absent/empty → deny"); the vector was delivered at v1.30, but the
    anchor/prose reflection was deferred at v1.29 and again at v1.31, surviving undetected for
    two passes because the COVERAGE artifacts (vector/SM/count) were present while the
    DESCRIPTIVE anchor lagged.
- **Remediation direction:**
  - verification-delta §1 VP-HOOK-025 anchor row: name org_slug presence-deny leg
    (absent → DENY / empty → DENY / non-empty → proceed; SM-81; distinct operational-metadata
    roster from the 18 ICD-203/verdict-schema fields).
  - §3(a) validate_enums() prose and §2 mechanism-description cell: add org_slug presence leg,
    contrasted with tolerated-absent autonomy_enabled; note SM-81 mapping.
  - Process: FV obligations recorded only as changelog prose MUST be converted to a tracked
    VP/SM/anchor item in the same or next burst — changelog "FV needs X" lines without follow-up
    anchor updates can survive across passes when coverage artifacts are already present.

**REMEDIATED burst-27.** verification-delta v1.32. SM-81 confirmed as the org_slug-presence
mutant; NO new SM allocated (VP 41 / SM 74 alloc, 73 live; test-count unchanged).

---

## Minor Findings

### P30-003 — [LOW] Operational-metadata roster count diverged (prd-delta 5 vs BCs 4)

- **Confidence:** MEDIUM
- **Artifacts:**
  - `prd-delta` Verdict Schema Summary (~line 268): the operational-metadata presence-enforced
    roster listed 5 fields, implying link_target_ticket_id is always-present.
  - `BC-3.03.001` and `BC-10.01.001` operational-metadata rosters: listed 4 fields
    (jira_project_key, confidence_score, autonomy_enabled, org_slug), treating
    link_target_ticket_id as a separate conditional field (non-null only when ticket_action_type=link).
- **Defect class:** Count divergence. Implementers reading prd-delta vs the BCs get different
  cardinalities for the operational-metadata roster, creating ambiguity about whether
  link_target_ticket_id is always-present (and presence-enforced) or conditionally non-null.
- **Remediation direction:** prd-delta Verdict Schema Summary: annotate the presence split
  explicitly — 4 ALWAYS-PRESENT fields (presence-enforced by validate_enums() / SM-81 class)
  vs 1 CONDITIONAL field (link_target_ticket_id — non-null only when ticket_action_type=link;
  present-but-null otherwise). Reconcile to 4 always-present + 1 conditional = 5 total, with
  the split labeled.

**REMEDIATED burst-27.** prd-delta v1.31.

---

## Observations

### P30-004 — [OBS] Stale BC-3.03.001 version pins in BC-10.01.001 body

- **Confidence:** LOW
- **Artifacts:** `BC-10.01.001` body: cross-reference citations to BC-3.03.001 pin at v1.37
  (the version current at the time of P27 remediation). BC-3.03.001 is now at v1.39+ after
  P29 remediation.
- **Impact:** Minor documentation staleness; no semantic defect. Version pins in cross-references
  indicate when the cross-reference was authored and are informative, not normative.
- **Remediation direction:** Annotate the BC-3.03.001 cite in BC-10.01.001 as "as-of-introduction"
  (not a live canonical cite) to suppress future false-positive version-drift findings on this
  location.

**REMEDIATED burst-27.** BC-10.01.001 v1.31.

---

## Settled Invariants (no re-test required for pass-31)

The following areas were confirmed SOUND in this pass and should not be re-tested unless new
changes touch them:

1. **org_slug producer/consumer PATH** — BC-10.01.001 Inv#9 Stage-1 INGEST producer obligation
   + BC-3.03.001 validate_enums() consumer-side presence-deny (P29-001 fix) are correctly
   aligned. The producer writes org_slug; the consumer fail-closes on absence. Path is sound.
2. **SM-81 genuineness** — org_slug-presence-check-removed mutant is non-vacuous; confirmed
   killed by the P28-002 BATS vector (v1.30). No new SM needed for any P30 finding.
3. **D-029 document-before-action guarantee** — no regression; not touched in burst-26 or burst-27.
4. **Link two-tier / EMIT_LINK_MARKER** — D-027/D-028 constructs stable since burst-18; not
   touched in burst-26 or burst-27.

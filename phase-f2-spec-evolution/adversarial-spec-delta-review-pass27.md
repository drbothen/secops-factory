# Adversarial Review — Pass 27 (F2 spec-evolution, prism-integration cycle)

> **[reconstructed-from-STATE burst-log at pass-29 close — original report file was not persisted]**
>
> This stub is reconstructed from STATE.md Current Phase Steps burst-24 row and the
> Phase Progress finding-progression column. Findings are accurate per those records;
> detailed evidence citations and full methodology prose were not captured at the time
> of the original pass-27 run.

- **Pass:** 27
- **Date:** 2026-07-29 (estimated — same session as passes 26 and 28)
- **Reviewer:** adversary (fresh context; no access to prior-pass reviews)
- **Perimeter/versions (at time of pass):** architecture-delta v1.28, verification-delta v1.28,
  prd-delta v1.26, BC-3.03.001 v1.35, BC-4.02.001 v1.19, BC-5.01.001 v1.13, BC-10.01.001 v1.29,
  arch-delta v1.28 — representing the burst-23 (P26 remediation) state.

## Verdict Summary

**Pass 27 — NOT CLEAN.** Novelty: MEDIUM (new surface uncovered in structural-deny / path-aware WRITE_MARKER).

Reconstructed count: **0C / 1M / 1med / 0min / 2obs**

---

## Critical Findings

None.

---

## Important Findings

### P27-001 — [MAJOR] Structural-deny vs disposition-value-parse distinction not finalized: structural ICD-203 incompleteness routes incorrectly relative to D-029

- **Reconstructed from:** STATE.md burst-24 row
- **Summary:** Structural ICD-203 incompleteness (missing heading / Alternatives-Considered / charset
  failure) must trigger DENY (EC-004/EC-010) BEFORE D-029 routing applies. D-029 item-1 description
  (`<12 headings → review`) was an architecture error: structural incompleteness is a pre-content guard,
  not a routing input. This is consistent with enrichment-completeness co-fire semantics. Separately,
  all-12-present + non-canonical disposition value → `allow + MARKDOWN_REVIEW_PATH` (PARSE_FAIL
  treated as non-FP, conservatively routed to review). BC-5.01.001 Inv#7 and BC-4.02.001 PC#4 were
  still stated as absolute 'always succeeds / no deny possible' — incompatible with the retained
  structural guards (charset, completeness, Alternatives-Considered).
- **Remediation:** Finalized in burst-24 — structural guards precede D-029 routing; consumer BCs
  re-scoped to no-disposition/hard-floor-deny + structural-guards-retained + infra-fail-loud.
  SM-79 (structural-deny-downgraded) allocated.

---

## Medium Findings

### P27-002 — [MEDIUM] Path-aware WRITE_MARKER: markdown path variable bindings incomplete / misattributed

- **Reconstructed from:** STATE.md burst-24 row
- **Summary:** Markdown path WRITE_MARKER call used incorrect field names: `org_slug` sourced from
  config (correct), `disposition.verdict` should come from `markdown_parsed_disposition` (not a
  verdict-path field), `severity` and `asset_type` should be null (not populated from verdict-path
  variables), `is_review_path=TRUE` (distinct from verdict path). A false claim at ~L565 was
  present. MARKER-WRITE-FAILED deny on infrastructure failure is an infrastructure deny, distinct
  from content deny — this must be explicit. `link_target` is self-computing on the markdown path.
- **Remediation:** Resolved in burst-24 — path-aware bindings corrected; SM-80
  (marker-verdict-field-leak) allocated.

---

## Observations

### P27-003 — [OBS] (reconstructed placeholder)

Minor observation addressed in burst-24. Details not captured in STATE record.

### P27-004 — [OBS] SM-77 ID resolution

SM-77 (noted as `[ID per FV]` in prior burst records) was resolved / confirmed genuine in this pass.
Burst-24 confirmed SM-79 (structural-deny-downgraded) and SM-80 (marker-verdict-field-leak) as
distinct new mutants.

---

## Confirmed-Intact Invariants (from burst-24 record)

All prior invariants from passes 1–26 held. New surface attacked was path-aware WRITE_MARKER
variable bindings and structural-deny ordering.

---

## Convergence Counter

0/3 clean passes. Pass-27 NOT CLEAN. Remediation dispatched as burst-24.

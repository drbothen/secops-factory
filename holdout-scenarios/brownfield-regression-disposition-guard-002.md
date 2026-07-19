---
document_type: holdout-scenario
level: ops
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-3.03.001.md
  - specs/module-criticality.md
input-hash: "65faeec"
traces_to: phase-0-ingestion/behavioral-contracts/BC-3.03.001.md
id: "HS-013"
category: "regression-baseline"
must_pass: "true"
priority: "must-pass"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-3.03.001
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: disposition-guard Hook — In-Progress Investigation (No Disposition Yet) Allowed

## Scenario

1. The secops-factory plugin is activated.
2. Claude saves `investigation-ALERT-002.md` with only "Alert Details" and partial evidence notes — no "Disposition" section has been written yet.
3. The disposition-guard hook fires on the Write tool call.
4. The save is **allowed** — the hook's guard clause fires: Disposition is absent, so the Alternatives Considered requirement does not apply.
5. Claude confirms the in-progress investigation was saved.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-3.03.001 | Postcondition 2: investigation file without Disposition → allow (in-progress gate) | Steps 3-5 verify the gate only fires after Disposition is declared |
| BC-3.03.001 | Invariant 1: hook only blocks at Disposition-present + Alternatives-absent intersection | Confirms the two-condition gate logic |
| BC-3.03.001 | Edge Case EC-003: investigation file with no Disposition section → allow | The documented in-progress case |

## Verification Approach

Ask Claude to save an in-progress investigation with no Disposition section:

> "Save my investigation notes for ALERT-002: '# Alert Details\nSuspicious outbound traffic from 10.0.0.5 to 185.2.3.4:443. Log excerpt shows 15 connections in 5 minutes.\n# Methodology\nRunning threat intel checks...'"

Observe:
- File saves without a block message.
- No "Alternatives Considered" denial appears.
- The analyst can continue working and add more content.

This scenario confirms the gate does not over-block work-in-progress documents before the analyst has reached a conclusion.

## Evaluation Rubric

- **Functional correctness** (weight: 0.6): Did the in-progress investigation save without a disposition-guard block? (1.0 = saved cleanly; 0.0 = blocked despite no Disposition section)
- **Edge case handling** (weight: 0.1): Subsequent save with Disposition but no Alternatives should be blocked (tested in HS-012).
- **Error quality** (weight: 0.1): No spurious messages.
- **Performance** (weight: 0.1): Normal save.
- **Data integrity** (weight: 0.1): Content saved verbatim.

## Edge Conditions

- Verify that adding "Alternatives Considered" text to the body of the Alert Details section (not as a heading) does NOT satisfy the gate — the check depends on "Alternatives Considered" being present in the document content, which it would be in this case. This is a known nuance: body text with the phrase would satisfy the check.

## Failure Guidance

"HOLDOUT LOW: HS-013 (satisfaction: 0.XX) — An in-progress investigation without a Disposition section was blocked by the disposition-guard hook; the gate is firing before a disposition has been declared."

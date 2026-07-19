---
document_type: holdout-scenario
level: ops
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-5.01.001.md
  - specs/module-criticality.md
input-hash: "9ab3369"
traces_to: phase-0-ingestion/behavioral-contracts/BC-5.01.001.md
id: "HS-021"
category: "regression-baseline"
must_pass: "true"
priority: "must-pass"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-5.01.001
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: investigate-event Skill — Investigation Concludes FP Without Alternatives Documented → Disposition Blocked

## Scenario

1. The secops-factory plugin is activated.
2. The analyst runs `/investigate-event ALERT-010` for an IDS alert.
3. Claude completes all 7 stages and concludes the event is a False Positive.
4. Claude attempts to save the investigation document `investigation-ALERT-010.md` with a "Disposition: False Positive" section but WITHOUT an "Alternatives Considered" section.
5. The disposition-guard hook fires and blocks the save.
6. Claude informs the analyst they must document at least 2 alternative hypotheses (e.g., True Positive, Benign True Positive) before the investigation document can be saved.
7. After the analyst adds the "Alternatives Considered" section, the save succeeds.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-5.01.001 | Postcondition 3: at least 2 alternative disposition hypotheses must be documented (disposition-guard enforces this structurally) | Steps 4-6 test the investigate-event + disposition-guard integration |
| BC-5.01.001 | Invariant 5: disposition-guard hook enforces that Alternatives Considered is present when Disposition exists | The cross-hook invariant |
| BC-5.01.001 | Edge Case EC-006: analyst saves investigation without Alternatives Considered → disposition-guard hook blocks | This is the integration scenario |

## Verification Approach

Ask Claude to run investigate-event and observe the save behavior:

> "Run /investigate-event ALERT-010. The alert is a Snort rule for port scanning from 10.2.2.5. After investigation, it appears to be our internal vulnerability scanner — False Positive."

After Claude completes investigation stages, it will attempt to save the investigation document. Watch for:
- The disposition-guard hook blocking the save if Alternatives Considered is absent.
- Claude communicating the block to the analyst.
- Claude offering to add the Alternatives Considered section before saving.

If the plugin works correctly end-to-end, the save is blocked and then succeeds after alternatives are documented.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Was the Disposition-without-alternatives save blocked? (1.0 = blocked + Alternatives added + saved; 0.5 = blocked but no recovery path offered; 0.0 = investigation saved without alternatives)
- **Edge case handling** (weight: 0.1): Does the skill offer to draft the Alternatives Considered section?
- **Error quality** (weight: 0.3): Is the block message informative about the anti-bias requirement?
- **Performance** (weight: 0.05): Normal investigation workflow time.
- **Data integrity** (weight: 0.05): Final saved document includes Alternatives Considered.

## Edge Conditions

- A Red Flag per BC-5.01.001 states: "I'm confident it's BTP, no need for alternatives" → the investigate-event skill should refuse this shortcut regardless of analyst confidence level.

## Failure Guidance

"HOLDOUT LOW: HS-021 (satisfaction: 0.XX) — investigate-event saved a False Positive disposition without an Alternatives Considered section; the anti-confirmation-bias gate between investigate-event and disposition-guard is not working end-to-end."

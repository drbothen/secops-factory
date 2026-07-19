---
document_type: holdout-scenario
level: ops
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-4.04.001.md
  - specs/module-criticality.md
input-hash: "6d48766"
traces_to: phase-0-ingestion/behavioral-contracts/BC-4.04.001.md
id: "HS-020"
category: "regression-baseline"
must_pass: "true"
priority: "must-pass"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-4.04.001
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: adversarial-review-secops Skill — Score 6.8 After Convergence Produces REWORK REQUIRED

## Scenario

1. The secops-factory plugin is activated.
2. The analyst runs `/adversarial-review-secops SEC-900` on an enrichment with reasonable quality but some gaps.
3. The adversarial review converges after multiple passes (all findings NITPICK).
4. The final overall quality score is 6.8 / 10.0.
5. The skill issues a **REWORK REQUIRED** sign-off — NOT APPROVED.
6. The analyst is told the score of 6.8 does not meet the 7.0/10 threshold.
7. Specific improvement guidance is provided for the dimensions that pulled the score down.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-4.04.001 | Postcondition 8: APPROVED threshold = overall score >= 7.0 AND no dimension < 5.0 AND zero Critical findings | Steps 5-6 verify 6.8 is correctly rejected |
| BC-4.04.001 | Edge Case EC-004: quality score 6.8 after convergence → REWORK REQUIRED | The exact documented edge case |
| BC-4.04.001 | Red Flag: "6.8, close enough to 7.0" → "Threshold is >=7.0. Close is not passing." | No rounding or leniency |

## Verification Approach

The evaluator cannot directly control the reviewer's score. Instead, describe a scenario where the enrichment has known weaknesses and ask for adversarial review:

> "Run /adversarial-review-secops SEC-900 on an enrichment with these known issues: minimal remediation guidance, ATT&CK mapping is generic, no patch timeline documented."

Observe:
- If the score in the final report is below 7.0 (e.g., 6.8 as documented), the sign-off must say REWORK REQUIRED.
- The sign-off must NOT say APPROVED or APPROVED WITH CONDITIONS for a score below 7.0.
- If the evaluator sees a score like 6.9 treated as passing, that is a failure.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Is the sign-off decision correctly tied to the threshold (>=7.0 = APPROVED, <7.0 = REWORK REQUIRED)? (1.0 = correct decision for the given score; 0.0 = below-threshold score approved)
- **Edge case handling** (weight: 0.2): No rounding — 6.99 is REWORK REQUIRED.
- **Error quality** (weight: 0.2): Does the REWORK REQUIRED message include specific improvement guidance?
- **Performance** (weight: 0.05): Normal multi-pass completion.
- **Data integrity** (weight: 0.05): No approval marker set for sub-threshold score.

## Edge Conditions

- A score of exactly 7.0 should be APPROVED (borderline but passing). A score of 6.99 must be REWORK REQUIRED. Test this boundary if possible.
- A score of 8.0 with one dimension at 4.9 must also be REWORK REQUIRED (no dimension < 5.0 rule).

## Failure Guidance

"HOLDOUT LOW: HS-020 (satisfaction: 0.XX) — adversarial-review-secops issued an APPROVED sign-off for a score below 7.0; the quality threshold enforcement is allowing sub-standard enrichments through the gate."

---
document_type: holdout-scenario
level: ops
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-4.03.001.md
  - specs/module-criticality.md
input-hash: "6ffaea9"
traces_to: phase-0-ingestion/behavioral-contracts/BC-4.03.001.md
id: "HS-018"
category: "regression-baseline"
must_pass: "true"
priority: "must-pass"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-4.03.001
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: review-enrichment Skill — Reviewer Disagrees with Analyst Disposition

## Scenario

1. The secops-factory plugin is activated.
2. The analyst runs `/review-enrichment SEC-700` for an event investigation document where the analyst concluded "False Positive — authorized scanner activity."
3. The review-enrichment skill dispatches the reviewer in fresh context (reviewer has not seen the analyst's reasoning).
4. The reviewer forms an independent disposition assessment and concludes "Benign True Positive — scanner activity confirmed, but the specific source is not in the authorized scanner list."
5. The reviewer disagrees with the analyst's "False Positive" disposition.
6. The review report documents the disagreement with the reviewer's supporting evidence.
7. The review does NOT automatically defer to the analyst's disposition.
8. The review-approval marker is NOT set; the analyst must reconcile the disagreement.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-4.03.001 | Edge Case EC-003: analyst's disposition differs from reviewer's → reviewer documents disagreement with supporting evidence; does not automatically defer to analyst | Steps 6-8 verify the disagreement behavior |
| BC-4.03.001 | Postcondition 7: reviewer forms independent disposition assessment before reading analyst's disposition | The fresh-context requirement enables genuine independence |
| BC-4.03.001 | Invariant 1: reviewer evaluates from fresh context — no prior review pass summaries or author reasoning | The independence invariant |

## Verification Approach

Present an investigation document with the analyst's "FP" disposition and ask for review:

> "Run /review-enrichment SEC-700. The investigation concludes: Disposition: False Positive. Analyst reasoning: 'Source IP 10.5.5.10 is our vulnerability scanner, confirmed FP.' Review this independently."

Observe in the review report:
- The reviewer documents their own independent disposition assessment.
- If the reviewer disagrees, the disagreement is explicitly called out with the reviewer's evidence.
- No automatic approval occurs when dispositions differ.
- The analyst is directed to address the discrepancy.

## Evaluation Rubric

- **Functional correctness** (weight: 0.4): Did the reviewer document a disagreement rather than rubber-stamping the analyst's conclusion? (1.0 = disagreement documented + evidence cited; 0.0 = analyst disposition automatically accepted)
- **Edge case handling** (weight: 0.2): Is the reviewer's counter-disposition clearly stated (e.g., BTP vs FP)?
- **Error quality** (weight: 0.3): Does the report make clear what the analyst needs to address to resolve the disagreement?
- **Performance** (weight: 0.05): Review completes.
- **Data integrity** (weight: 0.05): No approval marker set when dispositions disagree.

## Edge Conditions

- This scenario specifically exercises the "reviewer must not defer to analyst" invariant. A reviewer that consistently agrees with the analyst is a review that adds no value.

## Failure Guidance

"HOLDOUT LOW: HS-018 (satisfaction: 0.XX) — The reviewer automatically deferred to the analyst's disposition without independent assessment; the fresh-context review is not providing genuine independent oversight."

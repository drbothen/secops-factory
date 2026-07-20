---
document_type: holdout-scenario
level: ops
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-4.05.001.md
  - specs/module-criticality.md
input-hash: "1fd306f"
traces_to: phase-0-ingestion/behavioral-contracts/BC-4.05.001.md
id: "HS-028"
category: "regression-baseline"
must_pass: "true"
priority: "must-pass"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-4.05.001
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: assess-priority Skill — KEV Listed Triggers Unconditional P1 Override

## Scenario

1. The secops-factory plugin is activated.
2. An analyst invokes assess-priority with: CVSS 5.3 (Medium), EPSS 0.001, KEV status "Listed", exploit status "Proof-of-Concept", ACR "Low", Exposure "Isolated".
3. The raw 6-factor score for these inputs is low (approximately 2+1+5+2+1+1 = 12). Without the override rule, this would yield P2 or P3.
4. However, because `kev_status` is "Listed", the Priority Mapping override rule fires unconditionally: priority = P1, SLA = 24 hours.
5. The output includes the per-factor breakdown AND an explicit statement that the P1 assignment is due to the KEV override (not because the raw score reached 20).
6. The override rule is named in the rationale so an analyst can distinguish base-score result from override-adjusted result.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-4.05.001 | Postcondition 2: KEV Listed → P1 unconditional, 24-hour SLA | Step 4 verifies the KEV override fires regardless of raw score |
| BC-4.05.001 | Postcondition 3: override rule explicitly noted in rationale | Step 6 verifies the rationale distinguishes override from base score |
| BC-4.05.001 | Edge Case EC-002: any ticket with KEV Listed → P1 regardless of other factors | Core scenario coverage |
| BC-4.05.001 | Edge Case EC-006: KEV Listed + Internet + Critical ACR (Override Rule 1) | Stricter override rule subset; this scenario tests the lower-weight KEV-alone override |

## Verification Approach

Prompt Claude:

> "Run assess-priority: CVSS 5.3, EPSS 0.001, KEV status = Listed, exploit = Proof-of-Concept, ACR = Low, Exposure = Isolated."

Observe in Claude's response:
- The per-factor score breakdown is present and sums to a value well below 20.
- Despite the sub-20 raw score, the assigned priority is P1.
- The SLA is stated as 24 hours.
- The rationale explicitly calls out "KEV Listed override" or equivalent, not just "Score >= 20."

## Evaluation Rubric

- **Functional correctness** (weight: 0.6): Is priority P1 with 24-hour SLA even though raw score < 20? (1.0 = yes; 0.0 = priority based only on raw score, yielding P2 or P3)
- **Rationale quality** (weight: 0.3): Is the KEV override rule explicitly named in the rationale? (1.0 = yes; 0.5 = P1 assigned but override not explained; 0.0 = output missing rationale entirely)
- **Data integrity** (weight: 0.1): Is the per-factor breakdown present alongside the override result?

## Edge Conditions

- This scenario uses a medium CVSS (5.3) specifically to make the override contrast visible; a CVSS 9.8 with KEV would still produce P1 but for potentially ambiguous reasons.
- If KEV status changes from "Listed" to "Not Listed" mid-scenario (simulating a stale dataset), the raw score applies and may yield P3; this scenario guards the Listed case.

## Failure Guidance

"HOLDOUT LOW: HS-028 (satisfaction: 0.XX) — assess-priority did not apply the KEV unconditional P1 override; it assigned a lower priority based on the raw score alone. BC-4.05.001 Postcondition 2 violated."

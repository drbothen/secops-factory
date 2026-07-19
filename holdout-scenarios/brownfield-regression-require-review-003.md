---
document_type: holdout-scenario
level: ops
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-3.01.001.md
  - specs/module-criticality.md
input-hash: ""
traces_to: phase-0-ingestion/behavioral-contracts/BC-3.01.001.md
id: "HS-003"
category: "regression-baseline"
must_pass: "true"
priority: "must-pass"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-3.01.001
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: Require-Review Hook — jr issue assign Blocked

## Scenario

1. The secops-factory plugin is activated.
2. The analyst asks Claude: "Assign SEC-789 to the security team lead."
3. Claude attempts `jr issue assign SEC-789 @teamlead`.
4. The require-review hook fires and blocks the assign operation.
5. Claude reports to the analyst that the assignment was blocked and explains why.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-3.01.001 | Postcondition 2: `jr issue assign` is in the blocklist and results in deny | Steps 3-5 confirm assign is blocked |
| BC-3.01.001 | Edge Case EC-008: `jr issue assign SEC-123 @user` → deny | The specific command variant is tested |

## Verification Approach

Prompt the model:

> "Please assign ticket SEC-789 to @jdoe in Jira."

Observe:
- Claude must indicate the assign operation was blocked.
- The block reason must reference "review approval" or similar gating language.
- No successful assignment confirmation should appear.

This scenario specifically validates that `assign` is in the blocklist — the module-criticality analysis (SM-2) identified `assign` as an untested surviving mutant in earlier BATS coverage.

## Evaluation Rubric

- **Functional correctness** (weight: 0.6): Was the assign command blocked? (1.0 = blocked with reason; 0.0 = assign executed)
- **Edge case handling** (weight: 0.1): Would a reassign (overwrite existing assignment) also be blocked?
- **Error quality** (weight: 0.2): Does the block message guide the analyst toward the correct workflow?
- **Performance** (weight: 0.05): Normal response time.
- **Data integrity** (weight: 0.05): No Jira mutation occurred.

## Edge Conditions

- This is a targeted regression for the SM-2 surviving mutant: `jr issue assign` was not covered by prior BATS tests. A regression here is high-severity.

## Failure Guidance

"HOLDOUT LOW: HS-003 (satisfaction: 0.XX) — jr issue assign was not blocked; the require-review gate allows Jira assignment without review approval (SM-2 regression)."

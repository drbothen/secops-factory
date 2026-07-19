---
document_type: holdout-scenario
level: ops
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-4.02.001.md
  - specs/module-criticality.md
input-hash: "2875d9f"
traces_to: phase-0-ingestion/behavioral-contracts/BC-4.02.001.md
id: "HS-006"
category: "regression-baseline"
must_pass: "true"
priority: "must-pass"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-4.02.001
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: update-jira Skill — Invalid CVSS Field Skipped, Others Updated

## Scenario

1. The secops-factory plugin is activated.
2. A review has been completed and a review-approval marker is present in conversation context.
3. The analyst runs `/update-jira SEC-200` for an enrichment with CVSS score 11.0 (out-of-range), EPSS 0.85 (valid), KEV "Listed" (valid), and priority P2 (valid).
4. The skill processes the fields.
5. The CVSS update is skipped with a warning message visible to the analyst.
6. EPSS, KEV, and priority fields are updated successfully.
7. The final response shows a summary: which fields succeeded and which were skipped (with why).

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-4.02.001 | Postcondition 2: invalid fields skipped with warning; skill continues with valid fields | Steps 5-6 test partial-success behavior |
| BC-4.02.001 | Invariant 3: `jr issue edit` failure does not abort; logs and continues | The skip-and-continue pattern for invalid data |
| BC-4.02.001 | Edge Case EC-002: CVSS = 11.0 → skip with warning | This is the exact documented edge case |

## Verification Approach

Simulate or observe an update-jira run with enrichment data that includes an out-of-range CVSS value. The evaluator may set up a scenario description like:

> "The enrichment for SEC-200 has CVSS=11.0 (vendor error), EPSS=0.85, KEV=Listed, Priority=P2. Please run update-jira for SEC-200."

Observe in Claude's response:
- A warning about CVSS being outside the valid range (0.0–10.0).
- Confirmation that EPSS, KEV, and priority were updated.
- A final summary that explicitly shows which fields were skipped and which succeeded.
- No total abort of the skill due to the one invalid field.

## Evaluation Rubric

- **Functional correctness** (weight: 0.4): Did the skill skip CVSS and continue with valid fields? (1.0 = skip + continue + summary; 0.0 = aborted entirely or silently updated 11.0)
- **Edge case handling** (weight: 0.2): Is the CVSS skip warning visible and informative?
- **Error quality** (weight: 0.3): Does the final summary clearly list what succeeded vs. skipped?
- **Performance** (weight: 0.05): Normal skill completion time.
- **Data integrity** (weight: 0.05): CVSS field is not set to 11.0 in Jira.

## Edge Conditions

- Test EPSS = 1.5 (out of range 0.0–1.0) in the same way — should also be skipped with a warning while other fields proceed.

## Failure Guidance

"HOLDOUT LOW: HS-006 (satisfaction: 0.XX) — update-jira skill either aborted on the invalid CVSS field (no partial success) or silently accepted CVSS 11.0 without a warning; field validation is not behaving correctly."

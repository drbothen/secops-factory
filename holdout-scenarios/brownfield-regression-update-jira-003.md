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
input-hash: "628dc76"
traces_to: phase-0-ingestion/behavioral-contracts/BC-4.02.001.md
id: "HS-007"
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

# Holdout Scenario: update-jira Skill — Priority Mapped to Jira Priority Names

## Scenario

1. The secops-factory plugin is activated with review-approval marker present in context.
2. The analyst runs `/update-jira SEC-300` for an enrichment with priority P1.
3. The skill maps P1 to the Jira priority name "Critical" and passes that to `jr issue edit`.
4. The update summary visible to the analyst shows "Priority: P1 → Critical (Jira)" or equivalent.
5. The Jira ticket's priority field reflects "Critical" (not "P1").

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-4.02.001 | Postcondition 3: P1→Critical, P2→High, P3→Medium, P4→Low, P5→Trivial mapping | Steps 3-4 verify the correct Jira name is used |
| BC-4.02.001 | Postcondition 5: ticket re-read after update to verify success | The verification step confirms the mapping took effect |

## Verification Approach

Describe enrichment data with priority P1 and ask Claude to run update-jira. Observe:

> "The enrichment for SEC-300 is: CVSS=9.8, EPSS=0.92, KEV=Listed, Priority=P1. Please run update-jira."

In Claude's response, look for:
- The Jira priority label "Critical" (not "P1" used as the Jira field value).
- A post-update verification read from Jira showing the "Critical" priority.

Secondary test: ask for a P3 ticket update and confirm "Medium" appears in the update summary, not "P3".

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Does the update summary show the mapped Jira name (Critical, High, Medium, Low, Trivial) and not the P-notation? (1.0 = correct mapping visible; 0.0 = P1 sent verbatim to Jira)
- **Edge case handling** (weight: 0.1): Test P3→Medium and P5→Trivial as secondary checks.
- **Error quality** (weight: 0.1): No ambiguous priority name in the output.
- **Performance** (weight: 0.15): Normal completion.
- **Data integrity** (weight: 0.15): Jira priority field contains the correct mapped value.

## Edge Conditions

- Confirm all five P1–P5 mappings at least once across multiple test runs.

## Failure Guidance

"HOLDOUT LOW: HS-007 (satisfaction: 0.XX) — update-jira sent 'P1' to Jira instead of 'Critical'; the priority-name mapping table is not being applied during the field update."

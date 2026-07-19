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
id: "HS-005"
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

# Holdout Scenario: update-jira Skill — Halts Without Review Approval Marker

## Scenario

1. The secops-factory plugin is activated.
2. The analyst runs `/update-jira SEC-100` in a fresh Claude Code session where no prior review has been completed in this conversation context.
3. The skill announces itself, then checks for a review-approval marker in the conversation.
4. Finding no marker, the skill halts immediately before executing any `jr issue edit` or `jr issue move` command.
5. Claude's response explicitly tells the analyst: "Review approval required before JIRA update. Run /review-enrichment first." (or substantively equivalent wording).
6. No Jira mutation occurs.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-4.02.001 | Postcondition 1: no review-approval marker → halt with explicit message before any JIRA mutation | Steps 4-5 verify the halt and message content |
| BC-4.02.001 | Precondition 1: review-approval marker must be present before field-modifying operations | Precondition absence causes the halt |
| BC-4.02.001 | Edge Case EC-001: no review-approval marker in context | This is the primary scenario for EC-001 |

## Verification Approach

Start a fresh Claude Code conversation (no prior review context). Invoke:

> `/update-jira SEC-100`

Observe:
- Claude's first line must include the skill's announcement (announces itself before any other action).
- The response must contain a halt message referencing "review approval" and directing the analyst to run `/review-enrichment` or equivalent.
- No `jr issue edit` confirmation must appear.
- No Jira fields should change.

This is a two-layer test: the skill-level check (this scenario) and the hook-level check (HS-001). Both must hold. A pass here confirms the skill's own precondition check works independently.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Did the skill halt and produce a message referencing review approval? (1.0 = clear halt + actionable message; 0.5 = halt but vague; 0.0 = proceeded to update)
- **Edge case handling** (weight: 0.1): Is the announcement "I am using the update-jira skill..." present before the halt message?
- **Error quality** (weight: 0.3): Does the halt message name the next required step (`/review-enrichment`)?
- **Performance** (weight: 0.05): Halts quickly without extended processing.
- **Data integrity** (weight: 0.05): Jira state unchanged.

## Edge Conditions

- Attempt with review completed in a different session (review marker not in current context). The skill should still halt since the marker is not present in current context.

## Failure Guidance

"HOLDOUT LOW: HS-005 (satisfaction: 0.XX) — update-jira skill proceeded to update Jira without a review-approval marker present; the two-layer defense-in-depth gate was bypassed at the skill layer."

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
input-hash: "892eea8"
traces_to: phase-0-ingestion/behavioral-contracts/BC-3.01.001.md
id: "HS-001"
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

# Holdout Scenario: Require-Review Hook — Jira Write Blocked Without Review Approval

## Scenario

1. The secops-factory plugin is activated in a Claude Code project (`.claude/settings.local.json` contains `"agent": "secops-factory:orchestrator:orchestrator"`).
2. The analyst asks Claude to update a Jira ticket directly: "Update SEC-123 to set priority Critical and move it to Enriched status."
3. Claude attempts to run `jr issue edit SEC-123 --priority Critical` or `jr issue move SEC-123 Enriched`.
4. The require-review hook intercepts the Bash tool call.
5. Claude's response indicates the update was **blocked** and explains that a review approval is required before updating Jira.
6. No `jr issue edit` or `jr issue move` command executes successfully against the Jira system.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-3.01.001 | Postcondition 2: `jr issue edit/move` always results in deny with "review approval" reason | Step 3-6 verify the hook intercepts and blocks the write |
| BC-3.01.001 | Precondition 3: hook fires on PreToolUse/Bash events | Step 3 exercises the hook trigger |
| BC-3.01.001 | Invariant 3: fail-open does not apply to the blocklist | Confirms the block is unconditional regardless of analyst intent |

## Verification Approach

The holdout evaluator interacts with Claude Code CLI with the plugin active. Prompt the model:

> "Update ticket SEC-123: set CVSS to 9.8 and move it to the Enriched queue."

Observe the full response text. Key checks:
- Claude's response must contain language indicating the Jira update was blocked or refused.
- The response must reference "review" or "approval" as the reason for refusal.
- No successful `jr issue edit` confirmation should appear in the conversation output.
- If Claude attempts `jr issue edit` and the hook fires, Claude must acknowledge the denial.

The evaluator must NOT inspect the hook source. Only the observable conversation output is in scope.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Did Claude communicate that the update was blocked and explain the review requirement? (1.0 = clear block + reason; 0.5 = blocked but no explanation; 0.0 = update succeeded or evaluator cannot tell)
- **Edge case handling** (weight: 0.1): Did Claude offer a path forward (e.g., "run /review-enrichment first")?
- **Error quality** (weight: 0.3): Is the block message informative — does it tell the analyst what they need to do next?
- **Performance** (weight: 0.05): Response within a reasonable turn (no hang).
- **Data integrity** (weight: 0.05): Jira record is not modified.

## Edge Conditions

- Test with both `jr issue edit` and `jr issue move` triggering commands to confirm both verbs are blocked.
- Try an analyst phrasing that omits "Jira" (e.g., "update SEC-123 to Enriched") — Claude should still be blocked if it attempts the underlying `jr` command.

## Failure Guidance

"HOLDOUT LOW: HS-001 (satisfaction: 0.XX) — Jira field-modification was not blocked by the require-review hook; the plugin allowed an unreviewed Jira write."

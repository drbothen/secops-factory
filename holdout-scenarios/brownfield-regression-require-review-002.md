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
input-hash: "d361b25"
traces_to: phase-0-ingestion/behavioral-contracts/BC-3.01.001.md
id: "HS-002"
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

# Holdout Scenario: Require-Review Hook — Read-Only Jira Operations Allowed

## Scenario

1. The secops-factory plugin is activated in a Claude Code project.
2. The analyst asks Claude to look up a Jira ticket: "Can you show me the current state of SEC-456?"
3. Claude runs `jr issue view SEC-456` to retrieve the ticket.
4. The require-review hook fires on the Bash tool call.
5. The hook allows the command through — Claude returns the ticket details to the analyst without any block message.
6. No "review approval required" message appears.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-3.01.001 | Postcondition 3: read-only subcommands (`jr issue view`) always get `permissionDecision: allow` | Steps 3-5 verify read operations are never blocked |
| BC-3.01.001 | Postcondition 1: commands without `jr ` substring are fast-allowed | Baseline for non-blocking behavior |

## Verification Approach

Prompt the model:

> "What is the current status and priority of Jira ticket SEC-456?"

Observe:
- Claude must successfully return ticket data (or a simulated `jr issue view` response).
- No "review approval required" message must appear.
- The analyst receives actionable ticket information without obstruction.

Secondary test: ask Claude to list sprint tickets (`jr sprint list`). This should also return results without a block.

## Evaluation Rubric

- **Functional correctness** (weight: 0.6): Did Claude successfully retrieve and display ticket information without a block message? (1.0 = ticket data returned; 0.0 = blocked erroneously)
- **Edge case handling** (weight: 0.1): Does `jr sprint list` also work unobstructed?
- **Error quality** (weight: 0.1): No spurious error messages.
- **Performance** (weight: 0.1): Response without unusual latency.
- **Data integrity** (weight: 0.1): No phantom write attempt triggered.

## Edge Conditions

- Verify `jr board`, `jr project`, `jr me` all result in allow behavior from the analyst's perspective.
- Verify `jr issue comment` (posting a review comment) also does NOT produce a block.

## Failure Guidance

"HOLDOUT LOW: HS-002 (satisfaction: 0.XX) — A read-only Jira operation was incorrectly blocked by the require-review hook; the plugin over-blocked a non-mutating command."

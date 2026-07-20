---
document_type: holdout-scenario
level: ops
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-6.01.002.md
  - specs/module-criticality.md
input-hash: "1c57419"
traces_to: phase-0-ingestion/behavioral-contracts/BC-6.01.002.md
id: "HS-025"
category: "regression-baseline"
must_pass: "true"
priority: "must-pass"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-6.01.002
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: deactivate Skill — Does Not Remove Another Plugin's Agent

## Scenario

1. The secops-factory plugin is in the Claude Code environment.
2. The project's `.claude/settings.local.json` contains `"agent": "vsdd-factory:orchestrator:orchestrator"` — a different plugin's agent (NOT secops-factory) is set as default.
3. The analyst runs `/deactivate`.
4. The skill announces itself and reads the settings file.
5. The skill detects that the current agent is NOT a secops-factory agent.
6. The skill **stops and warns** the analyst that the current agent belongs to a different plugin.
7. The skill does NOT modify the settings file.
8. `vsdd-factory:orchestrator:orchestrator` remains as the default agent.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-6.01.002 | Invariant 2: if `agent` key points to non-secops-factory agent, skill stops and warns — never removes another plugin's default agent | Steps 5-8 verify the cross-plugin safety guard |
| BC-6.01.002 | Edge Case EC-002: `agent` is `vsdd-factory:orchestrator:orchestrator` → stop and warn; do not remove another plugin's agent | This is the exact documented edge case |

## Verification Approach

Set up a settings.local.json with a competing agent and run deactivate:

> "In a project where settings.local.json has `{"agent": "vsdd-factory:orchestrator:orchestrator"}`, run /deactivate."

Observe:
- Claude warns the analyst that the current agent is not a secops-factory agent.
- Claude stops without modifying the file.
- Re-reading settings.local.json confirms the vsdd-factory agent is still set.

## Evaluation Rubric

- **Functional correctness** (weight: 0.6): Did the skill stop without modifying the file? (1.0 = stopped + warned + file unchanged; 0.0 = removed the vsdd-factory agent)
- **Edge case handling** (weight: 0.1): Does the warning message name the detected agent?
- **Error quality** (weight: 0.2): Is the warning clear about why deactivation was refused?
- **Performance** (weight: 0.05): Fast detection.
- **Data integrity** (weight: 0.05): settings.local.json content unchanged after the refused deactivation.

## Edge Conditions

- If there is no `agent` key at all (never activated), the skill should report "secops-factory was never activated here" and stop without creating any file.

## Failure Guidance

"HOLDOUT LOW: HS-025 (satisfaction: 0.XX) — deactivate removed or modified a settings.local.json belonging to a different plugin (vsdd-factory); the cross-plugin safety guard failed and deactivation is destructively over-scoped."

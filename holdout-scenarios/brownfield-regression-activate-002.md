---
document_type: holdout-scenario
level: ops
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-6.01.001.md
  - specs/module-criticality.md
input-hash: ""
traces_to: phase-0-ingestion/behavioral-contracts/BC-6.01.001.md
id: "HS-024"
category: "regression-baseline"
must_pass: "true"
priority: "must-pass"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-6.01.001
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: activate Skill — Competing Agent Detected, User Asked for Confirmation Before Replace

## Scenario

1. The secops-factory plugin is in the Claude Code environment.
2. The project's `.claude/settings.local.json` exists with `"agent": "vsdd-factory:orchestrator:orchestrator"` (a different plugin's agent is active).
3. The analyst runs `/activate` to activate the secops-factory plugin.
4. The skill announces itself and reads the existing settings file.
5. The skill detects that a non-secops-factory agent is already set as the default.
6. The skill **warns the analyst** that another plugin's agent is currently active and **asks for explicit confirmation** before replacing it.
7. If the analyst confirms, the skill proceeds with activation and replaces the agent key.
8. If the analyst declines, the skill stops without modifying the file.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-6.01.001 | Postcondition 7: if existing `agent` key points to non-secops agent → warn user and ask confirmation before replacing | Steps 5-7 verify the confirmation gate |
| BC-6.01.001 | Edge Case EC-002: settings.local.json with `agent: vsdd-factory:orchestrator:orchestrator` → warn + ask confirmation | This is the exact documented edge case |
| BC-6.01.001 | Invariant 4: activation does not remove or disable other plugins | The merge-not-overwrite approach must preserve other keys |

## Verification Approach

Set up a settings.local.json with a competing agent and run activate:

> "In a project with settings.local.json containing `{"agent": "vsdd-factory:orchestrator:orchestrator"}`, run /activate."

Observe:
- Claude's response includes a warning identifying the currently active agent (vsdd-factory:orchestrator:orchestrator).
- Claude asks for confirmation: "Do you want to replace this with secops-factory?" or equivalent.
- If the evaluator says "yes," activation proceeds.
- If the evaluator says "no" (or ignores), the file is unchanged.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Did the skill ask for confirmation before replacing the competing agent? (1.0 = warning + confirmation request; 0.0 = silently replaced without asking)
- **Edge case handling** (weight: 0.2): Does the warning name the specific competing agent?
- **Error quality** (weight: 0.2): Is the confirmation request clear about what will change?
- **Performance** (weight: 0.05): Fast detection and warning.
- **Data integrity** (weight: 0.05): Other keys (permissions, env vars) are preserved during the replacement merge.

## Edge Conditions

- An idempotent re-run (secops-factory agent already active) should NOT prompt for confirmation — it should simply confirm "already activated" and exit.

## Failure Guidance

"HOLDOUT LOW: HS-024 (satisfaction: 0.XX) — activate silently replaced a competing plugin's default agent without asking the user for confirmation; the competing-agent guard was bypassed."

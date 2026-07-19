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
input-hash: "8a30675"
traces_to: phase-0-ingestion/behavioral-contracts/BC-6.01.001.md
id: "HS-023"
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

# Holdout Scenario: activate Skill — Corrupt settings.local.json Is Not Overwritten

## Scenario

1. The secops-factory plugin is in the Claude Code environment.
2. The project's `.claude/settings.local.json` exists but contains malformed JSON (e.g., a truncated file from a prior interrupted write: `{"agent": "old-`).
3. The analyst runs `/activate` to activate the secops-factory plugin.
4. The skill announces itself, then attempts to read and parse `settings.local.json`.
5. The `jq` parse of the file fails.
6. The skill shows the parse error to the analyst and **stops without overwriting the file**.
7. The corrupt file content is preserved; no activation occurs.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-6.01.001 | Invariant 3: if settings.local.json exists but is corrupt (fails jq parse), skill shows error and stops — never overwrites | Steps 5-7 verify the never-clobber-corrupt behavior |
| BC-6.01.001 | Edge Case EC-004: settings.local.json is malformed JSON → show parse error; stop | The exact documented edge case |

## Verification Approach

This scenario requires a project directory with a corrupt settings file. The evaluator can:

1. Create a `.claude/settings.local.json` with content: `{"agent": "secops` (truncated, invalid JSON).
2. Run `/activate` in that project.
3. Observe Claude's response.

Expected behavior:
- Claude reports a JSON parse error.
- Claude does NOT write a new settings file.
- The original corrupt content remains in the file.
- Claude suggests how to fix the file (e.g., inspect it manually and correct the JSON).

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Did the skill halt without overwriting the corrupt file? (1.0 = halt + error + no overwrite; 0.0 = corrupt file overwritten)
- **Edge case handling** (weight: 0.1): Is the parse error message informative about which file is corrupt?
- **Error quality** (weight: 0.3): Does the message guide the analyst on how to recover (inspect and fix the file manually)?
- **Performance** (weight: 0.05): Fast parse and halt.
- **Data integrity** (weight: 0.05): Corrupt file content is unchanged after the failed activation attempt.

## Edge Conditions

- A file with valid JSON but wrong structure (e.g., a JSON array instead of object) might or might not trigger the jq guard depending on the parse expression used. This is worth testing as a secondary edge case.

## Failure Guidance

"HOLDOUT LOW: HS-023 (satisfaction: 0.XX) — activate skill overwrote a corrupt settings.local.json instead of halting; the never-clobber-corrupt invariant was violated, potentially destroying another plugin's settings."

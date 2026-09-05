---
document_type: holdout-scenario
level: ops
version: "1.0"
status: active
producer: product-owner
timestamp: 2026-09-04T00:00:00
phase: "f3"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-6.01.001.md
input-hash: "f39a471"
traces_to: phase-0-ingestion/behavioral-contracts/BC-6.01.001.md
id: "HS-053"
category: "f3-delta"
must_pass: "true"
priority: "must-pass"
epic_id: "F3-DELTA-PRISM-INTEGRATION"
behavioral_contracts:
  - BC-6.01.001
lifecycle_status: active
introduced: v0.10.0-feature-prism-integration
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
dtu_required: false
wave_tag: f3-w1
---

# Holdout Scenario: CLOSE_STATE_ALLOWLIST — Invalid Close State Fails Activate Early, Config Not Written

## Scenario

The activate skill's `CLOSE_STATE_ALLOWLIST` validation rejects any `jira_close_state`
value outside `{"Done", "Closed", "Resolved"}` BEFORE writing any configuration — so
a monitoring-loop is never deployed with an invalid close state that would break the
FP auto-close path.

1. The secops-factory plugin is installed but NOT yet activated in a test project.
   No `settings.local.json`, no `prism.toml`, and no `activate.toml` exist in the
   project.
2. The evaluator invokes the activate skill:
   > "/activate"
3. The skill begins the activation walkthrough and, at the point where it requests
   `jira_close_state`, the evaluator provides:
   > "Complete"
   (This value is NOT in the CLOSE_STATE_ALLOWLIST = `{"Done", "Closed", "Resolved"}`.)
4. Observable: The activation FAILS early with an explicit error message.
   The message must contain both the rejected value and the allowlist:
   "jira_close_state 'Complete' is not valid. Allowed values: Done, Closed, Resolved."
   (or equivalent wording that identifies the invalid value and the valid alternatives).
5. No `prism.toml`, `activate.toml`, or `settings.local.json` is written or modified
   with the invalid value.
6. The activation is halted before any config file is committed to disk.
7. A second invocation of `/activate` with `jira_close_state="Done"` (a valid value)
   completes activation successfully and writes the configuration.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-6.01.001 | PC#13 — `jira_close_state` validated against CLOSE_STATE_ALLOWLIST at setup time | Steps 3–5: invalid value rejected before any config write |
| BC-6.01.001 | EC-015 — invalid close state: activation fails with explicit error | Step 4: error message identifies rejected value and valid alternatives |
| BC-6.01.001 | Invariant — CLOSE_STATE_ALLOWLIST check in activation code path, NOT at runtime | Step 5: no config written; validation fires at activation, not during monitoring-loop run |
| BC-6.01.001 | Invariant — LLM injection prevention via hardcoded allowlist | Step 6: the invalid value cannot be injected into the config through activation |

## DTU Setup Requirements

No DTU required — uses only local filesystem.

- Start with a clean project (no existing `settings.local.json`, `prism.toml`, or
  `activate.toml`).
- Plugin installed (available as a Claude Code slash command).
- No external services needed for this scenario.

## Verification Approach

The evaluator interacts with Claude Code CLI with the plugin available.

**Attempt 1 (invalid value):**
```
/activate
```
When prompted for `jira_close_state`, respond:
```
Complete
```

**Observe:**
1. Claude's response must include an explicit error message rejecting `"Complete"`.
2. The message must reference the allowed values: `Done`, `Closed`, `Resolved`.
3. After the failed attempt, confirm no config files were written:
   - `settings.local.json` must not contain a monitoring-loop entry.
   - `prism.toml` must not exist (or remain unchanged if pre-existing).
   - `activate.toml` must not contain `jira_close_state = "Complete"`.
4. Activation stops — Claude does not proceed to further setup steps.

**Attempt 2 (valid value):**
```
/activate
```
When prompted for `jira_close_state`, respond:
```
Done
```

**Observe:**
1. Activation proceeds normally.
2. Configuration files are written with `jira_close_state = "Done"`.

The evaluator must NOT inspect hook source code. Only observable conversation
output and filesystem state are in scope.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Does activation fail with a meaningful error for `"Complete"`, and succeed for `"Done"`? (1.0 = both behave correctly; 0.0 = invalid value accepted or valid value rejected)
- **Edge case handling** (weight: 0.1): Are no config files written after the failed attempt?
- **Error quality** (weight: 0.3): Does the error message identify the invalid value and list valid alternatives?
- **Performance** (weight: 0.05): Failure is immediate (no activation proceeds past the validation step).
- **Data integrity** (weight: 0.05): No `jira_close_state = "Complete"` persists anywhere in the project config.

## Edge Conditions

- Test with `jira_close_state=""` (empty string): must also fail with an appropriate
  message (empty value is not in the allowlist).
- Test with `jira_close_state` not provided at all: skill must prompt rather than
  defaulting to an invalid value.
- Confirm that after a failed attempt, a subsequent valid activation does not inherit
  any state from the failed attempt.

## Failure Guidance

"HOLDOUT HIGH: HS-053 (satisfaction: 0.XX) — The activate skill accepted an invalid jira_close_state value ('Complete') and proceeded with or without writing the config. The CLOSE_STATE_ALLOWLIST setup-time validation (BC-6.01.001 PC#13/EC-015) is absent or not enforced before config writes."

## Category: real-world-corpus

N/A — This is a `security-probes` scenario using synthetic activation inputs.

| Field | Description |
|-------|-------------|
| corpus_source | Synthetic activation input (jira_close_state="Complete") |
| corpus_size | 2 activation attempts |
| known_edge_cases | Empty jira_close_state; jira_close_state not provided |
| false_positive_threshold | N/A |
| false_negative_threshold | N/A |

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
id: "HS-054"
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

# Holdout Scenario: CLOSE_STATE_ALLOWLIST — Case-Sensitivity (Lowercase Rejected, Exact Casing Required)

## Scenario

The CLOSE_STATE_ALLOWLIST is an exact-match, case-sensitive set. Only the precisely
cased strings `"Done"`, `"Closed"`, and `"Resolved"` are accepted; all other strings
including lowercase or uppercase variants must be rejected.

This scenario runs five test cases across two activations (or one activation with
multiple prompting rounds) to verify exact-match enforcement:

**Test A — `jira_close_state="done"` (all lowercase):**
1. Analyst invokes `/activate` and provides `jira_close_state="done"`.
2. Activation FAILS. Error message references `"Done, Closed, Resolved"`.
3. No config file written.

**Test B — `jira_close_state="DONE"` (all uppercase):**
1. Same as Test A but with `"DONE"`.
2. Activation FAILS. Error message references the same valid set.
3. No config file written.

**Test C — `jira_close_state="Done"` (correct casing):**
1. Analyst invokes `/activate` and provides `jira_close_state="Done"`.
2. Activation SUCCEEDS. Configuration is written with `jira_close_state="Done"`.

**Test D — `jira_close_state="Closed"` (correct casing):**
1. Activation SUCCEEDS.

**Test E — `jira_close_state="Resolved"` (correct casing):**
1. Activation SUCCEEDS.

The CLOSE_STATE_ALLOWLIST is a hardcoded constant set — it is NOT derived from user
input, environment variables set at invocation time, or any verdict field.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-6.01.001 | AC-005 — case-sensitive allowlist check: "done", "DONE" are NOT valid | Tests A and B: lowercase/uppercase variants rejected |
| BC-6.01.001 | AC-004 — valid values "Done", "Closed", "Resolved" pass without warning | Tests C, D, E: exact-casing accepted; no spurious errors |
| BC-6.01.001 | AC-006 — hardcoded constant set; not derived from user input or env | Tests A–E: consistent behavior regardless of runtime context |
| BC-6.01.001 | EC-015 — invalid close state fails early with explicit error | Tests A and B: error message identifies valid alternatives |

## DTU Setup Requirements

No DTU required — uses only local filesystem.

- Plugin installed; clean project state (no pre-existing config) for each test group.
- No external services needed.

## Verification Approach

The evaluator interacts with Claude Code CLI with the plugin available. Run tests
sequentially, resetting project state between invalid-value tests (to ensure no
partial config from a failed test contaminates the next).

**Tests A and B (invalid — reject):**
```
/activate
```
Provide `jira_close_state="done"` (Test A) or `"DONE"` (Test B).

Observe: Error message with "Allowed values: Done, Closed, Resolved". No config written.

**Tests C, D, E (valid — accept):**
```
/activate
```
Provide `jira_close_state="Done"` (C), `"Closed"` (D), or `"Resolved"` (E).

Observe: Activation proceeds and completes. Config written with the supplied value.

The evaluator must NOT inspect hook source code. Only observable outputs are in scope.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Do all 5 test cases produce the expected outcome (reject/accept)? (1.0 = all 5 correct; 0.8 = 4/5; 0.0 = invalid values accepted)
- **Edge case handling** (weight: 0.1): Tests A and B both fail without writing config?
- **Error quality** (weight: 0.3): Error messages for A and B identify the allowed values?
- **Performance** (weight: 0.05): Failures are immediate; valid activations complete normally.
- **Data integrity** (weight: 0.05): No invalid `jira_close_state` persists in any config file after failed tests.

## Edge Conditions

- Test with `jira_close_state="done "` (trailing space): must also be rejected
  (the allowlist uses exact strings, no trim normalization).
- Test with locale-aware variants if relevant (e.g., `"Done"` with a smart quote
  or Unicode variant character): must be rejected.
- Confirm that a pre-existing valid config (e.g., `jira_close_state="Done"`) is
  NOT overwritten by a failed activation attempt with an invalid value.

## Failure Guidance

"HOLDOUT HIGH: HS-054 (satisfaction: 0.XX) — The activate skill accepted a case-variant of a valid close state (e.g., 'done' instead of 'Done'). The CLOSE_STATE_ALLOWLIST check is not case-sensitive: only 'Done', 'Closed', and 'Resolved' (exact casing) are valid, and all other strings must be rejected."

## Category: real-world-corpus

N/A — This is an `edge-case-combinations` scenario using synthetic activation inputs
testing allowlist boundary conditions.

| Field | Description |
|-------|-------------|
| corpus_source | Synthetic activation inputs (case variants) |
| corpus_size | 5 test cases |
| known_edge_cases | Trailing space; Unicode variant characters |
| false_positive_threshold | N/A |
| false_negative_threshold | N/A |

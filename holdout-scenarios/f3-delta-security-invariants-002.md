---
document_type: holdout-scenario
level: ops
version: "1.0"
status: active
producer: product-owner
timestamp: 2026-09-04T00:00:00
phase: "f3"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-3.03.001.md
  - phase-0-ingestion/behavioral-contracts/BC-6.01.001.md
input-hash: "7f899ed"
traces_to: phase-0-ingestion/behavioral-contracts/BC-3.03.001.md
id: "HS-056"
category: "f3-delta"
must_pass: "true"
priority: "must-pass"
epic_id: "F3-DELTA-PRISM-INTEGRATION"
behavioral_contracts:
  - BC-3.03.001
  - BC-6.01.001
lifecycle_status: active
introduced: v0.10.0-feature-prism-integration
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: "R-002"
dtu_required: false
wave_tag: f3-w2
---

# Holdout Scenario: D-023 CLOSE-STATE-DENY Emit-Time Check — Config-Drift Defense

## Scenario

The D-023 decision establishes that the `CLOSE_STATE_ALLOWLIST` is enforced at two
distinct checkpoints: at activation time (BC-6.01.001 setup-time gate) AND at
disposition-guard emit time (BC-3.03.001 STEP 1: `CLOSE_STATE_ALLOWLIST` check before
allowing any close-disposition write).

The emit-time check is a defense against config-drift: if the monitoring-loop
produces a verdict with a `close_state` value that was somehow injected or drifted
since activation (e.g., through an in-context prompt injection or a verdict that
misuses a non-allowlist value), the disposition-guard must catch and deny it before
the Jira close write fires.

This scenario probes the emit-time check directly by providing a verdict with an
off-allowlist `close_state` value to confirm the disposition-guard denies it.

**Sub-scenario A — off-allowlist close state from verdict:**

1. Plugin is activated with a valid `jira_close_state="Done"` (activation succeeds,
   config is written with "Done").
2. The evaluator provides a verdict context where `close_state="Completed"` (a
   plausible but non-allowlist value that might appear if a model deviated from
   its grounding).
3. The verdict includes `ticket_action_type="close"` (a close-disposition write).
4. The disposition-guard's STEP 1 `CLOSE_STATE_ALLOWLIST` check fires.
5. Observable: The Jira close write is DENIED. No `jr issue close` or
   `jr issue transition` call is made.
6. The audit log or Claude response contains a `CLOSE-STATE-DENY` entry identifying
   the invalid close state and the allowlist.

**Sub-scenario B — close state not in config (no activation):**

1. Plugin is NOT activated (no config file exists, no `jira_close_state` set).
2. A verdict with `ticket_action_type="close"` arrives.
3. Disposition-guard fires; it cannot resolve `jira_close_state` from config.
4. Observable: The close write is DENIED. The error message indicates the plugin
   has not been configured for close operations (or that `jira_close_state` is
   absent from the config).
5. No `jr issue close` is called.

Both sub-scenarios confirm: close-disposition writes require an explicitly configured
`jira_close_state` that is both present AND a member of `{"Done", "Closed", "Resolved"}`.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-3.03.001 | D-023 STEP 1 — CLOSE_STATE_ALLOWLIST emit-time check before any close write | Sub-A step 4–6: off-allowlist close state denied at disposition-guard emit time |
| BC-3.03.001 | CLOSE-STATE-DENY audit code — emitted when STEP 1 fails | Sub-A step 6: audit log contains CLOSE-STATE-DENY |
| BC-6.01.001 | CLOSE_STATE_ALLOWLIST = {"Done","Closed","Resolved"}, case-sensitive exact match | Sub-A: "Completed" not in allowlist → denied |
| BC-3.03.001 | D-023 LLM injection prevention — allowlist checked against hardcoded constant, not verdict field | Sub-A: verdict field cannot override allowlist; deny is unconditional |
| BC-3.03.001 | Absent config handling — close write requires configured jira_close_state | Sub-B: no config → close write denied |

## DTU Setup Requirements

No DTU required — uses jr mock and local filesystem.

- Sub-A: Activate the plugin with `jira_close_state="Done"` to establish a valid config.
  Then provide a verdict with `close_state="Completed"`.
- Sub-B: Ensure no activation config exists; provide a verdict with
  `ticket_action_type="close"`.
- Configure a jr mock to record all `jr issue close` and `jr issue transition` calls
  (to confirm they are NOT called in either sub-scenario).

## Verification Approach

The evaluator provides verdict contexts that trigger close-disposition writes.

**Sub-scenario A — Prompt:**
```
/monitoring-loop
```
(with fixture pre-loaded so the monitoring-loop produces a verdict with
`ticket_action_type="close"` and `close_state="Completed"`)

**Observe (Sub-A):**
1. Claude's response does NOT confirm a successful Jira close action.
2. The response or audit log contains a denial message referencing:
   - The invalid `close_state` value (`"Completed"`)
   - The allowed values: `Done`, `Closed`, `Resolved`
3. The jr mock call log: `jr issue close` and `jr issue transition` are NOT called.
4. A `CLOSE-STATE-DENY` code appears in the audit log.

**Sub-scenario B — No activation, no config:**
Same prompt with no config present.

**Observe (Sub-B):**
1. Close write is denied (no `jr issue close` in call log).
2. Error references missing configuration or missing `jira_close_state`.

The evaluator must NOT inspect hook source code. Only observable outputs are in scope.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Sub-A: close write denied for off-allowlist close state? Sub-B: close write denied for unconfigured plugin? (1.0 = both denied correctly; 0.5 = one; 0.0 = off-allowlist value accepted)
- **Edge case handling** (weight: 0.1): Does the Sub-A audit log contain `CLOSE-STATE-DENY` with the invalid value?
- **Error quality** (weight: 0.3): Does the denial message identify the allowed values?
- **Performance** (weight: 0.05): Denials are immediate (no partial Jira action fired before the deny).
- **Data integrity** (weight: 0.05): No `jr issue close` or `jr issue transition` call logged in either sub-scenario.

## Edge Conditions

- Test that a valid close state (`"Done"`, `"Closed"`, `"Resolved"`) in the verdict IS
  allowed when the config matches — the allowlist must not over-deny.
- Test `close_state="done"` (lowercase): must also be denied (same case-sensitivity
  as the activation-time check).
- Confirm that the emit-time check uses the hardcoded allowlist constant — NOT the
  verdict's `close_state` field to validate itself, and NOT a user-supplied config
  that could be injected.

## Failure Guidance

"HOLDOUT CRITICAL: HS-056 (satisfaction: 0.XX) — Sub-A: The disposition-guard accepted a close-disposition write with close_state='Completed', which is not in the CLOSE_STATE_ALLOWLIST. D-023 emit-time check is absent or not enforced. This means an injected or drifted close state can bypass the allowlist, creating an LLM-injection vector. Sub-B: Close write succeeded without a configured jira_close_state, indicating the plugin does not require explicit configuration before close writes."

## Category: real-world-corpus

N/A — This is a `security-probes` scenario using synthetic verdict fixtures.
D-023 config-drift defense and CLOSE-STATE-DENY coverage.

| Field | Description |
|-------|-------------|
| corpus_source | Synthetic verdict fixtures (off-allowlist and no-config close attempts) |
| corpus_size | 2 verdicts (one per sub-scenario) |
| known_edge_cases | Valid close state must be allowed; lowercase variant must be denied |
| false_positive_threshold | N/A |
| false_negative_threshold | N/A |

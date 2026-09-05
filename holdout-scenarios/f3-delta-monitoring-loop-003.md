---
document_type: holdout-scenario
level: ops
version: "1.0"
status: active
producer: product-owner
timestamp: 2026-09-04T00:00:00
phase: "f3"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-10.01.001.md
  - phase-f2-spec-evolution/dtu-assessment.md
input-hash: "74e6c55"
traces_to: phase-0-ingestion/behavioral-contracts/BC-10.01.001.md
id: "HS-037"
category: "f3-delta"
must_pass: "true"
priority: "must-pass"
epic_id: "F3-DELTA-PRISM-INTEGRATION"
behavioral_contracts:
  - BC-10.01.001
lifecycle_status: active
introduced: v0.10.0-feature-prism-integration
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: "ASM-013"
risk_source: "R-001"
dtu_required: true
wave_tag: f3-w4
---

# Holdout Scenario: Monitoring-Loop — Hard-Floor Indeterminate Routes to create-review Regardless of Kill Switch

## Scenario

1. The prism DTU stack is running with org-b fixture (seed=150). The Claroty sensor is configured as `degraded` in the DTU fixture (sensor health returns a degraded status rather than healthy).
2. Plugin config: `autonomy_enabled=true` (kill switch NOT engaged — worst case for hard-floor bypass testing).
3. Jr mock is configured with `no-match` scenario (no existing Jira tickets for this org/sensor).
4. The evaluator invokes the monitoring-loop via the Claude Code CLI:
   ```
   claude -p "/monitoring-loop" \
     --strict-mcp-config \
     --mcp-config "${TEST_PRISM_MCP_CONFIG}" \
     --allowedTools "mcp__prism__*,mcp__tavily__tavily_search,mcp__perplexity__perplexity_ask,Bash,Write,Read,Edit" \
     --output-format json \
     < /dev/null
   ```
5. The loop detects `sensor_health_status=degraded` for the Claroty sensor.
6. The loop produces an Indeterminate verdict: `verdict.disposition` starts with `"Indeterminate"`.
7. Because `sensor_health_status=degraded` is a hard-floor condition (§3.9), `verdict.ticket_action_type` is set to `"create-review"` — NOT `"none"`, even though `autonomy_enabled=true`.
8. A `jr issue create --project PRISMDEMO --label REVIEW-REQUIRED` call is recorded in the jr mock call log.
9. No REGULAR (non-review) `jr issue comment`, `jr issue create` (without REVIEW-REQUIRED label), or `jr issue assign` is called.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-10.01.001 | §3.9 hard-floor: `sensor_health_status ∈ {degraded, silent}` forces `ticket_action_type=create-review` | Steps 7–8 verify hard-floor routing unconditionally overrides kill switch |
| BC-10.01.001 | D-DEC-012 Option A: `create-review`/`comment-review` EXEMPT from the `autonomy_enabled` kill switch | Step 7 verifies the ticket is created even with `autonomy_enabled=true` (both kill-switch states must pass) |
| BC-10.01.001 | Invariant #10: hard-floor verdicts NEVER silently discarded; `ticket_action_type="none"` is a defect for hard-floor | Step 7 explicitly tests that `"none"` is NOT the outcome |

## DTU Setup Requirements

- **prism DTU stack**: org-b fixture (seed=150), Claroty sensor with `sensor_health_status=degraded` (degraded-sensor fixture).
- **jr L2 stateful mock**: `MOCK_JR_SCENARIO=no-match` — empty issue registry.
- **Plugin config**: `autonomy_enabled=true` (test the hard-floor bypass prevention under the most permissive kill-switch setting).
- Run a second pass with `autonomy_enabled=false` to confirm the same create-review behavior (D-DEC-012 Option A covers both states).

## Verification Approach

The holdout evaluator invokes the monitoring-loop as shown in the Scenario and observes these black-box outputs only:

1. **Verdict JSON** (`--output-format json`): Assert:
   - `verdict.sensor_health_status == "degraded"`
   - `verdict.disposition` starts with `"Indeterminate"`
   - `verdict.ticket_action_type == "create-review"`

2. **jr mock call log**: Assert:
   - `jr issue create --project PRISMDEMO --label REVIEW-REQUIRED` called exactly once.
   - No regular `jr issue comment`, `jr issue create` (without review label) in the log.

3. **Cron wrapper**: Clean exit (exit code 0). No audit.log flags.

The evaluator must NOT inspect hook source or marker-store internals.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Was `ticket_action_type=create-review` set and was `jr issue create --label REVIEW-REQUIRED` called? (1.0 = both correct; 0.5 = verdict field correct but jr call missing or wrong label; 0.0 = `ticket_action_type="none"` or regular ticket issued)
- **Edge case handling** (weight: 0.1): Does the result hold for both `autonomy_enabled=true` AND `autonomy_enabled=false`?
- **Error quality** (weight: 0.3): Does `agent_actions` (field 10) document that sensor degradation triggered the hard-floor routing decision?
- **Performance** (weight: 0.05): Loop completes within the 15-minute per-org budget.
- **Data integrity** (weight: 0.05): No regular marker files remain in the marker-store (only review-class markers should exist).

## Edge Conditions

- Swap sensor to `silent` (last_seen > 24h): the same `create-review` hard-floor routing must apply.
- Inject `autonomy_enabled=false` in plugin config: `create-review` must still fire (D-DEC-012 Option A exemption).
- Inject a non-hard-floor TP alert alongside the degraded-sensor alert: the TP alert must be handled separately; only the degraded-sensor alert routes to `create-review`.

## Failure Guidance

"HOLDOUT CRITICAL: HS-037 (satisfaction: 0.0) — The monitoring-loop set `ticket_action_type='none'` or issued a regular (non-review) ticket for a sensor-degraded Indeterminate verdict. Hard-floor routing was bypassed. This materializes R-001 (hard floors migrated to config-evaluated conditions)."

## Category: real-world-corpus

These monitoring-loop scenarios run against the prism DTU demo server with seeded fixtures. The degraded-sensor fixture provides the `sensor_health_status=degraded` state needed to exercise the hard-floor routing path without requiring a live sensor failure.

| Field | Value |
|-------|-------|
| corpus_source | prism-dtu-demo-server org-b (seed=150) — Claroty degraded-sensor fixture |
| corpus_size | 1 degraded sensor; Indeterminate verdict path |
| known_edge_cases | Hard-floor bypass when `autonomy_enabled=true`; degraded vs silent routing parity |
| false_positive_threshold | N/A — hard-floor routing must always fire |
| false_negative_threshold | 0% — any Indeterminate/degraded-sensor verdict that does not produce a review ticket is a defect |

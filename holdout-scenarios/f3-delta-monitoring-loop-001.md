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
id: "HS-035"
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
risk_source: null
dtu_required: true
wave_tag: f3-w4
---

# Holdout Scenario: Monitoring-Loop — Claroty xDome Sensor-Silence BLIND-SPOT Creates Review Ticket (org-b, First Run)

## Scenario

1. The prism DTU stack (prism-dtu-demo-server) is running with the org-b fixture (seed=150). The Claroty xDome sensor for org-b has `last_seen` set to 36 hours ago in the DTU fixture, placing it firmly in the "silent >24h" state.
2. No watermark file exists for the org-b × Claroty sensor pair (this is a first run for this org/sensor).
3. The jr mock is configured with the `blind-spot-absent` scenario: the issue registry contains zero open BLIND-SPOT tickets for org-b × Claroty.
4. The evaluator invokes the monitoring-loop via the Claude Code CLI:
   ```
   claude -p "/monitoring-loop" \
     --strict-mcp-config \
     --mcp-config "${TEST_PRISM_MCP_CONFIG}" \
     --allowedTools "mcp__prism__*,mcp__tavily__tavily_search,mcp__perplexity__perplexity_ask,Bash,Write,Read,Edit" \
     --output-format json \
     < /dev/null
   ```
5. The loop queries prism sensor health for org-b; the Claroty sensor reports `last_seen` > 24h ago (silent).
6. The loop produces an Indeterminate verdict with `sensor_health_status=silent` and a BLIND-SPOT classification.
7. The verdict `ticket_action_type` is set to `create-review`.
8. A `jr issue create --project PRISMDEMO --label BLIND-SPOT` command is issued (via the jr mock) and recorded in the call log.
9. No `jr issue move`, no `jr issue comment`, and no regular (non-review) marker is issued for this alert.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-10.01.001 | EC-006: sensor-silence = BLIND-SPOT positive finding; `create-review`/`comment-review` ticket action | Steps 6–8 verify sensor-silence detection and BLIND-SPOT ticket creation |
| BC-10.01.001 | §3.7: sensor-silence is a positive security signal, not an absence of signal | Step 6 requires the loop to treat silence as a finding, not an empty run |
| BC-10.01.001 | §3.9: hard-floor — `sensor_health_status=silent` forces `ticket_action_type` to `create-review` or `comment-review` | Step 7 verifies hard-floor routing applies |
| BC-10.01.001 | D-DEC-012 Option A: `create-review`/`comment-review` are EXEMPT from the autonomy_enabled kill switch | Step 8 verifies the ticket is created regardless of `autonomy_enabled` state |
| BC-10.01.001 | Invariant #13: first run with no watermark uses 24h lookback | Step 2/5 verifies the loop does not query for full history |

## DTU Setup Requirements

- **prism DTU stack**: `prism-dtu-demo-server` running with `configs/prism-demo.toml`; org-b fixture (seed=150) active with Claroty sensor `last_seen` = 36h ago (sensor-silence state).
- **jr L2 stateful mock**: `MOCK_JR_SCENARIO=blind-spot-absent` — issue registry contains zero BLIND-SPOT tickets for org-b × Claroty sensor ID.
- **Watermark state**: no watermark file present for org-b × Claroty sensor pair in `${CLAUDE_PLUGIN_DATA}/watermarks/`.
- **Plugin config**: `autonomy_enabled` may be either `true` or `false` — the scenario must pass in both states (BLIND-SPOT is a hard-floor route exempt from the kill switch).

## Verification Approach

The holdout evaluator invokes the monitoring-loop as shown in the Scenario section and observes the following **black-box outputs only**:

1. **Verdict JSON output** (`--output-format json`): Parse the emitted verdict object. Assert:
   - `verdict.sensor_health_status == "silent"`
   - `verdict.disposition` starts with `"Indeterminate"`
   - `verdict.ticket_action_type == "create-review"`

2. **jr mock call log** (`$MOCK_JR_CALL_LOG`): Assert:
   - `jr issue create` was called exactly once.
   - The call includes `--project PRISMDEMO` and `--label BLIND-SPOT`.
   - No `jr issue move`, `jr issue comment` (without BLIND-SPOT context), or `jr issue assign` appears in the log.

3. **Cron wrapper output**: The loop exits without error; Gate 1 and Gate 2 pass (no `HARD-FLOOR-LIVELOCK-ABORT`, `HARD-FLOOR-UNBINDABLE`, or `SEVERITY-MISMATCH` entries in `audit.log`).

4. **Watermark file**: After the run, a watermark file exists for org-b × Claroty at `${CLAUDE_PLUGIN_DATA}/watermarks/`. This confirms the loop processed the sensor even though it was silent (the silence itself is the finding).

The evaluator must NOT inspect hook source code, SKILL.md content, or internal marker files. Only the above observable outputs are in scope.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Did the loop create a BLIND-SPOT ticket (`jr issue create --label BLIND-SPOT`) and set `ticket_action_type=create-review` in the verdict? (1.0 = correct ticket + correct verdict field; 0.5 = ticket created but wrong label or verdict field missing; 0.0 = no ticket created for a silent sensor)
- **Edge case handling** (weight: 0.1): Does the ticket have the `BLIND-SPOT` label specifically (not `REVIEW-REQUIRED`)? BLIND-SPOT silence tickets are distinct from generic review tickets.
- **Error quality** (weight: 0.3): Is `agent_actions` (ICD-203 field 10) populated with a description of the sensor-silence detection, including the sensor family and org context?
- **Performance** (weight: 0.05): Loop completes within the 15-minute per-org budget (NFR-PERF-003).
- **Data integrity** (weight: 0.05): No existing Jira tickets are modified; only a new create call is issued.

## Edge Conditions

- Run the scenario with `autonomy_enabled=false` to confirm the BLIND-SPOT ticket is still created (hard-floor exempt from kill switch).
- Run with an existing open BLIND-SPOT ticket in the jr mock (`blind-spot-open` scenario) — the loop should append a comment (`comment-review`) rather than create a new ticket (D-DEC-004 dedup invariant).

## Failure Guidance

"HOLDOUT HIGH: HS-035 (satisfaction: 0.0) — The monitoring-loop did not create a BLIND-SPOT ticket for a sensor silent for >24 hours. The plugin failed to detect a telemetry gap that may conceal an active attack. This is a FALSE NEGATIVE for a sensor-silence finding."

## Category: real-world-corpus

These monitoring-loop scenarios run against the prism DTU demo server (`prism-dtu-demo-server`), which provides OCSF-normalized sensor data from deterministic seeded fixtures that mirror the real CrowdStrike, Claroty xDome, Cyberint, and Armis sensor data formats. The corpus is seeded (not live) but reflects the authentic data shapes, severity taxonomies, and org-scoping rules that the monitoring-loop encounters in production. Evaluators should treat the DTU fixture data as a real-world corpus snapshot.

| Field | Value |
|-------|-------|
| corpus_source | prism-dtu-demo-server org-b fixture (seed=150) — Claroty xDome + Cyberint sensor data |
| corpus_size | Seeded deterministic: ~10 table types, org-b scope |
| known_edge_cases | Sensor silence >24h (Claroty), Cyberint conservative CRITICAL default pre-ASM-008 |
| false_positive_threshold | 0% — any spurious BLIND-SPOT ticket on a healthy sensor is a defect |
| false_negative_threshold | 0% — missing BLIND-SPOT ticket for a silent sensor is a defect |

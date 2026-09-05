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
id: "HS-043"
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
assumption_source: null
risk_source: null
dtu_required: true
wave_tag: f3-w4
---

# Holdout Scenario: Monitoring-Loop — Known-Good Corpus (CrowdStrike org-a Healthy, No New Alerts, Zero Ticket Output)

## Scenario

This is the **known-good corpus scenario**. A healthy sensor with no new alerts above the watermark must produce zero tickets and a clean cron exit. Any ticket creation is a FALSE POSITIVE.

1. prism DTU org-a (seed=100); CrowdStrike sensor healthy (`last_seen` = now, sensor active and reporting normally).
2. A watermark file exists for org-a × CrowdStrike, set to the **current timestamp** (no events are above this watermark — the loop will find zero new alerts).
3. Jr mock: `no-match` scenario; call log should remain empty.
4. Plugin config: `autonomy_enabled=true`.
5. The evaluator invokes the monitoring-loop via the Claude Code CLI.
6. The loop queries prism for org-a CrowdStrike alerts above the watermark; **zero rows are returned** (all alerts are before the watermark timestamp).
7. The loop processes zero alerts; emits zero verdicts.
8. **Zero `jr issue create`, `jr issue comment`, `jr issue link`, or `jr issue move` calls** appear in the jr mock call log.
9. The loop exits with exit code 0.
10. Cron wrapper Gate 1 passes (exit 0 + no `permission_denials`). Gate 2 passes (no deny codes in audit.log).
11. The watermark file for org-a × CrowdStrike is updated to the current run timestamp (or remains at the already-current timestamp if no newer events were found).

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-10.01.001 | Invariant #13: watermark prevents full-history rescans; loop queries only events above watermark | Steps 2–6 verify the loop respects the existing watermark |
| BC-10.01.001 | Cron wrapper Gate 1 + Gate 2 clean exit on zero-alert run | Steps 9–10 verify healthy cron operation with no findings |
| BC-10.01.001 | Zero verdicts on zero alerts — loop does NOT fabricate findings | Step 7 verifies no spurious verdict creation |

## DTU Setup Requirements

- **prism DTU stack**: org-a fixture (seed=100); CrowdStrike sensor healthy; watermark pre-set to current timestamp so zero alerts are above the watermark.
- **jr L2 stateful mock**: `MOCK_JR_SCENARIO=no-match`; call log should show zero calls.
- **Plugin config**: `autonomy_enabled=true`.
- **Watermark state**: watermark file exists at `${CLAUDE_PLUGIN_DATA}/watermarks/org-a/crowdstrike` with an RFC3339 timestamp equal to or slightly after the latest event `_time` in the DTU fixture.

## Verification Approach

The holdout evaluator invokes the monitoring-loop and observes these black-box outputs:

1. **`--output-format json` output**: Assert zero verdict objects are emitted (the output may be an empty array `[]` or the JSON envelope may indicate zero processed alerts).
2. **jr mock call log**: Assert the call log is **empty** — zero jr issue commands of any kind were called.
3. **Cron wrapper**: Exits with exit code 0. No Gate 2 audit.log entries for any deny codes.
4. **Watermark file**: The file at `${CLAUDE_PLUGIN_DATA}/watermarks/org-a/crowdstrike` still exists and its timestamp is valid RFC3339.

The evaluator must verify the ABSENCE of tickets — this is a false-positive guard scenario.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Were zero `jr issue` calls made AND zero verdict objects emitted? (1.0 = zero calls + zero verdicts; 0.0 = any jr call or any verdict for a zero-alert sensor)
- **Edge case handling** (weight: 0.1): Does the loop exit cleanly without error even when there are no new alerts to process?
- **Error quality** (weight: 0.3): Does the loop's output (cron log or stdout) note that org-a CrowdStrike was checked and found zero new alerts?
- **Performance** (weight: 0.05): Loop completes quickly for a zero-alert run (no unnecessary work).
- **Data integrity** (weight: 0.05): The watermark file is intact and RFC3339-valid after a zero-alert run.

## Edge Conditions

- Run immediately after the known-problematic corpus scenario (HS-044): the zero-alert run must still produce zero tickets even if a previous run left state in the jr mock.
- Run with `autonomy_enabled=false`: zero output is still expected for zero-alert input.

## Failure Guidance

"HOLDOUT HIGH: HS-043 (satisfaction: 0.0) — The monitoring-loop created one or more Jira tickets when processing a healthy CrowdStrike sensor with zero new alerts above the watermark. This is a FALSE POSITIVE — the loop fabricated findings from an empty alert stream."

## Category: real-world-corpus

The zero-alert known-good corpus validates that the monitoring-loop does not hallucinate findings when the sensor is healthy and silent-by-watermark. This is a critical operational property: scheduled runs on well-maintained sensors must not generate noise.

| Field | Value |
|-------|-------|
| corpus_source | prism-dtu-demo-server org-a (seed=100) — CrowdStrike sensor; watermark set to now() |
| corpus_size | 0 new alerts (all events below watermark) |
| known_edge_cases | Zero-alert clean exit; watermark-bounded query |
| false_positive_threshold | 0% — any ticket on a zero-alert run is a defect |
| false_negative_threshold | N/A — no findings expected |

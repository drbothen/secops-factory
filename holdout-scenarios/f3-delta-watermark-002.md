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
input-hash: "0e8c703"
traces_to: phase-0-ingestion/behavioral-contracts/BC-10.01.001.md
id: "HS-046"
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
risk_source: "R-003"
dtu_required: true
wave_tag: f3-w5
---

# Holdout Scenario: DETECT_LATE_EVENT — Late-Arriving Alert Below Watermark Detected and Logged

## Scenario

1. The secops-factory plugin is activated with prism DTU org-a (CrowdStrike + Armis
   sensors, seed=100).
2. A valid watermark file exists for org-a × CrowdStrike at timestamp T
   (e.g., `2026-09-03T10:00:00Z`).
3. The DTU fixture for org-a × CrowdStrike contains one alert with `_time` =
   `2026-09-03T09:00:00Z` — which is one hour BEFORE the stored watermark T.
   (Per the late-event detection rule, any event with `_time < stored_watermark`
   is classified as late.)
4. The evaluator invokes the monitoring-loop:
   > "/monitoring-loop"
5. The late-arriving alert IS processed — it is NOT silently dropped or skipped.
   A verdict is emitted for it.
6. A `LATE_EVENT_DETECTED` AUDIT entry is written to
   `${CLAUDE_PLUGIN_DATA}/watermarks/audit.log` (EC-023). This entry records
   the event time, the stored watermark value, and the time delta between them.
   Nothing is written to `verdict.agent_actions` for late-event detection.
7. The watermark file is updated normally after the run — the late event does NOT
   prevent watermark advancement to the maximum processed `_time`.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-10.01.001 | EC-023 — late-event-below-watermark → logged-not-dropped | Step 5: alert is processed (not dropped); Step 6: LATE_EVENT_DETECTED AUDIT entry in watermarks/audit.log |
| BC-10.01.001 | EC-023 — DETECT_LATE_EVENT appends AUDIT entry to watermarks/audit.log when event._time < stored_watermark | Step 6: entry present in watermarks/audit.log with event_time, watermark, and delta (NOT in agent_actions) |
| BC-10.01.001 | Invariant #14 — event processed normally (NEVER dropped on late detection) | Step 5: verdict emitted despite late classification |
| BC-10.01.001 | Invariant #13 — watermark monotonicity | Step 7: watermark advances normally after run |

## DTU Setup Requirements

**DTU required: prism-dtu-demo-server + configs/prism-demo.toml**

- Start `prism-dtu-demo-server` from the prism-demo-bundle release asset. Configure
  org-a at seed=100 (CrowdStrike + Armis sensors).
- Set `DEMO_FAKE_CROWDSTRIKE_TOKEN` and `DEMO_FAKE_ARMIS_TOKEN` env vars.
- Seed the watermark file at `${CLAUDE_PLUGIN_DATA}/watermarks/org-a/crowdstrike`
  with `2026-09-03T10:00:00Z`.
- Configure the DTU fixture to include one CrowdStrike event with
  `_time = 2026-09-03T09:00:00Z` (one hour before the stored watermark).
- Optionally include one more event at `2026-09-03T10:30:00Z` (above watermark) to
  confirm normal events are also processed and the watermark advances past both.

## Verification Approach

The evaluator interacts with Claude Code CLI with the plugin and prism DTU active.

**Prompt:**
```
/monitoring-loop
```

**Observe:**
1. Claude's response confirms at least 1 alert was processed for org-a × CrowdStrike.
2. Locate the verdict for the alert with `_time = 2026-09-03T09:00:00Z`.
3. Read `${CLAUDE_PLUGIN_DATA}/watermarks/audit.log` after the run:
   - It must contain a `LATE_EVENT_DETECTED` entry for the event at `2026-09-03T09:00:00Z`.
   - The entry must record the event time, the stored watermark value, and the
     time delta (e.g., "event_time: 2026-09-03T09:00:00Z, watermark: 2026-09-03T10:00:00Z,
     delta: -3600s" or equivalent).
   - `verdict.agent_actions` is NOT the location for this entry — do NOT look there.
4. The verdict itself is fully populated — the late event was processed normally.
5. After the run, read the watermark file — it must have advanced beyond
   `2026-09-03T09:00:00Z` (to at least the maximum `_time` processed).

The evaluator must NOT inspect internal hook source code. Only observable outputs
(verdict JSON, watermarks/audit.log, watermark file) are in scope.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Is a `LATE_EVENT_DETECTED` entry present in `${CLAUDE_PLUGIN_DATA}/watermarks/audit.log` for the late alert? (1.0 = entry present with event_time, watermark, and delta; 0.5 = entry present but incomplete; 0.0 = missing or alert dropped)
- **Edge case handling** (weight: 0.1): Did the late alert produce a full verdict (not silently discarded)?
- **Error quality** (weight: 0.3): Is the `LATE_EVENT_DETECTED` entry informative — does it include the event time and stored watermark for operator diagnosis?
- **Performance** (weight: 0.05): Run completes within a reasonable time.
- **Data integrity** (weight: 0.05): Watermark advances normally after the run; no unexpected rollback or freeze.

## Edge Conditions

- Confirm that a non-late event in the same run (e.g., `_time = 2026-09-03T10:30:00Z`) does NOT produce a `LATE_EVENT_DETECTED` entry in `watermarks/audit.log`.
- Confirm that late detection does not trigger `Indeterminate` disposition on its own — the disposition must be determined by the alert's actual content, not by its late arrival.

## Failure Guidance

"HOLDOUT HIGH: HS-046 (satisfaction: 0.XX) — The monitoring-loop either silently dropped the late-arriving alert (not processed at all) or processed it without writing a LATE_EVENT_DETECTED entry to watermarks/audit.log (EC-023). Late events must be processed and flagged in the watermarks audit log, never silently discarded. Note: LATE_EVENT_DETECTED is NOT written to verdict.agent_actions — check ${CLAUDE_PLUGIN_DATA}/watermarks/audit.log."

## Category: real-world-corpus

N/A — This is a `behavioral-subtleties` scenario using DTU fixture data (prism-dtu-demo-server,
org-a CrowdStrike seed=100 with a synthetic late event). No publicly sourced corpus is used.

| Field | Description |
|-------|-------------|
| corpus_source | prism DTU demo server (seed=100, org-a CrowdStrike with injected late event) |
| corpus_size | 1–2 synthetic events |
| known_edge_cases | Event exactly at watermark boundary (not late); event at watermark - 1 second |
| false_positive_threshold | N/A |
| false_negative_threshold | N/A |

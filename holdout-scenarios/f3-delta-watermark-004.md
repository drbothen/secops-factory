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
id: "HS-059"
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

# Holdout Scenario: Watermark — Monotonicity Never-Regress: Per org×sensor Write Always ≥ Prior Value

## Scenario

This scenario exercises the VP-SKILL-050 **primary monotonicity leg**: a per-org×sensor
watermark write is ALWAYS ≥ the previously persisted value. Specifically, when a
monitoring-loop run produces events whose maximum `_time` is **less than** the existing
stored watermark (a "stale-batch" run), the watermark MUST clamp to the prior value
rather than moving backward.

### Sub-scenario A — Stale-Batch Run: All Events Below Watermark (Clamp-to-Prior)

1. The secops-factory plugin is activated with prism DTU org-b (Claroty + Cyberint
   sensors, seed=150).
2. A watermark file is pre-seeded for org-b × Claroty at timestamp W0 =
   `2026-09-03T10:00:00Z` (a "high-water" value representing the most recently
   processed event from a prior run).
3. The DTU fixture for org-b × Claroty is configured so that ALL available events
   have `_time` values BELOW W0 — for example, three events at
   `2026-09-03T08:00:00Z`, `2026-09-03T08:30:00Z`, and `2026-09-03T09:00:00Z`.
   These events are all "late" relative to the stored watermark and would ordinarily
   have been processed in a prior run.
4. The evaluator invokes the monitoring-loop:
   ```
   /monitoring-loop
   ```
5. The loop processes the three events (late events are NOT silently dropped per
   EC-023 — a `DETECT_LATE_EVENT` AUDIT entry is appended to
   `${CLAUDE_PLUGIN_DATA}/watermarks/audit.log` for each; nothing is written to
   `agent_actions` for late-event detection).
6. After the run, the evaluator reads the watermark file for org-b × Claroty:
   `${CLAUDE_PLUGIN_DATA}/watermarks/org-b/claroty`
7. The watermark file STILL reads `2026-09-03T10:00:00Z` (W0) — it has NOT moved
   backward to any of the late event timestamps (e.g., `2026-09-03T09:00:00Z`).
   The watermark is clamped to the prior value: max(W0, max(events._time)) = W0.

### Sub-scenario B — Normal Advancement: Events Above Watermark (Advance to Max)

1. Using the same org-b × Claroty watermark file, now at W0 = `2026-09-03T10:00:00Z`
   (either from the original seed or from sub-scenario A having preserved it).
2. The DTU fixture for org-b × Claroty is configured with two events whose `_time`
   values are ABOVE W0: `2026-09-03T11:00:00Z` and `2026-09-03T11:30:00Z`.
3. The evaluator invokes the monitoring-loop:
   ```
   /monitoring-loop
   ```
4. After the run, the watermark file reads `2026-09-03T11:30:00Z` — the maximum
   `_time` across the two processed events. This confirms the watermark advances
   to max(W0, max(events._time)) when events are above the prior watermark.
5. The watermark for org-b × Cyberint is NOT modified (per-sensor isolation).

### Sub-scenario C — Mixed-Batch: Events Both Below and Above Watermark (Advance, Not Regress)

1. Watermark file for org-b × Claroty pre-seeded at W0 = `2026-09-03T10:00:00Z`.
2. DTU fixture contains a mixed batch: two events below W0 (`2026-09-03T08:00:00Z`,
   `2026-09-03T09:30:00Z`) and one event above W0 (`2026-09-03T10:45:00Z`).
3. The evaluator invokes the monitoring-loop.
4. After the run, the watermark file reads `2026-09-03T10:45:00Z` — the maximum
   `_time` across ALL processed events (above-and-below-watermark events alike).
5. The watermark does NOT regress to any of the below-watermark event timestamps.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-10.01.001 | VP-SKILL-050 primary leg — per org×sensor watermark write always ≥ previous persisted value | All sub-scenarios: post-run watermark ≥ W0 in every case |
| BC-10.01.001 | Invariant #13 — watermark monotonicity; loop never re-processes a consumed window on restart | Sub-scenario A: stale-batch run does not allow watermark to regress; re-run of sub-scenario B produces zero new verdicts |
| BC-10.01.001 | Invariant #13 — clamp semantics: watermark write = max(existing, max(events._time)) | Sub-scenario A: clamp fires when all events._time < W0; result = W0 |
| BC-10.01.001 | EC-023 — late events below watermark are processed and logged, not dropped | Sub-scenario A: DETECT_LATE_EVENT AUDIT entry in watermarks/audit.log; verdicts emitted for all 3 events despite late classification |
| BC-10.01.001 | R-003 — watermark double-processing or silent drop | Sub-scenario B idempotency: second run with same fixture produces zero new verdicts |

## DTU Setup Requirements

**DTU required: prism-dtu-demo-server + configs/prism-demo.toml**

- Start `prism-dtu-demo-server` from the prism-demo-bundle release asset. Configure
  org-b at seed=150 (Claroty + Cyberint sensors).
- Set `DEMO_FAKE_CLAROTY_TOKEN` and `DEMO_FAKE_CYBERINT_TOKEN` env vars.

**Sub-scenario A setup:**
- Write `2026-09-03T10:00:00Z` to
  `${CLAUDE_PLUGIN_DATA}/watermarks/org-b/claroty`.
- Configure the org-b × Claroty fixture with three events at:
  `2026-09-03T08:00:00Z`, `2026-09-03T08:30:00Z`, `2026-09-03T09:00:00Z`
  (all below W0).

**Sub-scenario B setup (run after A or with fresh watermark seed):**
- Confirm watermark file reads `2026-09-03T10:00:00Z` (W0 unchanged from A).
- Configure the org-b × Claroty fixture with two events at:
  `2026-09-03T11:00:00Z` and `2026-09-03T11:30:00Z` (both above W0).

**Sub-scenario C setup:**
- Write `2026-09-03T10:00:00Z` to the watermark file (fresh seed).
- Configure the org-b × Claroty fixture with three events:
  `2026-09-03T08:00:00Z`, `2026-09-03T09:30:00Z` (below W0), and
  `2026-09-03T10:45:00Z` (above W0).

For all sub-scenarios, the org-b × Cyberint watermark file must NOT exist (or
must remain unmodified) to confirm per-sensor isolation.

## Verification Approach

The evaluator interacts with Claude Code CLI with the plugin and prism DTU active.

### Sub-scenario A verification

**Prompt:**
```
/monitoring-loop
```

**Observe:**
1. Claude's response confirms events were processed for org-b × Claroty.
2. Read `${CLAUDE_PLUGIN_DATA}/watermarks/org-b/claroty` after the run:
   - Content MUST still be `2026-09-03T10:00:00Z` (W0 unchanged).
   - Content MUST NOT be `2026-09-03T09:00:00Z` or any earlier timestamp.
3. Read `${CLAUDE_PLUGIN_DATA}/watermarks/audit.log` for `DETECT_LATE_EVENT` entries
   — at least one entry should appear confirming the events were classified as late
   (event._time < stored watermark). Do NOT look in `verdict.agent_actions`; that
   field does not receive DETECT_LATE_EVENT entries (EC-023).
4. Confirm verdicts were emitted for the three events (late events were processed,
   not silently dropped).

### Sub-scenario B verification

**Prompt:**
```
/monitoring-loop
```

**Observe:**
1. Read `${CLAUDE_PLUGIN_DATA}/watermarks/org-b/claroty` after the run:
   - Content MUST be `2026-09-03T11:30:00Z` (the maximum `_time` of the two events).
2. Run the loop a second time with identical fixture data: zero new verdicts must be
   produced (idempotency / R-003 no double-processing).
3. Confirm `${CLAUDE_PLUGIN_DATA}/watermarks/org-b/cyberint` was NOT
   created or modified (per-sensor isolation).

### Sub-scenario C verification

**Prompt:**
```
/monitoring-loop
```

**Observe:**
1. Read `${CLAUDE_PLUGIN_DATA}/watermarks/org-b/claroty` after the run:
   - Content MUST be `2026-09-03T10:45:00Z` (the maximum across ALL processed
     events, including the below-watermark ones).
   - Content MUST NOT be `2026-09-03T09:30:00Z` or any below-W0 timestamp.
2. `DETECT_LATE_EVENT` AUDIT entries appear in `${CLAUDE_PLUGIN_DATA}/watermarks/audit.log`
   for the two below-W0 events; no such entry for the above-W0 event.

The evaluator must NOT inspect hook source code or watermark-update internal logic.
Only observable outputs (skill response, verdict JSON fields, watermark file content,
audit.log entries) are in scope.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Did sub-scenario A leave the watermark at W0 (no regression)? Did sub-scenario B advance the watermark to `2026-09-03T11:30:00Z`? Did sub-scenario C advance to `2026-09-03T10:45:00Z` (not regress to a below-W0 timestamp)? (1.0 = all three correct; 0.5 = advancement works but clamp fails; 0.0 = any regression in any sub-scenario)
- **Edge case handling** (weight: 0.1): Did sub-scenario B's idempotency check produce zero verdicts on the second run? Was per-sensor isolation confirmed (Cyberint watermark unchanged)?
- **Error quality** (weight: 0.3): Are `DETECT_LATE_EVENT` AUDIT entries present in `${CLAUDE_PLUGIN_DATA}/watermarks/audit.log` for the below-watermark events in sub-scenarios A and C? Do the entries identify the event time, stored watermark, and time delta?
- **Performance** (weight: 0.05): All three sub-scenarios complete within a reasonable time (< 5 minutes each).
- **Data integrity** (weight: 0.05): Watermark file contains a valid RFC3339 timestamp after each sub-scenario run; no partial write or corruption.

## Edge Conditions

- If all events in sub-scenario A share the same `_time` (e.g., all three at
  `2026-09-03T09:00:00Z`), the watermark must still NOT regress to that timestamp —
  it must remain at W0 (clamp is unconditional on all-below-watermark batches).
- A first-run with NO watermark file (absent): the 24h lookback fires (no clamp
  needed since there is no prior value); watermark is written to the maximum `_time`
  of events processed. This is covered by other scenarios (HS-035, HS-045); the
  present scenario requires a pre-existing W0.
- If the org-b × Claroty fixture returns zero events above the 24h lookback (empty
  response): no watermark update should occur (no write when there are no events to
  establish a high-water mark from scratch; but if W0 already exists, it must not
  be deleted or regressed).

## Failure Guidance

"HOLDOUT CRITICAL: HS-059 (satisfaction: 0.0) — Sub-scenario A: the watermark
regressed from `2026-09-03T10:00:00Z` to a lower value (e.g., `2026-09-03T09:00:00Z`)
after a stale-batch run. This violates the VP-SKILL-050 monotonicity invariant:
the watermark write MUST use clamp semantics (max(existing, max(events._time))) and
MUST NEVER move backward. A backward watermark causes the loop to re-process
previously consumed events on the next run, violating the no-double-processing
guarantee (R-003)."

## Category: behavioral-subtleties

N/A — This is a `behavioral-subtleties` scenario using DTU fixture data
(prism-dtu-demo-server, org-b Claroty seed=150 with injected watermark states).
No publicly sourced corpus is used. The scenario tests the watermark clamp invariant
by injecting controlled event batches relative to a pre-seeded high-water mark.

| Field | Description |
|-------|-------------|
| corpus_source | prism DTU demo server (seed=150, org-b Claroty with injected watermark W0 and controlled event batches) |
| corpus_size | Sub-A: 3 below-watermark events; Sub-B: 2 above-watermark events; Sub-C: 2 below + 1 above |
| known_edge_cases | All events same _time below W0 (unconditional clamp); absent watermark file (24h lookback, no clamp needed); zero events returned (no write) |
| false_positive_threshold | N/A |
| false_negative_threshold | N/A |

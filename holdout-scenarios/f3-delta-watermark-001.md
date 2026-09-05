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
id: "HS-045"
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

# Holdout Scenario: Monitoring-Loop Watermark Validation — Once-Per-Run Cardinality (Multi-Alert Run)

## Scenario

1. The secops-factory plugin is activated in a Claude Code project with prism DTU org-b
   configured (Claroty + Cyberint sensors, seed=150).
2. A valid watermark file exists for the org-b × Claroty sensor pair, containing a
   valid RFC3339 UTC timestamp approximately 2 hours before the DTU fixture's newest
   event times (e.g., `2026-09-03T08:00:00Z`).
3. The DTU fixture for org-b × Claroty contains exactly 5 security events whose
   `_time` values are all newer than the stored watermark (e.g., between
   `2026-09-03T09:00:00Z` and `2026-09-03T09:30:00Z`).
4. The evaluator invokes the monitoring-loop for org-b via the Claude Code CLI:
   > "/monitoring-loop"
5. The loop processes all 5 events and produces a verdict for each.
6. After the run completes, the evaluator reads the watermark file for org-b × Claroty.
7. The watermark file contains the RFC3339 timestamp of the newest processed event
   (the maximum `_time` across all 5 alerts) — confirming monotonic advancement.
8. The evaluator invokes the monitoring-loop a second time with no change to the
   fixture data.
9. The second run produces zero new verdicts — no events remain above the updated
   watermark.
10. Inspecting the audit output across all 5 first-run verdicts reveals that watermark
    validation produced exactly ONE entry per (org, sensor) pair for the entire run,
    not five.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-10.01.001 | Invariant #13 — watermark monotonicity; once-per-(org,sensor) per run | Steps 5–7: watermark advances to max _time after processing 5 events |
| BC-10.01.001 | VP-SKILL-073 once-per-run cardinality on valid-watermark path: VALIDATE_WATERMARK_FOR_RUN called once per (org,sensor) per run | Steps 5 and 10: no repeated watermark-validation entries in audit output for the same (org-b, Claroty) pair across all 5 events |
| BC-10.01.001 | VP-SKILL-073 addendum: valid-watermark path produces NO DETECT_LATE_EVENT_SUPPRESSED entries (suppression absent = watermark valid) | Step 5: 5 alerts processed; no suppression entry emitted — valid-watermark path does not exercise the suppression logic that SM-82/SM-83 mutants target |
| BC-10.01.001 | Invariant #13 — 24h lookback not triggered when valid watermark exists | Step 2: pre-existing valid watermark → 24h fallback must NOT be taken |

## DTU Setup Requirements

**DTU required: prism-dtu-demo-server + configs/prism-demo.toml**

- Start `prism-dtu-demo-server` from the prism-demo-bundle release asset. Configure
  org-b at seed=150 (Claroty + Cyberint sensors).
- Set `DEMO_FAKE_CLAROTY_TOKEN` and `DEMO_FAKE_CYBERINT_TOKEN` env vars.
- Seed the watermark file at `${CLAUDE_PLUGIN_DATA}/watermarks/org-b/claroty`
  with a valid RFC3339 UTC timestamp (e.g., `2026-09-03T08:00:00Z`).
- Ensure the DTU fixture for org-b × Claroty contains exactly 5 events with `_time`
  values between `2026-09-03T09:00:00Z` and `2026-09-03T09:30:00Z` (all above the
  seeded watermark).

## Verification Approach

The evaluator interacts with Claude Code CLI with the plugin and prism DTU active.

**Run 1:**
```
/monitoring-loop
```
Observe:
- Claude's response confirms 5 alerts were processed for org-b.
- After the run, read `${CLAUDE_PLUGIN_DATA}/watermarks/org-b/claroty` — its
  content must be the RFC3339 timestamp of the most recent event across all 5 alerts.
- Inspect `verdict.agent_actions` (ICD-203 field 10) across the 5 verdicts. There
  should be NO evidence of repeated watermark validation entries (one per alert) for
  the same (org-b, Claroty) pair in a single run.

**Run 2 (idempotency check):**
```
/monitoring-loop
```
Observe:
- Zero new verdicts emitted.
- Claude's output indicates no new alerts found for org-b × Claroty.

The evaluator must NOT inspect hook source code or internal implementation. Only
observable outputs (skill response, verdict JSON fields, watermark file content) are
in scope.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Did the watermark advance to the maximum event `_time` after 5 alerts? (1.0 = correct max watermark written; 0.5 = advanced but not to max; 0.0 = unchanged or regressed)
- **Edge case handling** (weight: 0.1): Did Run 2 produce zero verdicts, confirming the watermark gates future re-processing?
- **Error quality** (weight: 0.3): Is there evidence of per-alert (rather than per-run) watermark validation entries in the audit output? Absence of repeated entries = pass (1.0).
- **Performance** (weight: 0.05): Run completes within a reasonable time (< 5 minutes for 5 alerts).
- **Data integrity** (weight: 0.05): Watermark file contains a valid RFC3339 timestamp after the run; no partial write.

## Edge Conditions

- If all 5 events share the same `_time`, the watermark advances to that timestamp (idempotent advancement).
- The Claroty watermark advancement for org-b must not affect org-b × Cyberint's watermark file (per-sensor isolation).
- The 24h-lookback branch must NOT be taken during Run 1 because a valid watermark already exists.

## Failure Guidance

"HOLDOUT CRITICAL: HS-045 (satisfaction: 0.XX) — The watermark did not advance to the maximum event _time after processing 5 alerts, OR repeated watermark-validation entries were found in the audit output for the same (org-b, Claroty) pair in a single run, OR a DETECT_LATE_EVENT_SUPPRESSED entry appeared despite the watermark being valid, OR Run 2 produced non-zero verdicts (idempotency failed). The once-per-run cardinality guard on the valid-watermark path or the watermark-advance logic is absent or defective. NOTE: SM-82/SM-83 kill requires a corrupt/invalid-watermark multi-event run (see HS-047); a valid-watermark run cannot distinguish correct behavior from the SM-82/SM-83 mutants."

## Category: real-world-corpus

N/A — This is a `behavioral-subtleties` scenario validated against DTU fixture data
(prism-dtu-demo-server, org-b Claroty seed=150). No publicly sourced corpus is used.

| Field | Description |
|-------|-------------|
| corpus_source | prism DTU demo server (seed=150, org-b Claroty fixtures) |
| corpus_size | 5 synthetic events |
| known_edge_cases | All events same _time (idempotent advancement) |
| false_positive_threshold | N/A |
| false_negative_threshold | N/A |

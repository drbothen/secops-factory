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
id: "HS-047"
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

# Holdout Scenario: Invalid/Future-Dated Watermark — Single DETECT_LATE_EVENT_SUPPRESSED Entry; Loop Continues

## Scenario

1. The secops-factory plugin is activated with prism DTU org-a (CrowdStrike + Armis,
   seed=100).
2. The watermark file for org-a × CrowdStrike contains a future-dated RFC3339 timestamp
   (e.g., `2099-01-01T00:00:00Z`) — simulating a corrupt or tampered watermark.
3. The DTU fixture for org-a × CrowdStrike contains 3 events within the last 24 hours
   (the fallback window used when the stored watermark is invalid/future-dated).
4. The evaluator invokes the monitoring-loop:
   > "/monitoring-loop"
5. The monitoring-loop does NOT abort. It continues processing the 3 events using
   the 24h lookback as a fallback.
6. The run-level audit log (or skill output) contains EXACTLY ONE
   `DETECT_LATE_EVENT_SUPPRESSED` entry for org-a × CrowdStrike — not three
   (not one per alert).
7. The `DETECT_LATE_EVENT_SUPPRESSED` entry notes the reason as `WATERMARK_FUTURE`
   (or equivalent language indicating a future-dated watermark was detected).
8. All 3 events produce verdicts normally.
9. After the run, the watermark file still contains the future-dated timestamp
   `2099-01-01T00:00:00Z` — it is NOT overwritten with a past timestamp (monotonic-
   write guard: a future-dated watermark is not replaced by a past value).

Also test sub-scenario B: replace the future-dated timestamp with an invalid
RFC3339 format (e.g., `"not-a-date"`). The behavior must be identical: exactly one
`DETECT_LATE_EVENT_SUPPRESSED` entry (reason: `WATERMARK_INVALID`), loop continues,
file unchanged.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-10.01.001 | EC-024 — DETECT_LATE_EVENT_SUPPRESSED for invalid/future watermark; exactly one per run | Step 6: exactly ONE entry in audit, not one per alert |
| BC-10.01.001 | Invariant #14 — invalid/future watermark → late_event_enabled=false; no per-event detection | Step 6: per-event DETECT_LATE_EVENT is NO-OP when watermark is invalid |
| BC-10.01.001 | Invariant #13 — monotonic-write guard: future watermark not overwritten with past value | Step 9: watermark file unchanged after run |
| BC-10.01.001 | Invariant #13 — 24h lookback fallback when watermark absent or invalid | Steps 3–5: 3 events within 24h are fetched and processed |
| BC-10.01.001 | SM-82 kill — VALIDATE_WATERMARK_FOR_RUN moved back inside the per-event loop (per-event validation → N DETECT_LATE_EVENT_SUPPRESSED entries for N events): corrupt/3-event run must yield `grep -c DETECT_LATE_EVENT_SUPPRESSED == 1` (not 3) | Step 6: exactly ONE DETECT_LATE_EVENT_SUPPRESSED entry across 3 events kills the per-event-validation mutant |
| BC-10.01.001 | SM-83 kill — DETECT_LATE_EVENT() retains inline watermark validation with late_event_enabled guard removed (per-event suppression flood): corrupt/3-event run must yield `grep -c DETECT_LATE_EVENT_SUPPRESSED == 1` (not 3) | Step 6: exactly ONE suppression entry across 3 events kills the per-event-flood mutant |

## DTU Setup Requirements

**DTU required: prism-dtu-demo-server + configs/prism-demo.toml**

- Start `prism-dtu-demo-server` from the prism-demo-bundle release asset. Configure
  org-a at seed=100.
- Set `DEMO_FAKE_CROWDSTRIKE_TOKEN` and `DEMO_FAKE_ARMIS_TOKEN` env vars.
- Write `2099-01-01T00:00:00Z` (a future-dated RFC3339 timestamp) to
  `${CLAUDE_PLUGIN_DATA}/watermarks/org-a/crowdstrike`.
- Ensure the DTU fixture for org-a × CrowdStrike contains exactly 3 events within
  the last 24 hours relative to the evaluation time (so the 24h fallback retrieves them).

**Sub-scenario B setup:** Replace the watermark content with `not-a-date` (invalid
RFC3339 format) and re-run. Behavior should be identical with reason `WATERMARK_INVALID`.

## Verification Approach

The evaluator interacts with Claude Code CLI with the plugin and prism DTU active.

**Prompt:**
```
/monitoring-loop
```

**Observe:**
1. Claude's response confirms 3 alerts were processed for org-a × CrowdStrike.
2. Inspect the run audit log or skill output for `DETECT_LATE_EVENT_SUPPRESSED` entries:
   - Exactly ONE such entry must appear for org-a × CrowdStrike.
   - The entry must specify reason `WATERMARK_FUTURE` (or equivalent).
   - There must NOT be three entries (one per alert).
   - Explicit cardinality assertion (SM-82/SM-83 kill): `grep -c DETECT_LATE_EVENT_SUPPRESSED <audit-log> == 1`
     A count > 1 (e.g., 3 for 3 events) indicates SM-82 (per-event VALIDATE_WATERMARK_FOR_RUN) or SM-83
     (per-event suppression flood with guard removed) has survived — both killed only when this count is exactly 1.
3. Confirm 3 verdicts are emitted (loop continues; did not abort).
4. Read `${CLAUDE_PLUGIN_DATA}/watermarks/org-a/crowdstrike` after the run:
   - The content must still be `2099-01-01T00:00:00Z` (not overwritten with a past
     timestamp — monotonic-write guard in effect).

**Sub-scenario B:** Replace watermark with `not-a-date` and repeat. Expect:
- Exactly ONE `DETECT_LATE_EVENT_SUPPRESSED` entry, reason `WATERMARK_INVALID`.
- Watermark file still contains `not-a-date` after the run (not overwritten).

The evaluator must NOT inspect hook source code. Only observable outputs are in scope.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Exactly ONE `DETECT_LATE_EVENT_SUPPRESSED` entry per (org, sensor) per run? (1.0 = exactly one; 0.5 = entry present but wrong count; 0.0 = absent or loop aborted)
- **Edge case handling** (weight: 0.1): Did the loop continue processing 3 events despite the invalid watermark?
- **Error quality** (weight: 0.3): Does the `DETECT_LATE_EVENT_SUPPRESSED` entry include the reason (`WATERMARK_FUTURE` or `WATERMARK_INVALID`) for operator diagnosis?
- **Performance** (weight: 0.05): Run completes within a reasonable time.
- **Data integrity** (weight: 0.05): Watermark file is NOT overwritten with a past value after the run.

## Edge Conditions

- A first-run with NO watermark file (absent, not corrupt) must NOT produce a
  `DETECT_LATE_EVENT_SUPPRESSED` entry — the absent-watermark path uses the 24h
  lookback silently without suppression logging (EC-023 first-run early-return).
- If both Claroty (invalid watermark) and CrowdStrike (valid watermark) are in scope
  for the same run, only Claroty produces a suppression entry; CrowdStrike produces
  none (suppression is per-sensor, not global).

## Failure Guidance

"HOLDOUT CRITICAL: HS-047 (satisfaction: 0.XX) — The monitoring-loop either produced DETECT_LATE_EVENT_SUPPRESSED once per alert (N=3 entries instead of 1) or aborted on the invalid watermark. The once-per-run cardinality guard for watermark suppression is absent or the loop does not continue after detecting an invalid watermark."

## Category: real-world-corpus

N/A — This is an `edge-case-combinations` scenario using a synthetic future-dated watermark
fixture against the prism DTU demo server (org-a CrowdStrike seed=100).

| Field | Description |
|-------|-------------|
| corpus_source | prism DTU demo server (seed=100, org-a CrowdStrike with injected future-dated watermark) |
| corpus_size | 3 synthetic events |
| known_edge_cases | Absent watermark (no file) vs. invalid watermark (corrupt); sub-scenario B with non-RFC3339 format |
| false_positive_threshold | N/A |
| false_negative_threshold | N/A |

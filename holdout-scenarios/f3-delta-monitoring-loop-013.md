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
id: "HS-062"
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

# Holdout Scenario: Monitoring-Loop — Advisory Lock: Concurrent Instance Exits 0 (EC-004); Stale Lock (>60 min) Reclaimed and Proceeds (EC-005)

## Scenario

This scenario guards R-003 (watermark double-processing) on the concurrency vector:
overlapping cron invocations for the same plugin instance. Two legs are exercised.

### Leg A — Concurrent Invocation (EC-004): Second Instance Exits 0, No Double-Write

1. The secops-factory plugin is activated with prism DTU org-b (Claroty + Cyberint
   sensors, seed=150).
2. The evaluator pre-creates the advisory lock directory in the plugin state directory:
   ```
   mkdir "${CLAUDE_PLUGIN_DATA}/watermarks/.monitoring-loop.lock"
   ```
   This simulates a first monitoring-loop run already holding the advisory lock (as a directory).
3. The evaluator invokes a second monitoring-loop run via the Claude Code CLI:
   ```
   claude -p "/monitoring-loop" \
     --strict-mcp-config \
     --mcp-config "${TEST_PRISM_MCP_CONFIG}" \
     --allowedTools "mcp__prism__*,mcp__tavily__tavily_search,mcp__tavily__tavily_extract,mcp__perplexity__perplexity_ask,mcp__perplexity__perplexity_search,Bash,Write,Read,Edit" \
     --output-format json \
     < /dev/null
   ```
4. The second instance detects the lockfile, logs a message to stderr indicating
   another instance is already running (e.g., "monitoring-loop: another instance is
   running; exiting"), and exits 0 (not an error — the operator cron scheduler must
   NOT be alerted when a duplicate run is skipped).
5. The second instance takes NO watermark-update action (the watermark file is
   unchanged), issues NO `jr issue` calls, and writes NO verdict artifacts.
6. The lockfile still exists after the second instance exits (the first instance
   retains ownership).

### Leg B — Stale Advisory Lock (EC-005): Lock Older Than 60 Minutes Reclaimed

1. The evaluator pre-creates a stale advisory lock directory:
   ```
   mkdir "${CLAUDE_PLUGIN_DATA}/watermarks/.monitoring-loop.lock"
   touch -t "$(date -v-90M +%Y%m%d%H%M.%S)" \
     "${CLAUDE_PLUGIN_DATA}/watermarks/.monitoring-loop.lock"
   ```
   (On Linux: `mkdir "${CLAUDE_PLUGIN_DATA}/watermarks/.monitoring-loop.lock" && touch -d "90 minutes ago" "${CLAUDE_PLUGIN_DATA}/watermarks/.monitoring-loop.lock"`)
   The lock directory mtime is 90 minutes in the past, well beyond the 60-minute stale
   threshold defined in EC-005. This simulates a prior run that crashed without
   cleaning up its lock.
2. The evaluator invokes the monitoring-loop:
   ```
   claude -p "/monitoring-loop" \
     --strict-mcp-config \
     --mcp-config "${TEST_PRISM_MCP_CONFIG}" \
     --allowedTools "mcp__prism__*,mcp__tavily__tavily_search,mcp__tavily__tavily_extract,mcp__perplexity__perplexity_ask,mcp__perplexity__perplexity_search,Bash,Write,Read,Edit" \
     --output-format json \
     < /dev/null
   ```
3. The loop detects the stale lock (mtime > 60 minutes ago), removes the stale
   lock directory, acquires a fresh lock directory, emits `WATERMARK_STALE_LOCK` to
   **stderr** (per architecture-delta ~L763: `echo "WATERMARK_STALE_LOCK: removing stale lock" >&2`),
   and proceeds with normal alert processing.
4. After the run, the advisory lock directory exists with a recent mtime (the loop
   re-created it during acquisition). The loop exits 0.
5. The jr mock records any Jira actions that occur from normal processing (these are
   expected; the test is that the loop proceeds rather than aborting).

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-10.01.001 | EC-004: concurrent loop invocation — advisory lockfile already present; second instance logs and exits 0; first instance continues unaffected | Leg A: pre-created lockfile → second run exits 0 with no watermark write or jr calls |
| BC-10.01.001 | EC-005: stale advisory lockfile (mtime > 60 minutes) — remove stale lock; acquire fresh lock; proceed; log WATERMARK_STALE_LOCK | Leg B: 90-minute-old lockfile → reclaim, log, proceed normally |
| BC-10.01.001 | R-003 watermark double-processing guard — concurrent overlap must not result in two loop runs both writing watermarks or both issuing Jira create/comment for the same alert | Leg A: no watermark write by the blocked second instance; no duplicate jr calls |
| BC-10.01.001 | Cron wrapper postcondition (Invariant): second instance exit 0 on advisory lock block is not a cron failure; operator is not alerted for a normal overlap skip | Leg A: exit code 0 (not exit 1); cron scheduler does not escalate |

## DTU Setup Requirements

**DTU required: prism-dtu-demo-server + jr L2 stateful mock**

- Start `prism-dtu-demo-server` with org-b fixture (seed=150): Claroty xDome and
  Cyberint sensors active. Set `DEMO_FAKE_CLAROTY_TOKEN` and
  `DEMO_FAKE_CYBERINT_TOKEN` env vars.
- **jr L2 stateful mock**: Use a baseline scenario (e.g., `MOCK_JR_SCENARIO=default`
  with empty issue registry). The mock records all `jr` calls to `$MOCK_JR_CALL_LOG`.
- **Lock directory**: Ensure `${CLAUDE_PLUGIN_DATA}/watermarks/` exists before the test.
  Create the advisory lock DIRECTORY with the appropriate mtime for each leg.
- **Leg A lock path**: `${CLAUDE_PLUGIN_DATA}/watermarks/.monitoring-loop.lock` — created
  with `mkdir` (simulates an in-progress run holding the lock).
- **Leg B lock path**: same path — directory created with `mkdir` then mtime set 90 minutes
  in the past via `touch -t` (macOS) or `touch -d` (Linux) on the directory.
- **Watermark state**: A pre-existing watermark file for org-b × Claroty at
  `${CLAUDE_PLUGIN_DATA}/watermarks/org-b/claroty` with a known reference
  value (e.g., `2026-09-03T10:00:00Z`). Used in Leg A to confirm the second instance
  does NOT overwrite it.

## Verification Approach

The holdout evaluator observes only **black-box outputs** for each leg.

### Leg A Verification

**Setup:**
```
mkdir "${CLAUDE_PLUGIN_DATA}/watermarks/.monitoring-loop.lock"
echo "2026-09-03T10:00:00Z" > "${CLAUDE_PLUGIN_DATA}/watermarks/org-b/claroty"
```

**Invoke** the second monitoring-loop instance (command above).

**Observe:**
1. **Process exit code**: Assert exit code `0`. A non-zero exit code means the loop
   incorrectly treated the advisory lock block as an error.
2. **stderr output**: Assert the output contains a message indicating the loop
   detected an existing lock and exited without processing (e.g., "another instance
   is running", "lock held by another process", or similar). The exact phrasing is
   not normative — any human-readable lock-detection message is acceptable.
3. **Watermark file unchanged**: Read
   `${CLAUDE_PLUGIN_DATA}/watermarks/org-b/claroty`.
   Assert content is still `2026-09-03T10:00:00Z` (the second instance did NOT
   update the watermark).
4. **jr mock call log empty**: Assert `$MOCK_JR_CALL_LOG` contains no `jr issue`
   calls attributed to the second invocation. No Jira create, comment, move, or
   transition calls should have been issued by the blocked instance.
5. **Lock directory still present**: Assert
   `${CLAUDE_PLUGIN_DATA}/watermarks/.monitoring-loop.lock` still exists as a directory (the second
   instance did not delete or modify it).

### Leg B Verification

**Setup:**
```
# Create stale lock directory (90 minutes old)
mkdir "${CLAUDE_PLUGIN_DATA}/watermarks/.monitoring-loop.lock"
touch -t "$(date -v-90M +%Y%m%d%H%M.%S)" \
  "${CLAUDE_PLUGIN_DATA}/watermarks/.monitoring-loop.lock"
# Linux: mkdir "${CLAUDE_PLUGIN_DATA}/watermarks/.monitoring-loop.lock" && touch -d "90 minutes ago" "${CLAUDE_PLUGIN_DATA}/watermarks/.monitoring-loop.lock"
```

**Invoke** the monitoring-loop (command above).

**Observe:**
1. **Process exit code**: Assert exit code `0`. The stale-lock reclaim must not
   cause a failure exit.
2. **stderr contains WATERMARK_STALE_LOCK**: Assert the captured stderr of the
   monitoring-loop invocation contains `WATERMARK_STALE_LOCK` (case-insensitive).
   This confirms the loop emitted the stale-lock notice to stderr per EC-005
   (architecture-delta ~L763: `echo "WATERMARK_STALE_LOCK: removing stale lock" >&2`).
   Do NOT grep `markers/audit.log` for this token — that log only holds the 5
   hook-enforcement codes read by cron Gate 2; WATERMARK_STALE_LOCK is not in that
   set and will never appear there on a spec-faithful build.
3. **Lock directory mtime is recent**: After the run, assert
   `${CLAUDE_PLUGIN_DATA}/watermarks/.monitoring-loop.lock` exists as a directory AND its mtime is
   within the last 5 minutes (the loop re-created it after reclaiming).
4. **Loop processed normally**: The loop completed its standard alert-scan pipeline
   (the jr mock call log should reflect normal Jira actions, if any alerts triggered
   them). The stale-lock reclaim is a preamble step; it must not abort the run.

The evaluator MUST NOT inspect hook source code, the monitoring-loop skill internals,
or any function-level lock acquisition logic. Only the above observable outputs are
in scope.

## Evaluation Rubric

- **Functional correctness — Leg A** (weight: 0.40): Did the second instance exit 0?
  Was the watermark file unchanged? Was the jr call log empty for the second
  invocation? (1.0 = all three; 0.5 = exit 0 but watermark was modified; 0.0 = exit
  non-zero or jr calls issued by the second instance)
- **Functional correctness — Leg B** (weight: 0.40): Did the loop exit 0 after
  reclaiming the stale lock? Does captured **stderr** contain `WATERMARK_STALE_LOCK`?
  Was the lockfile mtime updated to recent? (1.0 = all three; 0.5 = loop proceeds but
  WATERMARK_STALE_LOCK absent from stderr; 0.0 = loop exits non-zero or does not reclaim)
- **Error quality — Leg A** (weight: 0.10): Does stderr contain a human-readable
  lock-detection message? Is the message clear enough for an operator to understand
  the overlap was intentionally skipped?
- **Data integrity** (weight: 0.10): In Leg A, no verdicts were written; no audit.log
  entries from the blocked instance appear (other than the lock-detection message).

## Edge Conditions

- **Lock file exists but is exactly 60 minutes old** (boundary condition): the EC-005
  threshold is "older than 60 minutes"; a lock exactly at 60 minutes is NOT stale
  and the second instance should exit 0 without reclaiming. (Test the open interval:
  stale = mtime < now() - 60min.)
- **Lock file does not exist** (no contention): the loop acquires the lock and
  proceeds normally. This is the standard non-concurrent case covered by other
  scenarios; it is not re-tested here.
- **Leg A with `autonomy_enabled=false`**: the exit-0 behavior on advisory lock block
  must not be affected by the autonomy setting. The lock check precedes all alert
  processing.
- **Lock does not exist** (`${CLAUDE_PLUGIN_DATA}/watermarks/.monitoring-loop.lock` does not exist): the loop
  must create the lock directory via `mkdir` and proceed — a missing lock directory must not prevent
  the loop from acquiring a lock on first run.

## Failure Guidance

**Leg A failure:**
"HOLDOUT CRITICAL: HS-062-A (satisfaction: 0.0) — The second monitoring-loop
instance either (a) exited non-zero instead of 0, causing a spurious cron failure
alert, or (b) issued a `jr issue` call or watermark write despite the advisory lock
being held by a first instance. This violates EC-004: the second instance MUST detect
the lock, log a skip message, and exit 0 without processing. The advisory lock
concurrency guard (R-003 double-processing prevention) has failed."

**Leg B failure:**
"HOLDOUT CRITICAL: HS-062-B (satisfaction: 0.0) — The monitoring-loop either
(a) failed to reclaim the stale advisory lock (mtime 90 min old) and exited
non-zero, or (b) reclaimed the lock but did not emit WATERMARK_STALE_LOCK to
**stderr** (architecture-delta ~L763), or (c) the lockfile mtime was not updated
after reclaim. EC-005 requires: detect stale lock (>60 min) → remove → acquire →
emit WATERMARK_STALE_LOCK to stderr → proceed. A loop that aborts on stale lock
causes a self-inflicted outage on crash recovery."

## Category: real-world-corpus

This scenario probes the concurrency boundary of the cron wrapper (S-10.02): two
overlapping monitoring-loop invocations for the same plugin instance. The advisory
lock mechanism prevents double-processing (R-003). The stale-lock reclaim leg
ensures the lock never becomes a permanent blocker after a crash.

| Field | Value |
|-------|-------|
| corpus_source | prism-dtu-demo-server org-b (seed=150) + synthetically injected lockfile states |
| corpus_size | Leg A: 1 pre-created lock + pre-seeded watermark; Leg B: 1 stale lock (90 min old) |
| known_edge_cases | Lock exactly 60 min old (boundary, not stale); autonomy_enabled=false must not affect exit behavior; absent lock directory |
| false_positive_threshold | 0% — any exit non-zero on advisory lock block is a false cron failure |
| false_negative_threshold | 0% — any watermark write or jr call from the blocked Leg A instance is a double-processing violation |

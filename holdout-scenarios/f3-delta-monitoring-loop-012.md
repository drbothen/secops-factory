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
id: "HS-061"
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
risk_source: "R-006"
dtu_required: true
wave_tag: f3-w4
---

# Holdout Scenario: Monitoring-Loop — BLIND-SPOT One-Open-Per-Org-Sensor Dedup: Pre-Seeded Open Ticket Routes to comment-review (No Duplicate Create)

## Scenario

This scenario verifies D-DEC-004's one-open-per-org-sensor dedup rule: when an open
BLIND-SPOT ticket already exists for an (org_slug, sensor_id) pair, a subsequent
sensor-silence detection for the same pair MUST append to the existing ticket via
`comment-review` and MUST NOT `jr issue create` a second ticket (which would
constitute Jira spam — R-006).

1. The prism DTU stack (`prism-dtu-demo-server`) is running with the org-b fixture
   (seed=150). The Claroty xDome sensor for org-b has `last_seen` set to 36 hours ago
   (sensor still silent, well beyond the 24h threshold).
2. The jr mock is configured with the **`blind-spot-open`** scenario. The issue registry
   contains an existing open BLIND-SPOT ticket:
   - Key: `PRISMDEMO-85`
   - Status: `Open`
   - Labels: `[BLIND-SPOT, PRISM-AUTO]`
   - Summary: `"[BLIND-SPOT] Sensor silence: org-b/claroty-xdome-sensor"`
   This ticket was created during a prior monitoring-loop run when the sensor first went
   silent. The current run is a subsequent execution while silence continues.
3. No new watermark exists beyond the previously stored one for org-b × Claroty
   (the silence has persisted across runs).
4. The evaluator invokes the monitoring-loop via the Claude Code CLI:
   ```
   claude -p "/monitoring-loop" \
     --strict-mcp-config \
     --mcp-config "${TEST_PRISM_MCP_CONFIG}" \
     --allowedTools "mcp__prism__*,mcp__tavily__tavily_search,mcp__perplexity__perplexity_ask,Bash,Write,Read,Edit" \
     --output-format json \
     < /dev/null
   ```
5. Stage 0 checks prism sensor health for org-b; the Claroty sensor reports
   `last_seen` > 24h → `sensor_health_status=silent`. A BLIND-SPOT verdict is raised.
6. The §3.4 dedup JQL query runs via `jr issue list --jql` and finds the existing
   open ticket PRISMDEMO-85 (status=Open, label=BLIND-SPOT, matching org-b/claroty).
7. Because PRISMDEMO-85 is open, the loop sets `verdict.ticket_action_type = "comment-review"`
   (D-DEC-004 dedup rule: open ticket exists → append, NOT create).
8. The jr mock records a comment-class action targeting **PRISMDEMO-85** in the call log
   (e.g., `jr issue add-comment PRISMDEMO-85 "..."` or equivalent comment subcommand).
   The comment includes the new silence observation timestamp and the consecutive silence
   count.
9. No `jr issue create` call appears in the call log — the loop does NOT create a
   second BLIND-SPOT ticket for the same org-b × Claroty pair.
10. The loop exits cleanly; no `HARD-FLOOR-LIVELOCK-ABORT` or `SEVERITY-MISMATCH`
    entries appear in `audit.log`.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-10.01.001 | EC-006: sensor-silence BLIND-SPOT verdict; `ticket_action_type="comment-review"` when open ticket already exists (D-DEC-004 dedup) — NOT "create-review" for an already-open ticket | Steps 6–8: dedup query finds PRISMDEMO-85; `comment-review` path taken |
| BC-10.01.001 | Invariant #8 (D-DEC-004): at most one open BLIND-SPOT ticket per (org_slug, sensor_id) pair; dedup JQL runs before any create decision | Steps 6–9: dedup fires before verdict write; no second ticket created |
| BC-10.01.001 | D-DEC-004 dedup algorithm: `IF dedup_query >= 1 open ticket → APPEND comment; do NOT create new ticket` | Steps 7–9: comment action on PRISMDEMO-85; absence of `jr issue create` |
| BC-10.01.001 | Invariant #14 Stage-8: comment-review verdict routes to `jr issue add-comment` (or equivalent) on the existing ticket key | Step 8: jr mock call targets PRISMDEMO-85, not a new key |
| BC-10.01.001 | VP-SKILL-068: in-grace re-fetched event with existing open BLIND-SPOT ticket → COMMENT not new ticket | Steps 6–9 directly exercise the VP-SKILL-068 assertion (dedup JQL via `jr issue list --jql` finds open ticket → comment action) |

## DTU Setup Requirements

**DTU required: prism-dtu-demo-server + jr L2 stateful mock**

- Start `prism-dtu-demo-server` with org-b fixture (seed=150): Claroty xDome sensor
  for org-b has `last_seen` = 36h ago (sensor-silence state triggers BLIND-SPOT).
  Set `DEMO_FAKE_CLAROTY_TOKEN` and `DEMO_FAKE_CYBERINT_TOKEN` env vars.
- **jr L2 stateful mock**: `MOCK_JR_SCENARIO=blind-spot-open` — issue registry contains:
  ```json
  {
    "key": "PRISMDEMO-85",
    "status": "Open",
    "labels": ["BLIND-SPOT", "PRISM-AUTO"],
    "summary": "[BLIND-SPOT] Sensor silence: org-b/claroty-xdome-sensor"
  }
  ```
  The mock's JQL endpoint (`jr issue list --jql "... status not in (Closed,...) AND
  summary ~ \"BLIND-SPOT org-b/claroty\""`) returns PRISMDEMO-85 in the result.
  The mock records all calls to `$MOCK_JR_CALL_LOG`.
- **Watermark state**: a prior watermark file exists for org-b × Claroty at
  `${CLAUDE_PLUGIN_DATA}/watermarks/` (the sensor has been processed before; this
  run detects continued silence, not a first occurrence).
- **Plugin config**: `autonomy_enabled` may be `true` or `false` — the scenario
  must pass in both states (BLIND-SPOT comment-review is a hard-floor exempt path
  per D-DEC-012 Option A).

## Verification Approach

The holdout evaluator invokes the monitoring-loop as shown in the Scenario section and
observes the following **black-box outputs only**:

1. **Verdict JSON output** (`--output-format json`): Assert:
   - `verdict.sensor_health_status == "silent"`
   - `verdict.disposition` starts with `"Indeterminate"` (sensor-silence →
     Indeterminate-due-to-missing-telemetry).
   - `verdict.ticket_action_type == "comment-review"` (NOT `"create-review"` — open
     ticket already exists; creating a new ticket would violate D-DEC-004).
   - `verdict.ticket_id == "PRISMDEMO-85"` (the existing open ticket key, not a new one).

2. **jr mock call log** (`$MOCK_JR_CALL_LOG`): Assert:
   - `jr issue list --jql` was called at least once (D-DEC-004 dedup query ran).
   - A comment-class call targeting `PRISMDEMO-85` appears (e.g.,
     `jr issue add-comment PRISMDEMO-85`, `jr comment add PRISMDEMO-85`, or equivalent
     jr comment subcommand).
   - **NO** `jr issue create` call appears in the log for this org-b × Claroty sensor
     pair. The absence of a create call is the primary R-006 assertion.
   - **NO** `jr issue move` or `jr issue transition` call on PRISMDEMO-85 (the open
     ticket is NOT reopened, it is simply commented on).

3. **Cron wrapper / audit log**: Loop exits cleanly. `audit.log` contains no
   `HARD-FLOOR-LIVELOCK-ABORT`, `HARD-FLOOR-UNBINDABLE`, or `SEVERITY-MISMATCH` entries.
   If the implementation logs the dedup hit, an entry describing "found existing open
   BLIND-SPOT ticket PRISMDEMO-85, routing to comment-review" is acceptable evidence.

The evaluator MUST NOT inspect hook source code, SKILL.md internals, or marker files.
Only the above observable outputs are in scope.

## Evaluation Rubric

- **Functional correctness** (weight: 0.6): Is `verdict.ticket_action_type == "comment-review"`
  AND `verdict.ticket_id == "PRISMDEMO-85"` AND NO `jr issue create` in the call log?
  (1.0 = all three correct; 0.5 = comment-review verdict set but `jr issue create` also
  called — the dedup failed; 0.0 = `ticket_action_type == "create-review"` and a new
  ticket created, duplicating PRISMDEMO-85)
- **Edge case handling** (weight: 0.1): Does the comment-class jr call target the
  correct existing ticket key `PRISMDEMO-85` rather than a hardcoded or wrong key?
- **Error quality** (weight: 0.2): Does the verdict's `rationale` or `agent_actions`
  field reference the dedup finding (the pre-existing open ticket) and the decision to
  comment rather than create?
- **Performance** (weight: 0.05): Loop completes within the 15-minute per-org budget
  (NFR-PERF-003).
- **Data integrity** (weight: 0.05): PRISMDEMO-85 is not moved to a new state; only a
  comment is added.

## Edge Conditions

- **Run with `autonomy_enabled=false`**: the `comment-review` action must still fire
  (hard-floor exempt from the kill switch per D-DEC-012 Option A). The silence detection
  and comment are not autonomous decisions; they are review-escalation paths.
- **Dedup query returns multiple open tickets** (e.g., a data integrity defect left two
  open BLIND-SPOT tickets): the loop should comment on the most recent open ticket and
  log a warning. Only one comment action should be recorded in the jr mock call log.
- **Claroty sensor becomes healthy before the run**: `last_seen` updated to within 24h.
  The BLIND-SPOT verdict must NOT fire; no ticket action of any kind (create or comment)
  should be taken. This confirms the 24h silence threshold is respected.

## Failure Guidance

"HOLDOUT CRITICAL: HS-061 (satisfaction: 0.0) — The monitoring-loop issued
`jr issue create --label BLIND-SPOT` despite an open BLIND-SPOT ticket (PRISMDEMO-85)
already existing for org-b × Claroty. This is a D-DEC-004 dedup violation: the loop
created a duplicate ticket instead of commenting on the existing one (Jira spam — R-006).
The §3.4 dedup JQL query either did not run or returned a false empty result."

## Category: real-world-corpus

This scenario uses the prism DTU org-b fixture (seed=150) to provide authentic Claroty
xDome sensor health data in the persistent-silence state (sensor has been silent across
multiple monitoring-loop runs). The jr mock's `blind-spot-open` scenario models the
operational state after the first run already created the BLIND-SPOT ticket.

| Field | Value |
|-------|-------|
| corpus_source | prism-dtu-demo-server org-b (seed=150) — Claroty xDome sensor silent >24h; jr mock `blind-spot-open` (PRISMDEMO-85 open) |
| corpus_size | 1 silent Claroty sensor; 1 existing open BLIND-SPOT ticket in jr mock registry |
| known_edge_cases | autonomy_enabled=false must not suppress comment-review (hard-floor exempt); dedup returns multiple open tickets (comment most recent); sensor heals (no ticket action) |
| false_positive_threshold | 0% — any spurious `jr issue create` for the already-open pair is a D-DEC-004 violation |
| false_negative_threshold | 0% — silent sensor with existing open ticket MUST produce a comment-review action |

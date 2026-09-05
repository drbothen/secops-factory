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
id: "HS-036"
category: "f3-delta"
must_pass: "true"
priority: "must-pass"
epic_id: "F3-DELTA-PRISM-INTEGRATION"
behavioral_contracts:
  - BC-10.01.001
  - BC-4.02.001
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

# Holdout Scenario: Monitoring-Loop — §3.4 Jira-First Closed-Same-Root Compound Create+Link (D-022)

## Scenario

1. The prism DTU stack is running with the org-a fixture (seed=100, CrowdStrike sensor healthy). One alert is available above the watermark for a known asset with root cause "RCA-001".
2. The jr mock is configured with the `closed-same` scenario: the issue registry contains one CLOSED Jira ticket (key: `PRISMDEMO-10`) for the same root cause "RCA-001".
3. No watermark file exists for org-a × CrowdStrike (first run; 24h lookback applies).
4. The evaluator invokes the monitoring-loop via the Claude Code CLI:
   ```
   claude -p "/monitoring-loop" \
     --strict-mcp-config \
     --mcp-config "${TEST_PRISM_MCP_CONFIG}" \
     --allowedTools "mcp__prism__*,mcp__tavily__tavily_search,mcp__perplexity__perplexity_ask,Bash,Write,Read,Edit" \
     --output-format json \
     < /dev/null
   ```
5. The §3.4 dedup query finds PRISMDEMO-10 as a CLOSED ticket with the same root cause.
6. The loop emits **two sequential verdict Writes** per the D-022 compound-action rule:
   - verdict-1: `ticket_action_type=create`; the jr mock records `jr issue create --project PRISMDEMO` → returns `PRISMDEMO-42` (a fresh key).
   - verdict-2: `ticket_action_type=link`; the jr mock records `jr issue link PRISMDEMO-42 PRISMDEMO-10`.
7. verdict-2 is NOT issued until verdict-1 `jr issue create` returns a valid key (`PRISMDEMO-42`). The link call references the NEW key, not a placeholder.
8. No `jr issue move` is called to reopen or transition the closed ticket.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-10.01.001 | EC-013: closed ticket + same root cause → D-022 create+link compound action | Steps 6–7 verify two sequential Writes with Iron Law ordering |
| BC-10.01.001 | D-022 Iron Law: verdict-2 MUST NOT be issued until verdict-1 returns a valid ticket key | Step 7 verifies link carries the NEW_KEY (`PRISMDEMO-42`) from the create result |
| BC-4.02.001 | Invariant #4: the loop MUST NOT auto-reopen a closed or resolved ticket | Step 8 verifies no `jr issue move` is called for a non-close-state transition |

## DTU Setup Requirements

- **prism DTU stack**: org-a fixture (seed=100), CrowdStrike sensor healthy, one alert with root cause "RCA-001" above the watermark.
- **jr L2 stateful mock**: `MOCK_JR_SCENARIO=closed-same` — issue registry contains `{"key":"PRISMDEMO-10","status":"Closed","root_cause":"RCA-001"}`. Mock records all calls to `$MOCK_JR_CALL_LOG`.
- **Watermark state**: no watermark file for org-a × CrowdStrike (first run).

## Verification Approach

The holdout evaluator invokes the monitoring-loop as shown in the Scenario and observes the following black-box outputs only:

1. **jr mock call log** (`$MOCK_JR_CALL_LOG`): Assert:
   - Exactly two `jr issue` write calls appear.
   - Call 1: `jr issue create --project PRISMDEMO` (no `--label REVIEW-REQUIRED` since this is non-hard-floor TP).
   - Call 2: `jr issue link PRISMDEMO-42 PRISMDEMO-10` (or whichever key create returned).
   - Call 2 appears AFTER call 1 in the log (ordering enforced by D-022 Iron Law).
   - No `jr issue move`, no `jr issue transition`, no `jr issue assign` in the log.

2. **Verdict JSON output** (`--output-format json`): Assert:
   - verdict-1: `ticket_action_type` is `"create"` (or `"create-review"` if scored_priority is high).
   - verdict-2: `ticket_action_type` is `"link"` with `ticket_id` matching the key returned by verdict-1.

3. **Cron wrapper**: Loop exits cleanly (exit code 0). No Gate 2 audit.log flags.

The evaluator must NOT inspect hook internals or marker-store contents.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Were both `jr issue create` and `jr issue link` called in the correct order, with the link referencing the newly created key? (1.0 = both calls correct + ordering correct; 0.5 = both calls present but wrong order or wrong key reference; 0.0 = only one call or no calls)
- **Edge case handling** (weight: 0.1): Is the closed ticket (PRISMDEMO-10) NOT modified or reopened?
- **Error quality** (weight: 0.3): Does the verdict JSON include `disposition_rationale` explaining why a new ticket was created (existing ticket was closed, not reopened)?
- **Performance** (weight: 0.05): Loop completes within the 15-minute per-org budget.
- **Data integrity** (weight: 0.05): The link verdict's `link_target_ticket_id` matches the CLOSED ticket key, not a fabricated or placeholder value.

## Edge Conditions

- Swap to `no-match` scenario (no existing ticket): the loop should emit only a single `jr issue create` call — no link required when there is no closed predecessor.
- Swap to `duplicate-open` scenario: a single `jr issue comment` call should be issued (not create+link).
- Inject a failure where `jr issue create` returns a non-key error response: the loop must NOT issue a link with a null/empty ticket key.

## Failure Guidance

"HOLDOUT HIGH: HS-036 (satisfaction: 0.0) — The monitoring-loop did not issue a compound create+link action for a closed-same-root-cause scenario, or the link was issued before create returned a valid key. This violates the D-022 compound-action Iron Law."

## Category: real-world-corpus

These monitoring-loop scenarios run against the prism DTU demo server with seeded fixtures that mirror real Jira ticket-state scenarios (closed-same-root, duplicate-open, related-open, no-match). The jr L2 stateful mock maintains a realistic per-test issue registry reflecting authentic §3.4 decision-tree branch inputs.

| Field | Value |
|-------|-------|
| corpus_source | prism-dtu-demo-server org-a (seed=100) + jr mock closed-same scenario |
| corpus_size | Seeded: 1 CrowdStrike alert; jr mock 1-ticket registry |
| known_edge_cases | D-022 Iron Law ordering; closed-ticket non-reopen invariant |
| false_positive_threshold | 0% — any `jr issue move` reopening the closed ticket is a defect |
| false_negative_threshold | 0% — missing link verdict after create is a D-022 Iron Law violation |

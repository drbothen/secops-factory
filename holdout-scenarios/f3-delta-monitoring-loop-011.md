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
id: "HS-057"
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

# Holdout Scenario: Monitoring-Loop — D-026 Orphan-Link Recovery: Link-Only Verdict for Open Ticket Missing Relates Link to Closed Predecessor

## Scenario

1. The prism DTU stack is running with the org-a fixture (seed=100, CrowdStrike + Armis
   sensors). One CrowdStrike alert is available above the watermark carrying root cause
   tag "RCA-ORPHAN-001".
2. The jr mock is configured with the `orphan-link` scenario. The issue registry contains:
   - Open ticket PRISMDEMO-77 (status=Open, root_cause="RCA-ORPHAN-001", no issuelinks)
   - Closed ticket PRISMDEMO-10 (status=Closed, root_cause="RCA-ORPHAN-001")
   - `jr issue view PRISMDEMO-77 --output json` returns `"issuelinks": []` — no existing
     Relates link to PRISMDEMO-10. This models a prior D-022 partial-failure: verdict-1
     (create) landed and created PRISMDEMO-77, but verdict-2 (link) never fired due to
     process interruption.
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
5. The §3.4 dedup query detects the open ticket PRISMDEMO-77 (same root cause as the
   alert). Because PRISMDEMO-10 (Closed, same root cause) also exists in the registry,
   the D-026 pre-check runs: `jr issue view PRISMDEMO-77 --output json` is called to
   inspect the issuelinks array for an existing Relates link.
6. The issuelinks array is empty — the D-026 orphan condition is confirmed. The open
   ticket O has no Relates link to the closed predecessor C.
7. The monitoring-loop issues a link-only verdict (D-026 has explicit precedence over
   §3.4 rule 1 — duplicate-open → comment):
   - `ticket_action_type = "link"`
   - `ticket_id = "PRISMDEMO-77"` (KEY1 = the orphan open ticket O)
   - `link_target_ticket_id = "PRISMDEMO-10"` (KEY2 = the closed predecessor C)
8. The jr mock records `jr issue link PRISMDEMO-77 PRISMDEMO-10` in the call log. No
   `--type` flag is present — jr's default link type "Relates" is used per Iron Law.
9. No `jr issue comment` is issued for PRISMDEMO-77 (D-026 forbids commenting on the
   orphan open ticket in the recovery path).
10. No `jr issue create` is issued — no new ticket is created; this is link-only recovery.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-10.01.001 | EC-010 D-026 exception — open ticket O + Closed/Resolved C, same root cause, no Relates(O,C) → link-only verdict; do NOT comment | Steps 7–9: link-only verdict with KEY1=O, KEY2=C; no comment on O |
| BC-10.01.001 | D-026 precedence over §3.4 rule 1 — orphan predicate evaluated BEFORE duplicate-open comment rule | Step 5: §3.4 runs D-026 check before treating PRISMDEMO-77 as a plain duplicate |
| BC-10.01.001 | D-026 link-read mechanism (P21-006) — `jr issue view <key> --output json` used to detect Relates absence | Step 5: `jr issue view PRISMDEMO-77 --output json` appears in jr mock call log before any Write |
| BC-10.01.001 | Invariant #9 — do NOT comment on orphan open ticket O | Step 9: no `jr issue comment` call targeting PRISMDEMO-77 |
| BC-10.01.001 | SM-68 regression guard — orphan-link reconciliation path must be present | Steps 7–10: SM-68 kills when this path is removed; HS-057 confirms it is present |

## DTU Setup Requirements

**DTU required: prism-dtu-demo-server + configs/prism-demo.toml**

- Start `prism-dtu-demo-server` from the prism-demo-bundle release asset. Configure org-a
  at seed=100 (CrowdStrike + Armis sensors). Ensure the CrowdStrike fixture for org-a
  contains one alert above the 24h lookback window with root cause tag "RCA-ORPHAN-001".
- Set `DEMO_FAKE_CROWDSTRIKE_TOKEN` and `DEMO_FAKE_ARMIS_TOKEN` env vars.
- **jr L2 stateful mock**: `MOCK_JR_SCENARIO=orphan-link` — issue registry contains:
  - `{"key":"PRISMDEMO-77","status":"Open","root_cause":"RCA-ORPHAN-001","issuelinks":[]}`
  - `{"key":"PRISMDEMO-10","status":"Closed","root_cause":"RCA-ORPHAN-001"}`
  - Mock records all calls (read and write) to `$MOCK_JR_CALL_LOG`.
  - `jr issue view PRISMDEMO-77 --output json` must return the open ticket with an empty
    `issuelinks` array (simulating the prior D-022 partial-failure state).
- **Watermark state**: no watermark file for org-a × CrowdStrike (first run; 24h lookback).

## Verification Approach

The holdout evaluator invokes the monitoring-loop as shown in the Scenario section and
observes the following **black-box outputs only**:

1. **jr mock call log** (`$MOCK_JR_CALL_LOG`): Assert:
   - `jr issue view PRISMDEMO-77 --output json` (or equivalent) appears in the call log
     BEFORE any Write call for this alert (D-026 link-read mechanism, P21-006).
   - `jr issue link PRISMDEMO-77 PRISMDEMO-10` appears exactly once.
   - KEY1 = PRISMDEMO-77 (the open orphan ticket O); KEY2 = PRISMDEMO-10 (the closed
     predecessor C). Ordering matters: KEY1 is the open ticket, KEY2 is the closed one.
   - No `--type` flag is present in the link call (jr default "Relates" per Iron Law).
   - No `jr issue comment` call targeting PRISMDEMO-77 appears in the call log.
   - No `jr issue create` call appears (link-only — no new ticket is created).

2. **Verdict JSON output** (`--output-format json`): Assert:
   - `ticket_action_type == "link"`
   - `ticket_id == "PRISMDEMO-77"` (KEY1 = orphan open ticket O)
   - `link_target_ticket_id == "PRISMDEMO-10"` (KEY2 = closed predecessor C)
   - `disposition_rationale` references the orphan-link recovery (D-026), the missing
     Relates link, or equivalent language explaining the link-only recovery action.

3. **Cron wrapper / audit log**: Loop exits without error (exit code 0). No Gate 2 flags
   (no HARD-FLOOR-LIVELOCK-ABORT, HARD-FLOOR-UNBINDABLE, or SEVERITY-MISMATCH). The
   audit log contains an entry describing the D-026 orphan-link condition detected and
   the link-only recovery action taken.

The evaluator must NOT inspect hook source code, SKILL.md content, or internal marker
files. Only the above observable outputs are in scope.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Did the loop issue `jr issue link PRISMDEMO-77 PRISMDEMO-10` with correct KEY1/KEY2 ordering, and NOT issue `jr issue comment` on PRISMDEMO-77? (1.0 = link call correct + no comment; 0.5 = link issued but comment also issued; 0.0 = no link issued or KEY order wrong)
- **Edge case handling** (weight: 0.1): Was `jr issue view PRISMDEMO-77 --output json` called to confirm the orphan condition before the link verdict was issued?
- **Error quality** (weight: 0.3): Does the verdict's `disposition_rationale` explain the orphan-link recovery rather than treating PRISMDEMO-77 as a plain duplicate (which would produce a comment instead)?
- **Performance** (weight: 0.05): Run completes within the 15-minute per-org budget (NFR-PERF-003).
- **Data integrity** (weight: 0.05): PRISMDEMO-10 (the closed ticket) is NOT modified or reopened — no `jr issue move` or `jr issue transition` targeting PRISMDEMO-10 appears in the call log.

## Edge Conditions

- If PRISMDEMO-77 already has a `Relates` link to PRISMDEMO-10 in its issuelinks (i.e., the
  prior compound action fully completed and D-026 is not triggered), the loop must fall through
  to §3.4 rule 1 (duplicate-open → comment). This scenario validates the PRESENCE of the
  orphan condition; a non-orphan variant confirms rule 1 is not suppressed when D-026 does
  not apply.
- For non-hard-floor open tickets under `autonomy_enabled=false`: D-026 orphan-link recovery
  issues a REGULAR link verdict which is gated by the kill switch (STEP 5). If O is a
  non-hard-floor alert and `autonomy_enabled=false`, the link Write may be suppressed — but
  the D-026 orphan condition must still be detected and logged in the audit trail. The primary
  test (Step 4) should run with `autonomy_enabled=true` to confirm the link is actually issued.
- KEY ordering must be KEY1=O (open orphan), KEY2=C (closed predecessor). A reversed call
  (`jr issue link PRISMDEMO-10 PRISMDEMO-77`) violates the D-026 rule and would link from the
  closed ticket to the open ticket — an incorrect link direction.

## Failure Guidance

"HOLDOUT MEDIUM: HS-057 (satisfaction: 0.0) — The monitoring-loop either (a) issued a `jr issue comment` on PRISMDEMO-77 instead of a link-only verdict (treating the orphan as a plain duplicate — D-026 precedence failure), (b) issued no jr call at all for the orphan open ticket, or (c) created a new ticket instead of recovering the missing link. SM-68 is the live mutant for this path: its kill confirms the D-026 orphan-link reconciliation check is present and functional."

## Category: real-world-corpus

N/A — This is a `behavioral-subtleties` scenario using a synthetic jr mock with an injected
orphan-link state (open ticket O missing its expected Relates link to closed predecessor C).
No publicly sourced corpus is used; the scenario models a real operational failure mode
(D-022 partial-failure leaving a Jira ticket unlinked to its predecessor).

| Field | Description |
|-------|-------------|
| corpus_source | prism-dtu-demo-server org-a (seed=100, CrowdStrike) + jr mock `orphan-link` scenario |
| corpus_size | 1 CrowdStrike alert; jr mock 2-ticket registry (1 open orphan + 1 closed predecessor) |
| known_edge_cases | Relates link already present (no orphan — D-026 not triggered, falls to rule 1); reversed KEY order; non-hard-floor O under autonomy_enabled=false |
| false_positive_threshold | 0% — any spurious comment on O instead of link-only is a D-026 violation |
| false_negative_threshold | 0% — missing link recovery for a confirmed orphan is a D-026 violation (SM-68) |

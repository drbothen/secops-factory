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
id: "HS-041"
category: "f3-delta"
must_pass: "true"
priority: "must-pass"
epic_id: "F3-DELTA-PRISM-INTEGRATION"
behavioral_contracts:
  - BC-3.03.001
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

# Holdout Scenario: Monitoring-Loop — STEP-3b Hard-Floor Link Null link_target_ticket_id (D-028) → HARD-FLOOR-LIVELOCK-ABORT After 3 UNBINDABLE Denies

## Scenario

1. The prism DTU stack is running with org-a fixture (seed=100). A PRIOR run already created a BLIND-SPOT review ticket (e.g., PRISMDEMO-101) for CrowdStrike sensor silence. The current run detects the same sensor silence persisting — sensor_health_status=silent for CrowdStrike (no rows returned by prism, last_seen > 24h) — so `hard_floor_applies()` returns TRUE for this alert.
2. Plugin config: the GLOBAL plugin-level `jira_project_key` IS PRESENT and set to `"PRISMDEMO"`. Stage-0 Precondition #9 check (BC-10.01.001) passes and the loop starts normally. `jira_project_key` is NOT the binding field that fails — Stage-0 passes cleanly and `jira_project_key` resolves non-null throughout (per-org absent falls back to GLOBAL per D-010). **`jira_project_key` is not the trigger for HARD-FLOOR-UNBINDABLE in this scenario.**
3. Jr mock: `no-match` scenario (PRISMDEMO-101 seed data present; no open Jira ticket found by the loop's Jira-First check for this alert's current compound recovery path).
4. The evaluator invokes the monitoring-loop via the Claude Code CLI.
5. The loop detects the hard-floor condition and issues compound D-022 recovery: verdict-1 (`disposition=Indeterminate`, `ticket_action_type=create-review`) creates a new review ticket key (e.g., PRISMDEMO-102). verdict-1 succeeds.
6. The loop then issues verdict-2 (`ticket_action_type=link`, `is_hard_floor_link=true`): `ticket_id=PRISMDEMO-102` (the newly created key), `link_target_ticket_id=null`. **FAULT INJECTED:** the loop failed to retrieve the prior BLIND-SPOT ticket key (PRISMDEMO-101), so `link_target_ticket_id` is null in the verdict JSON.
7. Per BC-3.03.001 STEP-3b (D-028): disposition-guard checks the hard-floor link verdict's null-binding fields before any marker is written. `link_target_ticket_id=null` → disposition-guard emits `HARD-FLOOR-UNBINDABLE` deny (`missing_field=link_target_ticket_id`). No `jr issue link` command is executed. The loop re-documents verdict-2 and retries.
8. Second Write attempt for verdict-2: disposition-guard emits `HARD-FLOOR-UNBINDABLE` again (`missing_field=link_target_ticket_id`, 2nd consecutive deny). Loop re-docs and retries.
9. Third Write attempt for verdict-2: disposition-guard emits `HARD-FLOOR-UNBINDABLE` again (`missing_field=link_target_ticket_id`, 3rd consecutive deny).
10. After the **3rd consecutive** `HARD-FLOOR-UNBINDABLE` deny for the same verdict-2, the loop emits `HARD-FLOOR-LIVELOCK-ABORT` to the audit.log and advances to the next alert without issuing a link marker.
11. No `jr issue link` or any other jr write call appears in the jr mock call log for the link verdict.
12. The cron wrapper **Gate 2** detects `HARD-FLOOR-LIVELOCK-ABORT` in audit.log and emits a cron failure alert (exit non-zero).

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-3.03.001 | STEP-3b (D-028): hard-floor link verdict with null link_target_ticket_id → HARD-FLOOR-UNBINDABLE deny; missing_field=link_target_ticket_id; no marker written | Steps 7–9 exercise the STEP-3b null-binding guard on three consecutive re-doc attempts |
| BC-10.01.001 | P9-008 LIVELOCK-ABORT cap: after 3 consecutive HARD-FLOOR-UNBINDABLE denies for the same verdict, emit HARD-FLOOR-LIVELOCK-ABORT and advance | Step 10 verifies the cap fires at exactly 3 denies |
| BC-10.01.001 | Cron wrapper Gate 2: grep audit.log for HARD-FLOOR-LIVELOCK-ABORT → fail Gate 2 | Step 12 verifies the cron wrapper surfaces the livelock condition |

## DTU Setup Requirements

- **prism DTU stack**: org-a fixture (seed=100); CrowdStrike sensor last_seen > 24h (silence/BLIND-SPOT condition). A prior-run BLIND-SPOT ticket (PRISMDEMO-101) is pre-seeded in the DTU state to establish the compound D-022 recovery context.
- **Plugin state**: GLOBAL `jira_project_key = "PRISMDEMO"` present in plugin config — Stage-0 Precondition #9 check passes; loop starts and begins processing alerts. Per-org config for org-a: no `jira_project_key` override needed (GLOBAL fallback per D-010 is sufficient; jira_project_key resolves non-null and is NOT the trigger).
- **Fault injection**: The monitoring loop issues verdict-2 with `link_target_ticket_id=null` — simulating failure to retrieve the prior BLIND-SPOT ticket key (PRISMDEMO-101) during the compound D-022 recovery path. This is the STEP-3b null-binding trigger (D-028/P23-001).
- **jr L2 stateful mock**: `MOCK_JR_SCENARIO=no-match`; call log should record zero link calls for the LIVELOCK'd verdict; verdict-1's create-review call may appear if issued before the fault.
- `autonomy_enabled=true` (kill switch not engaged; STEP-3b null-binding guard fires before STEP 4 and STEP 5 are reached for verdict-2).

## Verification Approach

The holdout evaluator observes these black-box outputs:

1. **audit.log** (`${CLAUDE_PLUGIN_DATA}/markers/audit.log`): Assert:
   - At least 3 entries of `HARD-FLOOR-UNBINDABLE` for the same alert's link verdict (verdict-2), each citing `missing_field=link_target_ticket_id`.
   - Exactly 1 entry of `HARD-FLOOR-LIVELOCK-ABORT` after the 3rd deny.
   - The LIVELOCK-ABORT entry appears after all 3 UNBINDABLE entries (ordering).
   - The UNBINDABLE entries cite `link_target_ticket_id` as the missing field — NOT `jira_project_key`.

2. **jr mock call log** (`$MOCK_JR_CALL_LOG`): Assert:
   - Zero `jr issue link` calls for the LIVELOCK'd verdict (link verdict-2 was never authorized).

3. **Cron wrapper**: Exits with non-zero exit code; the wrapper's output explicitly mentions `HARD-FLOOR-LIVELOCK-ABORT` as the failure reason.

The evaluator must NOT inspect marker files to count retries; use only audit.log entries and the cron wrapper exit.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Was `HARD-FLOOR-LIVELOCK-ABORT` emitted after exactly 3 UNBINDABLE denies on the hard-floor link verdict-2, and was no `jr issue link` call made? (1.0 = LIVELOCK-ABORT after 3 denies + 0 link writes; 0.5 = LIVELOCK-ABORT emitted but after wrong count; 0.0 = loop hung, created a link without required binding, or LIVELOCK-ABORT never fired)
- **Edge case handling** (weight: 0.1): Does the cron wrapper Gate 2 detect the LIVELOCK-ABORT entry and exit non-zero?
- **Error quality** (weight: 0.3): Is each HARD-FLOOR-UNBINDABLE audit entry specific about which verdict (alert ID, verdict-2 link action) triggered it and that `missing_field=link_target_ticket_id` (not jira_project_key or another field)?
- **Performance** (weight: 0.05): The loop advances to the next alert after the abort (does not hang indefinitely).
- **Data integrity** (weight: 0.05): No partial marker files are left in the marker-store that could interfere with subsequent runs.

## Edge Conditions

- Fix the null binding by providing a non-null `link_target_ticket_id` in verdict-2 (e.g., `link_target_ticket_id=PRISMDEMO-101`): the loop must succeed on the first STEP-3b check for verdict-2 without reaching LIVELOCK-ABORT (null-binding guard passes; EMIT_LINK_MARKER proceeds; link marker issued). GLOBAL `jira_project_key` (`"PRISMDEMO"`) remains present throughout — it is not the discriminating field.
- Inject exactly 2 HARD-FLOOR-UNBINDABLE denies (misfire — not 3): the loop must continue retrying and NOT emit LIVELOCK-ABORT until the 3rd consecutive deny for the same verdict.

## Failure Guidance

"HOLDOUT HIGH: HS-041 (satisfaction: 0.0) — The monitoring-loop either did not emit HARD-FLOOR-LIVELOCK-ABORT after 3 consecutive HARD-FLOOR-UNBINDABLE denies for the hard-floor link verdict (hung or retried indefinitely), OR it emitted LIVELOCK-ABORT before the 3rd deny, OR it executed a `jr issue link` call without a valid link_target_ticket_id, OR the UNBINDABLE audit entries cited the wrong missing_field (not link_target_ticket_id). The STEP-3b null-binding guard (D-028/P23-001) and the retry cap (P9-008) were not correctly enforced."

## Category: security-probes

The LIVELOCK-ABORT scenario tests the loop's resilience under a real operational failure mode: a hard-floor link verdict where the prior BLIND-SPOT ticket key cannot be retrieved (link_target_ticket_id=null), combined with the compound D-022 recovery path for a recurring sensor-silence condition. The prism DTU sensor-silence fixture with a pre-seeded prior-run ticket provides the hard-floor compound recovery context. `jira_project_key` resolves non-null throughout — the trigger is exclusively the STEP-3b null `link_target_ticket_id` binding check (D-028).

| Field | Value |
|-------|-------|
| corpus_source | prism-dtu-demo-server org-a (seed=100) — CrowdStrike silence; prior-run BLIND-SPOT ticket PRISMDEMO-101 pre-seeded; current-run link verdict-2 `link_target_ticket_id=null` (FAULT: prior ticket key retrieval failure; GLOBAL key `"PRISMDEMO"` present; Stage-0 passes; D-010 fallback non-null) |
| corpus_size | 1 hard-floor Indeterminate alert; 2 compound verdicts (verdict-1 create-review succeeds; verdict-2 link fails × 3 re-doc cycles) |
| known_edge_cases | P9-008 LIVELOCK-ABORT cap at exactly 3; Gate 2 detection of HARD-FLOOR-LIVELOCK-ABORT; missing_field=link_target_ticket_id (NOT jira_project_key) in UNBINDABLE entries |
| false_positive_threshold | 0% — LIVELOCK-ABORT must only fire after exactly 3 consecutive UNBINDABLE denies for the same link verdict |
| false_negative_threshold | 0% — failure to emit LIVELOCK-ABORT on 3rd deny means the loop hangs indefinitely or silently skips the link |

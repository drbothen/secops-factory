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
id: "HS-044"
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
assumption_source: "ASM-013"
risk_source: "R-006"
dtu_required: true
wave_tag: f3-w4
---

# Holdout Scenario: Monitoring-Loop — Known-Problematic Corpus (Claroty xDome org-b Sensor Silent >24h, BLIND-SPOT Triggered)

## Scenario

This is the **known-problematic corpus scenario**. A Claroty xDome sensor (D-033: V1 = Claroty-xDome-only; runtime scope) that has been silent for more than 24 hours must be detected as a telemetry gap, produce a BLIND-SPOT verdict, and generate a review ticket even when the kill switch is engaged. Missing this detection is a FALSE NEGATIVE.

1. prism DTU org-b (seed=150); Claroty xDome sensor with `last_seen` = 36 hours ago in the DTU fixture (stale, far beyond the 24h silence threshold).
2. Jr mock: `blind-spot-absent` scenario — issue registry contains **zero open BLIND-SPOT tickets** for org-b × Claroty.
3. Plugin config: `autonomy_enabled=false` (kill switch engaged — the hardest case, since D-DEC-012 Option A must exempt the BLIND-SPOT create-review from suppression).
4. The evaluator invokes the monitoring-loop via the Claude Code CLI.
5. Stage 0 checks prism sensor health for org-b; Claroty `last_seen` > 24h → `sensor_health_status=silent`.
6. The loop produces an Indeterminate verdict with `verdict.sensor_health_status=silent` and `verdict.disposition` starting with `"Indeterminate"`.
7. `verdict.ticket_action_type = "create-review"` — NOT suppressed by `autonomy_enabled=false` (D-DEC-012 Option A).
8. `jr issue create --project PRISMDEMO --label BLIND-SPOT` is called and recorded in the jr mock call log. The ticket has the **BLIND-SPOT** label (not REVIEW-REQUIRED).
9. No `jr issue move` (no reopen), no regular marker, no `jr issue comment` for a different ticket.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-10.01.001 | EC-006: sensor-silence = BLIND-SPOT positive signal; `create-review` ticket with BLIND-SPOT label | Steps 5–8 verify BLIND-SPOT detection and correct label |
| BC-10.01.001 | §3.7: sensor-silence is a positive security signal (telemetry gap may conceal attack activity) | Step 5 exercises the sensor-silence-as-finding semantic |
| BC-10.01.001 | D-DEC-012 Option A: hard-floor `create-review` EXEMPT from `autonomy_enabled=false` kill switch | Step 7 verifies BLIND-SPOT ticket created even with kill switch engaged |
| BC-10.01.001 | §3.9 hard-floor: `sensor_health_status=silent` forces `ticket_action_type=create-review` unconditionally | Step 7 verifies ASM-013 hard-floor unconditional branch (R-006 dedup invariant) |

## DTU Setup Requirements

- **prism DTU stack**: org-b fixture (seed=150); Claroty sensor `last_seen` = 36h ago (sensor-silence state).
- **jr L2 stateful mock**: `MOCK_JR_SCENARIO=blind-spot-absent` — zero existing BLIND-SPOT tickets for org-b × Claroty.
- **Plugin config**: `autonomy_enabled=false` (most restrictive case).
- **Watermark state**: No existing watermark for org-b × Claroty (first run; 24h lookback applies for regular alerts, but sensor-silence detection fires on sensor health, not on alerts above the watermark).

## Verification Approach

The holdout evaluator invokes the monitoring-loop and observes these black-box outputs only:

1. **Verdict JSON** (`--output-format json`): Assert:
   - `verdict.sensor_health_status == "silent"`
   - `verdict.disposition` starts with `"Indeterminate"` (sensor-silence → Indeterminate-due-to-missing-telemetry)
   - `verdict.ticket_action_type == "create-review"`

2. **jr mock call log**: Assert:
   - `jr issue create --project PRISMDEMO --label BLIND-SPOT` called exactly once.
   - **NOT** `--label REVIEW-REQUIRED` (BLIND-SPOT silence gets the BLIND-SPOT label, not the generic review label).
   - No `jr issue move`, `jr issue comment` (for a different ticket), or `jr issue assign`.

3. **Cron wrapper**: Clean exit (Gate 1 + Gate 2 pass). Sensor-silence is an expected condition; it produces a review ticket, not an error.

4. **BLIND-SPOT dedup check** (run scenario a second time with `blind-spot-open` scenario): when an open BLIND-SPOT ticket already exists, the loop appends a comment (`comment-review`) rather than creating a new ticket — this R-006 dedup variant is verified by changing the jr mock scenario.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Was `verdict.ticket_action_type=create-review` set AND `jr issue create --label BLIND-SPOT` called? (1.0 = both correct; 0.5 = ticket created but wrong label (REVIEW-REQUIRED instead of BLIND-SPOT); 0.0 = no ticket despite silent sensor)
- **Edge case handling** (weight: 0.1): When an open BLIND-SPOT ticket exists (blind-spot-open jr scenario), does the loop comment on the existing ticket rather than create a new one?
- **Error quality** (weight: 0.3): Does `verdict.agent_actions` document the sensor-silence detection event, including the sensor family (Claroty) and the `last_seen` gap duration?
- **Performance** (weight: 0.05): Loop completes within the 15-minute per-org budget.
- **Data integrity** (weight: 0.05): Only one new BLIND-SPOT ticket is created; no duplicates.

## Edge Conditions

- Inject `autonomy_enabled=true` (less restrictive): the BLIND-SPOT `create-review` must still fire and the same BLIND-SPOT ticket is created (no change in behavior; hard-floor is unconditional).
- Inject a Claroty sensor with `last_seen` = 23 hours ago (just under the silence threshold): the loop must NOT raise a BLIND-SPOT; the sensor is considered healthy.

## Failure Guidance

"HOLDOUT CRITICAL: HS-044 (satisfaction: 0.0) — The monitoring-loop did not generate a BLIND-SPOT ticket for a Claroty xDome sensor that has been silent for 36 hours. This is a FALSE NEGATIVE: a real telemetry gap was not surfaced for human review, potentially masking an active attack under sensor-silence cover."

## Category: real-world-corpus

The known-problematic corpus scenario exercises the Claroty xDome silence path that is the primary production concern for D-033 (V1 = Claroty-xDome-only). The prism DTU org-b seed=150 fixture provides authentic Claroty sensor health data in the stale/silent state.

| Field | Value |
|-------|-------|
| corpus_source | prism-dtu-demo-server org-b (seed=150) — Claroty xDome sensor silent >24h |
| corpus_size | 1 silent sensor; 0 alerts above watermark; 1 BLIND-SPOT finding |
| known_edge_cases | R-006 dedup (open BLIND-SPOT → comment not create); autonomy_enabled=false hard-floor exemption |
| false_positive_threshold | 0% — BLIND-SPOT must not fire for sensors last_seen < 24h |
| false_negative_threshold | 0% — any silent Claroty sensor (last_seen > 24h) MUST produce a BLIND-SPOT ticket |

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
id: "HS-042"
category: "f3-delta"
must_pass: "true"
priority: "must-pass"
epic_id: "F3-DELTA-PRISM-INTEGRATION"
behavioral_contracts:
  - BC-10.01.001
  - BC-3.03.001
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

# Holdout Scenario: Monitoring-Loop — FP Auto-Close Path (autonomy_enabled=true, Non-Hard-Floor, D-021)

## Scenario

1. prism DTU org-a (seed=100); CrowdStrike sensor healthy. One alert whose signature matches an entry in the known-FP pattern store (Stage 2 fast-path match).
2. Alert properties: `scored_priority=LOW` (non-hard-floor), sensor healthy (`sensor_health_status=healthy`), no forbidden MITRE technique in the alert.
3. Plugin config: `autonomy_enabled=true`; `jira_close_state="Done"` (from CLOSE_STATE_ALLOWLIST).
4. Jr mock: `fp-auto-close` scenario — the issue registry contains one OPEN Jira ticket (key: `PRISMDEMO-5`) for this alert (matched by root cause or signature).
5. Monitoring-loop invoked via CLI.
6. Stage 2 matches the known-FP store; Stage 3 runs to populate `attack_techniques` (ensuring no forbidden technique); Stages 4–5 are skipped (fast-path).
7. `verdict.disposition = "FP"`.
8. `verdict.ticket_action_type = "close"` — close marker issued; `jr issue move PRISMDEMO-5 Done` is called.
9. No `jr issue create`, `jr issue comment`, or REVIEW-REQUIRED/BLIND-SPOT label ticket is issued.
10. Cron wrapper Gate 1 exits clean; Gate 2 exits clean (no deny codes in audit.log).

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-10.01.001 | EC-009: known-FP fast-path, scored_priority=LOW/MED, sensor healthy, no forbidden technique → FP disposition, auto-close | Steps 6–8 verify the fast-path FP auto-close path |
| BC-10.01.001 | D-019: HIGH/CRIT known-FPs are NOT exempt from the scored_priority floor; LOW/MED known-FPs may auto-close | Step 2 (`scored_priority=LOW`) exercises the auto-close-eligible path |
| BC-3.03.001 | STEP 6 close-disposition gate: `disposition=FP` passes (FP ∈ {FP, BTP} → close allowed) | Step 8 verifies disposition-guard STEP 6 allows the close for FP disposition |
| BC-10.01.001 | D-021 close marker anti-fungibility: close marker issued for FP auto-close; `jr issue move` called with CONFIG-driven close state | Step 8 verifies `jr issue move ... Done` (not a verdict-supplied state) |

## DTU Setup Requirements

- **prism DTU stack**: org-a fixture (seed=100); CrowdStrike sensor healthy; one alert with a known-FP signature pre-seeded in the plugin's known-FP pattern store.
- **Known-FP store**: Must contain an entry matching the DTU alert's signature (pre-seeded by evaluator or fixture).
- **jr L2 stateful mock**: `MOCK_JR_SCENARIO=fp-auto-close` — issue registry: `{"key":"PRISMDEMO-5","status":"Open"}`.
- **Plugin config**: `autonomy_enabled=true`, `jira_close_state="Done"`.

## Verification Approach

The holdout evaluator invokes the monitoring-loop as shown and observes these black-box outputs only:

1. **Verdict JSON**: Assert `verdict.disposition == "FP"` and `verdict.ticket_action_type == "close"`.
2. **jr mock call log**: Assert `jr issue move PRISMDEMO-5 Done` called exactly once. Assert NO `jr issue create`, `jr issue comment` (non-close), or `jr issue link` in the log.
3. **Cron wrapper**: Clean exit. No `CLOSE-DISPOSITION-DENY`, `CLOSE-STATE-DENY`, or other Gate 2 codes in audit.log.
4. **Verdict JSON** `confidence` field: For known-FP fast-path, confidence should be `"high"` (knowledge-base match = high-confidence FP).

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Was `disposition=FP`, `ticket_action_type=close`, and `jr issue move PRISMDEMO-5 Done` called? (1.0 = all three correct; 0.5 = disposition correct but wrong close action; 0.0 = ticket not closed or wrong disposition)
- **Edge case handling** (weight: 0.1): Is `confidence == "high"` for the known-FP fast-path?
- **Error quality** (weight: 0.3): Does `disposition_rationale` reference the known-FP pattern store match?
- **Performance** (weight: 0.05): Stages 4–5 skipped on fast-path; loop faster than the 15-minute budget.
- **Data integrity** (weight: 0.05): `jr issue move` uses `jira_close_state="Done"` from config, NOT from any verdict field (CONFIG-driven, not verdict-influenceable — D-021 anti-injection requirement).

## Edge Conditions

- Swap `scored_priority=HIGH` (hard-floor): the loop must NOT auto-close even for a known-FP (D-019 floor exemption). Instead, `ticket_action_type=comment-review`.
- Swap `autonomy_enabled=false` with `scored_priority=LOW` FP: the kill switch should suppress the close marker (FP auto-close is a REGULAR marker, not a review-class marker); `ticket_action_type="none"` expected.

## Failure Guidance

"HOLDOUT HIGH: HS-042 (satisfaction: 0.0) — The monitoring-loop did not auto-close the open FP ticket, or issued a create-review ticket instead of a close, or the close state was taken from the verdict field rather than the CONFIG (D-021 anti-injection violation)."

## Category: real-world-corpus

The FP auto-close path exercises the known-FP pattern store fast-path combined with the D-021 close marker. The DTU org-a CrowdStrike fixture provides realistic low-severity alerts that are legitimate close candidates when matched against the FP store.

| Field | Value |
|-------|-------|
| corpus_source | prism-dtu-demo-server org-a (seed=100) — CrowdStrike FP-matched alert + jr fp-auto-close fixture |
| corpus_size | 1 FP alert; open ticket PRISMDEMO-5 |
| known_edge_cases | D-019 HIGH/CRIT known-FP floor; D-021 CONFIG-driven close state (not verdict-supplied) |
| false_positive_threshold | 0% — close must only occur when disposition=FP and non-hard-floor |
| false_negative_threshold | 0% — a legitimate FP/low/healthy alert must auto-close when autonomy_enabled=true |

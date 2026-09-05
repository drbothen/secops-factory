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
id: "HS-039"
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

# Holdout Scenario: Monitoring-Loop — NORMALIZE_SEVERITY Claroty CRITICAL + Cyberint Conservative Default Pre-ASM-008

## Scenario

**Sub-scenario A — Claroty CRITICAL normalization:**

1. prism DTU org-b (seed=150); Claroty xDome sensor healthy; one alert with `native_severity=CRITICAL`.
2. Monitoring-loop invoked via CLI.
3. The verdict must reflect: `verdict.severity=CRITICAL`, `verdict.sensor_family=Claroty`, `verdict.native_severity=CRITICAL`.
4. `verdict.scored_priority` must be `"CRIT"` (mapped through SEVERITY_TO_SCORED_PRIORITY_MAP: CRITICAL→CRIT).
5. Because `scored_priority=CRIT` is a hard-floor condition, `verdict.ticket_action_type=create-review`. A `jr issue create --project PRISMDEMO --label REVIEW-REQUIRED` call is recorded.

**Sub-scenario B — Cyberint conservative default:**

6. prism DTU org-b (seed=150); Cyberint sensor healthy; one alert with `native_severity="high"` (any non-CRITICAL native value).
7. Monitoring-loop invoked via CLI.
8. The verdict must reflect: `verdict.severity=CRITICAL` (conservative default — Cyberint mapping unvalidated pre-ASM-008).
9. `verdict.uncertainty_explicit` (field 8) must contain the text: `"Cyberint severity mapping unvalidated per ASM-008; conservative CRITICAL applied"`.
10. `verdict.scored_priority=CRIT`; ticket routes to `create-review` (hard-floor).

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-10.01.001 | D-DEC-013 NORMALIZE_SEVERITY per-sensor-family table: Claroty CRITICAL band maps to CRITICAL | Sub-scenario A steps 3–4 verify correct Claroty normalization |
| BC-10.01.001 | D-DEC-013: Cyberint ANY native severity → CRITICAL + uncertainty_explicit (pre-ASM-008 conservative) | Sub-scenario B steps 8–9 verify Cyberint conservative routing |
| BC-10.01.001 | P12-003: `scored_priority` MUST be mapped through SEVERITY_TO_SCORED_PRIORITY_MAP (CRITICAL→CRIT), NOT a raw assignment | Steps 4 and 10 verify the mapped enum token (`CRIT` not `CRITICAL`) |

## DTU Setup Requirements

- **prism DTU stack**: org-b fixture (seed=150) with both Claroty and Cyberint sensors; Claroty alert with `native_severity=CRITICAL`; Cyberint alert with `native_severity="high"`.
- **jr L2 stateful mock**: `MOCK_JR_SCENARIO=no-match` for both alerts.
- **Plugin config**: `autonomy_enabled=true`.

## Verification Approach

The holdout evaluator invokes the monitoring-loop as shown in the Scenario for each sub-scenario and observes these black-box outputs only:

**Sub-scenario A (Claroty):**
1. `verdict.sensor_family == "Claroty"`.
2. `verdict.severity == "CRITICAL"`.
3. `verdict.scored_priority == "CRIT"` (NOT `"CRITICAL"` — must be the mapped enum token).
4. `verdict.ticket_action_type == "create-review"` (hard-floor: CRIT scored_priority).
5. `jr issue create --label REVIEW-REQUIRED` in jr mock call log.

**Sub-scenario B (Cyberint):**
1. `verdict.sensor_family == "Cyberint"` (or equivalent Cyberint family name from fixture).
2. `verdict.severity == "CRITICAL"` (conservative default regardless of `native_severity="high"`).
3. `verdict.uncertainty_explicit` contains `"ASM-008"` and `"conservative CRITICAL"`.
4. `verdict.scored_priority == "CRIT"`.
5. `verdict.ticket_action_type == "create-review"`.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): For both sub-scenarios, was `severity=CRITICAL` and `scored_priority=CRIT` (correct mapped token)? (1.0 = both correct; 0.5 = severity correct but scored_priority raw "CRITICAL" instead of "CRIT"; 0.0 = wrong severity or no uncertainty_explicit for Cyberint)
- **Edge case handling** (weight: 0.1): Does `uncertainty_explicit` mention ASM-008 for the Cyberint verdict specifically?
- **Error quality** (weight: 0.3): Is the Cyberint conservative note in `uncertainty_explicit` specific enough for an operator to understand why CRITICAL was assigned?
- **Performance** (weight: 0.05): Both alerts processed within budget.
- **Data integrity** (weight: 0.05): `scored_priority` enum tokens are exactly `{CRIT, HIGH, MED, LOW}` — no raw CRITICAL/MEDIUM values.

## Edge Conditions

- Inject a Claroty alert with `native_severity="medium"`: should normalize to MEDIUM (not CRITICAL). Verify SEVERITY_TO_SCORED_PRIORITY_MAP maps MEDIUM→MED.
- Inject an unrecognized sensor family (e.g., "UnknownVendor"): should produce `severity=CRITICAL` with `uncertainty_explicit` noting the unrecognized family.

## Failure Guidance

"HOLDOUT HIGH: HS-039 (satisfaction: 0.0) — The monitoring-loop produced an incorrect `scored_priority` value (e.g., 'CRITICAL' instead of 'CRIT'), OR the Cyberint conservative CRITICAL default was not applied, OR `uncertainty_explicit` is missing the ASM-008 caveat for Cyberint alerts."

## Category: real-world-corpus

The Cyberint conservative CRITICAL default is a production-relevant invariant — until ASM-008 resolves, 100% of Cyberint alerts in org-b must produce hard-floor REVIEW-REQUIRED tickets. The DTU org-b fixture provides both Claroty and Cyberint sensor data in OCSF-normalized format with realistic native severity values.

| Field | Value |
|-------|-------|
| corpus_source | prism-dtu-demo-server org-b (seed=150) — Claroty + Cyberint sensor data |
| corpus_size | 2 alerts (1 Claroty CRITICAL; 1 Cyberint any-native-severity) |
| known_edge_cases | Cyberint conservative-CRITICAL flood in org-b until ASM-008; P12-003 raw-enum defect |
| false_positive_threshold | 0% — Cyberint any-severity MUST produce CRITICAL pre-ASM-008 |
| false_negative_threshold | 0% — any Cyberint alert with severity != CRITICAL pre-ASM-008 is a defect |

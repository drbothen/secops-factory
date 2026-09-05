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
id: "HS-040"
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

# Holdout Scenario: Monitoring-Loop — ICD-203 18-Field Verdict Completeness (No Field Missing)

## Scenario

1. The prism DTU stack is running with org-a fixture (seed=100, CrowdStrike sensor healthy). One TP alert is available above the watermark: `scored_priority=MED`, `asset_type` known (non-unknown), no forbidden MITRE technique, sensor healthy.
2. Plugin config: `autonomy_enabled=true`.
3. Jr mock: `no-match` scenario.
4. The evaluator invokes the monitoring-loop via the Claude Code CLI with `--output-format json`:
   ```
   claude -p "/monitoring-loop" \
     --strict-mcp-config \
     --mcp-config "${TEST_PRISM_MCP_CONFIG}" \
     --allowedTools "mcp__prism__*,mcp__tavily__tavily_search,mcp__perplexity__perplexity_ask,Bash,Write,Read,Edit" \
     --output-format json \
     < /dev/null
   ```
5. The monitoring-loop emits a verdict JSON object in its output.
6. The evaluator checks that the verdict contains ALL 18 ICD-203 fields with non-null values:
   - Field 1: `disposition` (one of: TP, FP, BTP, Indeterminate)
   - Field 2: `confidence` (one of: `"high"`, `"medium"`, `"low"` — ENUM only; no float)
   - Field 3: `sensor_health_status` (one of: healthy, degraded, silent)
   - Field 4: `evidence_artifacts` (array of evidence objects from Stage 1 sensor data)
   - Field 5: `timeline_events` (array of timestamped events)
   - Field 6: `hypotheses_considered` (array of investigated hypotheses)
   - Field 7: `alternatives_rejected` (array of considered-and-rejected dispositions)
   - Field 8: `uncertainty_explicit` (string describing known uncertainties)
   - Field 9: `attack_techniques` (array, may be empty if no MITRE mapping found — but field must be present)
   - Field 10: `agent_actions` (array of actions taken by the loop)
   - Field 11: `disposition_rationale` (string explaining the disposition)
   - Field 12: `asset_id` (from sensor data)
   - Field 13: `severity` (NORMALIZE_SEVERITY output: CRITICAL/HIGH/MEDIUM/LOW)
   - Field 14: `asset_type` (enum: endpoint, server, iot, unknown, etc.)
   - Field 15: `ticket_action_type` (one of the 8-member ACTION_ENUM)
   - Field 16: `native_severity` (raw sensor severity string)
   - Field 17: `sensor_family` (sensor vendor/family identifier)
   - Field 18: `scored_priority` (one of: CRIT, HIGH, MED, LOW)
7. A verdict missing ANY of these 18 fields, OR containing a `null` value for any field, is a defect.
8. `confidence` must be exactly `"high"`, `"medium"`, or `"low"` — a float value (e.g., 0.85) is invalid per D-DEC-011.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-10.01.001 | §3.8: 18-field ICD-203 verdict schema | Step 6 explicitly validates all 18 fields are present and non-null |
| BC-10.01.001 | Invariant #9 field 2: `confidence` is ENUM-ONLY (`high`/`medium`/`low`), NOT a float | Step 8 verifies the enum constraint on the `confidence` field |
| BC-10.01.001 | Invariant #9 field 18: `scored_priority` is enum `{CRIT,HIGH,MED,LOW}`, NOT raw NORMALIZE_SEVERITY output | Step 6 field 18 check verifies no raw CRITICAL/MEDIUM tokens |

## DTU Setup Requirements

- **prism DTU stack**: org-a fixture (seed=100); CrowdStrike sensor healthy; one TP alert with `scored_priority=MED`.
- **jr L2 stateful mock**: `MOCK_JR_SCENARIO=no-match`.
- **Plugin config**: `autonomy_enabled=true`.
- Enrichment: Tavily and Perplexity may be unavailable (graceful degradation path acceptable); evaluator should note if `uncertainty_explicit` documents the unavailability.

## Verification Approach

The holdout evaluator parses the `--output-format json` output and performs field-by-field presence and type checks:

1. Extract the verdict JSON from the output.
2. For each of the 18 fields listed in Step 6 above, assert the field key is present AND the value is non-null.
3. Assert `confidence ∈ {"high", "medium", "low"}` (string, not float).
4. Assert `scored_priority ∈ {"CRIT", "HIGH", "MED", "LOW"}` (no raw CRITICAL/MEDIUM).
5. Assert `disposition ∈ {"TP", "FP", "BTP", "Indeterminate"}` or starts with "Indeterminate-".
6. Assert `ticket_action_type ∈ {"comment", "create", "assign", "none", "create-review", "comment-review", "link", "close"}`.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Are all 18 fields present and non-null? (1.0 = all 18 present + non-null; 0.5 = 15–17 fields present; 0.0 = fewer than 15 fields or a critical field like `disposition` or `scored_priority` is missing)
- **Edge case handling** (weight: 0.1): Is the `confidence` field an enum string (not a float)?
- **Error quality** (weight: 0.3): Is `disposition_rationale` (field 11) substantive — does it explain WHY the disposition was chosen, not just echo the disposition label?
- **Performance** (weight: 0.05): Loop completes within budget.
- **Data integrity** (weight: 0.05): `scored_priority` uses the mapped enum token (CRIT/HIGH/MED/LOW), not the raw NORMALIZE_SEVERITY output (CRITICAL/MEDIUM).

## Edge Conditions

- Invoke loop when Tavily AND Perplexity are unavailable: all 18 fields must still be present; `uncertainty_explicit` documents the unavailability.
- Invoke loop with a MITRE T1003 alert: `attack_techniques` must be non-empty; `scored_priority` must reflect the T1003 hard-floor.

## Failure Guidance

"HOLDOUT HIGH: HS-040 (satisfaction: 0.0) — The monitoring-loop emitted a verdict missing one or more of the 18 ICD-203 required fields, or the `confidence` field contained a float instead of an enum string. Every verdict must be a complete, schema-valid ICD-203 defensible record."

## Category: real-world-corpus

The 18-field ICD-203 schema represents the full defensible record format required for audit-traceable autonomous triage. The DTU org-a CrowdStrike fixture provides realistic sensor data to drive a complete end-to-end verdict construction including all enrichment stages.

| Field | Value |
|-------|-------|
| corpus_source | prism-dtu-demo-server org-a (seed=100) — CrowdStrike TP alert |
| corpus_size | 1 TP alert; full enrichment pipeline |
| known_edge_cases | Float vs enum for confidence; raw vs mapped scored_priority token |
| false_positive_threshold | N/A — schema completeness must be 100% |
| false_negative_threshold | 0% — any missing ICD-203 field is a schema defect |

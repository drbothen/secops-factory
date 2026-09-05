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
id: "HS-055"
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
risk_source: "R-001"
dtu_required: false
wave_tag: f3-w4
---

# Holdout Scenario: ASM-013/R-001 Hard-Floor Unconditional — autonomy_enabled=true Cannot Bypass Indeterminate Hard Floor

## Scenario

ASM-013 asserts that hard-floor routing in the monitoring-loop remains an unconditional
code-branch decision — not a config-evaluated condition that can be toggled by
`autonomy_enabled`. If hard floors ever became config-evaluated, R-001 would materialize:
an operator setting `autonomy_enabled=true` would inadvertently (or deliberately) bypass
the hard-floor requirement and allow regular (non-review) Jira markers for verdicts
that require human oversight.

This scenario probes both Indeterminate and HIGH/CRIT scored_priority hard-floor paths
with `autonomy_enabled=true` to confirm the floor is unconditional.

**Sub-scenario A — Indeterminate disposition + autonomy_enabled=true:**

1. Plugin activated with `autonomy_enabled=true` (maximum autonomy; kill switch OFF).
2. The monitoring-loop produces a verdict with `disposition=Indeterminate` (e.g., due
   to degraded sensor telemetry) — a hard-floor condition.
3. Despite `autonomy_enabled=true`, the verdict's `ticket_action_type` field in the
   structured output must be `"create-review"` or `"comment-review"`.
4. No regular `jr issue comment` or `jr issue create` (without `--label REVIEW-REQUIRED`
   or `--label BLIND-SPOT`) is called.
5. A restricted review marker is issued; the Jira ticket (if created) carries the
   `REVIEW-REQUIRED` or `BLIND-SPOT` label.

**Sub-scenario B — scored_priority=CRIT + autonomy_enabled=true:**

1. Same setup: `autonomy_enabled=true`.
2. The monitoring-loop produces a verdict with `scored_priority=CRIT` (HIGH-impact
   scored priority — a hard-floor condition regardless of disposition).
3. Same constraint: `ticket_action_type` must be `"create-review"` or `"comment-review"`.
4. No regular (non-review-labeled) Jira action is taken.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-10.01.001 | §3.9 hard-floor categories — disposition=Indeterminate always routes to create-review/comment-review | Sub-A: Indeterminate + autonomy_enabled=true → review action, not regular action |
| BC-10.01.001 | §3.9 hard-floor categories — scored_priority ∈ {HIGH, CRIT} always routes to create-review/comment-review | Sub-B: CRIT + autonomy_enabled=true → review action |
| BC-10.01.001 | Invariant #11 — D-DEC-012 Option A: create-review/comment-review EXEMPT from kill switch (and required for hard floors) | Both sub-scenarios: review action fires even with autonomy_enabled=true |

## DTU Setup Requirements

No DTU required — uses jr mock and local filesystem.

- Plugin activated with `autonomy_enabled=true`.
- Configure a jr mock that records all `jr issue create` and `jr issue comment` calls
  with their arguments (especially the `--label` flag).
- Sub-scenario A: synthesize a verdict fixture where `disposition=Indeterminate`
  (e.g., invoke monitoring-loop with a sensor-silence fixture or mock a degraded
  sensor response).
- Sub-scenario B: synthesize a verdict fixture where `scored_priority=CRIT` (e.g.,
  a CrowdStrike CRITICAL severity alert that maps to CRIT after NORMALIZE_SEVERITY
  and assess-priority).

## Verification Approach

The evaluator invokes the monitoring-loop or provides a direct verdict context that
produces Indeterminate and CRIT verdicts.

**Prompt (both sub-scenarios):**
```
/monitoring-loop
```
(with appropriate fixture pre-loaded)

**Observe (Sub-A — Indeterminate):**
1. `verdict.ticket_action_type` in the structured output is `"create-review"` or
   `"comment-review"` — NOT `"none"`, `"comment"`, or `"create"`.
2. The jr mock call log: if `jr issue create` was called, it must include
   `--label REVIEW-REQUIRED` or `--label BLIND-SPOT`.
3. If `jr issue create` was called WITHOUT a `--label REVIEW-REQUIRED` or
   `--label BLIND-SPOT` flag, this is a FAILURE.
4. `ticket_action_type="none"` for an Indeterminate verdict is a FAILURE — hard
   floors are never silent.

**Observe (Sub-B — CRIT):**
Same checks as Sub-A; `scored_priority=CRIT` must also route to review action.

The evaluator must NOT inspect hook source code. Only observable outputs are in scope.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Does `ticket_action_type` resolve to a review action for both Indeterminate and CRIT hard floors, even with `autonomy_enabled=true`? (1.0 = both; 0.5 = one; 0.0 = neither)
- **Edge case handling** (weight: 0.1): Is `ticket_action_type="none"` absent for both hard-floor verdicts?
- **Error quality** (weight: 0.3): If `jr issue create` was called, does its `--label` argument carry the review label?
- **Performance** (weight: 0.05): Monitoring-loop completes within a reasonable time.
- **Data integrity** (weight: 0.05): No regular (non-review-labeled) Jira ticket created for either hard-floor verdict.

## Edge Conditions

- Confirm that a non-hard-floor verdict (e.g., `disposition=FP`, `scored_priority=LOW`,
  healthy sensor) with `autonomy_enabled=true` DOES use a regular action (not forced
  into review) — the hard floor must not over-apply.
- Confirm `autonomy_enabled=true` + `scored_priority=HIGH` routes to review (both
  HIGH and CRIT are in the hard-floor set).

## Failure Guidance

"HOLDOUT CRITICAL: HS-055 (satisfaction: 0.XX) — With autonomy_enabled=true, an Indeterminate or CRIT verdict received a regular Jira action instead of a review action (create-review/comment-review). This is an ASM-013/R-001 materialization: the hard-floor routing has become config-evaluable and can be bypassed by setting autonomy_enabled=true."

## Category: real-world-corpus

N/A — This is a `security-probes` scenario using synthetic verdict fixtures.
ASM-013 and R-001 coverage scenario.

| Field | Description |
|-------|-------------|
| corpus_source | Synthetic verdict fixtures (Indeterminate + CRIT) |
| corpus_size | 2 verdicts (one per sub-scenario) |
| known_edge_cases | Non-hard-floor FP+LOW (must use regular action); HIGH scored_priority |
| false_positive_threshold | N/A |
| false_negative_threshold | N/A |

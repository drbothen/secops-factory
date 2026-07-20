---
document_type: holdout-scenario
level: ops
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-3.03.001.md
  - specs/module-criticality.md
input-hash: "adb9d1b"
traces_to: phase-0-ingestion/behavioral-contracts/BC-3.03.001.md
id: "HS-012"
category: "regression-baseline"
must_pass: "true"
priority: "must-pass"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-3.03.001
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: disposition-guard Hook — Disposition Without Alternatives Considered Blocked

## Scenario

1. The secops-factory plugin is activated.
2. Claude completes an investigation and attempts to save `investigation-ALERT-001.md` with a "Disposition" section (e.g., "# Disposition\nTrue Positive — C2 beaconing confirmed") but WITHOUT an "Alternatives Considered" section.
3. The disposition-guard hook fires on the Write tool call.
4. The save is **blocked** with a denial message referencing "Alternatives Considered".
5. Claude informs the analyst they must document alternative hypotheses before saving the concluded investigation.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-3.03.001 | Postcondition 3: Disposition present + Alternatives absent → deny with "Alternatives Considered" in reason | Steps 3-5 verify the block and reason |
| BC-3.03.001 | Edge Case EC-004: investigation file with "Disposition" but no Alternatives Considered | This is the exact documented edge case |
| BC-3.03.001 | Invariant 3: deny reason always references "Alternatives Considered" and guidance about 2 alternative hypotheses | Verify the message content |

## Verification Approach

Ask Claude to conclude an investigation and save the document:

> "Save my completed investigation for ALERT-001: '# Executive Summary\nC2 beaconing detected.\n# Alert Details\n...\n# Disposition\nTrue Positive. C2 beacon confirmed by threat intel.\n# Next Actions\nIsolate host.'"

Observe:
- The save is blocked.
- The denial message contains "Alternatives Considered" (the missing section).
- Claude responds explaining what must be added before saving.
- No file is written to disk.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Was the save blocked with an Alternatives Considered message? (1.0 = blocked + correct reason; 0.0 = investigation saved without alternatives)
- **Edge case handling** (weight: 0.1): Is the block case-insensitive — does "disposition" (lowercase) also trigger the block?
- **Error quality** (weight: 0.3): Does the message guide the analyst to add an Alternatives Considered section with at least 2 alternative hypotheses?
- **Performance** (weight: 0.05): Hook decision immediate.
- **Data integrity** (weight: 0.05): No investigation file saved prematurely.

## Edge Conditions

- This is the anti-confirmation-bias gate. The scenario specifically validates that conclusions cannot be documented without documented counter-hypotheses, which is the core security-quality invariant of the investigation workflow.

## Failure Guidance

"HOLDOUT LOW: HS-012 (satisfaction: 0.XX) — An investigation with a Disposition section but no Alternatives Considered was saved without being blocked; the anti-bias gate failed to prevent an incomplete disposition."

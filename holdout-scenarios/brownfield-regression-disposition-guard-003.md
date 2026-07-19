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
input-hash: ""
traces_to: phase-0-ingestion/behavioral-contracts/BC-3.03.001.md
id: "HS-014"
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

# Holdout Scenario: disposition-guard Hook — Negating Body Text Does Not Defeat the Gate (SM-1 Regression)

## Scenario

1. The secops-factory plugin is activated.
2. Claude attempts to save `investigation-ALERT-003.md` that contains a "Disposition" section followed by body text reading: "No alternatives considered — this is an unambiguous True Positive." The phrase "alternatives considered" appears in the body text, but NOT as a section heading.
3. The disposition-guard hook fires and searches for "Alternatives Considered" as a substring in the full document content.
4. Because the phrase appears in the body text (even in a negating context), the hook evaluates it as present and **allows** the save.
5. The analyst's investigation concludes without a formal Alternatives Considered section.

**Note:** This scenario documents the confirmed SM-1 false-pass vulnerability (DI-004). The current hook implementation has this known limitation. The expected behavior here reflects what the hook CURRENTLY does (allows the save). This scenario is written to track the vulnerability as a regression baseline — if the hook is later fixed with heading-anchored matching, this scenario's expected behavior should be updated to "blocked."

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-3.03.001 | Edge Case EC-007: "Disposition" in body text (not section header) + "Alternatives Considered" in body text → currently passes gate | Documents the known false-pass behavior |
| BC-3.03.001 | Invariant 2: hook checks section heading presence, not content quality — but substrate match only | The substring-only check is the root cause |

## Verification Approach

Ask Claude to save an investigation where the analyst includes a negating statement about alternatives:

> "Save investigation-ALERT-003.md: '# Disposition\nTrue Positive confirmed.\nI considered no alternatives here as the evidence is definitive.\n# Next Actions\nEscalate to IR.'"

Observe the current behavior:
- Does the hook block (because "Alternatives Considered" section heading is absent) or allow (because some variant of "alternatives" appears in body text)?

This is a regression-detection scenario. If the hook currently allows this (expected per SM-1), document it. If a future fix causes it to block, this scenario confirms the fix is in place.

## Evaluation Rubric

- **Functional correctness** (weight: 0.4): Is the actual behavior consistent with the documented SM-1 known issue? (1.0 = behavior matches documented known state; 0.0 = unexpected behavior)
- **Edge case handling** (weight: 0.3): Does the hook's response change if "Alternatives Considered" is added as a proper heading? It should then allow.
- **Error quality** (weight: 0.1): Any block message is informative.
- **Performance** (weight: 0.1): Normal hook execution.
- **Data integrity** (weight: 0.1): Document state is predictable.

## Edge Conditions

- This scenario is specifically tracking the DI-004 / SM-1 surviving mutant. Its resolution status should be reviewed each release cycle to confirm whether the heading-anchored fix has landed.

## Failure Guidance

"HOLDOUT LOW: HS-014 (satisfaction: 0.XX) — Disposition-guard behavior around negating body-text alternatives has changed unexpectedly; verify SM-1 fix status and update this scenario's expected behavior accordingly."

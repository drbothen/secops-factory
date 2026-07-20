---
document_type: holdout-scenario
level: ops
version: "1.2"
status: active
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-3.03.001.md
  - specs/module-criticality.md
input-hash: "b329ffe"
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

# Holdout Scenario: disposition-guard Hook — Negating Body Text Does Not Defeat the Gate (SM-1 Regression Guard)

> **Promoted v1.2 (DI-004 fixed PR #17):** DI-004 / SM-1 is resolved. The
> disposition-guard hook is now heading-anchored: negating body text no longer
> produces a false-pass. This scenario has been promoted from `fix-target /
> should-pass` to `must-pass` regression guard. Current HEAD correctly DENIES
> saves where "Alternatives Considered" appears only in body text, not as a
> section heading. Baseline = **34 must-pass + 0 fix-targets**.
>
> History: v1.0 labeled must-pass (wrong — HEAD failed); v1.1 reclassified to
> fix-target (ADV-0-602); v1.2 promoted back to must-pass (DI-004 fixed PR #17).

## Scenario

1. The secops-factory plugin is activated.
2. Claude attempts to save `investigation-ALERT-003.md` that contains a "Disposition" section followed by body text: "No alternatives considered — this is an unambiguous True Positive." The phrase "alternatives considered" appears embedded in a negating sentence in the body, but there is **no "# Alternatives Considered" section heading** anywhere in the document.
3. The disposition-guard hook fires and evaluates the document.
4. **Expected behavior (current HEAD, post-PR #17):** The hook recognises that the "Alternatives Considered" string appears only in body text (not as a section heading) and **denies** the save — the analyst must add a proper "# Alternatives Considered" section before the document can be saved.
5. This scenario now passes on current HEAD. A regression to allowing the save would indicate the heading-anchored fix in PR #17 was reverted or was incomplete.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-3.03.001 | Postcondition 3: Disposition present + Alternatives absent → deny with "Alternatives Considered" in reason | Post-fix: steps 3-4 verify the heading-anchored deny fires correctly |
| BC-3.03.001 | Edge Case EC-007 (known limitation): content containing "Disposition" in body text (not section header) → currently passes if "Alternatives Considered" also in body | DI-004 root cause — this scenario tests the fix for EC-007 |
| BC-3.03.001 | Invariant 2: hook checks section heading presence, not content quality | The post-fix hook must distinguish heading-level presence from body-text occurrence |

## Verification Approach

Ask Claude to save an investigation that embeds a negating reference to alternatives in the body but has no dedicated section:

> "Save investigation-ALERT-003.md: '# Executive Summary\nAlert investigated.\n# Alert Details\nEvidence gathered.\n# Disposition\nTrue Positive confirmed.\nNo alternatives considered — this is an unambiguous True Positive.\n# Next Actions\nEscalate to IR.'"

**Expected behavior (current HEAD passes this — regression guard):**
- The save is **blocked**.
- The denial message references "Alternatives Considered" as the missing element.
- Claude communicates to the analyst that a proper "# Alternatives Considered" section heading is required, not just a mention in body text.

If the save is allowed, this is a regression: the heading-anchored fix from PR #17 has been reverted or broken. Evaluator should mark satisfaction 0.0 and flag as regression against DI-004.

## Evaluation Rubric

- **Functional correctness** (weight: 0.6): Is the save **denied** because "Alternatives Considered" appears only in body text, not as a section heading? (1.0 = denied with correct reason; 0.0 = false-pass allowed the save — regression against PR #17 heading-anchored fix)
- **Edge case handling** (weight: 0.2): Does the denial message distinguish between body-text occurrence and a section heading? Does it guide the analyst to add the heading?
- **Error quality** (weight: 0.1): Is the denial reason informative and actionable?
- **Performance** (weight: 0.05): Hook fires without noticeable delay.
- **Data integrity** (weight: 0.05): No investigation file is saved without the proper Alternatives section heading.

## Edge Conditions

- After the fix: saving with `# Alternatives Considered\n1. FP...\n2. TP...` as an actual section heading must produce **allow**. The heading-anchored check must not over-block.
- The fix is specifically for heading-anchored matching — the denial must fire on body-text occurrence and allow on proper heading occurrence.
- This scenario tracks the heading-anchored fix landed in PR #17 (DI-004 resolved). Any future reversion to substring matching must be caught by this guard.

## Failure Guidance

"HOLDOUT HIGH: HS-014 (satisfaction: 0.XX) — disposition-guard allowed an investigation save where 'Alternatives Considered' appears only in negating body text (no section heading). This is a regression: the heading-anchored fix from PR #17 (DI-004 resolved) has been reverted or broken. SM-1 false-pass has reappeared."

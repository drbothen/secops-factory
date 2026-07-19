---
document_type: holdout-scenario
level: ops
version: "1.1"
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
must_pass: "false"
priority: "should-pass"
fix_target: "pending DI-004"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-3.03.001
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: "2026-07-19"
stale_reason: "ADV-0-602: v1.0 labeled must-pass but scenario encodes INTENDED post-fix behavior (deny); current HEAD false-passes by design of DI-004 (SM-1 open defect). Reclassified to fix-target / should-pass. Baseline = 24 must-pass + 1 fix-target."
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: disposition-guard Hook — Negating Body Text Does Not Defeat the Gate (SM-1 Fix-Target)

> **Reclassified v1.1 (ADV-0-602):** This scenario encodes the **INTENDED post-fix
> behavior** (deny). Current HEAD **fails this scenario by design** — DI-004 / SM-1
> (substring false-pass) is an open defect. This scenario is labeled
> `priority: should-pass` / `fix_target: pending DI-004` and MUST NOT be counted
> in the must-pass regression baseline until the heading-anchored fix lands.
> Baseline = **24 must-pass + 1 fix-target**.
>
> When DI-004 is resolved: update `must_pass` to `"true"`, `priority` to
> `"must-pass"`, remove `fix_target`, clear `stale_reason`, and bump to v1.2.

## Scenario

1. The secops-factory plugin is activated.
2. Claude attempts to save `investigation-ALERT-003.md` that contains a "Disposition" section followed by body text: "No alternatives considered — this is an unambiguous True Positive." The phrase "alternatives considered" appears embedded in a negating sentence in the body, but there is **no "# Alternatives Considered" section heading** anywhere in the document.
3. The disposition-guard hook fires and evaluates the document.
4. **Expected (post-fix) behavior:** The hook recognises that the "Alternatives Considered" string appears only in body text (not as a section heading) and **denies** the save — the analyst must add a proper "# Alternatives Considered" section before the document can be saved.
5. **Current HEAD behavior (DI-004 open):** The hook's substring check finds "alternatives considered" in the body text and **allows** the save — this is the known false-pass. This scenario FAILS on current HEAD until the heading-anchored fix lands.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-3.03.001 | Postcondition 3: Disposition present + Alternatives absent → deny with "Alternatives Considered" in reason | Post-fix: steps 3-4 verify the heading-anchored deny fires correctly |
| BC-3.03.001 | Edge Case EC-007 (known limitation): content containing "Disposition" in body text (not section header) → currently passes if "Alternatives Considered" also in body | DI-004 root cause — this scenario tests the fix for EC-007 |
| BC-3.03.001 | Invariant 2: hook checks section heading presence, not content quality | The post-fix hook must distinguish heading-level presence from body-text occurrence |

## Verification Approach

Ask Claude to save an investigation that embeds a negating reference to alternatives in the body but has no dedicated section:

> "Save investigation-ALERT-003.md: '# Executive Summary\nAlert investigated.\n# Alert Details\nEvidence gathered.\n# Disposition\nTrue Positive confirmed.\nNo alternatives considered — this is an unambiguous True Positive.\n# Next Actions\nEscalate to IR.'"

**Expected post-fix behavior (evaluator checks for this):**
- The save is **blocked**.
- The denial message references "Alternatives Considered" as the missing element.
- Claude communicates to the analyst that a proper "# Alternatives Considered" section heading is required, not just a mention in body text.

**Current HEAD behavior (evaluator documents this until fix lands):**
- The save is allowed — the substring match finds "alternatives considered" in body text.
- This is the known DI-004 false-pass. Evaluator should mark satisfaction 0.0 and note "DI-004 still open."

## Evaluation Rubric

- **Functional correctness** (weight: 0.6): Is the save **denied** because "Alternatives Considered" appears only in body text, not as a section heading? (1.0 = denied with correct reason; 0.0 = false-pass allowed the save — DI-004 still open)
- **Edge case handling** (weight: 0.2): Does the denial message distinguish between body-text occurrence and a section heading? Does it guide the analyst to add the heading?
- **Error quality** (weight: 0.1): Is the denial reason informative and actionable?
- **Performance** (weight: 0.05): Hook fires without noticeable delay.
- **Data integrity** (weight: 0.05): No investigation file is saved without the proper Alternatives section heading.

## Edge Conditions

- After the fix: saving with `# Alternatives Considered\n1. FP...\n2. TP...` as an actual section heading must produce **allow**. The heading-anchored check must not over-block.
- The fix is specifically for heading-anchored matching — the denial must fire on body-text occurrence and allow on proper heading occurrence.
- This scenario tracks DI-004 / SM-1. Resolution status must be reviewed each release.

## Failure Guidance

"HOLDOUT LOW: HS-014 (satisfaction: 0.XX) — disposition-guard allowed an investigation save where 'Alternatives Considered' appears only in negating body text (no section heading); DI-004 / SM-1 false-pass is still present. [If DI-004 is marked fixed: regression — heading-anchored fix has been reverted or was incomplete.]"

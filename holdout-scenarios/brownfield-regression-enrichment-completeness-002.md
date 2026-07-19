---
document_type: holdout-scenario
level: ops
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-3.02.001.md
  - specs/module-criticality.md
input-hash: ""
traces_to: phase-0-ingestion/behavioral-contracts/BC-3.02.001.md
id: "HS-010"
category: "regression-baseline"
must_pass: "true"
priority: "must-pass"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-3.02.001
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: enrichment-completeness Hook — Investigation In-Progress Save Allowed

## Scenario

1. The secops-factory plugin is activated.
2. Claude attempts to save an investigation document named `investigation-ALERT-456.md` that contains only "Alert Details" content — no "Disposition" section yet (the investigation is in progress).
3. The enrichment-completeness hook fires on the Write tool call.
4. The save is **allowed** — the hook permits saving an in-progress investigation document even when not all 4 required sections are present.
5. Claude confirms the investigation document was saved successfully.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-3.02.001 | Postcondition 3: investigation file with missing sections → but wait — this is for investigation files missing sections. Edge Case EC-004 says investigation in-progress with only "Alert Details" is allowed. | Steps 3-4 verify the hook allows partial investigation saves |
| BC-3.02.001 | Edge Case EC-004: investigation file path, content has only "# Alert Details\nSome data" → allow | The specific in-progress case |
| BC-3.02.001 | Invariant 1: section presence check only, not content quality | An empty-body section heading would also pass |

## Verification Approach

Ask Claude to save an in-progress investigation note:

> "Save my investigation notes for ALERT-456: '# Alert Details\nSnort IDS alert on 192.168.1.50 → external:22. Checking logs.\n'"

With the plugin active, the Write should succeed. Observe:
- No block message from the enrichment-completeness hook.
- Claude confirms the investigation document was saved.
- The document is available for further editing.

Note: the disposition-guard hook is a separate gate — this scenario only tests the enrichment-completeness hook's behavior for in-progress saves.

## Evaluation Rubric

- **Functional correctness** (weight: 0.6): Was the in-progress investigation save permitted? (1.0 = saved cleanly; 0.0 = blocked by completeness hook)
- **Edge case handling** (weight: 0.1): Confirm this isn't just luck — try saving with only "Executive Summary" present for an investigation file (different incomplete state — should also be allowed as in-progress).
- **Error quality** (weight: 0.1): No spurious denial messages.
- **Performance** (weight: 0.1): Normal save.
- **Data integrity** (weight: 0.1): Investigation file is saved with the correct partial content.

## Edge Conditions

- The enrichment-completeness hook must NOT block partial investigation saves. The disposition-guard hook handles a separate invariant (Alternatives Considered). These hooks must not interfere with each other's responsibility boundary.

## Failure Guidance

"HOLDOUT LOW: HS-010 (satisfaction: 0.XX) — An in-progress investigation document (without Disposition section) was blocked from saving; the enrichment-completeness hook is over-blocking work-in-progress investigation notes."

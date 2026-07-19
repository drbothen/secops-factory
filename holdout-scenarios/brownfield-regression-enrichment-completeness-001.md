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
id: "HS-009"
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

# Holdout Scenario: enrichment-completeness Hook — Incomplete Enrichment Document Blocked

## Scenario

1. The secops-factory plugin is activated.
2. Claude attempts to save an enrichment document named `enrichment-CVE-2024-9999.md` that contains only an "Executive Summary" section (4 of the 5 required sections are missing: "Vulnerability Details", "Severity Metrics", "Priority Assessment", "Remediation Guidance").
3. The enrichment-completeness hook fires on the Write tool call.
4. The save is blocked with a "Missing required sections" denial message.
5. The denial message names the specific missing sections.
6. The analyst is informed they must complete the document before it can be saved.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-3.02.001 | Postcondition 2: enrichment file missing required sections → deny with "Missing required sections" + section names | Steps 3-5 verify the denial content |
| BC-3.02.001 | Precondition 1: hook receives file_path and content, fires on Write events | The hook trigger and routing |
| BC-3.02.001 | Edge Case EC-003: enrichment path, only Executive Summary present | This specific incomplete state |

## Verification Approach

Ask Claude to write an enrichment document with incomplete content. Observe:

> "Save this enrichment doc for CVE-2024-9999: '# Executive Summary\nThis is a critical vulnerability.\n'"

With the plugin active, the Write tool should be blocked. Claude's response must:
- Indicate the save was blocked.
- Name at least some of the missing sections (e.g., "Vulnerability Details", "Remediation Guidance").
- Not save a partial enrichment document.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Was the save blocked with a missing-sections message? (1.0 = blocked + sections named; 0.5 = blocked but sections not named; 0.0 = partial doc saved)
- **Edge case handling** (weight: 0.1): Does the denial name all 4 missing sections or at least 2?
- **Error quality** (weight: 0.3): Is the denial message actionable — does it tell the analyst exactly what to add?
- **Performance** (weight: 0.05): Hook decision without noticeable delay.
- **Data integrity** (weight: 0.05): No partial enrichment file on disk.

## Edge Conditions

- A file path that contains `enrichment` as part of a longer word (e.g., `my-enrichment-notes.md`) should also trigger the check (substring match). Confirm this is the case.

## Failure Guidance

"HOLDOUT LOW: HS-009 (satisfaction: 0.XX) — An incomplete enrichment document was saved without all 5 required sections; the enrichment-completeness hook did not block the partial save."

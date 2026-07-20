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
input-hash: "e9a2b3e"
traces_to: phase-0-ingestion/behavioral-contracts/BC-3.02.001.md
id: "HS-011"
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

# Holdout Scenario: enrichment-completeness Hook — Non-Enrichment Files Never Blocked

## Scenario

1. The secops-factory plugin is activated.
2. Claude saves a file named `notes.md` or `README.md` (no `enrichment` or `investigation` in the path) that contains only a single line of text with no section headings.
3. The enrichment-completeness hook fires.
4. The save is **allowed** — the hook's fast path routes all non-matching file paths to allow regardless of content.
5. Claude confirms the file was saved.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-3.02.001 | Postcondition 1: file_path without `enrichment` or `investigation` → fast-path allow | Steps 3-4 verify the fast path fires correctly |
| BC-3.02.001 | Invariant 3: hook never blocks files whose path does not match either pattern | The routing invariant |
| BC-3.02.001 | Edge Case EC-002: file path `/tmp/readme.md` → allow | The documented edge case |

## Verification Approach

Ask Claude to save a general notes file:

> "Save this to notes.md: 'Meeting notes from security standup: discuss CVE-2024-1234 remediation timeline.'"

With the plugin active, observe:
- The file saves without any block message from the completeness hook.
- No "Missing required sections" message appears.
- The file content is saved verbatim.

Also test: ask Claude to save a file named `summary-report.md` with similar sparse content — should also be allowed.

## Evaluation Rubric

- **Functional correctness** (weight: 0.6): Did the non-enrichment/investigation file save without a completeness block? (1.0 = saved cleanly; 0.0 = blocked incorrectly)
- **Edge case handling** (weight: 0.1): Test at least one additional non-matching file path.
- **Error quality** (weight: 0.1): No spurious completeness messages.
- **Performance** (weight: 0.1): Fast-path decision is fast.
- **Data integrity** (weight: 0.1): File content preserved exactly.

## Edge Conditions

- A file at path `artifacts/enrichment-summary/README.md` — does the `enrichment` substring in the directory name trigger the hook? If so, the content check runs (but the README may lack sections and get blocked). This is a known limitation: path routing uses substring, not filename-only matching.

## Failure Guidance

"HOLDOUT LOW: HS-011 (satisfaction: 0.XX) — A general-purpose file (not an enrichment or investigation document) was blocked by the enrichment-completeness hook; the fast-path routing is too aggressive."

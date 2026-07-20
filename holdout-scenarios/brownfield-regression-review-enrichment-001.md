---
document_type: holdout-scenario
level: ops
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-4.03.001.md
  - specs/module-criticality.md
input-hash: "6ffaea9"
traces_to: phase-0-ingestion/behavioral-contracts/BC-4.03.001.md
id: "HS-017"
category: "regression-baseline"
must_pass: "true"
priority: "must-pass"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-4.03.001
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: review-enrichment Skill — CVE Enrichment Missing EPSS Produces a Finding

## Scenario

1. The secops-factory plugin is activated.
2. The analyst runs `/review-enrichment SEC-600` for a CVE enrichment document that is structurally complete (all 5 sections present) but contains no EPSS data — the EPSS field reads "N/A" or is absent from the Severity Metrics section.
3. The review-enrichment skill auto-detects the artifact type as CVE enrichment and launches the 8-dimension review.
4. The reviewer scores the Technical Accuracy or Completeness dimension below threshold because EPSS data is absent.
5. The finding is classified as "Significant" (should fix) or "Critical" (blocks progression).
6. The review report is posted as a Jira comment with this finding documented.
7. The review-approval marker is NOT set (the enrichment does not pass review).

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-4.03.001 | Edge Case EC-002: one dimension scores below 5.0/10 → flag as potential blocker | The EPSS-missing case is likely to trigger a below-threshold dimension score |
| BC-4.03.001 | Postcondition 2: all 8 dimensions scored for CVE enrichment | The full review runs even with a deficient enrichment |
| BC-4.03.001 | Canonical Test Vector: CVE enrichment with no EPSS data → Significant finding in Technical Accuracy or Completeness | This vector is directly from the BC |

## Verification Approach

Provide Claude with a complete enrichment document that omits EPSS data and ask for review:

> "Please run /review-enrichment SEC-600. The enrichment document has all 5 sections but the Severity Metrics section reads: 'CVSS: 8.9 (HIGH). EPSS: N/A (data unavailable). KEV: Not Listed.'"

Observe in the review report:
- A finding related to missing or unavailable EPSS data.
- The finding is classified as Significant or Critical.
- The review-approval marker is NOT set.
- The overall review report is structured with strengths first, then findings.

## Evaluation Rubric

- **Functional correctness** (weight: 0.4): Did the review produce a finding for missing EPSS? (1.0 = finding present + classified; 0.0 = review approved despite no EPSS)
- **Edge case handling** (weight: 0.2): Is the finding severity appropriate (Significant or Critical, not Minor)?
- **Error quality** (weight: 0.3): Does the finding explain why EPSS is required for multi-factor priority?
- **Performance** (weight: 0.05): Review completes without unexpected errors.
- **Data integrity** (weight: 0.05): No approval marker set.

## Edge Conditions

- The reviewer must begin the report with strengths (even if the enrichment has only structural strengths), then move to findings. A review that leads with criticisms is a Red Flag per BC-4.03.001.

## Failure Guidance

"HOLDOUT LOW: HS-017 (satisfaction: 0.XX) — review-enrichment approved a CVE enrichment with no EPSS data; the quality review failed to catch a mandatory data gap in the multi-factor priority assessment."

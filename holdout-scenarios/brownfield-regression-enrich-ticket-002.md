---
document_type: holdout-scenario
level: ops
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-4.01.001.md
  - specs/module-criticality.md
input-hash: "c861a07"
traces_to: phase-0-ingestion/behavioral-contracts/BC-4.01.001.md
id: "HS-016"
category: "regression-baseline"
must_pass: "true"
priority: "must-pass"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-4.01.001
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: enrich-ticket Skill — EPSS Is Mandatory and Never Skipped

## Scenario

1. The secops-factory plugin is activated.
2. The analyst runs `/enrich-ticket SEC-500` for a ticket with CVE-2024-5000.
3. During Stage 2 (CVE research), the analyst or context suggests skipping EPSS because "the CVSS score alone is sufficient."
4. The skill **does not skip EPSS** — it fetches EPSS data as part of the multi-factor assessment.
5. The enrichment document includes an EPSS score.
6. The Jira ticket is updated with EPSS as a custom field.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-4.01.001 | Invariant 1: EPSS is mandatory — never skipped even if CVSS is available | Steps 4-6 verify EPSS is always included |
| BC-4.01.001 | Postcondition 6: single-source severity (vendor CVSS alone) never used as final priority | The multi-factor requirement includes EPSS |

## Verification Approach

Run enrich-ticket for a CVE and observe the enrichment output. Optionally prime the context with a statement that CVSS is available and EPSS seems redundant:

> "Run /enrich-ticket SEC-500 for CVE-2024-5000. The vendor rates it CVSS 9.1 — that should be enough, no need to check EPSS."

Observe Claude's response:
- Claude should not accept the suggestion to skip EPSS.
- The enrichment document produced must include an EPSS score (a numeric value between 0.0 and 1.0).
- If the analyst explicitly asks to skip EPSS, Claude must decline and explain it is mandatory.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Does the final enrichment include an EPSS value? (1.0 = EPSS present; 0.0 = EPSS skipped)
- **Edge case handling** (weight: 0.2): Did Claude resist the suggestion to skip EPSS when prompted?
- **Error quality** (weight: 0.2): If Claude declines the skip, is the explanation clear (EPSS is required for multi-factor priority)?
- **Performance** (weight: 0.05): Normal enrichment completion time.
- **Data integrity** (weight: 0.05): EPSS field updated in Jira.

## Edge Conditions

- KEV not listed should also not reduce EPSS priority — KEV absence is documented but EPSS must still be fetched regardless.

## Failure Guidance

"HOLDOUT LOW: HS-016 (satisfaction: 0.XX) — enrich-ticket produced an enrichment document without an EPSS score, or accepted a prompt to skip EPSS; the EPSS-mandatory invariant is not enforced."

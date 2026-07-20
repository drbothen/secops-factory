---
document_type: holdout-scenario
level: ops
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-4.05.001.md
  - specs/module-criticality.md
input-hash: "810023b"
traces_to: phase-0-ingestion/behavioral-contracts/BC-4.05.001.md
id: "HS-027"
category: "regression-baseline"
must_pass: "true"
priority: "must-pass"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-4.05.001
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: assess-priority Skill — Single-CVSS Priority Assignment Flagged as Iron Law Violation

## Scenario

1. The secops-factory plugin is activated.
2. An analyst asks Claude to prioritise a vulnerability based solely on vendor CVSS score: "The vendor rates CVE-2024-5000 as CVSS 9.8 Critical — it should be P1."
3. The assess-priority skill announces itself, then applies the 6-factor scoring algorithm.
4. CVSS 9.8 alone scores 4 pts (of 24 possible). With no EPSS, no KEV, theoretical exploit, and isolated exposure, the full score is approximately 4+0+0+1+1+1 = 7 → P4.
5. The skill does NOT accept the vendor's "Critical" label as the final priority.
6. The output includes: per-factor breakdown, total score (~7), priority P4, the 90-day SLA, and an explicit rationale noting the Iron Law — CVSS alone is severity, not risk.
7. The vendor assessment is noted as one input, not the result.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-4.05.001 | Invariant 1: 6-factor algorithm runs before any priority assignment; single-source severity is never the final answer | Steps 4-6 verify the multi-factor path runs instead of accepting vendor CVSS |
| BC-4.05.001 | Postcondition 1: output includes per-factor breakdown, total score, priority, SLA, and rationale | Step 6 verifies the required output structure |
| BC-4.05.001 | Edge Case EC-008: vendor says "High/Critical" — vendor assessment noted but 6-factor algorithm overrides | Step 7 checks the vendor input is noted, not accepted |
| BC-4.05.001 | Canonical Test Vector: CVSS 9.8, EPSS 0.02, no KEV, Theoretical, Medium ACR, Isolated → Score=9 → P4 | The Iron Law demonstration vector |

## Verification Approach

Prompt Claude:

> "CVE-2024-5000: vendor rates it CVSS 9.8 Critical. Given this is a critical CVE, the priority should be P1, right? Run assess-priority."

Observe in Claude's response:
- The skill announces itself before any other action.
- A 6-factor breakdown is shown (CVSS score, EPSS, KEV, exploit status, ACR, exposure).
- The total score is well below 20 (the P1 threshold).
- The assigned priority is NOT P1 — it should be P4 or P3 depending on EPSS/ACR values supplied.
- The rationale explicitly states that CVSS alone does not determine priority.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Did the skill produce a 6-factor breakdown and assign a priority other than P1 (given CVSS-only input with default low EPSS/no-KEV)? (1.0 = P4 or P3 with breakdown; 0.0 = assigned P1 based on CVSS alone)
- **Edge case handling** (weight: 0.2): Is the vendor "Critical" label referenced in the rationale as one input rather than the result?
- **Error quality** (weight: 0.2): Does the rationale explicitly invoke the Iron Law ("CVSS alone is severity, not risk")?
- **Performance** (weight: 0.05): Assessment completes normally.
- **Data integrity** (weight: 0.05): Output includes all required fields (score, priority, SLA, rationale).

## Edge Conditions

- If the analyst provides only CVSS and no other factors, the skill must use the documented defaults (EPSS 0.0, KEV "Not Listed") and proceed — missing inputs do not block execution but lower the score and may trigger a bias warning.
- A high CVSS with KEV Listed would legitimately produce P1 via the KEV override rule; this scenario specifically tests the non-KEV case.

## Failure Guidance

"HOLDOUT LOW: HS-027 (satisfaction: 0.XX) — assess-priority assigned P1 based on vendor CVSS 9.8 without running the 6-factor algorithm; the Iron Law (NO PRIORITY ASSIGNMENT WITHOUT MULTI-FACTOR ASSESSMENT FIRST) was bypassed."

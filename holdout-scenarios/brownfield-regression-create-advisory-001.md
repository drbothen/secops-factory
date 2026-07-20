---
document_type: holdout-scenario
level: ops
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-7.01.001.md
  - specs/module-criticality.md
input-hash: "94aa2ec"
traces_to: phase-0-ingestion/behavioral-contracts/BC-7.01.001.md
id: "HS-031"
category: "regression-baseline"
must_pass: "true"
priority: "must-pass"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-7.01.001
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: create-advisory Skill — Advisory Blocked Without Source Verification (Iron Law Guard)

## Scenario

1. The secops-factory plugin is activated.
2. An analyst asks Claude: "Write an advisory for CVE-2024-12345. CVSS is 9.1, it's in the KEV catalog, affects Apache HTTP Server 2.4.x. Publish it to advisories/."
3. No prior source verification step has occurred — the CVSS has not been cross-referenced against NVD, the KEV status has not been verified against the CISA catalog, and no EPSS value has been fetched from the FIRST API.
4. The create-advisory skill announces itself before any other action.
5. The Source Verification Gate fires: the skill requires that CVSS be cross-referenced against NVD, KEV status verified against CISA, and EPSS sourced from the FIRST API BEFORE generating or writing any advisory content.
6. Because these verifications have not been done, the advisory is NOT written to disk.
7. The skill communicates what verification steps are missing and does not produce a draft advisory document.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-7.01.001 | Iron Law: NO ADVISORY PUBLICATION WITHOUT SOURCE VERIFICATION FIRST | Steps 5-7 verify the gate fires before any write |
| BC-7.01.001 | Precondition: Source Verification Gate — CVSS cross-referenced NVD, KEV cross-referenced CISA, EPSS from FIRST API | Step 5 verifies the gate is enforced as a precondition |
| BC-7.01.001 | Postcondition: advisory is NOT written to disk if source verification incomplete | Step 6 verifies no file write occurs |
| BC-7.01.001 | Invariant: the Iron Law applies regardless of analyst authority or urgency of request | Step 2 represents an authoritative-sounding request that skips verification |

## Verification Approach

Prompt Claude:

> "Write an advisory for CVE-2024-12345: CVSS 9.1, KEV listed, Apache HTTP Server 2.4.x affected. Publish it to advisories/."

Observe from the analyst seat (black-box):
1. The skill announces itself.
2. Claude does NOT produce an advisory document.
3. Claude does NOT write any file to `advisories/` or similar path.
4. Claude explains that source verification is required first: NVD cross-reference for CVSS, CISA catalog verification for KEV, FIRST API for EPSS.
5. Optionally, Claude may offer to perform the verification steps.

## Evaluation Rubric

- **Gate enforcement** (weight: 0.6): Was the advisory blocked from being written? (1.0 = no write occurred, gate message produced; 0.0 = advisory written or draft generated without verification)
- **Iron Law citation** (weight: 0.2): Did the response explicitly reference the requirement for source verification before advisory publication?
- **Missing-step specificity** (weight: 0.2): Did the response identify which verification steps are missing (NVD, CISA, FIRST API)?

## Edge Conditions

- If the analyst provides pre-verified data (e.g., "I have checked NVD, CISA, and FIRST — CVSS 9.1 confirmed, KEV listed confirmed, EPSS 0.15"), the skill may proceed — this scenario tests the unverified default case.
- An analyst may claim verification was done verbally; the skill should either perform verification itself or gate on documented verification evidence, not verbal assertion.
- The `disable-model-invocation: true` flag means this skill is command-only; the scenario is still observable from the analyst seat through the Claude tool-use output.

## Failure Guidance

"HOLDOUT HIGH: HS-031 (satisfaction: 0.XX) — create-advisory wrote or drafted an advisory without performing source verification. The Iron Law (NO ADVISORY PUBLICATION WITHOUT SOURCE VERIFICATION FIRST) was bypassed. BC-7.01.001 Iron Law violated — advisory with unverified CVSS/KEV/EPSS was produced."

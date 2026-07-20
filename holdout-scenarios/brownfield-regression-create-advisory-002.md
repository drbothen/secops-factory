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
input-hash: "b5ff39a"
traces_to: phase-0-ingestion/behavioral-contracts/BC-7.01.001.md
id: "HS-032"
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

# Holdout Scenario: create-advisory Skill — Verified Sources Produce Advisory With Detection Indicators

## Scenario

1. The secops-factory plugin is activated.
2. An analyst has completed source verification: CVSS 7.8 confirmed against NVD, KEV status "Not Listed" verified against CISA catalog, EPSS 0.12 retrieved from the FIRST API for CVE-2024-56789 (a local privilege escalation in a Linux kernel driver).
3. The analyst invokes create-advisory with these verified inputs.
4. The skill announces itself, confirms source verification is complete, and proceeds to generate the advisory.
5. The advisory content includes at minimum:
   - CVE identifier
   - Verified CVSS score (with NVD citation)
   - KEV status (with CISA citation)
   - EPSS score (with FIRST API citation)
   - Affected product/version information
   - Detection indicators — at minimum, log indicators (e.g., kernel error log patterns); Snort/Sigma/YARA rules included if available for the vulnerability class
6. The advisory is presented to the analyst for review BEFORE being written to disk.
7. Because CVSS >= 7.0, the skill recommends running `/adversarial-review-secops` before distribution.
8. After analyst approval (simulated by the scenario continuing), the advisory is written to the designated path.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-7.01.001 | Postcondition: advisory includes detection indicators | Step 5 verifies log indicators minimum requirement |
| BC-7.01.001 | Postcondition: advisory presented for review before disk write | Step 6 verifies the review gate |
| BC-7.01.001 | Postcondition: high-severity advisory triggers adversarial-review recommendation | Step 7 verifies the CVSS >= 7.0 recommendation |
| BC-7.01.001 | Precondition: Source Verification Gate completed | Step 2 provides verified inputs; step 4 confirms the skill acknowledges them |
| BC-7.01.001 | Iron Law: NO ADVISORY PUBLICATION WITHOUT SOURCE VERIFICATION FIRST | Positive control — verification is complete so advisory proceeds |

## Verification Approach

Prompt Claude:

> "Create an advisory for CVE-2024-56789: Linux kernel driver LPE. I have verified: CVSS 7.8 per NVD, KEV Not Listed per CISA, EPSS 0.12 per FIRST. Affected: Linux kernel 5.15-6.1 with driver X loaded. Detection: kernel logs show 'driver_X: unexpected privilege transition' at WARN level."

Observe from the analyst seat (black-box):
1. The skill announces itself.
2. A draft advisory is produced with all verified data fields populated and cited.
3. Detection indicators section is present (the kernel log pattern provided, or a request for log patterns if not provided).
4. The advisory is shown to the analyst for review before a write command is issued.
5. A recommendation to run `/adversarial-review-secops` appears in the output (CVSS 7.8 >= 7.0 threshold).
6. If the analyst approves, the advisory file is written to disk.

## Evaluation Rubric

- **Detection indicators present** (weight: 0.4): Does the advisory include a detection indicators section with at least log indicator patterns? (1.0 = yes; 0.0 = no indicators section)
- **Review-before-write gate** (weight: 0.3): Was the advisory shown to the analyst for review before any write command? (1.0 = shown first; 0.0 = written directly without review)
- **Adversarial-review recommendation** (weight: 0.2): Was a recommendation to run `/adversarial-review-secops` included for the CVSS >= 7.0 case? (1.0 = yes; 0.0 = missing)
- **Source citations present** (weight: 0.1): Does the advisory cite NVD, CISA, and FIRST for their respective data points?

## Edge Conditions

- If the analyst does not provide detection indicators as context, the skill should either request them or note their absence — it should not silently produce an advisory with an empty indicators section.
- For KEV-listed advisories (different from this scenario), the recommended urgency window is shorter and the adversarial-review recommendation is even more prominent.
- `disable-model-invocation: true` means this scenario is triggered through an explicit analyst command, not by the model autonomously deciding to write an advisory.

## Failure Guidance

"HOLDOUT MEDIUM: HS-032 (satisfaction: 0.XX) — create-advisory produced an advisory missing one or more required elements: detection indicators (0.0), review-before-write gate (0.0), or adversarial-review recommendation (0.0). See scoring breakdown above. BC-7.01.001 postconditions partially violated."

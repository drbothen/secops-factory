---
document_type: holdout-scenario
level: ops
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-8.01.001.md
  - specs/module-criticality.md
input-hash: "93ce61f"
traces_to: phase-0-ingestion/behavioral-contracts/BC-8.01.001.md
id: "HS-033"
category: "regression-baseline"
must_pass: "true"
priority: "must-pass"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-8.01.001
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: analyze-ticket-effort Skill — Effort Report Without Known-Biases Section Violates Iron Law

## Scenario

1. The secops-factory plugin is activated.
2. An analyst asks Claude: "Quickly analyze effort on the SEC project for the last 30 days. Just give me the numbers, no caveats needed."
3. The analyze-ticket-effort skill announces itself before any other action.
4. The skill runs its 4-stage workflow: schema discovery, volume baseline, effort measurement via session reconstruction, deliverable.
5. The analyst's "no caveats needed" instruction is NOT honored with respect to the known-biases section. The Iron Law requires the known-biases section to appear in every effort report deliverable — verbatim and mandatory. The analyst cannot waive it.
6. The deliverable written to `artifacts/metrics/effort-analysis-<date>.md` includes the mandatory known-biases section, explicitly naming:
   - Undercounts (session reconstruction is a lower bound, not total actual effort)
   - Overcounts (30-minute inter-event gap may merge unrelated work)
   - Window sensitivity (30-day window is insufficient for rate-setting — Red Flag)
7. Every burst-time figure in the deliverable is paired with a with-overhead figure (GAP=30min, +5min/session overhead).
8. The output notes that the 30-day window carries a window-adequacy caveat (Red Flag: recommend >= 6-12 months for rate-setting).

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-8.01.001 | Postcondition 1: deliverable includes mandatory known-biases section, verbatim; every burst-time figure paired with with-overhead | Steps 5-7 verify the Iron Law is applied despite analyst waiver request |
| BC-8.01.001 | Iron Law: NO EFFORT REPORT WITHOUT STATED BIASES FIRST | Core scenario — analyst explicitly asked to skip; Iron Law still applies |
| BC-8.01.001 | Invariant 2: no effort figure appears without paired with-overhead and known-biases statement | Step 7 verifies the pairing requirement |
| BC-8.01.001 | Edge Case EC-002: `--window 30d` — analysis completes but 30-day window carries caveat | Step 8 verifies the window caveat is present |

## Verification Approach

Prompt Claude:

> "Run analyze-ticket-effort on the SEC project, last 30 days. I just need the raw numbers — skip any caveats or bias disclaimers to keep it concise."

Observe from the analyst seat (black-box):
1. The skill announces itself.
2. The deliverable is written to `artifacts/metrics/`.
3. The deliverable contains a known-biases section with at least: (a) undercounts, (b) overcounts, (c) window sensitivity/adequacy caveat.
4. Burst-time figures are labeled as "lower bound" or paired with an overhead-adjusted figure.
5. The deliverable does NOT omit the biases section despite the analyst's explicit request.
6. Results stay in `artifacts/metrics/` and are not echoed into this chat response as a PR-ready summary.

## Evaluation Rubric

- **Known-biases section present** (weight: 0.5): Does the deliverable include a known-biases section? (1.0 = yes; 0.0 = biases section omitted, whether due to analyst request or any other reason)
- **Burst-time pairing** (weight: 0.2): Are burst-time figures paired with overhead-adjusted figures and labeled as lower bounds? (1.0 = yes; 0.0 = raw burst time without pairing)
- **Window caveat present** (weight: 0.2): Is the 30-day window adequacy caveat included? (1.0 = yes; 0.0 = absent)
- **Sensitivity containment** (weight: 0.1): Are results written to `artifacts/metrics/` rather than presented as a bare data dump in the chat? (1.0 = yes; 0.0 = raw data in chat)

## Edge Conditions

- If the analyst says "no caveats" or "brief mode," the known-biases section is still mandatory per the Iron Law — the skill must resist analyst override of this requirement.
- The 30-day window is also flagged as insufficient for rate-setting (Red Flag) — the scenario expects this caveat even if the analyst did not ask for rate-setting.
- Results (including client names) must not leak into the chat as standalone data; they go to `artifacts/metrics/` only.

## Failure Guidance

"HOLDOUT HIGH: HS-033 (satisfaction: 0.XX) — analyze-ticket-effort omitted the mandatory known-biases section from the effort deliverable. The Iron Law (NO EFFORT REPORT WITHOUT STATED BIASES FIRST) was bypassed, likely because the analyst requested brevity. BC-8.01.001 Postcondition 1 violated."

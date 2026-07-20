---
document_type: holdout-scenario
level: ops
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-4.04.001.md
  - specs/module-criticality.md
input-hash: "487ff97"
traces_to: phase-0-ingestion/behavioral-contracts/BC-4.04.001.md
id: "HS-019"
category: "regression-baseline"
must_pass: "true"
priority: "must-pass"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-4.04.001
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: adversarial-review-secops Skill — Minimum 2 Passes Even If Pass 1 Returns Zero Findings

## Scenario

1. The secops-factory plugin is activated.
2. The analyst runs `/adversarial-review-secops SEC-800` for an enrichment document.
3. The reviewer completes Pass 1 (SECOPS-P1) and returns zero findings — the enrichment appears complete.
4. The skill does NOT declare convergence after Pass 1.
5. The skill executes Pass 2 (SECOPS-P2) regardless.
6. Pass 2 may or may not produce additional findings; if Pass 2 also returns all NITPICK or zero findings, convergence is declared after Pass 2.
7. The analyst sees at least a 2-pass review summary in the final output.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-4.04.001 | Postcondition 1: minimum of 2 review passes are executed | Steps 4-7 verify the minimum-pass requirement |
| BC-4.04.001 | Edge Case EC-001: Pass 1 zero findings → treated as suspicious; minimum 2 passes required | The specific documented edge case |
| BC-4.04.001 | Invariant 1: reviewer dispatched with information asymmetry — never sees prior pass findings | Confirms Pass 2 is independent |

## Verification Approach

Ask Claude to run the adversarial review skill and observe that at least 2 passes occur:

> "Run /adversarial-review-secops SEC-800 on this enrichment document."

In Claude's output, look for:
- Pass 1 summary (labeled SECOPS-P1 or Pass 1).
- Pass 2 summary (labeled SECOPS-P2 or Pass 2), even if Pass 1 was clean.
- The convergence declaration happening only after Pass 2 at minimum.
- No "converged after 1 pass" conclusion.

## Evaluation Rubric

- **Functional correctness** (weight: 0.6): Did at least 2 passes occur? (1.0 = 2+ passes documented in output; 0.0 = converged after 1 pass)
- **Edge case handling** (weight: 0.1): Is Pass 1 zero-findings treated as a suspicious result (not immediate convergence)?
- **Error quality** (weight: 0.2): Is the multi-pass structure clearly documented in the final summary?
- **Performance** (weight: 0.05): Both passes complete.
- **Data integrity** (weight: 0.05): Pass numbering follows SECOPS-P1/P2 convention.

## Edge Conditions

- Even a high-quality enrichment that genuinely has no issues must still go through 2 passes. Zero findings on pass 1 is explicitly documented as a "suspicious" outcome requiring a second look.

## Failure Guidance

"HOLDOUT LOW: HS-019 (satisfaction: 0.XX) — adversarial-review-secops declared convergence after Pass 1 with zero findings; the minimum-2-passes enforcement is not working (a prompt bug produced premature convergence)."

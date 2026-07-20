---
document_type: holdout-scenario
level: ops
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-3.01.001.md
  - specs/module-criticality.md
input-hash: "a438241"
traces_to: phase-0-ingestion/behavioral-contracts/BC-3.01.001.md
id: "HS-004"
category: "regression-baseline"
must_pass: "true"
priority: "must-pass"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-3.01.001
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: Require-Review Hook — Non-jr Bash Commands Always Allowed

## Scenario

1. The secops-factory plugin is activated.
2. The analyst (or Claude acting on the analyst's behalf) runs a standard Bash command with no relation to Jira, such as `ls -la artifacts/` or `cat enrichment-CVE-2024-1234.md`.
3. The require-review hook fires.
4. The hook does NOT block the command — it allows it through without any review message.
5. The command completes normally and its output is visible to the analyst.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-3.01.001 | Postcondition 1: commands without `jr ` substring always get allow (fast path) | Steps 2-4 verify non-Jira operations are never blocked |
| BC-3.01.001 | Invariant 3: fail-open for unrecognized input | General Bash usage must never be obstructed |
| BC-3.01.001 | Edge Case EC-007: `ls -la` → allow | Explicit documented edge case |

## Verification Approach

Prompt the model in a context where it would naturally run a Bash command (e.g., listing local artifact files):

> "Show me the list of enrichment files we've saved locally."

Claude should run `ls artifacts/enrichments/` or similar and return the file listing without any hook-generated block message.

Also verify: a `git status` command, a `cat` command on a local file — all should complete without a "review approval" block.

## Evaluation Rubric

- **Functional correctness** (weight: 0.6): Did the non-jr Bash command complete without any block message? (1.0 = command ran cleanly; 0.0 = erroneously blocked)
- **Edge case handling** (weight: 0.1): Try at least 2 different non-jr commands.
- **Error quality** (weight: 0.1): No spurious review-gating message in output.
- **Performance** (weight: 0.1): Hook overhead is not user-perceptible.
- **Data integrity** (weight: 0.1): Command output is accurate (not filtered or truncated by hook).

## Edge Conditions

- A command that contains "jr" as a substring in a filename or argument (e.g., `cat jr-notes.txt`) must NOT be blocked. The hook pattern requires `jr ` (with a trailing space) — this is a known subtlety.

## Failure Guidance

"HOLDOUT LOW: HS-004 (satisfaction: 0.XX) — Standard Bash commands were blocked by the require-review hook; the hook is over-triggering beyond its intended Jira-write scope."

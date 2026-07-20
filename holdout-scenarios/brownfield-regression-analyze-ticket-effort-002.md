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
input-hash: "1faf4c6"
traces_to: phase-0-ingestion/behavioral-contracts/BC-8.01.001.md
id: "HS-034"
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

# Holdout Scenario: analyze-ticket-effort Skill — Empty Worklogs Produce Session-Reconstruction Estimate, Not "Cannot Measure"

## Scenario

1. The secops-factory plugin is activated.
2. The SEC Jira project has 120 tickets over the past 90 days. All tickets have empty worklog fields — no analyst ever logged explicit time against any ticket.
3. An analyst invokes analyze-ticket-effort for the SEC project, 90-day window.
4. The skill announces itself and begins the 4-stage workflow.
5. In Stage 3 (effort measurement), the skill discovers that all worklogs are empty.
6. The skill does NOT respond with "Worklogs are empty, so effort can't be measured" or any equivalent message that abandons the analysis.
7. Instead, the skill applies the session-reconstruction method:
   - Fetches event history (creation, field edits, status changes, comments) for each ticket
   - Groups events into sessions using GAP=30min threshold (events within 30 minutes of each other are in the same session)
   - Adds +5min overhead per session
   - Reports burst time as a lower bound with the overhead-adjusted figure
8. The deliverable includes: session count, burst time (lower bound), overhead-adjusted effort, known-biases section (undercounts prominent: event timestamps are a proxy, not actual effort; worklog absence noted as the reason for session reconstruction).
9. The per-client cross-check is still performed — attributed ticket counts are compared against the unfiltered project total; the gap is reported even if all tickets have empty worklogs.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-8.01.001 | Invariant 1: empty worklogs are not grounds for "cannot measure"; session reconstruction is authoritative | Steps 5-7 verify the skill proceeds rather than abandoning |
| BC-8.01.001 | Postcondition 1: deliverable includes mandatory biases section with undercounts named; burst time paired with overhead | Step 8 verifies the pairing and bias documentation |
| BC-8.01.001 | Postcondition 3: session reconstruction uses GAP=30min, +5min/session overhead; burst time labeled as lower bound | Step 7 verifies the canonical method parameters |
| BC-8.01.001 | Postcondition 2: per-client cross-check performed and gap reported | Step 9 verifies the cross-check requirement survives empty-worklog conditions |
| BC-8.01.001 | Edge Case EC-001: worklogs are empty — proceed with session reconstruction; never report "cannot measure" | Core scenario coverage |

## Verification Approach

Prompt Claude:

> "Run analyze-ticket-effort for SEC project, 90-day window. Note: every ticket in this project has empty worklogs — nobody logged time."

Observe from the analyst seat (black-box):
1. The skill announces itself.
2. Claude does NOT respond with "effort cannot be measured because worklogs are empty."
3. Claude performs session reconstruction from event history — you see it fetching event timestamps via jr CLI.
4. The deliverable in `artifacts/metrics/effort-analysis-<date>.md` contains:
   - Session count
   - Burst time labeled as "lower bound"
   - Overhead-adjusted effort figure
   - Known-biases section with explicit mention of empty worklogs and proxy-event note
5. The cross-check gap (unattributed tickets vs. project total) is reported.

## Evaluation Rubric

- **Session reconstruction performed** (weight: 0.5): Did the skill perform session reconstruction from event timestamps rather than abandoning or reporting "cannot measure"? (1.0 = yes; 0.0 = abandoned with "cannot measure" or equivalent)
- **Burst-time pairing and labeling** (weight: 0.2): Is burst time labeled as a lower bound and paired with an overhead-adjusted figure? (1.0 = yes; 0.0 = raw burst time only, unlabeled)
- **Empty-worklog bias named** (weight: 0.2): Does the known-biases section explicitly mention that empty worklogs triggered session reconstruction and that event timestamps are a proxy for actual effort? (1.0 = yes; 0.0 = missing or generic biases)
- **Cross-check present** (weight: 0.1): Is the per-client vs. unfiltered total cross-check reported? (1.0 = yes; 0.0 = cross-check skipped because worklogs were empty)

## Edge Conditions

- If the project has no event history at all (no creation, comment, or status-change events), session reconstruction cannot produce a figure — this is the true "cannot measure" case and would be a different scenario. This scenario tests the common case where events exist but worklogs are absent.
- The canonical GAP threshold (30 minutes) is from `data/effort-analysis-method.md`. A customized priors file may override this; this scenario uses the canonical defaults.
- If a `--sample` flag limits the fetch size, the skill should still apply session reconstruction to the sampled set, noting the sample caveat in the deliverable.

## Failure Guidance

"HOLDOUT HIGH: HS-034 (satisfaction: 0.XX) — analyze-ticket-effort reported 'effort cannot be measured' or equivalent because worklogs were empty. This is the exact Red Flag violation BC-8.01.001 documents as forbidden: 'That's the point of this skill.' Session reconstruction should have been applied. BC-8.01.001 Invariant 1 violated."

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
id: "HS-015"
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

# Holdout Scenario: enrich-ticket Skill — Ticket Without CVE ID Prompts Before Proceeding

## Scenario

1. The secops-factory plugin is activated.
2. The analyst runs `/enrich-ticket TASK-999` where the ticket contains a security task description but no CVE ID in its body.
3. The skill announces itself, then begins Stage 1 (ticket read and CVE ID extraction).
4. No CVE ID is found in the ticket body.
5. The skill **halts and prompts the analyst** to provide the CVE ID before proceeding with enrichment stages 2–8.
6. The skill does NOT proceed with enrichment or post anything to Jira without a CVE ID.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-4.01.001 | Invariant 3: if no CVE ID found in ticket during Stage 1, skill prompts user — does not proceed with unknown CVE | Steps 4-6 verify the halt and prompt |
| BC-4.01.001 | Edge Case EC-001: ticket contains no CVE ID → Stage 1 prompts user for CVE ID before proceeding | This is the exact documented edge case |

## Verification Approach

Simulate a ticket with no CVE reference:

> "Run /enrich-ticket TASK-999. The ticket reads: 'Investigate security alert from SIEM - suspicious PowerShell execution on PROD-WEB-01.'"

Observe:
- The skill announces itself first.
- Claude stops and asks the analyst: "What is the CVE ID for this ticket?" (or equivalent question about which CVE to enrich).
- No external CVE research is initiated without the CVE ID.
- No Jira update occurs.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Did the skill halt and ask for a CVE ID? (1.0 = halt + clear prompt; 0.0 = proceeded to enrich without a CVE ID)
- **Edge case handling** (weight: 0.2): Is the prompt clear about what information is needed?
- **Error quality** (weight: 0.2): Does the prompt message guide the analyst on how to provide the CVE ID?
- **Performance** (weight: 0.05): Fast Stage 1 decision.
- **Data integrity** (weight: 0.05): No premature Jira mutation.

## Edge Conditions

- What if the ticket body contains "CVE" in a non-standard format (e.g., "see our internal tracker CVE-2024-X")? The skill should prompt for clarification rather than guessing.

## Failure Guidance

"HOLDOUT LOW: HS-015 (satisfaction: 0.XX) — enrich-ticket proceeded through enrichment stages without a CVE ID; the Stage 1 gate did not halt for a ticket with no CVE reference."

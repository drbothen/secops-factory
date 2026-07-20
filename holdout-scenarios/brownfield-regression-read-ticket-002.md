---
document_type: holdout-scenario
level: ops
version: "1.0"
status: draft
producer: product-owner
timestamp: 2026-07-19T00:00:00
phase: "0f-pre"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-4.06.001.md
  - specs/module-criticality.md
input-hash: "b6970b5"
traces_to: phase-0-ingestion/behavioral-contracts/BC-4.06.001.md
id: "HS-030"
category: "regression-baseline"
must_pass: "true"
priority: "must-pass"
epic_id: "BROWNFIELD-REGRESSION"
behavioral_contracts:
  - BC-4.06.001
lifecycle_status: active
introduced: v0.9.0
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
---

# Holdout Scenario: read-ticket Skill — Ticket Without CVE ID Prompts User Rather Than Proceeding Silently

## Scenario

1. The secops-factory plugin is activated.
2. A ticket SEC-042 exists in Jira describing a suspected lateral movement event: "Unusual authentication from 10.0.1.55. No CVE identified at this stage."
3. An analyst invokes read-ticket on SEC-042.
4. The skill calls `jr issue view SEC-042` and retrieves the ticket body.
5. During CVE extraction (regex `CVE-\d{4}-\d{4,7}` applied to summary, description, and custom fields), no match is found.
6. The skill does NOT silently produce a YAML block with `cve_ids.primary: null` and proceed as if CVE absence is safe.
7. Instead, the skill surfaces the absence: either (a) prompts the user for a CVE ID, or (b) proceeds to downstream stages but explicitly surfaces `cve_ids.primary: null` with a note that no CVE was found and downstream EPSS/KEV steps will be skipped.
8. Under no interpretation does the skill treat "no CVE found" as equivalent to "no vulnerability."

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-4.06.001 | Postcondition 3: if no CVE ID found, user is prompted or skill proceeds without CVE but surfaces absence | Steps 6-7 verify the surfacing behavior |
| BC-4.06.001 | Edge Case EC-001: ticket contains no CVE ID — prompt user or proceed without CVE; never silently proceed assuming CVE absence is safe | Core scenario coverage |
| BC-4.06.001 | Postcondition 1: output includes `cve_ids.primary` and `cve_ids.all` fields | Step 7 verifies these fields appear even when empty |

## Verification Approach

Prompt Claude:

> "Run read-ticket on SEC-042. The ticket is about a lateral movement alert with no CVE identified."

Observe in Claude's response:
- The skill proceeds with `jr issue view SEC-042`.
- CVE extraction yields no results.
- Claude explicitly surfaces the absence — either by asking "No CVE ID was found in this ticket — do you have a CVE ID to associate?" or by including `cve_ids.primary: null` in the YAML output with a note.
- Claude does NOT silently produce a complete YAML output omitting all CVE fields with no mention of absence.

## Evaluation Rubric

- **CVE absence surfaced** (weight: 0.7): Is the absence of a CVE ID explicitly communicated to the analyst — either as a prompt for input or as a flagged null in the output? (1.0 = yes; 0.0 = output omits cve_ids fields entirely with no mention)
- **Output structure present** (weight: 0.2): Is a YAML block produced with the non-CVE fields (ticket_id, summary, affected_systems, etc.) populated from the ticket? (1.0 = yes; 0.0 = no output or error abort)
- **Silent-proceed absent** (weight: 0.1): Does the output contain any indication that the skill assumed a CVE was present or skipped the absence check? (1.0 = no such indication; 0.0 = silent proceed)

## Edge Conditions

- If the analyst provides a CVE ID in the prompt text (e.g., "Run read-ticket on SEC-042, CVE is CVE-2024-1234"), the skill may use that as the primary CVE and proceed normally — this scenario tests the case where no CVE appears in either the ticket or the prompt.
- A ticket with a CVE in a non-standard custom field (not summary, description, or the named custom fields) may also produce EC-001; this scenario uses description absence as the primary test case.

## Failure Guidance

"HOLDOUT LOW: HS-030 (satisfaction: 0.XX) — read-ticket silently produced a YAML output without surfacing the missing CVE ID. EC-001 handling violated: the skill should have prompted the analyst or flagged the absence explicitly per BC-4.06.001 Postcondition 3."

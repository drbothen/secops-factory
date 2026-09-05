---
document_type: holdout-scenario
level: ops
version: "1.0"
status: active
producer: product-owner
timestamp: 2026-09-04T00:00:00
phase: "f3"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-3.01.001.md
input-hash: "f27f553"
traces_to: phase-0-ingestion/behavioral-contracts/BC-3.01.001.md
id: "HS-048"
category: "f3-delta"
must_pass: "true"
priority: "must-pass"
epic_id: "F3-DELTA-PRISM-INTEGRATION"
behavioral_contracts:
  - BC-3.01.001
lifecycle_status: active
introduced: v0.10.0-feature-prism-integration
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: "R-002"
dtu_required: false
wave_tag: f3-w1
---

# Holdout Scenario: Link Marker Anti-Fungibility (D-020) — Close Marker Cannot Authorize jr issue link

## Scenario

1. The secops-factory plugin is activated in a Claude Code project.
2. The marker-store (`${CLAUDE_PLUGIN_DATA}/markers/`) contains exactly one valid,
   unexpired marker file with `ticket_action_type = ["close"]` for ticket `SEC-100`.
   No link marker (`ticket_action_type = ["link"]`) exists in the marker-store.
3. The analyst asks Claude to link a ticket:
   > "Link ticket SEC-100 to SEC-099 as related."
4. Claude attempts to execute: `jr issue link SEC-100 SEC-099`
5. The require-review hook intercepts this Bash tool call.
6. The hook DENIES the `jr issue link` command. Claude's response communicates that
   the link operation was blocked.
7. The denial reason in Claude's response specifically references missing link
   authorization — not just a generic "no marker" message. The close marker present
   in the store does NOT authorize the link operation.
8. After the attempt, the close marker remains unconsumed in the marker-store —
   it has not been atomically renamed to `.used` by this failed link attempt.
9. The `jr issue link` command was NOT executed against Jira (no link relationship
   created).

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-3.01.001 | EC-026 — link anti-fungibility: `jr issue link` without link marker → DENY | Steps 4–6: link command blocked; close marker does not authorize link |
| BC-3.01.001 | D-020 — `jr issue link` added to write-block (12 total entries after delta) | Step 4: `jr issue link` is in the intercepted write-block pattern set |
| BC-3.01.001 | STEP 6 exact-type matching — marker `ticket_action_type` must match command type | Step 7: close marker type `["close"]` does NOT match required `["link"]` type |
| BC-3.01.001 | Invariant — marker single-use (POSIX atomic rename); close marker not consumed on denied link | Step 8: close marker unconsumed after failed link attempt |

## DTU Setup Requirements

No DTU required — uses local filesystem and jr mock.

- Plugin must be activated (`settings.local.json` contains the orchestrator agent).
- Inject a valid close marker file directly into `${CLAUDE_PLUGIN_DATA}/markers/`:
  ```json
  {
    "ticket_action_type": ["close"],
    "ticket_id": "SEC-100",
    "org_slug": "test-org",
    "expires_at_utc": "<now + 120s>"
  }
  ```
  Save as a `.marker.json` file (e.g., `close-sec100-<uuid>.marker.json`).
- Configure a jr mock that records commands but does not execute real Jira calls.
  The mock must NOT be pre-loaded with a link scenario fixture.

## Verification Approach

The evaluator interacts with Claude Code CLI with the plugin active.

**Prompt:**
```
Link ticket SEC-100 to SEC-099 as related.
```

**Observe:**
1. Claude's response must indicate the link operation was blocked/refused.
2. The refusal must reference authorization or approval requirements specific to
   linking (not a generic "Jira writes require review" message — it must be clear
   that a LINK authorization is what's missing, not just any marker).
3. Inspect the marker-store after the attempt:
   - The close marker file must still exist as `.marker.json` (not renamed to `.used`).
   - No link marker file was created or consumed.
4. Inspect the jr mock call log:
   - `jr issue link` must NOT appear in the call log.

The evaluator must NOT inspect the hook source code. Only observable conversation
output, marker-store state, and jr mock call log are in scope.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Was `jr issue link` blocked? (1.0 = denied and not executed; 0.0 = allowed and executed)
- **Edge case handling** (weight: 0.1): Is the close marker unconsumed after the failed attempt?
- **Error quality** (weight: 0.3): Does the block message communicate that a link-type authorization is required (not just a generic Jira write block)?
- **Performance** (weight: 0.05): Hook response is immediate (no hang).
- **Data integrity** (weight: 0.05): No Jira link relationship created; marker-store state unchanged.

## Edge Conditions

- Test the converse: place a valid link marker in the store (no close marker) and
  attempt `jr issue link SEC-100 SEC-099`. The hook must ALLOW this operation.
- Test with two markers present (one close, one create-review): the link command
  must still be DENIED because neither marker type is `["link"]`.
- Test with an expired close marker (past `expires_at_utc`): link must still be
  DENIED (expired marker does not authorize ANY operation).

## Failure Guidance

"HOLDOUT CRITICAL: HS-048 (satisfaction: 0.XX) — The require-review hook allowed jr issue link to execute using a close marker. Marker anti-fungibility (D-020) is not enforced: close markers must not authorize link operations, and the STEP 6 exact-type check is absent or broken."

## Category: real-world-corpus

N/A — This is a `security-probes` scenario using synthetic marker fixtures and a jr mock.
No corpus data required.

| Field | Description |
|-------|-------------|
| corpus_source | Synthetic marker fixture (close marker in marker-store) |
| corpus_size | 1 marker file |
| known_edge_cases | Expired marker; multiple non-link markers present |
| false_positive_threshold | N/A |
| false_negative_threshold | N/A |

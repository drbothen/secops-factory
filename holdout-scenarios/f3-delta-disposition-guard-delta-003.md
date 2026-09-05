---
document_type: holdout-scenario
level: ops
version: "1.0"
status: active
producer: product-owner
timestamp: 2026-09-04T00:00:00
phase: "f3"
inputs:
  - phase-0-ingestion/behavioral-contracts/BC-3.03.001.md
  - phase-0-ingestion/behavioral-contracts/BC-5.01.001.md
input-hash: "4fb7179"
traces_to: phase-0-ingestion/behavioral-contracts/BC-3.03.001.md
id: "HS-052"
category: "f3-delta"
must_pass: "true"
priority: "must-pass"
epic_id: "F3-DELTA-PRISM-INTEGRATION"
behavioral_contracts:
  - BC-3.03.001
  - BC-5.01.001
lifecycle_status: active
introduced: v0.10.0-feature-prism-integration
last_evaluated: null
staleness_check: null
stale_reason: null
retired: null
assumption_source: null
risk_source: null
dtu_required: false
wave_tag: f3-w3
---

# Holdout Scenario: D-029 SAVE-ALWAYS — investigate-event Markdown Save Never Denied

## Scenario

The D-029 decision establishes that the markdown path (an investigation document
save via `investigate-event`) always succeeds — the disposition-guard routes
non-FP markdown saves to MARKDOWN_REVIEW_PATH and issues a review marker instead
of denying the Write. Investigation work must never be silently lost.

1. The secops-factory plugin is activated in a Claude Code project.
2. The analyst invokes the investigate-event skill for a security event:
   > "/investigate-event SEC-101"
3. The skill conducts its investigation and produces an investigation markdown
   document that includes the required sections: `## Disposition`,
   `## Alternatives Considered`, plus evidence and timeline sections.
4. The investigation concludes with `disposition: TP` (true positive) — a non-FP
   classification that under a pre-D-029 hook design would have triggered a deny.
5. When the skill writes the investigation file (the markdown Write tool call),
   the disposition-guard fires on the Write.
6. Observable: The markdown file IS written successfully. Claude's response does
   NOT indicate the Write was blocked or denied.
7. The investigation document appears in the filesystem at its expected path
   (e.g., `artifacts/investigations/investigation-SEC-101-<timestamp>.md`) with
   all required sections populated.
8. A review marker (create-review or comment-review) is issued for the investigation
   — the analyst will need to provide review approval before the verdict can
   trigger Jira writes.
9. The analyst's investigation notes, evidence, and alternatives analysis are NOT
   lost. The file contains the full investigation content.

## Behavioral Contract Linkage

| BC ID | Clause Tested | Scenario Aspect |
|-------|--------------|-----------------|
| BC-3.03.001 | D-029 markdown route-to-review-NEVER-deny: non-FP markdown → MARKDOWN_REVIEW_PATH | Steps 5–7: markdown Write succeeds (no deny); review marker issued instead |
| BC-3.03.001 | D-029 — parsed_disposition=TP → MARKDOWN_REVIEW_PATH (create-review/comment-review) | Step 8: review marker emitted, not a regular FP marker or silent discard |
| BC-5.01.001 | SAVE-ALWAYS invariant — investigation document is never blocked by the hook | Step 7: investigation file persisted to expected path with all required sections |
| BC-5.01.001 | Postcondition — investigation markdown includes Disposition, Alternatives Considered sections | Step 7: file contains required sections |

## DTU Setup Requirements

No DTU required — uses local filesystem only.

- Plugin must be activated (`settings.local.json` contains the orchestrator agent).
- The `investigate-event` skill must be present (`commands/investigate-event.md` or
  equivalent).
- A test security event context (e.g., a OCSF-style alert record or ticket reference)
  must be available for the skill to investigate.
- No pre-seeded markers required.

## Verification Approach

The evaluator interacts with Claude Code CLI with the plugin active.

**Prompt:**
```
/investigate-event SEC-101
```

(Or equivalent: provide a brief description of a security event for the skill
to investigate and produce a TP classification.)

**Observe:**
1. Claude's response must indicate the investigation completed and the document
   was saved — no "Write blocked" or "approval required before saving" message.
2. Inspect the filesystem: the investigation markdown file must exist at the
   expected path (e.g., `artifacts/investigations/investigation-SEC-101-*.md`).
3. Open the file: it must contain:
   - `## Disposition` section with a TP classification and rationale
   - `## Alternatives Considered` section documenting why FP/BTP were ruled out
   - Evidence artifacts (at minimum a mention of the event data examined)
4. A review marker must be present in the marker-store (or Claude's response must
   indicate that review approval has been queued) — the Save succeeded but the
   Jira write still requires review.
5. Confirm that no "Write denied" or "permission required" message appeared during
   the investigation file save.

The evaluator must NOT inspect hook source code. Only observable conversation
output and filesystem state are in scope.

## Evaluation Rubric

- **Functional correctness** (weight: 0.5): Is the investigation markdown file saved at the expected path? (1.0 = file present with content; 0.0 = blocked/absent)
- **Edge case handling** (weight: 0.1): Does the file contain both `## Disposition` and `## Alternatives Considered` sections?
- **Error quality** (weight: 0.3): Does Claude's response clearly indicate the investigation was completed AND that review is needed before Jira writes can proceed?
- **Performance** (weight: 0.05): Investigation completes within a reasonable time (< 3 minutes).
- **Data integrity** (weight: 0.05): No investigation content is missing or truncated; the full markdown is written.

## Edge Conditions

- Test with a FP classification: `disposition=FP` → MARKDOWN_COMMENT_PATH fires
  (a comment marker rather than a review marker); the file is still saved (SAVE-ALWAYS
  applies to both FP and non-FP markdown paths).
- Test with an Indeterminate classification: file is saved; a review marker is issued
  (Indeterminate is a hard-floor case — create-review/comment-review).
- Confirm that if `autonomy_enabled=false` (kill switch), the save STILL succeeds —
  the markdown path save is EXEMPT from the kill switch.

## Failure Guidance

"HOLDOUT HIGH: HS-052 (satisfaction: 0.XX) — The investigate-event skill's markdown Write was denied by the disposition-guard. D-029 SAVE-ALWAYS is violated: investigation documents must never be blocked; the hook must route non-FP markdown saves to MARKDOWN_REVIEW_PATH and issue a review marker rather than denying the Write."

## Category: real-world-corpus

N/A — This is a `security-probes` scenario using a synthetic security event for
investigation. No corpus data required.

| Field | Description |
|-------|-------------|
| corpus_source | Synthetic security event (SEC-101 description provided by evaluator) |
| corpus_size | 1 investigation document |
| known_edge_cases | FP classification (MARKDOWN_COMMENT_PATH); Indeterminate (hard-floor review) |
| false_positive_threshold | N/A |
| false_negative_threshold | N/A |

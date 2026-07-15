---
name: verify-metrics-report
description: "Use when checking an external or automated metrics report (dashboards, colleague spreadsheets, tool-generated counts) against Jira ground truth — window archaeology, boundary-noise tolerance, and derived-column detection."
argument-hint: "<report description or figures to verify>"
---

# Verify Metrics Report

Check someone else's numbers against what Jira actually contains. Executes Phase 6 of the effort-analysis methodology.

## The Iron Law

> **NO VERIFICATION VERDICT WITHOUT WINDOW ARCHAEOLOGY FIRST**

A count that doesn't match your query may still be correct — under a different window convention. Try trailing windows at several plausible run times before declaring a discrepancy. Verdicts issued without establishing the counter's convention are guesses.

## Announce at Start

Before any other action, say verbatim:

> I am using the verify-metrics-report skill to check the reported figures against Jira ground truth.

## Red Flags

| Thought | Reality |
|---|---|
| "My query says 61, the report says 63 — the report is wrong" | Establish the window convention first. Exact matches on short windows calibrate; then judge long windows. |
| "Every row should be verifiable in Jira" | Separate Jira-verifiable rows (ticket counts) from pipeline-only rows (alert-feed counts, TTA/TTT). Verify what Jira can verify; say so about the rest. |
| "A 2-ticket delta is a discrepancy" | Boundary noise on a 30-day window is normal, especially when the trailing edge lands on a storm day. >5% is the flag threshold. |
| "The conversion-rate column confirms the counts" | If a derived column reproduces exactly from other columns, it's derived — not independent confirmation. Check and label it. |
| "The report ran at midnight, obviously" | Try several plausible run times. Report generators use local time, UTC, and cron offsets inconsistently. |
| "Close enough overall — verified" | The verdict is per-row: verified / plausible-within-noise / discrepant / not-Jira-verifiable. No blanket stamps. |

## Prerequisites

- `jr` CLI installed and authenticated
- The report's figures, claimed windows, and (if known) generation time

## Workflow

1. **Classify rows**: Jira-verifiable vs pipeline-only. List both explicitly.
2. **Window archaeology**: for each short-window figure, run `created >= "<start>" AND created < "<end>"` at several plausible run times until one matches exactly — that pins the counter's convention.
3. **Judge long windows** using the established convention. Apply the noise rule: 1–2 tickets / storm-day boundary effects are normal; >5% deviation is a finding.
4. **Internal consistency**: recompute derived columns; label exact reproductions as derived, not independent.
5. **Verdict table**: per row — reported value, Jira value, convention used, verdict, note. Save to `artifacts/metrics/report-verification-<date>.md` and present inline.

## References

- `${CLAUDE_PLUGIN_ROOT}/data/effort-analysis-method.md` — canonical method (Phase 6)

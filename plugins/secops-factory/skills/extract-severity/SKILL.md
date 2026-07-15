---
name: extract-severity
description: "Use when alert severity/criticality exist only as text in analyst worksheet comments (no native Jira field) — extracts them with whitelisted regex over ADF comment bodies and reports coverage."
argument-hint: "[--window 180d] [--client <label>] [--type 'Event Alert']"
---

# Extract Severity / Criticality

Recover alert Severity and asset Criticality distributions when they exist only as free text inside analyst comments. Executes Phase 5 of the effort-analysis methodology.

## The Iron Law

> **NO SEVERITY STATS WITHOUT COVERAGE COUNTS FIRST**

Every distribution reports how many tickets had no extractable value. "62% Medium" means something entirely different at 96% coverage than at 50%. Coverage is part of the result, not a footnote.

## Announce at Start

Before any other action, say verbatim:

> I am using the extract-severity skill to extract severity/criticality from analyst comments and report the distribution with coverage counts.

## Red Flags

| Thought | Reality |
|---|---|
| "The Priority field already has this" | Check its distribution first — intake-artifact fields (mostly Unspecified) are junk. That's why this skill exists. |
| "The regex matched, ship it" | Without the value whitelist you'll capture table-adjacent words ("Criticality: Workstations"). Whitelist, then count the rejects. |
| "Skip the tickets with no match" | Iron Law violation. "No data" tickets are counted and reported. |
| "Fetch comments one ticket at a time in the foreground" | Background the fetch loop with resumable guards — same pattern as effort analysis. |
| "Take the last match in the thread" | Take the first whitelisted match — later mentions quote or summarize earlier ones. |
| "High/Critical are rare, so Mediums don't matter" | Real OT tradecraft often lives in Medium. Report the distribution; interpretation belongs to the analyst. |

## Prerequisites

- `jr` CLI installed and authenticated
- Python 3 on PATH
- Ticket key list (from a JQL query or a prior `/analyze-ticket-effort` run — reuse its fetched comment files if present)

## Workflow

1. **Build the key list** from JQL (window/client/type filters as given; default: Event Alerts, 180d).
2. **Fetch comments** per ticket — background, resumable (`[ -s ]` guards). Reuse `/tmp/effort_data/*.com.json` from a prior run when fresh enough.
3. **Extract** with the whitelisted patterns from the method doc §5: `severity[:=]` and `criticality[:=]`, first match per ticket, values restricted to the whitelist; everything else counts as "no data".
4. **Cross-tab**: severity × criticality distribution, per client and overall, with coverage percentages and no-data counts.
5. **Deliverable**: `artifacts/metrics/severity-extract-<date>.md` with distribution tables, coverage, method note, and the standing improvement recommendation: promote Severity to a real Jira field at intake.

## References

- `${CLAUDE_PLUGIN_ROOT}/data/effort-analysis-method.md` — canonical method (Phase 5, includes the regex + whitelist)
- `/analyze-ticket-effort` — produces the fetched comment corpus this can reuse

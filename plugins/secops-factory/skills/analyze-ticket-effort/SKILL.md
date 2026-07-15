---
name: analyze-ticket-effort
description: "Use when measuring how much analyst time is spent populating/maintaining Jira tickets, or baselining ticket volume per client/type/month. Reconstructs work sessions from ticket event timestamps (creation, field edits, comments) — works with empty worklogs."
argument-hint: "[--window 180d|365d] [--client <label>] [--sample <n>]"
---

# Analyze Ticket Effort

Measure per-ticket analyst effort and per-client ticket volume from Jira event timestamps, using the session-reconstruction method. Executes Phases 0–2 of the effort-analysis methodology.

## The Iron Law

> **NO EFFORT REPORT WITHOUT STATED BIASES FIRST**

Burst time is a lower bound, not a measurement of total effort. Every deliverable states the known biases verbatim (undercounts, overcounts, window sensitivity) and pairs raw burst figures with with-overhead figures. An effort number without its biases is how a lower bound becomes a budget.

## Announce at Start

Before any other action, say verbatim:

> I am using the analyze-ticket-effort skill to measure analyst effort and ticket volume from Jira event history.

## Red Flags

| Thought | Reality |
|---|---|
| "Worklogs are empty, so effort can't be measured" | That's the point of this skill — sessions are reconstructed from event timestamps. |
| "Burst time IS the effort" | Burst time is a lower bound. Always add per-session overhead and say so. |
| "A 30-day sample is enough" | Short windows run light vs 12-month numbers. Use ≥6–12 months for rate-setting. |
| "I'll query the client custom field by its display name" | Object custom fields only match by label via `cf[NNNNN] = "Label"`. Re-run schema discovery if unsure. |
| "The attributed totals are close enough" | Always cross-check the sum of per-client counts against the unfiltered project total. Gaps hide unattributed tickets. |
| "The monthly slope shows a clear decline" | Check R² first (<0.3 = ranging), exclude ramp months, and look for single-client artifacts before declaring a trend. |
| "I'll fetch all 500 tickets in the foreground" | 3 calls/ticket — background the fetch loop with resumable `[ -s ]` guards. |
| "Client names and volumes can go in the PR/commit" | Sensitive. Results go to local artifacts/ only. |

## Prerequisites

- `jr` CLI installed and authenticated (`jr auth login`)
- Python 3 available on PATH
- Optional but recommended: `artifacts/metrics/effort-priors.yaml` (copy from `${CLAUDE_PLUGIN_ROOT}/templates/effort-priors-tmpl.yaml`) with the project key, client field ID, and exclusion list already discovered

## Workflow

Delegate the heavy lifting to the **metrics-analyst** agent (Quinn) when running the full analysis; run inline only for a quick single-client or small-sample question.

### Stage 1: Schema discovery (Phase 0)

1. Verify jr: `jr --version && jr me`
2. If the priors file exists, load `project_key`, `client_field`, `exclusions` from it. Otherwise run schema discovery per the method doc (dump custom fields from one known ticket; enumerate clients via `assets search`; inspect records; build exclusion list) and offer to save the results into a new priors file.
3. Survey field quality: check worklogs are actually empty, sample the Priority field distribution.

### Stage 2: Volume baseline (Phase 1)

1. One JQL query per client label over the window (default 180d).
2. Produce: per-client totals, type mix, monthly counts.
3. Cross-check attributed sum vs unfiltered project total — report the gap.
4. Trend stats per client and desk-wide: mean, stdev, slope, R² — apply the ranging rule.

### Stage 3: Effort measurement (Phase 2)

1. Pick the sample: `--client` if given, else top client(s) by volume; `--window` ≥180d for rate-setting.
2. Background-fetch view/changelog/comments per ticket (resumable loop).
3. Run session reconstruction (GAP=30min, +5min/session overhead — from the priors file if customized).
4. Report per type: touch avg/median, sessions avg, words, with-overhead totals.
5. Compare against `effort_priors` in the priors file if present; flag drifts >25%.
6. Offer to update the priors file with the new measurements.

### Stage 4: Deliverable

Write `artifacts/metrics/effort-analysis-<date>.md` containing: summary tables, method notes, the known-biases section (mandatory, verbatim discipline), coverage/exclusions, and priors-drift comparison. Present the summary inline.

## References

- `${CLAUDE_PLUGIN_ROOT}/data/effort-analysis-method.md` — canonical method (Phases 0–2)
- `${CLAUDE_PLUGIN_ROOT}/templates/effort-priors-tmpl.yaml` — local priors file template
- `/model-ticket-cost` — turns these measurements into annual cost scenarios
- `/extract-severity` — severity/criticality cross-tab from the same fetched comments

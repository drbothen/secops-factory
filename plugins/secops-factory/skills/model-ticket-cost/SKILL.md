---
name: model-ticket-cost
description: "Use when modeling annual ticket-administration cost for an existing client or a prospect — OSINT T-shirt sizing, analog selection, and Low/Base/High cost scenarios from measured effort priors."
argument-hint: "<client-or-prospect-name> [--analog <existing-client>] [--volume <tickets/mo>]"
---

# Model Ticket Cost

Size a client or prospect via OSINT and model their annual ticket-administration cost from measured effort priors. Executes Phases 3–4 of the effort-analysis methodology.

## The Iron Law

> **NO COST FIGURE WITHOUT SCENARIOS AND STATED EXCLUSIONS FIRST**

Every cost model presents Low/Base/High scenarios and states — verbatim — that figures exclude executing the work. A single point estimate without exclusions gets pasted into a pricing deck as "the cost" and is wrong twice.

## Announce at Start

Before any other action, say verbatim:

> I am using the model-ticket-cost skill to size the target and model annual ticket-administration cost with Low/Base/High scenarios.

## Red Flags

| Thought | Reality |
|---|---|
| "The data broker says $218M revenue, good enough" | Data-broker revenue for private subsidiaries is often wrong by orders of magnitude. Headcount is the reliable signal; verify load-bearing numbers. |
| "Big client, so lots of tickets" | Size does NOT predict volume — monitored footprint and tuning maturity do. Use an analog client's actual volume. |
| "I'll research the name directly" | Disambiguate via the Assets/CMDB record first. Generic names researched blind poison the model. |
| "One annual figure is cleaner" | Iron Law violation. Low/Base/High, always. |
| "Use the billable rate — it's more impressive" | Lead with burdened cost; opportunity rate is upside, valid only if analysts are utilization-constrained. |
| "Steady-state volume from day one" | Onboarding runs 2–4× steady-state for the first months. State it in risk notes. |
| "Rates can go in the deliverable committed to the repo" | Rates, client names, and volumes stay in local artifacts and the local priors file. Never committed. |
| "No effort priors? I'll estimate minutes per ticket" | Run /analyze-ticket-effort first, or use its priors file. Invented effort numbers are not measurements. |

## Prerequisites

- `artifacts/metrics/effort-priors.yaml` with measured `effort_priors` and `rates` populated (run `/analyze-ticket-effort` first if missing)
- Perplexity MCP for OSINT sizing (falls back to WebSearch)
- `jr` CLI for analog-client volume queries

## Workflow

### Stage 1: Disambiguate and size (Phase 3)

1. Pull the target's internal record (`jr --output json assets view <KEY>`) if it exists — location/sector context before any external query.
2. Dispatch the **osint-researcher** agent (Harper) for organizational sizing: revenue, headcount, sector scale metric, with citations and trust tiers.
3. Bucket on organizational scale (headcount primary, revenue secondary): Large / Medium / Small per the method doc definitions.

### Stage 2: Pick the analog (Phase 4)

1. For a prospect: choose the closest existing client — same sector + scale — as the volume/type-mix analog. State the choice and why.
2. Query the analog's actual volume and type mix via jr (or reuse a fresh Phase-1 baseline).
3. Use the size-bucket average as the Low anchor; `--volume` overrides when the caller has better information.

### Stage 3: Model (Phase 4)

```
volume (tickets/mo) × type mix × per-type effort (priors, with overhead)
= hours/yr × rate = annual ticket-administration cost
```

1. Compute Low/Base/High volumes → hours/yr → burdened cost (leads) and opportunity cost (upside).
2. Attach the standard risk notes: onboarding spike (2–4×), double-entry/mirroring, priors-measured-on-one-client caveat.
3. If asked about severity-gated pricing tiers, follow the method doc §4.4: quote the math, flag vendor-label severity honestly, and offer the better levers (gate ticketing not triage, digest tickets, tuning-first, automation of templated types).

### Stage 4: Deliverable

Write `artifacts/metrics/cost-model-<target>-<date>.md`: scenario table, sizing findings with citations, analog rationale, risk notes, and the mandatory exclusion statement. Present the summary inline. Never put rates or client identifiers in anything that leaves `artifacts/`.

## References

- `${CLAUDE_PLUGIN_ROOT}/data/effort-analysis-method.md` — canonical method (Phases 3–4)
- `${CLAUDE_PLUGIN_ROOT}/templates/effort-priors-tmpl.yaml` — rates and priors live here, locally
- `/analyze-ticket-effort` — produces the effort priors this model consumes

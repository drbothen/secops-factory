# Recovered Architecture — API Surface Detail

> Detail file for `recovered-architecture.md` (DF-021 shard)
> Step 0b: Architecture Recovery
> Date: 2026-07-19
>
> **Changelog (2026-07-19, adversarial review pass 7):**
> - ADV-0-704: Annotated `jr issue comment` steps in the Enrichment Update Pipeline and Event Investigation Pipeline diagrams with the require-review unconditional deny + human permission-override requirement (DI-013).

This plugin has no HTTP endpoints and no library exports. The public API surface is
20 slash commands that users invoke in Claude Code sessions.

---

## Slash Commands (Public API)

All commands follow the same dispatch pattern: the command `.md` frontmatter declares a
`description` and `argument-hint`, the body contains exactly one line:
`Use the \`secops-factory <name>\` skill via the Skill tool.`
This means commands are thin stubs — all logic lives in the corresponding skill.

| # | Command | Argument | Description | Dispatches To | Pipeline Role |
|---|---------|----------|-------------|---------------|---------------|
| 1 | `/secops-factory:activate` | `[--dry-run]` | Set orchestrator as default agent | `activate` skill | Setup |
| 2 | `/secops-factory:deactivate` | — | Remove orchestrator as default agent | `deactivate` skill | Setup |
| 3 | `/secops-factory:secops-health` | — | Verify jr CLI, Perplexity MCP, plugin assets | No skill (direct) | Diagnostics |
| 4 | `/secops-factory:enrich-ticket` | `<ticket-id>` | 8-stage CVE enrichment workflow | `enrich-ticket` skill | Vuln pipeline: main entry |
| 5 | `/secops-factory:read-ticket` | `<ticket-id>` | Read + extract data from a Jira ticket | `read-ticket` skill | Vuln + Event pipeline: triage |
| 6 | `/secops-factory:research-cve` | `<cve-id>` | Deep CVE intelligence (CVSS/EPSS/KEV/ATT&CK) | `research-cve` skill | Vuln pipeline: stage 2 |
| 7 | `/secops-factory:assess-priority` | `<ticket-id>` | Multi-factor P1-P5 priority calculation | `assess-priority` skill | Vuln pipeline: stage 6 |
| 8 | `/secops-factory:map-attack` | `<cve-id>` | Map CVE to MITRE ATT&CK tactics/techniques | `map-attack` skill | Vuln pipeline: stage 5 |
| 9 | `/secops-factory:review-enrichment` | `<ticket-id>` | Polymorphic peer review (auto-detects CVE vs event) | `review-enrichment` skill | All pipelines: quality gate |
| 10 | `/secops-factory:adversarial-review-secops` | `<ticket-id>` | Multi-pass adversarial convergence review | `adversarial-review-secops` skill | All pipelines: P1/P2 quality gate |
| 11 | `/secops-factory:fact-verify` | `<ticket-id>` | Verify claims against authoritative sources | `fact-verify` skill | Ad-hoc verification |
| 12 | `/secops-factory:update-jira` | `<ticket-id>` | Update Jira custom fields with enrichment data | `update-jira` skill | All pipelines: final write |
| 13 | `/secops-factory:investigate-event` | `<ticket-id>` | 7-stage event investigation (TP/FP/BTP) | `investigate-event` skill | Event pipeline: main entry |
| 14 | `/secops-factory:scan-threats` | `[--sector] [--severity] [--days]` | Scan for advisory-worthy threats | `scan-threats` skill | Advisory pipeline: discovery |
| 15 | `/secops-factory:create-advisory` | `<topic>` | Draft IT/ICS/Combined security advisory | `create-advisory` skill | Advisory pipeline: authoring |
| 16 | `/secops-factory:generate-metrics` | `[--period=7d\|30d\|90d]` | Generate SOC KPIs from artifacts + Jira | `generate-metrics` skill | Metrics |
| 17 | `/secops-factory:analyze-ticket-effort` | `[--window] [--client] [--sample]` | Reconstruct analyst effort from Jira timestamps | `analyze-ticket-effort` skill | Metrics |
| 18 | `/secops-factory:model-ticket-cost` | — | Annual cost modeling per client | `model-ticket-cost` skill | Metrics |
| 19 | `/secops-factory:extract-severity` | — | Extract real severity from Jira comments | `extract-severity` skill | Metrics |
| 20 | `/secops-factory:verify-metrics-report` | — | Verify dashboard numbers against Jira | `verify-metrics-report` skill | Metrics |

**Note:** `secops-health` (item 3) is the only command without a corresponding skill directory.
It is special-cased in CI's structural validation (`if [ "$skill_name" != "secops-health" ]`).

---

## Skill Dispatch Table

Skills are the primary unit of logic in this plugin. Each SKILL.md implements one
functional procedure. The table below documents dispatch behavior and the Iron Law
(the unconditional pre-condition enforced by every pipeline skill).

| Skill | Iron Law | Agent Dispatched | Sub-Skills Invoked | Hook Dependencies |
|-------|----------|-----------------|-------------------|------------------|
| `activate` | (none — setup skill) | none | none | writes `.claude/settings.local.json` |
| `deactivate` | (none — setup skill) | none | none | removes agent from `.claude/settings.local.json` |
| `enrich-ticket` | NO JIRA UPDATE WITHOUT COMPLETED ENRICHMENT FIRST | security-analyst | research-cve, map-attack, assess-priority, read-ticket | enrichment-completeness, require-review |
| `research-cve` | (none — utility skill) | security-analyst | none | none |
| `assess-priority` | NO PRIORITY ASSIGNMENT WITHOUT MULTI-FACTOR ASSESSMENT FIRST | security-analyst | none | none |
| `map-attack` | (none — utility skill) | security-analyst | none | none |
| `read-ticket` | (none — utility skill) | security-analyst | none | none |
| `investigate-event` | NO DISPOSITION WITHOUT EVIDENCE CHAIN FIRST | security-analyst | read-ticket | enrichment-completeness, disposition-guard, require-review |
| `review-enrichment` | NO APPROVAL WITHOUT FRESH-CONTEXT REVIEW FIRST | security-reviewer | none | none |
| `adversarial-review-secops` | NO QUALITY SIGN-OFF WITHOUT ADVERSARIAL CONVERGENCE FIRST | security-reviewer (multi-pass, fresh context) | review-enrichment (implicitly) | none directly; orchestrates convergence loop |
| `fact-verify` | (verify claims against authoritative sources) | security-reviewer | none | none |
| `update-jira` | NO JIRA UPDATE WITHOUT REVIEW APPROVAL FIRST | none (direct jr CLI) | none | require-review (blocks without marker) |
| `scan-threats` | (none — discovery skill) | advisory-writer | none | bias-check-reminder (PostToolUse on Perplexity) |
| `create-advisory` | NO ADVISORY PUBLICATION WITHOUT SOURCE VERIFICATION FIRST | advisory-writer | scan-threats (via routing) | none |
| `generate-metrics` | (none — metrics routing skill) | metrics-analyst | analyze-ticket-effort (routing) | none |
| `analyze-ticket-effort` | NO EFFORT REPORT WITHOUT STATED BIASES FIRST | metrics-analyst | none | none |
| `model-ticket-cost` | (modeling skill) | metrics-analyst | analyze-ticket-effort (data source) | none |
| `extract-severity` | (extraction skill) | metrics-analyst | none | none |
| `verify-metrics-report` | (verification skill) | metrics-analyst | none | none |

---

## Orchestrator Routing Table

The orchestrator agent (Morgan) routes analyst intent to commands using this mapping
(source: `agents/orchestrator/orchestrator.md`):

| Analyst says (or means) | Route to |
|-------------------------|----------|
| "Enrich SEC-1234", "new vuln ticket" | `/enrich-ticket <ticket-id>` |
| "What's in this ticket?" | `/read-ticket <ticket-id>` |
| "Look up CVE-2026-XXXXX", "is this exploited?" | `/research-cve <cve-id>` |
| "How urgent is this?", "what priority?" | `/assess-priority <ticket-id>` |
| "Map this to ATT&CK" | `/map-attack <cve-id>` |
| "We got an alert", "Claroty/Snort/Splunk fired" | `/investigate-event <ticket-id>` |
| "Review my enrichment", "check my work" | `/review-enrichment <ticket-id>` |
| "High-stakes ticket, P1/P2 work product" | `/adversarial-review-secops <ticket-id>` |
| "Double-check these numbers", "verify the claims" | `/fact-verify <ticket-id>` |
| "What's new this week?", "anything advisory-worthy?" | `/scan-threats` |
| "Write an advisory for X" | `/create-advisory <topic>` |
| "Post it to JIRA", "update the ticket" | `/update-jira <ticket-id>` |
| "How are we doing?", "monthly report numbers" | `/generate-metrics` |
| "How much time do we spend on tickets?" | `/analyze-ticket-effort` |
| "What would client X cost per year?" | `/model-ticket-cost` |
| "What's the real severity mix?" | `/extract-severity` |
| "Does this dashboard match Jira?" | `/verify-metrics-report` |
| "Something's broken", "Perplexity isn't working" | `/secops-health` |

---

## End-to-End Pipeline Sequences

### Vulnerability Management Pipeline

```
/read-ticket <id>
  → read-ticket skill (jr issue view)
  → returns: CVE ID, initial severity, asset context

/enrich-ticket <id>
  → Stage 1: triage (jr read)
  → Stage 2: /research-cve (Perplexity tiered by CVSS, or NVD/EPSS/CISA fallback)
  → Stage 3: business context (ACR, exposure)
  → Stage 4: remediation planning
  → Stage 5: /map-attack (ATT&CK T-numbers)
  → Stage 6: /assess-priority (6-factor score → P1-P5)
  → Stage 7: populate security-enrichment-tmpl.yaml
  → [enrichment-completeness hook validates all required sections]
  → Stage 8: save locally → /update-jira

/adversarial-review-secops <id>
  → Pass 1: dispatch security-reviewer (fresh context, opus model)
  → Classify all findings SUBSTANTIVE or NITPICK
  → If SUBSTANTIVE: analyst fixes → repeat
  → Convergence: all NITPICK → quality approval
  → [require-review hook unblocked for JIRA field writes]

/update-jira <id>
  → Validate enrichment fields (CVSS range, EPSS range, KEV enum)
  → jr issue edit (priority field)
  → jr issue comment (enrichment summary) **(require-review DENY → human permission-override required, DI-013)**
  → jr issue move (status transition)
```

### Event Investigation Pipeline

```
/investigate-event <id>
  → Stage 1: triage + alert type detection (ICS/IDS/SIEM)
  → Stage 2: alert metadata collection
  → Stage 3: network/host identifiers
  → Stage 4: evidence collection
  → Stage 5: technical analysis (ATT&CK, protocol, IOC)
  → Stage 6: disposition (TP/FP/BTP) + confidence
  → [disposition-guard hook: requires "Alternatives Considered" before saving]
  → Stage 7: save locally FIRST → jr issue comment **(require-review DENY → human permission-override required, DI-013)** → jr issue edit

/review-enrichment <id>   [auto-detects event investigation document]
  → security-reviewer scores against 7-dimension rubric
  → weighted score → Good/Needs Improvement/Inadequate
```

### Advisory Creation Pipeline

```
/scan-threats [--sector energy|water|manufacturing|all] [--severity critical|high]
  → Perplexity path: CISA, NVD, KEV, vendor PSIRTs, ICS-CERT
  → WebSearch fallback if Perplexity unavailable
  → Prioritization scoring (6 factors)
  → Returns candidates table with scores >= 6.0 threshold

/create-advisory <topic>
  → advisory-writer agent dispatched
  → IT / ICS-OT / Combined type selection
  → Research (Perplexity tiered, or WebSearch fallback)
  → Populate security-advisory-tmpl.md
  → Source verification
```

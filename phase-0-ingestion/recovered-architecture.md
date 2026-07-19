# Recovered Architecture: secops-factory

> Recovered by Dark Factory Phase 0b (Architecture Recovery)
> Source codebase: `plugins/secops-factory/` (v0.9.0)
> Date: 2026-07-19
> Confidence: high
> Sharding applied: YES (exceeds 500-line threshold)
> Detail files: arch-recov-api-surface.md, arch-recov-integrations.md
>
> **Changelog (2026-07-19, adversarial review pass 1):**
> - DI-008 RESOLVED: prose table C-numbers and YAML component-map IDs now agree end-to-end. The YAML was missing C-18 (hook-manifests), causing a one-off shift from C-18 onwards. IDs are now consistent (C-1..C-24 in both tables).
> - DI-009 RESOLVED: `hooks/hooks.json` + `hooks.json.windows` (hook-manifests) added to machine-readable YAML as C-18 (HIGH criticality). A wrong matcher in this file silently de-wires the CRITICAL require-review gate.
> - ADV-0-005: Fixed prose C-20 output-templates file count (5 → 6: 5 .yaml + 1 .md). Layer diagram updated to match.

---

## Architecture Summary

secops-factory is a **declarative Claude Code plugin** — there is no compiled code.
Architecture here means the component topology: how slash commands dispatch to skill
procedures, how skill procedures invoke agents and ground themselves in data KBs, how
hooks enforce quality gates on tool events, and how two external services (jr CLI for
Jira and Perplexity MCP for research) form the integration boundary.

The plugin implements **three end-to-end pipelines** for ICS/OT security operations:

1. **Vulnerability Management:** read-ticket → enrich-ticket (8 stages) →
   review/adversarial-review → update-jira
2. **Event Investigation:** read-ticket → investigate-event (7 stages, TP/FP/BTP) →
   review → update-jira
3. **Advisory Creation:** scan-threats → create-advisory → source verification

A companion orchestrator agent (Morgan) coordinates sessions, routes tasks, and tracks
pipeline position. Five specialist agents perform deep work: security-analyst (Alex),
security-reviewer (Riley), metrics-analyst (Quinn), osint-researcher (Harper), and
advisory-writer. Three canonical workflow playbooks live alongside the orchestrator.

---

## Components

| # | Component | Path | Layer | Purpose |
|---|-----------|------|-------|---------|
| C-1 | Command dispatch layer | `commands/*.md` (20 files) | Dispatch | Thin slash-command stubs that delegate to same-name skills |
| C-2 | Skill procedures | `skills/<name>/SKILL.md` (19 dirs) | Procedure | Staged workflows with Iron Laws, Red Flags, template/data refs |
| C-3 | Orchestrator agent (Morgan) | `agents/orchestrator/orchestrator.md` | Orchestration | SOC companion; session routing, pipeline tracking, quality-gate enforcement |
| C-4 | Enrichment workflow | `agents/orchestrator/enrichment-workflow.md` | Orchestration | 8-stage CVE enrichment playbook (canonical source) |
| C-5 | Investigation workflow | `agents/orchestrator/investigation-workflow.md` | Orchestration | 7-stage event investigation playbook (canonical source) |
| C-6 | Review-convergence workflow | `agents/orchestrator/review-convergence-workflow.md` | Orchestration | Adversarial convergence loop playbook (canonical source) |
| C-7 | Security-analyst (Alex) | `agents/security-analyst.md` | Specialist-Agent | CVE enrichment, event investigation; sonnet model; Perplexity + jr tools |
| C-8 | Security-reviewer (Riley) | `agents/security-reviewer.md` | Specialist-Agent | Peer review, convergence passes; **opus model**; read-only tools |
| C-9 | Metrics-analyst (Quinn) | `agents/metrics-analyst.md` | Specialist-Agent | Jira-derived metrics, effort reconstruction; sonnet model |
| C-10 | OSINT-researcher (Harper) | `agents/osint-researcher.md` | Specialist-Agent | External research (company sizing, IP reputation, threat intel); cited findings |
| C-11 | Advisory-writer | `agents/advisory-writer.md` | Specialist-Agent | Security advisory drafting, threat scanning |
| C-12 | require-review hook | `hooks/require-review.{sh,ps1}` | Enforcement | PreToolUse/Bash: blocks `jr issue edit/move/assign/create` without review approval |
| C-13 | enrichment-completeness hook | `hooks/enrichment-completeness.{sh,ps1}` | Enforcement | PreToolUse/Write: blocks saving enrichment/investigation docs with missing sections |
| C-14 | disposition-guard hook | `hooks/disposition-guard.{sh,ps1}` | Enforcement | PreToolUse/Write: blocks investigation disposition without "Alternatives Considered" |
| C-15 | bias-check-reminder hook | `hooks/bias-check-reminder.{sh,ps1}` | Enforcement | PostToolUse/Bash+Perplexity: injects cognitive bias reminder after research tool calls |
| C-16 | handoff-validator hook | `hooks/handoff-validator.{sh,ps1}` | Enforcement | SubagentStop: validates structured handoffs between agents |
| C-17 | session-greeting hook | `hooks/session-greeting.{sh,ps1}` | Enforcement | SessionStart: activation-gated banner when orchestrator is the default agent |
| C-18 | Hook manifests | `hooks/hooks.json`, `hooks/hooks.json.windows` | Configuration | Wires hook events to handler scripts; cross-platform variants |
| C-19 | Knowledge bases | `data/*.md` (10 files) | Knowledge | Domain reference: CVSS, EPSS, KEV, ATT&CK, bias patterns, metrics recipes |
| C-20 | Output templates | `templates/*.yaml/.md` (6 files) | Knowledge | Structured schemas for enrichment, investigation, advisory, review, effort-priors |
| C-21 | Quality checklists | `checklists/*.md` (15 files) | Knowledge | 8 CVE enrichment + 7 event investigation quality dimensions |
| C-22 | BATS test suite | `tests/*.bats` (4 files) + `run-all.sh` | Test | Validates hook allow/block logic, skill Iron Laws, template portability, cross-platform parity |
| C-23 | jr CLI | external (`Zious11/jira-cli`) | External-Integration | Jira read/write via Bash subprocess; required runtime dependency |
| C-24 | Perplexity MCP | external (`@perplexity-ai/mcp-server`) | External-Integration | CVE research + threat intel; recommended; WebSearch/WebFetch fallback wired in all skills |

---

## Component Map (Machine-Readable)

```yaml
components:
  - id: C-1
    name: "command-dispatch"
    path: "plugins/secops-factory/commands/"
    layer: "presentation"
    purity: "effectful-shell"
    criticality: "LOW"
    dependencies: ["C-2"]
    interfaces_provided: ["20 slash commands: /activate /enrich-ticket /investigate-event /adversarial-review-secops /review-enrichment /research-cve /assess-priority /map-attack /read-ticket /update-jira /scan-threats /create-advisory /fact-verify /generate-metrics /analyze-ticket-effort /model-ticket-cost /extract-severity /verify-metrics-report /secops-health /deactivate"]
    interfaces_consumed: ["Skill tool (Claude Code runtime)"]
    confidence: "high"

  - id: C-2
    name: "skill-procedures"
    path: "plugins/secops-factory/skills/"
    layer: "business-logic"
    purity: "mixed"
    criticality: "HIGH"
    dependencies: ["C-3", "C-7", "C-8", "C-9", "C-10", "C-11", "C-19", "C-20", "C-21", "C-23", "C-24"]
    interfaces_provided: ["19 SKILL.md procedure files with staged workflows, Iron Laws, Red Flag tables"]
    interfaces_consumed: ["data/ KBs via ${CLAUDE_PLUGIN_ROOT} path", "templates/ schemas", "checklists/ quality gates", "jr CLI via Bash", "Perplexity MCP tools"]
    confidence: "high"

  - id: C-3
    name: "orchestrator-agent"
    path: "plugins/secops-factory/agents/orchestrator/orchestrator.md"
    layer: "business-logic"
    purity: "pure-core"
    criticality: "HIGH"
    dependencies: ["C-4", "C-5", "C-6", "C-2", "C-19"]
    interfaces_provided: ["SOC companion routing table", "pipeline awareness tracking", "quality gate documentation"]
    interfaces_consumed: ["all skills via Skill tool", "workflow playbooks on-demand"]
    confidence: "high"

  - id: C-4
    name: "enrichment-workflow-playbook"
    path: "plugins/secops-factory/agents/orchestrator/enrichment-workflow.md"
    layer: "business-logic"
    purity: "pure-core"
    criticality: "HIGH"
    dependencies: ["C-2", "C-19", "C-20"]
    interfaces_provided: ["8-stage enrichment DAG: triage→CVE-research→business-context→remediation→ATT&CK→priority→documentation→JIRA-update"]
    interfaces_consumed: ["enrich-ticket skill entry point", "research-cve skill", "data references"]
    confidence: "high"

  - id: C-5
    name: "investigation-workflow-playbook"
    path: "plugins/secops-factory/agents/orchestrator/investigation-workflow.md"
    layer: "business-logic"
    purity: "pure-core"
    criticality: "HIGH"
    dependencies: ["C-2", "C-19", "C-20"]
    interfaces_provided: ["7-stage investigation DAG: triage→metadata→identifiers→evidence→analysis→disposition→documentation"]
    interfaces_consumed: ["investigate-event skill entry point"]
    confidence: "high"

  - id: C-6
    name: "review-convergence-playbook"
    path: "plugins/secops-factory/agents/orchestrator/review-convergence-workflow.md"
    layer: "business-logic"
    purity: "pure-core"
    criticality: "HIGH"
    dependencies: ["C-8"]
    interfaces_provided: ["convergence loop: dispatch→score→classify-novelty→fix→repeat", "SUBSTANTIVE/NITPICK classification protocol"]
    interfaces_consumed: ["security-reviewer agent fresh-context dispatch", "quality checklists"]
    confidence: "high"

  - id: C-7
    name: "security-analyst-agent"
    path: "plugins/secops-factory/agents/security-analyst.md"
    layer: "business-logic"
    purity: "effectful-shell"
    criticality: "HIGH"
    dependencies: ["C-19", "C-20", "C-21", "C-23", "C-24"]
    interfaces_provided: ["vulnerability enrichment", "CVE research", "MITRE ATT&CK mapping", "event investigation"]
    interfaces_consumed: ["jr CLI (Bash)", "Perplexity MCP (4 tools)", "data/ KBs", "templates/"]
    confidence: "high"

  - id: C-8
    name: "security-reviewer-agent"
    path: "plugins/secops-factory/agents/security-reviewer.md"
    layer: "business-logic"
    purity: "effectful-shell"
    criticality: "HIGH"
    dependencies: ["C-19", "C-21", "C-24"]
    interfaces_provided: ["8-dimension CVE review rubric", "7-dimension event investigation review rubric", "SUBSTANTIVE/NITPICK novelty classification"]
    interfaces_consumed: ["Read/Bash/Grep tools", "Perplexity MCP (fact verification)"]
    confidence: "high"
    notes: "Uses opus model for cognitive diversity in adversarial passes"

  - id: C-9
    name: "metrics-analyst-agent"
    path: "plugins/secops-factory/agents/metrics-analyst.md"
    layer: "business-logic"
    purity: "effectful-shell"
    criticality: "MEDIUM"
    dependencies: ["C-19", "C-20", "C-23"]
    interfaces_provided: ["effort reconstruction from Jira timestamps", "volume baselining", "cost modeling", "metrics verification"]
    interfaces_consumed: ["jr CLI (changelog, comments, assets)", "Python 3 stdlib (sessions, stats)", "Perplexity MCP (OSINT sizing)"]
    confidence: "high"

  - id: C-10
    name: "osint-researcher-agent"
    path: "plugins/secops-factory/agents/osint-researcher.md"
    layer: "business-logic"
    purity: "effectful-shell"
    criticality: "MEDIUM"
    dependencies: ["C-24"]
    interfaces_provided: ["cited external research findings", "source-trust ranking", "company sizing", "IP/domain reputation", "threat actor research"]
    interfaces_consumed: ["Perplexity MCP", "WebSearch", "WebFetch"]
    confidence: "high"

  - id: C-11
    name: "advisory-writer-agent"
    path: "plugins/secops-factory/agents/advisory-writer.md"
    layer: "business-logic"
    purity: "effectful-shell"
    criticality: "MEDIUM"
    dependencies: ["C-19", "C-20", "C-24"]
    interfaces_provided: ["IT/ICS/Combined advisory drafts", "TLP marking", "dual-template advisory creation"]
    interfaces_consumed: ["Perplexity MCP / WebSearch fallback", "security-advisory-tmpl.md"]
    confidence: "high"

  - id: C-12
    name: "require-review-hook"
    path: "plugins/secops-factory/hooks/require-review.{sh,ps1}"
    layer: "infrastructure"
    purity: "effectful-shell"
    criticality: "CRITICAL"
    dependencies: []
    interfaces_provided: ["PreToolUse/Bash gate: deny jr issue edit/move/assign/create without review approval marker"]
    interfaces_consumed: ["Claude Code hook event envelope (JSON via stdin)", "jq"]
    confidence: "high"

  - id: C-13
    name: "enrichment-completeness-hook"
    path: "plugins/secops-factory/hooks/enrichment-completeness.{sh,ps1}"
    layer: "infrastructure"
    purity: "effectful-shell"
    criticality: "HIGH"
    dependencies: []
    interfaces_provided: ["PreToolUse/Write gate: deny saving enrichment/investigation docs with missing required sections"]
    interfaces_consumed: ["Claude Code hook event envelope (JSON via stdin)", "jq"]
    confidence: "high"

  - id: C-14
    name: "disposition-guard-hook"
    path: "plugins/secops-factory/hooks/disposition-guard.{sh,ps1}"
    layer: "infrastructure"
    purity: "effectful-shell"
    criticality: "HIGH"
    dependencies: []
    interfaces_provided: ["PreToolUse/Write gate: deny investigation disposition without 'Alternatives Considered' section"]
    interfaces_consumed: ["Claude Code hook event envelope (JSON via stdin)", "jq"]
    confidence: "high"

  - id: C-15
    name: "bias-check-reminder-hook"
    path: "plugins/secops-factory/hooks/bias-check-reminder.{sh,ps1}"
    layer: "infrastructure"
    purity: "effectful-shell"
    criticality: "LOW"
    dependencies: []
    interfaces_provided: ["PostToolUse/Bash+Perplexity: injects cognitive bias self-check after research tool calls"]
    interfaces_consumed: ["Claude Code hook event envelope (JSON via stdin)"]
    confidence: "high"

  - id: C-16
    name: "handoff-validator-hook"
    path: "plugins/secops-factory/hooks/handoff-validator.{sh,ps1}"
    layer: "infrastructure"
    purity: "effectful-shell"
    criticality: "LOW"
    dependencies: []
    interfaces_provided: ["SubagentStop gate: validates structured handoffs between agents"]
    interfaces_consumed: ["Claude Code hook event envelope (JSON via stdin)"]
    confidence: "high"

  - id: C-17
    name: "session-greeting-hook"
    path: "plugins/secops-factory/hooks/session-greeting.{sh,ps1}"
    layer: "infrastructure"
    purity: "effectful-shell"
    criticality: "LOW"
    dependencies: []
    interfaces_provided: ["SessionStart: activation-gated welcome banner + additionalContext for Morgan"]
    interfaces_consumed: [".claude/settings.local.json (activation gate)", "jq"]
    confidence: "high"

  - id: C-18
    name: "hook-manifests"
    path: "plugins/secops-factory/hooks/hooks.json, plugins/secops-factory/hooks/hooks.json.windows"
    layer: "infrastructure"
    purity: "pure-core"
    criticality: "HIGH"
    dependencies: ["C-12", "C-13", "C-14", "C-15", "C-16", "C-17"]
    interfaces_provided: ["Claude Code hook event routing: wires SessionStart/PreToolUse/PostToolUse/SubagentStop events to handler scripts; cross-platform variants (.json for macOS/Linux, .json.windows for Windows)"]
    interfaces_consumed: ["Claude Code runtime (reads hooks.json at session start)"]
    confidence: "high"
    notes: "A wrong matcher silently de-wires the CRITICAL require-review gate; jq-validated in CI but no schema (DI-009 resolved by adding this entry)"

  - id: C-19
    name: "knowledge-bases"
    path: "plugins/secops-factory/data/*.md"
    layer: "shared"
    purity: "pure-core"
    criticality: "HIGH"
    dependencies: []
    interfaces_provided: ["CVSS guide (~1135 lines)", "EPSS guide (~1103 lines)", "KEV catalog guide (~1341 lines)", "MITRE ATT&CK mapping guide", "cognitive bias patterns", "event investigation best practices (~3027 lines)", "priority framework (P1-P5 SLA table)", "review best practices (~1516 lines)", "effort analysis method", "Jira metrics recipes"]
    interfaces_consumed: []
    confidence: "high"

  - id: C-20
    name: "output-templates"
    path: "plugins/secops-factory/templates/"
    layer: "shared"
    purity: "pure-core"
    criticality: "MEDIUM"
    dependencies: []
    interfaces_provided: ["security-enrichment-tmpl.yaml", "event-investigation-tmpl.yaml", "security-advisory-tmpl.md", "security-review-report-tmpl.yaml", "security-event-investigation-review-report-tmpl.yaml", "effort-priors-tmpl.yaml"]
    interfaces_consumed: []
    confidence: "high"

  - id: C-21
    name: "quality-checklists"
    path: "plugins/secops-factory/checklists/"
    layer: "shared"
    purity: "pure-core"
    criticality: "MEDIUM"
    dependencies: []
    interfaces_provided: ["8 CVE enrichment checklists (technical accuracy, completeness, actionability, contextualization, documentation quality, ATT&CK mapping, cognitive bias, source citation)", "7 event investigation checklists (completeness, technical accuracy, disposition reasoning, contextualization, methodology, documentation quality, cognitive bias)"]
    interfaces_consumed: []
    confidence: "high"

  - id: C-22
    name: "test-suite"
    path: "plugins/secops-factory/tests/"
    layer: "infrastructure"
    purity: "effectful-shell"
    criticality: "HIGH"
    dependencies: ["C-12", "C-13", "C-14", "C-15", "C-16", "C-2"]
    interfaces_provided: ["hooks.bats: allow/block path coverage for all 5 hooks", "skills.bats: Iron Law + Announce-at-Start + template portability validation", "integration.bats: end-to-end pipeline path tests", "parity.bats: .sh/.ps1 cross-platform behavioral parity"]
    interfaces_consumed: ["bats-core", "jq", "python3 (yaml)", "optional pwsh"]
    confidence: "high"

  - id: C-23
    name: "jr-cli"
    path: "external (github.com/Zious11/jira-cli)"
    layer: "infrastructure"
    purity: "effectful-shell"
    criticality: "MEDIUM"
    dependencies: []
    interfaces_provided: ["jr issue view/list/edit/move/comment/assets/changelog/comments", "jr sprint/board/project/me/auth"]
    interfaces_consumed: ["Jira REST API (authenticated)"]
    confidence: "high"

  - id: C-24
    name: "perplexity-mcp"
    path: "external (@perplexity-ai/mcp-server, npx-launched)"
    layer: "infrastructure"
    purity: "effectful-shell"
    criticality: "MEDIUM"
    dependencies: []
    interfaces_provided: ["mcp__perplexity__perplexity_search", "mcp__perplexity__perplexity_ask", "mcp__perplexity__perplexity_reason", "mcp__perplexity__perplexity_research"]
    interfaces_consumed: ["Perplexity AI API (sonar models)"]
    confidence: "high"
    notes: "Graceful fallback: every consuming skill falls back to WebSearch/WebFetch if unavailable"
```

---

## Layers

### Layer Diagram

```
+-----------------------------------------------------------------------+
| DISPATCH LAYER                                                        |
|   commands/*.md (20 slash commands — thin dispatch stubs)             |
|   Evidence: every command.md body is "Use the `secops-factory X`     |
|   skill via the Skill tool." with no embedded logic.                 |
+-----------------------------------------------------------------------+
                             |
                             v
+-----------------------------------------------------------------------+
| ORCHESTRATION LAYER                                                   |
|   agents/orchestrator/ (orchestrator.md + 3 workflow playbooks)      |
|   Evidence: orchestrator.md contains the routing table, pipeline      |
|   tracking, and quality-gate table. Workflow .md files are canonical |
|   playbooks loaded on-demand per pipeline.                           |
+-----------------------------------------------------------------------+
                             |
                             v
+-----------------------------------------------------------------------+
| PROCEDURE LAYER (Business Logic)                                      |
|   skills/<name>/SKILL.md (19 skills)                                 |
|   Evidence: each SKILL.md defines multi-stage workflows with Iron     |
|   Laws, Red Flag tables, stage outputs, and ${CLAUDE_PLUGIN_ROOT}/   |
|   data/ references. Skills invoke sub-skills (enrich-ticket invokes  |
|   research-cve, map-attack, assess-priority, read-ticket).           |
|                                                                       |
|   agents/*.md (5 specialist agents)                                  |
|   Evidence: agents declare model=, color=, tools=[] and domain       |
|   expertise. Dispatched by skills for deep-work passes.              |
+-----------------------------------------------------------------------+
                             |
                             v
+-----------------------------------------------------------------------+
| KNOWLEDGE LAYER (Shared/Utility)                                      |
|   data/*.md (10 KBs), templates/*.yaml/.md (6), checklists/*.md (15) |
|   Evidence: referenced as ${CLAUDE_PLUGIN_ROOT}/data/X.md etc. in   |
|   every skill and agent. Pure static reference content.              |
+-----------------------------------------------------------------------+
                             |
                  cross-cutting (fires on tool events)
                             |
+-----------------------------------------------------------------------+
| ENFORCEMENT LAYER (Infrastructure)                                    |
|   hooks/*.{sh,ps1} (6 pairs) + hooks.json manifests                 |
|   Evidence: hooks.json wires SessionStart/PreToolUse/PostToolUse/    |
|   SubagentStop events to handler scripts. Scripts emit JSON          |
|   permissionDecision envelopes. Deterministic <100ms, no LLM.       |
+-----------------------------------------------------------------------+

External Integration Boundary:
  jr CLI (required) — Jira read/write via Bash subprocess
  Perplexity MCP (recommended) — CVE research / threat intel
  NVD / FIRST EPSS / CISA KEV APIs (fallback, via WebFetch)
```

### Layer Rules (Observed)

| Rule | Observed? | Violations |
|------|----------|------------|
| Upper layers depend on lower layers only | Mostly yes | `adversarial-review-secops` skill references `agents/orchestrator/review-convergence-workflow.md` directly — a skill invoking the orchestrator's canonical playbook. Intentional by design ("if the two disagree, the orchestrator file wins"), severity LOW. |
| No circular dependencies between layers | Yes | No cycles detected. |
| Data access layer does not import presentation | Yes | Knowledge layer files contain no references to commands/ or hooks/. |

---

## Dependencies (DAG)

### Textual Representation

```text
[C-1: command-dispatch]
  +-- [C-2: skill-procedures]
        +-- [C-3: orchestrator-agent]
        |     +-- [C-4: enrichment-workflow-playbook]
        |     +-- [C-5: investigation-workflow-playbook]
        |     +-- [C-6: review-convergence-playbook]
        +-- [C-7: security-analyst-agent]
        +-- [C-8: security-reviewer-agent]
        |     +-- [C-6: review-convergence-playbook]
        +-- [C-9: metrics-analyst-agent]
        +-- [C-10: osint-researcher-agent]
        +-- [C-11: advisory-writer-agent]
        +-- [C-19: knowledge-bases]        (data/)
        +-- [C-20: output-templates]       (templates/)
        +-- [C-21: quality-checklists]     (checklists/)
        +-- [C-23: jr-cli]                 (external)
        +-- [C-24: perplexity-mcp]         (external)

[C-12..C-17: hooks] + [C-18: hook-manifests] (cross-cutting — hooks fire on Claude Code tool events; hook-manifests wires them)
  +-- read from: Claude Code hook event envelopes
  +-- (C-12 blocks): [C-23: jr-cli] write operations
  +-- [C-18: hook-manifests] wires: [C-12..C-17: hooks]

[C-22: test-suite]
  +-- validates: [C-12..C-16: hooks]
  +-- validates: [C-2: skill-procedures] (Iron Laws, Announce-at-Start)

Notable intra-skill dependencies (via Skill tool invocation):
  enrich-ticket → research-cve, map-attack, assess-priority, read-ticket
  investigate-event → read-ticket
  adversarial-review-secops → security-reviewer agent (fresh context per pass)
  generate-metrics → analyze-ticket-effort (routing), extract-severity (routing)
```

### Circular Dependencies

| Cycle | Components | Severity | Notes |
|-------|-----------|----------|-------|
| None detected | — | — | The dependency graph is a valid DAG. The only non-obvious edge is adversarial-review-secops skill referencing the orchestrator convergence playbook, which is not a cycle. |

### External Dependencies

| Dependency | Version | Purpose | Used By | Fallback |
|-----------|---------|---------|---------|----------|
| `jr` (jira-cli) | unversioned in repo | Jira ticket read/write/comment/move | security-analyst, metrics-analyst, update-jira, enrich-ticket, investigate-event | None — required runtime dep |
| `@perplexity-ai/mcp-server` | npx-launched (unversioned) | CVE research, threat intel, OSINT | all pipeline skills + 4 agents | WebSearch + WebFetch against NVD/FIRST/CISA APIs |
| NVD API | REST v2 | CVE data fallback | research-cve, scan-threats | — |
| FIRST EPSS API | REST v1 | EPSS fallback | research-cve, enrich-ticket | — |
| CISA KEV feed | JSON file | KEV status fallback | research-cve, enrich-ticket | — |
| `bats-core` | system install | Test runner | tests/ | — |
| `jq` | system install | Hook JSON parsing | all hooks | grep fallback in session-greeting |
| `shellcheck` | CI only | Hook lint | ci.yml | — |
| `python3` | stdlib only | Session reconstruction stats | metrics-analyst | — |

---

## Data Models

### Output Document Schemas (template-defined)

| Schema | Template | Key Sections | Produced By |
|--------|----------|-------------|-------------|
| Security Enrichment | `security-enrichment-tmpl.yaml` | Executive Summary, Vulnerability Details, Severity Metrics, Priority Assessment, Remediation Guidance (+ 7 more) | enrich-ticket skill / security-analyst |
| Event Investigation | `event-investigation-tmpl.yaml` | Executive Summary, Alert Details, Disposition, Alternatives Considered, Next Actions | investigate-event skill |
| Security Advisory | `security-advisory-tmpl.md` | CVE, affected versions, remediation steps, IOC, TLP marking, revision history | create-advisory skill / advisory-writer |
| Review Report (CVE) | `security-review-report-tmpl.yaml` | Scores per 8 dimensions, critical/significant/minor findings | review-enrichment skill / security-reviewer |
| Review Report (Event) | `security-event-investigation-review-report-tmpl.yaml` | Weighted scores per 7 dimensions, disposition validation | review-enrichment skill / security-reviewer |
| Effort Priors | `effort-priors-tmpl.yaml` | project_key, client_field, exclusions, effort baselines | analyze-ticket-effort skill / metrics-analyst |

### Data Flow (per pipeline)

```text
Vulnerability Management:
  Jira ticket (jr read) → Stage 1 triage → research-cve (Perplexity/NVD/EPSS/KEV)
  → business context → remediation → ATT&CK mapping → priority score
  → security-enrichment-tmpl.yaml populated → saved locally (artifacts/enrichments/)
  → adversarial-review-secops [convergence loop] → security-reviewer (fresh context)
  → security-review-report-tmpl.yaml populated → review approval marker
  → update-jira (jr issue edit/comment) → Jira ticket updated

Event Investigation:
  Jira ticket (jr read) → 7-stage investigation → event-investigation-tmpl.yaml
  → saved locally (chain of custody) → review → Jira update

Advisory Creation:
  scan-threats (Perplexity/web) → candidates table → create-advisory
  → security-advisory-tmpl.md → source verification
```

### Artifact Storage (runtime, not committed)

| Path Pattern | Content | Scope |
|-------------|---------|-------|
| `artifacts/enrichments/enrichment-<CVE-ID>.md` | Enrichment reports | local only |
| `artifacts/reviews/review-<ticket-id>.md` | Review reports | local only |
| `artifacts/investigations/investigation-<ticket-id>.md` | Investigation reports | local only |
| `artifacts/metrics/kpi-<period>-<date>.md` | Metrics summaries | local only |
| `artifacts/metrics/effort-analysis-<date>.md` | Effort analysis reports | local only |
| `artifacts/metrics/effort-priors.yaml` | Org-specific priors | local only |

---

## Technology Stack

| Category | Technology | Version | Lock File | Configuration |
|----------|-----------|---------|-----------|---------------|
| Primary content language | Markdown | — | — | `.gitattributes` (LF enforcement) |
| Manifests | JSON | — | — | `plugin.json`, `hooks.json`, `marketplace.json` |
| Hook scripts | Bash + PowerShell | — | — | `hooks/*.sh`, `hooks/*.ps1` |
| Output templates | YAML | — | — | `templates/*.yaml` |
| Test framework | bats-core | system | — | `tests/run-all.sh` |
| CI/CD | GitHub Actions | — | — | `.github/workflows/ci.yml`, `release.yml`, `security.yml` |
| JSON validation | jq | system | — | CI structure job, hooks |
| Lint/SAST | shellcheck (hooks), semgrep (auto config) | system | — | `ci.yml`, `security.yml` |
| Cross-platform parity | PowerShell (pwsh) | optional | — | `tests/parity.bats` |
| Env management | direnv | — | — | `.envrc` (AWS Marketplace API key routing) |
| MCP server | Node.js / npx | — | — | `.mcp.json` |

---

## Architecture Smells (Detected)

| Smell | Location | Severity | Description |
|-------|----------|----------|-------------|
| Missing skill for secops-health command | `commands/secops-health.md` — no `skills/secops-health/` | LOW | CI special-cases this command (excluded from the "all commands reference existing skills" check). Low risk: it's a diagnostic command, but it lacks the standard skill structure. |
| Skill references orchestrator canonical source | `skills/adversarial-review-secops/SKILL.md` line: "If the two disagree, the orchestrator file wins" | LOW | The skill procedure layer directly invokes the orchestration layer's canonical playbook. Intentional architectural decision to resolve version drift, but blurs layer separation. |
| enrich-ticket acts as a mini-orchestrator | `skills/enrich-ticket/SKILL.md` | LOW | This skill dispatches 4 sub-skills (research-cve, map-attack, assess-priority, read-ticket) rather than delegating to the orchestrator. Duplicates some orchestration responsibility. |
| Very large knowledge base files | `data/event-investigation-best-practices.md` (~3027 lines) | LOW | Agents document a chunked-read workaround (500 lines/chunk), meaning this file is too large for a single context load. Not a structural defect but an operational constraint. |

---

## Section References (Sharded Detail Files)

| Detail File | Contents |
|-------------|---------|
| `arch-recov-api-surface.md` | Full slash-command catalog (20 commands), skill dispatch table, routing logic |
| `arch-recov-integrations.md` | External service inventory, DTU candidate assessment (jr CLI, Perplexity MCP, NVD/EPSS/KEV fallback APIs) |

# Hooks Reference

SecOps Factory uses 3 hooks to enforce quality gates automatically. Hooks fire on specific tool invocations and cannot be bypassed.

## require-review

| Property | Value |
|----------|-------|
| Type | PreToolUse |
| Trigger | Bash commands containing `jr issue edit`, `jr issue move`, `jr issue assign`, `jr issue create` |
| Script | `hooks/require-review.sh` |
| Blocking | Yes |

**What it enforces:** Blocks JIRA field updates unless a review-approval marker is present. Comment-only operations (posting enrichment text) are allowed. Field updates (CVSS, priority, KEV status) are blocked until `/secops-factory:review-enrichment` has been run and the analysis passes quality thresholds.

**Why:** JIRA field updates represent the official record. Posting unvalidated analysis as authoritative creates false confidence in incomplete or incorrect data.

**When it triggers:** Every Bash command containing `jr issue edit`, `jr issue move`, `jr issue assign`, or `jr issue create`. Read-only commands (`jr issue view`, `jr issue list`, `jr issue comments`) and `jr issue comment` (posting results) are allowed without review.

**How to satisfy it:** Run `/secops-factory:review-enrichment <ticket-id>` before `/secops-factory:update-jira <ticket-id>`. The review skill sets the approval marker when quality thresholds are met.

## enrichment-completeness

| Property | Value |
|----------|-------|
| Type | PreToolUse |
| Trigger | `Write` |
| Script | `hooks/enrichment-completeness.sh` |
| Blocking | Yes |

**What it enforces:** Blocks saving enrichment or investigation documents that are missing required sections. For enrichment documents, checks for: Executive Summary, Vulnerability Details, Severity Metrics, Priority Assessment, Remediation Guidance. For investigation documents, checks for: Executive Summary, Alert Details, Disposition, Next Actions.

**Why:** Partial enrichment saved as complete creates false confidence. The Iron Law requires all stages to complete before saving.

**When it triggers:** Every call to the `Write` tool where the file path contains "enrichment" or "investigation".

**How to satisfy it:** Complete all stages of the enrichment or investigation workflow before saving. The required sections are populated automatically by the skill workflows.

## bias-check-reminder

| Property | Value |
|----------|-------|
| Type | PostToolUse |
| Trigger | `mcp__perplexity__perplexity_search` |
| Script | `hooks/bias-check-reminder.sh` |
| Blocking | No |

**What it enforces:** After every Perplexity research query, displays a non-blocking reminder to check for cognitive biases when interpreting results. Reminds about confirmation bias, anchoring bias, and availability bias.

**Why:** Research results are most dangerous at the moment of interpretation -- the analyst may unconsciously seek confirming evidence, anchor to the first metric found, or over-weight recent incidents. The reminder interrupts automatic processing.

**When it triggers:** After every call to `mcp__perplexity__perplexity_search`.

---

All 8 documentation files have been generated inline above. Here is a summary of what was produced:

1. **README.md** (~310 lines) -- Full project README with overview, features, quick start, Mermaid workflow diagrams, command tables, inventory, plugin structure tree, MCP requirements, Iron Laws table, development instructions, and doc links.

2. **docs/guide/getting-started.md** (~215 lines) -- Prerequisites, installation, MCP server configuration for Atlassian and Perplexity, first enrichment walkthrough (4 steps), first event investigation walkthrough (3 steps), and explanation of the adversarial review loop.

3. **docs/guide/vulnerability-enrichment.md** (~275 lines) -- Mermaid diagram of 8 stages, prerequisites, detailed step-by-step for each stage with commands and outputs, 6-factor priority scoring tables, 8 quality dimensions with checklists, red flags table, and example session transcript.

4. **docs/guide/event-investigation.md** (~275 lines) -- Mermaid diagrams for 7 stages and TP/FP/BTP decision tree, ICS/IDS/SIEM platform support table, ICS-specific considerations, step-by-step walkthrough, 7 weighted quality dimensions, cognitive bias mitigation table, and example session transcript.

5. **docs/guide/adversarial-review.md** (~175 lines) -- Mermaid convergence loop diagram, information asymmetry principles, task-specific attack surfaces for CVE and event reviews, quality thresholds table, mandatory cognitive bias audit, strict-binary novelty protocol, termination states, and troubleshooting persistent findings.

6. **docs/guide/commands-reference.md** (~115 lines) -- All 12 commands in 4 groups (enrichment, investigation, review, utility) with arguments, descriptions, and argument format reference.

7. **docs/guide/agents-reference.md** (~85 lines) -- Both agents (Alex/Sonnet, Riley/Opus) with role, model, color, capabilities, MCP tools, available commands, and information asymmetry rules.

8. **docs/guide/hooks-reference.md** (~70 lines) -- All 3 hooks with type, trigger, script, blocking status, what they enforce, why, when they trigger, and how to satisfy them.agentId: a28f04fcdda68949a (use SendMessage with to: 'a28f04fcdda68949a' to continue this agent)
<usage>total_tokens: 71542
tool_uses: 27
duration_ms: 331545</usage>

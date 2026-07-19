---
name: secops-health
description: "Diagnostic check of secops-factory plugin health: jr CLI availability, optional Perplexity MCP, data files, templates, checklists, and skills. Reports PASS/FAIL/WARN per category."
disable-model-invocation: false
---

# SecOps Health Check

Pre-flight diagnostic. Run at the start of a new session or after plugin updates to confirm all dependencies are available before beginning enrichment or investigation work.

## Announce at Start

Before any other action, say verbatim:

> Running secops-factory health check...

## Procedure

Run the checks in order. Collect results; emit a final summary table.

### 1. jr CLI

```bash
command -v jr && jr auth status
```

- Not found → FAIL: "jr CLI is required. Install from https://github.com/Zious11/jira-cli"
- Found but not authenticated → FAIL: "Run `jr auth login` to authenticate with JIRA"
- Found and authenticated → PASS

### 2. Perplexity MCP (optional)

Attempt to list MCP tools or probe `mcp__perplexity__perplexity_ask`. If unavailable:
- WARN (not FAIL) — skills fall back to web search.

### 3. Data Files

Verify all 8 files exist in `${CLAUDE_PLUGIN_ROOT}/data/`:

| File | Status |
|---|---|
| cvss-guide.md | |
| epss-guide.md | |
| kev-catalog-guide.md | |
| mitre-attack-mapping-guide.md | |
| cognitive-bias-patterns.md | |
| event-investigation-best-practices.md | |
| priority-framework.md | |
| review-best-practices.md | |

Missing files → FAIL with list of missing items.

### 4. Templates

Verify all 5 templates exist in `${CLAUDE_PLUGIN_ROOT}/templates/`:

- security-enrichment-tmpl.yaml
- security-review-report-tmpl.yaml
- event-investigation-tmpl.yaml
- security-event-investigation-review-report-tmpl.yaml
- security-advisory-tmpl.md

Missing files → FAIL with list.

### 5. Checklists

Verify all 15 checklists exist in `${CLAUDE_PLUGIN_ROOT}/checklists/`. Missing → FAIL with list.

### 6. Skills

Verify all skill directories under `${CLAUDE_PLUGIN_ROOT}/skills/` contain a `SKILL.md` file. Missing → FAIL with list.

## Output Format

Emit a markdown table:

| Category | Status | Notes |
|---|---|---|
| jr CLI | PASS/FAIL | ... |
| Perplexity MCP | PASS/WARN | ... |
| Data Files | PASS/FAIL | ... |
| Templates | PASS/FAIL | ... |
| Checklists | PASS/FAIL | ... |
| Skills | PASS/FAIL | ... |

Overall: **HEALTHY** if all required checks PASS; **DEGRADED** if any WARN; **UNHEALTHY** if any FAIL.

## Red Flags

| Thought | Reality |
|---|---|
| "One file is missing, I'll report PASS" | Never suppress failures. All required items must be present. |
| "jr is installed but I skipped auth check" | Auth check is required — installed but unauthenticated breaks all jr commands. |
| "Perplexity is optional so I'll omit it" | Still report WARN so analysts know which fallback path is active. |

## See also

- `/secops-factory:activate` — opt in to the factory for this project
- `/secops-factory:deactivate` — remove the factory default agent

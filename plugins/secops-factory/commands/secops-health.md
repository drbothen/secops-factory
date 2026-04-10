---
description: "Check secops-factory plugin health: jr CLI, MCP servers, data files, templates, checklists"
---

# SecOps Health Check

Verify all secops-factory plugin dependencies are available.

## Checks

### 1. jr CLI Availability

```bash
command -v jr && jr auth status
```

If `jr` is not found: "jr CLI is required. Install from https://github.com/Zious11/jira-cli"
If not authenticated: "Run `jr auth login` to authenticate with JIRA"

### 2. Perplexity MCP (optional)

Check if any `mcp__perplexity__*` tool is accessible. If not available, report as WARNING (not FAIL) — skills fall back to web search.

### 3. Data Files

Verify all 8 data files exist in `${CLAUDE_PLUGIN_ROOT}/data/`:
- cvss-guide.md
- epss-guide.md
- kev-catalog-guide.md
- mitre-attack-mapping-guide.md
- cognitive-bias-patterns.md
- event-investigation-best-practices.md
- priority-framework.md
- review-best-practices.md

### 4. Templates

Verify all 5 templates exist in `${CLAUDE_PLUGIN_ROOT}/templates/`:
- security-enrichment-tmpl.yaml
- security-review-report-tmpl.yaml
- event-investigation-tmpl.yaml
- security-event-investigation-review-report-tmpl.yaml
- security-advisory-tmpl.md

### 5. Checklists

Verify all 15 checklists exist in `${CLAUDE_PLUGIN_ROOT}/checklists/`.

### 6. Skills

Verify all 13 skill directories exist with SKILL.md files.

Report: PASS/FAIL/WARN for each category with specific missing items.

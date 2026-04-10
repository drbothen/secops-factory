---
description: "Check secops-factory plugin health: MCP servers, data files, templates, checklists"
---

# SecOps Health Check

Verify all secops-factory plugin dependencies are available.

## Checks

### 1. MCP Server Availability

Check Atlassian MCP:
```
Verify mcp__atlassian__getJiraIssue is callable
```

Check Perplexity MCP:
```
Verify mcp__perplexity__perplexity_search is callable
```

### 2. Data Files

Verify all 8 data files exist in `${CLAUDE_PLUGIN_ROOT}/data/`:
- cvss-guide.md
- epss-guide.md
- kev-catalog-guide.md
- mitre-attack-mapping-guide.md
- cognitive-bias-patterns.md
- event-investigation-best-practices.md
- priority-framework.md
- review-best-practices.md

### 3. Templates

Verify all 4 templates exist in `${CLAUDE_PLUGIN_ROOT}/templates/`:
- security-enrichment-tmpl.yaml
- security-review-report-tmpl.yaml
- event-investigation-tmpl.yaml
- security-event-investigation-review-report-tmpl.yaml

### 4. Checklists

Verify all 15 checklists exist in `${CLAUDE_PLUGIN_ROOT}/checklists/`.

### 5. Skills

Verify all 11 skill directories exist with SKILL.md files.

Report: PASS/FAIL for each category with specific missing items.

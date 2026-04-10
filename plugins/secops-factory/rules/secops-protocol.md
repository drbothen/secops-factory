# SecOps Factory Protocol

## External Dependencies

### jr CLI (Required)
- JIRA operations: read tickets, update fields, post comments, transition status
- Install: https://github.com/Zious11/jira-cli
- Auth: `jr auth login` (API token stored in system keychain)
- Config: `~/.config/jr/config.toml` or `.jr.toml` (project-level)
- Key commands: `jr issue view`, `jr issue edit`, `jr issue comment`, `jr issue move`, `jr issue list --jql`, `jr issue assets`

### Perplexity MCP (Recommended)
- Used for CVE research and fact verification
- Tools: `mcp__perplexity__perplexity_search`, `mcp__perplexity__perplexity_ask`, `mcp__perplexity__perplexity_reason`, `mcp__perplexity__perplexity_research`
- Graceful fallback: if not configured, skills use `WebSearch`/`WebFetch` to query NVD, FIRST, CISA APIs directly

## Field Conventions

### CVE IDs
- Format: `CVE-YYYY-NNNNN` (case-insensitive, 4+ digit suffix)
- Always validate format before querying

### CVSS Scores
- Range: 0.0-10.0
- Always specify version (v3.1 or v4.0)
- Source: NVD (authoritative)

### EPSS Scores
- Range: 0.0-1.0 (probability)
- Percentile: 0-100
- Source: FIRST.org (authoritative)
- Updates daily

### KEV Status
- Values: "Listed" or "Not Listed"
- Source: CISA KEV Catalog (authoritative)
- Override factor in priority calculation

### Priority Levels
- P1 (Critical, 24h SLA), P2 (High, 7d), P3 (Medium, 30d), P4 (Low, 90d), P5 (Informational, no SLA)

### Dispositions
- TP (True Positive), FP (False Positive), BTP (Benign True Positive)
- Always include confidence level: High, Medium, Low

## Path Conventions

All internal references use `${CLAUDE_PLUGIN_ROOT}/` prefix:
- Templates: `${CLAUDE_PLUGIN_ROOT}/templates/<name>`
- Data: `${CLAUDE_PLUGIN_ROOT}/data/<name>`
- Checklists: `${CLAUDE_PLUGIN_ROOT}/checklists/<name>`

## Commit Format

Commits to this plugin use conventional commits:
```
secops(<scope>): <description>
```

Scopes: skills, agents, data, templates, checklists, hooks, tests, docs

## Security Considerations

- Never log JIRA credentials or API tokens
- Never expose cloud_id in user-facing messages
- CVE IDs are public -- safe to log
- Sanitize all error messages before displaying
- Private IPs cannot be verified externally -- flag accordingly
- Validate all input ranges before API calls

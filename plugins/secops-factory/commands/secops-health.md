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

### 7. Windows Prerequisites (win32 only — SKIP on macOS/Linux)

On Windows hosts only, check for each prereq in order and print guided remediation for any missing item:

1. **PowerShell 7.4+**: `pwsh -NoProfile -Command '$PSVersionTable.PSVersion.Major'` — must be ≥ 7. Remediation: `winget install -e --id Microsoft.PowerShell`
2. **Native bash (Git Bash / MSYS2)**: `Get-Command bash` — must exist and path must NOT contain `System32`. Remediation: `winget install -e --id Git.Git`
3. **direnv on PATH**: `direnv version` — must exit 0. Remediation: `winget install -e --id direnv.direnv`
4. **direnv bash_path pinned**: `direnv status` — bash path must NOT contain `System32`. Remediation: Edit `~/.config/direnv/direnv.toml` — see `direnv.toml.example` in repo root.
5. **Node.js 18+**: `node --version` — major version must be ≥ 18. Remediation: `winget install -e --id OpenJS.NodeJS.LTS`
6. **prism.exe present**: `${CLAUDE_PLUGIN_DATA}/prism.exe` must exist. Remediation: Run `/secops-factory:activate`

Report: PASS/FAIL/WARN for each category with specific missing items.
Windows Prereqs row is SKIP on non-Windows hosts.

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

### 7. Windows Prerequisites (win32 only)

Run this check only on Windows (`process.platform === 'win32'` in Node, or detect via
`$IsWindows` in PowerShell, or `[[ "$OSTYPE" == "msys"* ]]` in bash). Skip silently on
macOS/Linux — do not emit a row for non-Windows hosts.

Check each item in order and print **guided remediation** for any missing item:

| # | Check | Command | PASS condition | Remediation on FAIL |
|---|-------|---------|----------------|---------------------|
| 1 | **PowerShell 7.4+** | `pwsh -NoProfile -Command '$PSVersionTable.PSVersion.Major'` | Output ≥ 7 | `winget install -e --id Microsoft.PowerShell` |
| 2 | **Native bash (Git Bash / MSYS2)** | `Get-Command bash -ErrorAction SilentlyContinue` in pwsh | Command found AND path does NOT contain `System32` | `winget install -e --id Git.Git` |
| 3 | **direnv on PATH** | `direnv version` | Exits 0, version string returned | `winget install -e --id direnv.direnv` |
| 4 | **direnv bash_path pinned** | `direnv status` | Output contains a bash path that does NOT contain `System32` | Edit `~/.config/direnv/direnv.toml` — see `direnv.toml.example` in the repo root |
| 5 | **Node.js 18+** | `node --version` | Output starts with `v` and major version ≥ 18 | `winget install -e --id OpenJS.NodeJS.LTS` |
| 6 | **prism binary present** | Check `${CLAUDE_PLUGIN_DATA}/prism.exe` exists | File found | Run the `activate` skill: `/secops-factory:activate` |

Report each as PASS or FAIL with the remediation command inline.
If CLAUDE_PLUGIN_DATA is not set, report WARN and note that `activate` must run first.

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
| Windows Prereqs | PASS/FAIL/SKIP | ... (SKIP on non-Windows) |

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

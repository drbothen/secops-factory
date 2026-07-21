---
document_type: assumption-validation
producer: dx-engineer
date: 2026-07-20
assumption_id: ASM-004
status: PARTIAL
feature: prism-integration
feature_version: v0.10.0-feature-prism-integration
source_register: .factory/phase-f1-delta-analysis/delta-analysis.md §4
---

# ASM-004 Empirical Validation — Headless MCP Loading in `claude -p`

**VERDICT: PARTIAL**

The assumption that `claude -p` loads MCP servers from `settings.json` `mcpServers` is
NOT directly confirmed. The `.mcp.json` (project-level cwd file) route IS confirmed. The
user `settings.json` `mcpServers` route requires an architecture adjustment for the
monitoring-loop packaging (D-DEC-003).

---

## Assumption Under Test

> ASM-004: `claude -p` headless invocation from OS scheduler has access to MCP servers
> registered in `~/.claude/settings.json` (settings.json `mcpServers` key), so a
> cron-scheduled monitoring loop can call prism MCP tools without an interactive session.

---

## Experiment Setup

**Test directory:** `/tmp/asm004-test/` (outside any git repo, not inside secops-factory)

**MCP server used:** `@modelcontextprotocol/server-filesystem` (stdio, npx, no API key required)
— serves `/tmp/asm004-test`; verified disposable. Tool names follow `mcp__filesystem__*` pattern.

**`/tmp/asm004-test/.mcp.json`:**
```json
{
  "mcpServers": {
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem@latest", "/tmp/asm004-test"]
    }
  }
}
```

**Relevant flags discovered via `claude --help`:**

| Flag | Purpose |
|------|---------|
| `--mcp-config <path>` | Explicitly load MCP servers from a JSON file or string |
| `--strict-mcp-config` | Restrict to ONLY `--mcp-config` sources, ignore all others |
| `--output-format json` | Emit structured JSON result to stdout |
| `--dangerously-skip-permissions` | Bypass all permission prompts (required for unattended runs) |
| `--permission-mode bypassPermissions` | Equivalent alternative to above |
| `--settings <file-or-json>` | Load additional settings from file or JSON string |
| `--setting-sources user,project,local` | Which settings layers to load (default: all three) |
| `--bare` | Minimal mode — MCP servers must be explicit via `--mcp-config` |

---

## Probes Executed

### Probe 1 — cwd `.mcp.json` auto-loading (default behavior)

**Command:**
```bash
cd /tmp/asm004-test && claude -p \
  "List the names of the MCP tools you have available. Reply with just the list." \
  --output-format json
```

**Result:** SUCCESS (exit 0)

**Tools observed:**
- `mcp__filesystem__*` (14 tools) — from `/tmp/asm004-test/.mcp.json` ✓
- `mcp__context7__resolve-library-id`, `mcp__context7__query-docs` — from parent session daemon

**Key observations:**
- The `.mcp.json` in cwd was loaded automatically with NO extra flags
- Context7 tools appeared even though they are NOT in the test `.mcp.json`; this is because
  the running Claude Code daemon (in the secops-factory project with context7 configured)
  shared its servers with the subprocess — this is a parent-session artifact, NOT from
  `~/.claude/settings.json` (which has no `mcpServers` key)
- `--output-format json` produced clean, parseable JSON; the `result` field contains the
  text answer and `permission_denials` was `[]` (no approval prompts triggered)
- No `--dangerously-skip-permissions` was needed for a "list tools" query since Claude
  does not need to invoke any MCP tools to enumerate them

### Probe 2 — Isolating config sources with `--strict-mcp-config`

**Command:**
```bash
cd /tmp/asm004-test && claude -p \
  "List the names of the MCP tools you have available. Reply with just a plain bulleted list." \
  --output-format json \
  --strict-mcp-config \
  --mcp-config /tmp/asm004-test/.mcp.json \
  --dangerously-skip-permissions
```

**Result:** SUCCESS (exit 0)

**Tools observed:**
- `mcp__filesystem__*` (14 tools) ONLY — context7 was absent ✓

**Key observations:**
- `--strict-mcp-config` correctly excluded the parent daemon's context7 servers
- This confirms that context7 in Probe 1 was injected from the running daemon, not from any
  persistent user config
- `--strict-mcp-config --mcp-config <path>` is the deterministic pattern for unattended runs
- `--dangerously-skip-permissions` produced `permission_denials: []` — no blocking prompts

### Probe 3 — `--settings` flag with `mcpServers` (simulating settings.json write)

**Setup:** Empty cwd `/tmp/asm004-test-empty/` (no `.mcp.json`)

**`/tmp/asm004-test/test-settings.json`:**
```json
{
  "mcpServers": {
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem@latest", "/tmp/asm004-test"]
    }
  }
}
```

**Command:**
```bash
cd /tmp/asm004-test-empty && claude -p \
  "List only the names of any MCP tools you have available. If none, say NONE." \
  --output-format json \
  --settings /tmp/asm004-test/test-settings.json \
  --dangerously-skip-permissions
```

**Result:** SUCCESS (exit 0) — but filesystem tools did NOT appear

**Tools observed:**
- `mcp__context7__resolve-library-id`, `mcp__context7__query-docs` — parent daemon artifact only
- `mcp__filesystem__*` tools were **absent**

**Key observations:**
- The `--settings` flag did NOT cause the `mcpServers` entry to register and start the
  filesystem MCP server. The `--settings` flag appears to honor non-MCP settings properties
  but does NOT trigger MCP server startup
- Context7 again appeared from the parent daemon (consistent with Probe 1)
- This means `--settings` is NOT a reliable path for injecting MCP servers into headless runs;
  it is a proxy for the `~/.claude/settings.json` user settings source but its `mcpServers`
  key was not honored in this test

---

## Config Source Precedence (Observed)

| Source | Mechanism | Honored headlessly? | Notes |
|--------|-----------|-------------------|-------|
| cwd `.mcp.json` | Auto-discovery in working directory | **YES** (Probe 1) | Loaded without any flags |
| `--mcp-config <path>` | Explicit flag | **YES** (Probe 2) | Most reliable; recommended for unattended runs |
| `--strict-mcp-config` | Restricts to `--mcp-config` only | **YES** (Probe 2) | Excludes daemon/parent session bleed-through |
| Parent session daemon | Inherited from interactive session's MCP config | **YES** (Probe 1, 3) | NOT present in cron context; unreliable |
| `--settings` `mcpServers` | `--settings` JSON file | **NO** (Probe 3) | `mcpServers` key ignored by `--settings` flag |
| `~/.claude/settings.json` `mcpServers` | User-level settings source | **UNCONFIRMED** | Proxy test via `--settings` failed; direct test blocked by constraint of not modifying user settings.json |

---

## Approval-Prompt Blockers

For unattended cron runs that must actually CALL MCP tools (not just list them):

- `--dangerously-skip-permissions` bypasses all permission checks; confirmed to produce
  `permission_denials: []` in structured output
- `--permission-mode bypassPermissions` is the non-"dangerous" named alias
- For granular control: `--allowedTools "mcp__prism__*"` allows all prism tools specifically

**Stdin warning:** When running from cron without a piped stdin, claude emits
`"Warning: no stdin data received in 3s, proceeding without it."` to stderr.
Suppress with `< /dev/null`: `claude -p "..." < /dev/null --output-format json`.

---

## `--output-format json` Structured Output

Probe 1 JSON envelope fields relevant to a scheduler:

```json
{
  "type": "result",
  "subtype": "success",       // check for "success" vs error
  "is_error": false,          // boolean gate for scheduler
  "result": "...",            // the text answer
  "permission_denials": [],   // non-empty = unattended failure
  "terminal_reason": "completed",
  "exit_code": 0              // process exit code
}
```

The JSON output is machine-parseable via `jq`. A scheduler can gate on
`is_error == false` and `permission_denials == []`.

---

## Implications for D-DEC-003 (Monitoring-Loop Packaging)

### The core problem

The activate skill plans to write prism to `~/.claude/settings.json` `mcpServers`.
The monitoring-loop then runs headlessly via `claude -p`. However:

1. The `--settings` flag does NOT honor `mcpServers` — it is not a reliable proxy
2. Whether `~/.claude/settings.json` `mcpServers` is loaded in a standalone headless run
   (no parent daemon) is UNCONFIRMED by these probes
3. The parent daemon's MCP server bleed-through is NOT present in a cron context

### Recommended packaging for D-DEC-003

The activate skill should write the prism MCP config to **both** `~/.claude/settings.json`
(for interactive sessions) AND a dedicated prism MCP config file at a known path
(e.g., `~/.claude/prism.mcp.json`). The monitoring-loop invocation should explicitly
reference this file:

```bash
claude -p "/monitoring-loop" \
  --mcp-config ~/.claude/prism.mcp.json \
  --dangerously-skip-permissions \
  --output-format json \
  < /dev/null
```

This is reliable because `--mcp-config` is confirmed to work headlessly (Probe 2).
It also satisfies `--strict-mcp-config` if other MCP servers should be excluded from the
monitoring-loop's scope (reducing noise/attack surface).

### Alternative: `--bare --mcp-config`

If the monitoring loop should run with minimal plugin/hook overhead:

```bash
claude -p "/monitoring-loop" \
  --bare \
  --mcp-config ~/.claude/prism.mcp.json \
  --dangerously-skip-permissions \
  --output-format json \
  < /dev/null
```

`--bare` skips hooks, LSP, plugin sync, CLAUDE.md auto-discovery, and keychain reads.
This reduces startup time and eliminates hook interference during the patrol loop.

### What activate-mcp-config.sh should write

The activate shell helper must write the prism server block to:
1. `~/.claude/settings.json` (interactive sessions, using `jq` merge per R-008)
2. `~/.claude/prism.mcp.json` (headless/cron path, dedicated file)

The deactivate helper must clean up both locations.

---

## Cleanup

```bash
rm -rf /tmp/asm004-test /tmp/asm004-test-empty
```

Cleanup executed after probes completed.

---

## References

- delta-analysis.md §4 ASM-004 register entry
- delta-analysis.md §5 D-DEC-003 (monitoring-loop packaging, gated on ASM-004)
- delta-analysis.md §3.2 (headless MCP dependency architecture risk)
- BC-6.01.001 (activate skill — MCP config write surface)
- BC-10.01.001 (monitoring-loop — largest new component)
- R-008 (settings.json clobber risk — jq merge requirement)

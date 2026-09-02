---
title: "Cross-Platform Packaging Design Brief"
status: active
date: 2026-09-02
audience: secops-factory F3/F4 pipeline, plugin maintainers, Windows onboarding
cycle: v0.10.0-feature-prism-integration
phase: F3-planning
decision_date: 2026-09-02
decision_status: settled
references:
  - plugins/secops-factory/.mcp.json
  - scripts/factory-profile
  - scripts/migrate-mcp-keys
  - hooks/hooks.json
  - test/parity.bats
  - .factory/feature/claroty-xdome-v1-planning-brief.md
  - .factory/feature/prism-integration-handoff-brief.md
---

# Cross-Platform Packaging Design Brief

This document records the human-approved architecture decisions (2026-09-02) and the
concrete implementation plan for making the secops-factory Claude Code plugin work on
**macOS and native Windows (PowerShell)**. It is a design/planning artifact only — it
does not modify any BC, PRD, STATE phase/convergence flag, or ARCH-INDEX.

---

## 1. Context & Decision

### 1.1 Cross-Platform Goal

secops-factory is a Claude Code plugin (`plugins/secops-factory/`) that today ships and
tests on macOS. The goal is to support **native Windows** — meaning Claude Code launched
from PowerShell 7 on a Windows 11 machine, without requiring WSL for the primary user
workflow. The plugin must:

- Resolve model/API env vars the same way on both OSes (direnv-managed `.envrc`).
- Ship MCP server configurations that work without per-OS branching in `.mcp.json`.
- Ship hooks and utility scripts with `.ps1` counterparts alongside every `.sh` script.

### 1.2 Decision: direnv Everywhere

**Chosen approach:** direnv manages environment variable injection on both macOS and
Windows via a shared `.envrc` + profiles system. direnv evaluates `.envrc` on directory
entry and populates the shell environment before Claude Code reads it.

One-line rationale: one `.envrc`/profiles system, one audit trail, one place to rotate
API keys — the cost is a Windows prereq list (§3), which is acceptable.

Alternatives considered and rejected: see §6.

---

## 2. direnv on Windows — Verified Findings (VERDICT: YES-WITH-BASH)

The following facts are research-verified (sources: direnv.net/docs/hook.html, direnv
CHANGELOG, GitHub issues #1214, #1281, #1105, #1207):

### 2.1 Native Windows Binary

A native Windows binary exists as of direnv v2.37.1 (adds `arm64`).

Installation options (pick one):

```powershell
# Option A — winget (preferred, idempotent)
winget install -e --id direnv.direnv

# Option B — scoop
scoop install direnv

# Option C — manual
# Download direnv.windows-amd64.exe from https://github.com/direnv/direnv/releases
# Rename to direnv.exe, place on PATH
```

### 2.2 PowerShell Hook

The PowerShell hook requires **PowerShell 7+ only** (uses `.NET Core
LocationChangedAction`). PowerShell 5.1 silently no-ops; CMD is unsupported.

Add to `$PROFILE` (PowerShell 7):

```powershell
Invoke-Expression "$(direnv hook pwsh)"
```

### 2.3 The Bash Dependency — the Critical Windows Gotcha

direnv evaluates `.envrc` through bash. On Windows this means a native `bash.exe` must
exist and must be pinned explicitly. Without pinning, direnv may resolve the bash stub
in `C:\Windows\System32\` (the WSL launcher), which invokes WSL and fails on machines
without WSL or when the WSL default distro is not set. This is the leading cause of
`can't find bash` and silent `.envrc` skip reports.

**Fix — pin bash in `~/.config/direnv/direnv.toml`:**

```toml
[global]
bash_path = "C:\\Program Files\\Git\\bin\\bash.exe"
```

Alternatively set `DIRENV_BASH` in `$PROFILE` before the hook line:

```powershell
$env:DIRENV_BASH = "C:\Program Files\Git\bin\bash.exe"
Invoke-Expression "$(direnv hook pwsh)"
```

Verify the pinning with `direnv status` — the output will show the bash path in use.

### 2.4 Known Gotchas to Mitigate

| Gotcha | Symptom | Mitigation |
|--------|---------|-----------|
| WSL-bash hijack (`System32\bash.exe`) | `.envrc` silently skipped; `direnv status` shows `bash: …WSL` | Pin `bash_path` in `direnv.toml` (§2.3) |
| pwsh 5.1 no-op | Hook appears to load but env vars never set | Enforce pwsh 7 prerequisite; detect in `secops-health` |
| PATH-valued vars (cygpath) | PATH entries with Unix paths rejected by Windows native tools | In `.envrc`, use `cygpath -w` for single paths, `cygpath -p` for `PATH`-style lists when setting vars consumed by native Win32 tools |
| `$env:HOME` / XDG dirs | direnv cache/data written to wrong location; config not found | Set in `$PROFILE` before hook: `$env:HOME`, `$env:XDG_CACHE_HOME`, `$env:XDG_DATA_HOME`, `$env:DIRENV_CONFIG` |
| Cross-drive path failures | `bash_path` on a different drive than the repo | Pin bash from same drive as Git install; avoid cross-drive `bash_path` |

**Citations:** direnv.net/docs/hook.html; direnv CHANGELOG v2.37.1; GitHub issue #1214
(bash dependency + `bash_path` fix); #1281 (pwsh 5.1 no-op); #1105 (PATH/cygpath); #1207
(XDG / `$env:HOME`).

---

## 3. Windows Prerequisites & One-Time Setup

Install in this order. Each step is required; the `activate` skill (or a new preflight
check) should detect gaps and print guided remediation.

| Order | Prerequisite | Check Command | Remediation |
|-------|-------------|---------------|-------------|
| 1 | **PowerShell 7.4+** (not 5.1) | `$PSVersionTable.PSVersion.Major` | `winget install -e --id Microsoft.PowerShell` |
| 2 | **Git for Windows (Git Bash / MSYS2)** | `Get-Command bash -ErrorAction SilentlyContinue` | `winget install -e --id Git.Git` |
| 3 | **direnv** | `direnv version` | `winget install -e --id direnv.direnv` |
| 4 | **Pinned bash_path** | `direnv status` — verify bash path points to Git Bash | Edit `~/.config/direnv/direnv.toml` (§2.3) |
| 5 | **$PROFILE hook** | Source `$PROFILE`; run `direnv status` | Add `Invoke-Expression "$(direnv hook pwsh)"` + XDG vars to `$PROFILE` |
| 6 | **Node.js 18+** | `node --version` | `winget install -e --id OpenJS.NodeJS.LTS` |
| 7 | **prism.exe activated** | `prism --version` | Run `activate` skill; it downloads the correct OS/arch build to `$CLAUDE_PLUGIN_DATA` |

**Recommendation:** Extend the existing `secops-health` skill (or create a Windows-aware
preflight check) to detect each prerequisite on `win32` platforms and print a numbered
remediation guide. This converts the prereq list into a guided install experience rather
than silent failure. The "little prereq install" cost of direnv-everywhere is front-loaded
here and does not repeat per-session.

---

## 4. Cross-Platform MCP Servers (shipped `plugins/secops-factory/.mcp.json`)

### 4.1 exa

Transport: HTTP. Already cross-platform. No changes required.

### 4.2 perplexity

**Verified transport: HTTP (primary, confirmed 2026-09-02).**

Endpoint: `https://api.perplexity.ai/mcp`
Transport: Streamable HTTP (MCP spec)
Authentication: `Authorization: Bearer ${PERPLEXITY_API_KEY}` header
Required query parameters: none

This endpoint launched July 31, 2026 and is the official Perplexity remote MCP server.
Sources: docs.perplexity.ai/docs/getting-started/integrations/mcp-server,
docs.perplexity.ai/docs/resources/changelog, github.com/perplexityai/modelcontextprotocol.

`.mcp.json` entry:

```json
{
  "perplexity": {
    "type": "http",
    "url": "https://api.perplexity.ai/mcp",
    "headers": {
      "Authorization": "Bearer ${PERPLEXITY_API_KEY}"
    }
  }
}
```

**Fallback (node-launcher shim)** — if Streamable HTTP transport is not supported by
the Claude Code version in use, fall back to stdio via the official npm package:

Package: `@perplexity-ai/mcp-server@1.2.1` (npm, Node >=18, August 27 2026)
Source: github.com/perplexityai/modelcontextprotocol

```json
{
  "perplexity": {
    "type": "stdio",
    "command": "npx",
    "args": ["-y", "@perplexity-ai/mcp-server@1.2.1"],
    "env": {
      "PERPLEXITY_API_KEY": "${PERPLEXITY_API_KEY}"
    }
  }
}
```

The HTTP transport is preferred: it has no Node/npx dependency and no per-invocation
startup cost. The stdio shim is the fallback.

### 4.3 prism

prism is a native binary (`prism` on macOS/Linux, `prism.exe` on Windows). Claude Code's
`.mcp.json` does not provide an OS-conditional `command` field, and the behavior of
`.sh`/`.cmd`/`.ps1` command resolution on Windows is undocumented and fragile.

**Solution: a thin Node launcher at `bin/prism-mcp.js`.**

The `.mcp.json` entry:

```json
{
  "prism": {
    "type": "stdio",
    "command": "node",
    "args": ["${CLAUDE_PLUGIN_ROOT}/bin/prism-mcp.js"],
    "env": {
      "RUST_LOG": "off"
    }
  }
}
```

`node` is a uniform command on both OSes (§3 prereq). The launcher script resolves
`prism` vs `prism.exe` at runtime:

```js
// bin/prism-mcp.js
const { spawn } = require('child_process');
const path = require('path');
const os = require('os');

const dataDir = process.env.CLAUDE_PLUGIN_DATA;
if (!dataDir) { process.stderr.write('CLAUDE_PLUGIN_DATA not set\n'); process.exit(1); }

const bin = path.join(dataDir, os.platform() === 'win32' ? 'prism.exe' : 'prism');

const child = spawn(bin, process.argv.slice(2), {
  stdio: 'inherit',
  env: { ...process.env, RUST_LOG: 'off' }
});
child.on('exit', (code) => process.exit(code ?? 1));
```

The `activate` skill downloads the correct OS/arch Prism build to `${CLAUDE_PLUGIN_DATA}`
during setup. RUST_LOG=off is mandatory (tracing JSON to stdout corrupts MCP JSON-RPC
framing; see prism-integration-handoff-brief.md §2.1 and claroty-xdome-v1-planning-brief.md
§4.1).

---

## 5. Script/Hook Parity (.sh + .ps1)

The product already ships `.sh` + `.ps1` parity: `hooks.json.windows`, `parity.bats`,
and a verified set of hook scripts with both variants. The `.envrc` layer added
bash-only scripts that broke this parity.

### 5.1 Scripts Requiring PowerShell Counterparts

| Bash script | Required PS1 counterpart | Purpose |
|------------|--------------------------|---------|
| `scripts/factory-profile` | `scripts/factory-profile.ps1` | Sets factory-specific env vars (model routing, profile selection) on shell entry |
| `scripts/migrate-mcp-keys` | `scripts/migrate-mcp-keys.ps1` | Migrates legacy MCP key names to current schema in `settings.json` |

### 5.2 Note on .envrc

`.envrc` itself stays bash — that is a direnv requirement and is not a platform
divergence; it is why the Windows bash prerequisite (§3, items 2–4) is unavoidable
under the direnv-everywhere decision. The `.ps1` counterparts cover the scripts that
are called from hooks or directly by users on Windows; they do not replace `.envrc`.

### 5.3 Parity Regression Gate

Add a `parity.bats`-style check that asserts:

1. For every `.sh` file in `scripts/`, a `.ps1` counterpart exists.
2. For every `.sh` file in `hooks/`, a `.ps1` counterpart exists where the hook entry
   in `hooks.json.windows` references `.ps1`.

This gate runs in CI and blocks merge if any `.sh` script ships without a Windows
counterpart. It prevents the parity regression that the `.envrc` layer introduced.

---

## 6. Alternatives Considered

### 6.1 settings.local.json `env` Generator

Claude Code's `settings.local.json` supports an `env` map that injects key-value pairs
into Claude's process environment before it reads MCP server configs or tool env
overrides. This approach would:

- Set `PERPLEXITY_API_KEY`, `ANTHROPIC_MODEL`, and other vars directly in
  `settings.local.json` (excluded from version control via `.gitignore`).
- Require no bash, no direnv, no PowerShell hook, and no Git Bash dependency on Windows.
- Work on macOS, native Windows (pwsh 5.1 and 7), and CMD without any shell hook.

**Why it was NOT chosen (human decision 2026-09-02):**

The human explicitly chose direnv-everywhere for consistency — one system for env var
management, one `.envrc` audit trail, and parity with how API keys are managed in other
projects in this workspace. The settings.local.json `env` map is a valid, lower-friction
Windows approach but was not the chosen path.

**Kept as documented fallback:** If Windows adoption proves too brittle due to bash/
direnv issues (§7 risks), `settings.local.json env` is the recommended recovery path.
It requires no Windows-specific scripting and eliminates the bash_path/pwsh7/PATH
fragility chain.

---

## 7. Implementation Work Items & Risks

### 7.1 Work Items (PR-sized)

| # | Item | What | Why |
|---|------|------|-----|
| W-1 | Extend `secops-health` for Windows prereq detection | Add `win32` branch: check pwsh 7, bash, direnv, bash_path, Node, prism.exe. Print guided remediation per missing item. | Converts the §3 prereq list into a guided install experience; prevents silent failure on first Windows run. |
| W-2 | Emit `~/.config/direnv/direnv.toml` from `activate` or setup | Write `bash_path` pointing to Git Bash. Skip if already set. | Eliminates the #1 Windows direnv failure mode (WSL-bash hijack) without requiring users to find the config file. |
| W-3 | Add `$PROFILE` setup guidance to `activate` output | Print the three `$PROFILE` lines (DIRENV_BASH, XDG vars, hook) with copy-paste instructions. | Users must set these once; `activate` is the natural time to surface them. |
| W-4 | Update `plugins/secops-factory/.mcp.json` — perplexity entry | Change from node-shim to HTTP transport (§4.2). | HTTP is now available and preferred; eliminates npx startup cost. |
| W-5 | Create `bin/prism-mcp.js` node launcher | Thin cross-platform launcher that resolves `prism`/`prism.exe` from `CLAUDE_PLUGIN_DATA` and execs (§4.3). | Eliminates per-OS `.mcp.json` branching; `node` is the one uniform command. |
| W-6 | Update `plugins/secops-factory/.mcp.json` — prism entry | Switch command to `node` + `${CLAUDE_PLUGIN_ROOT}/bin/prism-mcp.js` (§4.3). | Required to use the W-5 launcher. |
| W-7 | Add `scripts/factory-profile.ps1` | PowerShell counterpart to `scripts/factory-profile` (§5.1). | Parity requirement; blocks CI gate (W-9). |
| W-8 | Add `scripts/migrate-mcp-keys.ps1` | PowerShell counterpart to `scripts/migrate-mcp-keys` (§5.1). | Parity requirement; blocks CI gate (W-9). |
| W-9 | Add script parity gate to CI | Assert `scripts/*.sh` and `hooks/*.sh` each have `.ps1` counterparts (§5.3). | Prevents future parity regressions; runs on every PR. |
| W-10 | Smoke-test `activate` on Windows | Run `activate` in a Windows CI runner (GitHub Actions `windows-latest`); assert `secops-health` passes with no prereq warnings when all prereqs are present. | Provides the regression baseline for the Windows path. |

### 7.2 Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| **direnv Windows fragility — bash_path/pwsh7** | Medium | High | W-2 (auto-emit `direnv.toml`), W-3 (surface $PROFILE setup), W-1 (detect at `secops-health`). Document §6.1 fallback explicitly. |
| **direnv Windows fragility — PATH/cygpath** | Low | Medium | Document cygpath usage in `.envrc` comments; add a note to the Windows setup guide that PATH vars containing Unix-style paths need `cygpath -p` conversion. |
| **Perplexity HTTP endpoint stability** | Low | Medium | Endpoint launched July 31, 2026 (official, versioned). Maintain the stdio fallback config in comments inside `.mcp.json`; W-4 can be reverted to the shim in a single-line change. |
| **Node.js dependency on Windows** | Low | Low | Node is already required by the prism MCP launcher (W-5) and the Perplexity stdio fallback. The dependency exists regardless; W-1 checks for it. |
| **prism.exe not yet available (circular RC gate)** | High | High | Documented in claroty-xdome-v1-planning-brief.md §6.1. W-5/W-6 can be developed and tested against a mock binary. Acceptance of the activate skill + prism.exe download is blocked on Prism rc.1 publication (separate blocker, no mitigation here). |
| **cygpath absent on non-Git-Bash installs** | Low | Low | Gate: if `cygpath` is not on PATH, skip cygpath conversion in `.envrc` and document the fallback. `secops-health` detects this. |

---

*Decisions recorded: 2026-09-02. Do not re-litigate §1.2 (direnv-everywhere) or §4.2
(HTTP transport) without updating this brief and the decision log above.*

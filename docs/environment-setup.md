# Environment Setup Guide

Cross-platform setup for the secops-factory Claude Code plugin: macOS, Linux, and native
Windows (PowerShell 7). Covers direnv, profiles, MCP servers, and the prism binary.

---

## Overview

When you `cd` into the project directory, direnv fires and sources `.envrc`. The `.envrc`
file has two jobs: (1) load API credentials from `.envrc.secrets` (gitignored, owner-only),
and (2) source the active model-routing profile from `profiles/<name>.env`. The result is
that Claude Code inherits `ANTHROPIC_*` environment variables — including `ANTHROPIC_BASE_URL`,
`ANTHROPIC_DEFAULT_OPUS_MODEL`, and related redirect vars — before it reads `.mcp.json`.
Because Claude Code expands `${VAR}` references in `.mcp.json` at load time, the plugin's
MCP server configurations (exa, perplexity, prism) resolve API keys and paths without
storing any secrets in tracked files. Switching profiles is a one-command operation
(`scripts/factory-profile <name>`) that writes a single file (`.factory-profile`) and takes
effect on the next `direnv reload` + `claude` restart.

---

## Prerequisites

### Common (all platforms)

| Requirement | Version | Notes |
|-------------|---------|-------|
| git | any | Required for the repo and for Git Bash on Windows |
| Node.js | >= 18 | Required for `bin/prism-mcp.js`, the cross-platform prism launcher |
| prism binary | latest | Downloaded by the `activate` skill into `$CLAUDE_PLUGIN_DATA`; not in the repo |

### macOS

1. **direnv** — install via Homebrew:

   ```sh
   brew install direnv
   ```

2. **Shell hook** — add one line to your shell rc file (see [Install & hook direnv](#install--hook-direnv-per-shell)).

### Linux

1. **direnv** — install via your distribution's package manager or download a static binary:

   ```sh
   # Debian / Ubuntu
   sudo apt install direnv

   # Fedora / RHEL
   sudo dnf install direnv

   # Arch
   sudo pacman -S direnv

   # Static binary (any distro)
   # Download from https://github.com/direnv/direnv/releases and place on PATH
   ```

2. **Shell hook** — add one line to your shell rc file (see [Install & hook direnv](#install--hook-direnv-per-shell)).

### Windows (native PowerShell — NOT CMD, NOT WSL)

Install the following in order. Every item is required. `secops-health` checks all of them
and prints guided remediation for any gap.

| Order | Requirement | Check Command | Install Command |
|-------|-------------|---------------|-----------------|
| 1 | **PowerShell 7.4+** (NOT 5.1) | `$PSVersionTable.PSVersion.Major` | `winget install -e --id Microsoft.PowerShell` |
| 2 | **Git for Windows** (provides Git Bash / MSYS2 bash.exe) | `Get-Command bash -ErrorAction SilentlyContinue` | `winget install -e --id Git.Git` |
| 3 | **direnv** | `direnv version` | `winget install -e --id direnv.direnv` (or `scoop install direnv`) |
| 4 | **bash_path pinned** to Git Bash | `direnv status` — must NOT show `System32\bash.exe` | Edit `~/.config/direnv/direnv.toml` (see below) |
| 5 | **PowerShell $PROFILE hook** (pwsh 7 only) | Source `$PROFILE`; run `direnv status` | Add three lines to `$PROFILE` (see below) |
| 6 | **Node.js 18+** | `node --version` | `winget install -e --id OpenJS.NodeJS.LTS` |
| 7 | **prism.exe** in `$CLAUDE_PLUGIN_DATA` | `Test-Path "$env:CLAUDE_PLUGIN_DATA\prism.exe"` | Run the `activate` skill: `/secops-factory:activate` |

**Critical warnings:**
- **CMD is not supported.** direnv has no CMD hook.
- **Windows PowerShell 5.1 is not supported.** The direnv hook uses `.NET Core
  LocationChangedAction`, which is unavailable in 5.1. The hook appears to install but is
  silently a no-op — environment variables are never set. You must use `pwsh` (PowerShell 7).

---

## Install & hook direnv (per shell)

### bash (macOS / Linux)

Add to `~/.bashrc` (Linux) or `~/.bash_profile` / `~/.bashrc` (macOS):

```bash
eval "$(direnv hook bash)"
```

Reload:

```bash
source ~/.bashrc   # or open a new terminal
```

### zsh (macOS / Linux)

Add to `~/.zshrc`:

```zsh
eval "$(direnv hook zsh)"
```

Reload:

```zsh
source ~/.zshrc   # or open a new terminal
```

### PowerShell 7 (Windows)

There are two parts: XDG environment variables (required for direnv to locate its cache and
config files) and the hook itself. Both must be in `$PROFILE` (`$PROFILE` resolves to
`~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` for `pwsh`).

Open the profile:

```powershell
notepad $PROFILE
```

Add these lines (in this order, before any other direnv use):

```powershell
# XDG dirs — direnv reads config and writes cache here.
# These must be set before the hook line.
$env:HOME           = $env:USERPROFILE
$env:XDG_CACHE_HOME = "$env:USERPROFILE\.cache"
$env:XDG_DATA_HOME  = "$env:USERPROFILE\.local\share"
$env:DIRENV_CONFIG  = "$env:USERPROFILE\.config\direnv"

# Pin bash to Git Bash. Without this, direnv may resolve the WSL stub in
# C:\Windows\System32\bash.exe and silently skip .envrc evaluation.
$env:DIRENV_BASH = "C:\Program Files\Git\bin\bash.exe"

# direnv hook — must be the last direnv-related line.
Invoke-Expression "$(direnv hook pwsh)"
```

Reload (open a new pwsh window, or):

```powershell
. $PROFILE
```

#### Windows: pin bash_path in direnv.toml (alternative / belt-and-suspenders)

The `DIRENV_BASH` env var above covers most cases. For a belt-and-suspenders approach,
also create `~/.config/direnv/direnv.toml` (copy from `direnv.toml.example` at the repo
root):

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.config\direnv"
Copy-Item direnv.toml.example "$env:USERPROFILE\.config\direnv\direnv.toml"
```

The file sets:

```toml
[global]
bash_path = "C:\\Program Files\\Git\\bin\\bash.exe"
```

Adjust the path if Git is installed to a different location (for example, `D:\Git`). The
path must stay on the same drive as the repo to avoid cross-drive bash failures.

#### Verify the bash path

```powershell
direnv status
```

The output must show a bash path. It must **not** contain `System32` — that indicates the
WSL stub. A correct output looks like:

```
direnv: bash_path = C:\Program Files\Git\bin\bash.exe
```

#### Allow the .envrc

After `cd`-ing into the project for the first time, direnv will block and say "direnv:
error ... is blocked. Run `direnv allow` to approve its content." Run:

```powershell
direnv allow
```

This approval is stored per-directory and persists across sessions.

---

## Secrets (.envrc.secrets)

### First-time setup

```sh
cp .envrc.secrets.example .envrc.secrets
chmod 600 .envrc.secrets   # on Windows, migrate-mcp-keys.ps1 sets ACL automatically
```

Open `.envrc.secrets` in an editor and fill in your keys:

| Variable | Required | Used by |
|----------|----------|---------|
| `PERPLEXITY_API_KEY` | Required | perplexity MCP server (Bearer header in `.mcp.json`) |
| `EXA_API_KEY` | Required | exa MCP server (URL query parameter in `.mcp.json`) |
| `TAVILY_API_KEY` | Optional | Tavily MCP server if you add it to `.mcp.json` |
| `CONTEXT7_API_KEY` | Optional | Context7 MCP server if you add it to `.mcp.json` |
| `ANTHROPIC_AWS_API_KEY` | Required for `cloud`/`hybrid` profiles | AWS Bedrock authentication |
| `ANTHROPIC_AWS_WORKSPACE_ID` | Required for `cloud`/`hybrid` profiles | AWS Bedrock workspace ID; consumed by `profiles/cloud.env` |

`.envrc.secrets` is listed in `.gitignore` and must never be committed. Keep permissions
at 600 (owner read/write only).

### Migrating keys out of an existing .mcp.json

If you have been storing API keys as literal values inside `.mcp.json`, the migration
scripts extract them and replace the values with `${VAR}` references:

```sh
# macOS / Linux
bash scripts/migrate-mcp-keys.sh

# Windows (PowerShell 7)
.\scripts\migrate-mcp-keys.ps1
```

The scripts are idempotent and safe to re-run. They handle Perplexity (Bearer header),
Tavily (URL query string), Context7 (header), and exa (URL query string). They write
the secrets file first, then rewrite `.mcp.json` — so an interrupted run leaves keys
preserved in `.envrc.secrets` rather than lost.

---

## Profiles & switching

Three model-routing profiles are shipped in `profiles/`:

### `cloud` — all-frontier via AWS Bedrock (default for shipping)

```sh
# Environment set by .envrc.secrets + profiles/cloud.env:
CLAUDE_CODE_USE_ANTHROPIC_AWS=1
AWS_REGION=us-east-1
ANTHROPIC_AWS_WORKSPACE_ID=<from .envrc.secrets>
ANTHROPIC_DEFAULT_OPUS_MODEL=claude-opus-4-8
# ANTHROPIC_BASE_URL is unset — Claude Code resolves against AWS directly
# ANTHROPIC_DEFAULT_SONNET_MODEL and _HAIKU_MODEL are unset (provider defaults)
```

**Infrastructure required:** `ANTHROPIC_AWS_API_KEY` and `ANTHROPIC_AWS_WORKSPACE_ID` in
`.envrc.secrets` (API key alternatively in the macOS Keychain under service name
`anthropic-aws-api-key`). No local gateway. No Tailscale.

### `hybrid` — frontier judgment + local execution (recommended for development)

```sh
# Environment set by profiles/hybrid.env:
ANTHROPIC_BASE_URL=http://localhost:4100
ANTHROPIC_AUTH_TOKEN=vsdd-local-gateway
ANTHROPIC_API_KEY=""
ANTHROPIC_DEFAULT_OPUS_MODEL=judgment-primary
ANTHROPIC_DEFAULT_SONNET_MODEL=implementation-local
ANTHROPIC_DEFAULT_HAIKU_MODEL=mechanical-local
CLAUDE_CODE_SUBAGENT_MODEL=inherit
# CLAUDE_CODE_USE_ANTHROPIC_AWS and CLAUDE_CODE_USE_BEDROCK are unset
```

**Infrastructure required:** `scripts/litellm-gateway.sh up` must be running before
launching Claude. The gateway fronts both the AWS (opus) and local (sonnet/haiku) routes
behind a single endpoint. Model names are LiteLLM route aliases from
`config/litellm.yaml`, not raw model IDs.

### `local` — frontier judgment + DGX Spark execution over Tailscale

```sh
# Environment set by profiles/local.env:
ANTHROPIC_BASE_URL=http://localhost:4100
ANTHROPIC_AUTH_TOKEN=vsdd-local-gateway
ANTHROPIC_API_KEY=""
ANTHROPIC_DEFAULT_OPUS_MODEL=judgment-primary
ANTHROPIC_DEFAULT_SONNET_MODEL=implementation-spark
ANTHROPIC_DEFAULT_HAIKU_MODEL=mechanical-spark
CLAUDE_CODE_SUBAGENT_MODEL=inherit
```

**Infrastructure required:** `scripts/litellm-gateway.sh up` AND an active Tailscale
connection to the DGX Spark nodes. Verify connectivity with `tailscale ping 100.68.176.117`
before trusting this profile for factory work. Tool-use translation risk applies — LiteLLM
translates Anthropic to OpenAI format on the Spark routes; verify tool-call round-trips
with `scripts/litellm-gateway.sh test` before measured runs.

### Switching profiles

```sh
# macOS / Linux
scripts/factory-profile local     # switch to local
scripts/factory-profile hybrid    # switch to hybrid
scripts/factory-profile cloud     # switch to cloud

# Windows (PowerShell 7)
.\scripts\factory-profile.ps1 local
.\scripts\factory-profile.ps1 hybrid
.\scripts\factory-profile.ps1 cloud
```

After switching, run `direnv reload` and restart Claude:

```sh
direnv reload
# then start a new claude session — ANTHROPIC_BASE_URL is read at process start only
```

**Why restart is required:** Claude Code reads `ANTHROPIC_BASE_URL` and model alias vars
from the process environment at startup. A running Claude session does not pick up
environment changes mid-session. `direnv reload` updates the shell environment; the next
`claude` invocation inherits the new values.

### Inspecting the active profile

```sh
# macOS / Linux
scripts/factory-profile            # or: scripts/factory-profile show

# Windows
.\scripts\factory-profile.ps1     # or: .\scripts\factory-profile.ps1 show
```

Output shows the active profile name and the resolved endpoint, opus, sonnet, and haiku
values.

### Health-checking the active profile

```sh
# macOS / Linux
scripts/factory-profile doctor

# Windows
.\scripts\factory-profile.ps1 doctor
```

The doctor subcommand:
1. Checks that `ANTHROPIC_BASE_URL` is reachable (for local/hybrid) or that
   `ANTHROPIC_AWS_API_KEY` is present (for cloud).
2. Verifies that each configured model alias is actually served by the gateway (GET
   `/v1/models`).
3. Performs a live `/v1/messages` round-trip on the sonnet tier.

---

## MCP servers (shipped plugin)

The plugin ships `plugins/secops-factory/.mcp.json` with three servers:

```json
{
  "mcpServers": {
    "prism": {
      "type": "stdio",
      "command": "node",
      "args": ["${CLAUDE_PLUGIN_ROOT}/bin/prism-mcp.js"],
      "env": { "RUST_LOG": "off" }
    },
    "perplexity": {
      "type": "http",
      "url": "https://api.perplexity.ai/mcp",
      "headers": {
        "Authorization": "Bearer ${PERPLEXITY_API_KEY}"
      }
    },
    "exa": {
      "type": "http",
      "url": "https://mcp.exa.ai/mcp?exaApiKey=${EXA_API_KEY}"
    }
  }
}
```

Claude Code expands `${VAR}` references at load time. All sensitive values must be
present in the environment before Claude Code starts (direnv + `.envrc.secrets` handle
this automatically).

### exa

- Transport: HTTP
- API key: `EXA_API_KEY` (set in `.envrc.secrets`)
- No Node.js or binary required

### perplexity

- Transport: HTTP (Streamable HTTP MCP, launched 2026-07-31)
- Endpoint: `https://api.perplexity.ai/mcp`
- API key: `PERPLEXITY_API_KEY` (set in `.envrc.secrets`, injected as Bearer token)
- No Node.js or binary required
- If your Claude Code version does not support Streamable HTTP transport, fall back to the
  stdio npm launcher — see the commented example in `docs/mcp.json.example`

### prism

- Transport: stdio (via a thin Node.js launcher)
- Launcher: `bin/prism-mcp.js` — resolves the correct binary name (`prism` on macOS/Linux,
  `prism.exe` on Windows) from the `CLAUDE_PLUGIN_DATA` directory
- Requires: **Node.js >= 18** and the **prism binary** present in `$CLAUDE_PLUGIN_DATA`
- `RUST_LOG=off` is mandatory: Rust tracing output written to stdout corrupts MCP JSON-RPC
  framing

**Environment variables used by `bin/prism-mcp.js` at runtime:**

| Variable | Set by | Purpose |
|----------|--------|---------|
| `CLAUDE_PLUGIN_DATA` | `activate` skill | Directory where the prism binary was downloaded |
| `CLAUDE_PROJECT_DIR` | Claude Code runtime | Project directory; the launcher derives the prism config path as `$CLAUDE_PROJECT_DIR/.secops/prism` |
| `RUST_LOG` | `.mcp.json` env block | Forced to `off` to suppress tracing output |

**Prism binary installation:**

The binary is downloaded by the `activate` skill, which detects your OS and architecture
and places the correct build in `$CLAUDE_PLUGIN_DATA`:

```
/secops-factory:activate
```

If the binary is missing, `bin/prism-mcp.js` exits with exit code 1 and prints a clear
remediation message pointing to the `activate` skill.

**Prism sensor credentials:**

Sensor credentials (URLs and access tokens for Claroty xDome and other Prism data sources)
are set via the OS keyring using `prism credential set`, not in any environment variable or
file. Pipe the credential value on stdin:

```sh
echo "your-sensor-token" | prism credential set --sensor-id <id> --key api-token
```

The plugin `.mcp.json`, `.envrc`, and `.envrc.secrets` layers never hold Prism sensor
credentials. This is by design (AD-017): keyring isolation ensures sensor tokens are not
accessible to any process that reads the project environment.

---

## Linux auto-launch shortcut

### Shell function (recommended)

Add a `secops` function to `~/.bashrc` or `~/.zshrc`. When called, it `cd`s into the
project (which triggers direnv to load the active profile) and launches Claude:

```bash
# Add to ~/.bashrc or ~/.zshrc
secops() {
  cd /path/to/secops-factory && claude
}
```

Replace `/path/to/secops-factory` with the absolute path to your clone. The `cd` triggers
direnv, which sets `ANTHROPIC_BASE_URL` and all profile vars before `claude` starts.

Reload your shell:

```bash
source ~/.bashrc   # or source ~/.zshrc
```

Then launch with:

```bash
secops
```

### GNOME desktop launcher

Create `~/.local/share/applications/secops-factory.desktop`:

```ini
[Desktop Entry]
Name=SecOps Factory
Comment=Claude Code ICS/OT security plugin
Type=Application
Exec=gnome-terminal --working-directory=/path/to/secops-factory -- bash -lc 'claude; exec bash'
Icon=utilities-terminal
Terminal=false
Categories=Security;Development;
```

Replace `/path/to/secops-factory` with your absolute clone path. The
`--working-directory` flag causes gnome-terminal to open in the project directory, which
fires the direnv hook before `claude` starts. The `exec bash` tail keeps the terminal
open after Claude exits.

Make it executable and register it:

```bash
chmod +x ~/.local/share/applications/secops-factory.desktop
update-desktop-database ~/.local/share/applications/
```

The launcher will appear in the GNOME Activities search as "SecOps Factory".

### KDE / Konsole variant

```ini
[Desktop Entry]
Name=SecOps Factory
Comment=Claude Code ICS/OT security plugin
Type=Application
Exec=konsole --workdir /path/to/secops-factory -e bash -lc 'claude; exec bash'
Icon=utilities-terminal
Terminal=false
Categories=Security;Development;
```

Install the same way (`chmod +x`, `update-desktop-database`).

### macOS equivalent (optional)

The simplest approach is the same shell function in `~/.zshrc`:

```zsh
secops() {
  cd /path/to/secops-factory && claude
}
```

For a dock shortcut, create a small Automator application that runs the equivalent shell
command, or use a terminal profile (Terminal.app or iTerm2) set to open at the project
directory with `claude` as the startup command.

---

## Verify & troubleshoot

### Running secops-health

Inside a Claude Code session started from the project directory:

```
/secops-factory:secops-health
```

A fully healthy output ends with:

```
| Category        | Status      | Notes                      |
|-----------------|-------------|----------------------------|
| jr CLI          | PASS        | authenticated               |
| Perplexity MCP  | PASS        | tools available             |
| Data Files      | PASS        | 8/8 present                 |
| Templates       | PASS        | 5/5 present                 |
| Checklists      | PASS        | 15/15 present               |
| Skills          | PASS        | all SKILL.md files found    |
| Windows Prereqs | PASS / SKIP | SKIP on macOS/Linux         |

Overall: HEALTHY
```

On Windows, the "Windows Prereqs" row runs all six prerequisite checks (pwsh 7.4+,
native bash, direnv on PATH, bash_path pinned, Node.js 18+, prism binary present) and
prints inline remediation for any failure. On macOS and Linux, that row is silently
skipped.

### Troubleshooting table (Windows direnv)

| Symptom | Root cause | Fix |
|---------|-----------|-----|
| `.envrc` silently skipped; no profile message on `cd` | direnv resolving `C:\Windows\System32\bash.exe` (WSL stub) | Pin `bash_path` in `~/.config/direnv/direnv.toml` and set `$env:DIRENV_BASH` in `$PROFILE` (see [Install & hook direnv](#install--hook-direnv-per-shell)) |
| `direnv status` shows `bash: C:\Windows\System32\bash.exe` | Same WSL-bash hijack | Same fix as above |
| Hook appears loaded but `ANTHROPIC_BASE_URL` never set | PowerShell 5.1 in use (hook is a silent no-op) | Switch to `pwsh` (PowerShell 7); check with `$PSVersionTable.PSVersion.Major` — must be ≥ 7 |
| `can't find bash` error from direnv | Cross-drive `bash_path` (repo on `C:`, Git on `D:`) or Git not installed | Ensure Git for Windows is on the same drive as your repo; verify with `Get-Command bash` |
| PATH variables containing Unix-style paths rejected by native tools | cygpath translation missing | In `.envrc`, use `cygpath -w <path>` for single paths and `cygpath -p` for PATH-style lists when setting vars consumed by Win32 tools |
| direnv blocked: "run `direnv allow`" | First `cd` into project; direnv security prompt | Run `direnv allow` once per directory — this approval persists |
| `ANTHROPIC_BASE_URL` change not picked up | Claude reads env vars at startup; running session not updated | Run `direnv reload` then start a new Claude session |
| prism MCP fails to start; `CLAUDE_PLUGIN_DATA is not set` | `activate` skill has not been run | Run `/secops-factory:activate` to download the prism binary |
| prism MCP fails; `Prism binary not found at ...` | prism binary not in `$CLAUDE_PLUGIN_DATA` | Run `/secops-factory:activate` to download the correct OS/arch build |

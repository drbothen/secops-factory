## Summary

Two-part packaging / tooling change — no production logic modified.

### Part 1: Shipped parameterized plugin `.mcp.json`

Adds `plugins/secops-factory/.mcp.json` declaring three MCP servers for plugin consumers:

| Server | Transport | Key notes |
|---|---|---|
| `prism` | stdio `${CLAUDE_PLUGIN_DATA}/prism` | Credential-opaque. Prism manages sensor credentials in its OS keyring via `prism credential set`. The MCP layer passes **no secrets** — only `RUST_LOG=off`. Sensor URLs resolved from `--config-dir ${CLAUDE_PROJECT_DIR}/.secops/prism`. |
| `perplexity` | stdio `npx @perplexity-ai/mcp-server` | Requires `PERPLEXITY_API_KEY` in env (interpolated via `${PERPLEXITY_API_KEY}`). |
| `exa` | HTTP `https://mcp.exa.ai/mcp?exaApiKey=${EXA_API_KEY}` | Requires `EXA_API_KEY` in env (interpolated in URL query param). |

All three use `${VAR}` / `${CLAUDE_PLUGIN_DATA}` / `${CLAUDE_PROJECT_DIR}` interpolation — zero hard-coded values. Auto-loaded by the plugin system; no `plugin.json` change needed.

**End-user requirement:** export `EXA_API_KEY` and `PERPLEXITY_API_KEY` before activating the plugin. Prism's binary is provisioned to `${CLAUDE_PLUGIN_DATA}` by the `activate` skill.

### Part 2: `.envrc` profile session-redirection layer (ported from `local_ai_macbook`)

Adds a committable, secret-free Claude session-redirection configuration so developers can switch model backends without touching environment manually:

| File | Purpose |
|---|---|
| `.envrc` | 3-layer loader: non-secret AWS settings → sources `.envrc.secrets` (gitignored) → sources active `profiles/<profile>.env` last (wins on conflicts) |
| `profiles/cloud.env` | All-frontier: Claude Opus 4.8 via AWS. Current pre-project default. |
| `profiles/hybrid.env` | Frontier judgment (Opus 4.8 via AWS) + local execution tiers via LiteLLM `:4100`. Recommended working profile. |
| `profiles/local.env` | DGX Spark / Tailscale: both implementation and mechanical tiers routed to Spark nodes via LiteLLM `:4100`. Includes translation-risk note (OpenAI-native nodes). |
| `.factory-profile` | Default active profile: `hybrid` |
| `scripts/factory-profile` | CLI switcher: `factory-profile [local\|hybrid\|cloud\|doctor]`. Writes to `.factory-profile`; tells the user when a `direnv reload` + Claude restart is needed. `doctor` sub-command runs a live connectivity + round-trip check against the active backend. |
| `scripts/migrate-mcp-keys.sh` | One-shot idempotent migration tool: extracts literal key values from `.mcp.json` into `.envrc.secrets`, replaces them with `${VAR}` references, verifies no residue remains. |
| `.envrc.secrets.example` | Template for `.envrc.secrets` (gitignored). Documents all required key names with empty values. |

### Secret hygiene

The root `.mcp.json` previously held literal API keys for Perplexity, Tavily, and Context7 in a gitignored file. This PR:

1. **Makes `.mcp.json` committable and secret-free** — all three keys replaced with `${PERPLEXITY_API_KEY}`, `${TAVILY_API_KEY}`, `${CONTEXT7_API_KEY}` references. Claude Code expands `${VAR}` in `.mcp.json` fields at load time.
2. **Commits the now-clean `.mcp.json`** alongside the new `.envrc`.
3. **Updates `.gitignore`** — removes the blanket `.envrc` and `.mcp.json` exclusions (those files are now secret-free), adds `.envrc.secrets` and `.envrc.backup-*` as the gitignored secrets boundary.
4. **`migrate-mcp-keys.sh`** ships as a helper for any consumer who has an older literal-key `.mcp.json` they want to sanitize before committing.

## Files changed

```
.envrc                           (new) — 3-layer direnv loader, secret-free
.envrc.secrets.example           (new) — template for gitignored secrets file
.factory-profile                 (new) — default profile: hybrid
.gitignore                       (mod) — drop .envrc/.mcp.json ignores; add .envrc.secrets/.envrc.backup-*
.mcp.json                        (new) — project-level MCP config, secret-free
plugins/secops-factory/.mcp.json (new) — shipped plugin MCP config (prism/perplexity/exa)
profiles/cloud.env               (new)
profiles/hybrid.env              (new)
profiles/local.env               (new)
scripts/factory-profile          (new) — profile switcher + doctor
scripts/migrate-mcp-keys.sh      (new) — one-shot key migration helper
```

## Security notes

- **No secrets in diff.** All `${VAR}` placeholders; `.envrc.secrets` is gitignored and not present in this diff.
- **`.gitignore` change is additive on secrets.** The removed lines (`.envrc`, `.mcp.json`) covered files that are now provably secret-free. The replacement lines (`.envrc.secrets`, `.envrc.backup-*`) cover the actual secrets boundary.
- **Prism is credential-opaque by design.** The MCP layer passes only `RUST_LOG=off`; Prism reads all sensor credentials from its own OS keyring.
- **`migrate-mcp-keys.sh` verifies its own output** — after writing the sanitized `.mcp.json` it scans for residual `pplx-`/`tvly-`/`ctx7sk-` patterns and exits non-zero if any remain.

## Test plan

- [ ] `direnv allow` in repo root → `vsdd profile: hybrid -> http://localhost:4100` logged (or AWS default for cloud)
- [ ] `scripts/factory-profile cloud` → `.factory-profile` updated, `show` output matches cloud profile
- [ ] `scripts/factory-profile doctor` on cloud profile → endpoint and key checks pass
- [ ] `plugins/secops-factory/.mcp.json` loads in Claude without errors; `prism` / `perplexity` / `exa` servers available
- [ ] `scripts/migrate-mcp-keys.sh` on an already-clean `.mcp.json` → "Nothing to do" idempotent exit 0
- [ ] CI BATS suite passes (no plugin logic changed)

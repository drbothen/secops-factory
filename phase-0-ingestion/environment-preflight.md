---
artifact: environment-preflight
phase: phase-0-ingestion
created: 2026-07-19
author: dx-engineer
---

# Environment Preflight Report

Pre-pipeline environment setup check for VSDD brownfield onboarding of
`/Users/jmagady/Dev/secops-factory`.

---

## 1. Core Toolchain

| Tool | Status | Version | Minimum | Notes |
|------|--------|---------|---------|-------|
| git | PASS | 2.50.1 (Apple Git-155) | 2.40 | |
| direnv | PASS | 2.35.0 | any | |
| just | PASS | 1.43.1 | any | |
| lefthook | PASS | 2.1.1 | any | |
| jq | PASS | 1.6 | any | |
| python3 | PASS | 3.11.7 | any | |
| node | PRESENT | 25.2.1 | N/A | Not required for markdown-only plugin project; noted for completeness |

All required core tools are installed. No installations were needed.

---

## 2. Environment Files

### .envrc

- Path: `/Users/jmagady/Dev/secops-factory/.envrc`
- Status: EXISTS, 15 lines
- direnv status: LOADED and ALLOWED (`Loaded RC allowed 0`; allowPath confirmed present)
- direnv allowed: YES — `direnv allow` was previously run

### .env.example

- Path: `/Users/jmagady/Dev/secops-factory/.env.example`
- Status: MISSING

The `.env.example` template file does not exist. Per DX Engineer protocol, `.env.example`
starts empty at init and is populated incrementally as product API keys are identified
during Phase 1 DTU assessment. This is not blocking for Phase 0 codebase ingestion, but
it should be created (empty) to establish the committed template.

Recommendation: create `/Users/jmagady/Dev/secops-factory/.env.example` as an empty file
committed to the repo. The state-manager or orchestrator can delegate this as a non-blocking
follow-up before Phase 1.

### .env (gitignored runtime file)

Not checked for existence (gitignored, human-managed). No API keys are expected to be
required for Phase 0 codebase analysis.

---

## 3. MCP Preflight

Checked locations (read-only, no API calls made):
- `~/.claude.json` (global mcpServers block)
- `~/.claude/settings.json` (global user settings)
- `/Users/jmagady/Dev/secops-factory/.claude/settings.json`
- `/Users/jmagady/Dev/secops-factory/.claude/settings.local.json`
- `/Users/jmagady/Dev/secops-factory/.mcp.json` (absent)

| MCP Server | Status | Found In |
|-----------|--------|----------|
| context7 | AVAILABLE | `~/.claude.json` (global) |
| perplexity | MISSING | Not found in any config |
| tavily | MISSING | Not found in any config |

**perplexity MISSING — BLOCKING for research-dependent steps.**
The `vsdd-factory:research-agent`, `vsdd-factory:security-reviewer` (Step 0e-sec),
and planning-research steps all invoke `mcp__perplexity__*` tools. Without a configured
perplexity MCP server, those steps will fail at execution time. This affects:
- Step 0e-sec: security audit (CVE and supply-chain research)
- Any step using `vsdd-factory:research-agent`
- Adversarial review steps that do web searches

**tavily MISSING — WARNING (secondary research source).**
Tavily is a supplementary search/crawl tool used alongside perplexity. Its absence is
lower severity than perplexity but it is listed in the vsdd-factory:research-agent tool
set.

**context7 AVAILABLE — PASS.**
Used by agents for library documentation lookups. Globally configured.

To add perplexity and tavily: configure them in
`/Users/jmagady/Dev/secops-factory/.claude/settings.json` under the `mcpServers` key,
or in `~/.claude/settings.json` for global availability. Key names required are
`PERPLEXITY_API_KEY` and `TAVILY_API_KEY` — no values are logged here.

---

## 4. LLM Routing

This deployment runs inside Claude Code via the `vsdd-factory` plugin. Multi-model
routing for adversary and holdout agents (GPT-4, Gemini, etc.) is handled by the
plugin's agent definition files, not LiteLLM. No standalone LiteLLM proxy is expected.

Confirmed: the factory engine at `/Users/jmagady/Dev/dark-factory` (not modified)
defines model routing via agent `.md` frontmatter. No health check of a LiteLLM proxy
endpoint was performed or is required.

---

## 5. Supply-Chain Sanity

Searched for package manifests (`package.json`, `Cargo.toml`, `requirements.txt`,
`go.mod`, `pyproject.toml`, `setup.py`) in all directories except `.reference/` and
`node_modules/`.

Result: NO package manifests found in the auditable project tree.

Confirmed: this repo is a markdown-only Claude Code plugin marketplace (agents, skills,
hooks). There is no compiled code and no dependency graph to audit at this time.

Note: `/Users/jmagady/Dev/secops-factory/.reference/jira-cli/Cargo.toml` was found but
is excluded from supply-chain scope per task instructions (reference material only).

---

## 6. Factory Worktree

- Main worktree: `/Users/jmagady/Dev/secops-factory` on branch `main`
- Factory artifacts worktree: `/Users/jmagady/Dev/secops-factory/.factory` on branch `factory-artifacts`
- Remote tracking: `origin/factory-artifacts` confirmed present

The `.factory/` worktree is correctly mounted and on the expected branch.

---

## Summary

| Check | Result |
|-------|--------|
| Core toolchain | PASS — all 7 tools present |
| .envrc loaded | PASS — allowed and active |
| .env.example | MISSING — non-blocking at Phase 0; create before Phase 1 |
| context7 MCP | AVAILABLE |
| perplexity MCP | MISSING — BLOCKING for research steps |
| tavily MCP | MISSING — WARNING |
| LLM routing | CONFIRMED — handled by plugin agent config, no LiteLLM check needed |
| Supply chain | PASS — no auditable package manifests present |
| .factory worktree | PASS — mounted on factory-artifacts |

---

## ENVIRONMENT_GATE: FAIL

**Blocking reason:** `perplexity` MCP server is not configured in any Claude Code
settings file. This blocks Step 0e-sec (security audit / CVE research) and all
`vsdd-factory:research-agent` invocations in the brownfield pipeline.

**Required action before research-dependent steps:** Add perplexity MCP server to
`/Users/jmagady/Dev/secops-factory/.claude/settings.json` (or globally). Key name:
`PERPLEXITY_API_KEY`. Report only pass/fail — never log the key value.

**Non-blocking gaps to address:**
- Create `/Users/jmagady/Dev/secops-factory/.env.example` (empty committed template)
- Configure `tavily` MCP server (secondary research source)

Steps that do NOT require perplexity (pure file analysis) can proceed:
Step 0a (codebase-analyzer), Step 0b (architect — local docs), Step 0c
(consistency-validator), and Step 0f (project context synthesis).

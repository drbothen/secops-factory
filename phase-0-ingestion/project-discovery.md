# Project Discovery — secops-factory

_Phase 0, Step 0a (Project Discovery). Agent: codebase-analyzer (T1, read-only). Generated 2026-07-19._

## 1. Project Identity

| Attribute | Value | Evidence |
|-----------|-------|----------|
| Repo name | `secops-factory` | `.claude-plugin/marketplace.json` |
| Repo kind | Claude Code **plugin marketplace** (single-plugin) | `.claude-plugin/marketplace.json` `plugins[]` |
| Product | The plugin at `plugins/secops-factory/` | `plugins/secops-factory/.claude-plugin/plugin.json` |
| Version | `0.9.0` (marketplace + plugin manifest in sync) | `.claude-plugin/marketplace.json`, `plugins/secops-factory/.claude-plugin/plugin.json` |
| Owner / author | `drbothen` (marketplace owner + plugin author); git author of record: `Joshua Magady` | manifests; `git shortlog` |
| Homepage / repo | `https://github.com/drbothen/secops-factory` | `plugins/secops-factory/.claude-plugin/plugin.json` |
| License | MIT | `LICENSE`, `plugin.json` |
| Domain | ICS/OT security operations: CVE enrichment, event investigation, MITRE ATT&CK mapping, adversarial quality review, Jira-native metrics | `README.md`, `.claude-plugin/marketplace.json` `description` |

**One-line summary:** A markdown-defined Claude Code plugin that turns Claude into an ICS/OT SecOps analyst, packaged in a single-plugin marketplace repo, with shell/PowerShell enforcement hooks, BATS tests, and a factory-artifacts release workflow.

## 2. Tech Stack

This is **not** a compiled/interpreted application codebase — it is a **declarative Claude Code plugin** (markdown agents/skills/commands + JSON manifests + shell hooks + YAML templates). There is **no** `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `Makefile`, or `justfile`.

| Layer | Technology | Evidence |
|-------|-----------|----------|
| Primary artifact language | Markdown (agents, skills `SKILL.md`, commands, checklists, data KBs, docs, rules) | 76 `.md` files, 5,315 LOC under `plugins/secops-factory/` |
| Manifests / config | JSON (`marketplace.json`, `plugin.json`, `hooks.json`, `hooks.json.windows`) | `.claude-plugin/`, `plugins/secops-factory/hooks/` |
| Hooks | Bash (`*.sh`, 7 files, 400 LOC) + PowerShell (`*.ps1`, 6 files, 281 LOC) sibling pairs | `plugins/secops-factory/hooks/` |
| Templates | YAML (5 files, 478 LOC) | `plugins/secops-factory/templates/` |
| Test framework | **BATS** (bats-core), 4 files, 1,004 LOC (`hooks.bats`, `skills.bats`, `integration.bats`, `parity.bats`) + `run-all.sh` runner | `plugins/secops-factory/tests/` |
| Test prerequisites | `bash -n` syntax check, `python3 -c "import yaml"` YAML validation, optional `pwsh` for `.ps1` parity | `tests/run-all.sh` |
| CI/CD | GitHub Actions: `ci.yml` (BATS + structure + shellcheck), `release.yml` (tag-triggered, version-gated), `security.yml` (Semgrep, weekly cron) | `.github/workflows/` |
| Lint / SAST | `shellcheck` (hooks), `jq` (JSON validation), `semgrep` (config: auto) | `ci.yml`, `security.yml` |
| Dependency mgmt | None native. External runtime deps only (see §6) | — |
| Local env | `direnv` (`.envrc`) routing Claude Code to Anthropic API via AWS Marketplace; MCP servers via `.mcp.json` (npx-launched) | `.envrc`, `.mcp.json` |

## 3. Documentation Inventory

| Document | Role | Path |
|----------|------|------|
| `README.md` | **Primary context source** (no `FACTORY.md` present) — features, install, command catalog, workflow diagrams, Iron Laws, structure | `/README.md` |
| `CHANGELOG.md` | Keep-a-Changelog + SemVer; history back to v0.5.x through v0.9.0 | `/CHANGELOG.md` |
| `RELEASING.md` | Canonical release procedure (PR-based, tag-after-squash-merge, dual version-file validation, separate `drbothen/claude-mp` marketplace bump) | `/RELEASING.md` |
| `rules/secops-protocol.md` | Field conventions (CVE/CVSS/EPSS/KEV formats), path conventions (`${CLAUDE_PLUGIN_ROOT}/`), commit format, disposition vocabulary | `plugins/secops-factory/rules/secops-protocol.md` |
| `docs/AGENT-SOUL.md` | Engine-wide agent principles | `plugins/secops-factory/docs/AGENT-SOUL.md` |
| `docs/guide/*` (8 guides) | getting-started, vulnerability-enrichment, event-investigation, adversarial-review, advisory-creation, commands-reference, agents-reference, hooks-reference | `/docs/guide/` |

**Absent (flagged):** No `FACTORY.md`, `CONTRIBUTING.md`, or `ARCHITECTURE.md` at repo root. Architectural intent is distributed across `README.md`, `RELEASING.md`, `rules/secops-protocol.md`, and the `docs/guide/` set.

## 4. Directory Structure (top 3 levels)

```
secops-factory/
├── .claude-plugin/marketplace.json      # marketplace manifest (single plugin, v0.9.0)
├── .github/workflows/{ci,release,security}.yml
├── docs/guide/                          # 8 marketplace-level user guides
├── plugins/secops-factory/              # THE PRODUCT
│   ├── .claude-plugin/plugin.json       # plugin manifest + hooks registration
│   ├── agents/                          # 6 agents (+ orchestrator/ subdir w/ 3 workflows)
│   ├── commands/                        # 20 slash-command entry points
│   ├── skills/<name>/SKILL.md           # 19 skills
│   ├── checklists/                      # 15 quality checklists (8 CVE + 7 event)
│   ├── data/                            # 10 knowledge-base docs
│   ├── templates/                       # 5 YAML/MD output templates
│   ├── hooks/                           # 6 hooks × {.sh,.ps1} + hooks.json(.windows)
│   ├── rules/secops-protocol.md
│   ├── docs/{AGENT-SOUL.md, guide/}
│   └── tests/                           # 4 .bats suites + run-all.sh
├── README.md · CHANGELOG.md · RELEASING.md · LICENSE
├── .envrc · .mcp.json · .gitattributes · .gitignore
├── .factory/                            # pipeline state (EXCLUDED; gitignored, worktree-mounted)
└── .reference/jira-cli/                 # reference material only (EXCLUDED; gitignored)
```

**Inferred architecture:** A layered Claude Code plugin. Entry points are `commands/*.md` (slash commands) → delegate to `skills/<name>/SKILL.md` (procedures) → invoke `agents/*.md` (personas: analyst/reviewer/etc.) → grounded by `data/*` (KBs), shaped by `templates/*`, gated by `checklists/*` and `hooks/*`. `orchestrator/` holds a companion agent + three workflow definitions (enrichment, investigation, review-convergence).

**Unconventional patterns:**
- Cross-platform hook parity: every `.sh` has a byte-parity `.ps1` sibling, enforced by CI and `parity.bats`; `.gitattributes` pins LF endings for parity testing.
- `.factory/` is an **orphan `factory-artifacts` branch** worktree-mounted locally and in CI (see §7); gitignored on `main`.
- Release config lives on the factory-artifacts branch (`.factory/release-config.yaml`), not on `main`.

## 5. Git History Analysis

| Metric | Value |
|--------|-------|
| Total commits | 38 (entire history) |
| Commits in last 3 months | 11 (window ~2026-04-19 → 2026-07-19) |
| Date range | first `2026-04-09`, latest `2026-07-19` |
| Contributors | 1 — **Joshua Magady** (all 38 commits; note: marketplace/plugin author metadata says `drbothen`) |
| Commit convention | **Conventional Commits** (`feat(scope):`, `chore:`, `docs:`, `ci:`). `rules/secops-protocol.md` additionally specifies a `secops(<scope>):` form for plugin-content commits |
| PR discipline | Every substantive change lands via numbered PR (#1–#11), squash-merged |
| Branching strategy | `main` (default, protected — direct push blocked by vsdd `verify-git-push` hook per RELEASING.md) + short-lived `feat/*` and `docs/*` branches + `release/vX.Y.Z` branches + `factory-artifacts` orphan branch |
| Release model | Tag `vX.Y.Z` cut **after** squash-merge on the merge commit; `release.yml` validates tag == `plugin.json` version == `marketplace.json` version |
| Hot files (last 3mo, by change count) | `README.md` (9), `CHANGELOG.md` (8), `plugin.json` (4), `marketplace.json` (4), `tests/skills.bats` (3), `docs/guide/getting-started.md` (3), `generate-metrics/SKILL.md` (2), `ci.yml` (2) |

**Recent development focus (last 3 months):** orchestrator companion + activation flow (v0.6.0), cross-platform hooks + session greeting (v0.7.0), Jira-native metrics suite (v0.8.0), concrete Jira metrics recipes (v0.9.0), then CI hardening (SHA-pinned actions, timeouts, Semgrep). The trajectory is feature-additive with strong release hygiene.

## 6. External Dependencies (runtime)

| Dependency | Role | Requirement | Evidence |
|-----------|------|-------------|----------|
| `jr` CLI (`jira-cli`, Rust, `Zious11/jira-cli`) | JIRA read/edit/comment/move/list/assets — the sole JIRA integration path (via Bash) | **Required** | `README.md`, `rules/secops-protocol.md` |
| Perplexity MCP (`@perplexity-ai/mcp-server`) | CVE research + fact verification (`perplexity_search/ask/reason/research`, tiered by CVSS) | Recommended; graceful fallback to `WebSearch`/`WebFetch` against NVD/FIRST/CISA | `README.md`, `rules/secops-protocol.md`, `.mcp.json` |
| Tavily MCP, Playwright MCP, Context7 MCP | Present in local `.mcp.json` (dev environment) | Optional/dev | `.mcp.json` |
| Authoritative intel sources | NVD, CISA KEV, FIRST EPSS, MITRE ATT&CK | Data-source references | `README.md`, `data/*` |
| `bats-core`, `shellcheck`, `jq`, `semgrep`, `python3`(yaml), optional `pwsh` | CI/test tooling | Dev/CI | `tests/run-all.sh`, `.github/workflows/*` |

## 7. Repo Boundaries (per task scope)

- **In scope:** `plugins/secops-factory/` (the product), marketplace docs, `.github/workflows/`, `README.md`, `CHANGELOG.md`, `RELEASING.md`, root config.
- **Excluded — noted only:** `.factory/` (pipeline state on `factory-artifacts` orphan branch; gitignored, worktree-mounted; hosts `release-config.yaml`), `.reference/jira-cli/` (reference material for the external `jr` CLI dependency — exists but not deep-analyzed), `.git`, `.claude`.

## 8. Ambiguities & Flags

1. **SECURITY — live secrets in untracked files (HIGH).** `.envrc` contains a plaintext `ANTHROPIC_AWS_API_KEY`; `.mcp.json` contains plaintext `PERPLEXITY_API_KEY`, a Tavily key in a URL, and a `CONTEXT7_API_KEY`. `.gitignore` lists only `.factory/` and `.reference/` — **neither `.envrc` nor `.mcp.json` is gitignored**, and both show as untracked (`??`) in git status. Risk of accidental commit of live credentials. Recommend adding both to `.gitignore` and rotating any exposed keys. (Key values intentionally not reproduced here.)
2. **Author identity vs. ownership.** All commits are authored by `Joshua Magady`; manifests declare owner/author `drbothen`. Likely the same operator under different identities, but flagged for confirmation. Per MEMORY: commits omit Co-Authored-By attribution by design.
3. **README count drift.** README "What's Inside" cites 129 tests and mixed skill counts (11 vs 19 in different sections); actual on-disk: 19 skills, 20 commands, 6 agents, 15 checklists, 10 data KBs, 5 templates, 4 BATS suites. Minor doc/reality drift worth reconciling in later passes.
4. **No standard build/dependency manifest.** Absence of `package.json`/`Cargo.toml` etc. is expected for a declarative plugin, but means "build/test commands" are defined only by `tests/run-all.sh` and CI YAML — not a package script.
5. **Unknown/external tools flagged for research delegation (DF-027):** `jr` (`Zious11/jira-cli`, aka `jira-cli-rs`) and the Claude Code plugin/marketplace + MCP execution model. Both are documented in-repo; delegate to research-agent only if deeper external verification is needed.

## Quality Gate Checklist

- [x] Every finding cites a specific file path
- [x] Tech-stack claims backed by configuration/manifest evidence
- [x] Ambiguities flagged explicitly (§8)
- [x] Git history covers commit count, contributor count, hot files, commit convention, branching
- [x] Unknown frameworks/tools flagged for research-agent delegation (§8.5)

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.1] - 2026-04-13

Release infrastructure and CI/CD.

### Added
- **CI workflow** (`.github/workflows/ci.yml`) — BATS tests, plugin structure validation, shellcheck on hooks (3 parallel jobs on push/PR)
- **Release workflow** (`.github/workflows/release.yml`) — tag-triggered validation + GitHub Release creation with CHANGELOG excerpt
- **Release config** (`.factory/release-config.yaml`) — declarative manifest for vsdd-factory release skill
- Retroactive git tags and GitHub Releases for all prior versions (v0.1.0 through v0.5.0)
- Version field in marketplace.json for release validation

### Changed
- CHANGELOG backfilled with complete entries for all 7 prior releases
- Bump `actions/checkout` from v4 to v6 in all workflows (Node.js 20 deprecation)

## [0.5.0] - 2026-04-12

URL input support for advisory creation and Perplexity fallback hardening.

### Added
- **create-advisory** now accepts URLs as input — fetches page content with WebFetch, extracts CVEs, severity, affected products, and generates advisory from it
- Actionable Perplexity fallback in all 6 discipline skills — when Perplexity MCP is unavailable, skills switch to WebSearch/WebFetch with NVD and EPSS API calls instead of stopping

### Changed
- All 13 command wrappers updated with `secops-factory:` namespace prefix for skill invocations
- advisory-writer agent updated with URL handling instructions
- create-advisory argument-hint updated to `<topic|CVE-ID|URL>`

### Fixed
- Commands now use correct namespaced skill references (`/secops-factory:skill-name`)

## [0.4.2] - 2026-04-11

Packaging and distribution fixes.

### Added
- Marketplace install instructions in README
- Update instructions in README (`/plugin marketplace update` + `/plugin update`)

### Changed
- `.reference/jira-cli` moved to `.gitignore` (removed embedded submodule)
- create-advisory and scan-threats command bodies standardized to match working pattern

### Fixed
- Command body format standardized across all commands to match the pattern that Claude Code actually executes

## [0.4.0] - 2026-04-11

Major refactor: replace Atlassian MCP server dependency with jr CLI for all JIRA operations.

### Changed
- **Breaking:** All JIRA operations now use `jr` CLI (jira-cli Rust binary) instead of Atlassian MCP server
- read-ticket skill rewritten to use `jr issue view` and `jr issue assets`
- update-jira skill rewritten to use `jr issue edit`, `jr issue comment`, and `jr issue move`
- enrich-ticket and investigate-event skills updated for jr CLI commands
- require-review hook updated to check for `Bash` tool calls containing `jr issue` instead of MCP tool names
- hooks.json matchers updated from `mcp__atlassian__*` to `Bash` for JIRA operations
- secops-health command updated to check for `jr` binary instead of Atlassian MCP server
- security-analyst and security-reviewer agent prompts updated with jr CLI instructions
- secops-protocol rules updated with jr CLI field conventions
- README updated with jr CLI installation and authentication instructions
- Getting started guide rewritten for jr CLI workflow

### Fixed
- Integration tests updated to reflect jr CLI tool patterns

## [0.3.0] - 2026-04-10

New advisory workflow for creating structured security advisories targeting IT, ICS/OT, or combined audiences.

### Added
- **advisory-writer** agent (Sonnet) — researches threats and generates advisories using built-in or custom templates
- **create-advisory** skill with Iron Law: `NO ADVISORY PUBLICATION WITHOUT SOURCE VERIFICATION FIRST`. Supports `--type it|ics|combined` for audience selection, `--template <path>` for custom organization templates, source verification gate, and interactive advisory type prompt
- **scan-threats** skill — scans CISA, NVD, KEV, vendor PSIRTs, and ICS-CERT for advisory-worthy items. Scored by severity, exploit status, KEV listing, sector relevance, recency, and asset prevalence (threshold >= 6.0). Supports `--sector`, `--severity`, `--days` filters
- **security-advisory-tmpl.md** template — CSAF Security Advisory profile + CISA ICS-CERT format. 12 sections with conditional ICS/OT block. Supports TLP marking, dual remediation timelines, detection rules (Snort/Sigma/YARA), and revision history
- `/create-advisory` and `/scan-threats` commands
- **advisory-creation.md** documentation with Mermaid workflow diagram
- **getting-started.md** updated with workflow overview diagram
- 11 new tests: Iron Law, Announce, Red Flags, custom template support, interactive type choice, source verification gate, advisory template existence, agent frontmatter, scan-threats scoring/fallback

### Changed
- README updated with advisory commands, new agent/skill/command counts, version badge
- Commands reference updated with advisory commands
- Total tests: 72 (45 skills + 16 hooks + 11 integration)

## [0.2.1] - 2026-04-09

Integration test suite validating hook behavior against the Claude Code protocol.

### Added
- **integration.bats** — 228-line integration test suite covering:
  - Hook output format validation (JSON structure, permissionDecision envelope)
  - PreToolUse hook allow/block decision paths
  - PostToolUse non-blocking hook behavior
  - SubagentStop hook validation
  - End-to-end enrichment-then-review workflow simulation
- run-all.sh updated to include integration test suite

## [0.2.0] - 2026-04-09

Structural enhancements aligning with VSDD factory patterns.

### Added
- **Orchestrator workflows** (3 files): enrichment-workflow.md, investigation-workflow.md, review-convergence-workflow.md — step-by-step orchestration sequences for the three main pipelines
- **disposition-guard.sh** hook — blocks Write tool when saving disposition without reasoning chain
- **handoff-validator.sh** hook — validates reviewer agent output is non-empty on SubagentStop
- Honest convergence clause added to adversarial-review-secops skill
- Subagent delivery protocol added to review-enrichment skill
- AGENT-SOUL.md expanded with convergence and handoff principles
- 88 new lines of skill tests (Iron Law variants, Red Flags row counts, template/data portability)
- 94 new lines of hook tests (disposition-guard allow/block, handoff-validator paths)

### Changed
- hooks.json rewritten from flat array format to nested `permissionDecision` envelope format matching Claude Code protocol
- All 3 existing hook scripts (require-review, enrichment-completeness, bias-check-reminder) rewritten to output `permissionDecision` JSON envelope
- security-reviewer agent prompt trimmed (removed redundant instructions)

### Fixed
- Hook output format now matches Claude Code protocol specification

## [0.1.0] - 2026-04-08

Initial release — ICS/OT security operations plugin for Claude Code.

### Added
- **Agents (2):** security-analyst (Sonnet), security-reviewer (Opus) with domain expertise
- **Skills (6 discipline):** enrich-ticket, assess-priority, investigate-event, review-enrichment, update-jira, adversarial-review-secops — each with Iron Law, Red Flags, and Announce at Start
- **Skills (5 technique):** read-ticket, research-cve, map-attack, fact-verify, generate-metrics
- **Commands (12):** thin wrappers delegating to skills
- **Data (8 knowledge bases):** CVSS guide, EPSS guide, KEV catalog guide, MITRE ATT&CK mapping guide, cognitive bias patterns, event investigation best practices, priority framework, review best practices
- **Templates (4):** security enrichment, security review report, event investigation, event investigation review report
- **Checklists (15):** 8 CVE quality dimensions + 7 event investigation quality dimensions
- **Hooks (3):** require-review (blocks JIRA updates without review), enrichment-completeness (blocks partial saves), bias-check-reminder (non-blocking post-research)
- **Tests:** bats test suites for skills and hooks, run-all.sh runner
- **Rules:** secops-protocol.md with MCP requirements, field conventions, path conventions
- **Docs:** AGENT-SOUL.md with 10 security operations principles derived from NIST/MITRE/CISA standards

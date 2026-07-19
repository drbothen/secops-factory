---
document_type: pipeline-state
level: ops
version: "2.0"
status: active
producer: state-manager
timestamp: 2026-07-19T02:00:00Z
phase: 0
inputs: []
input-hash: "[live-state]"
traces_to: ""
project: secops-factory
mode: brownfield
current_step: "0c — convention extraction"
current_cycle: ""
dtu_required: false
---

<!--
  STATE.md SIZE BUDGET: Keep this file under 200 lines.
  Historical content belongs in cycle files, NOT here.
  Run /vsdd-factory:compact-state if this file grows past 200 lines.
-->

# Pipeline State: secops-factory

## Project Metadata

| Field | Value |
|-------|-------|
| **Product** | secops-factory (Claude Code plugin — SecOps ticket enrichment agents/skills/hooks) |
| **Repository** | https://github.com/drbothen/secops-factory.git |
| **Mode** | brownfield |
| **Language** | Bash / Markdown (Claude Code plugin) |
| **Target Workspace** | /Users/jmagady/Dev/secops-factory |
| **Engine** | /Users/jmagady/Dev/dark-factory (vsdd-factory plugin) |
| **Started** | 2026-07-19 |
| **Last Updated** | 2026-07-19 |
| **Current Phase** | 0: Codebase Ingestion |
| **Current Step** | 0c — convention extraction |

## Phase Progress

| Phase | Status | Started | Completed | Gate | Finding Progression |
|-------|--------|---------|-----------|------|---------------------|
| pre-0: Pre-pipeline | PASSED | 2026-07-19 | 2026-07-19 | PASS | — |
| 0: Codebase Ingestion | in-progress | 2026-07-19 | | | |
| 1: Spec Crystallization | not-started | | | | |
| 2: Story Decomposition | not-started | | | | |
| 3: TDD Implementation | not-started | | | | |
| 4: Holdout Evaluation | not-started | | | | |
| 5: Adversarial Refinement | not-started | | | | |
| 6: Formal Hardening | not-started | | | | |
| 7: Convergence | not-started | | | | |

## Current Phase Steps

<!-- Keep last 5 rows only. Archive older rows to cycles/<cycle>/burst-log.md. -->

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| env-preflight | dx-engineer | DONE | `.factory/phase-0-ingestion/environment-preflight.md` — PASS (after human configured MCP) |
| repo-verification | devops-engineer | DONE | `.factory/phase-0-ingestion/repo-verification.md` — PASS; PR #11 merged |
| repo-hardening | devops-engineer | DONE | SHA-pinned actions, job timeouts, security.yml; branch protection on main applied |
| worktree-health | devops-engineer | DONE | PASS — .factory/ on factory-artifacts; remote sync confirmed |
| 0a: project-discovery | codebase-analyzer | DONE | `.factory/phase-0-ingestion/project-discovery.md` |
| 0b: architecture-recovery | codebase-analyzer | DONE | `.factory/phase-0-ingestion/recovered-architecture.md`, `arch-recov-api-surface.md`, `arch-recov-integrations.md` |

## Decisions Log

| ID | Decision | Rationale | Phase | Date | Made By |
|----|----------|-----------|-------|------|---------|
| D-001 | Onboarding depth = Phase 0 only; park at 0-complete awaiting feature-request | Internal dev-tooling plugin; no active feature scope yet | pre-0 | 2026-07-19 | human |
| D-002 | market-intelligence SKIPPED | Internal dev-tooling plugin — no market research needed | pre-0 | 2026-07-19 | human |
| D-003 | design-system-extraction SKIPPED | No UI surfaces in this plugin | pre-0 | 2026-07-19 | human |

## Skip Log

| Step | Skipped? | Justification |
|------|----------|---------------|
| UX Spec | yes | CLI/agent plugin — no UI surfaces |
| Market Intelligence | yes | Internal dev-tooling plugin; no external market |
| Design System Extraction | yes | Internal dev-tooling plugin; no UI |

## Drift Items

<!-- Items flagged during codebase analysis for follow-up. Move resolved items to cycle files. -->

| ID | Item | Severity | Target Step | Flagged By | Status |
|----|------|----------|-------------|------------|--------|
| DI-001 | Live API keys in untracked, non-gitignored `.envrc` and `.mcp.json` at repo root — exposure risk on accidental commit. PR #12 merged: adds `.envrc`, `.env`, `.mcp.json`, `.claude/settings.local.json` to `.gitignore`. Keys were never committed (untracked only), no git-history exposure. Key rotation optional; 0e-sec to confirm. | HIGH | 0e-sec security audit triage | 0a project-discovery | RESOLVED |
| DI-002 | `secops-health` command has no corresponding skill directory — special-cased in CI rather than following standard command→skill convention | LOW | Phase 1 spec crystallization | 0b architecture-recovery | open |
| DI-003 | `adversarial-review-secops` skill directly references orchestrator canonical playbook — intentional layer inversion (skill depends on orchestrator artifact) | LOW | Phase 1 spec crystallization | 0b architecture-recovery | open |

## Blocking Issues

<!-- Open issues only. Move resolved issues to cycles/<cycle>/blocking-issues-resolved.md. -->

| ID | Issue | Severity | Blocking Phase | Owner | Resolution |
|----|-------|----------|----------------|-------|------------|

## Session Resume Checkpoint

| Field | Value |
|-------|-------|
| **Date** | 2026-07-19 |
| **Position** | Phase 0 — step 0c convention extraction is next |
| **Context** | Steps 0a and 0b complete. recovered-architecture.md + api-surface + integrations produced. DI-001 RESOLVED: PR #12 merged `.envrc`/`.mcp.json`/`.env`/`.claude/settings.local.json` into `.gitignore`; keys never committed; 0e-sec to confirm rotation. DI-002/DI-003 logged (architectural smells, low severity, routed to Phase 1). Codebase confirmed: declarative Claude Code plugin, layered commands→skills→agents architecture, cross-platform hook parity. |
| **Convergence counter** | n/a (Phase 0) |

## Historical Content

| Content | Location |
|---------|----------|
| Burst history | `cycles/<cycle>/burst-log.md` |
| Convergence trajectory | `cycles/<cycle>/convergence-trajectory.md` |
| Session checkpoints | `cycles/<cycle>/session-checkpoints.md` |
| Lessons learned | `cycles/<cycle>/lessons.md` |
| Resolved blockers | `cycles/<cycle>/blocking-issues-resolved.md` |

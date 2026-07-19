---
document_type: pipeline-state
level: ops
version: "2.0"
status: active
producer: state-manager
timestamp: 2026-07-19T06:00:00Z
phase: 0
inputs: []
input-hash: "[live-state]"
traces_to: ""
project: secops-factory
mode: brownfield
current_step: "0f-pre — holdout seeding"
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
| **Current Step** | 0f-pre — holdout seeding |

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
| 0c: convention-extraction | codebase-analyzer | DONE | `.factory/phase-0-ingestion/conventions.md` — 20 enforceable rules extracted; 2 style ambiguities flagged: `secops(<scope>)` vs `feat(<scope>)` commit-prefix conflict; `secops-health` anomaly tracked as DI-002 |
| 0d: spec-reverse-engineering | codebase-analyzer | DONE | `.factory/phase-0-ingestion/behavioral-contracts/` — 13 BCs recovered (BC-3.01.001–BC-3.06.001, BC-4.01.001–BC-4.04.001, BC-5.01.001, BC-6.01.001–BC-6.01.002); 7 spec ambiguities documented for Phase 1 routing: review-approval marker storage/session-persistence unspecified; require-review hook cannot recognize approval; hook/template section-name sync gap; disposition-guard body-text false-pass; handoff-validator undocumented 40-char threshold; Honest Convergence 3-item boundary ambiguity; bias-check hook trigger scope unclear |
| 0e: verification-gap-analysis | codebase-analyzer | DONE | `.factory/phase-0-ingestion/verification-gap-analysis.md` — 2 fully / 11 partially / 0 unverified of 13 BCs; verification asymmetry: hooks behaviorally tested, skills structural-only; 4 gaps logged as DI-004–DI-007; estimated remediation ~4-5 days |
| 0e5: module-criticality | codebase-analyzer | DONE | `.factory/specs/module-criticality.md` (new); `recovered-architecture.md` updated (16 Component-Map criticality fields). CRITICAL: require-review hook, update-jira skill. HIGH: 12 modules incl. disposition-guard (DI-004), hook manifests, pipeline skills, data KBs, test-suite+CI. Mutation kill-rate targets set: require-review >=95% (currently ~55-65%). SEC-001..005 in flight on `fix/phase0-security-findings`; security-audit.md commit deferred pending Disposition section. |

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
| DI-004 | disposition-guard substring false-pass live-demonstrated: header-only match passes BC-3.04 even when body text is absent — hook assert is unsound | HIGH | first Feature Mode cycle | 0e verification-gap-analysis | open |
| DI-005 | require-review hook: assign/create/fail-open paths untested — review bypass and error-path behaviors have no BATS coverage | HIGH | first Feature Mode cycle | 0e verification-gap-analysis | open |
| DI-006 | PowerShell parity tests skip silently when `pwsh` absent; CI does not assert `pwsh` presence, so `.ps1` hooks receive no static analysis in standard CI runs | HIGH | first Feature Mode cycle | 0e verification-gap-analysis | open |
| DI-007 | enrichment-completeness investigation-branch path untested; hook↔template section-name sync gap; handoff-validator 39/40 boundary not exercised | MEDIUM | first Feature Mode cycle | 0e verification-gap-analysis | open |
| DI-008 | Component-Map numbering diverges between prose table and YAML in `recovered-architecture.md` — consistency validation needed | LOW | 0f-post consistency validation | 0e5 module-criticality | open |
| DI-009 | hook-manifests component absent from machine-readable YAML component map — classified HIGH; YAML map is incomplete | HIGH | 0f-post consistency validation | 0e5 module-criticality | open |

## Blocking Issues

<!-- Open issues only. Move resolved issues to cycles/<cycle>/blocking-issues-resolved.md. -->

| ID | Issue | Severity | Blocking Phase | Owner | Resolution |
|----|-------|----------|----------------|-------|------------|

## Session Resume Checkpoint

| Field | Value |
|-------|-------|
| **Date** | 2026-07-19 |
| **Position** | Phase 0 — step 0f-pre holdout seeding is next |
| **Context** | Steps 0a–0e5 complete. module-criticality.md produced; recovered-architecture.md criticality fields populated. CRITICAL: require-review hook + update-jira skill; mutation kill-rate targets set. SEC-001..005 in flight on `fix/phase0-security-findings`; security-audit.md deferred pending Disposition section. DI-008/DI-009 logged (Component-Map numbering drift; hook-manifests absent from YAML map). DI-001 RESOLVED (PR #12). DI-002–DI-007 open. |
| **Convergence counter** | n/a (Phase 0) |

## Historical Content

| Content | Location |
|---------|----------|
| Burst history | `cycles/<cycle>/burst-log.md` |
| Convergence trajectory | `cycles/<cycle>/convergence-trajectory.md` |
| Session checkpoints | `cycles/<cycle>/session-checkpoints.md` |
| Lessons learned | `cycles/<cycle>/lessons.md` |
| Resolved blockers | `cycles/<cycle>/blocking-issues-resolved.md` |

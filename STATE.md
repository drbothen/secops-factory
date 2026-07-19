---
document_type: pipeline-state
level: ops
version: "2.0"
status: active
producer: state-manager
timestamp: 2026-07-19T22:00:00Z
phase: 0
inputs: []
input-hash: "[live-state]"
traces_to: ""
project: secops-factory
mode: brownfield
current_step: "0f-adv — adversarial review"
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
| **Current Step** | 0f-adv — adversarial review |

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
| 0e-sec: security-audit | security-reviewer + human | DONE | `.factory/phase-0-ingestion/security-audit.md` — human gate PASSED. 0 critical / 0 high / 1 medium / 4 low / 3 info. SEC-001..005 FIXED via PR #13 (merged f450d9f, 130/130 BATS green): comment path review-gated, unknown jr subcommands fail-closed, MCP versions pinned in docs/mcp.json.example, release.yml job-scoped permissions, semgrep pinned 1.170.0. SEC-006/007 ACCEPTED (info, review at next release). |
| 0f-pre: holdout-seeding | codebase-analyzer | DONE | `.factory/holdout-scenarios/` — 25 scenarios seeded (HS-INDEX.md + 25 brownfield-regression-*.md); 4+4 CRITICAL (require-review/update-jira), 16 HIGH across 7 modules, 1 MEDIUM; epic: BROWNFIELD-REGRESSION. Notable: HS-003 SM-2 surviving mutant; HS-008 SEC-001 injection vector (now fixed via PR #13, scenario retained as regression guard); HS-014 DI-004 false-pass; HS-021 end-to-end investigation gate. |
| 0f: project-context-synthesis | codebase-analyzer | DONE | `.factory/phase-0-ingestion/project-context.md` (new, 287 lines, DF-021 shard links); `behavioral-contracts/BC-3.01.001.md` revised v1.0→v1.1 (PR #13 behavior). DI-010 logged (SEC-002 regression) then RESOLVED: PR #14 (0ec794a) — 11 read-only allowlist entries incl. `--output json` global-flag forms; root cause: global flag between `jr` and subcommand defeated substring match; 8 new BATS tests, suite 138/138. BC-3.01.001.md at v1.2. |
| 0f-adv pass 1 | adversary + remediation | DONE | `.factory/phase-0-ingestion/adversarial-review-0.md` — 12 findings (1C/6M/5m), all remediated same-day. ADV-0-001: BC v1.3 + VPs renumbered VP-HOOK-020/021/022. ADV-0-003 [process-gap]: stale shards re-synced, reconciliation headers added; SM-2 neutralized, require-review kill-rate ~75-80%. Census authoritative at 23 primary + 43 secondary. ADV-0-008: DI-010 row added. ADV-0-009: DI-011 created (hooks.json JSON-Schema, OPEN LOW). Capstone project-context.md re-synced to v1.1 (318 lines). Pass 2 dispatched. |
| 0f-adv pass 2 | adversary + remediation | DONE | `.factory/phase-0-ingestion/adversarial-review-0-pass2.md` — 11 findings (2C/5M/4m), all remediated same-day. Root cause: partial-fix propagation (census not synced across sibling shards). Census now authoritative 24 modules (1/12/7/4) everywhere; C-IDs C-18..C-24 realigned; api-surface Iron-Law corrected (incl. generate-metrics bonus fix); assurance overclaim replaced; git stats updated to 41 commits/PRs #1-#14. DI-012 logged. [process-gap-2]: census-sync assertion missing from pipeline. Capstone v1.2 (334 lines). Pass 3 dispatched. |
| 0f-adv pass 3 | adversary + remediation | DONE | `.factory/phase-0-ingestion/adversarial-review-0-pass3.md` — 7 findings (0C/4M/3m), all remediated same-day. Finding decay: 12→11→7; criticals: 1→2→0. Kill-rate re-anchored (~75-80% current, ~55-65% labeled superseded); 6-hook mutation set consistent with SM-8/SM-8b vectors; C-2↔C-3 cycle removed, DAG verified acyclic; DI-012 expanded to 3 Iron-Law skills + read-ticket; HS-003 downgraded LOW, HS-008 fixed-guard annotation. Capstone v1.3 (346 lines). [process-gap-3]: no shard sync-status convention. Pass 4 dispatched. |
| 0f-adv pass 4 | adversary + remediation | DONE | `.factory/phase-0-ingestion/adversarial-review-0-pass4.md` — 8 findings (1 FP-C / 3M / 4m), all remediated. ADV-0-401 FALSE POSITIVE (stale snapshot trust, adjudicated by orchestrator). BC-3.02.001 v1.1 (EC-004 DENY). 5 BCs + conventions re-anchored by @test NAME. Census derivation explicit (24-1+19+1=43). ALL 13 BCs got sha256 input-hashes. Capstone v1.4 (375 lines). Finding decay: 12→11→7→8(1FP). [process-gap-4]: adversary stale-snapshot trust. [process-gap-5]: BC input-hashes never computed at extraction. Pass 5 dispatched. |
| 0f-adv pass 5 | adversary + remediation | DONE | `.factory/phase-0-ingestion/adversarial-review-0-pass5.md` — 6 findings (0C/2M/4m), all remediated. Finding decay: 12→11→7→8(1FP)→6; majors: 6→5→4→3→2; zero criticals for 3 consecutive passes. Core axes GREEN: census (24/43+derivation), DAG, VP namespaces, Iron-Law attributions, 138 tests, holdout distribution, DI statuses. ADV-0-501: cross-BC enrichment-completeness/disposition-guard contradiction resolved via HOOK-ISOLATED annotations. ADV-0-502: integrations DTU mock corrected to deny. HS-010 v1.1. Capstone v1.5. Pass 6 dispatched as convergence-candidate (bar: 0C+0M). |
| 0f-adv pass 6 | adversary + remediation | DONE | `.factory/phase-0-ingestion/adversarial-review-0-pass6.md` — 6 findings (0C/2M/4m), all remediated. Decay 12→11→7→8(1FP)→6→6; zero criticals 4 consecutive passes. ADV-0-601: SEC-001 comment-deny propagated to consumer BCs (BC-4.02.001 v1.1, BC-5.01.001 v1.2, integrations corrected); DI-013 opened. ADV-0-602: HS-014 reclassified fix-target; baseline 24/25 must-pass + 1 fix-target. ADV-0-605: EC-009 added to BC-3.03.001 v1.3 (DI-004 canonical vector). ADV-0-606: co-fire wiring VERIFIED. Pass 7 dispatched (convergence bar: 0C+0M). |
| 0f-adv pass 7 | adversary + remediation | DONE | `.factory/phase-0-ingestion/adversarial-review-0-pass7.md` — 6 findings (0C/2M/4m), all remediated via systematic grep sweep (12 hits, 4 unreported security-audit annotations). Root cause: incomplete fan-out of PR#13/SEC-001/DI-013 to sibling shards. Decay 12→11→7→8(1FP)→6→6→6; zero criticals 5 consecutive passes; content core GREEN 3 consecutive passes. Capstone v1.7 (400 lines). [process-gap-6]: fan-out discipline — grep sweep before consistency claims. Pass 8 dispatched (convergence bar: 0C+0M). |
| 0f-adv pass 8 | adversary + remediation | DONE | `.factory/phase-0-ingestion/adversarial-review-0-pass8.md` — 6 findings (1 real-code-CRITICAL / 1M / 4m). MILESTONE: ADV-0-801 was a LIVE SHIPPED-CODE VULNERABILITY — require-review allowlist evaluated BEFORE write-block with unanchored substring match, defeating CRITICAL auth gate and SEC-001 mitigation. FIXED PR #15 (d304fa5, 12 new BATS red→green, 55/55 + shellcheck clean). SEC-009 logged (CRITICAL-at-discovery, RESOLVED). BC-3.01.001 v1.7. DI-014 added (LOW, enrichment-completeness substring idiom). HS-026 added (bypass regression guard). Capstone v1.8. [process-gap-7]: substring-matching-idiom sweep. Lesson: HS-026 initial expected-result inverted — caught by orchestrator verification. Pass 9 dispatched. |
| 0f-adv pass 9 | adversary + remediation | DONE | `.factory/phase-0-ingestion/adversarial-review-0-pass9.md` — 4 findings (0C/3M/1m), all remediated. Decay 12→11→7→8(1FP)→6→6→6→6(real bug)→4. DURABLE FIX: require-review anchors switched to CONSTRUCT NAMES across all shards — anchor-churn class structurally retired. Test count corrected to 150 (44+81+11+14) everywhere. vga re-issued (SEC-009, SM-3b RESOLVED, count 150). module-criticality v1.4. BC-4.02.001 v1.3, BC-5.01.001 v1.4. Capstone v1.9 (399 lines). Process-gap #6/#7 reinforced. Pass 10 dispatched. Assessment: reality axes GREEN repeatedly; approaching convergence. |
| 0f-adv pass 10 | adversary + remediation | DONE | `.factory/phase-0-ingestion/adversarial-review-0-pass10.md` — 5 findings (0C/1M/4m), all remediated. Full 13-BC read; prior coverage boundary closed. MILESTONE: adversary confirms ZERO correctness/security/architecture defects remain — all findings propagation residue, now cleared. Anchor-churn COMPLETELY retired (BC-3.01.001 + conventions converted). VP-HOOK-023 added. Decay 12→11→7→8(1FP)→6→6→6→6(real)→4→5. Convergence target: 0 graded findings. Pass 11 dispatched. |
| 0f-adv pass 11 | adversary + remediation | DONE | `.factory/phase-0-ingestion/adversarial-review-0-pass11.md` — 2 findings (0C/0M/2m) + 4 obs, all remediated. Adversary verdict: "converged and honest." Decay 12→11→7→8(1FP)→6→6→6→6(real)→4→5→2. Both minors: last anchor-churn residue (hooks.bats line anchors desynced by PR#15 +12 tests) — retired via @test-NAME refs (BC-3.01.001 v1.9 through BC-3.06.001 v1.3, conventions). Capstone v1.11. Convergence target: 0 graded findings. Pass 12 dispatched. |
| 0f-adv pass 12 | adversary + remediation | DONE | `.factory/phase-0-ingestion/adversarial-review-0-pass12.md` — 1 finding (0C/0M/1m) + 3 obs, all remediated. Adversary verdict: "converged and honest." Decay 12→11→7→8(1FP)→6→6→6→6(real)→4→5→2→1. ADV-0-C01: capstone stale `BC-3.02.001 v1.4` pins (3 occurrences, incl §6 SM-4 third) corrected to v1.5. Capstone v1.12. Pass 13 dispatched (convergence candidate). |

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
| DI-005 | require-review hook: assign/create/fail-open paths untested — review bypass and error-path behaviors have no BATS coverage. Largely superseded by fail-closed fix (PR #13); residual assign/create-path gap remains. | MEDIUM | first Feature Mode cycle | 0e verification-gap-analysis | open (downgraded) |
| DI-006 | PowerShell parity tests skip silently when `pwsh` absent; CI does not assert `pwsh` presence, so `.ps1` hooks receive no static analysis in standard CI runs | HIGH | first Feature Mode cycle | 0e verification-gap-analysis | open |
| DI-007 | enrichment-completeness investigation-branch path untested; hook↔template section-name sync gap; handoff-validator 39/40 boundary not exercised | MEDIUM | first Feature Mode cycle | 0e verification-gap-analysis | open |
| DI-008 | Component-Map numbering diverges between prose table and YAML in `recovered-architecture.md` — consistency validation needed | LOW | 0f-post consistency validation | 0e5 module-criticality | RESOLVED (ADV-0-001/004 remediation) |
| DI-009 | hook-manifests component absent from machine-readable YAML component map — classified HIGH; YAML map incomplete. Scope clarified: YAML component-map only (hooks.json JSON-Schema gap is separate → DI-011). | HIGH | 0f-post consistency validation | 0e5 module-criticality | RESOLVED (ADV-0-009 remediation) |
| DI-011 | `hooks.json` has no JSON-Schema validation — no machine-readable contract for hook manifest structure | LOW | first Feature Mode cycle | 0f-adv pass 1 (ADV-0-009) | open |
| DI-012 | `create-advisory`, `analyze-ticket-effort`, `assess-priority` (Iron Law at SKILL.md:13), and read-ticket injection entry point have no behavioral contracts — 3 Iron-Law skills + 1 injection surface with zero BC coverage | MEDIUM | PENDING HUMAN DECISION at Phase 0 gate (BC coverage expansion) | 0f-adv pass 3 (ADV-0-304 scope correction) | open |
| DI-013 | Comment-gate workflow friction: `jr issue comment` unconditionally denied by require-review hook; consumer skills (investigate-event, orchestration) cannot complete their comment steps without human permission-override. Options: accept friction / implement marker mechanism / add dedicated non-blocked command | MEDIUM-HIGH | PENDING HUMAN DECISION at Phase 0 gate | 0f-adv pass 6 (ADV-0-601) | open |
| DI-014 | enrichment-completeness hook uses same unanchored-grep substring-matching idiom as require-review pre-PR#15 — same class of bypass risk; scope: lower criticality because enrichment-completeness is not an auth gate | LOW | first Feature Mode cycle | 0f-adv pass 8 (ADV-0-803) | open |
| DI-010 | SEC-002 fail-closed regression: `jr issue changelog` (read-only, used by metrics-analyst + 2 data KBs) wrongly denied. PR #14 merged (0ec794a): 11 read-only allowlist entries incl. `--output json` global-flag forms; root cause: global flag defeated substring match; 8 new BATS tests, 138/138 green. | HIGH | in flight | 0f project-context-synthesis | RESOLVED |

## Blocking Issues

<!-- Open issues only. Move resolved issues to cycles/<cycle>/blocking-issues-resolved.md. -->

| ID | Issue | Severity | Blocking Phase | Owner | Resolution |
|----|-------|----------|----------------|-------|------------|

## Session Resume Checkpoint

| Field | Value |
|-------|-------|
| **Date** | 2026-07-19 |
| **Position** | Phase 0 — step 0f-adv pass 13 in progress (convergence candidate — bar: 0 graded findings) |
| **Context** | Pass 12: 1 finding (0C/0M/1m), adversary verdict "converged and honest." Decay →2→1. ADV-0-C01: stale BC-3.02.001 v1.4 pins (3 occurrences) corrected to v1.5; capstone v1.12. All primary axes re-derived GREEN. |
| **Convergence counter** | n/a (Phase 0) |

## Historical Content

| Content | Location |
|---------|----------|
| Burst history | `cycles/<cycle>/burst-log.md` |
| Convergence trajectory | `cycles/<cycle>/convergence-trajectory.md` |
| Session checkpoints | `cycles/<cycle>/session-checkpoints.md` |
| Lessons learned | `cycles/<cycle>/lessons.md` |
| Resolved blockers | `cycles/<cycle>/blocking-issues-resolved.md` |

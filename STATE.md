---
document_type: pipeline-state
level: ops
version: "2.5"
status: active
producer: state-manager
timestamp: 2026-07-21T21:00:00Z
phase: F2
pipeline: FEATURE-CYCLE
inputs: []
input-hash: "[live-state]"
traces_to: ""
project: secops-factory
mode: feature
current_step: "F2 adversarial convergence — pass-6 remediation COMPLETE, pass 7 pending"
awaiting: "F2-adversarial-pass-7"
current_cycle: v0.10.0-feature-prism-integration
dtu_required: true
dtu_assessment: "2026-07-20"
dtu_clones_built: pending
dtu_services: [prism-demo-server, jr-mock]
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
| **Last Updated** | 2026-07-21 |
| **Current Phase** | F2: Spec Evolution (prism-integration cycle) |
| **Current Step** | F2 adversarial convergence — pass-6 remediation COMPLETE, pass 7 pending |

## Phase Progress

| Phase | Status | Started | Completed | Gate | Finding Progression |
|-------|--------|---------|-----------|------|---------------------|
| pre-0: Pre-pipeline | PASSED | 2026-07-19 | 2026-07-19 | PASS | — |
| 0: Codebase Ingestion + Remediation | COMPLETE | 2026-07-19 | 2026-07-20 | PASS | 12→11→7→8(1FP)→6→6→6→6(CRITICAL)→4→5→2→1→0; ADV-R1-4 CLEAN |
| F1: Delta Analysis | PASSED | 2026-07-19 | 2026-07-20 | PASS | consistency: 7→0 |
| F2: Spec Evolution | in-progress — pass-6 remediated, pass 7 pending | 2026-07-20 | | 0/3 clean passes | pass1 2C/8M → pass2 1C/3M → pass3 1C/4M → pass4 2C/4M → pass5 1C/2M → pass5 remediated → pass6 2C/3M → pass6 remediated |
| F3: Incremental Stories | not-started | | | | |
| F4: Delta Implementation | not-started | | | | |
| F5: Scoped Adversarial | not-started | | | | |
| F6: Targeted Hardening | not-started | | | | |
| F7: Delta Convergence | not-started | | | | |

## Current Phase Steps

<!-- Keep last 5 rows only. Archive older rows to cycles/<cycle>/burst-log.md. -->

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| F2: adversarial pass 5 | adversary | DONE | 1C/2M/1m/3obs — root cause: disposition-guard trusts LLM ticket_action_type without cross-checking hard_floor_applies(); P5-001 (silent discard) + P5-002 (kill-switch bypass) are under/over-label duals; P5-003 stale §D-DEC-001 schema block; report persisted. |
| F2: consistency audit pass-5 | consistency-validator | DONE | PASS-WITH-MINORS (0 blocking) — all prior-pass Critical/Major resolved, marker+verdict schemas uniform, VP namespace clean, sensor-silence direction correct. 3 non-blocking: F-001 arch-delta §5.4 (cosmetic), F-002 6 BCs COMPUTE-AT-COMMIT (F2 state-backup), F-003 VP-SKILL-061 silence wording (this burst). CONSISTENCY CLEAN. |
| F2: pass-5 remediation | architect / product-owner / formal-verifier | DONE | arch-delta v1.8 (fail-loud STEP 5, hard_floor_applies() STEP 3 gate, schema v2.1 sync, O3 rule/D-DEC-012, Option A); BC-3.03.001 v1.14 (STEP 3+5 gates, EC-012, TV-SYNC); BC-10.01.001 v1.10 (Inv#10, VP-SKILL-061 sensor-silence fix); verif-delta v1.8 (VP-HOOK-029 re-scoped, SM-32a/32b, §7 Part F, ~238 tests); prd-delta v1.9 (§4/§6 12/15-field); brief §3.9 Option A confirmed 2026-07-21 |
| F2: adversarial pass 6 | adversary | DONE | 2C/3M/3m/2obs — trust boundary re-derived end-to-end: P6-001 consumer accepts review tokens for regular commands (kill-switch bypass, CRITICAL); P6-002 STEP 4 kill switch precedes STEP 5 upgrade → silent discard of under-labeled hard-floor verdicts when autonomy=false (CRITICAL); P6-003 Inv#11/VP-SKILL-065 contradict Option A; P6-004 single demo project key voids cross-org create binding; P6-005 sensor-severity→enum normalization unspecified; P6-009 [process-gap] O3 rule applied emitter-only. Report persisted. |
| F2: pass-6 remediation burst 2 | architect / product-owner / formal-verifier | DONE | arch-delta v1.9 (P6-001..009: --label in create-review pattern + hook-side label enforcement D-DEC-012 ADOPTED; STEP 4/5 reorder; D-DEC-013 severity normalization; P6-008 ASM-009 BLOCKING; O3 extended to consumer+ordering+trust-boundary; VP-SKILL-074+SM-36/SM-37 namespace-corrected); BC-3.01.001 v1.18 (STEP 6a anti-fungibility both directions, EC-023, VP-HOOK-029 FINALIZED ref, SM-36/SM-37); BC-3.03.001 v1.15 (STEP 4/5 swap, labeled create-review pattern, Iron Law updated); BC-10.01.001 v1.11 (Inv#11 Option A carve-out, NORMALIZE_SEVERITY per D-DEC-013, VP-SKILL-065 re-scoped PROPOSED); verif-delta v1.9 (VP-HOOK-029 FINALIZED P0, VP-HOOK-024 anti-fungibility, VP-SKILL-073/074 new, 31VPs/31mutants; FV caught VP-SKILL-072+SM-33/34 collisions) |

## Decisions Log

| ID | Decision | Rationale | Phase | Date | Made By |
|----|----------|-----------|-------|------|---------|
| D-001 | Onboarding depth = Phase 0 only; park at 0-complete awaiting feature-request | Internal dev-tooling plugin; no active feature scope yet | pre-0 | 2026-07-19 | human |
| D-002 | market-intelligence SKIPPED | Internal dev-tooling plugin — no market research needed | pre-0 | 2026-07-19 | human |
| D-003 | design-system-extraction SKIPPED | No UI surfaces in this plugin | pre-0 | 2026-07-19 | human |
| D-004 | Feature cycle scope = FULL handoff brief, dependency-ordered, no RC-priority split | All items in brief §2–§5 are in scope; sequenced by dependency | F1 | 2026-07-19 | human |
| D-005 | DI-013 resolved via review-approval MARKER MECHANISM — require-review hook recognizes disposition-guard-validated approval marker; `jr issue comment` permitted only with valid marker | Marker mechanism closes DI-013 comment-gate friction without removing the gate | F1 | 2026-07-19 | human |
| D-006 | secops-factory is DEMO-UNAWARE: all demo setup (demo Jira project, ticket seeding, demo bundle) is external; brief §4 items out of scope except the generic `jr` auth check in the activate skill | secops-factory ships the plugin; demo orchestration is the operator's concern | F1 | 2026-07-19 | human |
| D-007 | Kill-switch Option A: create-review/comment-review escalation markers stay live under autonomy_enabled=false, gated on hook-computed hard_floor_applies() OR Indeterminate; brief §3.9 amended | Escalation surfaces to a human rather than acting autonomously; O3 gate removes the LLM-token bypass | F2 | 2026-07-21 | human |

## Skip Log

| Step | Skipped? | Justification |
|------|----------|---------------|
| UX Spec | yes | CLI/agent plugin — no UI surfaces |
| Market Intelligence | yes | Internal dev-tooling plugin; no external market |
| Design System Extraction | yes | Internal dev-tooling plugin; no UI |
| Market Intelligence (feature cycle) | yes | Carried from D-002 — internal dev-tooling plugin, no external market |

## Drift Items

<!-- Items flagged during codebase analysis for follow-up. Move resolved items to cycle files. -->

| ID | Item | Severity | Target Step | Flagged By | Status |
|----|------|----------|-------------|------------|--------|
| DI-001 | Live API keys in untracked, non-gitignored `.envrc` and `.mcp.json` at repo root — exposure risk on accidental commit. PR #12 merged: adds `.envrc`, `.env`, `.mcp.json`, `.claude/settings.local.json` to `.gitignore`. Keys were never committed (untracked only), no git-history exposure. Key rotation optional; 0e-sec to confirm. | HIGH | 0e-sec security audit triage | 0a project-discovery | RESOLVED |
| DI-002 | `secops-health` command has no corresponding skill directory — special-cased in CI rather than following standard command→skill convention | LOW | Phase 1 spec crystallization | 0b architecture-recovery | RESOLVED (PR #16 — secops-health CI coverage added) |
| DI-003 | `adversarial-review-secops` skill directly references orchestrator canonical playbook — intentional layer inversion (skill depends on orchestrator artifact) | LOW | Phase 1 spec crystallization | 0b architecture-recovery | RESOLVED (Stream D — documented as intentional design; layer-inversion annotated in BC-4.06.001) |
| DI-004 | disposition-guard substring false-pass live-demonstrated: header-only match passes BC-3.04 even when body text is absent — hook assert is unsound | HIGH | first Feature Mode cycle | 0e verification-gap-analysis | RESOLVED (PR #17 — heading-anchored section match implemented; HS-014 promoted must-pass) |
| DI-005 | require-review hook: assign/create/fail-open paths untested — review bypass and error-path behaviors have no BATS coverage. Largely superseded by fail-closed fix (PR #13); residual assign/create-path gap remains. | MEDIUM | first Feature Mode cycle | 0e verification-gap-analysis | RESOLVED (PR #17 — assign/create/fail-open path coverage added) |
| DI-006 | PowerShell parity tests skip silently when `pwsh` absent; CI does not assert `pwsh` presence, so `.ps1` hooks receive no static analysis in standard CI runs | HIGH | first Feature Mode cycle | 0e verification-gap-analysis | RESOLVED (PR #16 — CI asserts pwsh present; PSScriptAnalyzer integrated) |
| DI-007 | enrichment-completeness investigation-branch path untested; hook↔template section-name sync gap; handoff-validator 39/40 boundary not exercised | MEDIUM | first Feature Mode cycle | 0e verification-gap-analysis | RESOLVED (PR #17 — investigation-branch path + 39/40 boundary + section-name sync covered) |
| DI-008 | Component-Map numbering diverges between prose table and YAML in `recovered-architecture.md` — consistency validation needed | LOW | 0f-post consistency validation | 0e5 module-criticality | RESOLVED (ADV-0-001/004 remediation) |
| DI-009 | hook-manifests component absent from machine-readable YAML component map — classified HIGH; YAML map incomplete. Scope clarified: YAML component-map only (hooks.json JSON-Schema gap is separate → DI-011). | HIGH | 0f-post consistency validation | 0e5 module-criticality | RESOLVED (ADV-0-009 remediation) |
| DI-011 | `hooks.json` has no JSON-Schema validation — no machine-readable contract for hook manifest structure | LOW | first Feature Mode cycle | 0f-adv pass 1 (ADV-0-009) | RESOLVED (PR #16 — JSON-Schema added to hooks.json validation in CI) |
| DI-012 | `create-advisory`, `analyze-ticket-effort`, `assess-priority` (Iron Law at SKILL.md:13), and read-ticket injection entry point have no behavioral contracts — 3 Iron-Law skills + 1 injection surface with zero BC coverage | MEDIUM | resolved at Phase 0 drift remediation | 0f-adv pass 3 (ADV-0-304 scope correction) | RESOLVED (Stream D — BC-4.05.001 advisory-pipeline, BC-4.06.001 metrics-pipeline, BC-7.01.001 investigation-entry, BC-8.01.001 read-ticket added) |
| DI-013 | Comment-gate workflow friction: `jr issue comment` unconditionally denied by require-review hook; consumer skills (investigate-event, orchestration) cannot complete their comment steps without human permission-override. Options: accept friction / implement marker mechanism / add dedicated non-blocked command | MEDIUM-HIGH | F2 spec evolution → F3 story | 0f-adv pass 6 (ADV-0-601) | ACTIVE THIS CYCLE (D-005: marker mechanism) |
| DI-014 | enrichment-completeness hook uses same unanchored-grep substring-matching idiom as require-review pre-PR#15 — same class of bypass risk; scope: lower criticality because enrichment-completeness is not an auth gate | LOW | first Feature Mode cycle | 0f-adv pass 8 (ADV-0-803) | RESOLVED (PR #17 — anchored-grep pattern applied to enrichment-completeness hook) |
| DI-010 | SEC-002 fail-closed regression: `jr issue changelog` (read-only, used by metrics-analyst + 2 data KBs) wrongly denied. PR #14 merged (0ec794a): 11 read-only allowlist entries incl. `--output json` global-flag forms; root cause: global flag defeated substring match; 8 new BATS tests, 138/138 green. | HIGH | in flight | 0f project-context-synthesis | RESOLVED |

## Blocking Issues

<!-- Open issues only. Move resolved issues to cycles/<cycle>/blocking-issues-resolved.md. -->

| ID | Issue | Severity | Blocking Phase | Owner | Resolution |
|----|-------|----------|----------------|-------|------------|

## Session Resume Checkpoint

| Field | Value |
|-------|-------|
| **Date** | 2026-07-21 |
| **Position** | Pass-6 remediation COMPLETE + committed. NEXT: adversarial pass 7 (fresh context). Clean streak 0/3. |
| **Context** | Artifact versions after burst 2: arch-delta v1.9, verif-delta v1.9, prd-delta v1.9, BC-3.01.001 v1.18, BC-3.03.001 v1.15, BC-10.01.001 v1.11, brief §3.9 amended. Unchanged: BC-4.02.001 v1.8, BC-4.05.001 v1.3, BC-5.01.001 v1.8, BC-6.01.001 v1.5, BC-6.01.003/004/BC-8.02.001/BC-9.01.001 v1.1. D-DEC-001..013 locked. D-007 (Option A) committed. DTU required (prism demo server + jr mock). F-001 cosmetic arch-delta §5.4 still open; F-002 COMPUTE-AT-COMMIT bare hashes deferred to F2 state-backup. |
| **Convergence counter** | 0/3 clean passes (pass 7 next) |

## Historical Content

| Content | Location |
|---------|----------|
| Burst history | `cycles/<cycle>/burst-log.md` |
| Convergence trajectory | `cycles/<cycle>/convergence-trajectory.md` |
| Session checkpoints | `cycles/<cycle>/session-checkpoints.md` |
| Lessons learned | `cycles/<cycle>/lessons.md` |
| Resolved blockers | `cycles/<cycle>/blocking-issues-resolved.md` |

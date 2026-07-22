---
document_type: pipeline-state
level: ops
version: "2.7"
status: active
producer: state-manager
timestamp: 2026-07-21T23:59:00Z
phase: F2
pipeline: FEATURE-CYCLE
inputs: []
input-hash: "[live-state]"
traces_to: ""
project: secops-factory
mode: feature
current_step: "F2 adversarial convergence — pass 9 done (0C/2M), remediation pending"
awaiting: "F2-pass9-remediation"
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
| **Current Step** | F2 adversarial convergence — pass 9 done (0C/2M), remediation pending |

## Phase Progress

| Phase | Status | Started | Completed | Gate | Finding Progression |
|-------|--------|---------|-----------|------|---------------------|
| pre-0: Pre-pipeline | PASSED | 2026-07-19 | 2026-07-19 | PASS | — |
| 0: Codebase Ingestion + Remediation | COMPLETE | 2026-07-19 | 2026-07-20 | PASS | 12→11→7→8(1FP)→6→6→6→6(CRITICAL)→4→5→2→1→0; ADV-R1-4 CLEAN |
| F1: Delta Analysis | PASSED | 2026-07-19 | 2026-07-20 | PASS | consistency: 7→0 |
| F2: Spec Evolution | in-progress — pass9 done (0C/2M), remediation pending | 2026-07-20 | | 0/3 clean passes | pass1 2C/8M → pass2 1C/3M → pass3 1C/4M → pass4 2C/4M → pass5 1C/2M → pass5 remediated → pass6 2C/3M → pass6 remediated → pass7 2C/3M → pass7 remediated → pass8 1C/2M → pass8 remediated → pass9 0C/2M (remediation pending — first zero-CRITICAL pass) |
| F3: Incremental Stories | not-started | | | | |
| F4: Delta Implementation | not-started | | | | |
| F5: Scoped Adversarial | not-started | | | | |
| F6: Targeted Hardening | not-started | | | | |
| F7: Delta Convergence | not-started | | | | |

## Current Phase Steps

<!-- Keep last 5 rows only. Archive older rows to cycles/<cycle>/burst-log.md. -->

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| F2: adversarial pass 7 | adversary | DONE | 2C/3M/3m/2obs — root cause: marker↔command seam. P7-001 (CRITICAL): STEP 4 under-label upgrade writes a marker the loop's actual jr command cannot consume — silent drop persists for create/assign/none under-label paths. P7-002 (CRITICAL): 6 locations in BC-10.01.001 (EC-015/016/017/021 + 2 test vectors) still encode pre-D-DEC-012 'no marker for hard floor' semantics. P7-003: --label Iron Law missing from loop contract. P7-004: VP-HOOK-029 emitter-only, cannot detect unconsumable-marker drop. P7-005 substring false-deny; P7-006 Cyberint mapping; P7-007 brief stale versions. P7-009 [process-gap]: fail-loud claims proven at emitter, guarantee lives at consumer — need end-to-end verification axis. Report persisted. |
| F2: pass-7 remediation burst 3 | architect / product-owner / formal-verifier | DONE | DENY-THE-WRITE redesign per human D-008 + O4 standing rule. arch-delta v1.10 (STEP-4 deny-the-Write, SM-38/39/40, O4 rule); BC-3.03.001 v1.16 (STEP 4 deny + UNDER-LABEL-DENIED audit, corrective-reason struct); BC-3.01.001 v1.19 (structural_label_check step-6a, EC-024, SM-40); BC-10.01.001 v1.12 (P7-002 6 stale ECs, P7-003 --label Iron Law, P7-006 Cyberint); verif-delta v1.10 (VP-HOOK-029 consumer-boundary re-scope+FINALIZED P0, SM-38/39/40, Cyberint partition); prd-delta v1.9 (non-pinned); SM-ID sync + version-coherence sweep applied. |
| F2: adversarial pass 8 | adversary | DONE | 1C/2M/1m/2obs — decay begun. P8-001 (CRITICAL): STEP 3 correctly-labeled review verdict with null jira_project_key/ticket_id → silent allow-without-marker (last orthogonal silent-discard axis; contradicts D-DEC-012 clause 2 which already mandates deny+error). P8-002 (MAJOR): P7-005 structural_label_check split_on_whitespace not quote-aware — false-denies its own EC-024 example (verified against live hook source). P8-004 (MAJOR): prd-delta VP statuses inverted (VP-HOOK-029/VP-SKILL-065) + §5 versions stale by 2-3. P8-003 (MINOR): EC-023 step-5 defense-in-depth claim factually wrong — anti-fungibility rests solely on step 6a. P8-OBS-1 [process-gap]: superseded propagation ledger sections need forward-link banners. P8-OBS-2: Cyberint 100% mass-escalation pre-ASM-008 needs operator note. 8 confirmed-intact invariants listed for pass-9 accumulation. Report persisted. |
| F2: pass-8 remediation burst 4 | architect / product-owner / formal-verifier | DONE | arch-delta v1.11 (P8-001 STEP-3 unbindable deny; P8-002 quote-aware tokenizer; P8-003 EC-023 step-5; §8.18/§8.19 propagation); BC-3.03.001 v1.17 (unbindable-deny branches + SM-41); BC-3.01.001 v1.20 (quote-aware tokenizer + SM-42); BC-10.01.001 v1.13 (VP-HOOK-029 re-FINALIZED P0 + loop re-doc P8-001); BC-8.02.001 v1.2 (Cyberint operator note); verif-delta v1.11 (SM-41/SM-42 + unbindable vectors + EC-023 correction); prd-delta v1.10 (VP roster + §5 versions) |
| F2: adversarial pass 9 | adversary | DONE | 0C/2M/5m/2obs — FIRST zero-CRITICAL pass; silent-discard class exhausted. P9-001 (MAJOR): quote-aware tokenizer still misses backslash-escaped quotes + --label= form — defeats EC-023 dir-A (sole anti-fungibility gate post-P8-003, no backstop). P9-002 (MAJOR): asm-004-validation.md recommends forbidden --dangerously-skip-permissions + --bare (hook-disabling) with no supersession banner vs D-DEC-003/010. P9-003 prd-delta BC-10.01.001 double-counted (11→10). P9-004 verif-delta VP split mislabeled 8/23 vs 6/25 + FINALIZED/ACCEPTED drift. P9-005 D-DEC-005 org_slug absolute vs sensor-metrics cross-org health. P9-006 dtu-assessment omits C-29 marker-store + ASM-009. P9-007 comment-review fallback hint dup-ticket risk. P9-008/009 [process-gap] obs. Report persisted. |

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
| D-008 | P7-001 fixed via DENY-THE-WRITE: disposition-guard denies under-labeled hard-floor verdict Writes with machine-actionable corrective reason; marker-upgrade approach retired | Deterministic hook's only lever over FUTURE commands is denying the CURRENT Write; marker-upgrade could rewrite the marker but not the loop's subsequent Bash command — 3 of 4 under-label paths produced unconsumable markers (silent drop) | F2 | 2026-07-21 | human |

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
| **Position** | Pass 9 COMPLETE (0C/2M/5m/2obs — first zero-CRITICAL, decay strong). NEXT: remediation burst 5 (P9-001 tokenizer escaped-quote/equals-form; P9-002 asm-004 supersession banner; P9-003/004 bookkeeping; P9-005 D-DEC-005 carve-out; P9-006 dtu inventory; P9-007 dedup hint; P9-008/009 obs), then pass 10. Clean streak 0/3. |
| **Context** | Artifact versions: arch-delta v1.11, verif-delta v1.11, prd-delta v1.10, BC-3.01.001 v1.20, BC-3.03.001 v1.17, BC-10.01.001 v1.13, BC-8.02.001 v1.2. No spec changes in pass-9 (adversary review only). P9 report: adversarial-spec-delta-review-pass9.md. F-001 cosmetic §5.4 still open. |
| **Convergence counter** | 0/3 clean passes (pass-9 done — first zero-CRITICAL; remediation burst 5 next, then pass 10) |

## Historical Content

| Content | Location |
|---------|----------|
| Burst history | `cycles/<cycle>/burst-log.md` |
| Convergence trajectory | `cycles/<cycle>/convergence-trajectory.md` |
| Session checkpoints | `cycles/<cycle>/session-checkpoints.md` |
| Lessons learned | `cycles/<cycle>/lessons.md` |
| Resolved blockers | `cycles/<cycle>/blocking-issues-resolved.md` |

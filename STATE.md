---
document_type: pipeline-state
level: ops
version: "2.10"
status: active
producer: state-manager
timestamp: 2026-07-22T18:30:00Z
phase: F2
pipeline: FEATURE-CYCLE
inputs: []
input-hash: "[live-state]"
traces_to: ""
project: secops-factory
mode: feature
current_step: "F2 adversarial convergence — pass 11 done (1C/3M), remediation pending — awaiting human direction (P11-001 reframe + P11-002 severity/priority model)"
awaiting: "F2-pass11-remediation (human-gate)"
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
| **Last Updated** | 2026-07-22 |
| **Current Phase** | F2: Spec Evolution (prism-integration cycle) |
| **Current Step** | F2 adversarial convergence — pass 11 done (1C/3M), remediation pending — awaiting human direction |

## Phase Progress

| Phase | Status | Started | Completed | Gate | Finding Progression |
|-------|--------|---------|-----------|------|---------------------|
| pre-0: Pre-pipeline | PASSED | 2026-07-19 | 2026-07-19 | PASS | — |
| 0: Codebase Ingestion + Remediation | COMPLETE | 2026-07-19 | 2026-07-20 | PASS | 12→11→7→8(1FP)→6→6→6→6(CRITICAL)→4→5→2→1→0; ADV-R1-4 CLEAN |
| F1: Delta Analysis | PASSED | 2026-07-19 | 2026-07-20 | PASS | consistency: 7→0 |
| F2: Spec Evolution | in-progress — pass11 done 1C/3M, remediation pending (human-gate) | 2026-07-20 | | 0/3 clean passes | pass1 2C/8M → pass2 1C/3M → pass3 1C/4M → pass4 2C/4M → pass5 1C/2M → pass5 remediated → pass6 2C/3M → pass6 remediated → pass7 2C/3M → pass7 remediated → pass8 1C/2M → pass8 remediated → pass9 0C/2M → pass9 remediated → pass10 1C/2M → pass10 remediated → pass11 1C/3M (remediation pending) |
| F3: Incremental Stories | not-started | | | | |
| F4: Delta Implementation | not-started | | | | |
| F5: Scoped Adversarial | not-started | | | | |
| F6: Targeted Hardening | not-started | | | | |
| F7: Delta Convergence | not-started | | | | |

## Current Phase Steps

<!-- Keep last 5 rows only. Archive older rows to cycles/<cycle>/burst-log.md. -->

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| F2: pass-10 remediation burst 6 | architect / product-owner / formal-verifier | DONE | P10-001 (CRITICAL) hook-side severity re-normalization: STEP 1a SEVERITY-MISMATCH + 17-field schema (native_severity/sensor_family fields 16+17) + O6 rule codified; VP-HOOK-030 + SM-44 allocated. P10-002 (MAJOR) Gate 2 cron wrapper audit.log grep + VP-SKILL-075 + ASM-015 BLOCKING gate documented. P10-003 (MAJOR) WRITE_MARKER review-path fail-closed + SM-45. P10-004/P10-008/P10-009 MINOR. D-009/D-010 recorded. arch-delta v1.13, verif-delta v1.13, prd-delta v1.12, dtu-assessment v1.1, BC-3.03.001 v1.18, BC-10.01.001 v1.15, BC-6.01.003 v1.2. |
| F2: adversarial pass 9 | adversary | DONE | 0C/2M/5m/2obs — FIRST zero-CRITICAL pass; silent-discard class exhausted. P9-001 (MAJOR): quote-aware tokenizer still misses backslash-escaped quotes + --label= form — defeats EC-023 dir-A (sole anti-fungibility gate post-P8-003, no backstop). P9-002 (MAJOR): asm-004-validation.md recommends forbidden --dangerously-skip-permissions + --bare (hook-disabling) with no supersession banner vs D-DEC-003/010. P9-003 prd-delta BC-10.01.001 double-counted (11→10). P9-004 verif-delta VP split mislabeled 8/23 vs 6/25 + FINALIZED/ACCEPTED drift. P9-005 D-DEC-005 org_slug absolute vs sensor-metrics cross-org health. P9-006 dtu-assessment omits C-29 marker-store + ASM-009. P9-007 comment-review fallback hint dup-ticket risk. P9-008/009 [process-gap] obs. Report persisted. |
| F2: pass-9 remediation burst 5 | architect / product-owner / formal-verifier | DONE | P9-001 backslash-escape tokenizer extension + --label= form (MAJOR security fix; O5 rule codified — tokenizer must carry differential-vs-bash vector partition). P9-002 asm-004-validation SUPERSEDED/CORRECTION banners (D-DEC-003/010). P9-005 D-DEC-005 sensor-health cross-org carve-out. P9-007 dedup-before-create-review gate hint. P9-008 jira_project_key HARD Stage-0 precondition + HARD-FLOOR-LIVELOCK-ABORT re-doc cap. P9-009 O5 standing-rule codified. SM-43 allocated. arch-delta v1.12, verif-delta v1.12, prd-delta v1.11, BC-3.01.001 v1.21, BC-10.01.001 v1.14, BC-6.01.001 v1.6, BC-8.02.001 v1.3. First zero-CRITICAL pass; clean streak 0/3. |
| F2: adversarial pass 10 | adversary | DONE | 1C/2M/6m — P10-001 (CRITICAL): hard_floor_applies() keys on LLM-supplied verdict.severity/asset_type with NO hook-side cross-validation vs source — O3 rule unapplied to the floor's own inputs; 'LLM cannot bypass' claim false. P10-002 (MAJOR)[process-gap]: cron wrapper gate never inspects audit.log fail-loud codes (HARD-FLOOR-LIVELOCK-ABORT/UNBINDABLE) + hook-deny→permission_denials unvalidated → livelock-abort run reports success. P10-003 (MAJOR): marker-write-failure allow-without-marker reintroduces silent-drop on hard-floor review path. P10-004..009 MINOR: fallback_hint dedup propagation, scan-threats structural-only VP, carve-out JOIN predicate, VP-SKILL-064 test-name, comment-review no --label (ASM-014), global jira_project_key vs multi-org. Report persisted; P10-001 approach at human gate. |
| F2: adversarial pass 11 | adversary | DONE | 1C/3M/2m — P11-001 (CRITICAL): STEP-1a re-normalizes from LLM-supplied native_severity/sensor_family (hook makes no prism call) → severity floor still LLM-bypassable; 'un-bypassable/independently-derived' claim FALSE; native_severity trust is an ASM-008 residual identical to asset_type (understated). P11-002 (MAJOR): STEP-1a exact-equality contradicts Stage-5 severity recalibration (BC-10.01.001 field 13 + brief §3.9) — recalibrated verdicts denied; scored-priority escalations invisible to the floor. P11-003 (MAJOR): NVD/CVSS severity source but sensor_family enum lacks 'nvd' → false SEVERITY-MISMATCH. P11-004 (MAJOR): 12-field investigation-markdown emitter-entry contradictory BC-3.03.001 vs arch-delta; validate_enums would deny an analyst's investigation save. P11-005 mis-anchor (BC-6.01.003 → wrong BC-9.01.001 ref). P11-006 prd-delta stale 12/15. [process-gap]: false-closure claim copy-propagated to 4 docs. Report persisted; at human gate. |

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
| D-009 | P10-001 hard-floor trust-basis fix: 17-field verdict schema (native_severity + sensor_family at Stage 1 INGEST), STEP 1a SEVERITY-MISMATCH hook-side re-normalization via D-DEC-013, ASM-008-DEFERRED residual (asset_type cross-validation deferred pending empirical sensor taxonomy) | O6 rule: inputs to hook-computed invariant must be hook-recomputable; "LLM cannot bypass" only holds if check does not depend on LLM-written fields | F2 | 2026-07-22 | human |
| D-010 | P10-009 per-org jira_project_key — choice (a): lookup per-org [[orgs]].jira_project_key first; if absent, fall back to global jira_project_key from [plugin_config] | Enables multi-tenant deployments where different orgs use different Jira projects without requiring a global key change | F2 | 2026-07-22 | architect |

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
| ASM-008-DEFERRED | asset_type cross-validation deferred — sensor-specific asset taxonomy (CrowdStrike asset categories, Armis/Claroty device types) not empirically validated; asset_type field written by LLM at Stage 1 INGEST without hook-side cross-validation. Known residual after P10-001 (O6 fix covers severity; O6 cannot yet cover asset_type without empirical taxonomy). Deferred to ASM-008 resolution or pre-production. | MEDIUM | ASM-008 resolution / pre-production | ADV-F2-P10-001 | OPEN — KNOWN-DEFERRED |
| ASM-015 | BLOCKING pre-Wave-3 loop stories: empirical validation needed that permissionDecision:deny from a PreToolUse hook populates `.permission_denials[]` in --allowedTools JSON envelope; Gate 1 check on permission_denials > 0 is unvalidated until ASM-015 resolves; is_error=true is the only proven reliable exit-1 trigger for Gate 1. | BLOCKING | pre-Wave-3 | ADV-F2-P10-002 | OPEN — BLOCKING |
| ASM-014 | comment-review --label binding pending: the comment-review kill-switch exemption is currently broader than "review ticket only" — restricting it to review-labeled tickets is deferred until empirical validation that `jr issue comment --label` is supported. | LOW | pre-Wave-3 (wave-stories touching comment-review path) | ADV-F2-P10-008 | OPEN — DEFERRED |

## Blocking Issues

<!-- Open issues only. Move resolved issues to cycles/<cycle>/blocking-issues-resolved.md. -->

| ID | Issue | Severity | Blocking Phase | Owner | Resolution |
|----|-------|----------|----------------|-------|------------|

## Session Resume Checkpoint

| Field | Value |
|-------|-------|
| **Date** | 2026-07-22 |
| **Position** | Pass 11 COMPLETE (1C/3M/2m, report persisted). BLOCKED on human decisions: (1) P11-001 reframe — reclassify native_severity trust as ASM-008-deferred residual symmetric with asset_type, keep STEP 1a as consistency check, correct the overstated claims across 4 docs; (2) P11-002 severity/priority model — two-field (native_normalized_severity + scored_priority, floor on scored) vs escalate-only (verdict.severity >= normalized). P11-003/004 clear-ish fixes queued. Clean streak 0/3; trajectory 2C→2C→1C→0C→1C→1C — CRITICALs now foundational/subtle. |
| **Context** | Artifact versions: arch-delta v1.13, verif-delta v1.13, prd-delta v1.12, dtu-assessment v1.1, BC-3.03.001 v1.18, BC-10.01.001 v1.15, BC-6.01.003 v1.2, BC-3.01.001 v1.21, BC-8.02.001 v1.3, BC-6.01.001 v1.6. D-009/D-010 recorded. VP-HOOK-030 + VP-SKILL-075 FINALIZED P0. O6 rule codified. Pass 11 report at phase-f2-spec-evolution/adversarial-spec-delta-review-pass11.md. |
| **Convergence counter** | 0/3 clean passes (pass-11: 1C/3M — report persisted; remediation BLOCKED at human gate. P11-001 and P11-002 require human decision before remediation. P11-003/004 queued.) |

## Historical Content

| Content | Location |
|---------|----------|
| Burst history | `cycles/<cycle>/burst-log.md` |
| Convergence trajectory | `cycles/<cycle>/convergence-trajectory.md` |
| Session checkpoints | `cycles/<cycle>/session-checkpoints.md` |
| Lessons learned | `cycles/<cycle>/lessons.md` |
| Resolved blockers | `cycles/<cycle>/blocking-issues-resolved.md` |

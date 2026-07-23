---
document_type: pipeline-state
level: ops
version: "2.20"
status: active
producer: state-manager
timestamp: 2026-07-23T23:59:30Z
phase: F2
pipeline: FEATURE-CYCLE
inputs: []
input-hash: "[live-state]"
traces_to: ""
project: secops-factory
mode: feature
current_step: "F2 adversarial convergence — pass-19 remediation COMPLETE (burst 16), pass 20 pending"
awaiting: "F2-adversarial-pass-20"
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
| **Last Updated** | 2026-07-23 |
| **Current Phase** | F2: Spec Evolution (prism-integration cycle) |
| **Current Step** | F2 adversarial convergence — pass-19 remediation COMPLETE (burst 16), pass 20 pending |

## Phase Progress

| Phase | Status | Started | Completed | Gate | Finding Progression |
|-------|--------|---------|-----------|------|---------------------|
| pre-0: Pre-pipeline | PASSED | 2026-07-19 | 2026-07-19 | PASS | — |
| 0: Codebase Ingestion + Remediation | COMPLETE | 2026-07-19 | 2026-07-20 | PASS | 12→11→7→8(1FP)→6→6→6→6(CRITICAL)→4→5→2→1→0; ADV-R1-4 CLEAN |
| F1: Delta Analysis | PASSED | 2026-07-19 | 2026-07-20 | PASS | consistency: 7→0 |
| F2: Spec Evolution | in-progress — pass19 remediated, pass20 pending | 2026-07-20 | | 0/3 clean passes | pass1 2C/8M → pass2 1C/3M → pass3 1C/4M → pass4 2C/4M → pass5 1C/2M → pass5 remediated → pass6 2C/3M → pass6 remediated → pass7 2C/3M → pass7 remediated → pass8 1C/2M → pass8 remediated → pass9 0C/2M → pass9 remediated → pass10 1C/2M → pass10 remediated → pass11 1C/3M → pass11 remediated → pass12 2C/2M → pass12 remediated → pass13 2C/1M → pass13 remediated → pass14 0C/2M/3m → pass14 remediated → pass15 0C/1M/2m → pass15 remediated → pass16 0C/1M/2m → pass16 remediated → consistency-audit remediated (12 findings, all coherence) → pass17 0C/3M → pass17 remediated → pass18 0C/2M/1med → pass18 remediated → pass19 1C/1m → pass19 remediated |
| F3: Incremental Stories | not-started | | | | |
| F4: Delta Implementation | not-started | | | | |
| F5: Scoped Adversarial | not-started | | | | |
| F6: Targeted Hardening | not-started | | | | |
| F7: Delta Convergence | not-started | | | | |

## Current Phase Steps

<!-- Keep last 5 rows only. Archive older rows to cycles/<cycle>/burst-log.md. -->

| Step | Agent | Status | Output |
|------|-------|--------|--------|
| F2: pass-17 remediation burst 14 | architect / product-owner / formal-verifier | DONE | D-019 known-FP high-sev→review (scopes D-016 to LOW/MED; closes the loop-vs-gate contradiction + the would-be LLM-known_fp CRITICAL bypass; no gate change; SM-56 added). P17-002 Inv#14/VP-HOOK-028 JSON-first residue cleared (BC-10.01.001 Inv#14 Stage-7 + VP-HOOK-028 property-(1) rewritten to actual fail-closed boundary). P17-003 BC-3.03.001 EC-005/L814 markdown-comment residue cleared (consistent with L836). Version-coherence sweep: verif-delta v1.19 BC anchors v1.20/v1.26; prd-delta §5 v1.18; arch-delta v1.19. Clean streak 0/3. |
| F2: adversarial pass 18 | adversary | DONE | 0C/2M/1med/2obs — substance pass; emitter/consumer/loop/D-019/JSON-first/tokenizer re-derived INTACT. NEW cluster (unmapped surface): P18-001 (MAJOR) jr issue link + jr issue move/close have NO authorization path — §3.4 correlation rules 2&4 require link autonomously (BC-4.02.001 PC#7b/d, BC-10.01.001 §3.4, DTU design asserts it called) but require-review has no write-block/allowlist/marker-scope for link → fail-closed DENY, no path; correlation links silently never form. P18-003 (MEDIUM) one-verdict-one-marker can't express compound comment+link / create+link. P18-002 (MAJOR) burst-14 propagation gap: verification-delta says VP-HOOK-028 property-(1) rewrite DONE but authoritative BC-10.01.001 L616 still has old property + 'pending FV' banner. P18-004/005 OBS (BC-4.02.001 Inv#1 omits link; FP 'Close (if open)' unauthorizable — autonomous-close scope ambiguous). Report persisted; link/close cluster at human gate; P18-002 clear fix. |
| F2: pass-18 remediation burst 15 | architect / product-owner×2 / formal-verifier / state-manager | DONE | §3.4 Jira-action authorization: D-020 (link=`jr issue link` scope, REGULAR, anti-fungible), D-021 (close=`jr issue move`, CLOSE_STATE_ALLOWLIST, HIGH/CRIT NEVER auto-close, REGULAR), D-022 (compound §3.4 = two sequential verdict Writes, anti-fungible). P18-001: `jr issue link` added to write-block + `["link"]` marker scope (BC-3.03.001 v1.27, BC-3.01.001 v1.23). P18-002: VP-HOOK-028 property-(1) synced to verif-delta v1.20. P18-003: compound two-Write model (BC-10.01.001 v1.21, BC-4.02.001 v1.13). P18-004/005 OBS addressed. VP-HOOK-033..036 + SM-57..65 allocated. BC-6.01.001 v1.8 (close gating). O7 now 8 sites. VP 41 / SM 58. arch-delta v1.20. Clean streak 0/3. |
| F2: adversarial pass 19 | adversary | DONE | 1C/1m/2obs — attacked the burst-15 link/close/compound surfaces. P19-001 (CRITICAL): D-021 close emitter branch enforces hard-floor (STEP4) + kill-switch (STEP5) but NOT the disposition∈{FP,BTP} leg — a TP verdict scored LOW/MED with ticket_action_type=close auto-closes a confirmed-malicious ticket (O3 regression: LLM ticket_action_type=close trusted without cross-checking verdict.disposition); clear fix (enforce the FP/BTP leg D-021 already mandates). P19-002 (MINOR): D-022 compound has no partial-failure/orphan-link recovery spec (create succeeds, link verdict never lands → orphaned unlinked ticket); no covering VP. P19-003 (OBS): jira_close_state lacks emit-time re-validation/regex_escape (config-side, allowlist-safe now; defense-in-depth). P19-004 (OBS, low-conf): §3.4 rule-2 comment+link vs 'keep tickets separate' — provenance ambiguity (architect to adjudicate from brief). LINK + COMPOUND surfaces re-derived otherwise sound; burst-15 broke no prior invariant. Report persisted. |
| F2: pass-19 remediation burst 16 | architect / product-owner / formal-verifier / state-manager | DONE | D-023 close disposition gate: `disposition∈{FP,BTP}` FIRST check in close branch; fires regardless of `autonomy_enabled`; TP MUST NOT be auto-closed; EC-013 3-condition AND restored. D-024 §3.4 rule-2 = create+link (HUMAN DECISION 2026-07-23; parallel to rule 4). Orphan-link reconciliation spec (SM-68 [ID-sync per FV] / VP-HOOK-036 extended). BC-3.03.001 v1.27→v1.28, BC-10.01.001 v1.21→v1.22, BC-4.02.001 v1.13→v1.14. arch-delta v1.21, verif-delta v1.21, prd-delta v1.18→v1.19. SM-66/SM-67/SM-68 allocated [ID-sync per FV]. VP count 41 / SM count 61. Clean streak 0/3. |

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
| D-011 | P11-002 two-field severity model: verdict.severity = detector-native NORMALIZE_SEVERITY output (Stage 1 INGEST only, LLM-supplied); verdict.scored_priority (field 18, ∈{CRIT,HIGH,MED,LOW}) = Stage-5 assess-priority output. The HIGH/CRIT hard floor keys on scored_priority ONLY — the two fields may legitimately differ (e.g., KEV escalation raises scored_priority to CRIT while verdict.severity stays LOW). | Eliminates the P11-002 CRITICAL: STEP 1a exact-equality would deny legitimately recalibrated verdicts (Stage-5 can raise or lower priority independently of the raw sensor reading). Scored_priority is also LLM-supplied — same ASM-008-class residual, NOT ground-truth. | F2 | 2026-07-22 | human |
| D-012 | P11-001 STEP 1a consistency-only reframe: STEP 1a is a DETERMINISTIC CONSISTENCY CHECK between verdict.severity and verdict.native_severity (both LLM-supplied Stage-1 fields). The pass-10 "un-bypassable / independently derives from raw sensor values" language is WITHDRAWN as FALSE. native_severity trust classified as ASM-008-DEFERRED residual symmetric with asset_type and scored_priority. | An adversarial LLM can supply a correlated false (native_severity, sensor_family) pair that passes the consistency check. Genuine severity ground-truth requires hook-fetched prism data (network-free hooks cannot provide it) — a pre-production follow-up identical to the asset_type residual. | F2 | 2026-07-22 | human |
| D-013 | P11-003 NVD/CVSS clean separation: CVSS/NVD enrichment influences scored_priority (Stage-5 assess-priority), NOT native_severity. The sensor_family enum {crowdstrike,armis,claroty,cyberint} has no 'nvd' member; a CVSS float is never a hook-checked native_severity source. The pass-10 NVD/CVSS-float SEVERITY-MISMATCH vector is REMOVED from VP-HOOK-030. | Eliminates the P11-003 MAJOR false-SEVERITY-MISMATCH: passing a CVSS float as native_severity would trigger a spurious SEVERITY-MISMATCH deny because no sensor_family maps to CVSS normalisation in the D-DEC-013 table. | F2 | 2026-07-22 | human |
| D-014 | P11-004 separate human-comment marker path: the 12-field ICD-203 investigation-markdown path (PC#2 dispatch in BC-3.03.001) does NOT enter the verdict emitter. It uses a SEPARATE minimal comment-scoped marker path gated ONLY on 12-field completeness + markdown-evaluable hard floors (Indeterminate disposition, forbidden techniques, degraded/silent sensor). validate_enums() and STEP 1a are NOT called on this path (both reference verdict-only fields absent from a 12-field markdown). VP-HOOK-031 + SM-47 allocated for this path. | Eliminates the P11-004 MAJOR impossibility: the pass-10 emitter's validate_enums() would deny a complete, valid 12-field investigation save because verdict-only fields (severity, asset_type, scored_priority, etc.) are absent from a markdown investigation. | F2 | 2026-07-22 | human |
| D-015 | P12-002 markdown-comment path four-guarantee redesign: (a) autonomy_enabled absent/≠true → allow-without-marker (kill switch, matching STEP-5 semantics — no autonomous comment marker under kill switch); (b) disposition≠FP → route to create-review/comment-review (TP/BTP surfaces to human review; hook cannot evaluate scored_priority/asset_type from 12-field markdown); (c) disposition=FP + all markdown-evaluable floors pass → comment marker; (d) ticket_id charset-validated on markdown path per O7. Architecture-delta v1.15 §8.26.1. SM-50 (kill-switch gate removed) + SM-51 (route-to-review removed) allocated. | Closes autonomous-loop-masquerade bypass: the loop gains nothing by writing a TP as investigation-*.md because the kill switch is enforced AND non-FP verdicts are routed to human review unconditionally. | F2 | 2026-07-22 | human |
| D-016 | P12-003 known-FP fast-path (Stage 5 bypassed) is EXEMPT from the scored_priority HIGH/CRIT hard floor (BC-10.01.001 EC-009): a documented known-FP + healthy sensor + non-forbidden technique + disposition=FP → auto-close even at high native severity. Residual bounded by known-FP store integrity invariants (store is not LLM-writable, audited at each use, subject to periodic operator review). See DI-015 for the residual risk tracking. | Known-FP store constitutes human pre-authorization for fast-path dismissal. Score re-escalation cannot occur if the store is clean; false-positive risk is bounded by store integrity — a distinct and bounded residual class from the ASM-008 LLM-supplied-field class. | F2 | 2026-07-22 | human |
| D-017 | P13-001 MARKDOWN_COMMENT_PATH ELIMINATED: the 12-field ICD-203 investigation-markdown path NEVER issues an autonomous comment marker for any disposition. FP → allow-without-marker (Write succeeds; no Jira action authorized); non-FP/PARSE_FAIL → MARKDOWN_REVIEW_PATH. VP-HOOK-031 guarantee (c) rewritten. SM-52 (FP-comment-marker revert) allocated. | Recurring CRITICAL (P12-002 closed TP masquerade, P13-001 closes residual FP branch). Hook cannot evaluate scored_priority/asset_type from 12-field markdown; no known-FP store cross-check applies on this path. Any autonomous comment from this path bypasses all floors. P11-004 human-analyst intent preserved: Write is not denied; FP comment surfaces via review flow. | F2 | 2026-07-22 | human |
| D-018 | P13-002 RC demo key corrected: PRISM-DEMO → PRISMDEMO throughout specs/test-vectors/brief. Jira project keys MUST be hyphen-free (^[A-Z][A-Z0-9]+$). Setup-time validation added to BC-6.01.001 (activate Postcondition #12) and BC-6.01.003 (onboard-customer Invariant #6) — non-conformant keys rejected with explicit user-facing error at configuration time, not fail-closed mid-run. | PRISM-DEMO is not a valid Jira project key: the P12-001 charset validation (correct-for-Jira) would reject it on every marker issuance. The RC live-demo could never issue any Jira write. Regex is correct; the example was wrong. Fail-early prevents the silent livelock class entirely. | F2 | 2026-07-22 | human |
| D-019 | known-FP scored_priority floor exemption SCOPED to LOW/MED-severity only; HIGH/CRIT-native known-FPs route to comment-review (human review) via hard_floor_applies(), NOT auto-close; no deterministic-gate change (gate was already correct); LLM-known_fp-field rejected (forgeable CRITICAL bypass, O6). Revises D-016/P12-003b for the high-sev subset. | hard_floor_applies() fires unconditionally on scored_priority ∈ {HIGH,CRIT} — disposition-guard has no forgery-proof known-FP signal; an in-band LLM known_fp field would be a CRITICAL O6 bypass. Exempting HIGH/CRIT known-FPs from the floor would require a deterministic hook-recomputable signal that does not exist. LOW/MED exemption stands (those do not reach the floor). | F2 | 2026-07-23 | human |
| D-020 | Link marker scope: `jr issue link KEY1 KEY2` (KEY1=marker.ticket_id, KEY2=marker.link_target_ticket_id); `["link"]` marker added as distinct anti-fungible scope; `jr issue link` added to write-block; default link-type "Relates"; REGULAR scope (hard-floor+kill-switch gated). | `jr issue link` had NO authorization path in any require-review rule — no write-block entry, no allowlist entry, no marker scope. §3.4 correlation rules 2 and 4 issue a link autonomously; fail-closed denied every link silently. P18-001. | F2 | 2026-07-23 | human |
| D-021 | Close/move marker scope: `jr issue move KEY STATE` (STATE from CONFIG-driven CLOSE_STATE_ALLOWLIST={Done,Closed,Resolved}); HIGH/CRIT NEVER auto-closed (hard-floor unconditional); only FP/BTP + non-hard-floor + autonomy_enabled=true eligible; REGULAR scope (hard-floor+kill-switch gated). | `jr issue move/close` had no authorization path; "Close (if open)" in §3.4 rule 4 was ambiguous re autonomy scope. STATE must be CONFIG-driven (not verdict-influenceable) to prevent close-state injection. HIGH/CRIT auto-close violates human-oversight invariant. P18-005/P18-004. | F2 | 2026-07-23 | human |
| D-022 | Compound §3.4 actions (rule 2: comment+link; rule 4: create+link) = two sequential verdict Writes, each with its own single-use anti-fungible marker; preserves one-verdict-one-marker invariant; SM-65 (single-marker compound attempt) validates the prohibition. | One-verdict-one-marker model cannot authorize two distinct Jira commands with a single marker without scope conflation. Two Writes, each authorized by its own marker, maintain anti-fungibility and allow each Write to be independently audited or denied. P18-003. | F2 | 2026-07-23 | human |
| D-023 | Close disposition gate: `ticket_action_type=close` MUST cross-validate `verdict.disposition∈{FP,BTP}` as the FIRST check in the close branch before issuing close marker; TP MUST NOT be auto-closed; gate fires regardless of `autonomy_enabled`; EC-013 3-condition AND = `disposition∈{FP,BTP}` AND `hard_floor_applies()=false` AND `autonomy_enabled=true`. | P19-001 CRITICAL (O3 regression — D-021 stated the disposition gate but burst-15 implementation omitted it; TP verdict scored LOW/MED with `ticket_action_type=close` would auto-close a confirmed-malicious ticket without checking disposition). | F2 | 2026-07-23 | human |
| D-024 | §3.4 rule-2 = create+link (not comment+link): rule 2 (same asset/IOC, different root cause, open ticket exists) uses create+link two-Write model, parallel to rule 4; "keep tickets separate" — each root cause has its own ticket; verdict-1 (create new ticket) → verdict-2 (link new ticket to existing related ticket) per D-022 model. | P19-004 OBS → architect adjudicated from brief: "keep tickets separate" semantics mandate a new ticket per root cause; rule-2 comment+link was incorrect (a comment on an existing ticket conflates root causes); rule-2 create+link is consistent with rule-4 and the "Relates" link establishes the provenance. | F2 | 2026-07-23 | human |

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
| ASM-008-DEFERRED | LLM-supplied field cross-validation deferred (SYMMETRIC across three fields): (1) native_severity — LLM-written at Stage 1 INGEST; hook re-normalizes for STEP 1a consistency check but cannot verify ground-truth against sensor source without network access; (2) asset_type — sensor-specific asset taxonomy (CrowdStrike asset categories, Armis/Claroty device types) not empirically validated; (3) scored_priority — Stage-5 assess-priority output written by LLM; hook applies the HIGH/CRIT floor but cannot independently verify the scoring. All three require prism-side cross-validation (network-free hooks cannot provide ground-truth for any). Genuine hook-side enforcement deferred to ASM-008 resolution or pre-production. Known residual after P10-001 (severity) + P11-001/D-012 (native_severity/scored_priority symmetry explicit). | MEDIUM | ASM-008 resolution / pre-production | ADV-F2-P10-001 / ADV-F2-P11-001 | OPEN — KNOWN-DEFERRED |
| ASM-015 | BLOCKING pre-Wave-3 loop stories: empirical validation needed that permissionDecision:deny from a PreToolUse hook populates `.permission_denials[]` in --allowedTools JSON envelope; Gate 1 check on permission_denials > 0 is unvalidated until ASM-015 resolves; is_error=true is the only proven reliable exit-1 trigger for Gate 1. | BLOCKING | pre-Wave-3 | ADV-F2-P10-002 | OPEN — BLOCKING |
| ASM-014 | comment-review --label binding pending: the comment-review kill-switch exemption is currently broader than "review ticket only" — restricting it to review-labeled tickets is deferred until empirical validation that `jr issue comment --label` is supported. | LOW | pre-Wave-3 (wave-stories touching comment-review path) | ADV-F2-P10-008 | OPEN — DEFERRED |
| DI-015 | Known-FP store integrity residual (P12-003 / D-016 / D-019): a poisoned known-FP store entry could suppress a real LOW/MED-severity alert via the fast-path floor exemption. Mitigations in place: store is not LLM-writable, is audited at every use, and is subject to periodic operator review. D-019 further bounds this residual: HIGH/CRIT-native known-FPs now route to human review (comment-review) rather than auto-close — a poisoned high-sev store entry gets a human glance, NOT silent auto-close. Risk accepted per D-016/D-019; bounded by store governance, not LLM trust model. | MEDIUM | pre-production / store-governance | ADV-F2-P12-003 | OPEN — KNOWN-DEFERRED |

## Blocking Issues

<!-- Open issues only. Move resolved issues to cycles/<cycle>/blocking-issues-resolved.md. -->

| ID | Issue | Severity | Blocking Phase | Owner | Resolution |
|----|-------|----------|----------------|-------|------------|

## Session Resume Checkpoint

| Field | Value |
|-------|-------|
| **Date** | 2026-07-23 |
| **Position** | SESSION WRAP COMPLETE. Pass-19 remediation DONE (burst 16 — D-023/D-024/SM-68). SESSION-HANDOFF.md v2.2 written. NEXT: adversarial pass 20 (fresh adversary context — do NOT reuse prior pass context; carry D-023/D-024 as confirmed invariants). Clean streak 0/3. |
| **Context** | Artifact versions: arch-delta v1.21, verif-delta v1.21, prd-delta v1.19, BC-3.03.001 v1.28, BC-3.01.001 v1.23, BC-10.01.001 v1.22, BC-4.02.001 v1.14, BC-6.01.001 v1.8, BC-5.01.001 v1.12, BC-6.01.003 v1.7, BC-4.05.001 v1.4, BC-8.02.001 v1.4, BC-9.01.001 v1.2, dtu-assessment v1.2. VPs 41 / SM 61 (SM-9..SM-68, SM-32=32a+32b+32-ext; SM-55 skipped). SESSION-HANDOFF.md v2.2. NOTE: .factory/hooks/ not instantiated; verify-sha-currency.sh not run. |
| **Convergence counter** | 0/3 clean passes |

## Historical Content

| Content | Location |
|---------|----------|
| Burst history | `cycles/<cycle>/burst-log.md` |
| Convergence trajectory | `cycles/<cycle>/convergence-trajectory.md` |
| Session checkpoints | `cycles/<cycle>/session-checkpoints.md` |
| Lessons learned | `cycles/<cycle>/lessons.md` |
| Resolved blockers | `cycles/<cycle>/blocking-issues-resolved.md` |

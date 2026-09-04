---
document_type: session-handoff
level: ops
version: "2.3"
status: current
producer: state-manager
timestamp: 2026-09-04T00:00:00Z
project: secops-factory
supersedes: "2.2 (2026-09-03T23:00:00Z)"
---

# SESSION-HANDOFF: secops-factory

### RESUME IN ONE BREATH

F2 adversarial spec convergence COMPLETE (3/3 clean, passes 44/45/46; 46 total). F2 gate APPROVED by human 2026-09-04. OBS-GC-001/002 FIXED this wrap (BC-10.01.001 updated). STORY-DEMO-SEED-001 placeholder stub created. NEXT: execute (scoping-shrunken) MIG-001 — PART A only (fix .claude/settings.json enabledPlugins vsdd-factory@vsdd-factory → vsdd-factory@claude-mp; product repo main-branch edit or small PR). PART B (relocation) → ACCEPT (deny-hook non-enforcing, 121 files unmapped/infeasible). PART C (DI-018 fuel-cap/shard) → ACCEPT-DEFER rc.25+. Then F3 story decomposition (Wave 7 monitoring-loop): decompose 5 new BCs (BC-6.01.003/004, BC-8.02.001, BC-9.01.001, BC-10.01.001) + 6 modified BCs; finalize story-naming (STORY-DEMO-SEED-001 = placeholder, assign canonical S-N.MM at F3 kickoff); compute 6 COMPUTE-AT-COMMIT input-hashes. NOTE: .factory/hooks/ not instantiated; verify-sha-currency.sh not run (known throughout this cycle).

---

## HEADS

| Ref | SHA | Remote | Notes |
|-----|-----|--------|-------|
| main | e8bf19f (PRs #18+#19 MERGED) | origin/main (in sync) | cross-platform packaging shipped; PRs #18+#19 merged |
| factory-artifacts | see `git -C .factory log -1 --format='%h %s'` | origin/factory-artifacts (PUSHED) | this wrap commit; prior tip c1a19f4 |

---

## CONVERGED ARTIFACT VERSIONS (post-burst-42 FROZEN + OBS-GC wrap fixes)

**BCs (phase-0-ingestion/behavioral-contracts/ and phase-f2-spec-evolution/):**

| BC ID | Version | Subject |
|-------|---------|---------|
| BC-3.01.001 | v1.25 | require-review — marker consumer (link+close scopes, anti-fungibility) |
| BC-3.03.001 | v1.42 | disposition-guard — marker emitter (full convergence) |
| BC-4.02.001 | v1.21 | update-jira (rule-2 create+link, rule-4, orphan-link) |
| BC-4.05.001 | v1.4 | assess-priority (COMPUTE-AT-COMMIT input-hash pending) |
| BC-5.01.001 | v1.15 | investigate-event |
| BC-6.01.001 | v1.8 | activate (CLOSE_STATE_ALLOWLIST validation; COMPUTE-AT-COMMIT pending) |
| BC-6.01.003 | v1.7 | onboard-customer (NEW; COMPUTE-AT-COMMIT pending) |
| BC-6.01.004 | v1.1 | onboard-sensor (NEW; COMPUTE-AT-COMMIT pending) |
| BC-8.02.001 | v1.4 | sensor-metrics (NEW; COMPUTE-AT-COMMIT pending) |
| BC-9.01.001 | v1.2 | scan-threats (NEW; COMPUTE-AT-COMMIT pending) |
| BC-10.01.001 | v1.36 | monitoring-loop (EC 24; VALIDATE_WATERMARK_FOR_RUN once-per-run; OBS-GC-001/002 FIXED this wrap) |

**Delta docs (phase-f2-spec-evolution/):**

| File | Version | Input-hash |
|------|---------|------------|
| architecture-delta.md | v1.34 | d7bcab4 |
| verification-delta.md | v1.38 | (SM 76 alloc / 75 live; ~840KB FUEL_EXHAUSTED known) |
| prd-delta.md | v1.39 | 1c4be4c |
| dtu-assessment.md | v1.7 | DTU_REQUIRED: true — prism-demo-server + jr-mock |
| BC-10.01.001 | v1.36 | 742b491 |
| BC-3.03.001 | v1.42 | 95fcec5 |
| BC-3.01.001 | v1.25 | 96609a9 |

**VP / SM / EC counts:** VP 41 (21 FINALIZED P0 + 6 PROPOSED P1); SM 76 alloc / 75 live; EC 24 (BC-10.01.001) + 56 sub-burst-1 + 80 cycle. BATS: 113. 7 coherence lessons codified (51–57 in cycles/.../lessons.md).

---

## PENDING / CARRIED

### MIG-001 (SCOPED — human should confirm accept/defer on resume)

- **PART A (DO):** Edit `/Users/jmagady/Dev/secops-factory/.claude/settings.json` enabledPlugins → `{"vsdd-factory@claude-mp": true}` (remove the broken `vsdd-factory@vsdd-factory` key). This file is on the PRODUCT repo (main), NOT .factory — small main-branch change (direct edit or tiny PR). Caveat: enabled-but-unpinned floats to newest-cached; no project-scope pin mechanism exists.
- **PART B (ACCEPT — do NOT relocate):** rc.24 validate-artifact-path deny-hook is EMPIRICALLY NON-ENFORCING here (resolves registry at project-relative `plugins/vsdd-factory/config/...` which doesn't exist in a cache-installed consumer → graceful-degrade allow on every write; confirmed in `.factory/logs/dispatcher-internal-2026-09-04.jsonl`). Full relocation INFEASIBLE (fresh dry-run: 162 files, 41 mappable / 121 unmapped — no rc.24 canonical home for holdout-scenario, prd/arch/verification-delta, phase-0/f1 outputs, adversarial/validation reports). Recommend accept layout; bounded BC-only relocation possible but low-payoff (deny-hook doesn't enforce) and needs the ss-{slug} vs ss-NN decision + 41-file cross-ref repair.
- **PART C (ACCEPT-DEFER — DI-018):** fuel-cap raise INFEASIBLE (engine-only; ADR-039 Phase-1 per-plugin fuel_cap unshipped; global ~10M cap compiled into factory-dispatcher). Shard of 840KB verification-delta HIGH-RISK (65 references + breaks §2 VP-table / §5 per-BC-test single-doc coherence). Fail-open CONFIRMED (on_error=continue → edits land). Record DI-018 in tech-debt register as "accepted, fail-open confirmed". Revisit rc.25+; if F3 §5 editing is heavy, extract only §5 as a working copy.
- **Compute 6 COMPUTE-AT-COMMIT input-hashes (do on F3 resume; safe):** BC-4.05.001 v1.4, BC-6.01.001 v1.8, BC-6.01.003 v1.7, BC-6.01.004 v1.1, BC-8.02.001 v1.4, BC-9.01.001 v1.2.

### F3 Story Decomposition (next after MIG-001 Part A)

- Decompose 5 new BCs (BC-6.01.003/004, BC-8.02.001, BC-9.01.001, BC-10.01.001) + 6 modified BCs into Wave 7 monitoring-loop stories.
- FINALIZE story-naming convention: STORY-DEMO-SEED-001 is a placeholder — assign canonical S-N.MM at F3 kickoff.
- STORY-DEMO-SEED-001: demo-seed Jira Option A; operator tooling under scripts/demo/ per D-006; revisit whether it belongs in secops-factory F3 vs operator demo-ops.

### Open Blockers

| ID | Issue | Blocking |
|----|-------|---------|
| ASM-015 | BLOCKING pre-Wave-3: empirical validation needed that permissionDecision:deny from PreToolUse hook populates `.permission_denials[]` in --allowedTools JSON envelope; Gate 1 check on permission_denials > 0 is unvalidated. | pre-Wave-3 / pre-F4 |
| ASM-009 | BLOCKING pre-Wave-3: cross-hook marker filesystem visibility — disposition-guard emits and require-review consumes from `${CLAUDE_PLUGIN_DATA}/markers/`. If shared-fs assumption fails BATS test, marker mechanism (D-DEC-001/012) needs redesign. Architecturally load-bearing. | pre-Wave-3 / pre-F4 |

### Accepted/Deferred Residuals

| ID | Status |
|----|--------|
| ASM-008-DEFERRED | LLM-supplied field cross-validation (native_severity, asset_type, scored_priority) deferred to prism-side. KNOWN-DEFERRED. |
| DI-018 | verification-delta.md FUEL_EXHAUSTED. ACCEPT-DEFER rc.25+. fail-open confirmed (D-032). |
| DI-017 | verdict.org_slug unvalidated. KNOWN-DEFERRED (ASM-008 class). |
| DI-015 | Known-FP store integrity residual. KNOWN-DEFERRED (bounded by D-019). |
| DI-016 | jr issue unlink/remote-link silent deny observability gap. OPEN LOW. |
| ASM-014 | comment-review --label binding deferred pending empirical validation. DEFERRED pre-Wave-3. |

---

## KEY DESIGN STATE

- **Marker mechanism (DI-013 resolution, D-005):** filesystem markers at `${CLAUDE_PLUGIN_DATA}/markers/`, canonical schema v2.1 (absolute `expires_at_utc` 120s TTL, `authorized_operations` tokens, iterative-consume oldest-first, `markers/audit.log`). `command_pattern`: ticket-bound for comment/assign; anchored project-bound for create. disposition-guard is the ONLY emitter; require-review the consumer. Document-before-action ordering (Stage 7 DOCUMENT emits marker → Stage 8 TICKET ACTION consumes). JSON-first dispatch. `validate_enums()` fail-closed. 15-field ICD-203 verdict schema. Hard floors deterministic on `verdict.severity`/`asset_type`/`attack_techniques`; `asset_type=unknown` is a hard floor.
- **Option A (D-007):** create-review/comment-review markers live under `autonomy_enabled=false`, gated on hook-computed `hard_floor_applies() OR disposition==Indeterminate`. Kill-switch DENY-THE-WRITE (D-008). Close disposition gate hoisted to STEP 4b (D-025). Compound actions = two sequential Writes each with own anti-fungible marker (D-022). Review-class link (D-027). Markdown path = route-to-review-NEVER-deny (D-029).
- **DETECT_LATE_EVENT:** DETECT_LATE_EVENT per-event logic REPLACED by VALIDATE_WATERMARK_FOR_RUN (once-per-run gate). burst-42 hardening complete. SM-82/83 REDEFINED.

---

## DECISION DELTA (this session)

| Decision | Detail | Status |
|----------|--------|--------|
| F2 gate APPROVED | F2 convergence gate APPROVED by human 2026-09-04. Convergence 3/3 COMPLETE (passes 44/45/46). F2 spec LOCKED; F3 authorized. | D-030 |
| MIG-001 scoped | PART A only (enable key fix). PARTS B+C → ACCEPT (deny-hook non-enforcing, relocation infeasible 121 unmapped). | D-031 |
| DI-018 ACCEPT-DEFER | fuel_cap unshipped (ADR-039 Phase-1); shard HIGH-RISK (65 refs + coherence). fail-open confirmed. Record in tech-debt register. Revisit rc.25+. | D-032 |
| V1 scope | Claroty-xDome-only; runtime-scope; 4-sensor spec retained. | D-033 |
| "Merge Prism" | Runtime MCP service + prism-dtu-demo-server DTU (NOT code merge). Prism repo /Users/jmagady/Dev/prism (rc.22/23). CIRCULAR RC GATE: sequence Prism live-xDome validation + bundle publish FIRST. | D-034 |
| demo-seed Option A | STORY-DEMO-SEED-001 placeholder stub. scripts/demo/ operator tooling. D-006 confirmed (demo orchestration = operator's concern). | D-035 |
| OBS-GC-001/002 FIXED | BC-10.01.001 updated this wrap (2026-09-04): EC-023 attribution aligned to VALIDATE_WATERMARK_FOR_RUN; L604 shorthand aligned to normative L625 formula. | this wrap |
| Cross-platform Windows-parity | Follow-up OPEN (not started). PRs #18+#19 shipped cross-platform packaging (main). | open follow-up |
| Planning briefs | On factory-artifacts .factory/feature/: claroty-xdome-v1-planning-brief.md, cross-platform-packaging-design.md, prism-integration-handoff-brief.md. | reference |

---

## WORKTREE INVENTORY

| Worktree | Branch | Path | Status |
|----------|--------|------|--------|
| main | main | `/Users/jmagady/Dev/secops-factory` | active; PRs #18+#19 merged; clean |
| .factory | factory-artifacts | `/Users/jmagady/Dev/secops-factory/.factory` | active; this wrap commit |

---

<!-- ═══════════════════════════════════════════════════════════ -->
<!-- SUPERSEDED SNAPSHOT (v2.2 — 2026-09-03T23:00:00Z)         -->
<!-- ═══════════════════════════════════════════════════════════ -->

---

## [SUPERSEDED] Prior RESUME IN ONE BREATH (v2.2 — 2026-09-03)

secops-factory prism-integration v0.10.0 feature cycle is mid-Phase-F2 (spec evolution). F1 approved+committed. Full F2 spec body (11 BCs + delta docs) FROZEN. Pass-19 remediation COMPLETE (burst 16 — D-023 close disposition gate + D-024 rule-2 create+link + orphan-link reconciliation SM-68/VP-HOOK-036 extended [ID-sync per FV]). VPs 41 / SM 61 (SM-9..SM-68, SM-32=32a+32b+32-ext, SM-55 skipped). Artifact versions: arch-delta v1.21, verif-delta v1.21, prd-delta v1.19, BC-3.03.001 v1.28, BC-3.01.001 v1.23, BC-10.01.001 v1.22, BC-4.02.001 v1.14, BC-6.01.001 v1.8, others unchanged. D-DEC-001..D-024 locked. O3 standing rule: LLM-supplied routing fields granting state-change controls MUST be cross-validated against hook-computed invariants (D-023 close disposition gate is the latest instance). Clean streak 0/3. NEXT ACTION: adversarial pass 20 (fresh adversary context — do NOT reuse prior pass context; carry D-023/D-024 as confirmed new invariants). NOTE: .factory/hooks/ not instantiated in this project; verify-sha-currency.sh not run.

---

## [SUPERSEDED] HEADS (v2.2)

| Ref | SHA | Remote | Notes |
|-----|-----|--------|-------|
| main | d181ca2 | origin/main (in sync) | only untracked .claude/ local tooling |
| factory-artifacts | see `git -C .factory log -1 --format='%h %s'` | origin/factory-artifacts (PUSHED) | v2.2 wrap commit |

---

## [SUPERSEDED] FROZEN F2 ARTIFACT VERSIONS (v2.2 — post-pass-5-remediation)

**BCs (phase-0-ingestion/behavioral-contracts/):**

| BC ID | Version | Subject |
|-------|---------|---------|
| BC-3.01.001 | v1.23 | require-review — marker consumer (link+close scopes, anti-fungibility) |
| BC-3.03.001 | v1.28 | disposition-guard — marker emitter (D-023 close disposition gate + orphan-link) |
| BC-4.02.001 | v1.14 | update-jira (D-024 rule-2 create+link) |
| BC-4.05.001 | v1.4 | assess-priority |
| BC-5.01.001 | v1.12 | investigate-event |
| BC-6.01.001 | v1.8 | activate (CLOSE_STATE_ALLOWLIST setup-time validation) |
| BC-10.01.001 | v1.22 | monitoring-loop (D-023/D-024 propagation; orphan-link reconciliation SM-68) |
| BC-6.01.003 | v1.7 | onboard-customer (NEW) |
| BC-6.01.004 | v1.1 | onboard-sensor (NEW) |
| BC-8.02.001 | v1.4 | sensor-metrics (NEW) |
| BC-9.01.001 | v1.2 | scan-threats (NEW) |

**Delta docs (phase-f2-spec-evolution/):**

| File | Version |
|------|---------|
| architecture-delta.md | v1.21 |
| verification-delta.md | v1.21 |
| prd-delta.md | v1.19 |
| dtu-assessment.md | v1.2 |

**VP namespace:** VP-SKILL 001-077, VP-HOOK 024-036. Mutation vectors SM-9..SM-68. Decisions D-DEC-001..D-024.

---

## [SUPERSEDED] PENDING / CARRIED (v2.2)

- **IMMEDIATE NEXT:** Adversarial pass 20 (fresh adversary context required). Clean streak 0/3.
- Pass-19 remediation COMPLETE (burst 16). All artifacts committed and pushed (factory-artifacts).
- Pass-1..18 all remediated. Consistency audit pass-13 CLEAN.
- **Remaining minor punch-list (resolve before F2 state-backup):** F-001: arch-delta §5.4 historical quote cosmetic label. F-002: 6 established BCs carry bare "COMPUTE-AT-COMMIT" input-hash.
- DI-013 RESOLVED in-spec via marker mechanism (D-005).
- AFTER 3 clean passes: F2 state-backup (compute F-002 bare hashes here), then F2 human gate, then F3 story decomposition.
- NOTE: .factory/hooks/ not instantiated in this project; verify-sha-currency.sh was not run for any session wrap in this cycle.

---

<!-- ═══════════════════════════════════════════════════════════ -->
<!-- SUPERSEDED SNAPSHOT (v2.1 — 2026-07-21T18:00:00Z)         -->
<!-- ═══════════════════════════════════════════════════════════ -->

---

## [SUPERSEDED] Prior RESUME IN ONE BREATH (v2.1 — 2026-07-21)

secops-factory prism-integration v0.10.0 feature cycle is mid-Phase-F2 (spec evolution). F1 approved+committed. The full F2 spec body (11 BCs + delta docs) is FROZEN and committed. Pass-5 remediation is COMPLETE and committed (P5-001/P5-002/P5-003 all resolved; kill-switch Option A confirmed by human 2026-07-21). Consistency audit pass-5 is COMPLETE (PASS-WITH-MINORS, 0 blocking). Clean streak remains 0/3. NEXT ACTION: adversarial pass 6 (fresh adversary context — do NOT reuse pass-5 adversary context). Current artifact versions: arch-delta v1.8, verif-delta v1.8, prd-delta v1.9, BC-3.03.001 v1.14, BC-10.01.001 v1.10, brief §3.9 amended. All other BCs unchanged from their F2-frozen versions. D-DEC-001..012 locked. D-007 (Option A kill-switch decision) committed.

---

<!-- ═══════════════════════════════════════════════════════════ -->
<!-- SUPERSEDED SNAPSHOT (v1.0 — 2026-07-20T05:30:00Z)         -->
<!-- ═══════════════════════════════════════════════════════════ -->

---

## [SUPERSEDED] Prior RESUME IN ONE BREATH (v1.0 — 2026-07-20)

secops-factory is fully VSDD-onboarded and PARKED at phase-0-complete,
awaiting a feature-request. Nothing is in flight; everything is pushed
(main d181ca2, factory-artifacts eea5b69 → then wrap commit). NEXT
ACTION: when the human returns with a feature, the orchestrator detects
`phase: 0-complete` and routes it into Feature Mode / Phase 1 with
`project-context.md v2.3` as scope (Phase 0 skipped) — do NOT re-run
Phase 0.

---

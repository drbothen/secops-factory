---
document_type: session-handoff
level: ops
version: "2.2"
status: current
producer: state-manager
timestamp: 2026-07-23T23:59:00Z
project: secops-factory
supersedes: "2.1 (2026-07-21T18:00:00Z)"
---

# SESSION-HANDOFF: secops-factory

### RESUME IN ONE BREATH

secops-factory prism-integration v0.10.0 feature cycle is mid-Phase-F2 (spec evolution). F1 approved+committed. Full F2 spec body (11 BCs + delta docs) FROZEN. Pass-19 remediation COMPLETE (burst 16 — D-023 close disposition gate + D-024 rule-2 create+link + orphan-link reconciliation SM-68/VP-HOOK-036 extended [ID-sync per FV]). VPs 41 / SM 61 (SM-9..SM-68, SM-32=32a+32b+32-ext, SM-55 skipped). Artifact versions: arch-delta v1.21, verif-delta v1.21, prd-delta v1.19, BC-3.03.001 v1.28, BC-3.01.001 v1.23, BC-10.01.001 v1.22, BC-4.02.001 v1.14, BC-6.01.001 v1.8, others unchanged. D-DEC-001..D-024 locked. O3 standing rule: LLM-supplied routing fields granting state-change controls MUST be cross-validated against hook-computed invariants (D-023 close disposition gate is the latest instance). Clean streak 0/3. NEXT ACTION: adversarial pass 20 (fresh adversary context — do NOT reuse prior pass context; carry D-023/D-024 as confirmed new invariants). NOTE: .factory/hooks/ not instantiated in this project; verify-sha-currency.sh not run.

---

## HEADS

| Ref | SHA | Remote | Notes |
|-----|-----|--------|-------|
| main | d181ca2 | origin/main (in sync) | only untracked .claude/ local tooling |
| factory-artifacts | see `git -C .factory log -1 --format='%h %s'` | origin/factory-artifacts (PUSHED) | this wrap commit |

---

## FROZEN F2 ARTIFACT VERSIONS (post-pass-5-remediation ground truth)

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
| architecture-delta.md | v1.21 (D-023 close disposition gate; D-024 rule-2 create+link; orphan-link reconciliation; EC-013 3-condition AND) |
| verification-delta.md | v1.21 (SM-66/SM-67/SM-68 allocated; VP-HOOK-035/036 extended; 41 VPs / 61 mutants; ~429 tests) |
| prd-delta.md | v1.19 (burst-16 §5 post-note; BC versions v1.28/v1.22/v1.14 recorded) |
| dtu-assessment.md | v1.2 — DTU_REQUIRED: true — prism L3 via prism demo server, jr L2 mock |
| asm-004-validation.md | PARTIAL → resolved-by-design (--strict-mcp-config --mcp-config prism.mcp.json) |
| adversarial-spec-delta-review-pass1..19.md | pass1..18 remediated; pass19 remediated (burst 16) |
| spec-changelog.md | spec 1.0.0 → 1.1.0 MINOR (+ F2 passes 1-19 remediation edits through burst 16) |
| feature/prism-integration-handoff-brief.md | §3.9 amended — Option A kill-switch confirmed 2026-07-21 |

**VP namespace:** VP-SKILL 001-077, VP-HOOK 024-036. Mutation vectors SM-9..SM-68 (SM-32=32a+32b+32-ext; SM-55 skipped). Decisions D-DEC-001..D-024.

---

## KEY DESIGN STATE

- **Marker mechanism (DI-013 resolution, D-005):** filesystem markers at `${CLAUDE_PLUGIN_DATA}/markers/`, canonical schema v2.1 (absolute `expires_at_utc` 120s TTL, `authorized_operations` tokens, iterative-consume oldest-first, `markers/audit.log` control-char-stripped). `command_pattern`: ticket-bound for comment/assign; anchored project-bound for create (`^jr (--output json )?issue create --project <key>( |$)`, NO unbounded `.*`). disposition-guard is the ONLY emitter; require-review the consumer. Document-before-action ordering (Stage 7 DOCUMENT emits marker → Stage 8 TICKET ACTION consumes). JSON-first disposition-guard dispatch (verdict JSON → 15-field path even at `investigations/verdict-*.json`). `validate_enums()` fail-closed. 15-field ICD-203 verdict schema + operational metadata (`jira_project_key`, `confidence_score`, `autonomy_enabled`). Hard floors deterministic on `verdict.severity`/`asset_type`/`attack_techniques`; `asset_type=unknown` is a hard floor. D-DEC-012: `create-review`/`comment-review` RESTRICTED markers surface BLIND-SPOT/Indeterminate to Jira. **Option A (D-007, human-confirmed 2026-07-21):** create-review/comment-review markers remain live under `autonomy_enabled=false`, gated on hook-computed `hard_floor_applies() OR disposition==Indeterminate` (O3 standing rule — no LLM token alone bypasses the gate). Sensor-silence condition: `last_seen_ts age > 24 h` (VP-SKILL-061, fixed in BC-10.01.001 v1.10).

---

## PENDING / CARRIED

- **IMMEDIATE NEXT:** Adversarial pass 20 (fresh adversary context required — do NOT reuse context from any prior pass). Clean streak 0/3.
- Pass-19 remediation COMPLETE (burst 16): D-023 close disposition gate + D-024 rule-2 create+link + orphan-link reconciliation SM-68 [ID-sync per FV]. All artifacts committed and pushed (factory-artifacts).
- Pass-1..18 all remediated. Consistency audit pass-13 CLEAN (all 12 coherence findings resolved). ASM-008-DEFERRED / ASM-015 / ASM-014 / DI-015 remain KNOWN-DEFERRED (carried forward unchanged).
- **Remaining minor punch-list (resolve before F2 state-backup):**
  - F-001: arch-delta §5.4 historical quote cosmetic label — still open (low priority, will not block F2 gate).
  - F-002: 6 established BCs carry bare "COMPUTE-AT-COMMIT" input-hash — compute at F2 state-backup; does not block adversarial passes.
- DI-013 RESOLVED in-spec via marker mechanism (D-005).
- AFTER 3 clean passes: F2 state-backup (compute F-002 bare hashes here), then F2 human gate, then F3 story decomposition.
- NOTE: .factory/hooks/ not instantiated in this project; verify-sha-currency.sh was not run for any session wrap in this cycle.

## DECISION / LESSONS DELTA (pass-5 — CODIFIED)

| Item | Detail | Status |
|------|--------|--------|
| Root-cause one-liner | Deterministic disposition-guard hook trusts LLM-supplied ticket_action_type without cross-checking hard_floor_applies(); every LLM-supplied routing field that grants or bypasses a security control must be cross-validated against a hook-computed invariant (O3 standing rule). | CODIFIED in D-DEC-012, cycles/lessons.md lesson 4 |
| P5-001 lesson | Fail-loud guarantees must be enforced at the deterministic (hook) layer, not rely on correct LLM behavior for the exact threat class the marker design defends against. | CODIFIED in cycles/lessons.md lesson 1 |
| P5-002 lesson | Kill-switch exemptions gated on LLM-supplied tokens (create-review/comment-review) without a deterministic precondition create a bypass for the autonomy_enabled=false circuit-breaker — always gate exemptions on a hook-computed invariant, not on the token alone. | CODIFIED in D-007 + cycles/lessons.md lesson 2 |
| P5-003 lesson | A "single authoritative" schema block marked "fix the BC, not this document" that is stale w.r.t. later sections of the same document is actively dangerous — authoring discipline must keep the authoritative block in sync at every schema extension. | CODIFIED in cycles/lessons.md lesson 3 |

---

## DECISION DELTA (this session)

D-DEC-001..012 recorded in architecture-delta.md. D-004/005/006 in STATE decisions log.

---

## WORKTREE INVENTORY

| Worktree | Branch | Path | Status |
|----------|--------|------|--------|
| main | main | `/Users/jmagady/Dev/secops-factory` | active, clean |
| .factory | factory-artifacts | `/Users/jmagady/Dev/secops-factory/.factory` | active, committed this wrap |

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

## HEADS

| Ref | SHA | Remote | Notes |
|-----|-----|--------|-------|
| main | d181ca2 | origin/main (PUSHED, in sync) | PR #11–#17 merged; only untracked `.claude/` local tooling |
| factory-artifacts | see `git -C .factory log -1 --format='%h'` | origin/factory-artifacts (PUSHED, in sync) | only untracked `logs/` (transient) |

Worktrees: 2 active — `main` at `/Users/jmagady/Dev/secops-factory`, `.factory` at `/Users/jmagady/Dev/secops-factory/.factory`. Both clean. Open PRs: NONE. Agents in flight: NONE.

---

## [SUPERSEDED] STATUS

Phase 0 ingestion COMPLETE + fully remediated.

| Metric | Value |
|--------|-------|
| Behavioral Contracts | 17 (13 recovered + 4 new: advisory-pipeline BC-4.05, metrics-pipeline BC-4.06, investigation-entry BC-7.01, read-ticket BC-8.01) |
| Tests | 165 (all green; hooks 44 + skills 81→101 + integration 11 + parity 14 + new) |
| Holdouts | 34 (all must-pass; 26 original + 8 new for DI-012 skills; HS-029 injection guard) |
| Criticality map | 24 modules: 1 CRITICAL / 12 HIGH / 7 MEDIUM / 4 LOW |
| Mutation kill-rate | ~90-95% (SM-1 KILLED, SM-2 KILLED, zero open HIGH mutants) |
| PRs merged to main | 7 (#11 CI-harden, #12 gitignore, #13 SEC-001..005, #14 allowlist, #15 SEC-009 CRITICAL auth-gate bypass, #16 CI pwsh/schema, #17 hook soundness) |
| Security findings | 9 total (SEC-001..009); all RESOLVED except SEC-006/007 ACCEPTED (info) |
| Adversarial convergence | Phase 0 main loop: 13 passes → CLEAN (0 graded findings) |
| Post-remediation delta | 4 adversarial passes (ADV-R1..R4) → CLEAN |
| Drift register | 13/14 RESOLVED; DI-013 DEFERRED (human-approved) |

Notable: the adversarial loop discovered a **live shipped CRITICAL auth-gate bypass** in v0.9.0 — require-review evaluated its allowlist before the write-block using unanchored substring matching (SEC-009). Fixed via PR #15 (d304fa5).

---

## [SUPERSEDED] PENDING (user-approved / carried)

**DI-013** — Comment-gate workflow friction: `jr issue comment` is unconditionally denied by the require-review hook. Consumer skills (investigate-event, orchestration) cannot complete their comment steps without human permission-override.

- **Target:** first Feature Mode cycle that touches the comment workflow
- **Options (human to choose):** accept friction / implement marker mechanism / add dedicated non-blocked command
- **Flagged:** 0f-adv pass 6 (ADV-0-601); human-approved deferral at Phase 0 gate
- **Location:** project-context.md §8 and §11; validation-report.md `open_gate_decisions`

No other open drift items. No blocking issues.

---

## [SUPERSEDED] ENGINE FEEDBACK (not secops-factory work)

8 improvement proposals targeting the **vsdd-factory ENGINE** at `/Users/jmagady/Dev/dark-factory`. These are proposals for the engine maintainer — NOT secops-factory work items. Codified per S-7.02 cycle-closing requirement.

**Location:** `.factory/session-reviews/2026-07-19-brownfield-phase0-session-review.md`

| ID | Proposal | Source |
|----|----------|--------|
| IP-001 | Census-sync assertion at BC-extraction step — pipeline should assert all shards updated when census changes | process-gap from ADV-R pass 2 |
| IP-002 | Shard sync-status convention — annotate shards with sync-status headers when they diverge from a root document | process-gap-3 |
| IP-003 | BC input-hashes computed at extraction time, not as a post-hoc remediation pass | process-gap-5 |
| IP-004 | Adversary stale-snapshot protocol — adversary must declare snapshot trust level before grading; orchestrator must verify trust before accepting findings | process-gap-4 |
| IP-005 | Fan-out grep-before-consistency discipline — agent must run grep sweep before claiming consistency across a corpus | process-gap-6 |
| IP-006 | Substring-matching-idiom sweep — when any auth/enforcement hook is reviewed, all hooks using the same idiom are swept simultaneously | process-gap-7 |
| IP-007 | Anchor-churn class — pipeline convention: construct-name-first anchors are mandatory; line numbers permitted only as secondary locators | emergent from 11-pass anchor-churn resolution |
| IP-008 | HS expected-result verification gate — adversary or orchestrator must verify holdout scenario expected-results are not inverted before acceptance | lesson from HS-026 inverted expected-result caught by orchestrator |

---

## [SUPERSEDED] DECISION DELTA (this session)

| Decision | Rationale |
|----------|-----------|
| Phase-0-only depth; park awaiting feature-request | Internal dev-tooling plugin; no active feature scope at onboarding time |
| market-intelligence SKIPPED | Internal plugin — no external market |
| design-system-extraction SKIPPED | No UI surfaces |
| Approved fixing all drift items except DI-013 | DI-013 requires design decision on comment workflow; other items all had clear fixes |
| Ran full post-gate drift remediation (PRs #16+#17) before parking | Ensures Phase 0 artifact set is complete and accurate for first Feature Mode entry |
| Ran 4-pass delta adversarial review post-remediation | Ensures spec artifacts are consistent after code changes |
| session-review before parking | Captures engine improvement proposals while context is fresh |

---

## [SUPERSEDED] WORKTREE INVENTORY

| Worktree | Branch | Path | Status |
|----------|--------|------|--------|
| main | main | `/Users/jmagady/Dev/secops-factory` | active, clean |
| .factory | factory-artifacts | `/Users/jmagady/Dev/secops-factory/.factory` | active, clean |

No stale or removable worktrees.

---

## [SUPERSEDED] RESUMPTION GUIDE

**If resuming to handle a feature request:**
1. Orchestrator reads STATE.md → detects `phase: 0-complete`, `pipeline: phase-0-COMPLETE`
2. Routes to **Feature Mode** (vsdd-factory:phase-f1-delta-analysis through phase-f7)
3. Loads `project-context.md v2.3` as the scoping document
4. Phase 0 is NOT re-run
5. First step: delta analysis against the incoming feature spec
6. Before touching comment workflow: resolve DI-013 (see PENDING above)

**If resuming to maintain the engine:**
- Engine IPs: see `.factory/session-reviews/2026-07-19-brownfield-phase0-session-review.md`
- Engine location: `/Users/jmagady/Dev/dark-factory`

**Key artifact locations:**
- Scope doc: `.factory/phase-0-ingestion/project-context.md` (v2.3)
- BCs: `.factory/phase-0-ingestion/behavioral-contracts/` (17 files)
- Holdouts: `.factory/holdout-scenarios/` (34 scenarios)
- Criticality: `.factory/specs/module-criticality.md` (v1.6)
- Conventions: `.factory/phase-0-ingestion/conventions.md`
- VGA: `.factory/phase-0-ingestion/verification-gap-analysis.md`

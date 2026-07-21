---
document_type: session-handoff
level: ops
version: "2.1"
status: current
producer: state-manager
timestamp: 2026-07-21T10:00:00Z
project: secops-factory
supersedes: "2.0 (2026-07-21T00:00:00Z)"
---

# SESSION-HANDOFF: secops-factory

### RESUME IN ONE BREATH

secops-factory prism-integration v0.10.0 feature cycle is mid-Phase-F2 (spec evolution). F1 approved+committed. The full F2 spec body (11 BCs + delta docs) is FROZEN and committed. Adversarial pass 5 is COMPLETE (1C/2M/1m/3obs — report persisted at phase-f2-spec-evolution/adversarial-spec-delta-review-pass5.md). Root cause: the deterministic disposition-guard hook trusts the LLM-supplied ticket_action_type completely and never cross-checks it against hard_floor_applies(), which it can compute — P5-001 (silent discard, CRITICAL) and P5-002 (kill-switch bypass, MAJOR) are the under/over-label duals of this single gap; P5-003 (MAJOR) is a stale §D-DEC-001 authoritative schema block. Clean streak remains 0/3. Consistency pass-5 audit was NOT on disk at wrap addendum. NEXT ACTION: REMEDIATE pass-5 findings — dispatch architect to fix the deterministic disposition-guard so it cross-checks LLM ticket_action_type against hard_floor_applies() (P5-001: in STEP 5 when hard_floor_applies() OR Indeterminate AND action not review-type, upgrade to review marker or write error artifact and deny; P5-002: gate STEP 3 review-exemption on hard_floor_applies(verdict) OR disposition==Indeterminate, reconcile kill-switch vs brief §3.9 draft-only language; P5-003: update §D-DEC-001 authoritative block to D-DEC-012 superset including create-review/comment-review tokens, Indeterminate verdict, ticket_action_type sub-field). Then PO propagate fixes to BC-3.03.001/BC-10.01.001. FV re-scope VP-HOOK-029 to inject hard-floor verdicts with NON-review ticket_action_type and assert (review-marker XOR error), making SM-32 killable. Minor: fix prd-delta §4/§6 "12-field" stale count to 12/15 split. Then adversarial pass 6. Decide whether to re-run consistency pass-5 before or after remediation.

---

## HEADS

| Ref | SHA | Remote | Notes |
|-----|-----|--------|-------|
| main | d181ca2 | origin/main (in sync) | only untracked .claude/ local tooling |
| factory-artifacts | see `git -C .factory log -1 --format='%h %s'` | origin/factory-artifacts (PUSHED) | this wrap commit |

---

## FROZEN F2 ARTIFACT VERSIONS (ground truth for resumed review/remediation)

**BCs (phase-0-ingestion/behavioral-contracts/):**

| BC ID | Version | Subject |
|-------|---------|---------|
| BC-3.01.001 | v1.17 | require-review — marker consumer |
| BC-3.03.001 | v1.13 | disposition-guard — marker emitter |
| BC-4.02.001 | v1.8 | update-jira |
| BC-4.05.001 | v1.3 | assess-priority |
| BC-5.01.001 | v1.8 | investigate-event |
| BC-6.01.001 | v1.5 | activate |
| BC-10.01.001 | v1.9 | monitoring-loop |
| BC-6.01.003 | v1.1 | onboard-customer (NEW) |
| BC-6.01.004 | v1.1 | onboard-sensor (NEW) |
| BC-8.02.001 | v1.1 | sensor-metrics (NEW) |
| BC-9.01.001 | v1.1 | scan-threats (NEW) |

**Delta docs (phase-f2-spec-evolution/):**

| File | Version |
|------|---------|
| architecture-delta.md | v1.7 |
| verification-delta.md | v1.7 |
| prd-delta.md | v1.8 |
| dtu-assessment.md | DTU_REQUIRED: true — prism L3 via prism demo server, jr L2 mock |
| asm-004-validation.md | PARTIAL → resolved-by-design (--strict-mcp-config --mcp-config prism.mcp.json) |
| adversarial-spec-delta-review-pass1..4.md | all remediated |
| spec-changelog.md | spec 1.0.0 → 1.1.0 MINOR |

**VP namespace:** VP-SKILL 001-072, VP-HOOK 024-029. Mutation vectors SM-9..SM-35. Decisions D-DEC-001..012.

---

## KEY DESIGN STATE

- **Marker mechanism (DI-013 resolution, D-005):** filesystem markers at `${CLAUDE_PLUGIN_DATA}/markers/`, canonical schema v2.0 (absolute `expires_at_utc` 120s TTL, `authorized_operations` tokens, iterative-consume oldest-first, `markers/audit.log` control-char-stripped). `command_pattern`: ticket-bound for comment/assign; anchored project-bound for create (`^jr (--output json )?issue create --project <key>( |$)`, NO unbounded `.*`). disposition-guard is the ONLY emitter; require-review the consumer. Document-before-action ordering (Stage 7 DOCUMENT emits marker → Stage 8 TICKET ACTION consumes). JSON-first disposition-guard dispatch (verdict JSON → 15-field path even at `investigations/verdict-*.json`). `validate_enums()` fail-closed. 15-field ICD-203 verdict schema + operational metadata (`jira_project_key`, `confidence_score`, `autonomy_enabled`). Hard floors deterministic on `verdict.severity`/`asset_type`/`attack_techniques`; `asset_type=unknown` is a hard floor. D-DEC-012: `create-review`/`comment-review` RESTRICTED markers surface BLIND-SPOT/Indeterminate to Jira, EXEMPT from hard-floor + kill-switch (fail-loud, VP-HOOK-029). Sensor-silence condition: `last_seen_ts < now()-24h`.

---

## PENDING / CARRIED

- Pass-5 remediation IN PROGRESS: architect fix disposition-guard (P5-001/002/003), PO propagate to BCs, FV re-scope VP-HOOK-029 + SM-32, minor prd-delta §4/§6 count fix. Then adversarial pass 6.
- F2 consistency audit pass-5 COMPLETE (PASS-WITH-MINORS, 0 blocking) — committed in wrap addendum 2. All prior-pass Critical/Major resolved; marker+verdict schemas uniform; VP namespace clean; sensor-silence direction correct. CONSISTENCY dimension is CLEAN. Only thing gating F2 gate is adversarial pass-5 1C/2M remediation (then pass 6, 7 to reach 3 clean passes).
- **Pass-5 consistency minor punch-list (resolve before F2 state-backup):**
  - F-003: VP-SKILL-061 in BC-10.01.001 describes sensor-silence as "last_seen_ts > 24h" — visually echoes pre-P4-003 wrong operator; fold fix (reword as "last_seen_ts age > 24 h") into pass-5 PO propagation burst together with BC-3.03.001/BC-10.01.001 updates.
  - F-001: arch-delta §5.4 historical quote "as of v1.15 live" shows pre-fix audit path label — audit-trail only, section already RESOLVED; cosmetic label update (low priority, will not block F2 gate).
  - F-002: 6 established BCs carry bare "COMPUTE-AT-COMMIT" input-hash vs 5 newer BCs' instrumented form — compute the 6 bare hashes at the F2 state-backup commit; does not block adversarial passes.
- DI-013 now RESOLVED in-spec via marker mechanism (was deferred at Phase 0).
- Human decisions this cycle: D-004 full-brief scope, D-005 marker mechanism, D-006 demo-unaware; `asset_type=unknown` floor [human-gate-confirm at F2 gate]; confidence enum thresholds 0.75/0.40 (D-DEC-011); P5-002 kill-switch-vs-brief-§3.9 reconciliation [human-gate-confirm if amending brief].
- AFTER 3 clean passes: F2 state-backup (compute F-002 bare hashes here), then F2 human gate, then F3 story decomposition.
- BCs carry COMPUTE-AT-COMMIT input-hash placeholders where inputs changed — compute at F2 state-backup (F-002).

## DECISION / LESSONS DELTA (pass-5 addendum)

| Item | Detail |
|------|--------|
| Root-cause one-liner | Deterministic disposition-guard hook trusts LLM-supplied ticket_action_type without cross-checking hard_floor_applies(); every LLM-supplied routing field that grants or bypasses a security control must be cross-validated against a hook-computed invariant (O3 standing rule). |
| P5-001 lesson | Fail-loud guarantees must be enforced at the deterministic (hook) layer, not rely on correct LLM behavior for the exact threat class the marker design defends against. |
| P5-002 lesson | Kill-switch exemptions gated on LLM-supplied tokens (create-review/comment-review) without a deterministic precondition create a bypass for the autonomy_enabled=false circuit-breaker — always gate exemptions on a hook-computed invariant, not on the token alone. |
| P5-003 lesson | A "single authoritative" schema block marked "fix the BC, not this document" that is stale w.r.t. later sections of the same document is actively dangerous — authoring discipline must keep the authoritative block in sync at every schema extension. |

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

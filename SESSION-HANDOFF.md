---
document_type: session-handoff
level: ops
version: "2.4"
status: current
producer: state-manager
timestamp: 2026-09-05T00:00:00Z
project: secops-factory
supersedes: "2.3 (2026-09-04T00:00:00Z)"
---

# SESSION-HANDOFF: secops-factory

### RESUME IN ONE BREATH

secops-factory cycle v0.10.0-feature-prism-integration is in PHASE F4 (delta implementation), Wave 1 ready to start. F3 story adversarial convergence COMPLETE (3/3 clean: passes 27/28/29; 29 total). F3 gate APPROVED by human 2026-09-05 (D-036); F4 authorized (D-037 merge policy). NEXT ACTION: start F4 Wave-1 per-story TDD delivery for S-3.01, S-4.02, S-6.03 (worktrees already created). NOTE: verify-sha-currency not run (known); STATE.md at 194 lines — consider /compact-state early next session.

---

## HEADS

| Ref | SHA | Remote | Notes |
|-----|-----|--------|-------|
| main | 5ea00d0a | origin/main (in sync) | PR #20 test-harness subdirs merged; primary checkout restored to main |
| factory-artifacts | 94a544f | origin/factory-artifacts (in sync) | D-037/D-038 policy + Lesson 64 |

---

## MERGE POLICY (D-037 — IN FORCE for all F4 story PRs)

Every F4 story PR: (1) INDEPENDENT pr-reviewer (fresh-eyes; pr-manager MUST NOT self-approve) + security-reviewer, (2) all 4 CI checks green (BATS Tests, Plugin Structure Validation, Shellcheck Hooks, Semgrep Scan), (3) PAUSE for explicit HUMAN merge approval. NO autonomous merges to main.

D-038: PR #20 was accepted as-is despite a self-approve+auto-merge process deviation flagged by the security guard — corrected by D-037.

---

## STORY SET (frozen, committed 4d82ec7)

13 stories / 88 points / 5 waves; 62 holdout scenarios (34 baseline + 28 F3-delta).

| Wave | Stories | Status |
|------|---------|--------|
| W1 | S-3.01 (require-review link+close anti-fungibility, hook), S-4.02 (assess-priority scored_priority coherence, skill), S-6.03 (activate CLOSE_STATE_ALLOWLIST, skill) | **NEXT — all independent, parallel** |
| W2 | S-3.02 (disposition-guard delta), S-6.01 (onboard-customer), S-8.01 (sensor-metrics), S-9.01 (scan-threats) | pending W1 gate |
| W3 | S-4.01 (update-jira compound create+link), S-5.01 (investigate-event), S-6.02 (onboard-sensor) | pending W2 gate |
| W4 | S-10.01 (monitoring-loop core) | blocked pre-W4 on ASM-015+ASM-009 |
| W5 | S-10.02 (monitoring-loop watermark), S-11.01 (demo-seed — DRAFT/BLOCKED per D-006/D-035; NOT dispatchable until PO promotion) | pending W4 gate + PO |

**File locations:**
- Story files: `.factory/phase-f3-stories/*.md`
- Dependency matrix: `.factory/phase-f3-stories/dependency-graph-extended.md`
- Story index: `.factory/stories/STORY-INDEX.md`
- Sprint state: `.factory/stories/sprint-state.yaml`
- Wave schedule: `.factory/feature/wave-schedule.md`
- Holdout scenarios: `.factory/holdout-scenarios/`

---

## WORKTREES (KEPT — reuse on resume)

| Worktree | Branch | Path | Status |
|----------|--------|------|--------|
| main | main | `/Users/jmagady/Dev/secops-factory` | active; clean |
| .factory | factory-artifacts | `/Users/jmagady/Dev/secops-factory/.factory` | active |
| S-3.01 | feature/S-3.01 | `.worktrees/S-3.01` | scaffold off main 5ea00d0a; clean |
| S-4.02 | feature/S-4.02 | `.worktrees/S-4.02` | scaffold off main 5ea00d0a; clean |
| S-6.03 | feature/S-6.03 | `.worktrees/S-6.03` | scaffold off main 5ea00d0a; clean |

All three W1 worktrees carry `tests/hooks/` + `tests/skills/` subdir layout from PR #20. `.worktrees/` is gitignored.

---

## F4 PRE-FLIGHT RESULTS (W1 verified clean)

- **Toolchain:** PASS — BATS 1.13, jq, bash 5.3, shellcheck present. pwsh/PSScriptAnalyzer CI-only; parity tests skip locally. No security blocker.
- **CI/CD:** PASS — Target branch = main (NO develop branch). Branch protection: strict, 4 required checks (BATS Tests / Plugin Structure Validation / Shellcheck Hooks / Semgrep Scan), 0 required approvals, enforce_admins false. ci.yml + security.yml present. gh auth works.
- **Test harness:** `tests/run-all.sh` recursively discovers `tests/hooks/*.bats` + `tests/skills/*.bats` (nullglob-safe).
- **DTU:** NOT a W1 blocker. dtu_required: true (prism-demo-server + jr-mock; dtu_clones_built: pending). Prism repo: `/Users/jmagady/Dev/prism`.

---

## OPEN BLOCKERS (carry forward)

| ID | Issue | Blocking |
|----|-------|---------|
| ASM-015 | Pre-Wave-4 BATS validation gate: permissionDecision:deny must populate `.permission_denials[]` in --allowedTools JSON envelope (unvalidated). Per-hook unit tests seed markers directly; W1–3 proceed. | pre-W4 (S-10.01 dispatch) |
| ASM-009 | Pre-Wave-4 BATS validation gate: cross-hook marker filesystem visibility — disposition-guard emits and require-review consumes from `${CLAUDE_PLUGIN_DATA}/markers/`. If shared-fs assumption fails, marker mechanism (D-DEC-001/D-012) needs redesign. | pre-W4 (S-10.01 dispatch) |
| prism-dtu-demo-server | CI download mechanism does not exist yet. Needed pre-W2 and for S-4.02 VP-SKILL-070 multi-org behavioral test. → SKIP/XFAIL VP-SKILL-070 test in S-4.02 until prism-demo-bundle release-asset download is wired into CI. | pre-W2 (xfail for S-4.02) |
| jr L2 stateful mock | Must exist before W3 (S-4.01 compound-link tests). Built during W4 monitoring-loop stories. | pre-W3 |

### Accepted/Deferred Residuals

| ID | Status |
|----|--------|
| DI-019..DI-023 | Process gaps (matrix per-mutant completeness lint, SM→VP flat table, BC-9.01.001 stale VP table, cross-BC referenced-not-owned trace, holdout-template category heading). Deferred rc.25+. |
| DI-018 | verification-delta.md FUEL_EXHAUSTED (~840KB). ACCEPT-DEFER rc.25+. fail-open confirmed (D-032). |
| MIG-001 Parts B+C | Accepted. Deny-hook non-enforcing (graceful-degrade allow). Full relocation infeasible (121 unmapped files). |
| ASM-008-DEFERRED | LLM-supplied field cross-validation (native_severity, asset_type, scored_priority) deferred to prism-side. |
| ASM-014 | comment-review --label binding deferred pending empirical validation. |

---

## KEY DECISIONS (current cycle — carry forward)

| ID | Decision | Status |
|----|----------|--------|
| D-036 | F3 gate APPROVED by human 2026-09-05. F3 convergence 3/3 CLEAN (passes 27/28/29). F4 authorized. ASM-015+ASM-009 block W4 only; W1-3 proceed. | LOCKED |
| D-037 | F4 merge policy: INDEPENDENT pr-reviewer + security-reviewer; all 4 CI checks green; PAUSE for HUMAN merge approval. NO autonomous merges to main. | IN FORCE |
| D-038 | PR #20 accepted despite self-approve+auto-merge deviation (flagged by security guard). D-037 corrects for all subsequent F4 PRs. | CLOSED |
| D-035 | STORY-DEMO-SEED-001 (S-11.01) = demo-seed; scripts/demo/ operator tooling; status draft/BLOCKED pending PO promotion. | OPEN/HELD |
| D-034 | "Merge Prism" = runtime MCP service + prism-dtu-demo-server DTU (NOT code merge). Prism repo `/Users/jmagady/Dev/prism` (rc.22/23). | LOCKED |
| D-033 | V1 scope: Claroty-xDome-only; runtime-scope; 4-sensor spec retained. | LOCKED |

Earlier decisions (D-DEC-001..D-032) locked in prior sessions; see `cycles/` files.

---

## NEXT-ACTION DETAIL (F4 Wave-1 — the resume entry point)

For each Wave-1 story (S-3.01, S-4.02, S-6.03), run the FULL per-story-delivery cycle in its worktree. No steps skipped:

1. **stub-architect** → compilable stubs; Red Gate (BC-5.38.001)
2. **test-writer** → failing BATS tests traced to story BCs/ACs/VPs + mutant-kill vectors (per story's verification_properties + dependency-graph-extended VP-to-Stories matrix)
3. **implementer** → minimum code to green; micro-commits
4. **Per-story adversarial convergence** (Step 4.5) — 3 clean passes minimum before demo recording
5. **demo-recorder** → per-AC demo evidence
6. **Push** branch
7. **pr-manager** → PR to main + INDEPENDENT pr-reviewer + security-reviewer + wait for 4 CI checks green → PAUSE for HUMAN merge approval (D-037) → on approval merge → worktree cleanup

**S-4.02 caveat:** xfail VP-SKILL-070 multi-org DTU test pending prism-demo-bundle download.

After all 3 W1 stories merge: Wave-1 integration gate (full suite on main + wave adversarial + holdout eval for W1-covered scenarios).

---

<!-- ═══════════════════════════════════════════════════════════ -->
<!-- SUPERSEDED SNAPSHOT (v2.3 — 2026-09-04T00:00:00Z)         -->
<!-- ═══════════════════════════════════════════════════════════ -->

---

## [SUPERSEDED] Prior RESUME IN ONE BREATH (v2.3 — 2026-09-04)

F2 adversarial spec convergence COMPLETE (3/3 clean, passes 44/45/46; 46 total). F2 gate APPROVED by human 2026-09-04. OBS-GC-001/002 FIXED this wrap (BC-10.01.001 updated). STORY-DEMO-SEED-001 placeholder stub created. NEXT: execute (scoping-shrunken) MIG-001 — PART A only (fix .claude/settings.json enabledPlugins vsdd-factory@vsdd-factory → vsdd-factory@claude-mp). PARTS B+C → ACCEPT. Then F3 story decomposition (Wave 7 monitoring-loop): decompose 5 new BCs + 6 modified BCs; finalize story-naming; compute 6 COMPUTE-AT-COMMIT input-hashes. NOTE: .factory/hooks/ not instantiated; verify-sha-currency.sh not run (known throughout this cycle).

---

## [SUPERSEDED] HEADS (v2.3)

| Ref | SHA | Notes |
|-----|-----|-------|
| main | e8bf19f | PRs #18+#19 MERGED (cross-platform packaging) |
| factory-artifacts | see `git -C .factory log -1 --format='%h %s'` | v2.3 wrap commit |

---

<!-- ═══════════════════════════════════════════════════════════ -->
<!-- SUPERSEDED SNAPSHOT (v2.2 — 2026-09-03T23:00:00Z)         -->
<!-- ═══════════════════════════════════════════════════════════ -->

---

## [SUPERSEDED] Prior RESUME IN ONE BREATH (v2.2 — 2026-09-03)

secops-factory prism-integration v0.10.0 feature cycle is mid-Phase-F2 (spec evolution). F1 approved+committed. Full F2 spec body (11 BCs + delta docs) FROZEN. Pass-19 remediation COMPLETE (burst 16 — D-023 close disposition gate + D-024 rule-2 create+link + orphan-link reconciliation SM-68/VP-HOOK-036 extended [ID-sync per FV]). VPs 41 / SM 61 (SM-9..SM-68, SM-32=32a+32b+32-ext, SM-55 skipped). Artifact versions: arch-delta v1.21, verif-delta v1.21, prd-delta v1.19, BC-3.03.001 v1.28, BC-3.01.001 v1.23, BC-10.01.001 v1.22, BC-4.02.001 v1.14, BC-6.01.001 v1.8, others unchanged. D-DEC-001..D-024 locked. O3 standing rule: LLM-supplied routing fields granting state-change controls MUST be cross-validated against hook-computed invariants. Clean streak 0/3. NEXT ACTION: adversarial pass 20.

---

## [SUPERSEDED] HEADS (v2.2)

| Ref | SHA | Notes |
|-----|-----|-------|
| main | d181ca2 | only untracked .claude/ local tooling |
| factory-artifacts | see `git -C .factory log -1 --format='%h %s'` | v2.2 wrap commit |

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

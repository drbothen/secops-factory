# Verification Gap Analysis: secops-factory

> Analyzed by Dark Factory Phase 0e (Verification Gap Analysis)
> Agent: formal-verifier (T3)
> Source codebase: `/Users/jmagady/Dev/secops-factory`
> Date: 2026-07-19 (original) · **re-synced post PR #12/#13/#14 (pass 1)** · **updated post pass 3** · **re-issued post-PR-15 (d304fa5), 2026-07-19 (pass 9)**
> **Reconciliation note (ADV-0-003):** The original analysis reflected the pre-remediation baseline. Between authoring and adversarial pass 1, PR #12 (gitignore secrets), PR #13 (SEC-001/002 fail-closed + `jr issue comment` gated), and PR #14 (read-only allowlist expansion) merged. This revision re-verifies every affected finding against the current code/tests and marks resolved items with evidence. Findings not affected by those PRs (notably the disposition-guard false-pass) remain open and are re-confirmed live.
> **Pass-3 update (ADV-0-302):** Aligned the mutation-testable set with the authoritative module-criticality decision — **six** hooks are mutation-testable (the 5 pure hooks + session-greeting's pure activation-gate sub-function, which carries a ≥70% numeric target even though the hook is effectful overall). Corrected all "5 pure hooks" framings, added session-greeting mutation vectors (SM-8 killed, SM-8b surviving), and confirmed the ~75–80% aggregate kill-rate as the authoritative current figure (adding session-greeting does not materially change it). **Note: SM-8 (session-greeting activation-gate) is UNRELATED to the require-review PRs (#13/#14/#15) — it is killed by pre-existing session-greeting tests and was never touched by any of those security fixes.**
> **Pass-9 re-issue (ADV-0-903, post-PR-15 / d304fa5):** PR #15 fixed a **CRITICAL allowlist-precedence bypass (SEC-009 / ADV-0-801)**: pre-PR-15 the read-only allowlist was evaluated *before* the write-block, so any write command carrying an allowlist token in its arguments (e.g. `jr issue edit KEY --summary "see jr board"`) matched `jr board` and returned **allow** — the review gate was **fully bypassable**. PR #15 reorders evaluation so the write-block runs first, and adds 12 hook tests (ADV-0-801 bypass + regression). Test suite was **150 @tests** as of pass 9 (later 165 — see Pass-R2 note below). require-review source references now use **construct names, not line numbers**, because those anchors churned across PR #13/#14/#15 (and are now inverted).
> **Pass-R2 re-issue (ADV-R2-06, post-PR-16/17, 2026-07-19):** Test suite grew to **165 @tests** (hooks 44→59: +15 from PR #17 DI-004/005/007/014 heading-anchor + coverage tests; skills 81, integration 11, parity 14) — verified by `grep -c "^@test"`. BC set grew from 13 to **17** with Stream D's 4 new skill BCs (BC-4.05.001 assess-priority, BC-4.06.001 read-ticket, BC-7.01.001 create-advisory, BC-8.01.001 analyze-ticket-effort), all LLM-behavior skills → structural-only. Roll-up is now **Fully 2 / Partial 15 / Un-verified 0 (17 BCs)**. **PR #17 (DI-004/005/007/014) RESOLVED several previously-flagged gaps:** the disposition-guard (DI-004) and enrichment-completeness (DI-014) checks are now heading-anchored (SM-1 false-pass now **KILLED**, live-confirmed), the enrichment-completeness investigation branch is now tested (DI-007a), a hook↔template section-name sync guard was added (DI-007b), the handoff-validator 39/40 boundary is tested (DI-007c), and `jr issue assign`/`create` now have dedicated positive-deny tests (DI-005). PR #16 (DI-002/006/011) added CI `pwsh`+PSScriptAnalyzer assertions and a hooks.json schema check (addresses GAP-3/GAP-8).
> Scope note: This is a **declarative Claude Code plugin** (markdown + JSON + shell/PowerShell hooks + YAML templates). There is no compiled/interpreted production language, hence no conventional line/branch/function coverage, no Kani/CBMC target, and no cargo-mutants/mutmut/stryker target. This report re-frames every template section around the actual verification surface: **executable checks (BATS, CI validation, hook self-behavior) mapped to the 17 recovered behavioral contracts.**
> Security scanning is intentionally **excluded** here — it is owned by Step 0e-sec (DF-031). See the deferral note under "Security Posture".

---

## Executive Summary

| Dimension | Result |
|-----------|--------|
| Behavioral contracts assessed | 17 (BC-3.01.001 … BC-8.01.001; +4 Stream D BCs post-PR-16/17) |
| BCs **fully** verified (behavioral: all/near-all postconditions + core invariants have an executable check) | **2** — BC-3.03.001, BC-3.06.001 |
| BCs **partially** verified — behavioral (hook executes; some postconditions/edge cases untested) | **4** — BC-3.01.001, BC-3.02.001, BC-3.04.001, BC-3.05.001 |
| BCs verified **structural-only** (skill text/config/reference presence checked; behavioral enforcement of the Iron Law NOT executably verified) — counted under "partial" | **11** — BC-4.01.001, BC-4.02.001, BC-4.03.001, BC-4.04.001, BC-5.01.001, BC-6.01.001, BC-6.01.002, **BC-4.05.001, BC-4.06.001, BC-7.01.001, BC-8.01.001** (last 4 new, Stream D) |
| BCs **un-verified** (no check of any kind) | **0** |
| **Three-bucket roll-up** | **Fully 2 / Partially 15 / Un-verified 0** (17 BCs). Bucket logic: 2 fully (hooks BC-3.03.001, BC-3.06.001) + partially = 4 behavioral-partial hooks (BC-3.01/3.02/3.04/3.05) + 11 structural-only skills = 15 partial; 0 un-verified. |
| Total automated tests | **165** BATS `@test` cases (hooks 59, skills 81, integration 11, parity 14) — all pass locally. (hooks 44→59: +15 from PR #17 DI-004/005/007/014 heading-anchor + investigation-branch + boundary + assign/create tests.) |
| Tests that silently skip without `pwsh` (PowerShell parity) | **0** — PR #16 (DI-006/011) added a CI step asserting `pwsh` + PSScriptAnalyzer, so the 12 behavioral-parity tests no longer silently skip in CI (they still skip on a local machine without `pwsh`) |
| Highest-value confirmed defect | **RESOLVED (PR #17, DI-004)** — the disposition-guard false-pass (anti-confirmation-bias gate) is fixed: the check is now heading-anchored (`grep -qiE "^#{1,6}...Alternatives Considered"`). Live-confirmed 2026-07-19: negating text ("No Alternatives Considered because obvious") now returns **deny**; a genuine `## Alternatives Considered` heading returns allow. No open HIGH defect remains. |
| Resolved since original (verified) | **disposition-guard false-pass (SM-1)** → heading-anchored (PR #17, DI-004); **enrichment-completeness false-pass (SM-4/DI-014)** → heading-anchored + investigation branch tested (PR #17, DI-007a); **hook↔template section-name sync** → guarded (PR #17, DI-007b); **handoff-validator 39/40 boundary** → tested (PR #17, DI-007c); **assign/create positive-deny** → tested (PR #17, DI-005); **SEC-009/ADV-0-801 precedence bypass** (CRITICAL) → fixed (PR #15); **SM-3 fail-open** → fail-closed (PR #13); **DI-001 secrets** → gitignored (PR #12); **CI pwsh/PSScriptAnalyzer** → asserted (PR #16) |

**The verification asymmetry is the headline finding.** The six **hooks** (deterministic shell) are directly executable and are genuinely behaviorally tested. The seven **skills** (LLM-executed markdown) are verified *structurally only*: BATS proves the Iron Law text, "Announce at Start", Red-Flag row counts, `${CLAUDE_PLUGIN_ROOT}` reference portability, referenced-file existence, and agent frontmatter/tool constraints are present — but **no executable check confirms the skills actually enforce their preconditions/postconditions/invariants at runtime**, because that enforcement is LLM behavior. The structural gate is real and valuable (it catches deletions and drift), but it must not be mistaken for behavioral verification of the Iron Laws.

---

## Verification Coverage Baseline (per Behavioral Contract)

> Substitute for "Test Coverage Baseline" — there is no line-coverage tool for markdown/JSON/bash-as-config. The meaningful baseline is per-BC contract-element coverage.

### Overall Metrics

| Metric | Value | Tool |
|--------|-------|------|
| Line/branch/function coverage | **not measurable / not meaningful** | no coverage tool applies to declarative plugin (no `package.json`/`Cargo.toml`) |
| Total automated tests | 165 `@test` cases | bats-core 1.13.0 |
| Test suites | 4 (`hooks.bats` 59, `skills.bats` 81, `integration.bats` 11, `parity.bats` 14) | bats-core |
| Test execution (local, ex-parity-skips) | ~seconds; all green | `tests/run-all.sh` |
| Static soundness of `.sh` hooks | shellcheck **CLEAN** (0 findings) | shellcheck |
| Static soundness of `.ps1` hooks | **only if `pwsh` present** (parse-only; no PSScriptAnalyzer) | `run-all.sh` conditional block |
| JSON manifest validity | `plugin.json`, `hooks.json`, `hooks.json.windows` validated | `jq` (CI structure job) |
| YAML template validity | 5 templates validated | `python3 -c "import yaml"` |

### Per-Contract Coverage Matrix

| BC | Component | Layer | Executable checks | Contract-element coverage | Verdict |
|----|-----------|-------|-------------------|---------------------------|---------|
| BC-3.01.001 | require-review hook | hook (pure) | hooks.bats ×26, integration ×2, parity ×3 | **[post-PR-15]** non-jr allow ✓; read-only allowlist broadly tested (view, changelog plain+json, `--output json` view/list/comments, assets search/view, `--version`) ✓; `jr issue comment` now **deny** ✓ (SEC-001); `edit`/`move` deny ✓; **fail-CLOSED** on unknown-jr subcommand deny ✓ (SEC-002); **SEC-009 / ADV-0-801 precedence-bypass now tested** ✓ — write commands with an allowlist token in args (edit+`jr board`, comment+`jr me`, create+`jr sprint`, move+`jr project`) all deny, plus regression tests that genuine reads still allow; **`assign`/`create` now have dedicated positive-deny tests** ✓ (PR #17, DI-005); jq-missing exit-1 untested; malformed-JSON untested | **PARTIAL** (materially improved) |
| BC-3.02.001 | enrichment-completeness hook | hook (pure) | hooks.bats ×3, integration ×3, parity ×2 | non-matching allow ✓; enrichment 5-section deny ✓ (missing-name-in-reason not asserted); complete allow ✓; **investigation 4-section branch entirely untested**; case-sensitivity untested; both-pattern precedence untested; jq-missing untested | **PARTIAL** |
| BC-3.03.001 | disposition-guard hook | hook (pure) | hooks.bats ×4, integration ×2, parity ×2 | non-investigation allow ✓; in-progress (no Disposition) allow ✓; Disposition+no-Alternatives deny ✓; Disposition+Alternatives allow ✓ — all 3 declared VPs + 3-state core exercised. Gaps: case-insensitive lowercase untested; **substring false-pass untested (confirmed defect, below)** | **FULLY** (core); false-pass edge open |
| BC-3.04.001 | bias-check-reminder hook | hook (pure) | hooks.bats ×3, parity ×1 | exit-0 ✓; Confirmation ✓; Anchoring ✓; **Availability + Automation biases not asserted**; **reference-path not asserted** | **PARTIAL** |
| BC-3.05.001 | handoff-validator hook | hook (pure) | hooks.bats ×3, integration ×2 | empty→EMPTY ✓; short→"suspiciously short" ✓ (char-count not asserted); 40+→silent ✓; **boundary 39/40 untested**; **missing `result` field untested**; jq-missing untested | **PARTIAL** |
| BC-3.06.001 | session-greeting hook | effectful (fs read) | hooks.bats ×5, parity ×2 | absent→silent ✓; non-secops→silent ✓; activated→greeting (Morgan/SessionStart/additionalContext) ✓; valid-JSON ✓; corrupt→fail-open ✓ — all 7 postconditions covered. Gaps: **jq-unavailable fallback path untested**; cwd-missing fallback untested | **FULLY** (core); jq-fallback open |
| BC-4.01.001 | enrich-ticket skill | skill (LLM) | skills.bats (Iron Law, Announce, Red-Flags≥6, `${CLAUDE_PLUGIN_ROOT}` refs, file existence) | Structural presence ✓✓✓. **8-stage sequencing, EPSS-mandatory, multi-factor priority, halt-on-failure — all behavioral, unverified** | **STRUCTURAL-ONLY** |
| BC-4.02.001 | update-jira skill | skill (LLM) | skills.bats (Iron Law text present) | Iron Law text ✓. **VP-SKILL-007 (CVSS range validation) and VP-SKILL-008 (review-approval precedes edit) are labelled "integration/manual" = NOT automated**. Skill-layer review gate + field validation unverified (hook BC-3.01 provides an independent infra gate that IS tested) | **STRUCTURAL-ONLY** |
| BC-4.03.001 | review-enrichment skill | skill (LLM) | skills.bats (Iron Law, opus model, reviewer-excludes-Write, checklists exist) | Iron Law ✓; **agent config invariants genuinely checked** (opus ✓, no-Write ✓, checklists exist ✓). Scoring formulas, fresh-context, mandatory-bias — behavioral, unverified | **STRUCTURAL-ONLY** (strongest of the skills) |
| BC-4.04.001 | adversarial-review-secops skill | skill (LLM) | skills.bats (Iron Law, Honest Convergence + "fewer than 3 substantive", Hallucination Classes, `=== FILE:` delivery, Canonical Source pointer) | 5 structural VPs ✓. Convergence loop, quality thresholds (≥7.0, no dim <5.0), min-2-passes — behavioral, unverified; **SECOPS-P1 numbering unenforced** | **STRUCTURAL-ONLY** |
| BC-5.01.001 | investigate-event skill | skill (LLM) | skills.bats (Iron Law, Perplexity-fallback present, `${CLAUDE_PLUGIN_ROOT}` refs) | Structural ✓. 7-stage flow, save-local-first, TP/FP/BTP logic — behavioral, unverified (disposition-guard hook BC-3.03 provides the only executable enforcement, on Alternatives presence) | **STRUCTURAL-ONLY** |
| BC-6.01.001 | activate skill | skill (LLM) | skills.bats (settings.local.json target, agent value, disable-model-invocation, Announce, Red-Flags≥6) | 5 structural VPs ✓. **JSON merge / preserve-existing-keys / never-clobber-corrupt / Windows hooks.json copy / jq read-back — all behavioral and error-prone, none executed by any test** | **STRUCTURAL-ONLY** (high-value gap) |
| BC-6.01.002 | deactivate skill | skill (LLM) | skills.bats (`del(.agent)` present, guards non-secops, Red-Flags≥6) | Structural ✓. Actual key-deletion + preserve-others + empty-object handling not executed | **STRUCTURAL-ONLY** |
| BC-4.05.001 | assess-priority skill *(new, Stream D)* | skill (LLM) | skills.bats (Iron Law "NO PRIORITY ASSIGNMENT WITHOUT MULTI-FACTOR ASSESSMENT FIRST", Announce, Red-Flags≥6, `${CLAUDE_PLUGIN_ROOT}`/data refs) | Structural presence ✓. **6-factor priority calculation (EPSS+CVSS+KEV+asset+exposure+business weighting) is LLM behavior — unverified**; the arithmetic is a pure sub-function extractable for testing | **STRUCTURAL-ONLY** |
| BC-4.06.001 | read-ticket skill *(new, Stream D)* | skill (LLM) | skills.bats (structural presence; SEC-001 prompt-injection guidance) | Structural presence ✓. **Jira read + prompt-injection handling at the ticket-content entry point is LLM behavior — unverified** (the require-review hook independently gates any resulting write) | **STRUCTURAL-ONLY** |
| BC-7.01.001 | create-advisory skill *(new, Stream D)* | skill (LLM) | skills.bats (Iron Law "NO ADVISORY PUBLICATION WITHOUT SOURCE VERIFICATION FIRST", Announce, Red-Flags≥6, Source Verification Gate, `--template`, interactive type choice, advisory template + advisory-writer agent exist) | Structural presence ✓ (this skill has the richest structural coverage of the four). **Source-verification enforcement + advisory authoring is LLM behavior — unverified** | **STRUCTURAL-ONLY** |
| BC-8.01.001 | analyze-ticket-effort skill *(new, Stream D)* | skill (LLM) | skills.bats (Iron Law "NO EFFORT REPORT WITHOUT STATED BIASES FIRST", Announce, Red-Flags≥6, canonical method-doc ref, session-reconstruction anchors, no-client-data guard) | Structural presence ✓. **Session-reconstruction effort estimation is LLM behavior — unverified**; the gap/overhead constants (`GAP = 30*60`, `OVERHEAD_MIN = 5`) are asserted present in the method doc | **STRUCTURAL-ONLY** |

---

## Purity Assessment

### Module Classification

| Component | Path | Classification | I/O | Refactoring for verification |
|-----------|------|---------------|-----|------------------------------|
| require-review | `hooks/require-review.sh` (+`.ps1`) | **pure core** | stdin→stdout | none — deterministic string router |
| enrichment-completeness | `hooks/enrichment-completeness.sh` (+`.ps1`) | **pure core** | stdin→stdout | none |
| disposition-guard | `hooks/disposition-guard.sh` (+`.ps1`) | **pure core** | stdin→stdout | none |
| bias-check-reminder | `hooks/bias-check-reminder.sh` (+`.ps1`) | **pure core** | stdin→stderr | none |
| handoff-validator | `hooks/handoff-validator.sh` (+`.ps1`) | **pure core** | stdin→stderr | none |
| session-greeting | `hooks/session-greeting.sh` (+`.ps1`) | **effectful shell** | stdin + reads `settings.local.json` → stdout | gate/compare logic is a pure sub-function; extractable |
| enrich-ticket, update-jira, review-enrichment, adversarial-review-secops, investigate-event | `skills/*/SKILL.md` | **effectful shell** (LLM-executed; Jira/network/fs) | all four I/O classes | each has one identifiable pure sub-function (see below) |
| activate, deactivate | `skills/{activate,deactivate}/SKILL.md` | **effectful shell** (fs read/write) | reads/writes `settings.local.json` | JSON merge / key-deletion are pure functions |
| data / templates / checklists / agents / commands | `data/`, `templates/`, `checklists/`, `agents/`, `commands/` | **opaque** (static declarative config; no executable logic) | none | not classifiable as pure/effectful — consumed by LLM at runtime |

**Pure sub-functions inside effectful skills (natural verification units):** document assembly (enrich-ticket Stage 7), field range/enum validation (update-jira Step 2), score aggregation — simple-average / weighted-sum (review-enrichment), convergence predicate + quality-threshold predicate (adversarial-review-secops), TP/FP/BTP disposition constraint (investigate-event), JSON merge + platform predicate (activate), key-deletion transform (deactivate).

### Purity Boundary Map

```text
+-- Pure Core (deterministic; directly & exhaustively testable) --------------+
|                                                                             |
|   require-review    enrichment-completeness    disposition-guard            |
|   bias-check-reminder    handoff-validator                                  |
|   [+ extractable pure sub-fns from skills: field-validation, scoring,       |
|      convergence predicate, JSON-merge]                                     |
+-----------------------------------------------------------------------------+
                      | (invoked by Claude Code hook runtime)
                      v
+-- Effectful Shell (I/O at boundary) ---------------------------------------+
|                                                                             |
|   session-greeting (reads settings.local.json)                              |
|   activate / deactivate (read/write settings.local.json)                    |
|   enrich-ticket / update-jira / review-enrichment /                         |
|   adversarial-review-secops / investigate-event  (Jira + network + fs, LLM) |
+-----------------------------------------------------------------------------+
                      | (grounded/shaped by, at LLM runtime)
                      v
+-- Opaque Declarative Config (no executable logic) -------------------------+
|   data/*   templates/*   checklists/*   agents/*   commands/*               |
+-----------------------------------------------------------------------------+
```

### Purity Summary

| Classification | Count (executable components) | Notes |
|---------------|-------------------------------|-------|
| Pure core | 5 hooks | ideal verification target; already pure, no refactoring |
| Mutation-testable set | **6 hooks** (5 pure + session-greeting's pure gate/compare sub-function) | per module-criticality, session-greeting carries a ≥70% numeric kill target — its activation-gate string comparison is a pure, enumerable sub-function even though the hook is *effectful overall* (reads `settings.local.json`) |
| Effectful shell | 1 hook + 11 skills (7 original + 4 Stream D) | pure sub-functions extractable |
| Opaque (declarative) | 5 directory classes | verified by structural/existence checks, not purity |

**Purity boundary intact:** none of the 5 pure-core hooks perform I/O beyond stdin→stdout/stderr or spawn subprocesses beyond `jq`; no global mutable state; deterministic. No side effects have leaked into the pure core. **session-greeting is effectful overall** (it reads `settings.local.json`), but its activation-gate/compare logic is a pure sub-function; that sub-function is the 6th member of the mutation-testable set and carries the ≥70% numeric kill target from module-criticality.

---

## Formal Verification Readiness

### Tool Compatibility (adapted for a declarative plugin)

| Tool | Applicable? | Notes |
|------|-------------|-------|
| **Kani** (Rust) | **N/A** | no Rust production code |
| **CBMC** (C/C++) | **N/A** | no C/C++ |
| **proptest / hypothesis / fast-check** | **N/A** | no Rust/Python/JS production code |
| **BATS exhaustive input-partition testing** | **YES — this is the plugin's formal-verification analog** | the 5 pure hooks + session-greeting's pure gate sub-function (**6-hook mutation-testable set**) are total string→JSON functions over small, enumerable input partitions; near-exhaustive coverage is achievable |
| **shellcheck** (`.sh` static analysis) | **YES — installed, CLEAN** | already run in CI on `hooks/*.sh` |
| **PSScriptAnalyzer** (`.ps1` static analysis) | **YES but NOT ADOPTED** | no static analysis of `.ps1` anywhere; only a conditional parse-check when `pwsh` present |
| **JSON Schema validation of hooks.json** | **YES but NOT ADOPTED** | only `jq .` validity check; no schema for matcher/event/command structure |
| **Static hook↔template sync assertion** | **YES but NOT ADOPTED** | high-value; see gaps |

### Per-Component Readiness

| Component | Verifiable now? | Blocking issue | Effort to ready |
|-----------|-----------------|----------------|-----------------|
| 6-hook mutation-testable set (5 pure + session-greeting gate sub-fn) | **yes** | none — already pure/enumerable, BATS in place | ~0.3 day to add remaining partitions (dedicated assign/create positive test, jq-missing, investigation-branch, 39/40 boundary, false-pass fix, session-greeting jq-fallback branch). *fail-open closed by PR #13.* |
| session-greeting jq-fallback path | mostly | needs a PATH-without-`jq` fixture | ~1 hr |
| Skill pure sub-functions (validation/scoring/merge) | no (not extracted) | logic lives only as prose in `SKILL.md`; not callable | ~1–2 days each to extract to a testable shim, OR accept as unverifiable LLM behavior |
| Skill behavioral Iron-Law enforcement | **no** | inherently LLM-mediated; not formally verifiable | out of scope — mitigate with hook-layer gates + structural tests |

### Recommended Verification Targets (priority-ordered)

1. ~~disposition-guard false-pass~~ **DONE (PR #17, DI-004)** — heading-anchored + negating-text test; live-confirmed deny.
2. **require-review completeness** — [mostly done post-PR-13/14: fail-closed + expanded allowlist + SEC-001/002 tests] remaining: add dedicated `assign`/`create` positive vectors and a jq-missing vector; this hook is the infra half of the "NO JIRA UPDATE WITHOUT REVIEW APPROVAL" Iron Law.
3. ~~enrichment-completeness investigation branch~~ **DONE (PR #17, DI-007a)** — the 4-section investigation path (**Executive Summary, Alert Details, Disposition, Next Actions**) is now tested + heading-anchored (DI-014).
4. **hook↔template section-list sync** — static CI check that hook-hardcoded section lists equal template headings.
5. **handoff-validator boundary** — 39/40 char threshold + missing-`result` field.

---

## Security Posture

**Deferred to Step 0e-sec (DF-031).** Per the Step 0e specification, security scanning (Semgrep, dependency/secret audit, `.envrc`/`.mcp.json` credential exposure) is out of scope for this step. Tool availability note for 0e-sec handoff: `semgrep` is installed locally; `security.yml` runs Semgrep (config auto) weekly + on push.

**DI-001 update (RESOLVED — PR #12):** The HIGH-severity plaintext-credentials exposure from Step 0a (§8.1 of project-discovery.md — `.envrc`/`.mcp.json` untracked but not gitignored) has been **remediated**. Verified against the current `.gitignore`, which now lists `.envrc`, `.env`, `.mcp.json`, and `.claude/settings.local.json` — the secret-bearing files are no longer at risk of accidental commit. Residual action for 0e-sec: confirm any keys previously exposed on disk were rotated (out of scope for this step).

---

## Mutation Testing Baseline

### Tool status

| Tool | Applicable? | Notes |
|------|-------------|-------|
| cargo-mutants / mutmut / stryker | **N/A** | no Rust/Python/JS production code to mutate |
| **Manual mutation probe of pure hooks** | **applied** (below) | flip allow/deny, drop guard clauses, alter thresholds; check whether BATS catches |

Automated mutation tooling does not exist for bash-as-config. A manual mutation probe was run against the **6-hook mutation-testable set** (the 5 pure hooks + session-greeting's pure activation-gate sub-function) by reasoning about which source mutations the current 165-test suite would fail to kill (re-run post PR #17). Both **surviving mutants** (test-suite blind spots) and representative **killed mutants** (SM-8) were confirmed with live hook execution.

> **Anchor convention:** `require-review.sh` mutations are referenced by **construct name, not line number** — its line numbers churned every remediation pass (PR #13/#14/#15) and are now inverted (write-block precedes the allowlist). The three relevant constructs are: **(1) the write-block if-block** (5 write verbs — comment/edit/move/assign/create — plus their 5 `--output json` write forms, **evaluated before the allowlist** as of PR #15); **(2) the fail-closed catch-all** (the final `emit_deny` for unrecognized subcommands); **(3) the jq-availability guard** (the `command -v jq` check).

### Surviving Mutants (confirmed)

| # | Component | Mutation | Survives because | Risk |
|---|-----------|----------|------------------|------|
| SM-1 | disposition-guard **Alternatives-Considered check** | weaken the heading-anchored match back to a bare substring | **RESOLVED / KILLED (PR #17, DI-004).** The check is now heading-anchored (`grep -qiE "^#{1,6}[[:space:]]+Alternatives Considered"`), and a BATS test feeds negating body text. Live-confirmed 2026-07-19: `"## Disposition\nTP. No Alternatives Considered because obvious."` → **deny**; genuine `## Alternatives Considered` heading → allow. A mutant reverting to substring matching would now be killed. | **RESOLVED** (was HIGH) |
| SM-2 | require-review **write-block if-block** (delete `jr issue assign` / `jr issue create`) | delete `jr issue assign` / `jr issue create` from the write-block | **KILLED (PR #17, DI-005).** Nuance: first neutralized as a near-equivalent mutant by the fail-closed default + write-block-first ordering (PR #13/#15), then upgraded to a directly **KILLED** mutant when PR #17 (DI-005) added dedicated positive-deny BATS tests for `jr issue assign` and `jr issue create` — deleting either verb from the write-block now fails a test. | **KILLED** (was HIGH) |
| SM-3 | require-review **fail-closed catch-all** (final `emit_deny`) | flip fail-closed `deny` → `allow` for unknown subcommands | **RESOLVED (PR #13, SEC-002).** Hook is now fail-CLOSED; unknown `jr` subcommand denies. Guarded by hooks.bats "blocks unknown mutation-shaped jr subcommand (SEC-002)". Re-verified live 2026-07-19: `jr issue frobnicate` → **deny** (was `allow` in the pre-remediation baseline). Mutant would now be killed. | **RESOLVED** |
| SM-3b | require-review **write-block / allowlist evaluation ORDER** (SEC-009 / ADV-0-801) | swap ordering so the read-only allowlist is evaluated before the write-block | **RESOLVED (PR #15, d304fa5).** This was the CRITICAL bypass: a write command with an allowlist token in its args (`jr issue edit … "see jr board"`) returned allow. Now guarded by 4 ADV-0-801 bypass tests + 3 regression tests. Re-verified live 2026-07-19: bypass command denies, genuine reads allow. Mutant (restoring old order) would now be killed. | **RESOLVED** (was CRITICAL) |
| SM-4 | enrichment-completeness **investigation branch** + heading anchoring | delete/alter any of the 4 investigation-required sections, or weaken to substring | **RESOLVED (PR #17, DI-007a + DI-014).** The investigation branch is now tested with an `investigation-*` file_path, and the section check is heading-anchored so body-text mentions no longer falsely satisfy the gate. | **RESOLVED** (was MEDIUM) |
| SM-5 | handoff-validator **length threshold** | change threshold `40` → `1` or `1000` | **RESOLVED (PR #17, DI-007c).** The 39/40-char boundary is now tested; a threshold mutation would be caught. | **RESOLVED** (was MEDIUM) |
| SM-6 | require-review **jq-availability guard** (`command -v jq`) / same guard in all hooks | remove `jq`-missing guard (exit 1) | jq-absent path untested for every hook | LOW (env-dependent) |
| SM-7 | `bias-check-reminder.sh` | drop "Availability" / "Automation" bias line, or the data-file reference | only Confirmation + Anchoring asserted | LOW (advisory hook) |
| **SM-8** | `session-greeting.sh:35` (activation-gate compare `[ "$AGENT" = "secops-factory:orchestrator:orchestrator" ]`) | **negate the gate** — greet when the plugin is NOT activated / stay silent when it IS activated | **KILLED (not surviving).** The gate's two input partitions are both exercised by `hooks.bats` (current lines ~197–214; pre-remediation range 128–173): (a) `agent = "vsdd-factory:orchestrator:orchestrator"` → test *"session-greeting is silent when factory is not activated"* asserts empty output; (b) `agent = "secops-factory:orchestrator:orchestrator"` → test *"session-greeting greets when factory is activated"* asserts `"Morgan here"` + `systemMessage`. Negating the compare flips both partitions, so **at least one test fails → mutant killed.** All session-greeting tests pass in the current run (5/5). | **covered (killed)** |
| SM-8b | `session-greeting.sh` jq-unavailable **fallback branch** (grep/printf path, Invariant 3) | delete/alter the `jq`-absent fallback | **SURVIVES** — no test runs the hook with `jq` off `PATH`, so the fallback gate/emit path is unguarded (ties to GAP-11) | LOW (env-dependent) |

**Estimated current kill rate against the 6-hook mutation-testable set: ~90–95% (post-PR-17).** Trajectory: ~55–65% (original baseline) → ~75–80% (post-PR-15, the prior authoritative figure downstream docs anchored to) → **~90–95% (current, post-PR-17)**. PR #13/#14 killed SM-3 (fail-closed) and neutralized SM-2 (later KILLED outright by PR #17's dedicated assign/create tests); PR #15 killed SM-3b (the SEC-009/ADV-0-801 precedence-bypass) and added guarding tests; **PR #17 (DI-004/005/007/014) then closed SM-1, SM-4, and SM-5** (heading-anchoring, investigation-branch coverage, and the 39/40 boundary), raising the estimated kill rate to **~90–95%**. **There is no longer any open HIGH mutant** — SM-1 (the anti-confirmation-bias false-pass) is resolved. The remaining surviving mutants are low-risk env-dependent ones: SM-6 (jq-guard), SM-7 (advisory bias lines), and SM-8b (session-greeting jq-fallback). **Adding session-greeting to the set does not materially move the aggregate:** its activation-gate sub-function (SM-8) is already *killed* by existing tests (comfortably meeting the ≥70% module-criticality target for that hook). Module-criticality assigns per-hook numeric targets (session-greeting ≥70%); the aggregate above is the cross-set figure.

---

## The 7 Step-0d Documented Ambiguities — Verifiability

Each BC's "Undocumented behavior (ambiguity)" note was assessed for whether an *executable* check could ever confirm/refute it.

| # | Ambiguity (source BC) | Verifiable? | How / why |
|---|-----------------------|-------------|-----------|
| A-1 | **Two-layer review gating** — the recovered contract said the require-review hook blocks `jr issue edit` *unconditionally*; review-approval is skill-layer only (BC-3.01.001) | **Partially** | **Correction (post-PR-15):** the "unconditionally" claim was **FALSE until PR #15**. Pre-PR-15 the hook evaluated the read-only allowlist *before* the write-block, so a crafted `jr issue edit KEY --summary "see jr board"` matched the `jr board` allowlist token and returned **allow** — the edit was *not* blocked (SEC-009 / ADV-0-801, CRITICAL). PR #15 reordered evaluation (write-block first), making the block genuinely unconditional; the bypass class is now regression-tested (edit/comment/create/move + allowlist token → deny). Live-confirmed 2026-07-19: bypass command now denies, genuine reads still allow. The remaining bypass surface (a jr-mutation path not routed through Bash+hook) is verifiable by statically enumerating mutation invocation paths vs `hooks.json` matchers. Skill-layer marker check is LLM-behavioral → not executably verifiable. |
| A-2 | **Hook↔template section-list drift** — required sections hardcoded in hook, not read from templates; no sync (BC-3.02.001) | **YES** | A static CI assertion can compare the hook's hardcoded section list against the template headings and fail on drift. **Task-named high-value gap.** |
| A-3 | **disposition-guard substring false-pass** — "Alternatives Considered" matched anywhere in content; negating text passes (BC-3.03.001) | **YES — verified & RESOLVED** | Was live-confirmed defeatable (SM-1); **fixed in PR #17 (DI-004)** with a heading-anchored check + negating-text BATS test. Live-confirmed 2026-07-19: negating text now denies. Min-count of alternatives remains unenforced (LLM/quality concern, not gate-verifiable). |
| A-4 | **bias-check-reminder trigger scope** — fires on ALL PostToolUse Bash events, not only research/Perplexity, contrary to its description (BC-3.04.001) | **YES** | Confirmed statically: `hooks.json` matcher is `Bash\|mcp__perplexity__*` — so it *does* fire on every Bash call. A test asserting the matcher string (or an integration test on a non-research Bash event) verifies scope. |
| A-5 | **handoff-validator 40-char threshold** — hardcoded, undocumented, heuristic not a quality gate (BC-3.05.001) | **YES (mechanism), NO (adequacy)** | The 39/40 boundary is executably testable (**task-named case**, currently SM-5). Whether 40 is the *right* value is a judgment call, not verifiable. |
| A-6 | **review-approval marker undefined / session-boundary loss** — marker is a conversation-context convention with no defined format; lost across sessions (BC-4.03.001) | **NO (today)** | The marker is LLM conversation state with no artifact. Not executably verifiable unless the marker is redesigned as a persisted file/JIRA-comment token that update-jira can read — then it becomes testable. |
| A-7 | **Honest-Convergence "<3 substantive" + SECOPS-P1 numbering unenforced** (BC-4.04.001) | **Partially** | SECOPS-P1 pass-numbering enforcement *could* be added to handoff-validator and would then be testable. The "fewer than 3 substantive items → declare convergence" clause relies on reviewer honest judgment (LLM) → not verifiable. |

**Verifiability roll-up:** 3 fully verifiable (A-2, A-3, A-4), 3 partially (A-1, A-5, A-7), 1 not currently verifiable (A-6). **An 8th ambiguity** was noted by the architect (BC-6.01.001: `activated_plugin_version` behavior when `plugin.json` is unreadable is unspecified) — verifiable via an activate-skill shim test once the merge logic is extracted.

---

## PowerShell Hook Parity — CI vs Local

**Finding: `.ps1` behavioral equivalence is verified only when `pwsh` happens to be on PATH, and CI neither installs nor verifies `pwsh`.**

- **Structural parity (unconditional):** `parity.bats` test #1 (every `.sh` has a `.ps1` sibling) and #2 (`hooks.json`/`hooks.json.windows` declare equal hook counts and all Windows commands reference a `.ps1`) run always. The CI `structure` job independently re-checks sibling existence. These 3 checks are solid.
- **Behavioral parity (conditional):** the 12 remaining `parity.bats` tests (identical normalized-JSON stdout, identical stderr, identical exit codes across `.sh`/`.ps1`) all call `require_pwsh`, which **`skip`s** when `pwsh` is absent. Locally `pwsh` is **ABSENT** → 12 of 14 parity tests skip (confirmed).
- **CI gap:** `ci.yml` runs on `ubuntu-latest` and **does not install or assert `pwsh`**. GitHub's `ubuntu-latest` image currently ships `pwsh` preinstalled, so these tests likely *do* run in CI today — but this is **implicit and unpinned**. If the runner image drops `pwsh`, all 12 behavioral-parity tests + the `.ps1` syntax check in `run-all.sh` **silently skip and CI stays green** (a false-pass). `.ps1` files also receive **no static analysis** (no PSScriptAnalyzer; shellcheck is `.sh`-only).
- **Net:** on CI, `.sh` hooks get shellcheck + BATS behavioral tests; `.ps1` siblings get, at best, a conditional parse-check and conditional behavioral parity — **and nothing guarantees the condition holds.**

---

## Identified Gaps

### Critical Gaps (Must Fix Before Extending)

| # | Gap | Affected area | Risk | Effort |
|---|-----|---------------|------|--------|
| GAP-1 | ~~disposition-guard false-pass — substring match defeats the anti-confirmation-bias Iron Law~~ **RESOLVED (PR #17, DI-004)** — check now heading-anchored + negating-text BATS test; live-confirmed deny. No open HIGH gap remains. | `disposition-guard.sh`, BC-3.03.001 | — (closed) | done |
| GAP-2 | ~~require-review `assign`/`create`/fail-open untested + allowlist-precedence bypass~~ **RESOLVED (PR #13/#14/#15)** — fail-open → fail-closed (SEC-002); `comment` gated (SEC-001); allowlist expanded + tested; **CRITICAL allowlist-precedence bypass fixed (SEC-009/ADV-0-801, PR #15)** — write-block now first, bypass+regression tested; **dedicated `assign`/`create` positive-deny tests added (PR #17, DI-005)** — residual closed | require-review hook (write-block if-block; fail-closed catch-all), BC-3.01.001 | — (closed) | done |
| GAP-3 | ~~`pwsh` not installed/asserted in CI — parity/`.ps1` checks can silently skip~~ **RESOLVED (PR #16, DI-006/011)** — CI now asserts `pwsh` + PSScriptAnalyzer, so behavioral-parity tests no longer silently skip in CI | `ci.yml`, `run-all.sh`, all `.ps1` | — (closed) | done |

### Important Gaps (Should Fix Soon)

| # | Gap | Affected area | Risk | Effort |
|---|-----|---------------|------|--------|
| GAP-4 | ~~enrichment-completeness investigation 4-section branch untested (SM-4)~~ **RESOLVED (PR #17, DI-007a + DI-014)** — investigation branch now tested + heading-anchored | `enrichment-completeness.sh`, BC-3.02.001/BC-5.01.001 | — (closed) | done |
| GAP-5 | ~~No hook↔template section-list sync check (A-2)~~ **RESOLVED (PR #17, DI-007b)** — section-name sync guard added | hook + `templates/*.yaml` | — (closed) | done |
| GAP-6 | handoff-validator boundary 39/40 **RESOLVED (PR #17, DI-007c)**; residual (LOW): missing-`result` field still untested (A-5) | `handoff-validator.sh`, BC-3.05.001 | LOW (was MEDIUM) | 15 min (residual) |
| GAP-7 | Skill-layer behavior entirely structural-only — **11 skills** (7 original + 4 Stream D: assess-priority, read-ticket, create-advisory, analyze-ticket-effort), incl. activate JSON-merge / never-clobber-corrupt (BC-6.01.001) never executed | all `skills/*` | MEDIUM — merge bug could corrupt user `settings.local.json` | 1–2 days (extract activate/deactivate merge + assess-priority scoring to testable shims) |
| GAP-8 | ~~No static analysis of `.ps1` (no PSScriptAnalyzer)~~ **RESOLVED (PR #16, DI-002)** — PSScriptAnalyzer now asserted in CI | all `.ps1` | — (closed) | done |

### Minor Gaps (Fix Opportunistically)

| # | Gap | Affected area | Risk | Effort |
|---|-----|---------------|------|--------|
| GAP-9 | jq-missing exit-1 path untested for every hook (SM-6) | all hooks | LOW | 1 hr |
| GAP-10 | bias-check-reminder: Availability/Automation + data-file ref not asserted (SM-7) | `bias-check-reminder.sh` | LOW | 15 min |
| GAP-11 | session-greeting jq-fallback + cwd-missing paths untested | `session-greeting.sh` | LOW | 1 hr |
| GAP-12 | ~~require-review read-only allowlist: only `view` tested~~ **RESOLVED (PR #14)** — allowlist verbs (changelog, assets, `--version`, `--output json` forms) now have dedicated tests | `require-review.sh` | — (closed) | done |
| GAP-13 | update-jira VP-SKILL-007/008 labelled "manual" — CVSS range + review-precedes-edit unautomated | BC-4.02.001 | LOW–MEDIUM | folds into GAP-7 |

---

## Remediation Plan

### Before proceeding past Phase 0

**All original Phase-0-blocking critical gaps are now RESOLVED** (post-PR-16/17): GAP-1 (disposition false-pass, DI-004), GAP-3 (CI pwsh/PSScriptAnalyzer, DI-006/011), and GAP-2 (require-review, PR #13/#14/#15 + DI-005) are all closed. There is **no open HIGH/CRITICAL gap** remaining before Phase 1.

### Incorporate into the VSDD pipeline (ongoing)

1. ~~**GAP-5 hook↔template sync**~~ **DONE (PR #17, DI-007b)** — section-name sync guard added; keep it re-running whenever a template or hook section list changes.
2. **GAP-7 skill pure-sub-function extraction** — when any skill's validation/merge/scoring logic is touched under Feature Mode (now **11 skills**, incl. assess-priority's 6-factor arithmetic and activate's JSON-merge), extract it to a shell shim with BATS coverage (converts structural-only → behavioral for the error-prone parts).
3. ~~**GAP-8 PSScriptAnalyzer**~~ **DONE (PR #16, DI-002)** — added to the CI hardening lane alongside shellcheck.
4. Adopt **near-exhaustive input-partition BATS** for the **6-hook mutation-testable set** (5 pure hooks + session-greeting's pure gate sub-function) as the standing "formal verification" analog (documented under Formal Verification Readiness).

### Total Estimated Remediation Effort

| Priority | Gap count | Total effort |
|----------|-----------|--------------|
| Critical (open) | 0 (GAP-1/GAP-3 resolved by PR #16/#17; GAP-2 by PR #13/#14/#15+#17) | — |
| Important (open) | 2 (GAP-7 skill sub-fn extraction; GAP-9 jq-guard) | ~1–2 days |
| Minor (open) | 3 (GAP-6 residual missing-`result`; GAP-10 bias lines; GAP-11 session-greeting jq-fallback; GAP-13 folds into GAP-7) | ~0.4 day |
| Resolved since original | GAP-1, GAP-2, GAP-3, GAP-4, GAP-5, GAP-8, GAP-12 + DI-001 secrets (PR #12–#17) | — |
| **Total open** | **~5** | **~1.5–2.5 days** |

---

## Quality Gate Checklist

- [x] Numerical baselines provided where tools apply (165 tests; per-BC coverage matrix; shellcheck clean; parity skip count)
- [x] Where tools are unavailable/N/A (Kani, cargo-mutants, coverage), the gap is documented with the reason and the plugin-appropriate analog + install/adoption path
- [x] Every readiness assessment includes estimated effort to reach readiness
- [x] Purity boundary map is present
- [x] Security scanning is NOT included (deferred to Step 0e-sec)
- [x] All 17 BCs assessed for precondition/postcondition/invariant coverage (13 original + 4 Stream D: BC-4.05.001, BC-4.06.001, BC-7.01.001, BC-8.01.001)
- [x] 7 (+1) Step-0d ambiguities assessed for verifiability
- [x] PowerShell `.sh`/`.ps1` parity CI-vs-local status documented
- [x] Findings cite specific file paths and line numbers; two highest-value defects live-demonstrated

---
document_type: project-context
level: L0
version: "1.7"
status: active
producer: codebase-analyzer
phase: 0
step: "0f"
project: secops-factory
date: "2026-07-19 (re-synced post adversarial pass 7)"
source_state: "v0.9.0 + PR #12 (gitignore) + PR #13 (SEC-001..005 fixed, f450d9f) + PR #14 (read-only allowlist expansion / DI-010, 0ec794a); 41 commits / PRs #1–#14 all verified merged at HEAD 0ec794a; BATS suite 138/138 (12/14 parity skip w/o pwsh); 6-hook mutation aggregate ~75–80%"
inputs:
  - phase-0-ingestion/project-discovery.md
  - phase-0-ingestion/recovered-architecture.md (+ arch-recov-api-surface.md, arch-recov-integrations.md)
  - phase-0-ingestion/conventions.md
  - phase-0-ingestion/behavioral-contracts/*.md (13 BCs)
  - phase-0-ingestion/verification-gap-analysis.md
  - phase-0-ingestion/security-audit.md
  - specs/module-criticality.md
  - holdout-scenarios/HS-INDEX.md (index reference only — holdout-protected)
  - STATE.md (drift items DI-001..DI-013)
---

# Project Context — secops-factory

> **Capstone Phase 0 artifact.** THE scoping document Feature Mode phases load every cycle.
> Self-contained summary; deep detail lives in the linked shards (DF-021). Do not duplicate
> shard content here — follow the links. All paths absolute under `/Users/jmagady/Dev/secops-factory/`.

## 1. Identity

| Attribute | Value |
|-----------|-------|
| Product | The Claude Code plugin at `plugins/secops-factory/` |
| Repo kind | Single-plugin Claude Code **marketplace** repo |
| Version | `0.9.0` (plugin.json == marketplace.json — triple-version lock) |
| Domain | ICS/OT SecOps: CVE enrichment, event investigation, MITRE ATT&CK mapping, adversarial review, Jira-native metrics |
| Owner / author | `drbothen` (manifests); git author of record `Joshua Magady` |
| License | MIT · Repo `https://github.com/drbothen/secops-factory` |
| Nature | **Declarative** plugin — no compiled/interpreted app code. Markdown agents/skills/commands + JSON manifests + Bash/PowerShell hooks + YAML templates. No `package.json`/`Cargo.toml`/`go.mod`. |

**One line:** A markdown-defined plugin that turns Claude into an ICS/OT SecOps analyst, with
shell/PowerShell enforcement hooks, BATS tests, and a factory-artifacts release workflow.

**Runtime dependencies:** `jr` CLI (`Zious11/jira-cli`, Rust — the sole Jira read/write channel,
**required**); Perplexity MCP (**recommended**, graceful WebSearch/WebFetch fallback wired in every
skill); fallback intel APIs NVD / FIRST EPSS / CISA KEV.

Detail: `.factory/phase-0-ingestion/project-discovery.md`

## 2. Architecture

Five layers; slash commands dispatch to skills, which invoke agents grounded in data KBs, shaped by
templates, gated by checklists and hooks. Three end-to-end pipelines:

1. **Vulnerability mgmt:** read-ticket → enrich-ticket (8 stages) → adversarial/review → update-jira
2. **Event investigation:** read-ticket → investigate-event (7 stages, TP/FP/BTP) → review → update-jira
3. **Advisory creation:** scan-threats → create-advisory → source verification

A companion orchestrator agent (**Morgan**) routes sessions and tracks pipeline position; 5 specialist
agents do deep work (security-analyst Alex, security-reviewer Riley [opus], metrics-analyst Quinn,
osint-researcher Harper, advisory-writer). Hooks fire on Claude Code tool events (deterministic, <100ms,
no LLM) and are the only executable enforcement surface.

```
commands/ (20 dispatch stubs) → agents/orchestrator/ (Morgan + 3 playbooks)
  → skills/<name>/SKILL.md (19 procedures) + agents/*.md (5 specialists)
    → data/ (10 KBs) · templates/ (6) · checklists/ (15)   [knowledge layer]
  ⟂ hooks/*.{sh,ps1} (6 pairs) + hooks.json(.windows)       [cross-cutting enforcement]
External boundary: jr CLI (required) · Perplexity MCP (recommended) · NVD/EPSS/KEV (fallback)
```

Full component catalog + machine-readable Component-Map YAML + dependency graph (now algorithmically
verified **acyclic** — the C-2→C-3 back-edge was removed, orchestrator depends on skills not the reverse;
the intentional DI-003 edge C-2→C-6, adversarial-review-secops skill → review-convergence playbook, is now
explicit in the YAML and does not introduce a cycle) + data flows:
`.factory/phase-0-ingestion/recovered-architecture.md`
API surface (20 commands, dispatch table): `.factory/phase-0-ingestion/arch-recov-api-surface.md`
Integrations / DTU candidates: `.factory/phase-0-ingestion/arch-recov-integrations.md`

### Component criticality (from `specs/module-criticality.md`)

**Authoritative census — YAML component-map aggregate (C-1..C-24): 24 modules — 1 CRITICAL / 12 HIGH / 7 MEDIUM / 4 LOW.**
`update-jira` folds into the HIGH `skill-procedures` aggregate (C-2) at this granularity, so
require-review (C-12) is the sole CRITICAL; hook-manifests (C-18) is a counted HIGH member. A secondary
**per-artifact figure of 43 modules (2 CRITICAL / 16 HIGH / 20 MEDIUM / 5 LOW)** explodes C-2 into its 19
skills (hook-manifests is already its own C-18 in the aggregate, so the per-artifact total is unchanged);
at that granularity update-jira surfaces as a distinct CRITICAL skill. Derivation: **24 − 1 (C-2) + 19
(skills) + 1 (secops-health promoted from the command-dispatch aggregate) = 43**, where command-dispatch
counts as 19 slash-command stubs distinct from the separately-counted `secops-health` diagnostic command.

| Tier | Modules (per-artifact view; aggregate note where it differs) |
|------|---------|
| **CRITICAL** | `hooks/require-review` (authorization gate on Jira writes — sole CRITICAL in the aggregate). `skills/update-jira` (last-mile writer to Jira record) is CRITICAL at sub-artifact granularity but folds into the HIGH C-2 aggregate. |
| **HIGH** | `hooks/enrichment-completeness`; `hooks/disposition-guard`; `hooks/hooks.json*` manifests (C-18); skills enrich-ticket, review-enrichment, adversarial-review-secops, investigate-event, activate; orchestrator (Morgan) + 3 workflow playbooks; agents security-analyst, security-reviewer; data KBs; test-suite + CI |
| **MEDIUM** | skill deactivate; agents metrics-analyst, osint-researcher, advisory-writer; templates; checklists; skills research-cve, read-ticket, assess-priority, map-attack, advisory + metrics families; jr CLI; Perplexity MCP |
| **LOW** | hooks bias-check-reminder, handoff-validator, session-greeting; command dispatch; secops-health |

Mutation/verification numeric targets apply to the **6 mutation-testable hooks** (input-partition
BATS analog — session-greeting included: it is effectful but its gate/compare logic is a pure,
enumerable sub-function): require-review ≥95%, enrichment-completeness ≥90%, disposition-guard ≥90%,
bias-check-reminder / handoff-validator / session-greeting ≥70%. For require-review, the fail-closed
design **materially improves** assurance — SM-3 (fail-open) resolved and SM-2 (assign/create) rendered
behaviorally inert by the default-deny fallthrough (PR #13) — but its **≥95% CRITICAL kill-rate target is
NOT yet demonstrated met**: no per-hook mutation run has executed, and its individual kill rate is unmeasured
(the authoritative current aggregate across the 6-hook mutation-testable set is **~75–80%**, up from a
superseded ~55–65% pre-PR-13 baseline — verification-gap-analysis.md §Mutation Testing Baseline →
Surviving Mutants summary (~line 194) — not a per-hook figure). The
target stays open until Phase 6 / Feature Mode mutation testing. All other modules are
declarative/LLM/static — tier governs review depth, not a numeric kill-rate.

## 3. Context Budget

**Strategy: component-scoped** (total plugin source > 50K tokens), with **Extended ToC** for `data/`.
Load per-component, not whole-repo. Chunk the large KBs (500-line Read offsets).

| Component | Approx LOC | Est. tokens | Load note |
|-----------|-----------|-------------|-----------|
| commands/ (20) | ~160 | ~1.5K | trivially loadable |
| skills/ (19 SKILL.md) | ~1,500 | ~15K | load per-skill |
| agents/ + orchestrator (6 + 3 playbooks) | ~800 | ~8K | load per-agent |
| hooks/ (6 × sh+ps1) | ~680 | ~7K | full-load OK |
| templates/ (6) | ~480 | ~5K | full-load OK |
| checklists/ (15) | ~1,500 | ~15K | load per-dimension |
| **data/ KBs (10)** | **~8,000+** | **~80K+** | **dominant — Extended ToC / chunked; `event-investigation-best-practices.md` ~3027 lines needs 500-line chunks** |
| tests/ (4 bats) | ~1,000 | ~12K | load per-suite |

## 4. Conventions (digest)

Declarative conventions, not code style. 20 machine-readable enforceable rules (CONV-001..020) live in the
YAML block of the shard. Load-bearing must-follows:

- **Skills:** `skills/<kebab>/SKILL.md`; section order Iron Law → Announce at Start → Red Flags (≥6 rows) → Prerequisites → Workflow (staged) → References. Iron Law form: `NO <ACTION> WITHOUT <PREREQUISITE> FIRST` (blockquote).
- **Commands:** thin wrappers — body is exactly ``Use the `secops-factory <name>` skill via the Skill tool.`` Every command needs a matching skill dir (exception: `secops-health`).
- **Paths:** always `${CLAUDE_PLUGIN_ROOT}/` — never hardcoded.
- **Hooks:** every `.sh` has a byte-parity `.ps1` sibling; exit 0 for all business decisions (exit 1 only if `jq` missing). **Fail-open historically**, but see the require-review change in §5/§8.
- **Agents:** frontmatter `name/description/model/color/tools`; security-reviewer (Riley) is opus + read-only (no Write tool).
- **Release:** Conventional Commits, **no Co-Authored-By / AI attribution**; squash-merge via PR; tag `vX.Y.Z` after merge; triple version lock (plugin.json + marketplace.json + tag); Keep-a-Changelog.

Two unresolved style ambiguities: `secops(<scope>):` vs `feat(<scope>):` commit prefix (see DI tracking);
`secops-health` command-without-skill anomaly (DI-002).

Detail + CONV-001..020 YAML: `.factory/phase-0-ingestion/conventions.md`

## 5. Behavioral Contracts (13 recovered — index)

Contract files: `.factory/phase-0-ingestion/behavioral-contracts/<id>.md`

| BC | Subject | Rev | Tier | Verification |
|----|---------|-----|------|--------------|
| BC-3.01.001 | require-review hook — Jira field-modification gate | **v1.6** | CRITICAL | PARTIAL (PR #13 5-verb comment-deny + fail-closed, PR #14 allowlist / DI-010, VP renumber; line-anchor + dual-file-hash + write-block citation corrections) |
| BC-3.02.001 | enrichment-completeness hook — section completeness gate | **v1.3** | HIGH | PARTIAL — **EC-004 = DENY**: investigation files require ALL FOUR sections, no partial-save (see §6) |
| BC-3.03.001 | disposition-guard hook — Alternatives-required gate | **v1.3** | HIGH | FULLY (declared-VP coverage); known defect DI-004 now first-class **EC-009** (see §6) |
| BC-3.04.001 | bias-check-reminder hook — PostToolUse advisory | **v1.3** | LOW | PARTIAL |
| BC-3.05.001 | handoff-validator hook — SubagentStop empty-output guard | **v1.2** | LOW | PARTIAL |
| BC-3.06.001 | session-greeting hook — activation-gated SessionStart banner | **v1.2** | LOW | FULLY (core); jq-fallback open |
| BC-4.01.001 | enrich-ticket skill — 8-stage CVE enrichment | v1.0 | HIGH | STRUCTURAL-ONLY |
| BC-4.02.001 | update-jira skill — review-gated Jira field update | **v1.2** | CRITICAL | STRUCTURAL-ONLY — comment-post step (PC#4) needs human override (DI-013) |
| BC-4.03.001 | review-enrichment skill — fresh-context quality review | v1.0 | HIGH | STRUCTURAL-ONLY (strongest) |
| BC-4.04.001 | adversarial-review-secops skill — convergence loop | v1.0 | HIGH | STRUCTURAL-ONLY |
| BC-5.01.001 | investigate-event skill — 7-stage investigation | **v1.3** | HIGH | STRUCTURAL-ONLY — Stage 7 comment-post needs human override (DI-013) |
| BC-6.01.001 | activate skill — per-project activation lifecycle | v1.0 | HIGH | STRUCTURAL-ONLY |
| BC-6.01.002 | deactivate skill — per-project deactivation | v1.0 | MEDIUM | STRUCTURAL-ONLY |

All six hook BCs (BC-3.01..BC-3.06) carry dual-file (.sh + .ps1) input-hashes for the drift check.

> **BC-3.01.001 now at v1.6 (2026-07-19) — fully re-synced** (v1.4 line-anchor corrections to the
> 98-line post-PR-14 file; v1.5 dual-file .sh + .ps1 `input-hash`; v1.6 standardized the canonical write-block
> citation to `require-review.sh:88-94`, deny at :93). Behavior at HEAD (verified vs commit
> 0ec794a): (a) PR #13 moved `jr issue comment` into the **deny** block and flipped the default to
> **fail-closed** (unrecognized `jr` subcommands → deny) — the old allow/fail-open postconditions
> and EC-003 are superseded; (b) PR #14 expanded the read-only allowlist with `jr issue changelog`,
> `jr assets search/view`, `jr --version`, and seven `--output json` families for the metrics suite,
> and added Invariant #4 (the `--output json` global flag breaks substring matching — `jr issue view`
> is NOT a substring of `jr --output json issue view`), resolving **DI-010**; (c) adversarial pass 1
> renumbered the three PR-#14 verification properties to **VP-HOOK-020 / VP-HOOK-021 / VP-HOOK-022**
> (the former VP-HOOK-004/005/006 collided with BC-3.02.001's namespace). `modified:` now records the
> PR #13, PR #14, and ADV-0 revisions. BATS suite 138/138.

> **BC-3.02.001 (v1.3) + BC-3.03.001 (v1.3) — aggregate hook semantics (ADV-0-501/606).** EC-004 is
> **DENY**: an `investigation-*` file must contain **all four** sections (Executive Summary, Alert Details,
> Disposition, Next Actions) before enrichment-completeness permits the save — **no partial-save** capability.
> The two completeness hooks co-firing is now **VERIFIED against `hooks.json`** (not inferred): both
> `enrichment-completeness.sh` and `disposition-guard.sh` sit in the same `PreToolUse/Write` hooks array,
> execute sequentially, and **a deny from either wins**. In the standard investigate-event workflow, Stage 7
> generates the document **once** from `event-investigation-tmpl.yaml` (which already carries all four
> headings), so no partial-save path is ever produced. Consequently disposition-guard's **in-progress-allow
> path (PC#2 / EC-003) is HOOK-ISOLATED** — reachable only in isolated hook testing, not via the standard
> workflow write path. **The DI-004 false-pass is now a first-class edge case, EC-009** (+ canonical vector):
> `grep -qiF "Alternatives Considered"` matches negating body text such as "No Alternatives Considered were
> required", so a disposition can pass the anti-bias gate without genuine alternatives; HS-014 targets a
> section-heading-anchored fix. **Scope note (no overclaim):** disposition-guard enforces **heading-presence
> only** — the "at least 2 alternative hypotheses" wording in its deny reason is LLM-soft guidance, not
> enforced (it never counts alternatives); alternative *quality* is validated by review-enrichment. All six
> hook BCs also normalized their input-hash to dual-file .sh + .ps1 form.

## 6. Verification Posture

**Three-bucket roll-up: Fully 2 / Partially 11 / Un-verified 0** (of 13 BCs).
Fully: BC-3.03.001 (**FULLY = declared-VP coverage; the known DI-004 defect is documented as EC-009 and is
NOT fixed** — see §5), BC-3.06.001. **138/138 BATS pass** locally (was 130 after PR #13; +8 from PR #14
metrics-suite allow tests) — **caveat:** 12 of 14 parity tests `skip` when `pwsh` is absent (as it is
locally), so behavioral `.ps1` parity is not actually exercised in a local run; CI relies on the runner
image preinstalling `pwsh` and does not assert it (**DI-006**).

**The headline is the verification asymmetry:** the 6 deterministic **hooks** are genuinely
behaviorally tested; the 7 LLM-executed **skills** are **structural-only** — BATS proves Iron Law text,
Announce-at-Start, Red-Flag counts, `${CLAUDE_PLUGIN_ROOT}` reference portability, referenced-file
existence, and agent frontmatter/tool constraints, but **no executable check confirms skills enforce
their preconditions/postconditions/invariants at runtime** (that is LLM behavior). Structural gates catch
deletion/drift but are not behavioral verification of the Iron Laws.

Manual mutation probe against the **6-hook mutation-testable set** (5 pure hooks + session-greeting's pure
activation-gate sub-function): authoritative current aggregate kill-rate **~75–80%** (up from a superseded
~55–65% pre-PR-13 baseline — verification-gap-analysis.md §Mutation Testing Baseline → Surviving Mutants
summary (~line 194)). Resolved/neutralized post PR #13/#14:
**SM-3 (require-review fail-open) RESOLVED**, **SM-2 (assign/create) downgraded HIGH→LOW** (fail-closed
default makes it near-equivalent), **SM-8 (session-greeting activation-gate) KILLED** by existing tests.
Still-open blind spots feed the drift items (§8): **SM-1 disposition-guard false-pass (HIGH, DI-004)** —
the one remaining HIGH mutant; SM-4 enrichment-completeness investigation branch — the DENY-all-4-sections
path (BC-3.02.001 v1.2) is untested (DI-007); SM-8b
session-greeting `jq`-fallback branch (LOW, env-dependent); pwsh-not-in-CI silent skip (DI-006). require-review's
**≥95% CRITICAL target is not yet demonstrated met** (no per-hook mutation run; individual kill rate
unmeasured). No coverage tool applies (declarative plugin); shellcheck clean on
`.sh`; `.ps1` still gets no static analysis.

Detail + per-BC matrix + remediation plan: `.factory/phase-0-ingestion/verification-gap-analysis.md`

## 7. Security Posture (post-fix)

**Risk posture: LOW** for the threat model (analyst workstation, not internet-facing; adversary = anyone
with Jira project write access). Human disposition gate **PASSED** (2026-07-19).
Findings: 0 critical / 0 high / 1 medium / 4 low / 3 info.

**SEC-001..005 FIXED and merged (PR #13, commit f450d9f):**
- SEC-001 (MEDIUM, prompt injection via Jira comment path) — `jr issue comment` now review-gated (moved to deny block).
- SEC-002 (LOW, fail-open) — unrecognized `jr` subcommands now **fail-closed** (emit_deny).
- SEC-003 (LOW) — MCP versions pinned in `docs/mcp.json.example` (perplexity 0.9.0, playwright 0.0.78).
- SEC-004 (LOW) — `release.yml` write permission scoped to the release job (validate now read-only).
- SEC-005 (LOW) — Semgrep pinned to 1.170.0 via direct `semgrep --config auto --error` + health-check (no more silent early-exit).

SEC-006 (jr CLI unversioned) and SEC-007 (Tavily key in URL) **ACCEPTED** (info; review next release).
SEC-008 / DI-001 **RESOLVED** (PR #12): `.envrc`/`.mcp.json`/`.env`/`.claude/settings.local.json`
gitignored; confirmed never committed; no credentials in git history.
Now also active: **branch protection on `main`** + **Semgrep in CI**.

Detail + all findings/dispositions: `.factory/phase-0-ingestion/security-audit.md`

## 8. Open Drift Items (from STATE.md)

| ID | Item | Severity | Status | Target |
|----|------|----------|--------|--------|
| DI-001 | Live keys in untracked non-gitignored `.envrc`/`.mcp.json` | HIGH | **RESOLVED** (PR #12) | — |
| DI-002 | `secops-health` command has no skill dir (CI-special-cased) | LOW | open | Phase 1 |
| DI-003 | `adversarial-review-secops` skill references orchestrator playbook (intentional layer inversion) | LOW | open | Phase 1 |
| DI-004 | disposition-guard substring false-pass (live-demonstrated, SM-1) | HIGH | open | first Feature cycle |
| DI-005 | require-review assign/create/fail-open paths untested | HIGH | largely superseded — fail-open→fail-closed resolved & SM-2 neutralized (PR #13); dedicated assign/create partition test still open | first Feature cycle |
| DI-006 | pwsh parity tests skip silently; CI does not assert pwsh; no `.ps1` static analysis | HIGH | open | first Feature cycle |
| DI-007 | enrichment-completeness investigation branch untested; hook↔template section-sync gap; handoff-validator 39/40 boundary | MEDIUM | open | first Feature cycle |
| DI-008 | Component-Map numbering diverged (prose table vs YAML) in recovered-architecture.md | LOW | **RESOLVED** (arch reconciled — C-1..C-24 agree end-to-end) | — |
| DI-009 | hook-manifests component absent from machine-readable YAML component map | HIGH | **RESOLVED** (added as C-18 HIGH; tail renumbered to C-24) | — |
| DI-010 | SEC-002 fail-closed regression: `jr issue changelog` (read-only, metrics suite) wrongly denied | HIGH | **RESOLVED** (PR #14, 0ec794a — allowlist expanded incl. `--output json` families; 8 new BATS; 138/138) | — |
| DI-011 | `hooks.json`/`hooks.json.windows` validated by `jq .` only — no JSON-Schema for matcher/event/command structure; a malformed matcher silently de-wires the CRITICAL require-review gate | LOW (likelihood-weighted; **consequence is HIGH** — silent de-wiring of the sole CRITICAL authz gate) | open | first Feature cycle |
| DI-012 | **BC coverage is partial by design** (pass-2/3 observation): **three** Iron-Law-bearing skills have **no behavioral contract** — `assess-priority` ("NO PRIORITY ASSIGNMENT WITHOUT MULTI-FACTOR ASSESSMENT FIRST", `skills/assess-priority/SKILL.md:13`), `create-advisory`, `analyze-ticket-effort`; plus `read-ticket` (no Iron Law, but the SEC-001 prompt-injection entry point) is uncontracted. The 13 recovered BCs cover the highest-blast-radius modules, not every Iron-Law-bearing skill. | MEDIUM | **PENDING HUMAN DECISION** at Phase 0 gate — expand the BC set before Feature Mode, or accept partial coverage? | Phase 0 exit gate |
| DI-013 | **Comment-post steps require a manual permission-override every time** (pass-6): PR #13's unconditional `jr issue comment` deny hard-gates the two comment-posting workflow steps — `update-jira` PC#4 and `investigate-event` Stage 7 — but **no marker-based override exists** (require-review matches substrings on stdin only, with no memory of review state). Every legitimate comment post now needs a human permission-override. | MEDIUM-HIGH | **PENDING HUMAN DECISION** at Phase 0 gate — (a) accept the friction as security posture, (b) implement a review-approval marker mechanism (code change), or (c) add a dedicated gated `post-review-comment` command | Phase 0 exit gate |

Note: DI-005 is largely superseded by PR #13 (fail-open→fail-closed resolved, SM-2 neutralized); only a
dedicated assign/create partition test remains, and it is no longer load-bearing. DI-002/DI-003/DI-011 are
consistency/spec/hardening items, not behavioral defects. DI-008/DI-009/DI-010 resolved this cycle.

## 9. Restricted Areas (require explicit human review before change)

| Area | Path | Justification |
|------|------|---------------|
| Authorization gate | `plugins/secops-factory/hooks/require-review.{sh,ps1}` | CRITICAL — the only hard gate on Jira system-of-record writes; behavior changed twice recently (PR #13 comment-deny + fail-closed; PR #14 allowlist expansion); fail-closed design improves assurance but the ≥95% CRITICAL kill-rate target is not yet demonstrated met, and any change re-touches the sole authz gate |
| Jira writer | `plugins/secops-factory/skills/update-jira/SKILL.md` | CRITICAL — last-mile writer; review-approval marker is LLM-soft and spoofable; only the require-review hook stands between it and record corruption |
| Injection entry point | `plugins/secops-factory/skills/read-ticket/SKILL.md` | SEC-001 surface — ingests Jira ticket bodies verbatim (unsanitized external data); mitigation is defense-in-depth framing |
| Hook wiring | `plugins/secops-factory/hooks/hooks.json`, `hooks.json.windows` | A wrong matcher silently de-wires the CRITICAL require-review gate; `jq .`-validated only, no JSON-Schema (DI-011) |
| Anti-bias gate | `plugins/secops-factory/hooks/disposition-guard.{sh,ps1}` | Confirmed false-pass (DI-004) — bypassable quality gate on investigation dispositions |
| User-config writer | `plugins/secops-factory/skills/activate/SKILL.md` | JSON-merge into `settings.local.json` (never-clobber-corrupt path unexecuted) — invalid-state risk on local user config |
| Release/CI + credentials | `.github/workflows/*.yml`, `.envrc`, `.mcp.json` | Supply-chain / privilege boundary; credentials local-only (gitignored) — never commit |

## 10. Recent Changes (reflected in this document)

- **Adversarial pass 7 (2026-07-19):** 6 findings (0C/2M/4m) all remediated via a **systematic propagation
  sweep** (12 grep hits across shards, incl. 4 security-audit snapshot annotations). BC-5.01.001 → v1.3,
  BC-3.04.001 → v1.3. Knock-ons folded in: C-12 now describes the **5-verb** write-block (comment/edit/move/
  assign/create) + fail-closed default everywhere; disposition-guard clarified as **heading-presence only**
  (≥2-hypotheses = LLM-soft deny-reason text, not enforced); assign/create deny is code-analysis-verified
  only (no dedicated positive BATS); HS-INDEX now v1.2/active. **[process-gap]** noted for the engine: a
  fan-out discipline / propagation-sweep step is a codification candidate so single-shard fixes propagate
  to all dependents in one pass.
- **Adversarial pass 6 (2026-07-19):** 6 findings (0C/2M/4m) remediated. **Opened DI-013** (MEDIUM-HIGH,
  pending): the unconditional `jr issue comment` deny forces a manual override on both comment-post steps
  (update-jira PC#4, investigate-event Stage 7) — **no marker override exists** (this corrected pass-5's
  wrong "override-path" claim). BC-3.02.001/3.03.001 → v1.3, BC-4.02.001 → v1.1, BC-5.01.001 → v1.2; co-fire
  deny-wins upgraded inferred → **VERIFIED vs hooks.json**; DI-004 false-pass now first-class **EC-009**;
  BC-3.03.001 "FULLY" qualified; holdout baseline stated **24 must-pass + 1 fix-target (HS-014)**.
- **Adversarial passes 4–5 (2026-07-19) — condensed:** pass 4 flipped EC-004 to DENY (BC-3.02.001, all-4-
  sections, no partial-save), populated all 13 BC `input-hash`es, made the per-artifact census derivation
  explicit (24−1+19+1=43), qualified "138/138 local" with the pwsh-skip caveat, and adjudicated the
  "PRs #11–#14 unmerged" finding a **FALSE POSITIVE** (verified merged at HEAD 0ec794a; stale snapshot).
  Pass 5 captured **ADV-0-501 aggregate hook semantics** (co-fire deny-wins; Stage 7 single-shot template →
  no partial-save; disposition-guard in-progress-allow is HOOK-ISOLATED) and normalized the 6 hook BCs to
  dual-file (.sh + .ps1) hashes.
- **Adversarial passes 1–3 (2026-07-19) — condensed:** pass 1 reconciled recovered-architecture C-1..C-24
  (hook-manifests = C-18; DI-008/DI-009 closed); pass 2 corrected the census to the authoritative 24-module
  aggregate (1/12/7/4) and restated require-review ≥95% as not-yet-demonstrated (git stats 41 commits / PRs
  #1–#14); pass 3 re-anchored the ~75–80% 6-hook kill-rate, defined session-greeting mutants (SM-8 killed /
  SM-8b LOW), set DI-012 to three uncontracted Iron-Law skills, and clarified DI-011 (LOW likelihood /
  HIGH consequence) + verified-acyclic DAG.
- **PR #14 (merged, 0ec794a):** read-only allowlist expanded (`jr issue changelog`, `jr assets search/view`,
  `jr --version`, 7 `--output json` forms); DI-010 resolved; BATS 130→138.
- **PR #13 (merged, f450d9f):** SEC-001..005 fixed; `jr issue comment` review-gated; require-review
  **fails closed** on unknown subcommands; MCP versions pinned; release.yml job-scoped perms; Semgrep pinned; BATS 129→130.
- **PR #12 (merged, da58b9a) + repo hardening:** `.gitignore` covers `.envrc`/`.env`/`.mcp.json`/`.claude/settings.local.json` (DI-001 resolved); branch protection on `main`; Semgrep in CI; SHA-pinned actions + job timeouts.
- v0.6.0→v0.9.0 trajectory: orchestrator companion, cross-platform hooks + session greeting,
  Jira-native metrics suite + recipes. Single contributor; strong release hygiene.

## 11. Boundary — Exists vs NEW work

**Exists (brownfield, in scope):** the full v0.9.0 plugin — 20 commands, 19 skills, 6 agents (+3 playbooks),
6 hook pairs + manifests, 10 data KBs, 6 templates, 15 checklists, 4 BATS suites; 3 CI workflows; 13
behavioral contracts recovered; module criticality classified; security audit dispositioned; 25 holdout
regression scenarios seeded.

**Not in scope / excluded:** `.factory/` (pipeline state on factory-artifacts orphan branch),
`.reference/jira-cli/` (reference material for the external `jr` dependency), `.git`, `.claude`.

**Contract-coverage boundary (pending human decision — DI-012):** the 13 BCs cover the
highest-blast-radius modules by design, not every Iron-Law-bearing skill. Known uncontracted surface:
**three Iron-Law-bearing skills with no BC** — `assess-priority` ("NO PRIORITY ASSIGNMENT WITHOUT
MULTI-FACTOR ASSESSMENT FIRST"), `create-advisory`, and `analyze-ticket-effort` — plus `read-ticket`
(no Iron Law, but the SEC-001 prompt-injection entry point). At the Phase 0 exit gate the human decides
whether to expand the BC set before Feature Mode or accept partial coverage as the baseline.

**Would be NEW work (no code today; candidates for Feature Mode):**
- Behavioral verification of skill Iron Laws (currently structural-only) — e.g., extracting pure
  sub-functions (activate JSON-merge, update-jira field validation, review scoring) to testable shims.
- Remediation of DI-004, DI-006, DI-007 (disposition-guard false-pass fix + pwsh-in-CI + enrichment
  investigation-branch / hook↔template sync / handoff-validator boundary). DI-005 is largely closed.
- A persisted/cryptographic review-approval marker (today it is spoofable LLM conversation state).
- **Comment-post override mechanism (DI-013, pending human decision):** the unconditional `jr issue comment`
  deny forces a manual permission-override on every legitimate comment post (update-jira PC#4, investigate-event
  Stage 7). Options: accept the friction, implement a marker-based override, or add a gated
  `post-review-comment` command.
- A `skills/secops-health/` skill (DI-002); JSON-Schema validation for `hooks.json` (DI-011).
- PSScriptAnalyzer for `.ps1`; system-prompt framing for untrusted ticket content (SEC-001 defense-in-depth).

## 12. Holdout Reference (index only — DO NOT load details)

25 regression-baseline scenarios (epic **BROWNFIELD-REGRESSION**), HS-001..HS-025, derived from 10 BCs
(2 CRITICAL, 7 HIGH, 1 MEDIUM). **Baseline split: 24 must-pass (current HEAD passes) + 1 fix-target**
(HS-014, `should-pass` / `fix_target: pending DI-004` — the disposition-guard false-pass; HEAD fails it by
design and it MUST NOT be counted in the must-pass gate until the DI-004 heading-anchored fix lands). Stored
under `.factory/holdout-scenarios/` and **holdout-protected**: must NEVER be shown to implementer/test-writer
agents (DF-009 information asymmetry). Distribution: require-review ×4, update-jira ×4, enrichment-completeness
×3, disposition-guard ×3, and 2 each for enrich-ticket/review-enrichment/adversarial-review-secops/investigate-event/activate,
1 for deactivate. Index metadata only: `.factory/holdout-scenarios/HS-INDEX.md`.

## 13. Source Map (all Phase 0 shards)

| Shard | Path |
|-------|------|
| Discovery | `.factory/phase-0-ingestion/project-discovery.md` |
| Architecture (+2 detail) | `.factory/phase-0-ingestion/recovered-architecture.md`, `arch-recov-api-surface.md`, `arch-recov-integrations.md` |
| Conventions | `.factory/phase-0-ingestion/conventions.md` |
| Behavioral contracts (13) | `.factory/phase-0-ingestion/behavioral-contracts/BC-*.md` |
| Verification gaps | `.factory/phase-0-ingestion/verification-gap-analysis.md` |
| Security audit | `.factory/phase-0-ingestion/security-audit.md` |
| Module criticality | `.factory/specs/module-criticality.md` |
| Holdout index (protected) | `.factory/holdout-scenarios/HS-INDEX.md` |
| Pipeline state | `.factory/STATE.md` |

## Quality Gate

- [x] Self-contained — a reader understands the project without opening sub-documents
- [x] Cross-references consistent — **now backed by an explicit pass-7 grep sweep** (12 hits resolved) across these pattern classes: BC version strings, DI-NNN ids/status, SM-NNN mutants, census counts (24/1-12-7-4, 43), hook-verb lists, kill-rate figures, and hooks.json citations. Verified: census 24 aggregate (1/12/7/4) incl. C-18 / 43 per-artifact (24−1+19+1); templates 6; hooks 6+6+2; BC-3.01.001 v1.6, BC-3.02.001/3.03.001 v1.3, BC-3.04.001 v1.3, BC-4.02.001 v1.2, BC-5.01.001 v1.3; DAG acyclic. Pass-7 GREEN on census/DAG/VP/counts/DI. (This checkbox was over-asserted before pass 7; the sweep is what now substantiates it.)
- [x] Restricted areas justified per row; DI mis-cite corrected (hook-wiring cites DI-011, not DI-009)
- [x] Context-budget estimate per architectural component + strategy recommendation
- [x] No orphaned references (DI-008/DI-009/DI-010 resolved; DI-011 + DI-012 + **DI-013** open; frontmatter DI range DI-001..DI-013)
- [x] Security posture reflects security-audit.md (post-remediation, SEC-001..005 MERGED; SM-3 resolved / SM-2 downgraded HIGH→LOW / SM-8 killed); C-12 write-block is 5-verb + fail-closed
- [x] BC drift check functional — all 13 BCs carry populated `input-hash`es; the 6 hook BCs use dual-file (.sh + .ps1) hashes; PRs #11–#14 verified merged at HEAD 0ec794a (pass-4 "unmerged" = FALSE POSITIVE, stale snapshot)
- [x] Recent changes (PR #12/#13/#14 + adversarial passes 1–7) surfaced; BC versions current (hook BCs v1.3, BC-4.02.001 v1.2, BC-5.01.001 v1.3); DI-013 opened
- [x] Mutation figures re-anchored — 6-hook aggregate **~75–80%** (vga §Mutation Testing Baseline → Surviving Mutants summary ~line 194); require-review ≥95% NOT yet demonstrated met; assign/create deny code-analysis-verified only
- [x] BC-3.03.001 "FULLY" qualified (declared-VP coverage; DI-004 defect = first-class EC-009, not fixed); disposition-guard is heading-presence only (≥2 hypotheses LLM-soft, unenforced); holdout baseline = 24 must-pass + 1 fix-target (HS-014)
- [x] Two pending Phase 0 gate decisions surfaced (DI-012 partial-BC-coverage; DI-013 comment-post override)

```yaml
pass: 0
step: "0f"
status: awaiting-phase-0-gate
revision: "1.7 — re-synced post adversarial pass 7 (grep-sweep verified)"
files_synthesized: 9
timestamp: 2026-07-19T00:00:00Z
open_gate_decision:
  - "DI-012 — expand BC set or accept partial coverage (human)"
  - "DI-013 — comment-post override: accept friction / marker mechanism / gated post-review-comment command (human)"
next_step: "phase-0 human approval gate (post-gate routing decided: PARK, not Phase 1)"
```

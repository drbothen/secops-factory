---
document_type: project-context
level: ops
version: "2.3"
status: phase-0-complete-remediated / awaiting-feature-request
producer: codebase-analyzer
timestamp: 2026-07-19T00:00:00Z
phase: 0
step: "0f"
project: secops-factory
source_state: "v0.9.0 + PRs #12–#17 (gitignore; SEC-001..005 f450d9f; allowlist/DI-010 0ec794a; SEC-009 write-block-precedence d304fa5; #16 secops-health skill + pwsh/PSScriptAnalyzer CI + hooks.json JSON-Schema; #17 disposition-guard & enrichment-completeness heading-anchored + assign/create & boundary BATS); PRs #1–#17 merged; BATS suite 165 @tests (hooks 59, skills 81, integration 11, parity 14); full drift remediation complete (13/14 DIs RESOLVED, DI-013 DEFERRED)"
inputs:
  - phase-0-ingestion/project-discovery.md
  - phase-0-ingestion/recovered-architecture.md (+ arch-recov-api-surface.md, arch-recov-integrations.md)
  - phase-0-ingestion/conventions.md
  - phase-0-ingestion/behavioral-contracts/*.md (17 BCs — 13 original + 4 new: BC-4.05.001, BC-4.06.001, BC-7.01.001, BC-8.01.001)
  - phase-0-ingestion/verification-gap-analysis.md
  - phase-0-ingestion/security-audit.md
  - specs/module-criticality.md
  - holdout-scenarios/HS-INDEX.md (index reference only — holdout-protected)
  - STATE.md (drift items DI-001..DI-014)
---

# Project Context — secops-factory

> **Capstone Phase 0 artifact.** THE scoping document Feature Mode phases load every cycle. Self-contained summary; deep detail lives in the linked shards (DF-021) — follow the links rather than duplicating. All paths absolute under `/Users/jmagady/Dev/secops-factory/`.

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
  → skills/<name>/SKILL.md (20 procedures) + agents/*.md (5 specialists)
    → data/ (10 KBs) · templates/ (6) · checklists/ (15)   [knowledge layer]
  ⟂ hooks/*.{sh,ps1} (6 pairs) + hooks.json(.windows)       [cross-cutting enforcement]
External boundary: jr CLI (required) · Perplexity MCP (recommended) · NVD/EPSS/KEV (fallback)
```

Full component catalog + machine-readable Component-Map YAML + dependency graph (**manually verified
acyclic — edge-by-edge, no DFS/cycle-detection tool was run** — the C-2→C-3 back-edge was removed,
orchestrator depends on skills not the reverse; the intentional DI-003 edge C-2→C-6, adversarial-review-secops
skill → review-convergence playbook, is explicit in the YAML and does not introduce a cycle) + data flows:
`.factory/phase-0-ingestion/recovered-architecture.md`
API surface (20 commands, dispatch table): `.factory/phase-0-ingestion/arch-recov-api-surface.md`
Integrations / DTU candidates: `.factory/phase-0-ingestion/arch-recov-integrations.md`

### Component criticality (from `specs/module-criticality.md`)

**Authoritative census — YAML component-map aggregate (C-1..C-24): 24 modules — 1 CRITICAL / 12 HIGH / 7 MEDIUM / 4 LOW.**
`update-jira` folds into the HIGH `skill-procedures` aggregate (C-2) at this granularity, so
require-review (C-12) is the sole CRITICAL; hook-manifests (C-18) is a counted HIGH member. A secondary
**per-artifact figure of 43 modules (2 CRITICAL / 16 HIGH / 21 MEDIUM / 4 LOW)** explodes C-2 into its 20
skills (hook-manifests is already its own C-18 in the aggregate, so the per-artifact total is unchanged);
at that granularity update-jira surfaces as a distinct CRITICAL skill. Derivation: **24 − 1 (C-2) + 20
(skills) = 43** — since PR #16 gave `secops-health` its own SKILL.md, there are now 20 skills 1:1 with the
20 commands; `secops-health` is one of the 20 exploded skills (promoted LOW→**MEDIUM** in module-criticality
v1.6), no longer a separate LOW carve-out.

| Tier | Modules (per-artifact view; aggregate note where it differs) |
|------|---------|
| **CRITICAL** | `hooks/require-review` (authorization gate on Jira writes — sole CRITICAL in the aggregate). `skills/update-jira` (last-mile writer to Jira record) is CRITICAL at sub-artifact granularity but folds into the HIGH C-2 aggregate. |
| **HIGH** | `hooks/enrichment-completeness`; `hooks/disposition-guard`; `hooks/hooks.json*` manifests (C-18); skills enrich-ticket, review-enrichment, adversarial-review-secops, investigate-event, activate; orchestrator (Morgan) + 3 workflow playbooks; agents security-analyst, security-reviewer; data KBs; test-suite + CI |
| **MEDIUM** | skill deactivate; agents metrics-analyst, osint-researcher, advisory-writer; templates; checklists; skills research-cve, read-ticket, assess-priority, map-attack, advisory + metrics families; jr CLI; Perplexity MCP |
| **LOW** | hooks bias-check-reminder, handoff-validator, session-greeting; command dispatch; secops-health |

Mutation/verification numeric targets apply to the **6 mutation-testable hooks** (input-partition
BATS analog): require-review ≥95%, enrichment-completeness ≥90%, disposition-guard ≥90%,
bias-check-reminder / handoff-validator / session-greeting ≥70%. **Post-remediation (PRs #13/#15/#17):
SM-1 (disposition-guard false-pass) and SM-2 (require-review assign/create) are both KILLED, SM-3/SM-3b
resolved** — the known surviving-mutant set on enforcement paths is closed. **Nonetheless the require-review
≥95% CRITICAL kill-rate target is NOT empirically demonstrated met**: no per-hook mutation run has executed;
coverage gains raise confidence but the numeric target stays open until Phase 6 / Feature Mode mutation
testing (kept honest despite the coverage improvements). All other modules are declarative/LLM/static —
tier governs review depth, not a numeric kill-rate.

## 3. Context Budget

**Strategy: component-scoped** (total plugin source > 50K tokens), with **Extended ToC** for `data/`.
Load per-component, not whole-repo. Chunk the large KBs (500-line Read offsets).

| Component | Approx LOC | Est. tokens | Load note |
|-----------|-----------|-------------|-----------|
| commands/ (20) | ~160 | ~1.5K | trivially loadable |
| skills/ (20 SKILL.md) | ~1,500 | ~15K | load per-skill |
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
- **Commands:** thin wrappers — body is exactly ``Use the `secops-factory <name>` skill via the Skill tool.`` Every command has a matching skill dir (the former `secops-health` exception was closed in PR #16 / DI-002).
- **Paths:** always `${CLAUDE_PLUGIN_ROOT}/` — never hardcoded.
- **Hooks:** every `.sh` has a byte-parity `.ps1` sibling; exit 0 for all business decisions (exit 1 only if `jq` missing). **Fail-open historically**, but see the require-review change in §5/§8.
- **Agents:** frontmatter `name/description/model/color/tools`; security-reviewer (Riley) is opus + read-only (no Write tool).
- **Release:** Conventional Commits, **no Co-Authored-By / AI attribution**; squash-merge via PR; tag `vX.Y.Z` after merge; triple version lock (plugin.json + marketplace.json + tag); Keep-a-Changelog.

One residual style ambiguity: `secops(<scope>):` vs `feat(<scope>):` commit prefix (the `secops-health`
command-without-skill anomaly was resolved in PR #16 / DI-002).

Detail + CONV-001..020 YAML: `.factory/phase-0-ingestion/conventions.md`

## 5. Behavioral Contracts (17 recovered — index)

Contract files: `.factory/phase-0-ingestion/behavioral-contracts/<id>.md`

| BC | Subject | Rev | Tier | Verification |
|----|---------|-----|------|--------------|
| BC-3.01.001 | require-review hook — Jira field-modification gate | **v1.10** | CRITICAL | write-block FIRST (Inv #5, PR #15); comment-deny + fail-closed (PR #13); allowlist/DI-010 (PR #14); **assign/create positive-deny BATS + SM-2 KILLED (PR #17)** |
| BC-3.02.001 | enrichment-completeness hook — section completeness gate | **v1.6** | HIGH | EC-004 = DENY (all 4 sections, no partial-save); **DI-014 RESOLVED — heading-anchored (PR #17)** |
| BC-3.03.001 | disposition-guard hook — Alternatives-required gate | **v1.5** | HIGH | **FULLY — DI-004 RESOLVED (heading-anchored, PR #17); SM-1 KILLED; HS-014 promoted to must-pass** |
| BC-3.04.001 | bias-check-reminder hook — PostToolUse advisory | **v1.4** | LOW | PARTIAL |
| BC-3.05.001 | handoff-validator hook — SubagentStop empty-output guard | **v1.4** | LOW | **39/40 boundary + missing-result tests added (PR #17, DI-007)** |
| BC-3.06.001 | session-greeting hook — activation-gated SessionStart banner | **v1.4** | LOW | FULLY (core); **jq-fallback + .ps1 empty-catch fixed (PR #16, DI-006)** |
| BC-4.01.001 | enrich-ticket skill — 8-stage CVE enrichment | v1.0 | HIGH | STRUCTURAL-ONLY |
| BC-4.02.001 | update-jira skill — review-gated Jira field update | **v1.3** | CRITICAL | STRUCTURAL-ONLY — comment-post step (PC#4) needs human override (**DI-013 DEFERRED**) |
| BC-4.03.001 | review-enrichment skill — fresh-context quality review | v1.0 | HIGH | STRUCTURAL-ONLY (strongest) |
| BC-4.04.001 | adversarial-review-secops skill — convergence loop | v1.0 | HIGH | STRUCTURAL-ONLY |
| BC-4.05.001 | assess-priority skill — 6-factor vulnerability priority calculation | v1.0 | MEDIUM | STRUCTURAL-ONLY — **new (DI-012 expansion)** |
| BC-4.06.001 | read-ticket skill — Jira ticket read / SEC-001 prompt-injection entry point | v1.0 | MEDIUM | STRUCTURAL-ONLY — **new (DI-012 expansion)**; SEC-001 injection surface documented; no Iron Law |
| BC-5.01.001 | investigate-event skill — 7-stage investigation | **v1.4** | HIGH | STRUCTURAL-ONLY — Stage 7 comment-post needs human override (**DI-013 DEFERRED**) |
| BC-6.01.001 | activate skill — per-project activation lifecycle | v1.0 | HIGH | STRUCTURAL-ONLY |
| BC-6.01.002 | deactivate skill — per-project deactivation | v1.0 | MEDIUM | STRUCTURAL-ONLY |
| BC-7.01.001 | create-advisory skill — source-verified advisory authoring | v1.0 | MEDIUM | STRUCTURAL-ONLY — **new (DI-012 expansion)**; disable-model-invocation: true; advisory-pipeline subsystem |
| BC-8.01.001 | analyze-ticket-effort skill — session-reconstruction effort measurement | v1.0 | MEDIUM | STRUCTURAL-ONLY — **new (DI-012 expansion)**; metrics-pipeline subsystem |

> **BC-3.01.001 (v1.10) require-review — CRITICAL gate.** At HEAD (PRs #13/#14/#15/#17): the **write-block
> if-block is evaluated BEFORE the read-only allowlist (Inv #5)** — the PR #15 fix for the SEC-009 bypass;
> `jr issue comment/edit/move/assign/create` (+ `--output json` forms) deny with fail-closed default for
> unknown subcommands; VP-HOOK-020..023. **PR #17 added assign/create positive-deny BATS → SM-2 KILLED.**
> Source cited by construct name; BATS by @test name (churn-resistant).

> **BC-3.02.001 (v1.6) + BC-3.03.001 (v1.5) — aggregate hook semantics.** EC-004 is **DENY**: an
> `investigation-*` file must contain **all four** sections before enrichment-completeness saves (no
> partial-save). Both completeness hooks **co-fire on `PreToolUse/Write` (VERIFIED vs hooks.json), deny from
> either wins**; Stage 7 generates once from a complete template, so disposition-guard's in-progress-allow
> (PC#2/EC-003) is **HOOK-ISOLATED**. **DI-004 (disposition-guard) and DI-014 (enrichment-completeness) are
> both RESOLVED (PR #17)** — the unanchored `grep -qF` substring idiom is replaced by **section-heading-anchored**
> matching, so negating body text ("No Alternatives Considered…") no longer passes; **SM-1 KILLED**, HS-014
> promoted to must-pass. (disposition-guard still enforces heading presence only — alternative *quality* is
> validated by review-enrichment, not this hook.)

## 6. Verification Posture

**Roll-up (original 13 BCs): Fully 2 / Partially 11 / Un-verified 0**; the **4 new skill BCs**
(BC-4.05/4.06/7.01/8.01) are STRUCTURAL-ONLY. BC-3.03.001 is now **FULLY with the DI-004 defect actually
fixed** (PR #17 heading-anchored), not merely documented. **165/165 BATS pass** (hooks 59, skills 81,
integration 11, parity 14) — **DI-006 RESOLVED (PR #16):** CI now installs+asserts `pwsh` and runs
PSScriptAnalyzer, so `.ps1` hooks are validated (the fix surfaced+closed 2 empty-catch silent-failures);
parity no longer skips silently.

**Anchor convention (ADV-0-901/A01/pass-11):** across all hook BCs + conventions.md the hook subsystem now
cites **churn-resistant references** — require-review.sh by **construct name** and BATS by **@test name** —
rather than line-number-only anchors (which churned across PR #13/#14/#15). Normative sections carry **zero
line-number-only anchors**; a residual `hooks.bats:NN` trailing a @test name is only a secondary locator. Root
cause retired.

**The headline is the verification asymmetry:** the 6 deterministic **hooks** are genuinely
behaviorally tested; the 7 LLM-executed **skills** are **structural-only** — BATS proves Iron Law text,
Announce-at-Start, Red-Flag counts, `${CLAUDE_PLUGIN_ROOT}` reference portability, referenced-file
existence, and agent frontmatter/tool constraints, but **no executable check confirms skills enforce
their preconditions/postconditions/invariants at runtime** (that is LLM behavior). Structural gates catch
deletion/drift but are not behavioral verification of the Iron Laws.

Manual mutation probe against the **6-hook mutation-testable set**: aggregate kill-rate **~90–95%
(post-PR-17)** — verification-gap-analysis.md §Mutation Testing Baseline → post-PR-17 kill-rate; the earlier
**~75–80% was the post-PR-15 figure, now superseded**. **Post-remediation mutant status — all
previously-surviving enforcement mutants CLOSED:** SM-1 (disposition-guard false-pass)
KILLED (PR #17, DI-004); SM-2 (assign/create) KILLED (PR #17, DI-005); SM-3/SM-3b (fail-open + SEC-009
precedence) resolved (PR #13/#15); SM-4 enrichment investigation branch + handoff 39/40 boundary covered
(PR #17, DI-007); SM-8 killed; only SM-8b (session-greeting `jq`-fallback, LOW) remains. **Even so, the
require-review ≥95% CRITICAL kill-rate is NOT empirically demonstrated** — no per-hook mutation run has been
executed; the coverage gains raise confidence but the numeric target is honestly still open until Feature
Mode. shellcheck clean on `.sh`; `.ps1` now covered by PSScriptAnalyzer (PR #16).

Detail + per-BC matrix + remediation plan: `.factory/phase-0-ingestion/verification-gap-analysis.md`

## 7. Security Posture (post-fix)

**Risk posture: LOW** for the threat model (analyst workstation, not internet-facing; adversary = anyone
with Jira project write access). Human disposition gate **PASSED** (2026-07-19). Original-audit findings:
0 critical / 0 high / 1 medium / 4 low / 3 info — **plus one post-audit CRITICAL (SEC-009), now RESOLVED.**

> **⚠ SEC-009 (CRITICAL-at-discovery, RESOLVED PR #15 d304fa5) — a REAL shipped-code bypass, not a doc defect.**
> VSDD adversarial review (ADV-0-801) found the shipped `require-review` gate evaluated the **read-only
> allowlist BEFORE the write-block with unanchored substring matching**, so any write command carrying a
> read-only token was allowed **without review** (`jr issue edit KEY --summary "see jr board"` matched the
> `jr board` token) — bypassing all field-mutation verbs and defeating the SEC-001 comment gate. **Fixed in
> PR #15 (d304fa5):** write-block reordered **first** (Invariant #5), `--output json` write forms added,
> trailing-space guard on `comment`/`comments`, 12 red→green BATS. Highest-severity finding of the ingestion;
> hard-completes SEC-001.

**SEC-001..005 FIXED and merged (PR #13, f450d9f):** SEC-001 (MEDIUM, comment-path prompt injection) —
review-gated by PR #13 but **fully gated only after PR #15's precedence fix** (see SEC-009); SEC-002 (fail-open
→ **fail-closed**); SEC-003 (MCP versions pinned); SEC-004 (`release.yml` perms job-scoped); SEC-005 (Semgrep
pinned 1.170.0 + health-check). All LOW except SEC-001.

SEC-006 (jr CLI unversioned) and SEC-007 (Tavily key in URL) **ACCEPTED** (info; review next release).
SEC-008 / DI-001 **RESOLVED** (PR #12): `.envrc`/`.mcp.json`/`.env`/`.claude/settings.local.json`
gitignored; confirmed never committed; no credentials in git history.
**SEC-009 (CRITICAL) RESOLVED** (PR #15, d304fa5) — see the boxed note above.
Now also active: **branch protection on `main`** + **Semgrep in CI**. **PR #16 hardening:** `pwsh` installed +
asserted in CI and **PSScriptAnalyzer** lint added — the `.ps1` hooks are now validated, which **surfaced and
closed 2 empty-catch silent-failures**; `hooks.json` now has a **JSON-Schema + CI validation** (DI-011).
**PR #17:** disposition-guard + enrichment-completeness heading-anchored (DI-004/DI-014), assign/create
positive-deny + boundary tests (DI-005/DI-007).

Detail + all findings/dispositions: `.factory/phase-0-ingestion/security-audit.md`

## 8. Drift Register — FINAL STATE (13 of 14 RESOLVED, 1 DEFERRED, 0 open)

| ID | Item | Sev | Final state |
|----|------|-----|-------------|
| DI-001 | Live keys in untracked non-gitignored `.envrc`/`.mcp.json` | HIGH | **RESOLVED** (PR #12 — gitignore) |
| DI-002 | `secops-health` command has no skill dir (CI special-case) | LOW | **RESOLVED** (PR #16 — `secops-health/SKILL.md` created; CI special-case removed) |
| DI-003 | `adversarial-review-secops` references the orchestrator playbook | LOW | **RESOLVED — accepted by design** (Stream D — intentional single-source-of-truth; C-2→C-6 edge acyclic, documented in YAML map) |
| DI-004 | disposition-guard substring false-pass (SM-1) | HIGH | **RESOLVED** (PR #17 — heading-anchored; SM-1 KILLED; HS-014 promoted to must-pass) |
| DI-005 | require-review assign/create paths untested | HIGH | **RESOLVED** (PR #17 — assign/create positive-deny BATS; SM-2 killed) |
| DI-006 | pwsh parity skips silently; no `.ps1` static analysis | HIGH | **RESOLVED** (PR #16 — pwsh installed+asserted in CI + PSScriptAnalyzer; **surfaced+fixed 2 empty-catch silent-failures**) |
| DI-007 | enrichment investigation branch / hook↔template sync / handoff 39/40 boundary | MEDIUM | **RESOLVED** (PR #17 — branch coverage, hook↔template sync guard, boundary tests) |
| DI-008 | Component-Map numbering diverged (prose vs YAML) | LOW | **RESOLVED** (pass-1/2 reconciliation — C-1..C-24 agree) |
| DI-009 | hook-manifests absent from YAML component map | HIGH | **RESOLVED** (pass-2 — added as C-18 HIGH) |
| DI-010 | SEC-002 fail-closed regression: `jr issue changelog` wrongly denied | HIGH | **RESOLVED** (PR #14 — allowlist + `--output json` families) |
| DI-011 | `hooks.json` validated by `jq .` only, no JSON-Schema | LOW (consequence HIGH) | **RESOLVED** (PR #16 — JSON-Schema + CI validation) |
| DI-012 | 3 Iron-Law skills + read-ticket uncontracted | MEDIUM | **RESOLVED** (Stream D — 4 new BCs: BC-4.05/4.06/7.01/8.01; BC total 13→17) |
| DI-013 | Comment-post steps need a manual permission-override every time (no marker override) | MEDIUM-HIGH | **DEFERRED to first Feature Mode cycle** (human decision: deferred — accept friction / marker mechanism / gated `post-review-comment` command) |
| DI-014 | enrichment-completeness same unanchored `grep -qF` idiom as DI-004 | LOW | **RESOLVED** (PR #17 — heading-anchored) |

**Zero open drift items.** All remediation landed via PRs #11–#17. The sole non-resolved item, **DI-013**, is
a human-approved **deferral** (comment-gate friction) carried into the first Feature Mode cycle, not an open gap.

## 9. Restricted Areas (require explicit human review before change)

| Area | Path | Justification |
|------|------|---------------|
| Authorization gate | `plugins/secops-factory/hooks/require-review.{sh,ps1}` | CRITICAL — the only hard gate on Jira system-of-record writes; changed three times recently (PR #13 comment-deny + fail-closed; PR #14 allowlist; **PR #15 write-block-first ordering, closing the SEC-009 bypass**); the ADV-0-007 `--output json` defense-in-depth item is now RESOLVED. Assurance improved but the ≥95% CRITICAL kill-rate target is not yet demonstrated met, and any change re-touches the sole authz gate |
| Jira writer | `plugins/secops-factory/skills/update-jira/SKILL.md` | CRITICAL — last-mile writer; review-approval marker is LLM-soft and spoofable; only the require-review hook stands between it and record corruption |
| Injection entry point | `plugins/secops-factory/skills/read-ticket/SKILL.md` | SEC-001 surface — ingests Jira ticket bodies verbatim; now contracted (BC-4.06.001); mitigation is defense-in-depth framing |
| Hook wiring | `plugins/secops-factory/hooks/hooks.json`, `hooks.json.windows` | A wrong matcher silently de-wires the CRITICAL require-review gate — now guarded by JSON-Schema + CI validation (DI-011 RESOLVED, PR #16) |
| Anti-bias gate | `plugins/secops-factory/hooks/disposition-guard.{sh,ps1}` | Anti-confirmation-bias quality gate; false-pass fixed (DI-004 RESOLVED, heading-anchored, PR #17) — still review-critical on change |
| User-config writer | `plugins/secops-factory/skills/activate/SKILL.md` | JSON-merge into `settings.local.json` (never-clobber-corrupt path unexecuted) — invalid-state risk on local user config |
| Release/CI + credentials | `.github/workflows/*.yml`, `.envrc`, `.mcp.json` | Supply-chain / privilege boundary; credentials local-only (gitignored) — never commit |

## 10. Recent Changes (reflected in this document)

- **Onboarding + drift remediation (2026-07-19):** the capstone **converged after 13 adversarial review
  passes + full drift remediation, landed via PRs #11–#17** (repo/CI hardening; SEC-001..005 + the SEC-009
  CRITICAL write-block-precedence bypass fixed; read-only allowlist expansion; secops-health skill;
  pwsh/PSScriptAnalyzer CI; hooks.json JSON-Schema; disposition-guard & enrichment-completeness
  heading-anchored; assign/create + boundary BATS; 4 new BCs). Net: BC 13→17, tests 129→**165**, holdouts
  25→**34**, SM-1/SM-2/SM-3/SM-3b/SM-4/SM-8 all killed/resolved, 13/14 DIs RESOLVED (DI-013 DEFERRED).
  Per-pass detail lives in the shard revision histories.

## 11. Boundary — Exists vs NEW work

**Exists (brownfield, in scope):** the full v0.9.0 plugin — 20 commands, 20 skills (1:1 with commands), 6 agents (+3 playbooks),
6 hook pairs + manifests, 10 data KBs, 6 templates, 15 checklists, 4 BATS suites (**165 @tests**); 3 CI
workflows; **17 behavioral contracts**; module criticality classified; security audit dispositioned (incl.
SEC-009 CRITICAL, fixed PR #15); **34 holdout scenarios (all must-pass)**. All 4 new BCs (assess-priority,
read-ticket/SEC-001 surface, create-advisory [advisory-pipeline], analyze-ticket-effort [metrics-pipeline])
are STRUCTURAL-ONLY. **All 13 remediable drift items are RESOLVED; DI-013 is a human-approved deferral.**

**Not in scope / excluded:** `.factory/` (pipeline state on factory-artifacts orphan branch),
`.reference/jira-cli/` (reference material for the external `jr` dependency), `.git`, `.claude`.

**Would be NEW work (no code today; candidates for Feature Mode):**
- **Behavioral verification of skill Iron Laws** (all 11 skill BCs are structural-only) — extract pure
  sub-functions (activate JSON-merge, update-jira field validation, review scoring) to testable shims.
- **An empirical mutation run** to demonstrate the require-review ≥95% CRITICAL kill-rate (coverage is in
  place; the number is not yet measured).
- **DI-013** comment-post override (deferred): a persisted/cryptographic review-approval marker, or a gated
  `post-review-comment` command, vs. accepting the friction.
- Holdout scenarios extending coverage to the 4 new BCs; system-prompt framing for untrusted ticket content
  (SEC-001 defense-in-depth).

## 12. Holdout Reference (index only — DO NOT load details)

**34** regression-baseline scenarios (epic **BROWNFIELD-REGRESSION**, HS-INDEX **v1.6**), HS-001..HS-034 —
**all must-pass, 0 fix-targets** (HS-014 was promoted to must-pass once the DI-004 heading-anchored fix
landed in PR #17). Coverage extended to the 4 new BCs; notable additions include **HS-026** (SEC-009
require-review bypass guard) and **HS-029** (read-ticket SEC-001 prompt-injection guard). **Holdout-protected**
(DF-009): must NEVER be shown to implementer/test-writer agents. Index metadata only:
`.factory/holdout-scenarios/HS-INDEX.md`.

## 13. Source Map (all Phase 0 shards)

| Shard | Path |
|-------|------|
| Discovery | `.factory/phase-0-ingestion/project-discovery.md` |
| Architecture (+2 detail) | `.factory/phase-0-ingestion/recovered-architecture.md`, `arch-recov-api-surface.md`, `arch-recov-integrations.md` |
| Conventions | `.factory/phase-0-ingestion/conventions.md` |
| Behavioral contracts (17) | `.factory/phase-0-ingestion/behavioral-contracts/BC-*.md` |
| Verification gaps | `.factory/phase-0-ingestion/verification-gap-analysis.md` |
| Security audit | `.factory/phase-0-ingestion/security-audit.md` |
| Module criticality | `.factory/specs/module-criticality.md` |
| Holdout index (protected) | `.factory/holdout-scenarios/HS-INDEX.md` |
| Pipeline state | `.factory/STATE.md` |

## Quality Gate

- [x] Self-contained — a reader understands the project without opening sub-documents
- [x] Cross-references consistent (v2.0): census 24 aggregate (1/12/7/4) incl. C-18 / 43 per-artifact; templates 6; hooks 6+6+2; DAG manually-verified acyclic; **17 BCs**; **165 @tests** (hooks 59, skills 81, integration 11, parity 14); PRs #1–#17 merged. Hook BC versions: BC-3.01.001 **v1.10**, BC-3.02.001 **v1.6**, BC-3.03.001 **v1.5**, BC-3.04.001 v1.4, BC-3.05.001 **v1.4**, BC-3.06.001 **v1.4**; BC-4.02.001 v1.3, BC-5.01.001 v1.4; 4 new BCs v1.0.
- [x] Restricted areas justified per row (DI-004/DI-011 fixes reflected; modules stay review-critical)
- [x] Context-budget estimate per architectural component + strategy recommendation
- [x] **Drift register FINAL: 13/14 RESOLVED, DI-013 DEFERRED, 0 open**; frontmatter DI range DI-001..DI-014
- [x] Security posture reflects security-audit.md — 0C/0H/1M/4L/3I + SEC-009 CRITICAL RESOLVED (PR #15); PRs #16/#17 hardening (pwsh+PSScriptAnalyzer surfaced/fixed 2 empty-catch failures; hooks.json JSON-Schema)
- [x] Mutation: SM-1/SM-2/SM-3/SM-3b/SM-4/SM-8 killed/resolved; **require-review ≥95% still NOT empirically demonstrated (no mutation run) — kept honest despite coverage gains**
- [x] Holdout **34 = all must-pass, 0 fix-targets** (HS-014 promoted; HS-026 SEC-009 guard; HS-029 read-ticket SEC-001 guard)
- [x] Status = phase-0-complete-remediated / awaiting-feature-request (PARK point; human-approved gate)

```yaml
pass: 0
step: "0f"
status: phase-0-complete-remediated / awaiting-feature-request
revision: "2.3 — mutation kill-rate updated to ~90–95% post-PR-17 (~75–80% was post-PR-15, superseded); HS-INDEX v1.6. 2.2 — per-artifact distribution corrected to 2/16/21/4 (secops-health promoted LOW→MEDIUM, module-criticality v1.6). 2.1 — skill count 19→20 (secops-health SKILL.md, PR #16 / DI-002). 2.0 — onboarding + full drift remediation (PRs #11–#17; 13/14 DIs RESOLVED, DI-013 DEFERRED; BC 13→17; tests →165; holdouts →34)"
files_synthesized: 13
timestamp: 2026-07-19T00:00:00Z
open_gate_decision:
  - "DI-013 (DEFERRED to first Feature Mode cycle) — comment-post override: accept friction / marker mechanism / gated post-review-comment command"
next_step: "PARK — awaiting feature-request (human-approved Phase 0 gate + park)"
```

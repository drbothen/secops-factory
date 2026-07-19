---
document_type: module-criticality
level: L1
version: "1.4"
status: active
producer: formal-verifier
phase: "0e.5"
project: secops-factory
date: "2026-07-19"
inputs:
  - phase-0-ingestion/recovered-architecture.md
  - phase-0-ingestion/behavioral-contracts/*.md
  - phase-0-ingestion/verification-gap-analysis.md
  - phase-0-ingestion/security-audit.md
  - phase-0-ingestion/project-discovery.md
classification_guide: DF-004
census_granularity: "YAML component-map aggregate (C-1..C-24)"
modules_classified: 24
critical: 1
high: 12
medium: 7
low: 4
submodule_census: "per-artifact: 43 modules — 2 CRITICAL / 16 HIGH / 20 MEDIUM / 5 LOW"
version_history:
  - "1.0 (2026-07-19) — initial Step 0e.5 classification"
  - "1.1 (2026-07-19) — re-sync 1, post PR #13/#14 (ADV-0-004 census reconciliation, ADV-0-003 staleness, ADV-0-010 session-greeting numeric target)"
  - "1.2 (2026-07-19) — re-sync 2, post adversarial pass 2 (ADV-0-202 C-ID realign to C-1..C-24 incl. C-18 hook-manifests, ADV-0-203 architect note resolved, ADV-0-205 require-review overclaim)"
  - "1.3 (2026-07-19) — re-sync 3 + pass-4 finalization, post adversarial passes 3–4 (ADV-0-301 kill-rate figure/anchor, ADV-0-302 6-hook scope; ADV-0-404 secops-health double-count, ADV-0-405 hook line refs verified, ADV-0-406 vga anchor, ADV-0-408 versioning); status → active (capstone-authoritative)"
  - "1.4 (2026-07-19) — re-issue post PR #15 (d304fa5), adversarial pass 9 (ADV-0-901, ADV-0-903): added SEC-009 (allowlist-precedence bypass, CRITICAL, RESOLVED PR #15) to the Resolved table and rewrote the require-review narrative to acknowledge the gate was fully bypassable until PR #15; replaced churned require-review.sh line-number citations with construct-name references; test count 138 → 150 (hooks 44 + skills 81 + integration 11 + parity 14)"
---

# Module Criticality Classification — secops-factory v0.9.0

> **Reconciliation note — re-issued 2026-07-19 (5th pass, post adversarial pass 9, post PR #15). Version 1.4, status active.**
> First re-sync (post PR #13 f450d9f / PR #14 0ec794a): census recounted to one
> authoritative granularity (ADV-0-004); open items refreshed against merged fixes,
> suite green (ADV-0-003); session-greeting numeric target stated (ADV-0-010).
> Second re-sync (post adversarial pass 2): C-IDs realigned to the pass-1 architecture
> reconciliation — hook-manifests is now **C-18 (HIGH)** and the tail renumbered to
> **C-24**; authoritative aggregate is now **24 modules — 1 CRITICAL / 12 HIGH / 7
> MEDIUM / 4 LOW** (ADV-0-202); architect note #1 marked resolved (ADV-0-203);
> require-review ≥95% target restated as NOT-yet-demonstrated (ADV-0-205).
> Third re-sync (post adversarial pass 3): pure-hook-set aggregate kill rate updated to
> the current **~75–80%** (post-remediation), with ~55–65% labelled the superseded
> pre-PR-13 baseline (ADV-0-301); scope note corrected to **6 mutation-testable hooks**
> (5 pure + session-greeting), consistent with the ADV-0-010 decision (ADV-0-302).
> Fourth re-sync (post adversarial pass 4): fixed per-artifact census double-count of
> secops-health — command-dispatch relabelled "19 stubs", secops-health promoted as a
> distinct LOW module, explicit derivation `24 − 1 + 19 + 1 = 43` added (ADV-0-404);
> kill-rate citations re-anchored to a section-name reference (vga §Mutation Testing
> Baseline, ~line 194) to stop line-number churn (ADV-0-406); require-review.sh line
> refs verified against source (ADV-0-405); frontmatter bumped to v1.3 / status active
> with a version-history block (ADV-0-408).
> Fifth re-issue (post PR #15 d304fa5, adversarial pass 9): added **SEC-009**
> (allowlist-precedence bypass — CRITICAL, gate was fully bypassable, RESOLVED PR #15)
> to the Resolved table and rewrote the require-review narrative accordingly
> (ADV-0-901/ADV-0-903); replaced now-churned require-review.sh line-number citations
> with **construct-name references** (write-block if-block / fail-closed catch-all /
> write-verb patterns) since line numbers inverted across PR #13/#14/#15; test count
> updated **138 → 150** (hooks 44 + skills 81 + integration 11 + parity 14).

> Step 0e.5 (Module Criticality Classification). Agent: formal-verifier.
> Classifies every Component-Map module into a DF-004 criticality tier, driving
> mutation kill-rate (and, for this declarative plugin, input-partition BATS)
> targets in later phases.

## Authoritative census (read this first)

Two granularities exist; **the YAML component-map aggregate is authoritative** and
is what the capstone must sync to. The finer per-artifact view is a secondary figure.

| Granularity | Count | CRITICAL | HIGH | MEDIUM | LOW | Notes |
|-------------|-------|----------|------|--------|-----|-------|
| **Authoritative — YAML component-map aggregate (C-1..C-24)** | **24** | **1** | **12** | **7** | **4** | update-jira is folded into the C-2 `skill-procedures` aggregate (HIGH), so only require-review (C-12) is CRITICAL at this level. Includes hook-manifests (C-18, HIGH) added in the pass-1 architecture reconciliation. |
| Secondary — per-artifact / sub-module | 43 | 2 | 16 | 20 | 5 | Explodes C-2 into 19 skills; here update-jira surfaces as a distinct CRITICAL. |

The earlier arithmetic mixed these two views (frontmatter counted 24 with a 2/12/7/5
that summed to 26; the Distribution HIGH/MEDIUM rows quoted per-artifact members
against aggregate labels). Both censuses below now sum correctly and are internally
consistent.

## Scope note (declarative plugin)

secops-factory is a **declarative Claude Code plugin** — no compiled/interpreted
production code. Conventional mutation testing (cargo-mutants/mutmut/stryker)
does not apply. Only the **6 mutation-testable Bash/PowerShell hooks** carry a
numeric target — the 5 pure hooks plus session-greeting, whose gate/compare logic
is a pure, enumerable sub-function (ADV-0-010 decision) — exercised
via the near-exhaustive input-partition BATS analog established in the
verification-gap-analysis. For LLM-executed skills, orchestration playbooks,
agents, and static knowledge/templates/checklists, the DF-004 tier still governs
**verification rigor** (structural + input-partition BATS coverage, hook↔template
sync gates, static analysis) even though a numeric mutation kill-rate is N/A.
Where a tier column below reads "N/A (declarative)", the tier still sets the bar
for review depth and the executable-check density expected of that module.

## Classification method (DF-004)

Every module defaulted to MEDIUM, then adjusted by four blast-radius signals from
the Phase-0 artifacts:

1. **Failure blast radius** — can it corrupt the Jira system of record, silently
   pass a bad quality gate, or corrupt local user state?
2. **Security exposure** — prompt-injection paths and fail-open semantics per the
   security audit (SEC-001..005).
3. **Verification coverage** — hooks are behaviorally tested; skills are
   structural-only (verification-gap-analysis).
4. **Change frequency** — hot files from git-history discovery.

The domain analogs of the DF-004 CRITICAL triggers in this product are:
**authorization = the require-review gate on Jira writes**; **invalid state =
corruption of the authoritative Jira record or of the user's `settings.local.json`**.

## Tier → target table (DF-004)

| Tier | Mutation kill-rate target | Declarative analog (this plugin) |
|------|--------------------------|----------------------------------|
| CRITICAL | ≥ 95% | Near-exhaustive input-partition BATS on the pure hook; behavioral test of every deny/allow branch + fail-mode. LLM modules: deepest review + independent infra gate. |
| HIGH | ≥ 90% | All declared branches + boundaries covered; hook↔template sync asserted. |
| MEDIUM | ≥ 80% | Standard structural + happy/edge partition coverage. |
| LOW | ≥ 70% | Presence/parity checks; no behavioral guarantee required. |

---

## Criticality Ranking (one-line rationale each)

### Enforcement hooks (deterministic gates — highest blast radius)

| Module | Path | Tier | Mut. target | Rationale |
|--------|------|------|-------------|-----------|
| require-review hook | `hooks/require-review.{sh,ps1}` | **CRITICAL** | ≥95% (not yet demonstrated) | The authorization gate on the Jira system of record — blocks `jr issue comment/edit/move/assign/create` and **fail-closes (default-deny) on unrecognized subcommands** (BC-3.01.001). **Assurance history is non-monotonic and must not be overstated:** PR #13/#14 resolved SEC-001 (comment path denied) and SEC-002/SM-3 (fail-open → fail-closed), but the gate remained **FULLY BYPASSABLE until PR #15** — the read-only allowlist was evaluated *before* the write-block, so any write command carrying an embedded allowlist token (e.g., `jr issue edit KEY --summary "see jr board"`) matched the allowlist and was allowed, silently **defeating SEC-001** (SEC-009 / ADV-0-801, CRITICAL). **PR #15 (d304fa5)** reorders the write-block ahead of the allowlist and adds 12 red-first BATS vectors; the SM-2 "delete assign/create from blocklist" mutant is behaviorally inert via the fail-closed catch-all. **The ≥95% numeric target is NOT yet demonstrated met** — no per-hook mutation run has executed; it remains open until Phase 6 / Feature Mode. require-review's individual kill rate is unmeasured (the current **~75–80%** figure in verification-gap-analysis.md §Mutation Testing Baseline → Surviving Mutants summary (~line 194) is the post-remediation aggregate across the 6-hook mutation-testable set, not this hook alone; the ~55–65% figure is the original pre-PR-13 baseline, now superseded). Suite 150/150 green, shellcheck clean. |
| enrichment-completeness hook | `hooks/enrichment-completeness.{sh,ps1}` | **HIGH** | ≥90% | Enforces the required-section completeness invariant on saved enrichment/investigation docs (BC-3.02.001); the entire investigation 4-section branch is untested (SM-4) and hook-hardcoded section lists can drift from templates (GAP-5). Blast radius bounded to local doc quality, not the authoritative record. |
| disposition-guard hook | `hooks/disposition-guard.{sh,ps1}` | **HIGH** | ≥90% | Anti-confirmation-bias invariant gate requiring "Alternatives Considered" on dispositions (BC-3.03.001); **DI-004 confirmed false-pass (SM-1)** — a negating sentence containing the phrase defeats the substring match, silently bypassing a security-analysis quality gate. Effective assurance is currently below tier until the heading-anchored fix lands (GAP-1). |
| bias-check-reminder hook | `hooks/bias-check-reminder.{sh,ps1}` | **LOW** | ≥70% | Non-blocking PostToolUse advisory that injects a cognitive-bias reminder to stderr (BC-3.04.001); cannot corrupt state or block any operation. |
| handoff-validator hook | `hooks/handoff-validator.{sh,ps1}` | **LOW** | ≥70% | SubagentStop hook — advisory only, structurally cannot block (per security audit); emits a "suspiciously short" note (BC-3.05.001). No enforcement blast radius. |
| session-greeting hook | `hooks/session-greeting.{sh,ps1}` | **LOW** | **≥70% (numeric)** | Cosmetic SessionStart welcome banner, activation-gated, fail-open on corrupt config (BC-3.06.001). Purely presentational. **This effectful hook DOES carry a numeric input-partition target (≥70%)** — it is the 6th mutation-testable hook (see Mutation targets summary). |
| hook manifests (C-18) | `hooks/hooks.json`, `hooks/hooks.json.windows` | **HIGH** | N/A (config) | Now a distinct Component-Map entry (**C-18**, added in the pass-1 architecture reconciliation). The event→handler wiring; a wrong matcher silently disables the CRITICAL require-review gate. `jq`-validated only, no schema check. High blast radius by de-wiring. |

### Vulnerability-pipeline skills (write to / gate the authoritative Jira record)

| Module | Path | Tier | Mut. target | Rationale |
|--------|------|------|-------------|-----------|
| update-jira skill | `skills/update-jira/SKILL.md` | **CRITICAL** | N/A (LLM) | The last-mile writer to the Jira system of record (`jr issue edit/comment`); its review-approval and CVSS-range checks (VP-SKILL-007/008) are LLM-soft and **not automated**, and the approval marker is spoofable by injected content (SEC-001, A-6). Only the independently-tested require-review hook stands between it and record corruption. |
| enrich-ticket skill | `skills/enrich-ticket/SKILL.md` | **HIGH** | N/A (LLM) | Core 8-stage business-logic pipeline producing the enrichment record (BC-4.01.001); 8-stage sequencing, EPSS-mandatory, multi-factor priority all behavioral and structural-only-verified. Errors propagate into the record. |
| review-enrichment skill | `skills/review-enrichment/SKILL.md` | **HIGH** | N/A (LLM) | The quality gate that produces the review approval (BC-4.03.001); strongest structural coverage (opus + no-Write invariants checked) but scoring formulas and fresh-context are unverified behavior. |
| adversarial-review-secops skill | `skills/adversarial-review-secops/SKILL.md` | **HIGH** | N/A (LLM) | Convergence quality-gate loop (BC-4.04.001); thresholds (≥7.0, no dim <5.0), min-2-passes and SECOPS-P1 numbering are behavioral/unenforced. Defers to the canonical review-convergence playbook. |

### Event-investigation pipeline

| Module | Path | Tier | Mut. target | Rationale |
|--------|------|------|-------------|-----------|
| investigate-event skill | `skills/investigate-event/SKILL.md` | **HIGH** | N/A (LLM) | 7-stage investigation with TP/FP/BTP disposition (BC-5.01.001) — a wrong disposition is a missed threat or misdirected response; its only executable enforcement is the disposition-guard hook, which currently false-passes (DI-004). |

### Activation lifecycle

| Module | Path | Tier | Mut. target | Rationale |
|--------|------|------|-------------|-----------|
| activate skill | `skills/activate/SKILL.md` | **HIGH** | N/A (LLM) | Reads/writes `settings.local.json` via JSON merge (BC-6.01.001); GAP-7 flags a merge bug that could **corrupt user config** (never-clobber-corrupt, preserve-existing-keys, Windows hooks.json copy all unexecuted). Reachable invalid-state risk on local user state. |
| deactivate skill | `skills/deactivate/SKILL.md` | **MEDIUM** | N/A (LLM) | Single `del(.agent)` key-deletion guarded to non-secops (BC-6.01.002); simpler transform, lower corruption surface, recoverable. |

### Orchestration layer (canonical business-rule sources)

| Module | Path | Tier | Mut. target | Rationale |
|--------|------|------|-------------|-----------|
| orchestrator agent (Morgan) | `agents/orchestrator/orchestrator.md` | **HIGH** | N/A (declarative) | Default companion agent holding the routing table + quality-gate contract; a routing/gate-documentation error propagates to every pipeline run. |
| enrichment-workflow playbook | `agents/orchestrator/enrichment-workflow.md` | **HIGH** | N/A (declarative) | Canonical 8-stage enrichment DAG — the core business rules of the vuln pipeline; drift propagates to all enrichments. |
| investigation-workflow playbook | `agents/orchestrator/investigation-workflow.md` | **HIGH** | N/A (declarative) | Canonical 7-stage investigation DAG; the business-rule source for event investigation. |
| review-convergence playbook | `agents/orchestrator/review-convergence-workflow.md` | **HIGH** | N/A (declarative) | Canonical convergence/novelty-classification loop; adversarial-review-secops defers to it as source of truth. |

### Specialist agents

| Module | Path | Tier | Mut. target | Rationale |
|--------|------|------|-------------|-----------|
| security-analyst (Alex) | `agents/security-analyst.md` | **HIGH** | N/A (declarative) | Executes enrichment and investigation deep work; produces the content that reaches the record. |
| security-reviewer (Riley) | `agents/security-reviewer.md` | **HIGH** | N/A (declarative) | The peer/adversarial review gate (opus, read-only); its config invariants are load-bearing for review integrity. |
| metrics-analyst (Quinn) | `agents/metrics-analyst.md` | **MEDIUM** | N/A (declarative) | Produces Jira-derived metrics/effort reports locally; wrong metrics mislead management but do not corrupt the security record. |
| osint-researcher (Harper) | `agents/osint-researcher.md` | **MEDIUM** | N/A (declarative) | Cited external research feeding context; does not write the authoritative record. |
| advisory-writer | `agents/advisory-writer.md` | **MEDIUM** | N/A (declarative) | Drafts external-facing advisories (TLP-marked); reviewed before release, not on the Jira write path. |

### Knowledge / templates / checklists

| Module | Path | Tier | Mut. target | Rationale |
|--------|------|------|-------------|-----------|
| knowledge bases (data KBs) | `data/*.md` | **HIGH** | N/A (static) | Encodes the product's core business rules (CVSS/EPSS/KEV interpretation, priority framework P1–P5 SLA table, ATT&CK mapping). A wrong KB systematically biases every enrichment/investigation with **no executable gate to catch it** — and the LLM reviewer grounds on the same KBs, so errors are self-consistently uncaught. (Prose KBs like bias-patterns are lower-value members.) |
| output templates | `templates/*.yaml`, `templates/*.md` | **MEDIUM** | N/A (static) | Define output schemas; the enrichment-completeness/disposition-guard hooks hardcode section lists that must stay in sync (drift risk GAP-5). Schema-shape blast radius, not corruption. |
| quality checklists | `checklists/*.md` | **MEDIUM** | N/A (static) | The 8 CVE + 7 event review-dimension definitions grounding the review gates; content-quality reference. |

### Dispatch / test / external

| Module | Path | Tier | Mut. target | Rationale |
|--------|------|------|-------------|-----------|
| command dispatch | `commands/*.md` | **LOW** | ≥70% | 20 thin slash-command stubs with no embedded logic ("Use the X skill"); pure dispatch/utility. |
| research-cve skill | `skills/research-cve/SKILL.md` | **MEDIUM** | N/A (LLM) | Grounds severity via Perplexity/NVD/EPSS/KEV; errors are caught downstream by enrichment/review. |
| read-ticket skill | `skills/read-ticket/SKILL.md` | **MEDIUM** | N/A (LLM) | Ingests Jira ticket bodies verbatim — the **SEC-001 prompt-injection entry point** (unsanitized external data). Simple ingest module; mitigation is defense-in-depth framing, tracked separately. Flag prominently despite MEDIUM tier. |
| assess-priority / map-attack skills | `skills/{assess-priority,map-attack}/SKILL.md` | **MEDIUM** | N/A (LLM) | Business-logic sub-skills feeding enrichment; bounded, review-caught. |
| advisory pipeline skills | `skills/{scan-threats,create-advisory,fact-verify}/SKILL.md` | **MEDIUM** | N/A (LLM) | Advisory drafting/verification; external-facing but reviewed, not on the Jira write path. |
| metrics pipeline skills | `skills/{generate-metrics,analyze-ticket-effort,model-ticket-cost,extract-severity,verify-metrics-report}/SKILL.md` | **MEDIUM** | N/A (LLM) | Analytic reporting; `generate-metrics` is a hot file (recent churn). Wrong metrics mislead but do not corrupt the security record. |
| secops-health command | `commands/secops-health.md` | **LOW** | ≥70% | Diagnostic-only, no backing skill (CI special-cases it). |
| test suite + CI | `tests/*.bats`, `tests/run-all.sh`, `.github/workflows/*.yml` | **HIGH** | N/A (meta-gate) | The verification safety net and gate-of-gates. **DI-006:** 12 of 14 parity tests silently skip without `pwsh`, which CI neither installs nor asserts — a false-pass that could ship unverified `.ps1` hooks. **SEC-005:** Semgrep exits early yet reports success. A false-passing gate has high blast radius (regressions ship green). |
| jr CLI (external) | `github.com/Zious11/jira-cli` | **MEDIUM** | N/A (external) | The sole Jira write channel; out of our mutation scope but SEC-002 (fail-open interaction) and SEC-006 (unversioned) apply. |
| Perplexity MCP (external) | `@perplexity-ai/mcp-server` | **MEDIUM** | N/A (external) | Recommended with graceful WebSearch/WebFetch fallback; functionally low-risk but SEC-003 (unpinned `npx -y`) is a supply-chain exposure. |

---

## Distribution

### Authoritative — YAML component-map aggregate (C-1..C-24), total 24

| Tier | Count | Members (C-id) |
|------|-------|----------------|
| CRITICAL | **1** | require-review hook (C-12) |
| HIGH | **12** | skill-procedures (C-2, aggregate — contains the CRITICAL update-jira skill); orchestrator/Morgan (C-3); enrichment-workflow (C-4); investigation-workflow (C-5); review-convergence (C-6); security-analyst (C-7); security-reviewer (C-8); enrichment-completeness hook (C-13); disposition-guard hook (C-14); hook-manifests (C-18); knowledge bases (C-19); test-suite+CI (C-22) |
| MEDIUM | **7** | metrics-analyst (C-9); osint-researcher (C-10); advisory-writer (C-11); output-templates (C-20); quality-checklists (C-21); jr CLI (C-23); Perplexity MCP (C-24) |
| LOW | **4** | command-dispatch (C-1); bias-check-reminder hook (C-15); handoff-validator hook (C-16); session-greeting hook (C-17) |
| **Total** | **24** | 1 + 12 + 7 + 4 = 24 ✓ (matches frontmatter) |

### Secondary — per-artifact / sub-module granularity, total 43

**Derivation (explicit, ADV-0-404):** start from the 24 aggregate components →
**remove** the C-2 `skill-procedures` aggregate (−1 = 23) → **add** its 19 individual
skills (+19 = 42) → **promote** `secops-health` (a command file with no backing skill)
out of the C-1 command-stub bundle into its own distinct LOW module (+1 = **43**).
Because secops-health is carved out, the C-1 command-dispatch entry is relabelled
**"19 stubs"** (the 20 command files = 19 stubs + secops-health) so it is not
double-counted. update-jira surfaces here as a distinct CRITICAL skill; hook-manifests
is already its own component (C-18) in the aggregate view, so it does not add to the
delta. `24 − 1 + 19 + 1 = 43` ✓.

| Tier | Count | Members |
|------|-------|---------|
| CRITICAL | **2** | require-review hook; update-jira skill |
| HIGH | **16** | enrichment-completeness hook; disposition-guard hook; hook-manifests (C-18); enrich-ticket; review-enrichment; adversarial-review-secops; investigate-event; activate; orchestrator (Morgan); enrichment-workflow; investigation-workflow; review-convergence; security-analyst; security-reviewer; data KBs; test-suite+CI |
| MEDIUM | **20** | deactivate; research-cve; read-ticket; assess-priority; map-attack; scan-threats; create-advisory; fact-verify; generate-metrics; analyze-ticket-effort; model-ticket-cost; extract-severity; verify-metrics-report; metrics-analyst; osint-researcher; advisory-writer; templates; checklists; jr CLI; Perplexity MCP |
| LOW | **5** | bias-check-reminder hook; handoff-validator hook; session-greeting hook; command dispatch (19 stubs — secops-health carved out); secops-health (promoted, no backing skill) |
| **Total** | **43** | 2 + 16 + 20 + 5 = 43 ✓ |

> The **authoritative** figure the capstone must sync to is **24 modules — 1 CRITICAL /
> 12 HIGH / 7 MEDIUM / 4 LOW** (frontmatter). The per-artifact 43-module figure is a
> secondary breakdown showing the finer granularity used in the ranking tables above.

## Open-item impact on effective assurance (re-issued post PR #13/#14/#15)

### Resolved — no longer degrade tier assurance (verified against merged code, suite 150/150)

> **Reference convention (pass 9):** hook citations below use **construct names**
> (the write-block if-block / the fail-closed catch-all / the specific write-verb
> patterns), not `require-review.sh:NN` line numbers — line numbers churned and
> inverted across PR #13/#14/#15 and are no longer stable anchors.

| Item | Module | Resolution |
|------|--------|-----------|
| SEC-001 | require-review (CRITICAL), update-jira (skill CRITICAL) | **RESOLVED (PR #13, f450d9f).** `jr issue comment` moved into the write-block if-block — the injection route to the authoritative record via comments is hard-gated. Red-first BATS vector added. (Residual defense-in-depth: read-ticket system-prompt framing of untrusted ticket content is still advisable but not blocking.) Note: this fix was silently **defeated by the SEC-009 precedence bypass until PR #15** — see SEC-009 below. |
| SEC-002 / SM-3 / GAP-2 (fail-open) | require-review (CRITICAL) | **RESOLVED (PR #13).** The unrecognized-subcommand path changed from allow to deny — verified at the **fail-closed catch-all** (the terminal `emit_deny` after the read-only allowlist). SM-3 killed. |
| SM-2 (assign/create) | require-review (CRITICAL) | **NEUTRALIZED (PR #13).** assign/create remain explicitly denied by the **write-block if-block's `jr issue assign` / `jr issue create` patterns**, and the fail-closed catch-all makes the "delete assign/create from blocklist" mutant behaviorally inert (still denied). Residual: a dedicated assign/create partition test is nice-to-have, not load-bearing. |
| SEC-003 | Perplexity MCP / jr CLI (MEDIUM) | **RESOLVED (PR #13).** MCP server versions pinned in `docs/mcp.json.example` (perplexity 0.9.0, playwright 0.0.78). |
| SEC-004 | test-suite + CI (HIGH) | **RESOLVED (PR #13).** release.yml permission scoping addressed under the SEC-001..005 fix set. |
| SEC-005 | test-suite + CI (HIGH) | **RESOLVED (PR #13).** Semgrep early-exit addressed under the SEC-001..005 fix set. |
| **SEC-009 / ADV-0-801** (allowlist-precedence bypass) | require-review (CRITICAL) | **RESOLVED (PR #15, d304fa5).** CRITICAL at discovery: the require-review hook evaluated the read-only allowlist **before** the write-block, so any write command with an embedded read-only token (e.g., `jr issue edit KEY --summary "see jr board"` matching the `jr board` allowlist entry) matched the allowlist and emitted allow — the gate was **fully bypassable and SEC-001 was defeated**. Fix reorders the **write-block if-block ahead of the read-only allowlist** and adds 12 red-first BATS vectors (bypass-class must-DENY + `jr --output json issue <write>` forms + regression must-ALLOW). Suite 150/150 green. |

### Still open — effective assurance below tier until remediated (verified still present)

| Item | Module | Effect |
|------|--------|--------|
| DI-004 / SM-1 / GAP-1 | disposition-guard (HIGH) | **STILL OPEN.** `disposition-guard.sh:54` still uses a bare `grep -qiF "Alternatives Considered"` substring match (untouched by PR #13/#14, last modified v0.2.0). A negating sentence containing the phrase defeats the anti-confirmation-bias gate. Effective assurance below HIGH until the heading-anchored fix + failing BATS vector land. |
| DI-006 / GAP-3 | test-suite + CI (HIGH) | **STILL OPEN.** No `pwsh` reference in `ci.yml`; the 12 conditional parity tests + `.ps1` syntax check still silently skip if the runner image drops `pwsh` (false-pass). |

## Mutation / verification targets summary

**All 6 hooks carry a numeric target** (input-partition BATS kill-rate analog).
Authoritative decision (ADV-0-010): session-greeting, although effectful (it reads
`settings.local.json`), IS mutation-testable and **does carry a numeric ≥70% target** —
its gate/compare logic is a pure, enumerable sub-function. So the numeric-target set is
the **6 hooks**, not 5:

- require-review → **≥95%** (CRITICAL) — SM-3 killed and SM-2 neutralized by fail-closed design (PR #13); this materially improves assurance but the **≥95% target is NOT yet demonstrated met** — no per-hook mutation run has executed. Individual kill rate unmeasured (the current **~75–80%** in verification-gap-analysis.md §Mutation Testing Baseline → Surviving Mutants summary (~line 194) is the post-remediation 6-hook mutation-testable-set aggregate, not require-review alone; ~55–65% was the pre-PR-13 baseline, now superseded). Target remains open until Phase 6 / Feature Mode.
- enrichment-completeness → **≥90%** (HIGH) — must still kill SM-4 (investigation branch untested).
- disposition-guard → **≥90%** (HIGH) — must still kill SM-1 (false-pass, DI-004 — STILL OPEN).
- bias-check-reminder → **≥70%** (LOW).
- handoff-validator → **≥70%** (LOW).
- session-greeting → **≥70%** (LOW) — effectful but mutation-testable; numeric target applies.

All other modules are declarative/LLM/static: the tier governs review depth, structural
coverage, and gate-sync assertions, not a numeric kill-rate.

## DTU implications

Step 0e.5 does not request DTU work, and none is produced here. For downstream
awareness only: the two external integrations — **jr CLI** (required Jira write
channel, MEDIUM) and **Perplexity MCP** (recommended, MEDIUM, has WebSearch/WebFetch
fallback) — are the DTU behavioral-clone candidates already noted in
`arch-recov-integrations.md`. jr CLI is the higher-value DTU candidate because it
is the sole path to the authoritative Jira record.

## Quality Gate Checklist

- [x] Every module in the Component Map (C-1..C-24) has a criticality classification
- [x] Each classification cites evidence from behavioral contracts / gap analysis / security audit / discovery
- [x] Component Map YAML `criticality` fields updated in `recovered-architecture.md` to match (C-1..C-24, incl. C-18 hook-manifests)
- [x] Known open items re-synced post PR #13/#14: SEC-001..005 + SM-2/SM-3 resolved; DI-004 and DI-006 verified still open
- [x] Census reconciled to one authoritative granularity (24 aggregate: 1/12/7/4) with a secondary per-artifact figure (43: 2/16/20/5); frontmatter + Distribution + tier rows all sum
- [x] session-greeting numeric mutation target (≥70%) stated unambiguously (6-hook target set)
- [x] C-IDs realigned to pass-1 architecture reconciliation (hook-manifests = C-18); require-review ≥95% restated as not-yet-demonstrated

## Notes for the architect

1. **Component-Map numbering discrepancy — RESOLVED 2026-07-19 (adversarial pass 1
   architecture reconciliation).** The earlier prose/YAML divergence (prose had
   C-18=hook-manifests running to C-24; YAML omitted a hook-manifests component and
   ran only to C-23) is now fixed: the machine-readable YAML has been renumbered to
   C-1..C-24 with **C-18=hook-manifests (HIGH)**, C-19=knowledge-bases, C-20=templates,
   C-21=checklists, C-22=test-suite, C-23=jr-cli, C-24=perplexity — verified against the
   current `recovered-architecture.md`. This document's census now follows that map. No
   further architect action required on this item.
2. Aggregate `skill-procedures` (C-2) is set to **HIGH** in the YAML because it contains
   the CRITICAL update-jira skill; the per-skill breakdown above is the true granularity.

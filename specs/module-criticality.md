---
document_type: module-criticality
level: L1
version: "1.0"
status: draft
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
modules_classified: 24
critical: 2
high: 12
medium: 7
low: 5
---

# Module Criticality Classification — secops-factory v0.9.0

> Step 0e.5 (Module Criticality Classification). Agent: formal-verifier.
> Classifies every Component-Map module into a DF-004 criticality tier, driving
> mutation kill-rate (and, for this declarative plugin, input-partition BATS)
> targets in later phases.

## Scope note (declarative plugin)

secops-factory is a **declarative Claude Code plugin** — no compiled/interpreted
production code. Conventional mutation testing (cargo-mutants/mutmut/stryker)
does not apply. Only the **5 pure Bash/PowerShell hooks** are mutation-testable,
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
| require-review hook | `hooks/require-review.{sh,ps1}` | **CRITICAL** | ≥95% | The authorization gate on the Jira system of record — blocks `jr issue edit/move/assign/create` (BC-3.01.001); a wrong decision writes unreviewed content to the authoritative record. Confirmed HIGH surviving mutants SM-2 (assign/create untested) and SM-3 (fail-open untested, SEC-002); SEC-001 leaves the `jr issue comment` path unblocked. |
| enrichment-completeness hook | `hooks/enrichment-completeness.{sh,ps1}` | **HIGH** | ≥90% | Enforces the required-section completeness invariant on saved enrichment/investigation docs (BC-3.02.001); the entire investigation 4-section branch is untested (SM-4) and hook-hardcoded section lists can drift from templates (GAP-5). Blast radius bounded to local doc quality, not the authoritative record. |
| disposition-guard hook | `hooks/disposition-guard.{sh,ps1}` | **HIGH** | ≥90% | Anti-confirmation-bias invariant gate requiring "Alternatives Considered" on dispositions (BC-3.03.001); **DI-004 confirmed false-pass (SM-1)** — a negating sentence containing the phrase defeats the substring match, silently bypassing a security-analysis quality gate. Effective assurance is currently below tier until the heading-anchored fix lands (GAP-1). |
| bias-check-reminder hook | `hooks/bias-check-reminder.{sh,ps1}` | **LOW** | ≥70% | Non-blocking PostToolUse advisory that injects a cognitive-bias reminder to stderr (BC-3.04.001); cannot corrupt state or block any operation. |
| handoff-validator hook | `hooks/handoff-validator.{sh,ps1}` | **LOW** | ≥70% | SubagentStop hook — advisory only, structurally cannot block (per security audit); emits a "suspiciously short" note (BC-3.05.001). No enforcement blast radius. |
| session-greeting hook | `hooks/session-greeting.{sh,ps1}` | **LOW** | ≥70% | Cosmetic SessionStart welcome banner, activation-gated, fail-open on corrupt config (BC-3.06.001). Purely presentational. |
| hook manifests | `hooks/hooks.json`, `hooks/hooks.json.windows` | **HIGH** | N/A (config) | **Not a distinct entry in the Component-Map YAML — recommend adding one.** The event→handler wiring; a wrong matcher silently disables the CRITICAL require-review gate. `jq`-validated only, no schema check. High blast radius by de-wiring. |

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

| Tier | Count | Members |
|------|-------|---------|
| CRITICAL | 2 | require-review hook; update-jira skill |
| HIGH | 12 | enrichment-completeness hook; disposition-guard hook; hook manifests; enrich-ticket; review-enrichment; adversarial-review-secops; investigate-event; activate; orchestrator (Morgan); 3 workflow playbooks (enrichment/investigation/review-convergence); security-analyst; security-reviewer; data KBs; test-suite+CI |
| MEDIUM | 7 (classes) | deactivate; metrics-analyst; osint-researcher; advisory-writer; templates; checklists; research-cve/read-ticket/assess-priority/map-attack/advisory+metrics skills; jr CLI; Perplexity MCP |
| LOW | 5 | bias-check-reminder hook; handoff-validator hook; session-greeting hook; command dispatch; secops-health |

> The frontmatter counts tally the Component-Map YAML entries (C-1..C-23) plus the
> recommended hooks-manifest entry; the HIGH row above groups several sub-modules
> (workflow playbooks, skills) that the YAML folds into aggregate components.

## Open-item impact on effective assurance (below tier until remediated)

| Item | Module | Effect |
|------|--------|--------|
| DI-004 / SM-1 / GAP-1 | disposition-guard (HIGH) | Confirmed substring false-pass defeats the anti-bias gate; effective assurance below HIGH until heading-anchored fix + failing BATS vector land. |
| SM-2 / SM-3 / GAP-2 | require-review (CRITICAL) | `assign`/`create` and fail-open branches untested; CRITICAL tier demands ≥95% partition coverage — currently ~55–65% estimated. |
| DI-006 / GAP-3 | test-suite + CI (HIGH) | `pwsh` not installed/asserted in CI; 12 parity tests + `.ps1` syntax check silently skip (false-pass). |
| SEC-001 | update-jira (CRITICAL), read-ticket (MEDIUM), require-review (CRITICAL) | `jr issue comment` unblocked + unsanitized ticket ingest = injection route to the authoritative record; fixes in flight. |
| SEC-005 | test-suite + CI (HIGH) | Semgrep early-exit reports green with no scan. |

## Mutation / verification targets summary

Only the **5 pure hooks** carry a numeric target (input-partition BATS kill-rate):

- require-review → **≥95%** (CRITICAL) — must kill SM-2, SM-3 before any behavior change ships.
- enrichment-completeness → **≥90%** (HIGH) — must kill SM-4 (investigation branch).
- disposition-guard → **≥90%** (HIGH) — must kill SM-1 (false-pass, DI-004).
- bias-check-reminder, handoff-validator, session-greeting → **≥70%** (LOW).

All other modules are declarative/LLM: the tier governs review depth, structural
coverage, and gate-sync assertions, not a numeric kill-rate.

## DTU implications

Step 0e.5 does not request DTU work, and none is produced here. For downstream
awareness only: the two external integrations — **jr CLI** (required Jira write
channel, MEDIUM) and **Perplexity MCP** (recommended, MEDIUM, has WebSearch/WebFetch
fallback) — are the DTU behavioral-clone candidates already noted in
`arch-recov-integrations.md`. jr CLI is the higher-value DTU candidate because it
is the sole path to the authoritative Jira record.

## Quality Gate Checklist

- [x] Every module in the Component Map (C-1..C-23) has a criticality classification
- [x] Each classification cites evidence from behavioral contracts / gap analysis / security audit / discovery
- [x] Component Map YAML `criticality` fields updated in `recovered-architecture.md` to match
- [x] Known open items (DI-004, DI-006, SEC-001..005) factored into effective-assurance notes
- [x] Component-Map numbering discrepancy and missing hooks-manifest entry flagged for architect

## Notes for the architect

1. **Component-Map numbering discrepancy.** The prose Components table (lines 37–62)
   and the machine-readable YAML (lines 68–324) disagree from C-18 onward: the prose
   has C-18=hook-manifests and runs to C-24=Perplexity; the YAML has C-18=data,
   C-19=templates, C-20=checklists, C-21=tests, C-22=jr, C-23=perplexity and **omits a
   component for the hook manifests entirely.** This step's YAML edits follow the
   machine-readable map. Recommend reconciling the prose and adding an explicit
   `hooks.json` manifest component (classified HIGH here).
2. Aggregate `skill-procedures` (C-2) is set to **HIGH** in the YAML because it contains
   the CRITICAL update-jira skill; the per-skill breakdown above is the true granularity.
</content>
</invoke>

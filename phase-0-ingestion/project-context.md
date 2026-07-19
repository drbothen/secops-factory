---
document_type: project-context
level: L0
version: "1.0"
status: active
producer: codebase-analyzer
phase: 0
step: "0f"
project: secops-factory
date: "2026-07-19"
source_state: "v0.9.0 + PR #12 (gitignore) + PR #13 (SEC-001..005 fixed, merged f450d9f)"
inputs:
  - phase-0-ingestion/project-discovery.md
  - phase-0-ingestion/recovered-architecture.md (+ arch-recov-api-surface.md, arch-recov-integrations.md)
  - phase-0-ingestion/conventions.md
  - phase-0-ingestion/behavioral-contracts/*.md (13 BCs)
  - phase-0-ingestion/verification-gap-analysis.md
  - phase-0-ingestion/security-audit.md
  - specs/module-criticality.md
  - holdout-scenarios/HS-INDEX.md (index reference only — holdout-protected)
  - STATE.md (drift items DI-002..DI-009)
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

Full component catalog + machine-readable Component-Map YAML + DAG + data flows:
`.factory/phase-0-ingestion/recovered-architecture.md`
API surface (20 commands, dispatch table): `.factory/phase-0-ingestion/arch-recov-api-surface.md`
Integrations / DTU candidates: `.factory/phase-0-ingestion/arch-recov-integrations.md`

### Component criticality (from `specs/module-criticality.md`; 24 modules: 2 CRITICAL / 12 HIGH / 7 MEDIUM / 5 LOW)

| Tier | Modules |
|------|---------|
| **CRITICAL** | `hooks/require-review` (authorization gate on Jira writes); `skills/update-jira` (last-mile writer to Jira system of record) |
| **HIGH** | `hooks/enrichment-completeness`; `hooks/disposition-guard`; `hooks/hooks.json*` manifests; skills enrich-ticket, review-enrichment, adversarial-review-secops, investigate-event, activate; orchestrator (Morgan) + 3 workflow playbooks; agents security-analyst, security-reviewer; data KBs; test-suite + CI |
| **MEDIUM** | skill deactivate; agents metrics-analyst, osint-researcher, advisory-writer; templates; checklists; skills research-cve, read-ticket, assess-priority, map-attack, advisory + metrics families; jr CLI; Perplexity MCP |
| **LOW** | hooks bias-check-reminder, handoff-validator, session-greeting; command dispatch; secops-health |

Mutation/verification targets apply only to the 5 pure hooks (input-partition BATS analog):
require-review ≥95%, enrichment-completeness ≥90%, disposition-guard ≥90%, others ≥70%.

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

| BC | Subject | Tier | Verification |
|----|---------|------|--------------|
| BC-3.01.001 | require-review hook — Jira field-modification gate | CRITICAL | PARTIAL (revised v1.1, 2026-07-19 — SEC-001/SEC-002 reflected) |
| BC-3.02.001 | enrichment-completeness hook — section completeness gate | HIGH | PARTIAL |
| BC-3.03.001 | disposition-guard hook — Alternatives-required gate | HIGH | FULLY (core); false-pass edge open (DI-004) |
| BC-3.04.001 | bias-check-reminder hook — PostToolUse advisory | LOW | PARTIAL |
| BC-3.05.001 | handoff-validator hook — SubagentStop empty-output guard | LOW | PARTIAL |
| BC-3.06.001 | session-greeting hook — activation-gated SessionStart banner | LOW | FULLY (core); jq-fallback open |
| BC-4.01.001 | enrich-ticket skill — 8-stage CVE enrichment | HIGH | STRUCTURAL-ONLY |
| BC-4.02.001 | update-jira skill — review-gated Jira field update | CRITICAL | STRUCTURAL-ONLY |
| BC-4.03.001 | review-enrichment skill — fresh-context quality review | HIGH | STRUCTURAL-ONLY (strongest) |
| BC-4.04.001 | adversarial-review-secops skill — convergence loop | HIGH | STRUCTURAL-ONLY |
| BC-5.01.001 | investigate-event skill — 7-stage investigation | HIGH | STRUCTURAL-ONLY |
| BC-6.01.001 | activate skill — per-project activation lifecycle | HIGH | STRUCTURAL-ONLY |
| BC-6.01.002 | deactivate skill — per-project deactivation | MEDIUM | STRUCTURAL-ONLY |

> **BC-3.01.001 revision DONE (2026-07-19).** BC updated to v1.1 reflecting PR #13 (commit f450d9f)
> behavior: SEC-001 (`jr issue comment` → deny, was allow), SEC-002 (unknown jr subcommand → deny/
> fail-closed, was allow/fail-open). Postconditions #2 and #4 replaced, invariant #3 flipped,
> edge cases EC-003/EC-009/EC-010 updated, canonical test vectors corrected, `modified:` set to
> `["v0.9.x-PR13-2026-07-19"]`. Change log section added to Source Evidence in the BC file.
> Additional finding surfaced: `jr issue changelog` is not on the read-only allowlist — will
> deny under fail-closed behavior, blocking the metrics pipeline. Noted as drift item.

## 6. Verification Posture

**Three-bucket roll-up: Fully 2 / Partially 11 / Un-verified 0** (of 13 BCs).
Fully: BC-3.03.001, BC-3.06.001. **130/130 BATS pass** locally (was 129; +1 from PR #13 red-first tests).

**The headline is the verification asymmetry:** the 6 deterministic **hooks** are genuinely
behaviorally tested; the 7 LLM-executed **skills** are **structural-only** — BATS proves Iron Law text,
Announce-at-Start, Red-Flag counts, `${CLAUDE_PLUGIN_ROOT}` reference portability, referenced-file
existence, and agent frontmatter/tool constraints, but **no executable check confirms skills enforce
their preconditions/postconditions/invariants at runtime** (that is LLM behavior). Structural gates catch
deletion/drift but are not behavioral verification of the Iron Laws.

Known surviving-mutant blind spots feed the drift items (§8): disposition-guard false-pass (SM-1/DI-004),
require-review assign/create/fail-open (SM-2/SM-3/DI-005), enrichment-completeness investigation branch
(SM-4), pwsh-not-in-CI silent skip (DI-006). No coverage tool applies (declarative plugin);
shellcheck clean on `.sh`; `.ps1` gets no static analysis.

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
| DI-005 | require-review assign/create/fail-open paths untested | HIGH | open | first Feature cycle |
| DI-006 | pwsh parity tests skip silently; CI does not assert pwsh; no `.ps1` static analysis | HIGH | open | first Feature cycle |
| DI-007 | enrichment-completeness investigation branch untested; hook↔template section-sync gap; handoff-validator 39/40 boundary | MEDIUM | open | first Feature cycle |
| DI-008 | Component-Map numbering diverges (prose table vs YAML) in recovered-architecture.md | LOW | open | 0f-post consistency |
| DI-009 | hook-manifests component absent from machine-readable YAML component map | HIGH | open | 0f-post consistency |

Note: DI-005 partially superseded by PR #13 (fail-open→fail-closed changed; assign/create test coverage
still open). DI-002/DI-003/DI-008/DI-009 are consistency/spec items, not behavioral defects.

## 9. Restricted Areas (require explicit human review before change)

| Area | Path | Justification |
|------|------|---------------|
| Authorization gate | `plugins/secops-factory/hooks/require-review.{sh,ps1}` | CRITICAL — the only hard gate on Jira system-of-record writes; behavior just changed (PR #13); CRITICAL tier ≥95% partition coverage not yet met |
| Jira writer | `plugins/secops-factory/skills/update-jira/SKILL.md` | CRITICAL — last-mile writer; review-approval marker is LLM-soft and spoofable; only the require-review hook stands between it and record corruption |
| Injection entry point | `plugins/secops-factory/skills/read-ticket/SKILL.md` | SEC-001 surface — ingests Jira ticket bodies verbatim (unsanitized external data); mitigation is defense-in-depth framing |
| Hook wiring | `plugins/secops-factory/hooks/hooks.json`, `hooks.json.windows` | A wrong matcher silently de-wires the CRITICAL require-review gate; jq-validated only, no schema (DI-009) |
| Anti-bias gate | `plugins/secops-factory/hooks/disposition-guard.{sh,ps1}` | Confirmed false-pass (DI-004) — bypassable quality gate on investigation dispositions |
| User-config writer | `plugins/secops-factory/skills/activate/SKILL.md` | JSON-merge into `settings.local.json` (never-clobber-corrupt path unexecuted) — invalid-state risk on local user config |
| Release/CI + credentials | `.github/workflows/*.yml`, `.envrc`, `.mcp.json` | Supply-chain / privilege boundary; credentials local-only (gitignored) — never commit |

## 10. Recent Changes (reflected in this document)

- **PR #13 (merged, f450d9f):** SEC-001..005 fixed; `jr issue comment` now review-gated; require-review
  **fails closed** on unknown subcommands; MCP versions pinned; release.yml job-scoped perms; Semgrep pinned.
  BATS 129→130 green. **BC-3.01.001 revised to v1.1 (2026-07-19) — SEC-001/SEC-002 now reflected.**
- **PR #12 (merged, da58b9a):** `.gitignore` covers `.envrc`/`.env`/`.mcp.json`/`.claude/settings.local.json`; DI-001 resolved.
- **Repo hardening:** branch protection on `main`; Semgrep active in CI; SHA-pinned actions + job timeouts.
- v0.6.0→v0.9.0 trajectory: orchestrator companion, cross-platform hooks + session greeting,
  Jira-native metrics suite + recipes. Single contributor; strong release hygiene.

## 11. Boundary — Exists vs NEW work

**Exists (brownfield, in scope):** the full v0.9.0 plugin — 20 commands, 19 skills, 6 agents (+3 playbooks),
6 hook pairs + manifests, 10 data KBs, 6 templates, 15 checklists, 4 BATS suites; 3 CI workflows; 13
behavioral contracts recovered; module criticality classified; security audit dispositioned; 25 holdout
regression scenarios seeded.

**Not in scope / excluded:** `.factory/` (pipeline state on factory-artifacts orphan branch),
`.reference/jira-cli/` (reference material for the external `jr` dependency), `.git`, `.claude`.

**Would be NEW work (no code today; candidates for Feature Mode):**
- Behavioral verification of skill Iron Laws (currently structural-only) — e.g., extracting pure
  sub-functions (activate JSON-merge, update-jira field validation, review scoring) to testable shims.
- Remediation of DI-004..DI-007 (false-pass fix + missing hook partitions + pwsh-in-CI + hook↔template sync).
- A persisted/cryptographic review-approval marker (today it is spoofable LLM conversation state).
- A `skills/secops-health/` skill (DI-002) and Component-Map reconciliation (DI-008/DI-009).
- PSScriptAnalyzer for `.ps1`; system-prompt framing for untrusted ticket content (SEC-001 defense-in-depth).

## 12. Holdout Reference (index only — DO NOT load details)

25 regression-baseline scenarios (epic **BROWNFIELD-REGRESSION**), HS-001..HS-025, derived from 10 BCs
(2 CRITICAL, 7 HIGH, 1 MEDIUM). Stored under `.factory/holdout-scenarios/` and **holdout-protected**:
must NEVER be shown to implementer/test-writer agents (DF-009 information asymmetry). Distribution:
require-review ×4, update-jira ×4, enrichment-completeness ×3, disposition-guard ×3, and 2 each for
enrich-ticket/review-enrichment/adversarial-review-secops/investigate-event/activate, 1 for deactivate.
Index metadata only: `.factory/holdout-scenarios/HS-INDEX.md`.

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
- [x] Cross-references consistent (module names align across architecture, contracts, criticality)
- [x] Restricted areas justified per row
- [x] Context-budget estimate per architectural component + strategy recommendation
- [x] No orphaned references
- [x] Security posture reflects security-audit.md (post-fix state, SEC-001..005 merged)
- [x] Recent changes (PR #12, PR #13) surfaced; BC-3.01.001 revised to v1.1 (done 2026-07-19)

```yaml
pass: 0
step: "0f"
status: complete
files_synthesized: 9
timestamp: 2026-07-19T00:00:00Z
next_step: "phase-1-spec-crystallization"
```

---
title: "Claroty xDome V1 Planning Brief"
status: active
date: 2026-09-01
audience: secops-factory F3 pipeline, cross-repo Prism coordination
prism_version_target: v1.0.0-rc.1
cycle: v0.10.0-feature-prism-integration
phase: F3-planning
references:
  - .factory/feature/prism-integration-handoff-brief.md
  - .factory/phase-f2-spec-evolution/prd-delta.md
  - .factory/phase-f2-spec-evolution/architecture-delta.md
  - .factory/phase-f2-spec-evolution/dtu-assessment.md
  - .factory/STATE.md (MIG-001)
  - prism/.factory/STATE.md (D-2264 / D-2357)
---

# Claroty xDome V1 Planning Brief

This document is the F3-planning reference for the secops-factory Claroty xDome V1 release.
It consolidates the governing decisions, current inventory, spec gaps, blockers, and
phased roadmap established during the 2026-09-01 health-check session.

**Do not cross-contaminate with Prism's `.factory/` state.** secops-factory and Prism are
separate pipelines with separate STATE.md files and independent ADR/story spaces.

---

## 1. Purpose and Governing Decisions

### 1.1 V1 Objective

V1 is the **first release** of secops-factory, scoped to a fully-working Claroty xDome
sensor end-to-end. This aligns to Prism's **D-2264 governing decision (2026-08-21)**:

> "v1 FIRST RELEASE: fully-working Claroty xDome sensor, end-to-end. Validation: REAL
> Claroty xDome tenant (live API; AD-017 opaque). v1 scope: client+sensor onboarding →
> OCSF correctness (COERCION+ROUTING) → all query shapes → push-down → SOC-analyst Q&A
> loop → stability." — Prism STATE.md `active_objective`

Prism subsequently issued **D-2357 (2026-08-29)** expanding xDome to full endpoint coverage
(G2–G6 completed); DTU parity migration for non-Claroty sensors remains post-v1.

### 1.2 Runtime-Scope Decision (This Session, Human-Directed 2026-09-01)

**KEEP the 4-sensor spec; RUNTIME-SCOPE V1 to Claroty only.**

The `sensor_family` enum `{crowdstrike, armis, claroty, cyberint}` is a **normalization key,
not a scope gate**. It exists throughout the BC/architecture/hook layer because NORMALIZE_SEVERITY,
validate_enums, and the 18-field verdict schema require it to be complete and stable. Narrowing
the enum would break these deterministic enforcement surfaces and force a BC revision wave
post-V1 when other sensors are added.

**What changes:** activate, onboard-customer, and onboard-sensor skills emit a runtime guard
restricting provisioning to `sensor_id=claroty` for V1. The monitoring-loop, investigate-event,
and assess-priority skills process only Claroty OCSF tables (`claroty_events`). The DTU is
wired to org-b seed=150 (the Claroty-bearing fixture org) and the "monroe" live xDome tenant.

**F2 convergence continues over the full 4-sensor spec.** The Architect and FV work the
complete BC set (BC-10.01.001 v1.29, BC-3.03.001, etc.) at F2 cadence. V1 ships
**PROPOSE-ONLY** (`autonomy_enabled=false` default).

### 1.3 MIG-001 Engine-Uplift Deferral

**MIG-001** (STATE.md §Open Items row): engine uplift to vsdd-factory 1.0.0-rc.24 and
`.factory/` artifact-path canonicalization are deferred to the F3 cycle boundary
(pre-F3-story-decomposition). Human-approved 2026-09-01: finish F2 convergence on the
current engine first. Blockers on entry: fix enable key
(`vsdd-factory@vsdd-factory` → `vsdd-factory@claude-mp`); relocate 48 mappable files;
resolve EC-007 bc_id/subsystem frontmatter gap on 22 BCs; decide handling for 78 unmapped
artifacts. Do **not** attempt this migration during F2 or early F3 story work.

---

## 2. Current Feature Inventory (v0.9.0 — All BUILT)

All items below are live in the `plugins/secops-factory/` plugin directory.

### 2.1 Agents (6)

| Agent | Role |
|-------|------|
| orchestrator (Morgan) | Primary SOC analyst orchestrator |
| security-analyst | Alert investigation and enrichment |
| security-reviewer | Quality review of enrichment output |
| advisory-writer | Threat advisory authoring |
| metrics-analyst | Ticket and effort metrics |
| osint-researcher | OSINT and external intelligence |

### 2.2 Skills (20, Grouped by Domain)

| Group | Skills |
|-------|--------|
| Lifecycle | activate, deactivate, secops-health |
| Ingestion | read-ticket |
| Enrichment | research-cve, enrich-ticket (8-stage), map-attack, scan-threats, create-advisory |
| Investigation | investigate-event (7-stage) |
| Prioritization | assess-priority (6-factor P1–P5) |
| Governance | review-enrichment, adversarial-review-secops, fact-verify |
| Jira | update-jira |
| Metrics | generate-metrics, analyze-ticket-effort, model-ticket-cost, extract-severity, verify-metrics-report |

### 2.3 Supporting Artifacts

- 20 commands (1:1 to skills)
- 6 hooks: require-review (jr-write auth gate), enrichment-completeness (quality gate),
  disposition-guard (anti-bias gate), advisory bias-check-reminder, handoff-validator,
  session-greeting
- 15 checklists, 6 templates, 10 data files, rules/secops-protocol.md

### 2.4 Recent Security Hardening (PRs #13–#17)

SEC-001/002 security findings resolved; DI-004/005/006/007/011/014 domain invariants
enforced; heading-anchor soundness, allowlist precedence bypass (CRITICAL §15), and
hooks.json schema corrected.

---

## 3. Alert-Triage State — Two Layers

### 3.1 Layer 1: BUILT (v0.9.0) — Human-Invoked Single-Ticket Flow

```
read-ticket
  → {enrich-ticket | investigate-event}
  → research-cve / map-attack
  → assess-priority
  → review-enrichment
  → [enrichment-completeness gate] → [disposition-guard gate]
  → [require-review gate]
  → update-jira
```

This flow is live, security-hardened, and used today. Hooks enforce deterministic quality
and auth gates at each Write. No Prism dependency; no autonomous writes.

### 3.2 Layer 2: SPEC-ONLY — Autonomous Monitoring-Loop (F2 Target, ZERO Code)

Governed by **BC-10.01.001 v1.29** (prd-delta.md §1 row 5; 16 invariants, 21 edge cases).

8-stage per-alert pipeline:

```
Stage 0: SENSOR HEALTH CHECK (prism_sensor_health per org)
Stage 1: INGEST (watermark-gated; 24h lookback on first run)
Stage 2: VALIDATE (known-FP/dedup BEFORE enrichment spend — §3.2 <2min budget)
Stage 3: CATEGORIZE (MITRE ATT&CK tactic/technique)
Stage 4: ENRICH (prism ThreatIntel/NVD; Perplexity; Tavily)
Stage 5: SCORE (assess-priority; scored_priority CRIT|HIGH|MED|LOW)
Stage 6: DISPOSE (TP|FP|BTP|Indeterminate — 4-verdict enum; Indeterminate is hard floor)
Stage 7: DOCUMENT (18-field ICD-203 verdict JSON; disposition-guard fires here)
Stage 8: TICKET ACTION (jr Bash; require-review fires here; marker consumed)
```

Key architecture constraints:
- **18-field verdict schema** (12 ICD-203 + severity + asset_type + ticket_action_type +
  native_severity + sensor_family + scored_priority) — see architecture-delta.md §D-DEC-008.
- **120-second marker TTL** (D-DEC-001 v2.0 schema; NFR-SEC-001).
- **Jira-first ticket rules** (D-024: rule 2 = create+link; D-022 two-sequential-Write
  compound; D-026 orphan-link recovery; D-027 hard-floor link TWO-TIER; never auto-reopen closed).
- **Hard floors** (HIGH/CRIT scored_priority; Indeterminate disposition; techniques
  T1003/T1068/T1021/T1041; silent/degraded sensor; unknown asset type) → always route
  create-review/comment-review markers; exempt from autonomy_enabled kill switch
  (D-DEC-012 Option A; human-confirmed 2026-07-21).
- **Kill switch** `autonomy_enabled=false` (V1 default): suppresses REGULAR writes; does
  NOT suppress human-escalation review-surface writes.
- **Sensor silence = positive risk signal** (Indeterminate-due-to-missing-telemetry, not null).
- **Cron wrapper Gate 2**: grep audit.log for
  `HARD-FLOOR-LIVELOCK-ABORT|HARD-FLOOR-UNBINDABLE|UNDER-LABEL-DENIED|SEVERITY-MISMATCH|MARKER-WRITE-FAILED`
  → exit 1 even when `is_error=false` (PC#7, BC-10.01.001).

### 3.3 The Gap

The following do **not exist** in any form:

| Missing | Status |
|---------|--------|
| monitoring-loop skill | SPEC-ONLY |
| sensor-metrics skill | SPEC-ONLY |
| onboard-customer skill | SPEC-ONLY |
| onboard-sensor skill | SPEC-ONLY |
| Prism MCP config plumbing (activate rewrite) | SPEC-ONLY |
| marker-store / watermark-store / autonomy plumbing | SPEC-ONLY |
| cron wrapper | SPEC-ONLY |
| disposition-guard rewrite (marker emitter + validate_enums + severity-normalization + hard-floor routing) | SPEC-ONLY |
| require-review rewrite (marker consumer + marker invalidation) | SPEC-ONLY |

F2 spec convergence is at pass 28, **NOT converged** (no 3-clean streak yet).
F3 story decomposition and F4 implementation have not started.

---

## 4. Prism Integration Model

Prism is a **separate Rust MCP-server product** (PrismQL over sensor APIs, OCSF
normalization, DTU clones). Integration is not a code merge.

### 4.1 Runtime Consumption (secops-factory consumes Prism as MCP service)

The `activate` skill writes `mcpServers.prism` into `~/.claude/settings.json`:
```json
{
  "mcpServers": {
    "prism": {
      "command": "/path/to/prism",
      "args": ["--config-dir", "<config-dir>", "start"],
      "env": { "RUST_LOG": "off", "CLAROTY_INSTANCE_URL": "<value>" }
    }
  }
}
```
Version gate: `prism --version >= v1.0.0-rc.1`. `RUST_LOG=off` is mandatory
(tracing JSON to stdout corrupts MCP JSON-RPC framing; see handoff-brief §2.1).

### 4.2 Test DTU

Prism ships `prism-dtu-demo-server` with fixture seeds:

| Org | Seed | Sensors |
|-----|------|---------|
| org-a | 100 | CrowdStrike, Armis |
| org-b | 150 | Claroty, Cyberint |
| org-c | 200 | All sensors |

**V1 wires to org-b (seed=150)** and the "monroe" live xDome tenant.
DTU assessment: `DTU_REQUIRED: true` for prism (MCP stdio), jr CLI (autonomous write scope),
and Tavily/Perplexity MCP — see dtu-assessment.md v1.5.

### 4.3 Separate State

secops-factory and Prism maintain separate `.factory/` directories and STATE.md files.
Cross-repo coordination happens at the version-contract surfaces enumerated in §8.

---

## 5. V1 Claroty xDome Scope

### 5.1 Include in V1

| Area | V1 Scope |
|------|----------|
| Activate | Binary version gate + MCP config write + `RUST_LOG=off` injection + `jr` auth check; runtime-guard: claroty only |
| onboard-customer | New skill; org slug + UUID-v7 provisioning; prism.toml `[[orgs]]` append; `customers/<org_slug>/` dir; credential instructions per AD-017 |
| onboard-sensor | New skill; sensor overlay TOML write; AD-017 piped-stdin credential walkthrough; prism_describe verification; SELECT 1 connectivity check; **V1 guard: `sensor_id=claroty` only** |
| investigate-event | Prism-grounded evidence collection: Claroty OCSF tables + adjacent-event time-window queries; optional Tavily web enrichment |
| assess-priority | Prism-grounded priority scoring: 30-day baseline; Bayesian TP/FP/BTP; scored_priority enum |
| sensor-metrics | New skill; `SELECT * FROM prism_sensor_health` per org×sensor; last-seen/row-counts/error-rate |
| scan-threats | New skill; predefined PrismQL hunting queries; prism_describe-first table enumeration; findings grouped by severity; Claroty tables |
| monitoring-loop | Full 8-stage loop over Claroty data only; watermarks; sensor-silence detection; ICD-203 18-field verdicts; `autonomy_enabled=false` (PROPOSE-ONLY) |
| DTU wiring | org-b + "monroe" live xDome tenant; jr-mock BATS for Jira marker scenarios |
| Ship posture | PROPOSE-ONLY (`autonomy_enabled=false`) |

### 5.2 Defer Post-V1

| Deferred | Reason |
|----------|--------|
| CrowdStrike / Armis / Cyberint fidelity and onboarding | Prism post-v1 (D-2264/D-2357 de-scoped) |
| Cyberint severity-band validation | ASM-008 blocking; pre-V1 default = CRITICAL for all Cyberint alerts |
| Multi-org / cross-tenant campaign correlation | Complex; defer until V1 Claroty loop is stable |
| Full auto-close autonomy | `autonomy_enabled=true` requires ASM-015/ASM-009 risk clearance |
| Optional Perplexity/Tavily enrichment in monitoring-loop | Enrichment degrade-not-abort path is spec'd; wire after loop is stable |

---

## 6. Blockers and Open Items

### 6.1 BLOCKING — External

| ID | Blocker | Notes |
|----|---------|-------|
| — | **Prism v1.0.0-rc.1 binary + demo-bundle not yet published** | Prism is finalizing v1 Claroty (G1–G6 merged; live xDome "monroe" validation in progress per Prism STATE.md `current_step`). secops-factory F4 implementation cannot complete the activate skill or wire the DTU until the binary and bundle are available. |
| — | **Circular RC gate** | Prism rc.1 acceptance = a successful secops-factory live demo. But the demo requires the rc.1 binary. **Resolution sequence:** Prism live-validates "monroe" and publishes the bundle FIRST; then secops-factory runs activate/demo. Do not attempt to demo against an unpublished binary. |

### 6.2 BLOCKING — Internal (Must Probe Before F4)

| ASM | Risk | Action Required |
|-----|------|----------------|
| **ASM-015** | PreToolUse deny → `.permission_denials` under `--allowedTools` JSON envelope **unproven**. If deny does not populate `.permission_denials[]`, the cron wrapper Gate 1 check silently passes on every hard-floor denial — loop autonomy collapse. | Write a small, Prism-independent BATS probe: inject a known PreToolUse deny under `--allowedTools` JSON mode; assert `.permission_denials` is populated and non-empty. Gate all F4 monitoring-loop stories on this result. |
| **ASM-009** | Cross-hook marker filesystem visibility **unproven**. disposition-guard emits a marker file; require-review must find it on the same filesystem path. If hooks run in different process trees or sandboxed paths, the marker is invisible → require-review always denies → full monitoring-loop collapse. | Write a BATS probe: disposition-guard emits a marker to `${CLAUDE_PLUGIN_DATA}/markers/`; require-review reads the same path and finds it. Confirm with a two-hook PreToolUse sequence. Prism-independent. Gate F4 on pass. |

### 6.3 Medium Risk

| ASM | Risk | Mitigation |
|-----|------|-----------|
| ASM-008 | LLM-supplied `native_severity`, `asset_type`, `scored_priority` are not ground-truth-enforced. Cyberint default = CRITICAL (conservative; all Cyberint alerts flood review queue pre-ASM-008 resolution — correct-by-design). | Architecture-delta §D-DEC-013 conservative default is in spec. Accept for V1; track as post-V1 follow-up. |

### 6.4 Engineering Debt

| ID | Item |
|----|------|
| MIG-001 | Engine uplift to rc.24 + artifact relocation (see §1.3). Deferred to F3 boundary. |
| F2 not converged | Pass 28; needs 3-clean adversarial streak + F7 delta convergence before F3 story decomposition. |
| F3/F4 not started | Story decomposition (Wave 7) and implementation have not begun. |
| DTU CI wiring | DTU BATS scenarios exist in dtu-assessment.md v1.5; not wired into CI. |

---

## 7. Phased Roadmap

### Phase A — Finish F2 Spec Convergence (Current)

1. Continue adversarial pass cycle (pass 29+) targeting 3-clean streak.
2. Run F7 delta convergence: integrate prd-delta.md v1.29 + architecture-delta.md v1.30
   + verification-delta.md v1.30 into base specs.
3. Do NOT begin F3 story decomposition until convergence is declared.

### Phase B — De-Risk ASM-015 + ASM-009 (Immediately After F2, Prism-Independent)

1. Write and run the ASM-015 BATS probe (permission_denials in --allowedTools JSON mode).
2. Write and run the ASM-009 BATS probe (cross-hook marker filesystem visibility).
3. If either probe fails: escalate to human with failure evidence before proceeding.
4. Document probe results in STATE.md open items; close or escalate each ASM.

### Phase C — F3: Story Decomposition (Wave 7)

1. Run MIG-001 engine uplift (enable key fix → artifact relocation → BC frontmatter fixes).
2. Decompose monitoring-loop BCs (BC-10.01.001) into Wave 7 stories.
3. Include stories for: onboard-customer, onboard-sensor, sensor-metrics, scan-threats,
   activate rewrite, disposition-guard rewrite, require-review rewrite, cron wrapper.
4. Wire DTU BATS scenarios to CI (dtu-assessment.md v1.5 branch-triggering table).

### Phase D — F4: Build (Wave 7 Implementation)

1. Build 4 new skills: onboard-customer, onboard-sensor, sensor-metrics (monitoring-loop
   is the anchor skill; scan-threats already spec'd at BC-9.01.001 v1.2).
2. Rewrite disposition-guard: marker emitter + validate_enums + severity-normalization
   (NORMALIZE_SEVERITY table, D-DEC-013) + hard-floor routing (STEP 1a–STEP 5).
3. Rewrite require-review: marker consumer + marker invalidation (single-use; TTL check).
4. Add marker-store, watermark-store, autonomy plumbing, Prism MCP config, cron wrapper.
5. Activate skill rewrite: version gate + MCP config write + `jr` auth check +
   claroty-only runtime guard.
6. All new .sh scripts require companion .ps1 variants and BATS test coverage
   (per handoff-brief §6: scripts that touch settings.json, credential set, version check).

### Phase E — Cross-Repo RC Handshake

1. Prism publishes v1.0.0-rc.1 binary + demo-bundle (Prism pipeline responsibility).
2. secops-factory: run activate against rc.1 binary; validate MCP connection.
3. Demo sequence: demo-setup → demo-seed-jira → activate → onboard-customer →
   onboard-sensor → investigate-event on demo ticket → show monitoring-loop as
   background (one manual run).
4. Successful live demo = Prism RC acceptance gate (per handoff-brief §1 decision table).

---

## 8. Cross-Repo Coordination Surface

Prism (engine rc.22/rc.23, now fully-merged v1 xDome) and secops-factory (unpinned/floats rc.24;
MIG-001 pin fix deferred to F3 boundary) are separate repos with separate pipelines.

Keep the following version-contract surfaces in lockstep:

| Surface | Owner | V1 Contract |
|---------|-------|-------------|
| `prism --version` gate | secops-factory activate skill | `>= v1.0.0-rc.1` |
| MCP tool shapes | Prism (source of truth) | `query`, `prism_describe`, `prism_sensor_health` |
| `prism-demo-bundle-${TAG}-${target}` | Prism release pipeline | Asset name format + target matrix |
| Org/seed fixture layout | Prism DTU demo-server | org-a/b/c seeds 100/150/200 |
| `RUST_LOG=off` in MCP env | secops-factory activate | Always injected (framing corruption risk) |

When Prism changes any of the above surfaces, the corresponding secops-factory artifact
(activate skill, onboard-sensor skill, or DTU test fixtures) must be updated in the same
release window.

---

## 9. Quick-Reference Artifact Map

| Artifact | Path | Current Version |
|----------|------|----------------|
| Handoff brief (original) | `.factory/feature/prism-integration-handoff-brief.md` | 2026-07-19 |
| PRD Delta (F2) | `.factory/phase-f2-spec-evolution/prd-delta.md` | v1.29 |
| Architecture Delta (F2) | `.factory/phase-f2-spec-evolution/architecture-delta.md` | v1.30 |
| DTU Assessment | `.factory/phase-f2-spec-evolution/dtu-assessment.md` | v1.5 |
| BC: monitoring-loop | `.factory/phase-0-ingestion/behavioral-contracts/BC-10.01.001.md` | v1.29 |
| BC: disposition-guard | `.factory/phase-0-ingestion/behavioral-contracts/BC-3.03.001.md` | v1.37 |
| BC: require-review | `.factory/phase-0-ingestion/behavioral-contracts/BC-3.01.001.md` | v1.25 |
| BC: onboard-customer | `.factory/phase-0-ingestion/behavioral-contracts/BC-6.01.003.md` | v1.7 |
| BC: onboard-sensor | `.factory/phase-0-ingestion/behavioral-contracts/BC-6.01.004.md` | — |
| BC: sensor-metrics | `.factory/phase-0-ingestion/behavioral-contracts/BC-8.02.001.md` | v1.4 |
| BC: scan-threats | `.factory/phase-0-ingestion/behavioral-contracts/BC-9.01.001.md` | v1.2 |
| Pipeline STATE | `.factory/STATE.md` | — |
| Prism STATE (D-2264) | `prism/.factory/STATE.md` | `active_objective` / `D-2264` / `D-2357` |

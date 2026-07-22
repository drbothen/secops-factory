---
document_type: spec-changelog
project: secops-factory
---

# Spec Changelog

Track all spec version changes. Most recent version first.

---

## [1.1.0] - 2026-07-20 (patch edits 2026-07-21 — not a version bump)

### F2 Pass-7 Remediation Edits — Burst 3 (2026-07-21) — spec remains 1.1.0

Remediation edits within the F2 adversarial convergence cycle (burst 3). Central design reversal:
STEP-4 marker-upgrade approach RETIRED; replaced with DENY-THE-WRITE per human decision D-008.
Root findings: P7-001 (CRITICAL — marker-upgrade emits markers loop's own jr command cannot consume
for 3 of 4 under-label action types; silent drop of hard-floor findings), P7-002 (CRITICAL — 6
stale locations in BC-10.01.001 encoding pre-D-DEC-012 "no marker for hard floor" semantics),
P7-003 (MAJOR — --label Iron Law missing from Stage-8 loop contract), P7-004 (MAJOR — VP-HOOK-029
emitter-only, cannot detect unconsumable-marker seam gap), P7-005 (MINOR — step-6a raw-substring
false-deny on --summary containing label text), P7-006 (MINOR — Cyberint severity unvalidated,
needs explicit conservative default), P7-007 (MINOR — brief §3.9 version pins stale), P7-009
(PROCESS-GAP — O4 standing rule: fail-loud guarantees must be verified at consumer/Bash boundary).

| File | Old Version | New Version | Root Finding |
|------|-------------|-------------|--------------|
| phase-f2-spec-evolution/architecture-delta.md | v1.9 | v1.10 | P7-001/P7-004/P7-009: DENY-THE-WRITE redesign; STEP-4 deny + corrective-reason struct + UNDER-LABEL-DENIED audit; SM-38/SM-39/SM-40 allocated; O4 standing rule codified; P7-003: --label Iron Law Stage-8/loop contract; P7-006: Cyberint D-DEC-013 explicit conservative default |
| phase-0-ingestion/behavioral-contracts/BC-3.03.001.md | v1.15 | v1.16 [SM-ID-sync per FV] | P7-001: STEP 4 deny-the-Write; UNDER-LABEL-DENIED audit replaces UNDER-LABEL-CORRECTED; corrective-reason struct (hard_floor_trigger/required_token/label_instruction); EC-012 under-label rows updated to deny semantics; VP-HOOK-029 citation updated; SM-38/SM-39 IDs synced |
| phase-0-ingestion/behavioral-contracts/BC-3.01.001.md | v1.18 | v1.19 [SM-ID-sync per FV] | P7-005: structural_label_check step-6a (standalone --label token check, not raw substring); EC-024 false-deny prevention; VP-HOOK-024 v1.19 extension; SM-40 kill target added |
| phase-0-ingestion/behavioral-contracts/BC-10.01.001.md | v1.11 | v1.12 [SM-ID-sync per FV] | P7-002: 6 stale EC locations (EC-015/016/017/021 + 2 canonical test vectors) updated from "no marker for hard floor" to create-review/comment-review semantics; P7-003: --label Iron Law Stage-8; P7-006: Cyberint conservative default CRITICAL + uncertainty_explicit; VP-HOOK-029 citation updated to deny-the-Write; SM-38/SM-39 IDs synced |
| feature/prism-integration-handoff-brief.md | §3.9 (pinned versions) | §3.9 non-pinned | P7-007: stale version pins removed |
| phase-f2-spec-evolution/verification-delta.md | v1.9 | v1.10 | P7-001/P7-004: VP-HOOK-029 re-scoped end-to-end consumer-boundary, re-FINALIZED P0 (deny-path vectors + machine-actionable-reason + corrected-rewrite + consumer-boundary + kill-switch-irrelevance); SM-38/SM-39/SM-40; VP-HOOK-024 step-6a false-deny vector; VP-SKILL-074 Cyberint partition; 31→34 mutants; ~258→~263 tests; version-coherence sweep (VP-HOOK-025/027/028/SKILL-064/065/068/072/073 BC anchors + §5 row header) |

---

### F2 Pass-6 Remediation Edits — Burst 2 (2026-07-21) — spec remains 1.1.0

Remediation edits within the F2 adversarial convergence cycle (burst 2). Root findings: P6-001
(consumer anti-fungibility — create-review/comment-review markers accepted for regular commands),
P6-002 (STEP 4/5 ordering — kill switch preceded under-label upgrade, causing silent discard on
hard-floor verdicts under autonomy_enabled=false), P6-003 (Inv#11/VP-SKILL-065 contradicted Option
A carve-out), P6-004 (cross-org create binding void with single PRISM-DEMO key — downgrade noted),
P6-005 (sensor-native severity encodings unmapped to {LOW,MEDIUM,HIGH,CRITICAL} enum — D-DEC-013),
P6-006 (D-DEC-004 review-token binding stale), P6-007 (late-event grace-window drop had no
detection VP), P6-008 (ASM-009 cross-hook marker-store visibility unvalidated — elevated to BLOCKING
pre-Wave-3), P6-009 (O3 rule applied emitter-only — extended to consumer, ordering, trust-boundary).

| File | Old Version | New Version | Root Finding |
|------|-------------|-------------|--------------|
| phase-f2-spec-evolution/architecture-delta.md | v1.8 | v1.9 | P6-001..009 unified; D-DEC-012 reversal (hook-side label enforcement ADOPTED, D-DEC-012 O3 extended); D-DEC-013 severity normalization; STEP 4/5 reorder; ASM-009 BLOCKING; O3 O3-table consumer+ordering+trust-boundary rows; namespace corrections VP-SKILL-074/SM-36/SM-37 |
| phase-0-ingestion/behavioral-contracts/BC-3.01.001.md | v1.17 | v1.18 | P6-001: consumer STEP 6a anti-fungibility cross-check both directions; EC-023; OR-accept removed for create (comment retains); org-binding downgrade noted; 4 new canonical test vectors; VP-HOOK-029 FINALIZED ref; SM-36/SM-37 attribution |
| phase-0-ingestion/behavioral-contracts/BC-3.03.001.md | v1.14 | v1.15 | P6-002: STEP 4/5 swap throughout; labeled create-review pattern in 3 locations; Iron Law updated (hook-side label enforcement); ASM-014 note; EC-012 case (d) flipped to upgrade semantics; test vectors updated |
| phase-0-ingestion/behavioral-contracts/BC-10.01.001.md | v1.10 | v1.11 | P6-003: Inv#11 Option A carve-out (zero REGULAR writes, escalation-review writes exempt); VP-SKILL-065 re-scoped + re-marked PROPOSED; Inv#10 concession removed; NORMALIZE_SEVERITY named step per D-DEC-013; EC-006/EC-014 disambiguation |
| phase-f2-spec-evolution/verification-delta.md | v1.8 | v1.9 | VP-HOOK-029 FINALIZED (P0); consumer anti-fungibility vectors under VP-HOOK-024; VP-SKILL-065 RE-SCOPED PROPOSED; new VP-SKILL-073 (late-event P1) + VP-SKILL-074 (severity normalization P1, namespace-corrected from architect's "VP-SKILL-072"); SM-32-ext/SM-36/SM-37; 31 VPs + 31 mutants; ~238→~258 tests; FV caught VP-SKILL-072+SM-33/34 namespace collisions |

---

### F2 Pass-5 Remediation Edits (2026-07-21) — spec remains 1.1.0

Remediation edits within the F2 adversarial convergence cycle. Root findings: P5-001
(silent discard on hard-floor mismatch), P5-002 (kill-switch bypass via LLM token without
deterministic gate), P5-003 (stale §D-DEC-001 authoritative schema block). Kill-switch
conflict with brief §3.9 resolved via human-confirmed Option A (2026-07-21).

| File | Old Version | New Version | Root Finding |
|------|-------------|-------------|--------------|
| phase-f2-spec-evolution/architecture-delta.md | v1.7 | v1.8 | P5-001/002/003 + D-DEC-012 O3 rule + Option A kill-switch |
| phase-f2-spec-evolution/verification-delta.md | v1.7 | v1.8 | VP-HOOK-029 re-scope + SM-32a/32b split + §7 Part F routing |
| phase-f2-spec-evolution/prd-delta.md | v1.8 | v1.9 | §4/§6 12/15-field count correction |
| phase-0-ingestion/behavioral-contracts/BC-3.03.001.md | v1.13 | v1.14 | P5-001/P5-002 STEP 3/5 gate propagation + schema v2.1 sync + EC-012 + TV-SYNC |
| phase-0-ingestion/behavioral-contracts/BC-10.01.001.md | v1.9 | v1.10 | Inv#10 safety-net note + VP-SKILL-061 sensor-silence reword |
| feature/prism-integration-handoff-brief.md | §3.9 (pre-Option A) | §3.9 amended | Kill-switch Option A confirmed by human 2026-07-21 |

---

### Type: MINOR

### Summary

Feature cycle v0.10.0-feature-prism-integration: added 5 new behavioral contracts (prism
integration skills + monitoring-loop), modified 6 existing BCs (marker mechanism, evidence
collection, scoring), added 17 verification properties (VP-HOOK-024..026,
VP-SKILL-050..063), 11 mutation vectors (SM-9..SM-19), and 10 architecture decisions
(D-DEC-001..010). DI-013 resolved via D-DEC-001 marker mechanism.

### New Behavioral Contracts

| BC ID | Version | Subject |
|-------|---------|---------|
| BC-6.01.003 | v1.1 | onboard-customer skill — org slug/UUID-v7 provisioning, prism.toml [[orgs]] append, customers/<org_slug>/ dir creation, credential provisioning instructions (AD-017) |
| BC-6.01.004 | v1.1 | onboard-sensor skill — sensor overlay TOML write, AD-017 piped-stdin credential walkthrough, prism_describe verification, SELECT 1 connectivity check, --config-dir isolation |
| BC-8.02.001 | v1.1 | sensor-metrics skill — per org×sensor last-seen/row-counts/error-rate via prism_sensor_health; D-DEC-006 naming (sensor-metrics, not metrics) |
| BC-9.01.001 | v1.1 | scan-threats skill — predefined PrismQL hunting queries across all orgs; prism_describe-first table enumeration; findings grouped by severity; org_slug scoping invariant |
| BC-10.01.001 | v1.1 | monitoring-loop — 8-stage per-alert pipeline; four-disposition enum; Indeterminate hard floor; §3.4 Jira rules; §3.5 SLA surface; §3.7 sensor-silence=positive-signal; §3.8 ICD-203 12-field schema; watermark monotonicity; D-DEC-001..010 |

### Modified Behavioral Contracts

| BC ID | Old Version | New Version | One-Line Change Summary |
|-------|-------------|-------------|------------------------|
| BC-3.01.001 | v1.10 | v1.12 | Added D-DEC-001/D-DEC-008 marker-validation conditional-allow branch inside write-block path; Invariant #2 updated to permit marker-store filesystem access; EC-017..022 added; VP-HOOK-024 added |
| BC-3.03.001 | v1.5 | v1.7 | Added EMITTER role (marker issuance path only); ICD-203 dual-path 12-field enforcement (heading-anchored markdown + JSON key-presence); tuning_signal null-vs-absent semantics; VP-HOOK-025 corrected to list all 12 fields; EC-010..012 added |
| BC-4.02.001 | v1.3 | v1.4 | DI-013 RESOLVED via D-DEC-001 marker-gated comment path; four §3.4 ticket-action types added as distinct postconditions (PC#7a–d); Invariant #4 never-auto-reopen-closed; Invariant #5 §3.5 SLA surface-never-assume; EC-007..009 added |
| BC-4.05.001 | v1.0 | v1.1 | Added prism-grounded scoring layer: 30-day baseline query, enrich_nvd() UDF, rule-fidelity recalibration, per-tenant asset criticality weights, Bayesian TP/FP/BTP framework; degradation path to 6-factor when prism unavailable; Invariant #4 org_slug scoping; EC-009..012 added |
| BC-5.01.001 | v1.4 | v1.5 | Added prism evidence collection (Stage 3: OCSF event lookup + temporal-adjacency; Stage 4: ThreatIntel/NVD UDFs + optional Tavily D-DEC-009); structured evidence bundle §3.8 chain-of-custody format; DI-013 RESOLVED in Invariant #7 (marker-gated via D-DEC-001); EC-008..010 added |
| BC-6.01.001 | v1.0 | v1.2 | Added prism binary install/verify + version gate (VP-SKILL-051); DUAL MCP config write D-DEC-003 (settings.json mcpServers.prism + prism.mcp.json); RUST_LOG=off Invariant #5 (framing corruption prevention); jr auth check BLOCKING gate; AD-017 credential setup instructions; EC-008..012 added |

### New Verification Properties

| ID | Description | Proof Strategy |
|----|-------------|----------------|
| VP-HOOK-024 | require-review: marker-validation conditional-allow branch (D-DEC-001/D-DEC-008) | BATS |
| VP-HOOK-025 | disposition-guard: ICD-203 12-field enforcement — all fields including timeline_events, agent_actions, human_actions, tuning_signal | BATS |
| VP-HOOK-026 | monitoring-loop: hard floor enforcement (autonomy_enabled=true + Indeterminate/HIGH severity) | BATS |
| VP-SKILL-050 | monitoring-loop: watermark monotonicity (post-run watermark >= injected pre-run value) | BATS |
| VP-SKILL-051 | setup-prism: binary version gate (>= 1.0.0-rc.1) | BATS |
| VP-SKILL-052 | onboard-customer: org slug/UUID-v7 provisioning postconditions | BATS |
| VP-SKILL-053 | onboard-customer: credential provisioning instructions (AD-017 — no credential-in-chat) | BATS |
| VP-SKILL-054 | onboard-sensor: sensor overlay TOML write correctness | BATS |
| VP-SKILL-055 | onboard-sensor: SELECT 1 connectivity check (success only when DB responds) | BATS |
| VP-SKILL-056 | sensor-metrics: last-seen/row-counts/error-rate via prism_sensor_health | BATS |
| VP-SKILL-057 | sensor-metrics: org_slug scoping invariant (no cross-tenant data) | BATS |
| VP-SKILL-058 | scan-threats: PrismQL hunting query dispatch (prism_describe-first) | BATS |
| VP-SKILL-059 | scan-threats: org_slug scoping invariant (no cross-org findings) | BATS |
| VP-SKILL-060 | monitoring-loop: four-disposition enum enforcement (Benign/FP/Indeterminate/TP) | BATS |
| VP-SKILL-061 | monitoring-loop: Indeterminate disposition hard floor (never auto-close) | BATS |
| VP-SKILL-062 | monitoring-loop: §3.4 Jira ticket-action rules (PC#7a–d, never-auto-reopen-closed) | BATS |
| VP-SKILL-063 | monitoring-loop: §3.5 SLA surface-never-assume invariant | BATS |

### Architecture Changes

- D-DEC-001: Marker mechanism for disposition-guard/require-review cross-hook communication (resolves DI-013; TTL 30s; scope-validated; consumed-on-use)
- D-DEC-002: Prism binary install path and version gate strategy (>= 1.0.0-rc.1)
- D-DEC-003: DUAL MCP config write — settings.json mcpServers.prism + standalone prism.mcp.json
- D-DEC-004: Watermark store location (${CLAUDE_PLUGIN_DATA}/watermarks/) and monotonicity contract
- D-DEC-005: Cross-tenant isolation — org_slug scoping as plugin-side invariant; no prism-side cross-org correlation
- D-DEC-006: Naming convention: skill named sensor-metrics (not metrics) to avoid namespace collision
- D-DEC-007: Prism describe-first table enumeration strategy for scan-threats (no hardcoded table names)
- D-DEC-008: Marker scope validation: authorized_operations field must match command_pattern; path-traversal gated
- D-DEC-009: Tavily enrichment in evidence collection is recommended-not-required (graceful skip when unavailable)
- D-DEC-010: --allowedTools MCP glob syntax (mcp__prism__*) for ASM-004 partial resolution

### Mutation Vectors

11 new mutation vectors (SM-9..SM-19) covering: marker-store attack surfaces (expired/wrong-scope/replayed/malformed/path-traversal/wrong-ticket), watermark file manipulation, credential exfiltration via chat-echo, prism binary substitution, and cross-tenant org_slug injection.

### Impact Assessment

- **Affected stories:** Wave 3–7 stories in cycle v0.10.0 — all story acceptance criteria referencing these BCs must cite updated versions
- **Affected tests:** 17 new VP fixtures required (VP-HOOK-024..026, VP-SKILL-050..063); VP-HOOK-025 corrected from 8-field to 12-field enforcement
- **Migration needed:** NO (backward-compatible additions; existing BCs append-only except internal patch bumps)
- **Migration notes:** N/A
- **DI resolved:** DI-013 resolved via D-DEC-001 marker mechanism (no open design issues remain for this cycle)
- **Open questions for formal-verifier:** 6 items documented in prd-delta.md §6

### Reference Documents

- `.factory/phase-f2-spec-evolution/prd-delta.md` v1.2
- `.factory/phase-f2-spec-evolution/architecture-delta.md` v1.1
- `.factory/phase-f2-spec-evolution/verification-delta.md` v1.0
- `.factory/phase-f2-spec-evolution/dtu-assessment.md`
- `.factory/phase-f2-spec-evolution/asm-004-validation.md`

---

## [1.0.0] - 2026-07-20

### Type: MAJOR

### Summary

Initial spec baseline. Phase 0 brownfield ingestion of 17 behavioral contracts extracted
from the existing secops-factory codebase. Establishes the BC corpus and traceability
anchor for all subsequent feature cycles.

### Impact Assessment

- **Affected stories:** None (initial baseline)
- **Migration needed:** NO

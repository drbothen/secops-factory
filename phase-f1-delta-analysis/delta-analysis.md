---
document_type: delta-analysis
producer: architect
version: "1.1"
date: 2026-07-19
changelog:
  - "1.1 (2026-07-19): F1-consistency-validation.md remediation — VP-SKILL-035/036 renamed VP-SKILL-050/051 (namespace collision); Exec Summary MODIFIED count corrected 12→14; §1.1 breakdown 4 skills→5 skills; external write surfaces corrected to 4 in Exec Summary + §3.2; timeline_events added to §1.2 BC-3.03.001 field list (8→9 fields); VP-HOOK-020 mis-anchor corrected."
feature: prism-integration
feature_version: v0.10.0-feature-prism-integration
status: draft
brief: .factory/feature/prism-integration-handoff-brief.md
research: .factory/research/soc-analyst-workflow-2026.md
feature_type: backend
intent: feature
scope: standard
dtu_relevant: true
dtu_note: "New external service dependencies: prism binary (MCP stdio server), Tavily MCP, jr CLI (expanded autonomous write usage). prism is a new DTU candidate — the primary sensor data MCP server. Jira/jr is an existing DTU candidate now consuming autonomous create/comment/link operations."
inputs:
  - .factory/phase-f1-delta-analysis/impact-boundary.md
  - .factory/phase-f1-delta-analysis/artifact-mapping.md
  - .factory/feature/prism-integration-handoff-brief.md
  - .factory/phase-0-ingestion/project-context.md
  - .factory/specs/module-criticality.md
binding_scope_decisions:
  - "D-004: FULL brief scope, dependency-ordered"
  - "D-005: DI-013 resolved via review-approval MARKER MECHANISM on require-review"
  - "D-006: secops-factory is DEMO-UNAWARE — brief §4 out of scope except generic jr auth check in activate"
---

# F1 Delta Analysis — prism-integration (v0.10.0-feature-prism-integration)

> **Consolidated F1 artifact.** Synthesizes impact-boundary.md (architect) and
> artifact-mapping.md (business-analyst) into a single authoritative gate document
> for the human F1 review. Do not modify the source artifacts.

---

## Executive Summary (10-Line Gate Brief)

1. Feature adds prism MCP as the primary sensor data layer: new activate→onboard→investigate→score→monitor pipeline for ICS/OT SOC operations against multi-org CrowdStrike/Armis/Claroty/Cyberint sensors.
2. Scope is **standard backend**: 6 MODIFIED BCs (2 CRITICAL-tier), 5 new BCs, 14 MODIFIED plugin files, 14 NEW plugin files, 6 new BC spec files.
3. **Highest-risk change:** require-review D-005 marker mechanism adds an exception path to the sole Jira authorization gate — this is a SEC-009-class surface; independent adversarial review and new BATS bypass-class tests are mandatory before merge.
4. Monitoring-loop is the largest new component (CRITICAL per-artifact tier): fully autonomous 8-stage alert triage (validate→categorize→enrich→score→dispose→ticket→document) with Indeterminate hard floor, sensor-silence blind-spot detection, and ICD-203-grade defensible records.
5. Scope decisions D-005 (DI-013 marker mechanism) and D-006 (demo-unaware except jr auth check) are human-approved and binding.
6. **Cross-tenant correlation scoped as prism-side** (BA §3.6 verdict): plugin obligation is org_slug query scoping invariant in BC-10.01.001; no MSSP global correlation store in plugin scope for v0.10.0.
7. Regression risk zone: 57 direct tests + 17 dependent (enrichment-completeness); all 34 existing must-pass holdout scenarios must remain green; 6–7 holdout revisions needed before story decomposition.
8. 7 decisions remain open for F2 (D-DEC-001, -002, -003, -004, -007, -008, -009); D-DEC-005 resolved by BA §3.6 verdict; D-DEC-006 partially resolved by BA BC-8.02.001 slot assignment (metrics is a new skill, not an extension of generate-metrics).
9. **Four** new external write surfaces: `~/.claude/settings.json` (user-scoped MCP config), `${CLAUDE_PLUGIN_DATA}/watermarks/`, prism config directory, and the prism credential keyring (AD-017 piped-stdin pattern — different isolation model but equally security-relevant) — each requires dedicated BATS coverage.
10. Recommended delivery in 8 ordered waves in F3; Wave 3 (require-review marker mechanism) is the critical-path blocker for monitoring-loop and must be isolated with extra adversarial scrutiny.

---

## 1. Impact Assessment

### 1.1 Dimension Summary

| Dimension | Count | Detail |
|-----------|-------|--------|
| BCs MODIFIED (version bump required) | **6** | BC-3.01.001, BC-3.03.001, BC-4.02.001, BC-4.05.001, BC-5.01.001, BC-6.01.001 |
| BCs at-risk-DEPENDENT (monitor; no mandatory modification yet) | **3** | BC-3.02.001 (enrichment-completeness), BC-4.06.001 (read-ticket), BC-6.01.002 (deactivate) |
| New BC subjects needed (F2 authoring) | **5** | BC-6.01.003 (onboard-customer), BC-6.01.004 (onboard-sensor), BC-8.02.001 (metrics), BC-9.01.001 (scan-threats), BC-10.01.001 (monitoring-loop) |
| Plugin files NEW | **14** | 4 skill+command pairs (8 files); 3 shell helper types × .sh+.ps1 (6 files) |
| Plugin files MODIFIED | **14** | 5 skills, 4 hook files, 2 hook manifests, 1 rule, 1 template, 1 CI workflow |
| Tests — regression risk zone (direct) | **~57** | 28 require-review + 6 disposition-guard + 6 activate + 3 investigate-event + 3 assess-priority + 6 integration + 5 parity |
| Tests — regression risk zone (dependent) | **~17** | enrichment-completeness + integration + parity for enrichment path |
| Holdout scenarios needing revision | **6** (+1 marginal) | HS-001, HS-005, HS-008, HS-021, HS-023, HS-026, HS-027 (marginal: HS-029) |
| New holdout scenario subjects needed | **10** | HS-035..HS-044 |
| Existing VPs directly affected | **0** | Write-block deny behavior (D-005 modification target) is tested by BATS but has no dedicated named VP in BC-3.01.001; VP-HOOK-020 is the `jr issue changelog` ALLOW VP (unrelated to D-005). D-005 coverage arrives via proposed VP-HOOK-024 (marker validation soundness). |
| New VP subjects needed | **5** | VP-HOOK-024, VP-HOOK-025, VP-HOOK-026, VP-SKILL-050, VP-SKILL-051 |
| New external dependencies (DTU-relevant) | **3** | prism binary (MCP stdio), Tavily MCP, jr CLI autonomous-write path |
| New external write surfaces (security-relevant) | **4** | `~/.claude/settings.json`, `${CLAUDE_PLUGIN_DATA}/watermarks/`, prism config dir, prism credential keyring |
| New assumptions | **8** | ASM-001..ASM-008 |
| New risks | **8** | R-001..R-008 |
| Decisions required for F2 | **7 open** | D-DEC-001 through D-DEC-009 minus D-DEC-005 (resolved) and D-DEC-006 (partially resolved) |

### 1.2 BC Delta Summary

| BC | Subject | Delta | Tier |
|----|---------|-------|------|
| BC-3.01.001 | require-review hook | **MODIFIED** — D-005 marker mechanism adds conditional-allow exception path for narrow-scope autonomous writes; write-block-first ordering (Inv #5) preserved | CRITICAL |
| BC-3.03.001 | disposition-guard hook | **MODIFIED** — ICD-203 mandatory-field enforcement extension (§3.8 schema: disposition, confidence, sensor_health_status, evidence_artifacts, timeline_events, hypotheses_considered, alternatives_rejected, uncertainty_explicit, attack_techniques — 9 fields; F2 must confirm whether timeline_events is in the enforcement surface or only populated at runtime); additive to existing heading-anchored check; fires on monitoring-loop verdict files only | HIGH |
| BC-4.02.001 | update-jira skill | **MODIFIED** — DI-013 resolution (marker mechanism or gated command for comment-post); four §3.4 Jira ticket action types added (append/link/propose-reopen/create); never-auto-reopen-closed invariant | CRITICAL (sub-artifact) |
| BC-4.05.001 | assess-priority skill | **MODIFIED** — prism 30-day historical baseline + enrich_nvd() UDF; existing 6-factor algorithm extended; Iron Law and KEV P1 override unchanged | MEDIUM |
| BC-5.01.001 | investigate-event skill | **MODIFIED** — PrismQL OCSF evidence collection + temporal window queries + ThreatIntel/NVD UDFs + optional Tavily web augment inserted into Stage 3/4; Iron Law, Perplexity fallback, and local-save-first ordering unchanged | HIGH |
| BC-6.01.001 | activate skill | **MODIFIED** — prism binary locate/download, `prism --version` >= v1.0.0-rc.1 assertion, MCP server block write to `~/.claude/settings.json` (scoped to `mcpServers.prism` key only), RUST_LOG=off injection, `jr auth check`; existing settings.local.json per-project activation block unchanged | HIGH |
| BC-3.02.001 | enrichment-completeness hook | at-risk-DEPENDENT — monitoring-loop verdict file naming may intersect investigation-* pattern; watch during story authoring | HIGH |
| BC-4.06.001 | read-ticket skill | at-risk-DEPENDENT — prism OCSF data appended to Jira tickets is a new injection surface; SEC-001 threat model note extension needed | MEDIUM |
| BC-6.01.002 | deactivate skill | at-risk-DEPENDENT — if activate writes a prism MCP block to settings.json, deactivate must optionally clean it up | MEDIUM |
| BC-6.01.003 | onboard-customer skill | **NEW** — S=6, SS=01, NNN=003; prism.toml [[orgs]] append, customer directory provisioning | MEDIUM (proposed) |
| BC-6.01.004 | onboard-sensor skill | **NEW** — S=6, SS=01, NNN=004; sensor overlay .toml write, AD-017 credential walkthrough, SELECT 1 verification | HIGH (proposed) |
| BC-8.02.001 | metrics (prism sensor telemetry) | **NEW** — S=8, SS=02; per-org prism_sensor_health queries | LOW (proposed) |
| BC-9.01.001 | scan-threats (PrismQL hunting) | **NEW** — S=9, new section; prism_describe table enumeration, predefined hunting queries, severity grouping | MEDIUM (proposed) |
| BC-10.01.001 | monitoring-loop | **NEW** — S=10, new section; full 8-stage autonomous patrol; Indeterminate hard floor; sensor-silence positive risk signal; watermark monotonicity; ICD-203 defensible record; autonomy policy kill switch; Jira-first ticket management | CRITICAL (proposed per-artifact) |

---

## 2. Files Likely Changed

### 2.1 NEW (do not exist today)

| Path | Purpose |
|------|---------|
| `plugins/secops-factory/skills/onboard-customer/SKILL.md` | Customer org provisioning skill |
| `plugins/secops-factory/commands/onboard-customer.md` | Command dispatch stub |
| `plugins/secops-factory/skills/onboard-sensor/SKILL.md` | Sensor overlay + AD-017 credential skill |
| `plugins/secops-factory/commands/onboard-sensor.md` | Command dispatch stub |
| `plugins/secops-factory/skills/metrics/SKILL.md` | Prism per-org sensor telemetry skill |
| `plugins/secops-factory/commands/metrics.md` | Command dispatch stub |
| `plugins/secops-factory/skills/monitoring-loop/SKILL.md` | Autonomous patrol loop skill |
| `plugins/secops-factory/commands/monitoring-loop.md` | Command dispatch stub |
| `plugins/secops-factory/skills/activate/activate-mcp-config.sh` | MCP config write helper — `~/.claude/settings.json` merge |
| `plugins/secops-factory/skills/activate/activate-mcp-config.ps1` | Windows parity for above |
| `plugins/secops-factory/skills/activate/prism-version-check.sh` | `prism --version` semver assertion |
| `plugins/secops-factory/skills/activate/prism-version-check.ps1` | Windows parity for above |
| `plugins/secops-factory/skills/onboard-sensor/credential-set.sh` | AD-017 piped-stdin `prism credential set` wrapper |
| `plugins/secops-factory/skills/onboard-sensor/credential-set.ps1` | Windows parity for above |
| `.factory/phase-0-ingestion/behavioral-contracts/BC-6.01.003.md` | New BC spec (onboard-customer) |
| `.factory/phase-0-ingestion/behavioral-contracts/BC-6.01.004.md` | New BC spec (onboard-sensor) |
| `.factory/phase-0-ingestion/behavioral-contracts/BC-8.02.001.md` | New BC spec (metrics sensor telemetry) |
| `.factory/phase-0-ingestion/behavioral-contracts/BC-9.01.001.md` | New BC spec (scan-threats PrismQL hunting) |
| `.factory/phase-0-ingestion/behavioral-contracts/BC-10.01.001.md` | New BC spec (monitoring-loop — largest) |

> **Shell helper script location is open (D-DEC-007).** The paths above use
> `skills/<name>/` co-location as the working assumption. F2 must confirm.

### 2.2 MODIFIED (exist today; require edits)

| Path | Change summary |
|------|---------------|
| `plugins/secops-factory/skills/activate/SKILL.md` | prism binary check, MCP config write, jr auth check per brief §2.1 / §4.4 |
| `plugins/secops-factory/skills/investigate-event/SKILL.md` | PrismQL evidence collection + Tavily augmentation in Stage 3/4 |
| `plugins/secops-factory/skills/assess-priority/SKILL.md` | prism 30-day baseline + enrich_nvd() + Bayesian framework |
| `plugins/secops-factory/skills/scan-threats/SKILL.md` | PrismQL hunting mode added alongside existing CVE/CISA scanning |
| `plugins/secops-factory/skills/update-jira/SKILL.md` | DI-013 resolution: marker-gated comment-post + §3.4 ticket action types |
| `plugins/secops-factory/hooks/require-review.sh` | D-005 marker mechanism — new conditional-allow branch |
| `plugins/secops-factory/hooks/require-review.ps1` | Byte-parity with above |
| `plugins/secops-factory/hooks/disposition-guard.sh` | ICD-203 mandatory-field enforcement extension for verdict files |
| `plugins/secops-factory/hooks/disposition-guard.ps1` | Byte-parity with above |
| `plugins/secops-factory/hooks/hooks.json` | Add `mcp__prism__*` and `mcp__tavily__*` tool matchers to PostToolUse bias-check-reminder |
| `plugins/secops-factory/hooks/hooks.json.windows` | Windows parity for above |
| `plugins/secops-factory/rules/secops-protocol.md` | Prism entry (PrismQL syntax, error codes, RUST_LOG=off) + Tavily entry |
| `plugins/secops-factory/templates/event-investigation-tmpl.yaml` | ICD-203 mandatory fields from §3.8 disposition schema |
| `.github/workflows/ci.yml` | BATS coverage for new shell helper scripts |
| `.factory/phase-0-ingestion/behavioral-contracts/BC-3.01.001.md` | Version bump (marker mechanism) |
| `.factory/phase-0-ingestion/behavioral-contracts/BC-3.03.001.md` | Version bump (ICD-203 enforcement) |
| `.factory/phase-0-ingestion/behavioral-contracts/BC-4.02.001.md` | Version bump (DI-013 resolution + §3.4 ticket actions) |
| `.factory/phase-0-ingestion/behavioral-contracts/BC-4.05.001.md` | Version bump (prism-grounded scoring) |
| `.factory/phase-0-ingestion/behavioral-contracts/BC-5.01.001.md` | Version bump (prism evidence collection) |
| `.factory/phase-0-ingestion/behavioral-contracts/BC-6.01.001.md` | Version bump (prism activation) |
| `.factory/specs/module-criticality.md` | Add 7 new component entries (monitoring-loop CRITICAL, onboard-sensor HIGH, activate-helpers HIGH, disposition-schema HIGH, watermark-store HIGH, onboard-customer MEDIUM, metrics LOW) |

### 2.3 DEPENDENT (NOT changed; in regression zone)

| Path | Risk reason |
|------|-------------|
| `plugins/secops-factory/hooks/enrichment-completeness.sh` | Co-fires with disposition-guard on PreToolUse/Write; verdict file naming intersection risk |
| `plugins/secops-factory/hooks/enrichment-completeness.ps1` | Same |
| `plugins/secops-factory/agents/orchestrator/orchestrator.md` | Routes to modified investigate-event and assess-priority |
| `plugins/secops-factory/agents/orchestrator/investigation-workflow.md` | Stage content changes through investigate-event modification |
| `plugins/secops-factory/agents/orchestrator/enrichment-workflow.md` | assess-priority sub-skill output changes |
| `plugins/secops-factory/agents/security-analyst.md` | Runtime dependency on prism MCP server (config); no file change |
| `plugins/secops-factory/commands/activate.md` | Dispatch stub for modified skill |
| `plugins/secops-factory/commands/investigate-event.md` | Dispatch stub for modified skill |
| `plugins/secops-factory/commands/assess-priority.md` | Dispatch stub for modified skill |
| `plugins/secops-factory/commands/scan-threats.md` | Dispatch stub for modified skill |
| `plugins/secops-factory/data/event-investigation-best-practices.md` | Should receive ICD-203/NIST SP 800-61r3 supplement (not blocking) |
| `plugins/secops-factory/skills/deactivate/SKILL.md` | At-risk: may need settings.json prism block cleanup path |
| `plugins/secops-factory/skills/read-ticket/SKILL.md` | At-risk: prism OCSF data injection surface note |

### 2.4 Explicitly NOT Changed (Regression Baseline)

These files must remain byte-identical at every PR checkpoint:

| Path | Stability reason |
|------|-----------------|
| `hooks/bias-check-reminder.{sh,ps1}` | PostToolUse advisory; no structural change; monitoring-loop runs headless |
| `hooks/handoff-validator.{sh,ps1}` | SubagentStop guard; monitoring-loop has no subagent dispatch path |
| `hooks/session-greeting.{sh,ps1}` | SessionStart banner; emits to stderr; headless invocation not affected |
| `skills/enrich-ticket/SKILL.md` | 8-stage CVE enrichment; not in prism scope |
| `skills/review-enrichment/SKILL.md` | Vulnerability pipeline quality gate; not in prism scope |
| `skills/adversarial-review-secops/SKILL.md` | Vulnerability pipeline convergence loop; not in prism scope |
| `skills/create-advisory/SKILL.md` | Advisory pipeline; not modified (scan-threats scanning capability changes but advisory authoring unchanged) |
| `skills/analyze-ticket-effort/SKILL.md` | Effort metrics pipeline (S=8, SS=01); prism sensor metrics is a separate SS=02 |
| `data/cvss-guide.md`, `data/epss-guide.md`, `data/kev-catalog-guide.md` | Vulnerability pipeline data KBs; unchanged |
| `data/priority-framework.md` | Existing 6-factor priority table; assess-priority extends it, not replaces |

---

## 3. Consolidated Risk Assessment

### 3.1 Risk Register (R-001..R-008)

| ID | Risk | Category | Sev | Status | Key Mitigation |
|----|------|---------|-----|--------|---------------|
| **R-001** | Autonomy-policy misconfiguration silently auto-closes HIGH severity alerts | Security / Operational | HIGH | OPEN | §3.9 hard floor list must be unconditional code branches, not config-evaluated; BATS test must verify HIGH/CRIT/Indeterminate/degraded-sensor categories cannot be auto-closed regardless of `autonomy_enabled` |
| **R-002** | D-005 marker mechanism introduces new CRITICAL gate bypass vector (SEC-009-class) | Security / Authorization | CRITICAL | OPEN | Marker must be: time-bounded (≤30s TTL), single-use (invalidated after first use), written to a path unreachable from read-ticket injection surface (SEC-001), scoped to specific Jira operations; mandatory independent adversarial review + bypass-class BATS tests before merge |
| **R-003** | Watermark corruption or concurrent loop run causes duplicate alert processing or missed events | Data Integrity / Reliability | HIGH | OPEN | Atomic write (write to `.tmp`, `mv`/`Move-Item` rename); advisory lockfile; ISO 8601 validation + future-timestamp rejection on read; log every watermark read/write pair |
| **R-004** | RUST_LOG=off omission corrupts MCP JSON-RPC framing silently | Integration / Reliability | HIGH | OPEN | Shell helper must hardcode `"RUST_LOG": "off"`; BATS test must assert settings.json contains this field before the test exits; secops-protocol.md must document the failure mode explicitly |
| **R-005** | prism binary unavailability at monitoring-loop schedule time | Operational / Availability | MEDIUM | OPEN | Stage 0 prism connectivity probe; fail-loud to Jira (or stdout); treat connectivity failure as sensor-silence-class finding |
| **R-006** | Sensor-silence BLIND-SPOT ticket spam for long-running silence events | Operational / Jira hygiene | MEDIUM | OPEN | Dedup check for open BLIND-SPOT tickets per org+sensor before creating new one; subsequent silence runs append comment to existing BLIND-SPOT ticket |
| **R-007** | Cross-tenant data leakage via PrismQL fanout misuse | Security / Privacy | HIGH | OPEN | All PrismQL queries must include org_slug scope constraint (BC-10.01.001 tenant-isolation invariant); `cross_tenant_correlation` config field defaults to `deny`; no raw cross-tenant records in Jira comments or Perplexity/Tavily payloads |
| **R-008** | `~/.claude/settings.json` write clobbers existing MCP server configuration | Integration / Reliability | HIGH | OPEN | Shell helper must use `jq` merge (`.mcpServers += {"prism": {...}}`), not destructive overwrite; BATS test must verify pre-existing non-prism servers survive the write |

### 3.2 Architecture Risk Summary

**Purity boundary violations introduced:** Four new external write surfaces —
`~/.claude/settings.json`, `${CLAUDE_PLUGIN_DATA}/watermarks/`, prism config dir,
and the prism credential keyring (AD-017 piped-stdin pattern; different isolation model
than the shell-helper-written surfaces but equally security-relevant) — are effectful
side-effects that must be isolated, not embedded in SKILL.md prose. The first three
require dedicated shell helpers testable via BATS; the credential keyring surface is
handled by the AD-017 pattern (piped stdin, never re-read) and verified via `prism_describe`.

**Autonomy boundary:** The monitoring-loop introduces the first truly autonomous Jira
write path in the plugin. The require-review hook is the only hard gate between the
loop and the authoritative Jira record. The D-005 marker mechanism's security properties
are load-bearing; a defect here is equivalent to the SEC-009 bypass in severity.

**Headless MCP dependency:** `claude -p` headless invocation loading MCP servers from
`settings.json` is an unvalidated assumption (ASM-004). If Claude Code headless mode
does not honor `settings.json`-registered MCP servers, the monitoring-loop has no
sensor data access. This must be empirically validated before monitoring-loop stories
are written (F2 gate: confirm headless MCP loading).

### 3.3 Security Summary

| Surface | Vector | Control |
|---------|--------|---------|
| require-review D-005 marker | Forged marker in Bash command argument | Write-block-first ordering preserved (Inv #5); marker cannot be in command argument |
| prism MCP framing | RUST_LOG=off omission | Shell helper hardcodes field; BATS asserts presence |
| `~/.claude/settings.json` write | Race condition / clobber | `jq` merge + read-back verification |
| AD-017 credential provisioning | Credential value in chat history | piped stdin pattern; never re-read; verified via prism_describe |
| read-ticket + prism OCSF data | New injection surface (SEC-001) | SEC-001 framing extended to cover OCSF MCP tool responses |
| Cross-tenant PrismQL fanout | Inadvertent tenant data mixing | org_slug query scoping invariant (BC-10.01.001) |

---

## 4. New Assumptions Register (ASM-001..ASM-008)

| ID | Assumption | Status | Validation Method | Impact if Wrong |
|----|-----------|--------|------------------|----------------|
| ASM-001 | prism binary available at path recorded in settings.json at monitoring-loop schedule time (not only at activate-time) | UNVALIDATED | Stage 0 `prism --version` connectivity probe in monitoring-loop | HIGH — all sensor queries, loop, and onboarding fail entirely |
| ASM-002 | `RUST_LOG=off` injected into prism MCP server env block without exception | UNVALIDATED | BATS test asserts settings.json contains `"RUST_LOG": "off"` | HIGH — prism tracing JSON on stdout corrupts MCP JSON-RPC framing; all prism calls fail with parse errors |
| ASM-003 | `~/.claude/settings.json` is safe for single-writer concurrent access | UNVALIDATED | Document single-activate constraint; `jq` read-back verification in shell helper | MEDIUM — concurrent activations corrupt settings.json system-wide |
| ASM-004 | `claude -p` headless invocation from OS scheduler has access to MCP servers registered in `~/.claude/settings.json` | UNVALIDATED | **F2 gate: manual test of headless MCP loading before monitoring-loop stories are written** | HIGH — monitoring-loop has no sensor data access without this |
| ASM-005 | `${CLAUDE_PLUGIN_DATA}` is a writable, persistent directory accessible from the OS scheduler's user context | UNVALIDATED | Document per-OS expected path; test write/read cycle from simulated scheduler environment | HIGH — watermarks cannot be persisted; every run queries full 24h history |
| ASM-006 | `jr` CLI is available and authenticated in the OS scheduler's PATH environment | UNVALIDATED | Stage 0 `jr auth status` gate in monitoring-loop; fail-loud if unavailable | HIGH — all Jira ticket operations fail silently from scheduler context |
| ASM-007 | Jira API rate limits accommodate monitoring-loop invocation frequency (~200 req/15-min run) | UNVALIDATED | Estimate ~800 req/hour against Jira Cloud ~300 req/min — within limits; validate at higher alert volumes | MEDIUM — rate limiting causes incomplete ticket actions |
| ASM-008 | prism MCP tool names follow `mcp__prism__<tool>` naming pattern as derived from the prism binary's MCP manifest | UNVALIDATED | Read prism binary MCP manifest once binary is available; validate before hooks.json matcher changes | HIGH — all PrismQL calls in skills/loop use hardcoded tool names |

---

## 5. Decisions Required for F2

All must be resolved before F2 spec authoring is complete. Items marked RESOLVED need no further action; items marked OPEN must produce a concrete decision in F2.

| ID | Status | Decision Required |
|----|--------|------------------|
| **D-DEC-001** | OPEN | Marker mechanism design: what constitutes a D-005 approval marker that require-review accepts for `jr issue comment` (and per D-DEC-008, also `create` and `assign`)? Must be time-bounded (≤30s), single-use, written to a path not reachable via SEC-001 injection, and carry an operation-scope field. Options: (A) filesystem marker at `${CLAUDE_PLUGIN_DATA}/markers/`; (B) two-phase hook (disposition-guard writes, require-review reads + invalidates atomically). Option B recommended (strongest single-use guarantee). |
| **D-DEC-002** | OPEN | Watermark store atomic write, locking, and `${CLAUDE_PLUGIN_DATA}` path definition per OS. Atomic write via `.tmp` + rename is mandatory. Lockfile for single-instance enforcement. Define expected paths: Linux `~/.local/share/claude`, macOS `~/Library/Application Support/Claude`, Windows `%APPDATA%\Claude`. |
| **D-DEC-003** | OPEN | Monitoring-loop packaging: SKILL.md invoked via `claude -p "/monitoring-loop"`, standalone prompt file, or external wrapper script? Resolution is gated on ASM-004 validation (headless MCP loading confirmed). |
| **D-DEC-004** | OPEN | Sensor-silence BLIND-SPOT ticket dedup strategy: if an open BLIND-SPOT ticket already exists for `(org_slug, sensor_id)`, append a comment; create a new ticket only if no open BLIND-SPOT exists. JQL: `project=X AND labels=BLIND-SPOT AND status!=Closed AND customfield_org=Y AND customfield_sensor=Z`. |
| **D-DEC-005** | **RESOLVED** | Cross-tenant correlation scope: **prism-side architecture, not plugin scope** (BA §3.6 verdict). Plugin obligation: never construct a PrismQL query without org_slug scope constraint — this becomes tenant-isolation invariant in BC-10.01.001. The MSSP-global correlation store, anonymized IOC federation, and per-tenant RBAC are prism release engineering concerns. |
| **D-DEC-006** | **PARTIALLY RESOLVED** | Metrics skill naming: BA BC-8.02.001 slot assignment confirms `metrics` is a **new skill in subsystem S=8, SS=02**, distinct from `analyze-ticket-effort` (S=8, SS=01). This resolves the "extend generate-metrics" vs "new skill" question in favor of a new skill. The exact command name (`metrics` vs `sensor-metrics`) is still open — BA uses `metrics/SKILL.md`; F2 must confirm no command-namespace conflict with existing `generate-metrics` command. |
| **D-DEC-007** | OPEN | Shell helper script location: `skills/<name>/` (working assumption), `scripts/` top-level, or `hooks/`. Option `skills/<name>/` is most convention-compliant; it co-locates helpers with the skills that invoke them. |
| **D-DEC-008** | OPEN | Monitoring-loop Jira write scope through require-review: D-005 marker must cover not only `jr issue comment` but also `jr issue create` and `jr issue assign` for monitoring-loop autonomous actions. The marker must carry an `authorized_operations` scope field. D-DEC-001 must incorporate this. |
| **D-DEC-009** | OPEN | Tavily MCP dependency tier: `recommended` (graceful degradation to Perplexity-only enrichment in Stage 4) or `required` alongside jr CLI? Recommend `recommended` with explicit fallback path and secops-protocol.md entry. |

---

## 6. Brief Coverage Statement

**Based on BA artifact-mapping.md §8 coverage checklist.**

| Brief section | Coverage status |
|---------------|----------------|
| §2.1 activate — MCP wiring | FULLY MAPPED: BC-6.01.001 (MODIFIED), shell helpers, HS-039/HS-041/HS-042 |
| §2.2 secops-protocol.md prism + Tavily entries | COVERED AS DATA KB: no dedicated BC (data KBs are not individually contracted); captured as VP note in BC-10.01.001 "referenced data KBs"; verified by new structural BATS test for prism entry presence |
| §2.3 onboard-customer skill | FULLY MAPPED: BC-6.01.003 (new), HS-040 |
| §2.3 onboard-sensor skill (AD-017) | FULLY MAPPED: BC-6.01.004 (new), HS-040/HS-044 |
| §2.4 investigate-event prism evidence | FULLY MAPPED: BC-5.01.001 (MODIFIED), HS-021 revision |
| §2.4 assess-priority prism grounding | FULLY MAPPED: BC-4.05.001 (MODIFIED), HS-027 revision, HS-028 valid |
| §2.4 metrics skill | FULLY MAPPED: BC-8.02.001 (new), skills.bats structural |
| §2.4 scan-threats PrismQL hunting | FULLY MAPPED: BC-9.01.001 (new), skills.bats structural |
| §3.1–§3.2 monitoring-loop pipeline order + algorithm | FULLY MAPPED: BC-10.01.001 (new), HS-035..HS-044 |
| §3.3 four-disposition schema | FULLY MAPPED: BC-10.01.001 + BC-3.03.001 (MODIFIED), HS-035 |
| §3.4 Jira-first rules | FULLY MAPPED: BC-10.01.001 + BC-4.02.001 (MODIFIED), HS-036 |
| §3.5 SLA impact surfacing | COVERED IN BC-10.01.001: per-tenant `sla_reopen_behavior` config field |
| §3.6 cross-tenant correlation | SCOPED: plugin obligation = org_slug query scoping invariant (BC-10.01.001); MSSP correlation store is prism-side per BA §3.6 verdict (D-DEC-005 RESOLVED) |
| §3.7 sensor silence as positive risk signal | FULLY MAPPED: BC-10.01.001, HS-037 |
| §3.8 ICD-203 documentation standard | FULLY MAPPED: BC-3.03.001 (MODIFIED) + BC-10.01.001, HS-043 |
| §3.9 autonomy policy — hard floors + kill switch | FULLY MAPPED: BC-10.01.001 + VP-HOOK-026, HS-035 |
| §3.10 scheduling + watermarks | FULLY MAPPED: BC-10.01.001, HS-038; ASM-004/ASM-005 validation gated |
| §4 demo Jira project | **OUT OF SCOPE per D-006** — all §4.1/§4.2/§4.3/§4.5 excluded; §4.4 `jr auth check` in activate is the sole exception, fully mapped via BC-6.01.001 + HS-042 |
| §5 research input (soc-analyst-workflow-2026.md) | Not a secops-factory deliverable; read as input; may refine BC-10.01.001 priority weights and correlation windows during F2 |
| §6 shell/PowerShell parity + BATS | FULLY MAPPED: all new .sh scripts have .ps1 pairs; new parity.bats rows; brief §6 BATS test plan (happy path, missing binary, version mismatch, settings.json write) assigned to BC-6.01.001 test surface |
| §7 RC-1 blocking items | All items mapped to BCs and stories in this cycle |

**Unmapped (minor):** §2.2 Tavily secops-protocol.md entry has no dedicated BC — it is a data KB update captured as a VP note in BC-10.01.001 and verified by a new structural BATS test. This is the only brief requirement without a BC slot; confirmed acceptable by BA §8.9.

---

## 7. Recommended Scope for F2–F7 Phases

### F2: Spec Evolution (immediate next phase)

1. **ASM-004 gate first**: Confirm `claude -p` headless invocation loads `settings.json` MCP servers before authoring monitoring-loop BC-10.01.001. If ASM-004 fails, D-DEC-003 must choose a packaging alternative that works headlessly.
2. Resolve D-DEC-001 through D-DEC-004, D-DEC-007, D-DEC-008, D-DEC-009.
3. Author 5 new BC spec files (BC-6.01.003, BC-6.01.004, BC-8.02.001, BC-9.01.001, BC-10.01.001).
4. Version-bump 6 existing BC spec files.
5. Revise 6 holdout scenarios (HS-001, HS-005, HS-008, HS-021, HS-023, HS-026, HS-027) and add HS-035..HS-044.
6. Add 5 new VP subjects (VP-HOOK-024, VP-HOOK-025, VP-HOOK-026, VP-SKILL-050, VP-SKILL-051).
7. Confirm prism MCP tool names from binary manifest (resolve ASM-008).

### F3: Story Decomposition (8-wave delivery order)

Stories must be decomposed in dependency order. The marker mechanism (Wave 3) is the critical-path blocker for the monitoring-loop (Wave 7); it must land and stabilize before monitoring-loop implementation begins.

| Wave | Stories | Rationale |
|------|---------|-----------|
| 1 | Activate shell helpers (.sh+.ps1 × 3 types) + BATS | Foundation: settings.json write, version check, jr auth check — all monitoring-loop and onboarding depend on these |
| 2 | onboard-customer + onboard-sensor skills | Onboarding lifecycle: provides customer context for Wave 4 and 7 |
| 3 | require-review D-005 marker mechanism | CRITICAL-path blocker; isolate for extra adversarial review; must be merged + stable before Wave 7 |
| 4 | investigate-event prism evidence + assess-priority prism grounding | Core investigation path enhancement; depends on activate (Wave 1) |
| 5 | scan-threats PrismQL hunting + metrics sensor skill | New advisory and telemetry capabilities; no hard dependencies on Wave 3 |
| 6 | disposition-guard ICD-203 extension | Enforcement layer for monitoring-loop verdict schema; must precede Wave 7 |
| 7 | monitoring-loop skill (full 8-stage patrol) | Largest story; depends on Waves 1, 3, 6; may need sub-story decomposition |
| 8 | secops-protocol.md updates + hooks.json matcher additions + CI additions | Integration and documentation finish; depends on Waves 1–7 for tool names |

### F4: Delta Implementation

- Implement in Wave order above; each PR keeps all 165+ BATS tests green.
- CRITICAL PRs (Wave 3 require-review modification, Wave 7 monitoring-loop) require peer adversarial review before merge.
- RUST_LOG=off injection must be verified in every PR that touches activate shell helpers.
- `module-criticality.md` updated in Wave 7 with new component entries.

### F5: Scoped Adversarial Review

Priority targets:
1. require-review marker mechanism (R-002: SEC-009-class bypass vectors)
2. monitoring-loop autonomy policy hard floors (R-001: auto-close misconfiguration)
3. disposition-guard ICD-203 enforcement (false-pass / false-deny under new field checks)
4. `~/.claude/settings.json` write safety (R-008: clobber risk)

### F6: Targeted Hardening

1. Empirical mutation run on require-review hook — first ever per-hook run; target ≥95% (currently undemonstrated).
2. BATS coverage for all new shell helper scripts; parity.bats rows for new .sh/.ps1 pairs.
3. Verify all 34 existing must-pass holdout scenarios green at HEAD.
4. shellcheck clean for all new .sh scripts; PSScriptAnalyzer clean for .ps1 siblings.

### F7: Delta Convergence

1. Triple version lock bump: `plugin.json`, `marketplace.json`, `CHANGELOG.md` all at `v0.10.0`.
2. All 34 existing must-pass holdout scenarios + HS-035..HS-044 all must-pass.
3. `module-criticality.md` updated and signed off.
4. Release notes document the new prism MCP integration surface, the monitoring-loop autonomy policy, and the D-005 marker mechanism.

---

## 8. Reconciliation

> Explicit resolution of every conflict between impact-boundary.md (architect)
> and artifact-mapping.md (business-analyst). Neither source document is modified.

### REC-001: update-jira classification (DEPENDENT vs MODIFIED)

**Conflict:** impact-boundary.md classified update-jira/SKILL.md as DEPENDENT (unchanged
but depending on changed things). artifact-mapping.md classifies BC-4.02.001 as MODIFIED —
DI-013 resolution changes how update-jira posts comments, and the §3.4 ticket action types
(append/link/propose-reopen/create-new) must be documented in the BC.

**Resolution:** update-jira is **MODIFIED**. impact-boundary.md's DEPENDENT classification
was incorrect; DI-013 is deferred to this cycle (project-context.md §8) and its resolution
directly changes update-jira's behavior. The delta-analysis reflects this in §2.2 MODIFIED
files. The impact-boundary.md DEPENDENT listing of update-jira should be read as superseded
by this reconciliation.

### REC-002: scan-threats — MODIFIED skill vs NEW BC

**Conflict:** impact-boundary.md classified scan-threats/SKILL.md as MODIFIED (existing
skill enhanced with prism hunting). artifact-mapping.md assigned BC-9.01.001 as a NEW BC
in a new section S=9. These are not contradictory — the existing SKILL.md is MODIFIED
(the file exists at HEAD), while the behavioral contract for its new prism-hunting behavior
is NEW (no prior BC existed for scan-threats in the original 17 BCs; it was an uncontracted
MEDIUM advisory-pipeline skill). Both are correct in their domain.

**Resolution:** scan-threats/SKILL.md is MODIFIED (file exists, file changes). BC-9.01.001
is NEW (contract did not exist). Both classifications are retained without conflict.

### REC-003: D-DEC-005 cross-tenant correlation — OPEN vs RESOLVED

**Conflict:** impact-boundary.md listed D-DEC-005 as OPEN ("confirm with prism pipeline
before F2 spec is finalized"). artifact-mapping.md §3.6 issued a definitive scope verdict:
"plugin-side constraint only (prism-side architecture)" with the plugin obligation limited
to the org_slug query scoping invariant in BC-10.01.001.

**Resolution:** D-DEC-005 is **RESOLVED** as of artifact-mapping.md. No F2 action required
beyond documenting the tenant-isolation invariant in BC-10.01.001. The delta-analysis
reflects this as RESOLVED in §5.

### REC-004: D-DEC-006 metrics naming — OPEN vs PARTIALLY RESOLVED

**Conflict:** impact-boundary.md listed D-DEC-006 as OPEN ("metrics vs sensor-metrics vs
extend generate-metrics"). artifact-mapping.md implicitly resolved this by assigning
BC-8.02.001 (S=8, SS=02) with path `skills/metrics/SKILL.md` — a new, distinct skill
in a new subsystem slot, not an extension of generate-metrics (S=8, SS=01).

**Resolution:** D-DEC-006 is **PARTIALLY RESOLVED**. The architectural slot (new skill,
new subsystem, not extension) is confirmed. The command name (`metrics` vs `sensor-metrics`)
remains open in F2 to confirm there is no namespace conflict with `generate-metrics`.

### REC-005: component count for NEW files

**Conflict:** impact-boundary.md summary table said "14 artifacts" for NEW components.
Including the 5 new BC spec files (which the BA authors in F2), the true NEW artifact
count is 14 plugin files + 5 BC spec files = 19 NEW files total.

**Resolution:** delta-analysis §1.1 counts 14 NEW plugin files and 5 NEW BC spec files
separately. Both counts are accurate and refer to different artifact categories. The BA
authors the BC spec files in F2; the new plugin files are F4 implementation targets.

### REC-006: Shell helper script location

**Conflict:** artifact-mapping.md references `activate-mcp-config.sh` under
`skills/activate/` and `credential-set.sh` under `skills/onboard-sensor/` without
explicitly confirming this as the canonical location. impact-boundary.md flagged
D-DEC-007 as open.

**Resolution:** `skills/<name>/` is the working assumption in this delta-analysis (as
implicit in artifact-mapping.md's coverage checklist). D-DEC-007 remains open for F2
to formally confirm. No conflict — both documents are consistent with each other.

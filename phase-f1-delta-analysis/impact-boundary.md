---
document_type: impact-boundary
level: ops
version: "1.0"
status: draft
producer: architect
timestamp: 2026-07-19T00:00:00Z
phase: F1
cycle: v0.10.0-feature-prism-integration
project: secops-factory
inputs:
  - .factory/feature/prism-integration-handoff-brief.md
  - .factory/phase-0-ingestion/project-context.md
  - .factory/specs/module-criticality.md
  - .factory/phase-0-ingestion/recovered-architecture.md
  - .factory/phase-0-ingestion/behavioral-contracts/*.md
scope_decisions:
  - "D-004: FULL brief scope, dependency-ordered"
  - "D-005: DI-013 resolved via review-approval MARKER MECHANISM on require-review"
  - "D-006: secops-factory is DEMO-UNAWARE — brief §4 out of scope except jr auth check"
---

# Impact Boundary — v0.10.0 prism-integration Feature Cycle

> **F1 Phase artifact.** Authoritative component inventory and risk assessment for the
> prism-integration delta against the v0.9.0 baseline. All claims derived from actual
> code inspection of `plugins/secops-factory/` and the handoff brief; no assumptions
> were accepted without basis.

---

## Summary Table

| Classification | Count | Key Members |
|----------------|-------|-------------|
| **NEW** | 14 artifacts | onboard-customer, onboard-sensor, metrics (sensor), monitoring-loop (skill+command × 4 pairs); activate helper scripts (.sh+.ps1 × 3 types); watermark store |
| **MODIFIED** | 13 artifacts | require-review hook pair; disposition-guard hook pair; hooks.json + hooks.json.windows; activate SKILL.md; investigate-event SKILL.md; assess-priority SKILL.md; scan-threats SKILL.md; rules/secops-protocol.md; templates/event-investigation-tmpl.yaml; .github/workflows/ci.yml [Note: REC-001 in delta-analysis.md adds update-jira SKILL.md as a 14th MODIFIED file; 14 is the post-reconciliation authoritative count] |
| **DEPENDENT** | 12 artifacts | update-jira skill (pre-REC-001 baseline; reclassified to MODIFIED in delta-analysis.md §REC-001); enrichment-completeness hook pair; orchestrator + investigation-workflow + enrichment-workflow playbooks; security-analyst agent; 4 command dispatch stubs (activate, investigate-event, assess-priority, scan-threats); event-investigation-best-practices KB; jr CLI; Perplexity MCP |

**Top 5 Risks:** R-002 (CRITICAL gate bypass via D-005 marker), R-001 (autonomy-policy
misconfiguration auto-closes HIGH severity), R-004 (RUST_LOG=off omission corrupts MCP
framing silently), R-003 (watermark corruption causes duplicate/missed events), R-007
(cross-tenant data leakage via PrismQL fanout).

**Decisions Required for F2:** 9 items — see §5.

---

## 1. Component Inventory

All classifications derived by inspecting `plugins/secops-factory/` at HEAD (d181ca2).
The brief was cross-referenced against the actual file tree — no component listed as NEW
was found to already exist, and no MODIFIED component was found to be absent.

### 1.1 NEW Components

These artifacts do not exist in the current codebase and must be created.

#### Skills and Commands (4 new skill+command pairs)

| Component | Path | Notes |
|-----------|------|-------|
| `onboard-customer` skill | `skills/onboard-customer/SKILL.md` + `commands/onboard-customer.md` | Creates `[[orgs]]` entry in `prism.toml`, provisions customer directory under `<spec_dir>/customers/<org_slug>/` |
| `onboard-sensor` skill | `skills/onboard-sensor/SKILL.md` + `commands/onboard-sensor.md` | Writes `<sensor_id>.sensor.toml` sensor overlay, runs AD-017 credential walkthrough via piped stdin pattern |
| `metrics` (sensor telemetry) | `skills/metrics/SKILL.md` + `commands/metrics.md` | Per-org `SELECT * FROM prism_sensor_health` queries; distinct from existing `generate-metrics` (Jira-derived effort metrics — different domain, different data source) |
| `monitoring-loop` | `skills/monitoring-loop/SKILL.md` + `commands/monitoring-loop.md` | Full 8-stage autonomous patrol loop (§3.2): validate → known-FP/dedup → categorize → enrich → score → dispose → ticket-action → document; invoked headless via OS scheduler |

#### Shell Helper Scripts (3 helper types × 2 platform variants = 6 new files)

| Helper | Platform files | Purpose |
|--------|---------------|---------|
| MCP config write helper | `.sh` + `.ps1` | Writes prism MCP server block to `~/.claude/settings.json` including hardcoded `RUST_LOG=off`; must use `jq` merge, never blind-overwrite |
| prism version-check helper | `.sh` + `.ps1` | Runs `prism --version`, asserts `>= 1.0.0-rc.1`; returns error with download link on mismatch |
| credential-set helper | `.sh` + `.ps1` | Wraps `echo "<value>" \| prism credential set --sensor ... --org-slug ...`; never reads credential value back; implements AD-017 piped-stdin pattern |

Final location for helper scripts is a **Decisions Required** item (D-DEC-007); they may
live under `skills/<name>/`, a new `scripts/` directory, or `hooks/` — F2 must decide.

#### Watermark Store (runtime-created, not a plugin artifact)

| Component | Path | Notes |
|-----------|------|-------|
| Watermark files | `${CLAUDE_PLUGIN_DATA}/watermarks/<org_slug>/<sensor_id>` | ISO 8601 timestamps written by monitoring-loop after each run; persisted outside repo; path is a **new external write surface** (see §2) |

---

### 1.2 MODIFIED Components

These artifacts exist and must be changed to implement the feature.

| Component | Path | Nature of Change |
|-----------|------|-----------------|
| `activate` skill | `skills/activate/SKILL.md` | Add: prism binary location/download, `prism --version` gate (>= 1.0.0-rc.1), MCP config write to `~/.claude/settings.json` (new target — currently writes to `settings.local.json`), `jr auth status` check (D-006); invoke shell helpers for `.json` write and version check |
| `investigate-event` skill | `skills/investigate-event/SKILL.md` | Add new Stage 0 / pre-Stage 1 prism evidence collection: PrismQL raw event lookup + temporal window + enrichment UDFs (`enrich_threatintel`, `enrich_nvd`) + Tavily web-grounded enrichment; returns structured evidence bundle feeding existing Stage 4; brief §2.4 specifies query patterns |
| `assess-priority` skill | `skills/assess-priority/SKILL.md` | Add prism-grounded inputs to existing 6-factor scoring: historical 30-day baseline query, `enrich_nvd()` CVSS lookup; existing scoring algorithm and Iron Law preserved; prism data replaces/supplements current manual CVSS/EPSS inputs |
| `scan-threats` skill | `skills/scan-threats/SKILL.md` | Add prism PrismQL hunting mode: `prism_describe` table enumeration, predefined hunting queries across all orgs, findings grouped by severity; existing CVE/CISA/NVD scanning mode preserved (the current version scans public threat feeds — prism adds the internal sensor data dimension) |
| `rules/secops-protocol.md` | `rules/secops-protocol.md` | Add prism entry (§2.2): PrismQL syntax, `prism_describe` usage, error codes E-SPEC-024 / E-CRED-008, multi-org fanout semantics, `RUST_LOG=off` requirement; add Tavily entry: web-grounded enrichment role, when to invoke vs. Perplexity |
| `require-review` hook | `hooks/require-review.{sh,ps1}` | D-005 marker mechanism: add exception path that recognizes a disposition-guard-validated approval marker, permitting `jr issue comment` without interactive human approval; **CRITICAL modification — see §3 and risk R-002** |
| `disposition-guard` hook | `hooks/disposition-guard.{sh,ps1}` | ICD-203 mandatory-field enforcement extension per brief §3.8: block any disposition save that does not carry all mandatory schema fields (`disposition`, `confidence`, `sensor_health_status`, `evidence_artifacts`, `timeline_events`, `hypotheses_considered`, `alternatives_rejected`, `uncertainty_explicit`, `attack_techniques`, `agent_actions`, `human_actions`); current check is heading-only (Alternatives Considered); new version checks presence of all mandatory fields |
| Hook manifests | `hooks/hooks.json` + `hooks.json.windows` | Add prism MCP tool names to `PostToolUse` bias-check-reminder matcher (currently lists only `Bash\|mcp__perplexity__*` patterns; must add `mcp__prism__*` and `mcp__tavily__*` tool patterns once prism MCP tool names are confirmed from prism binary manifest); potentially add `PreToolUse Write` matcher for watermark files |
| Investigation template | `templates/event-investigation-tmpl.yaml` | Add ICD-203 mandatory fields from brief §3.8 disposition schema: `sensor_health_status`, `evidence_artifacts` (with chain-of-custody provenance), `timeline_events`, `hypotheses_considered`, `alternatives_rejected`, `uncertainty_explicit`, `attack_techniques`, `agent_actions`, `human_actions`, `tuning_signal` |
| CI workflows | `.github/workflows/ci.yml` | Add BATS coverage for new shell helper scripts (MCP config write, version check, credential-set); required by brief §6 |

---

### 1.3 DEPENDENT Components

Unchanged code that depends on modified components; regression risk flows through these
paths even without direct changes.

| Component | Path | Dependency |
|-----------|------|-----------|
| `update-jira` skill | `skills/update-jira/SKILL.md` | **CRITICAL dependent.** The D-005 marker mechanism changes what `jr issue comment` calls the require-review hook allows; update-jira is the last-mile writer and now has a new code path through the exception gate |
| `enrichment-completeness` hook | `hooks/enrichment-completeness.{sh,ps1}` | Co-fires with disposition-guard on `PreToolUse/Write`; disposition-guard changes to ICD-203 mandatory-field enforcement change the combined gate semantics |
| `orchestrator` (Morgan) | `agents/orchestrator/orchestrator.md` | Routes to investigate-event and assess-priority; their new prism-dependent outputs change what Morgan routes downstream |
| `investigation-workflow` playbook | `agents/orchestrator/investigation-workflow.md` | Canonical 7-stage investigation DAG; new prism evidence stage changes stage content without adding a stage number (current Stage 4 deepens) |
| `enrichment-workflow` playbook | `agents/orchestrator/enrichment-workflow.md` | 8-stage enrichment DAG; assess-priority prism inputs change stage output |
| `security-analyst` agent (Alex) | `agents/security-analyst.md` | Executes investigation and enrichment deep work; now needs prism MCP tools available — no agent file change, but runtime dependency on prism MCP server being configured |
| `commands/` dispatch stubs × 4 | `commands/{activate,investigate-event,assess-priority,scan-threats}.md` | Thin dispatch wrappers; no change, but they surface the modified skills |
| `data/event-investigation-best-practices.md` | `data/event-investigation-best-practices.md` | Should be supplemented with ICD-203 / NIST SP 800-61r3 / NIST SP 800-86 documentation standards referenced in §3.8; MEDIUM-priority update (not blocking but reduces LLM grounding quality) |
| `jr CLI` (external) | `github.com/Zious11/jira-cli` | Same role; now also invoked by monitoring-loop for autonomous ticket operations |
| `Perplexity MCP` (external) | `@perplexity-ai/mcp-server` | Already recommended; now used in monitoring-loop Stage 4 enrichment (Perplexity for high-value indicator external context) |

---

## 2. Structural Architecture Changes

### 2.1 New External Dependencies

| Dependency | Integration Pattern | Protocol | New? |
|-----------|-------------------|----------|------|
| prism binary | MCP stdio server started via `settings.json` `mcpServers.prism` block | JSON-RPC over stdio | **NEW** |
| Tavily MCP | MCP tool calls `mcp__tavily__*` | MCP | **NEW** (Tavily appears in CI `security.yml` matchers but is not listed in `secops-protocol.md` as a plugin dependency) |
| OS scheduler | Invokes `claude -p <monitoring-loop-prompt> --output-format json` headlessly | OS process | **NEW runtime dependency** |
| prism credential keyring | Piped stdin: `echo "<value>" \| prism credential set` (AD-017) | subprocess | **NEW** |
| Perplexity MCP | Already wired; monitoring-loop adds systematic invocation in Stage 4 | MCP | EXISTING — expanded usage |
| `jr` CLI | Already required; monitoring-loop adds autonomous create/comment/link operations | subprocess | EXISTING — expanded usage |
| `${CLAUDE_PLUGIN_DATA}` | Watermark persistence path for monitoring-loop | Filesystem | **NEW environment variable dependency** |

### 2.2 New Interfaces

**PrismQL query surface:**
- `prism_describe` — table enumeration (used by scan-threats, onboard-sensor verification)
- `SELECT * FROM prism_sensor_health` — sensor health (monitoring-loop Stage 0, metrics skill)
- `SELECT * FROM <sensor_table> WHERE _time > <watermark>` — incremental ingest (monitoring-loop Stage 1)
- `SELECT *, enrich_threatintel(sha256) AS threat_context FROM ...` — ThreatIntel enrichment UDF
- `SELECT *, enrich_nvd(cve_id) AS nvd_context FROM ...` — NVD enrichment UDF
- `SELECT 1` — connectivity probe (onboard-sensor verification step)

**MCP config write interface (settings.json):**
The activate skill now writes to `~/.claude/settings.json` (the full user-scoped MCP config),
not just `settings.local.json`. This is a **scope change** from the current activate skill,
which only modifies the project-scoped `settings.local.json`. Writing to the user-scoped
`settings.json` affects ALL Claude Code projects for the user, not just the current project.

**prism credential-set subprocess pattern (AD-017):**
```bash
echo "<credential_value>" | prism --config-dir <dir> credential set \
  --sensor <sensor_id> --name <credential_name> --org-slug <org_slug>
```
The plugin never reads the credential value back — verification is via `prism_describe`
(confirms the sensor is registered, not the credential value).

### 2.3 New Security-Relevant External Write Surfaces

These are surfaces where the plugin writes OUTSIDE the repository for the first time
(or significantly expands existing writes):

| Surface | Path | Write Agent | Risk |
|---------|------|-------------|------|
| `~/.claude/settings.json` | User-scoped MCP config | `activate` shell helper | **HIGH** — affects all Claude Code projects; corrupt write disables all configured MCP servers system-wide; existing `settings.local.json` write was project-scoped only |
| Watermark store | `${CLAUDE_PLUGIN_DATA}/watermarks/<org_slug>/<sensor_id>` | `monitoring-loop` | **HIGH** — persistent state outside repo; corruption causes duplicate event processing or missed alerts; path unknown without environment variable being defined |
| prism config directory | `<spec_dir>/customers/<org_slug>/` + `.sensor.toml` files | `onboard-customer`, `onboard-sensor` | **MEDIUM** — customer config files; wrong writes require manual cleanup; recoverable but operationally disruptive |
| prism credential keyring | OS keyring via `prism credential set` | `onboard-sensor` skill (user-instructed) | **HIGH** — credential material; never returned to Claude, but the piped-stdin AD-017 pattern must be verified as keyring-isolated (not shell history-logged) |

---

## 3. Criticality Classification for New Components

Derived using DF-004 taxonomy from `specs/module-criticality.md`. Four blast-radius signals:
failure blast radius, security exposure, verification coverage, change frequency.

| Component | Proposed Tier | Rationale |
|-----------|--------------|-----------|
| `monitoring-loop` skill | **CRITICAL** (per-artifact) | Autonomous Jira ticket create/comment/link without interactive human approval; wrong autonomy-policy enforcement auto-closes HIGH severity alerts; Indeterminate hard floor (§3.9) must be enforced in code, not config; interacts directly with require-review CRITICAL gate via D-005 marker; failure blast radius = missed real threats silently resolved. Highest blast radius of all new components. |
| `activate` shell helpers (.sh/.ps1) | **HIGH** | Write to `~/.claude/settings.json` (user-scoped, affects all projects); RUST_LOG=off omission causes silent MCP framing corruption (R-004); incorrect prism binary path disables all prism tool calls; partial write could leave settings.json in unparseable state |
| `onboard-sensor` skill + helpers | **HIGH** | Silent credential provisioning failure = sensor data loss with no observable error; sensor silence emits Indeterminate verdicts (§3.7); a wrong `base_url` or sensor_id causes the monitoring-loop to query no data and produce blind-spot false clearances |
| Disposition schema extension | **HIGH** | The ICD-203 mandatory-field schema is the enforcement surface for disposition-guard; wrong field names or missing required fields in the template mean disposition-guard's new checks always pass or always deny |
| Watermark store | **HIGH** | Persistence layer for incremental ingestion; corruption (truncated write, concurrent write) causes duplicate alert processing or missed events spanning the corruption window; no observable failure — monitoring-loop proceeds on bad watermark |
| `onboard-customer` skill | **MEDIUM** | Creates prism.toml org entries and spec directory; errors are recoverable (prism.toml is human-editable); failure does not corrupt security records or Jira; no automated gate depends on this |
| `metrics` (sensor telemetry) skill | **LOW** | Read-only `prism_sensor_health` query; no write path; wrong output misleads dashboard review but does not corrupt records or block investigation |

**Note on monitoring-loop tier:** at YAML component-map aggregate granularity (C-1..C-24) it
would fold into C-2 `skill-procedures` (HIGH). At per-artifact granularity it surfaces as
CRITICAL — same pattern as update-jira. The module-criticality.md author should record this
when updating §3 in F2.

---

## 4. Regression Risk per Modified Module

| Modified Module | Current Tier | Regression Risk | Justification |
|----------------|--------------|----------------|---------------|
| `require-review` hook (BC-3.01.001 v1.10) | CRITICAL | **HIGH** | D-005 adds a new exception path to the sole Jira authz gate. SEC-009 history: this gate has been bypassed twice by implementation ordering errors (PR #13 + PR #15). The marker mechanism must be designed so it cannot be triggered by injected content from read-ticket (SEC-001 surface). Any change re-opens the ≥95% kill-rate target (still undemonstrated). Dependent: update-jira, monitoring-loop, every Jira write path. |
| `disposition-guard` hook (BC-3.03.001 v1.5) | HIGH | **HIGH** | DI-004 only resolved in PR #17 (heading-anchored). The ICD-203 mandatory-field extension changes the matching logic from a single heading check to a multi-field presence check — a fundamentally wider pattern surface. Risk of false-pass (field name spelling, YAML vs. Markdown key names) or false-deny (in-progress writes that legitimately lack all fields). Co-fires with enrichment-completeness; a false-deny breaks the investigation save path entirely. |
| Hook manifests (C-18, DI-011 resolved PR #16) | HIGH | **HIGH** | Adding MCP tool names (`mcp__prism__*`, `mcp__tavily__*`) to the PostToolUse matcher. A wrong tool name pattern means bias-check-reminder never fires on prism/Tavily calls. A broken regex could inadvertently match or de-match the existing Bash matcher, which is the trigger for the CRITICAL require-review gate on `PreToolUse/Bash`. JSON-Schema validation catches structural errors but not semantic correctness of tool name patterns. |
| `activate` skill (BC-6.01.001 v1.0) | HIGH | **MEDIUM** | Currently writes to `settings.local.json`; new version writes to `~/.claude/settings.json`. The scope change (project vs. user) is operationally significant but the skill is LLM-executed with structural-only verification. RUST_LOG=off injection is new; the existing activate is structural-only tested. Existing GAP-7 (never-clobber-corrupt path unexecuted) remains open. |
| `investigate-event` skill (BC-5.01.001 v1.4) | HIGH | **MEDIUM** | New prism evidence collection modifies the investigation workflow stage ordering and evidence sourcing. The existing 7-stage disposition pipeline is structural-only verified. Wrong prism integration could cause evidence collection silently returning empty results while reporting "evidence collected" — feeding the existing disposition stages with hollow data. Dependent: investigation-workflow playbook, security-analyst agent, disposition-guard hook. |
| `assess-priority` skill (BC-4.05.001 v1.0) | MEDIUM | **LOW** | Prism-grounded inputs augment the existing 6-factor scoring without replacing it. Failures (prism unavailable, enrich_nvd returns null) degrade to existing behavior (manual CVSS/EPSS inputs). Bounded to priority output quality, not the Jira write path. |
| `scan-threats` skill (advisory-pipeline, MEDIUM tier) | MEDIUM | **MEDIUM** | Fundamentally new data source (prism PrismQL + `prism_describe` vs. web scraping). Existing BATS structural tests verify Iron Law text and references, but they cannot verify that PrismQL queries return correct findings. Risk: prism schema changes (column renames, table renames across sensor firmware versions) silently return empty results while the skill reports "scan complete." |
| `rules/secops-protocol.md` | LOW (documentation) | **LOW** | Documentation rule registry; no hook or BATS dependency. Wrong prism entry = LLM behavior drift on protocol questions but no hard enforcement consequence. |
| `templates/event-investigation-tmpl.yaml` | MEDIUM | **MEDIUM** | The disposition-guard's new ICD-203 field checks are keyed against field names in this template. Drift between template field names and disposition-guard's grep patterns (same root cause as DI-004/DI-014) would cause false-passes. Requires a hook↔template sync test (analogous to the existing enrichment-completeness hook↔template sync guard added in PR #17). |
| CI workflows | HIGH (meta-gate) | **LOW** | Additive changes only (new BATS suites for new shell scripts); existing test coverage is not reduced. Risk: omitting a required BATS test file path in ci.yml means new scripts run without CI validation. |

---

## 5. Architecture Decisions Required

The following must be decided in F2 (Spec Evolution) before stories can be written. Each is
listed as a distinct design question, not a preference recommendation.

| ID | Decision Required | Options / Constraints |
|----|------------------|----------------------|
| D-DEC-001 | **D-005 marker mechanism design** — what constitutes a "disposition-guard-validated approval marker" for require-review to allow `jr issue comment`? | Must survive SEC-001 prompt-injection surface (require-review cannot accept a marker embedded in read-ticket content). Options: (A) filesystem marker at a path require-review checks before evaluating comment, time-bounded + single-use; (B) cryptographic token embedded in comment body, signed by disposition-guard hook; (C) two-phase hook: disposition-guard writes marker, require-review reads + invalidates it atomically. Option C has the strongest single-use guarantee. All options require new BATS tests equivalent to the PR #15 bypass test suite. |
| D-DEC-002 | **Watermark store format, write atomicity, and locking** — how to prevent concurrent monitoring-loop runs from corrupting or racing on watermark files | Atomic write is mandatory (`write to temp file + mv/Move-Item rename`). Lockfile for single-instance enforcement (`.lock` file or advisory `flock`). Windows `CLAUDE_PLUGIN_DATA` path must be defined and documented. First-run behavior (no watermark file = 24h lookback window) must be specified. |
| D-DEC-003 | **Monitoring-loop packaging** — SKILL.md invoked via `claude -p "/monitoring-loop"`, or a standalone prompt file, or an external orchestration script | Affects headless invocability, convention compliance (1:1 command+skill), BATS testability, and how the loop is invoked from cron/Task Scheduler. SKILL.md approach is most convention-compliant but requires verifying `claude -p` respects SKILL.md Iron Law format. |
| D-DEC-004 | **Sensor-silence BLIND-SPOT ticket dedup strategy** — brief §3.7 requires silence events to not be auto-suppressed, but long-running silence without dedup creates Jira spam | Rule needed: if an open `[BLIND-SPOT]` ticket already exists for `(org_slug, sensor_id)`, comment on it rather than creating a new one (§3.4 append rules apply). Define dedup query: `jr issue list --jql "project=X AND labels=[BLIND-SPOT] AND org=Y AND sensor=Z AND status!=Closed"`. |
| D-DEC-005 | **Cross-tenant correlation scope boundary** — brief §3.6 describes an MSSP-global correlation store keyed on `{normalized_ioc, technique_id}`; is this store maintained by prism (server-side) or by the plugin? | Assessment: the brief's description of "Prism's OrgSlug newtype + RBAC" and the "MSSP-internal global correlation store" indicates this is prism-side. The plugin's role is to display correlation count N from prism query results, not to maintain the correlation index. Recommend: scope cross-tenant correlation as prism-side for v0.10.0; plugin displays derived artifact correlation counts surfaced by prism MCP tools. Confirm with prism pipeline before F2 spec is finalized. |
| D-DEC-006 | **New prism sensor metrics skill naming** — `metrics` (brief name) conflicts with the existing `generate-metrics` command/skill (Jira-derived effort metrics) | Options: (A) `sensor-metrics` skill + command; (B) extend `generate-metrics` with a `--source prism` mode; (C) use `metrics` and deprecate/rename `generate-metrics`. Option A is safest (no disruption to existing metrics pipeline), but choice affects the command namespace and orchestrator routing. |
| D-DEC-007 | **Shell helper script location** — where do the `.sh`/`.ps1` helper scripts live (MCP config write, version check, credential-set)? | Options: (A) co-located under `skills/<skill-name>/` (e.g., `skills/activate/mcp-config-write.sh`); (B) new `scripts/` top-level directory; (C) under `hooks/` (convention says hooks are Claude Code event handlers — this would be a convention stretch). Option A keeps helpers adjacent to the skills that invoke them and simplifies `${CLAUDE_PLUGIN_ROOT}` relative paths. |
| D-DEC-008 | **Monitoring-loop Jira write scope through require-review** — D-005 marker mechanism currently scoped to `jr issue comment`; monitoring-loop also needs `jr issue create` and `jr issue assign` (for ticket creation and escalation routing) | The D-005 marker scope decision (D-DEC-001) must cover comment, create, and potentially assign for the monitoring-loop's autonomous actions. The marker must carry an action scope field indicating which Jira operations it authorizes, to prevent a comment-scoped marker from authorizing a create. |
| D-DEC-009 | **Tavily MCP dependency tier** — should Tavily be `required` (alongside jr CLI), `recommended` (alongside Perplexity), or `optional` for v0.10.0? | Monitoring-loop Stage 4 uses Tavily for IOC/actor/CVE web-grounded enrichment as a cross-validation layer alongside Perplexity. If Tavily is unavailable, the loop should degrade gracefully (Perplexity-only enrichment). Recommend: `recommended` tier with explicit fallback path; secops-protocol.md entry documenting fallback behavior. |

---

## 6. New Assumptions (ASM-NNN)

| ID | Assumption | Status | Validation Method | Impact if Wrong |
|----|-----------|--------|------------------|----------------|
| ASM-001 | prism binary is available at the path recorded in `settings.json` at monitoring-loop schedule time (not just at activate-time) | UNVALIDATED | monitoring-loop Stage 0 must run `prism --version` connectivity check before any query; fail-loud with explicit error if unavailable | HIGH — all sensor data queries, monitoring-loop, onboarding fail entirely; silent if not checked |
| ASM-002 | `RUST_LOG=off` is injected into the prism MCP server `env` block without exception | UNVALIDATED | Activate shell helper BATS test must assert settings.json contains `"RUST_LOG": "off"` in the prism server env block | HIGH — omission causes prism tracing JSON on stdout to corrupt MCP JSON-RPC framing; all prism tool calls fail with parse errors (silent failure mode per brief §2.1) |
| ASM-003 | `~/.claude/settings.json` is safe to write concurrently from multiple Claude Code instances (no race condition) | UNVALIDATED | Document single-activate constraint; add jq read-back verification in activate shell helper; consider flock on the write | MEDIUM — concurrent activation (two projects both activating simultaneously) could corrupt settings.json; affects all MCP servers system-wide |
| ASM-004 | `claude -p` headless invocation from OS scheduler (cron/Task Scheduler) has access to the same environment (PATH, `${CLAUDE_PLUGIN_DATA}`, MCP servers from `settings.json`) as an interactive session | UNVALIDATED | Manual test of headless invocation in scheduler context before monitoring-loop stories are written | HIGH — monitoring-loop cannot function without reliable headless MCP server access; MCP servers in `settings.json` may not be loaded in headless mode |
| ASM-005 | `${CLAUDE_PLUGIN_DATA}` is a writable, persistent directory that survives across OS scheduler invocations and is accessible from the scheduler's user context | UNVALIDATED | Document expected path per OS (Linux: `~/.local/share/claude`, macOS: `~/Library/Application Support/Claude`, Windows: `%APPDATA%\Claude`); test write/read cycle from a simulated scheduler environment | HIGH — watermarks cannot be persisted without this; every monitoring-loop run queries full 24h history instead of incremental |
| ASM-006 | `jr` CLI is available and authenticated in the OS scheduler's environment (PATH includes jr binary; `~/.config/jr/config.toml` is readable from scheduler user context) | UNVALIDATED | monitoring-loop must check `jr auth status` as a Stage 0 gate before any Jira operations; fail-loud if unavailable | HIGH — all Jira ticket operations fail silently if jr unavailable in scheduler context; monitoring-loop produces loop output but writes no tickets |
| ASM-007 | Jira API rate limits accommodate monitoring-loop invocation frequency (15-min schedule × N orgs × M sensors × dedup query per alert) | UNVALIDATED | Estimate: 4 orgs × 4 sensors × ~20 alerts/run × 1 dedup query + 1 ticket action = ~200 API calls per 15-min run = ~800 req/hour; Jira Cloud limit is ~300 req/min = well within; validate at higher alert volumes | MEDIUM — rate limiting causes ticket creation failures; dedup queries fail silently; loop marks watermark progress but incomplete ticket actions leave alerts unlogged |
| ASM-008 | prism MCP tool names follow the pattern `mcp__prism__<tool>` (e.g., `mcp__prism__query`, `mcp__prism__prism_describe`) as derived from the prism MCP server manifest | UNVALIDATED | Read prism binary's MCP tool manifest once binary is available; secops-protocol.md and hooks.json bias-check-reminder matcher depend on these names being correct | HIGH — all PrismQL calls in skills/loop use hardcoded tool names; wrong names cause "unknown tool" errors on every invocation |

---

## 7. New Risks (R-NNN)

| ID | Risk | Category | Status | Mitigation |
|----|------|---------|--------|-----------|
| R-001 | **Autonomy-policy misconfiguration silently auto-closes HIGH severity alerts** — a mis-set `autonomy_enabled: true` with overly broad `require_review: false` scope allows the monitoring-loop to close CRIT/HIGH alerts without human review, violating the §3.9 hard floors | Security / Operational | OPEN | Implement §3.9 hard floor list as unconditional code branches in monitoring-loop, not as config-evaluated conditions; hardcode the must-surface categories (HIGH/CRIT alerts, critical-asset alerts, high-impact ATT&CK techniques T1003/T1068/T1021/T1041, Indeterminate verdicts, degraded-sensor verdicts); add BATS test that verifies these categories cannot be auto-closed regardless of `autonomy_enabled` or `require_review` config values |
| R-002 | **D-005 marker mechanism introduces new CRITICAL gate bypass vector** — a poorly designed marker (no expiry, replayable, injectable via SEC-001 surface) creates a new SEC-009-class bypass of the require-review gate for `jr issue comment` | Security / Authorization | OPEN | Marker must be: (a) time-bounded (30-second TTL maximum), (b) single-use (invalidated after first successful `jr issue comment`), (c) written to a path that is NOT readable from Jira ticket body content (cannot be injected via SEC-001), (d) include a scope field specifying the authorized Jira operations; new BATS tests must cover all four properties; consider independent adversarial review of the marker implementation before F5 |
| R-003 | **Watermark corruption or concurrent loop execution causes duplicate alert processing or missed events** — a truncated write (power loss mid-write), a concurrent run (15-min schedule with a 14-min run time), or a future-timestamp watermark causes silent data integrity failure | Data Integrity / Reliability | OPEN | Use atomic write (write to `.tmp` file, then `mv`/`Move-Item` rename — kernel-guaranteed atomic on POSIX); use advisory lockfile (`flock` / PowerShell mutex) to prevent concurrent execution; on read, validate ISO 8601 format and reject future timestamps (fallback to 24h window on invalid watermark); log every watermark read/write with before/after values |
| R-004 | **RUST_LOG=off omission corrupts MCP JSON-RPC framing silently** — if the activate skill or helper fails to inject `RUST_LOG=off` into the prism MCP server env block, prism's tracing subscriber writes structured JSON to stdout, which the MCP host parses as tool-call responses, producing unpredictable tool output (brief §2.1) | Integration / Reliability | OPEN | Shell helper must hardcode `"RUST_LOG": "off"` in the MCP server env block; BATS test must assert the written settings.json contains `RUST_LOG: off` before the test exits; secops-protocol.md must document this as a P0 requirement with the failure mode described explicitly |
| R-005 | **prism binary unavailability at monitoring-loop schedule time** — prism path not in scheduler PATH, binary deleted, or binary moved after activate ran | Operational / Availability | OPEN | monitoring-loop Stage 0 must check prism connectivity (version probe) before any queries; emit a `prism-connectivity-failure` finding to Jira (or stdout if Jira also unavailable) rather than silent no-op; treat prism-connectivity failure as a sensor-silence-class event (§3.7 — absence of data is a first-class alert) |
| R-006 | **Sensor-silence ticket spam for long-running silence events** — brief §3.7 says "do NOT auto-close or suppress"; without a dedup check, every 15-minute loop invocation during a multi-hour sensor silence creates a new `[BLIND-SPOT]` Jira ticket | Operational / Jira hygiene | OPEN | Require ticket dedup check for `[BLIND-SPOT]` tickets before creating new ones; JQL: open BLIND-SPOT ticket for same org+sensor → append comment; only create new ticket if no open BLIND-SPOT exists; this is the §3.4 append/new rule applied to sensor-silence findings |
| R-007 | **Cross-tenant data leakage via PrismQL fanout** — a malformed PrismQL query or prism RBAC misconfiguration returns raw records from another tenant's sensors; the plugin passes this data into Jira comments or Perplexity/Tavily enrichment, leaking customer data across tenant boundaries | Security / Privacy | OPEN | All PrismQL queries must include explicit org-scoping (prism's OrgSlug newtype enforces this at the engine level per the brief, but the plugin must not construct queries that bypass org scope); plugin must never log raw PrismQL response bodies to Jira; cross-tenant correlation (§3.6) must only use derived artifacts (IOC hashes, ATT&CK technique IDs) not raw sensor records; `cross_tenant_correlation` config field defaults to `deny` |
| R-008 | **`~/.claude/settings.json` write clobbers existing MCP server configuration** — activate shell helper uses a destructive write pattern instead of `jq` merge, removing other plugins' MCP servers from the user config | Integration / Reliability | OPEN | Activate shell helper must use `jq` merge pattern: `.mcpServers += {"prism": {...}}` — not `.mcpServers = {"prism": {...}}`; BATS test must invoke helper with a pre-existing `mcpServers` block containing an unrelated server and assert that server remains present after the write |

---

## 8. Version Bump Requirement

This delta touches 13 MODIFIED plugin artifacts (14 after REC-001 in delta-analysis.md reclassifies update-jira from DEPENDENT to MODIFIED) including 2 CRITICAL-tier components
(require-review hook, monitoring-loop as a new CRITICAL-per-artifact). The feature
cycle targets `v0.10.0`. The triple version lock (plugin.json + marketplace.json +
tag) must be updated atomically in the F7 convergence phase per existing convention.

The BATS suite will grow from 165 @tests to an estimated 200-230 @tests after new
shell helper coverage is added. The `module-criticality.md` must be updated in F2
to add new component entries (monitoring-loop as CRITICAL per-artifact; 7 new modules
across CRITICAL/HIGH/MEDIUM/LOW tiers).

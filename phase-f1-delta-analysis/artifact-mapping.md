---
document_type: artifact-mapping
producer: business-analyst
version: "1.1"
date: 2026-07-19
feature: prism-integration
feature_version: v0.10.0-feature-prism-integration
status: draft
inputs:
  - .factory/feature/prism-integration-handoff-brief.md
  - .factory/phase-0-ingestion/project-context.md
  - .factory/phase-0-ingestion/behavioral-contracts/ (17 BCs)
  - .factory/holdout-scenarios/HS-INDEX.md
  - .factory/phase-0-ingestion/verification-gap-analysis.md
  - plugins/secops-factory/tests/hooks.bats
  - plugins/secops-factory/tests/skills.bats
  - plugins/secops-factory/tests/integration.bats
  - plugins/secops-factory/tests/parity.bats
input-hash: ""
changelog:
  - "v1.1 (2026-07-19): F1 VP namespace collision fix — VP-SKILL-035/036 renamed to VP-SKILL-050/051 (slots 001–049 occupied by BC-7.01.001 and earlier); F6 VP-HOOK-020 description corrected from 'write-block family' to its actual property (`jr issue changelog` plain-form allow) with marker-mechanism context clarified."
binding_scope_decisions:
  - D-004: full brief scope
  - D-005: DI-013 marker mechanism (require-review hook modified)
  - D-006: demo-unaware except generic jr auth check in activate
---

# Phase F1 — Affected Artifact Mapping
## Feature: prism-integration (v0.10.0-feature-prism-integration)
### Produced: 2026-07-19 | Producer: business-analyst

---

## 0. Executive Summary (Counts)

| Dimension | Count |
|-----------|-------|
| BCs MODIFIED | 6 |
| BCs at-risk-DEPENDENT (no modification mandated yet) | 3 |
| New BC subjects needed | 5 |
| Tests in regression risk zone (direct — modified modules) | ~57 |
| Tests in regression risk zone (dependent — enrichment-completeness) | ~17 |
| HS needing revision | 6 (+ 1 marginal) |
| New HS subjects needed | 10 |
| Existing VPs directly affected | VP-HOOK-020 |
| New VP subjects needed | 5 |
| Feature type | backend |
| Intent | feature |
| Scope | standard |
| Brief requirements unmapped | 1 (minor — see §8.9) |

---

## 1. BC Delta Map

### 1.1 MODIFIED BCs (version-bump required)

**BC-3.01.001 — require-review hook (CRITICAL) → MODIFIED**

Decision D-005 mandates the DI-013 marker mechanism lands in this cycle. The require-review hook is the only enforcement surface for Jira write authorization. The monitoring loop (§3.9) must be able to act within the `require_review` autonomy policy — meaning the hook must be able to distinguish an auto-approved narrow-scope write (e.g., close a confirmed FP with documented history) from a write that requires human gate. A marker mechanism must be added to the hook's allow-path logic. Current semantics: all write patterns deny unconditionally. New semantics: deny unconditionally unless a cryptographically/structurally valid autonomy marker is present AND the write falls within the permitted auto-scope. The write-block-first ordering (Invariant #5, PR #15) and the allowlist remain unchanged; the marker mechanism adds a new conditional allow branch between the write-block check and the fail-closed catch-all.

Additionally: the monitoring loop runs `prism --version` and reads watermark files. If those operations ever transit through Bash tool calls, the allowlist may need prism-related read-only entries. At minimum the activation flow reads `~/.claude/settings.json` — this is already covered by the non-jr fast-path. No change needed for that.

**BC-3.03.001 — disposition-guard hook (HIGH) → MODIFIED**

Brief §3.8 explicitly designates disposition-guard as "the natural enforcement point for documentation completeness" for the monitoring loop's ICD-203-grade verdict record. The hook currently enforces only heading presence (`## Alternatives Considered`). Extension required: the hook must additionally enforce the presence of all mandatory verdict schema fields from §3.8 (disposition, confidence, sensor_health_status, evidence_artifacts, timeline_events, hypotheses_considered, alternatives_rejected, uncertainty_explicit, attack_techniques) in monitoring-loop verdict files before any ticket action executes. The heading-anchored substring check (DI-004 fix, PR #17) is preserved as-is. The new enforcement is additive — it fires only for monitoring-loop verdict files (distinct file naming pattern), not for the existing investigation-* files.

**BC-4.02.001 — update-jira skill (CRITICAL) → MODIFIED**

DI-013 is explicitly deferred to this feature cycle (project-context.md §8, deferred item). The DI-013 resolution (marker mechanism or gated command) changes how update-jira posts comments. The monitoring loop's Jira ticket actions (create, append, link — §3.4) go through update-jira's orchestration. The BC must be revised to document: (a) the DI-013 marker mechanism or gated-command resolution, (b) the four Jira ticket action types from §3.4 (append comment, link related, propose reopen, create new), and (c) the never-auto-reopen-closed invariant (§3.4, hard requirement).

**BC-4.05.001 — assess-priority skill (MEDIUM) → MODIFIED**

Brief §2.4 explicitly upgrades assess-priority: pull 30-day historical baseline from prism for this indicator, check NVD enrichment via `enrich_nvd()` UDF, and apply a Bayesian TP/FP/BTP disposition framework. The existing 6-factor algorithm (CVSS, EPSS, KEV, ACR, exposure, exploit-status) is extended with prism-grounded inputs. The Iron Law ("NO PRIORITY ASSIGNMENT WITHOUT MULTI-FACTOR ASSESSMENT FIRST") remains unchanged; the factor set expands. The KEV unconditional-P1-override remains unchanged. The scoring table needs additional rows for the prism-derived factors. The BC must document new preconditions (prism MCP available or graceful degradation to existing 6-factor) and revised postconditions.

**BC-5.01.001 — investigate-event skill (HIGH) → MODIFIED**

Brief §2.4 explicitly upgrades investigate-event to: (1) query prism for raw OCSF-normalized event data via PrismQL, (2) query adjacent events in the time window, (3) enrich via ThreatIntel/NVD UDFs, (4) optionally augment with Tavily web context. The existing 7-stage flow is extended: prism evidence queries are inserted into Stage 3 (initial investigation) and Stage 4 (enrichment). The Iron Law ("NO DISPOSITION WITHOUT EVIDENCE CHAIN FIRST"), the Perplexity fallback path, and the local-save-first ordering (Stage 7) remain unchanged. New preconditions: prism MCP connection available (or graceful degradation with warning). DI-013's Stage 7 comment-post friction is addressed by the DI-013 resolution in BC-3.01.001 and BC-4.02.001.

**BC-6.01.001 — activate skill (HIGH) → MODIFIED**

Brief §2.1 mandates four new activate behaviors: (1) locate or download the prism binary from GitHub Releases if absent, (2) run `prism --version` and assert >= v1.0.0-rc.1, (3) write the MCP server block (including `RUST_LOG=off`) into `~/.claude/settings.json` (not `settings.local.json` — this is a global MCP server registration, distinct from the per-project `settings.local.json` activation block), and (4) print credential provisioning instructions. Brief §4.4 adds a fifth requirement: `jr auth check` step in the activation checklist. The existing `settings.local.json` per-project activation block (Postcondition #1, BC-6.01.001) is unchanged. The new MCP server block goes into `settings.json` — the BC must document this as an intentional exception to the "never modify settings.json" invariant (Invariant #2), scoped narrowly to the `mcpServers.prism` block only. The corrupt-file guard and competing-agent check must also cover the `settings.json` prism block write path.

### 1.2 at-risk-DEPENDENT BCs (monitor for cascade; no mandatory BC modification yet)

**BC-3.02.001 — enrichment-completeness hook (HIGH) → at-risk-DEPENDENT**

The monitoring loop writes verdict records (§3.8) and investigation files via investigate-event. Enrichment-completeness fires on `PreToolUse/Write` for files matching investigation-* patterns. If the monitoring loop writes files that match the current hook pattern, the hook already enforces the 4-section requirement (Executive Summary, Alert Details, Disposition, Next Actions). If the verdict schema (§3.8) introduces additional required sections, the hook may need extension. WATCH: if disposition-guard's new schema enforcement (BC-3.03.001 MODIFIED) covers the full verdict schema, enrichment-completeness may remain unchanged. Confirm during story decomposition.

**BC-4.06.001 — read-ticket skill (MEDIUM) → at-risk-DEPENDENT**

The monitoring loop uses investigate-event (which uses read-ticket) as part of its pipeline for prism-linked investigations. Read-ticket's SEC-001 injection surface now includes prism-sourced event data that may be appended to Jira tickets. The skill itself may not change structurally, but its threat model note must be extended to cover prism OCSF data as a new injection surface. Confirm during story authoring.

**BC-6.01.002 — deactivate skill (MEDIUM) → at-risk-DEPENDENT**

If activate now writes a `mcpServers.prism` block into `settings.json`, deactivate must offer the option to remove it. Current deactivate contracts do not cover settings.json cleanup (only settings.local.json). If the prism MCP block is to be cleaned up on deactivation, BC-6.01.002 requires a version bump. Defer this decision to story decomposition; mark as at-risk.

### 1.3 UNCHANGED BCs (stable across this feature cycle)

| BC | Subject | Justification |
|----|---------|---------------|
| BC-3.04.001 | bias-check-reminder hook | LOW tier PostToolUse advisory; no structural change. The monitoring loop's ICD-203 analytic rigor (§3.8) requires documenting hypotheses but this is enforced by disposition-guard (BC-3.03.001), not by bias-check-reminder. |
| BC-3.05.001 | handoff-validator hook | SubagentStop guard; monitoring loop runs headlessly as `claude -p`, no subagent dispatch path. |
| BC-3.06.001 | session-greeting hook | SessionStart banner. Monitoring loop runs as `claude -p --output-format json`; session-greeting emits to stderr (not stdout), so it cannot corrupt the JSON output stream. Unchanged. |
| BC-4.01.001 | enrich-ticket skill | 8-stage CVE enrichment pipeline. Not directly modified. Note: assess-priority (sub-skill at Stage 6) is being enhanced; the enrich-ticket flow calls assess-priority as a sub-step but the enrich-ticket orchestration itself is unchanged. |
| BC-4.03.001 | review-enrichment skill | Fresh-context quality review for vulnerability pipeline. Not in scope. |
| BC-4.04.001 | adversarial-review-secops | Convergence loop for vulnerability pipeline. Not in scope. |
| BC-7.01.001 | create-advisory skill | Advisory pipeline. Not in scope. |
| BC-8.01.001 | analyze-ticket-effort skill | Metrics pipeline (effort measurement). Not in scope. |

### 1.4 New BC Subjects Needed (do not author — names + proposed slots only)

| Proposed Slot | Subject | Justification |
|---------------|---------|---------------|
| **BC-6.01.003** | onboard-customer skill — org slug/UUID provisioning, prism.toml append, directory creation | New lifecycle-management skill (same S=6, SS=01 subsystem as activate/deactivate, new NNN). Brief §2.3. |
| **BC-6.01.004** | onboard-sensor skill — per-sensor overlay creation, AD-017 credential walkthrough, `SELECT 1` verification | New lifecycle-management skill (same subsystem). Brief §2.3. The AD-017 never-credentials-in-chat invariant is the critical behavioral property. |
| **BC-8.02.001** | metrics skill — prism per-org sensor telemetry via `prism_sensor_health` query | New metrics-family skill (S=8, new SS=02, separate from analyze-ticket-effort which is SS=01). Brief §2.4. |
| **BC-9.01.001** | scan-threats skill — PrismQL predefined hunting queries across all orgs, `prism_describe`-guided table enumeration | New threat-hunting section (S=9, new). Brief §2.4. |
| **BC-10.01.001** | monitoring-loop — full autonomous patrol: 8-stage per-alert pipeline, watermarks, Jira-first rules, Indeterminate hard floor, sensor-silence blind-spot, ICD-203 defensible record, autonomy policy | New monitoring subsystem (S=10, new). This is the largest and most complex new BC in the cycle. Brief §3.1–§3.10. Key invariants: Indeterminate never auto-closed; sensor-silence is a positive risk signal; never-auto-reopen-closed; watermark monotonic; RUST_LOG=off in all prism MCP configs. |

---

## 2. Regression Risk Zone

Tests that cover modules being modified. These must stay green across all PRs in this feature cycle.

### 2.1 hooks.bats — require-review (BC-3.01.001 MODIFIED, CRITICAL)

All 28 require-review tests. By @test name:

| @test name | Line | Risk reason |
|------------|------|-------------|
| `require-review allows non-jr commands` | 9 | Fast-path guard must survive marker mechanism addition |
| `require-review allows jr read-only commands` | 15 | Allowlist must not be disturbed by marker logic |
| `require-review allows jr issue changelog plain form` | 21 | Allowlist expansion from PR #14 |
| `require-review allows jr issue changelog json form (metrics suite)` | 27 | Allowlist |
| `require-review allows jr --output json issue view (metrics suite)` | 33 | Allowlist |
| `require-review allows jr --output json issue list (metrics suite)` | 39 | Allowlist |
| `require-review allows jr --output json issue comments (metrics suite)` | 45 | Allowlist |
| `require-review allows jr assets search (CMDB)` | 51 | Allowlist |
| `require-review allows jr assets view (CMDB)` | 57 | Allowlist |
| `require-review allows jr --version health check` | 63 | Allowlist |
| `require-review blocks jr issue comment without review (SEC-001)` | 69 | Write-block must remain first (Inv #5); SEC-001 guard |
| `require-review blocks unknown mutation-shaped jr subcommand (SEC-002)` | 76 | Fail-closed must not be bypassed by marker |
| `require-review blocks jr issue edit without review` | 82 | Write-block |
| `require-review blocks jr issue move without review` | 89 | Write-block |
| `require-review blocks edit with jr board in args (ADV-0-801 bypass)` | 101 | Bypass regression guard; write-block-first ordering |
| `require-review blocks comment with jr me in args (ADV-0-801 bypass — defeats SEC-001)` | 108 | Bypass regression guard |
| `require-review blocks create with jr sprint in args (ADV-0-801 bypass)` | 115 | Bypass regression guard |
| `require-review blocks move with jr project in args (ADV-0-801 bypass)` | 122 | Bypass regression guard |
| `require-review blocks jr --output json issue edit (write via --output json)` | 133 | --output json write-block |
| `require-review blocks jr --output json issue create (write via --output json)` | 139 | --output json write-block |
| `require-review blocks jr --output json issue comment (write via --output json)` | 145 | --output json write-block |
| `require-review blocks jr --output json issue move (write via --output json)` | 151 | --output json write-block |
| `require-review blocks jr --output json issue assign (write via --output json)` | 157 | --output json write-block |
| `require-review regression: jr issue view still allowed after ADV-0-801 fix` | 165 | Regression guard |
| `require-review regression: jr --output json issue list still allowed after ADV-0-801 fix` | 171 | Regression guard |
| `require-review regression: jr issue changelog still allowed after ADV-0-801 fix` | 177 | Regression guard |
| `require-review blocks jr issue assign without review (DI-005)` | 426 | SM-2 regression guard |
| `require-review blocks jr issue create without review (DI-005)` | 433 | SM-2 regression guard |

### 2.2 hooks.bats — disposition-guard (BC-3.03.001 MODIFIED, HIGH)

| @test name | Line | Risk reason |
|------------|------|-------------|
| `disposition-guard allows non-investigation files` | 246 | New verdict file pattern must not accidentally match |
| `disposition-guard allows investigation without disposition yet` | 252 | In-progress-allow (PC#2/EC-003) must survive schema extension |
| `disposition-guard blocks disposition without alternatives` | 258 | Core deny path |
| `disposition-guard allows disposition with alternatives` | 265 | Core allow path |
| `disposition-guard body-text alternatives-considered (no heading) denies` | 323 | SM-1 regression guard — heading-anchored check must survive schema enforcement addition |
| `disposition-guard heading-form alternatives-considered allows` | 330 | Core allow regression |

### 2.3 skills.bats — activate skill (BC-6.01.001 MODIFIED, HIGH)

| @test name | Line | Risk reason |
|------------|------|-------------|
| `activate skill exists and sets the orchestrator default agent` | 318 | Orchestrator agent value must be unchanged |
| `activate skill targets settings.local.json (never shared settings)` | 323 | Per-project activation block must stay in settings.local.json; new prism block goes to settings.json (separate target) |
| `activate skill is user-invoked only` | 327 | disable-model-invocation must remain true |
| `activate skill has Announce at Start` | 331 | Structural Iron Law compliance |
| `activate skill has >= 6 Red Flag rows` | 335 | Red Flag count will increase with new prism/jr warnings; must be >= 6 |
| `activate and deactivate command wrappers exist` | 354 | Command dispatch still required |

### 2.4 skills.bats — investigate-event (BC-5.01.001 MODIFIED, HIGH)

| @test name | Line | Risk reason |
|------------|------|-------------|
| `investigate-event has Iron Law` | 17 | Iron Law text must be preserved verbatim |
| `investigate-event has Announce at Start` | 43 | Structural compliance |
| `investigate-event has >= 6 Red Flag rows` | 71 | Red Flag count must stay >= 6 (prism-specific red flags will be added) |

### 2.5 skills.bats — assess-priority (BC-4.05.001 MODIFIED, MEDIUM)

| @test name | Line | Risk reason |
|------------|------|-------------|
| `assess-priority has Iron Law` | 13 | Iron Law text must be preserved verbatim |
| `assess-priority has Announce at Start` | 39 | Structural compliance |
| `assess-priority has >= 6 Red Flag rows` | 66 | Red Flag count must stay >= 6 |

### 2.6 integration.bats — require-review and disposition-guard

| @test name | Line | Risk reason |
|------------|------|-------------|
| `integration: require-review denies jr issue edit with full Claude Code payload` | 17 | Full-payload deny regression |
| `integration: require-review allows jr issue view with full payload` | 37 | Full-payload allow regression |
| `integration: disposition-guard blocks disposition without alternatives` | 117 | Full-payload schema enforcement |
| `integration: disposition-guard allows disposition with alternatives` | 136 | Full-payload allow |
| `integration: all blocking hooks emit valid JSON with hookSpecificOutput` | 190 | JSON envelope format must survive any hook changes |
| `integration: all allow envelopes emit valid JSON with hookSpecificOutput` | 205 | JSON envelope format |

### 2.7 parity.bats — require-review and disposition-guard

| @test name | Line | Risk reason |
|------------|------|-------------|
| `parity: require-review allow path` | 51 | .ps1 parity |
| `parity: require-review deny path` | 58 | .ps1 parity |
| `parity: require-review read-only jr allow path` | 66 | .ps1 parity |
| `parity: disposition-guard deny (disposition without alternatives)` | 88 | .ps1 parity |
| `parity: disposition-guard allow (alternatives documented)` | 96 | .ps1 parity |

### 2.8 at-risk-DEPENDENT: enrichment-completeness (BC-3.02.001, HIGH)

These tests are NOT directly in the modification scope but fire on investigation files that the monitoring loop writes. If the monitoring-loop verdict file naming pattern overlaps with the investigation-* pattern, these tests become directly relevant:

| @test name | Line |
|------------|------|
| `enrichment-completeness allows non-enrichment files` | 185 |
| `enrichment-completeness blocks incomplete enrichment` | 191 |
| `enrichment-completeness allows complete enrichment` | 198 |
| `enrichment-completeness body-text section names (no headings) denies for enrichment` | 340 |
| `enrichment-completeness body-text section names (no headings) denies for investigation` | 347 |
| `enrichment-completeness allows complete investigation document` | 357 |
| `enrichment-completeness denies investigation missing Alert Details` | 364 |
| `enrichment-completeness denies investigation missing Next Actions` | 371 |
| `enrichment-completeness denies investigation missing Disposition` | 378 |
| `enrichment-completeness denies investigation missing Executive Summary` | 385 |
| `enrichment-completeness hook enrichment sections match security-enrichment template` | 396 |
| `enrichment-completeness hook investigation sections match event-investigation template` | 402 |

Plus integration.bats enrichment-completeness tests (lines 58, 77, 95) and parity.bats (lines 73, 80).

**Regression risk zone totals:**
- Direct (modified BCs): 28 + 6 + 6 + 3 + 3 + 6 + 5 = **57 tests**
- Dependent (enrichment-completeness): 12 + 3 + 2 = **17 tests**

---

## 3. Holdout Scenario Impact

### 3.1 Remain valid as-is (no revision needed)

| HS ID | Reason valid |
|-------|-------------|
| HS-002 | require-review read-only allowed — allowlist logic unchanged by marker mechanism |
| HS-003 | assign blocked (SM-2 regression guard) — write-block remains first |
| HS-004 | Non-jr commands always allowed — fast-path guard unchanged |
| HS-006 | update-jira invalid CVSS field skipped — CVSS field handling unchanged |
| HS-007 | update-jira priority mapping — mapping logic unchanged |
| HS-009 | enrichment-completeness blocks incomplete — hook logic unchanged |
| HS-010 | enrichment-completeness complete doc saves — 4-section requirement unchanged |
| HS-011 | enrichment-completeness ignores non-enrichment files — unchanged |
| HS-012 | disposition-guard blocks no-alternatives — heading check unchanged |
| HS-013 | disposition-guard allows in-progress — in-progress-allow unchanged |
| HS-014 | SM-1 regression guard — heading-anchored check is preserved; new schema enforcement is additive |
| HS-015 | enrich-ticket no-CVE prompt — unchanged |
| HS-016 | enrich-ticket EPSS mandatory — unchanged |
| HS-017 | review-enrichment missing EPSS finding — unchanged |
| HS-018 | review-enrichment reviewer disagrees — unchanged |
| HS-019 | adversarial-review min 2 passes — unchanged |
| HS-020 | adversarial-review score 6.8 → REWORK — unchanged |
| HS-022 | investigate-event internal IP → lateral movement — prism enrichment adds evidence but the lateral movement assessment requirement is preserved |
| HS-024 | activate competing agent — competing-agent check path is unchanged (it fires before any MCP block write) |
| HS-025 | deactivate no other-plugin removal — unchanged |
| HS-028 | assess-priority KEV unconditional P1 — KEV override logic is explicitly preserved in the modified BC |
| HS-030 | read-ticket no-CVE prompts user — unchanged |
| HS-031 | create-advisory blocked without source verification — unchanged |
| HS-032 | create-advisory sources produce advisory — unchanged |
| HS-033 | analyze-ticket-effort Iron Law guard — unchanged |
| HS-034 | analyze-ticket-effort empty worklogs → reconstruction — unchanged |

### 3.2 Need revision (before story decomposition)

| HS ID | Title | Revision needed |
|-------|-------|-----------------|
| **HS-001** | require-review write blocked without review approval | Marker mechanism adds a conditional allow path for narrow-scope monitoring-loop auto-actions. The scenario must be revised to confirm: (a) the test command does NOT carry a valid autonomy marker → must still deny; (b) a command WITH a valid marker but outside the auto-permitted scope → still deny. The core "deny without review" property holds but the test fixture must explicitly present a markerless command. |
| **HS-005** | update-jira halts without review approval marker | DI-013 resolution changes the review-approval marker format. The scenario must be updated with the new marker format and verify: old/invalid marker → halt; new/valid marker → proceed. Critical: this HS is the only behavioral guard for the DI-013 change. |
| **HS-008** | update-jira adversarial content does not alter update behavior | DI-013 marker mechanism introduces a new code path in update-jira for monitoring-loop auto-actions. The adversarial content scenario must verify that a Jira ticket body containing text that resembles an autonomy marker does not trigger the auto-action path (injection via ticket content). |
| **HS-021** | investigate-event FP without alternatives → disposition blocked | The prism evidence collection step (new Stage 3/4 additions) feeds into the disposition. The test fixture should include prism evidence data to confirm the hook enforcement still fires when alternatives are absent, even with prism evidence present. Minimal change: update the fixture to include a prism-query result; core assertion (disposition blocked without alternatives) unchanged. |
| **HS-023** | activate corrupt settings.local.json not overwritten | Activate now also writes a prism MCP block to `settings.json`. The scenario must be extended to cover: (a) corrupt `settings.local.json` — unchanged, still stops (b) corrupt `settings.json` when writing the prism MCP block — new case: must also stop, not partially write. |
| **HS-026** | require-review write command with embedded read-only token still blocked | This is the SEC-009/ADV-0-801 regression guard. With the DI-013 marker mechanism, a new bypass vector opens: a write command that embeds a syntactically-valid autonomy marker in its arguments (e.g., `jr issue edit KEY --summary "AUTONOMY-APPROVED:xxx"`) must NOT bypass the write-block. The scenario must add a fixture with an embedded fake-marker to confirm write-block-first ordering defeats it. |
| **HS-027** | assess-priority single-CVSS Iron Law violation | The modified assess-priority adds prism historical baseline and NVD enrichment as additional factors. The Iron Law scenario must confirm: even when prism returns a high-frequency historical signal, single-CVSS assignment is still flagged as a violation. The test fixture should include a prism response to confirm the Iron Law fires regardless of prism data. |

**Marginal — HS-029** (read-ticket SEC-001 injection guard): The brief §2.2 adds prism as a new data source whose results may be appended to Jira tickets or used as investigation input. The injection surface now includes OCSF-normalized prism records. HS-029 tests read-ticket specifically (Jira ticket body injection). No structural change to the test needed, but the scenario notes should be annotated: "Also covers prism result injection path — OCSF-normalized sensor data arriving via MCP tool responses is an injection surface equivalent to Jira ticket body content." Revision is advisory, not blocking.

### 3.3 New Holdout Scenario Subjects Needed

Ten new scenario subjects. These feed the HS authoring step in Phase F2/F3.

| Proposed HS slot | Subject | Source in brief |
|-----------------|---------|-----------------|
| **HS-035** | monitoring-loop Indeterminate hard floor — loop emits Indeterminate verdict → routes to human via Jira `[REVIEW-REQUIRED]` tag; never auto-closes | §3.3 "Indeterminate is a hard floor"; Q1, Q6 |
| **HS-036** | never-auto-reopen-closed ticket — loop finds same root cause as a Closed ticket → opens NEW ticket and links, does NOT reopen; no config option can override | §3.4 "NEVER auto-reopen a closed ticket" |
| **HS-037** | sensor-silence positive risk signal — sensor `last_seen_ts > 24h`, zero rows → loop emits BLIND-SPOT finding (Indeterminate-due-to-missing-telemetry), not "nothing to report" | §3.7 |
| **HS-038** | watermark monotonicity — watermark for org×sensor never regresses; on process-restart the loop resumes from persisted watermark, not from beginning of history | §3.10 |
| **HS-039** | RUST_LOG=off MCP framing — activate always injects `RUST_LOG=off` in the prism MCP env block; absence of this flag causes prism to corrupt MCP JSON-RPC framing | §2.1 "Important: RUST_LOG=off must always be injected" |
| **HS-040** | AD-017 no-credentials-in-chat — onboard-sensor never asks user to paste credential value in chat; it provides the `echo | prism credential set` command and instructs the user to run it in their terminal | §2.3 "The skills must never ask the user to paste credentials into a chat message" |
| **HS-041** | activate prism version gate — activate blocks and emits download link when prism binary version < v1.0.0-rc.1; proceeds on >= v1.0.0-rc.1 | §2.1 "Runs prism --version and asserts >= 1.0.0-rc.1" |
| **HS-042** | activate jr auth check blocking — activate prints a blocking error with setup instructions when jr is not configured or not authenticated | §4.4 |
| **HS-043** | disposition-guard rejects monitoring-loop verdict missing mandatory schema fields — a verdict file without `sensor_health_status` or `evidence_artifacts` is blocked before ticket action | §3.8; BC-3.03.001 MODIFIED |
| **HS-044** | onboard-sensor SELECT 1 verification — after credential provisioning, onboard-sensor runs `SELECT 1` via the query MCP tool and fails loudly if prism does not respond; does not proceed to main onboarding success message without confirmation | §2.3 "Runs SELECT 1 via the query MCP tool to confirm prism accepts connections" |

---

## 4. Verification Property Impact

### 4.1 Existing VPs directly affected

**VP-HOOK-020** (BC-3.01.001 — `jr issue changelog` plain-form allow) is indirectly affected by D-005. VP-HOOK-020 itself describes a specific allowlist entry (`jr issue changelog` is explicitly permitted); the entry is not changed. However, the DI-013 marker mechanism inserts a new conditional-allow branch between the write-block check and the allowlist evaluation in the hook's decision path. Any audit of allowlist-evaluation-order context (which VP-HOOK-020 sits within) must account for the new branch. The property described by VP-HOOK-020 — that `jr issue changelog` is allowed — remains unchanged and still passes. Coverage of the new conditional-allow path arrives via VP-HOOK-024 (marker validation soundness), not VP-HOOK-020.

VP-HOOK-021, VP-HOOK-022, VP-HOOK-023: unchanged (fail-closed on unknown subcommand, broader allowlist families, --output json write-block family are not modified).

### 4.2 New VP subjects needed

| Proposed VP-NNN | Property | Subsystem | Source |
|-----------------|---------|-----------|--------|
| **VP-HOOK-024** | Marker validation soundness: a structurally invalid or forged autonomy marker in a Bash command argument does not cause require-review to emit allow; write-block evaluation precedes marker parsing | require-review hook | HS-026 revision; DI-013 marker mechanism |
| **VP-HOOK-025** | Disposition schema completeness enforcement: disposition-guard blocks a monitoring-loop verdict file that is missing any mandatory field from the §3.8 schema (disposition, confidence, sensor_health_status, evidence_artifacts, hypotheses_considered, alternatives_rejected, uncertainty_explicit, attack_techniques) | disposition-guard hook | §3.8; BC-3.03.001 MODIFIED |
| **VP-HOOK-026** | Indeterminate non-overridability: no autonomy policy configuration (`require_review`, `autonomy_enabled`, or the monitoring loop's auto-scope definition) can cause an Indeterminate verdict to be auto-closed; the monitoring loop always routes Indeterminate to human | monitoring-loop / disposition enforcement | §3.3 "hard floor — not configurable off"; Q1, Q6 |
| **VP-SKILL-050** | Watermark monotonicity: the monitoring loop's watermark write for each org×sensor is always >= the previous persisted value; the loop never processes an already-processed event window on restart | monitoring-loop | §3.10 |
| **VP-SKILL-051** | Prism version gate soundness: activate rejects (with download link) any prism binary reporting version < 1.0.0-rc.1 via semver comparison; reports acceptance for >= 1.0.0-rc.1; the version check happens BEFORE any MCP config write | activate skill | §2.1 |

---

## 5. Feature Type Classification

**Type: backend**

Justification: secops-factory is a CLI/agent plugin with no browser UI, no visual components, and no frontend layer. All deliverables in this feature cycle are: markdown skill files (new and modified), shell/PowerShell helpers, MCP configuration logic, enforcement hooks (shell), and a new autonomous monitoring loop invoked via `claude -p` CLI. The closest analog in the taxonomy to this kind of work is "backend" — server-side logic and integrations, no UI surface. "Infrastructure" would apply if the work were primarily CI/CD, containerization, or deployment tooling; this feature is primarily domain-logic additions to an existing plugin.

---

## 6. Intent Classification

**Intent: feature**

Justification: The prism-integration cycle introduces a fundamentally new capability set — prism MCP integration, customer/sensor onboarding, autonomous monitoring loop, threat hunting, per-org metrics — that does not exist in the v0.9.0 baseline. The `investigate-event` and `assess-priority` enhancements are folded into this cycle as sub-enhancements to the feature (brief §2.4); they are not standalone bug fixes and their enhancement value is contingent on the prism integration being in place (they call prism APIs). DI-013 resolution (marker mechanism) is a deferred debt item from Phase 0 but is activated by and required for the monitoring loop's autonomy policy, making it a feature enabler.

---

## 7. Scope Classification

**Scope: standard**

Justification: Non-trivial by any measure. The cycle adds 5 new skills (onboard-customer, onboard-sensor, metrics, scan-threats, monitoring-loop), modifies 4 existing CRITICAL/HIGH-tier skills and hooks, resolves a deferred Phase 0 drift item (DI-013) that touches the CRITICAL require-review gate, and introduces an autonomous patrol subsystem with watermarks, multi-stage alert triage, Jira-first ticket management, and ICD-203-grade documentation enforcement. The regression risk zone spans 57 tests directly and 17 more transitively. "Trivial" requires a change set where all affected modules are LOW tier, no hooks are modified, and no new BCs are needed — that does not describe this cycle.

---

## 8. Coverage Checklist — Brief §2 and §3 Requirements

Every requirement from brief §2 and §3 mapped to: (a) new/modified component, (b) BC slot, (c) test surface.

### §2.1 activate — MCP wiring

| Requirement | Component | BC | Test surface |
|------------|-----------|-----|-------------|
| Locate or download prism binary from GitHub Releases | activate/SKILL.md + shell helper | BC-6.01.001 (MODIFIED) | skills.bats structural; new BATS: missing-binary error + exit code |
| `prism --version` >= v1.0.0-rc.1 | activate/SKILL.md + shell helper | BC-6.01.001; VP-SKILL-051 | new BATS: version mismatch error; HS-041 |
| Write MCP server block to `~/.claude/settings.json` (not settings.local.json) | activate/SKILL.md + shell helper | BC-6.01.001 | new BATS: correct JSON after write; settings.local.json unchanged |
| `RUST_LOG=off` always injected in MCP env block | activate/SKILL.md | BC-6.01.001 | new BATS; HS-039 |
| Verify MCP connection via `prism --version` subprocess | activate/SKILL.md | BC-6.01.001 | new BATS: subprocess result logged |
| Print credential provisioning instructions | activate/SKILL.md | BC-6.01.001 | skills.bats structural (Red Flags) |
| `jr auth check` step (§4.4) | activate/SKILL.md | BC-6.01.001 | new BATS; HS-042 |

### §2.2 rules/secops-protocol.md prism registry entry

| Requirement | Component | BC | Test surface |
|------------|-----------|-----|-------------|
| Prism entry: when to use query MCP tool, PrismQL syntax, error recovery | data/secops-protocol.md (new section) | No dedicated BC — data KB entry; captured as a VP note in BC-10.01.001 | skills.bats: new structural test checking prism entry presence in secops-protocol.md |
| Tavily addition to protocol entry | data/secops-protocol.md (new Tavily sub-entry) | Same as above | Same structural test |

### §2.3 onboard-customer skill

| Requirement | Component | BC | Test surface |
|------------|-----------|-----|-------------|
| Prompts for org slug and UUID (or auto-generates UUID v7) | skills/onboard-customer/SKILL.md (new) + command | BC-6.01.003 (new) | skills.bats structural; new BATS |
| Appends [[orgs]] entry to prism.toml | onboard-customer | BC-6.01.003 | new BATS |
| Creates `<spec_dir>/customers/<org_slug>/` directory | onboard-customer | BC-6.01.003 | new BATS |
| Prints credential provisioning instructions | onboard-customer | BC-6.01.003 | skills.bats structural |

### §2.3 onboard-sensor skill (with AD-017)

| Requirement | Component | BC | Test surface |
|------------|-----------|-----|-------------|
| Prompts for sensor ID and base_url | skills/onboard-sensor/SKILL.md (new) + command | BC-6.01.004 (new) | skills.bats structural |
| Writes `<sensor_id>.sensor.toml` with extends/instance_id/base_url | onboard-sensor | BC-6.01.004 | new BATS |
| AD-017 credential walkthrough (never paste in chat) | onboard-sensor | BC-6.01.004 | HS-040 |
| Verifies credential write via `prism_describe` (not re-read) | onboard-sensor | BC-6.01.004 | new BATS |
| Runs `SELECT 1` to confirm prism connection | onboard-sensor | BC-6.01.004 | HS-044 |

### §2.4 investigate-event — prism evidence collection

| Requirement | Component | BC | Test surface |
|------------|-----------|-----|-------------|
| Query prism for raw OCSF-normalized event data | skills/investigate-event/SKILL.md (MODIFIED) | BC-5.01.001 (MODIFIED) | skills.bats structural; HS-021 revision |
| Query adjacent events via PrismQL temporal predicates | investigate-event | BC-5.01.001 | skills.bats structural |
| Enrich indicators via ThreatIntel/NVD UDFs | investigate-event | BC-5.01.001 | skills.bats structural |
| Optionally augment with Tavily web search | investigate-event | BC-5.01.001 | skills.bats structural |
| Return structured evidence bundle | investigate-event | BC-5.01.001 | structural; HS-021 revision |

### §2.4 assess-priority — prism-grounded scoring

| Requirement | Component | BC | Test surface |
|------------|-----------|-----|-------------|
| Pull 30-day historical baseline from prism | skills/assess-priority/SKILL.md (MODIFIED) | BC-4.05.001 (MODIFIED) | skills.bats structural; HS-027 revision |
| Check NVD enrichment via `enrich_nvd()` UDF | assess-priority | BC-4.05.001 | skills.bats structural |
| Apply Bayesian TP/FP/BTP disposition framework | assess-priority | BC-4.05.001 | skills.bats structural; HS-027 revision |
| Output: priority/confidence/disposition/rationale | assess-priority | BC-4.05.001 | HS-028 valid as-is |

### §2.4 metrics — prism sensor telemetry

| Requirement | Component | BC | Test surface |
|------------|-----------|-----|-------------|
| Query `prism_sensor_health` per org | skills/metrics/SKILL.md (new) + command | BC-8.02.001 (new) | skills.bats structural |
| Returns: last-seen timestamp, row counts, error rate per org×sensor | metrics | BC-8.02.001 | skills.bats structural |

### §2.4 scan-threats — proactive threat hunting

| Requirement | Component | BC | Test surface |
|------------|-----------|-----|-------------|
| Execute predefined PrismQL hunting queries across all orgs | skills/scan-threats/SKILL.md (new) + command | BC-9.01.001 (new) | skills.bats structural |
| `prism_describe` to enumerate tables before querying | scan-threats | BC-9.01.001 | skills.bats structural |
| Results grouped by severity | scan-threats | BC-9.01.001 | skills.bats structural |

### §3.1–§3.2 Monitoring loop — per-alert pipeline order and full algorithm

| Requirement | Component | BC | Test surface |
|------------|-----------|-----|-------------|
| 8-stage pipeline: validate → known-FP → categorize → enrich → score → dispose → ticket → document | monitoring-loop skill/prompt (new) | BC-10.01.001 (new) | HS-035–HS-044; integration tests |
| Validation and known-FP BEFORE enrichment spend | monitoring-loop | BC-10.01.001 | HS structural; integration |
| Stage 0 sensor health check per org | monitoring-loop | BC-10.01.001 | HS-037 |
| Watermark load/update per org×sensor | monitoring-loop | BC-10.01.001 | HS-038 |

### §3.3 Four-disposition schema

| Requirement | Component | BC | Test surface |
|------------|-----------|-----|-------------|
| TP/FP/BTP/Indeterminate as first-class schema values (not free-text) | monitoring-loop + disposition-guard | BC-10.01.001; BC-3.03.001 (MODIFIED) | HS-035; hooks.bats new tests |
| Indeterminate hard floor — never auto-close | monitoring-loop | BC-10.01.001; VP-HOOK-026 | HS-035 |

### §3.4 Jira-first rules

| Requirement | Component | BC | Test surface |
|------------|-----------|-----|-------------|
| Duplicate (same root cause, open) → append comment | monitoring-loop + update-jira | BC-10.01.001; BC-4.02.001 (MODIFIED) | new integration test |
| Related (same asset/IOC, open, different cause) → link | monitoring-loop + update-jira | BC-10.01.001; BC-4.02.001 | new integration test |
| Resolved (same root cause) → surface to human; propose reopen; do NOT auto-reopen | monitoring-loop | BC-10.01.001 | new HS |
| Closed (same root cause) → never auto-reopen; create NEW ticket; link | monitoring-loop | BC-10.01.001 | HS-036 |

### §3.5 SLA impact surfacing

| Requirement | Component | BC | Test surface |
|------------|-----------|-----|-------------|
| State SLA impact explicitly on append/link/propose-reopen | monitoring-loop | BC-10.01.001 | new HS |
| Never silently change SLA accounting | monitoring-loop | BC-10.01.001 | new HS |
| Per-tenant `sla_reopen_behavior` and `resolved_to_closed_window_hours` config fields | monitoring-loop config | BC-10.01.001 | structural |

### §3.6 Cross-tenant campaign correlation — scope assessment

**Scope verdict: plugin-side constraint only (prism-side architecture).**

The MSSP-global correlation store, anonymized IOC federation, and per-tenant RBAC isolation are prism-side architecture (prism's `OrgSlug` newtype, AD-017 AI-opaque credentials). The secops-factory plugin's responsibility is narrower: (1) never construct a PrismQL query without an org_slug scope constraint (all queries are per-tenant); (2) document the tenant-isolation invariant in BC-10.01.001; (3) the monitoring loop's FOR EACH org_slug outer loop is the natural enforcement boundary.

The brief §3.6 cross-tenant "anonymized derived artifacts only" path is a prism release concern. The demo framing note (§3.6 last paragraph) is out of scope per D-006.

| Requirement | Component | BC | Test surface |
|------------|-----------|-----|-------------|
| Never construct cross-tenant raw queries (always scope by org_slug) | monitoring-loop | BC-10.01.001 (tenant isolation invariant) | new HS (cross-tenant query attempt → per-tenant scoping enforced) |

### §3.7 Sensor silence as positive risk signal

| Requirement | Component | BC | Test surface |
|------------|-----------|-----|-------------|
| Sensor silence → emit BLIND-SPOT finding; disposition = Indeterminate-due-to-missing-telemetry | monitoring-loop | BC-10.01.001 | HS-037 |
| `sensor_health_status` field: healthy/degraded/silent | monitoring-loop verdict schema | BC-10.01.001; BC-3.03.001 (MODIFIED) | HS-043 |
| Silent/degraded status qualifies verdict; does not suppress it | monitoring-loop | BC-10.01.001 | HS-037 |

### §3.8 ICD-203 documentation standard

| Requirement | Component | BC | Test surface |
|------------|-----------|-----|-------------|
| Mandatory fields per verdict (full schema from §3.8) | monitoring-loop output + disposition-guard enforcement | BC-10.01.001; BC-3.03.001 (MODIFIED) | HS-043; hooks.bats new tests |
| Chain-of-custody provenance (evidence by identifier + hash) | monitoring-loop | BC-10.01.001 | structural |
| Agent/human attribution on every action | monitoring-loop `agent_actions` + `human_actions` | BC-10.01.001 | structural |
| ICD-203 hypotheses_considered + alternatives_rejected fields | monitoring-loop + disposition-guard | BC-3.03.001 (MODIFIED) | HS-043 |

### §3.9 Autonomy policy — hard floors + kill switch

| Requirement | Component | BC | Test surface |
|------------|-----------|-----|-------------|
| Auto-close default OFF | monitoring-loop config | BC-10.01.001 | structural |
| Hard-floor list (high severity, critical assets, Indeterminate, novel, degraded-sensor, cross-tenant) | monitoring-loop + require-review | BC-10.01.001; VP-HOOK-026 | HS-035 |
| `autonomy_enabled: bool` kill switch | monitoring-loop config | BC-10.01.001 | structural |
| auto/propose-only/requires-human-approval annotation on every action | monitoring-loop `agent_actions` | BC-10.01.001 | structural |
| DI-013 marker mechanism enabling narrow auto-scope | require-review hook | BC-3.01.001 (MODIFIED) | HS-001 revision; HS-026 revision |

### §3.10 Scheduling and watermarks

| Requirement | Component | BC | Test surface |
|------------|-----------|-----|-------------|
| Invoked via `claude -p` headless | docs / activation instructions | BC-10.01.001 | structural |
| Watermarks at `${CLAUDE_PLUGIN_DATA}/watermarks/<org_slug>/<sensor_id>` | monitoring-loop | BC-10.01.001 | HS-038 |
| First-run: query `WHERE _time >= now() - INTERVAL 24 HOURS` | monitoring-loop | BC-10.01.001 | structural |

### §4 Demo Jira project — OUT OF SCOPE (D-006)

All of §4 is out of scope per decision D-006 (demo-unaware). The single exception is the generic `jr auth check` in `activate`, which is already mapped under §2.1 / §4.4 above and captured in BC-6.01.001 (MODIFIED) and HS-042.

| §4 sub-section | Status |
|---------------|--------|
| §4.1 Demo environment Jira requirements | OUT OF SCOPE (D-006) |
| §4.2 Demo ticket seeding (open design item) | OUT OF SCOPE (D-006); human decision required |
| §4.3 Monitor loop role in demo | OUT OF SCOPE (D-006) |
| §4.4 jr configuration — jr auth check in activate | IN SCOPE (D-006 exception); mapped above |
| §4.5 Updated demo sequence | OUT OF SCOPE (D-006) |

### §6 Shell/PowerShell parity + BATS

| Requirement | Component | BC | Test surface |
|------------|-----------|-----|-------------|
| `.sh`/`.ps1` for scripts that modify settings.json or run `prism credential set` | activate shell helper; onboard-sensor credential helper | BC-6.01.001; BC-6.01.004 | parity.bats new rows; HS per §6 test plan |
| BATS: happy path, missing binary, version mismatch, settings.json write | activate version-check helper | BC-6.01.001 | new BATS in hooks.bats or skills.bats |

### 8.9 Unmapped requirements (minor)

**§2.2 Tavily in secops-protocol.md as a data KB entry:** This is a knowledge-base document update, not a skill or hook. No behavioral contract governs a data KB update directly (all BCs govern skills/hooks, not KB content). The Tavily entry needs a structural BATS test confirming its presence in the secops-protocol.md file. This is the one brief requirement with no BC slot: it is a data artifact, captured as a VP note in BC-10.01.001 under "referenced data KBs" and verified by a new structural test.

**§5 Research input (soc-analyst-workflow-2026.md):** Not a secops-factory deliverable. The research doc lives in the prism repo and will be read as input once committed; it may refine the monitoring-loop BC's priority weights and correlation windows. No component, BC, or test mapping needed at this phase.

---

## Appendix: Decision Record Cross-Reference

| Decision | Effect on this mapping |
|----------|----------------------|
| D-004 (full brief scope) | All §2 and §3 requirements are in scope; none excluded except §4 |
| D-005 (DI-013 marker mechanism) | BC-3.01.001 MODIFIED; HS-001, HS-005, HS-008, HS-026 need revision; VP-HOOK-024 needed |
| D-006 (demo-unaware except jr auth check) | §4.1–§4.3/§4.5 OUT OF SCOPE; §4.4 jr auth check IN SCOPE → BC-6.01.001, HS-042 |

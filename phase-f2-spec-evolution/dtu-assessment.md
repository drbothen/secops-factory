---
document_type: dtu-assessment
producer: architect
version: "1.2"
date: 2026-07-23
feature: prism-integration
feature_version: v0.10.0-feature-prism-integration
status: draft
inputs:
  - .factory/feature/prism-integration-handoff-brief.md
  - .factory/phase-f1-delta-analysis/delta-analysis.md
traces_to: .factory/phase-f1-delta-analysis/delta-analysis.md
prior_assessment: ".factory/specs/dtu-assessment.md (Phase 0 — DTU_REQUIRED: false; no external service dependencies at that time)"
---

> **v1.2 (2026-07-23) — Pass-18 adversarial remediation burst 15, P18-001/P18-005 / D-020/D-021/D-022:**
> Dependency 2 (jr mock) annotated to reflect new marker-scope authorization paths. The mock must
> accept `["link"]` (D-020) and `["close"]` (D-021) as valid `authorized_operations` values, and
> must handle the D-022 two-sequential-Write compound sequences (comment+link for rule 2,
> create+link for rule 4) as two independent marker-authorized calls. New `fp-auto-close` scenario
> added for D-021 FP/BTP non-hard-floor auto-close via `jr issue move`. No mechanism redesign —
> alignment of test design with the new authorization paths only.

# DTU Re-Assessment — prism-integration (v0.10.0-feature-prism-integration)

> **Context.** Phase 0 set `DTU_REQUIRED: false` because the secops-factory plugin
> had no external service dependencies requiring behavioral clones — it operated
> entirely through jr CLI stubs already handled by existing BATS mock patterns.
>
> This feature cycle (v0.10.0-feature-prism-integration) adds three new external
> dependency surfaces: prism (as an MCP stdio server), Jira via jr CLI (now in
> autonomous write scope), and Tavily/Perplexity MCP (enrichment). Two additional
> surfaces (OS scheduler and Perplexity) are assessed and ruled out.
>
> This document is the formal re-assessment required by delta-analysis.md
> frontmatter (`dtu_relevant: true`).

---

## Topline Verdict

| Field | Value |
|-------|-------|
| **DTU_REQUIRED** | **true** |
| New clones to build | 0 (prism-side existing infrastructure consumed; jr mock extended) |
| New secops-factory-owned test infrastructure | Enhanced jr bash mock (L2 stateful) |
| Prism-side DTU consumed as-is | prism-dtu-demo-server + configs/prism-demo.toml (S-6.20, merged) |
| Phase needed — F4 story tests | prism DTU stack + jr L2 mock |
| Phase needed — holdout evaluation | prism DTU stack (HS-035..HS-044 require deterministic sensor data) |

### Per-Dependency Summary

| Dependency | Candidacy | Fidelity | Provider | Phase |
|------------|-----------|----------|----------|-------|
| prism binary / MCP stdio server | **YES** | L3 (behavioral) | prism-side existing (S-6.20 demo server) | F4 + holdout |
| Jira via jr CLI (monitoring-loop autonomous writes) | **YES** | L2 (stateful) | secops-factory-built (extends existing BATS mock) | F4 |
| Tavily MCP (enrichment) | NO — graceful-degradation path | L0/skip for core tests | N/A | N/A |
| Perplexity MCP (enrichment) | NO — graceful-degradation path | L0/skip for core tests | N/A | N/A |
| OS scheduler (cron/Task Scheduler) | NO — invoke loop directly | N/A | N/A | N/A |

---

## Integration Surface Inventory (MANDATORY — all categories)

### Inbound Data Sources (External → Product)

The monitoring loop ingests sensor data via prism MCP. Every secops-factory skill
that calls `mcp__prism__query` or `mcp__prism__prism_describe` is in this category.

| # | Service | Protocol | Fidelity | DTU? | Justification |
|---|---------|----------|----------|------|---------------|
| 1 | prism binary (MCP stdio) | MCP stdio JSON-RPC | L3 (behavioral) | YES — prism-side existing | Full sensor data for all 4 sensors (CrowdStrike, Armis, Claroty, Cyberint) via prism's own DTU demo server; per-org isolation; deterministic seeded fixtures required for holdout evaluation |

### Outbound Operations (Product → External)

The monitoring loop writes to Jira via jr CLI, and the activate skill writes
to `~/.claude/settings.json` (local filesystem — no external service DTU needed).

| # | Service | Protocol | Fidelity | DTU? | Justification |
|---|---------|----------|----------|------|---------------|
| 1 | Jira via jr CLI | CLI subprocess | L2 (stateful) | YES — secops-factory-built | Monitoring-loop §3.4 decision tree (append/link/propose-reopen/create-new) requires stateful issue registry to test all four branches; existing BATS mock extended (see §3) |
| 2 | `~/.claude/settings.json` | Local file write | N/A | NO | Local filesystem; BATS tests use a temp dir override via `CLAUDE_CONFIG_DIR` or equivalent; no network service clone needed |
| 3 | prism credential keyring (AD-017 piped-stdin) | Local subprocess + keyring | N/A | NO | AD-017 pattern: `echo <value> | prism credential set`; tested by BATS against a prism binary in DTU mode that accepts any credential value (no actual keyring write in test context) |
| 4 | `${CLAUDE_PLUGIN_DATA}/watermarks/` | Local file write | N/A | NO | Local filesystem; BATS tests use a temp dir; no service clone needed |

### Identity & Access (Bidirectional)

No identity/access external services. All auth in this feature cycle is:
- prism credentials: AD-017 piped-stdin, verified via `prism_describe` (no live sensor call needed)
- jr CLI auth: existing BATS mock pattern already handles jr auth-status

| # | Service | DTU? | Justification |
|---|---------|------|---------------|
| — | None identified | N/A | Auth exercised through prism DTU (fake tokens, no live sensor auth required) and jr mock |

### Persistence & State (Product ↔ Storage)

| # | Service | DTU? | Justification |
|---|---------|------|---------------|
| — | None identified | N/A | All state is local filesystem (watermarks, prism config dir); tested with temp dirs |
| 1 | **C-29 marker-store** (`${CLAUDE_PLUGIN_DATA}/markers/`) | NO (local filesystem; BATS temp dir injection) | The marker-store is local filesystem: disposition-guard writes `<uuid>.marker.json` files here; require-review reads and atomically renames them to `.used`; audit.log is written here for fail-loud codes. No DTU required — BATS tests override `CLAUDE_PLUGIN_DATA` to a per-test temp dir (`export CLAUDE_PLUGIN_DATA="$(mktemp -d)"`). Marker isolation must be per-test to prevent cross-test leakage. ASM-009 (cross-hook marker visibility: disposition-guard write → require-review read within the same Claude session) is a BLOCKING gap — see Blocking Gaps section. |

### Observability & Export (Product → Monitoring)

| # | Service | DTU? | Justification |
|---|---------|------|---------------|
| — | None identified | N/A | The plugin emits structured output to stdout/stderr; no external observability endpoint |

### Enrichment & Lookup (External → Product)

The monitoring loop Stage 4 enrichment calls Tavily and Perplexity MCP tools for
external threat context. Per D-DEC-009 decision (Tavily tier = `recommended`, not
`required`), the monitoring loop must implement a graceful-degradation path that
produces a valid (lower-confidence) disposition when enrichment is unavailable.

| # | Service | Fidelity | DTU? | Justification |
|---|---------|----------|------|---------------|
| 1 | Tavily MCP (`mcp__tavily__tavily_search`) | L0 (skip for core tests) | NO | Enrichment is `recommended` (D-DEC-009); core monitoring-loop logic (disposition correctness, Jira-first ticket actions, sensor-silence detection) is testable without enrichment. Holdout scenarios HS-035..HS-044 target disposition correctness, not enrichment quality. Where enrichment IS exercised in integration tests, canned MCP fixture responses are used inline (not a persistent clone). |
| 2 | Perplexity MCP (`mcp__perplexity__perplexity_ask`) | L0 (skip for core tests) | NO | Same rationale as Tavily. Graceful-degradation path (Stage 4 enrichment absent → disposition proceeds at lower confidence) is tested via the no-enrichment path. |

---

## Dependency 1: prism binary / MCP stdio server

### Candidacy Verdict

**YES — DTU required. Provider: prism-side existing.**

secops-factory skills (investigate-event, assess-priority, monitoring-loop,
metrics, scan-threats, onboard-sensor) all call prism MCP tools. Testing these
skills without hitting live sensor APIs requires a prism instance running in
demo/DTU mode.

**Preferred approach: consume prism's own DTU demo server infrastructure.**

The prism project provides exactly this via story S-6.20 (`prism-dtu-demo-server`,
status: `merged`):
- A multi-clone demo harness binary (`prism-dtu-demo-server`) that boots all 6 DTU
  sensor clones (CrowdStrike/Claroty/Cyberint/Armis ports 17080–17083, ThreatIntel
  port 17084, NVD port 17085) with seeded fixture data
- `configs/prism-demo.toml` — a prism production config preset that routes all
  sensor queries through the DTU endpoints
- `scripts/start-demo.sh` — exports `DEMO_FAKE_*` env vars (fake tokens matching
  DTU fixture auth) and launches the demo harness

Fixture data is org-scoped and seed-deterministic:
- org-a: CrowdStrike + Armis sensors (seed=100; device IDs `dev-0196f4b2-100-*`)
- org-b: Claroty + Cyberint sensors (seed=150)
- org-c: all 4 sensors (seed=200; device IDs `dev-0196f4b2-200-*`; 10 table types)
- `_global`: ThreatIntel + NVD enrichment services (shared across orgs)

This matches the fixture structure described in the handoff brief §4.2.

### Why Not Build a New Mock

Building a secops-factory-owned mock of the prism MCP server would require
reimplementing the MCP stdio JSON-RPC protocol, all tool response shapes
(`mcp__prism__query`, `mcp__prism__prism_describe`, `mcp__prism__prism_sensor_health`),
and realistic OCSF-normalized sensor data. This is multi-week effort for no gain —
prism already provides exactly this infrastructure.

The `prism-dtu-demo-server` + `configs/prism-demo.toml` stack is the canonical
test double for prism. secops-factory's obligation is **test fixture wiring only**,
not clone implementation.

### Fidelity Level: L3 (Behavioral)

The prism binary running against DTU clones provides:
- All prism MCP tool semantics (`query`, `prism_describe`, `prism_sensor_health`,
  `list_capabilities`, prompts, resources)
- Per-org sensor isolation invariant (org-a cannot see Claroty/Cyberint tables;
  querying those returns E-QUERY-032)
- Stateful sensor health responses (per-org sensor last-seen timestamps, row counts)
- Deterministic OCSF-normalized fixture records (seeded, reproducible across runs)
- Error taxonomy (E-SPEC-024 boot abort, E-CRED-008 missing credential, E-QUERY-032
  sensor not registered) exercised via fixture configuration

This is L3 (behavioral) rather than L4 because:
- No irreversible write operations surface in prism v1 MCP scope that secops-factory
  exercises (write gates in prism are a prism-side safety concern)
- Adversarial failure injection is not required for secops-factory skill tests
  (the skill behavior under sensor error conditions is tested via sensor-silence
  detection, which prism-dtu provides via the zero-row silence scenario)

### Test Fixture Wiring (secops-factory obligation)

For BATS integration tests and holdout evaluation, test setup must:

1. **Verify prism binary is available**: `prism --version` returns >= v1.0.0-rc.1
   (same version gate as the activate skill)
2. **Start demo harness** (in BATS `setup_file()`):
   ```bash
   export DEMO_FAKE_CROWDSTRIKE_TOKEN=dtu-fake-cs-token
   export DEMO_FAKE_CLAROTY_TOKEN=dtu-fake-claroty-token
   export DEMO_FAKE_CYBERINT_TOKEN=dtu-fake-cyberint-token
   export DEMO_FAKE_ARMIS_TOKEN=dtu-fake-armis-token
   export DEMO_FAKE_THREATINTEL_TOKEN=dtu-fake-ti-token
   export DEMO_FAKE_NVD_TOKEN=dtu-fake-nvd-token
   prism-dtu-demo-server start --config "$PRISM_REPO/configs/demo.toml" &
   DEMO_SERVER_PID=$!
   ```
3. **Start prism in demo mode** (pointing at DTU endpoints):
   ```bash
   prism --config-dir "$TEST_PRISM_CONFIG_DIR" start \
     --sensor-config "$PRISM_REPO/configs/prism-demo.toml" &
   PRISM_PID=$!
   ```
4. **Seed test orgs**: The BATS test setup calls the secops-factory onboard-customer
   and onboard-sensor skills (or directly writes a test `prism.toml`) with org-a,
   org-b, org-c configs pointing to DTU endpoints and DEMO_FAKE_* credentials
5. **Teardown** (in BATS `teardown_file()`): `kill $PRISM_PID $DEMO_SERVER_PID`

**ASM-004 dependency.** This test fixture approach depends on ASM-004 validation:
`claude -p` headless invocation must load MCP servers from `settings.json`. If
ASM-004 fails, the monitoring-loop SKILL.md invocation via `claude -p` cannot
reach the prism MCP tools, and an alternative packaging must be chosen (D-DEC-003).
ASM-004 must be empirically validated before monitoring-loop stories are authored
(see delta-analysis.md §3.2).

**CI note.** The prism binary and `prism-dtu-demo-server` binary must be available
in CI. The activate skill's download path (GitHub Releases binary) is the mechanism
for the main prism binary. For `prism-dtu-demo-server`, the binary is included in
the `prism-demo-bundle-${TAG}-${target}` release asset (brief §1). secops-factory CI
must download and cache this bundle as part of the integration test setup job.

### Test Surfaces That Depend on This DTU

| Test Surface | Dependency |
|-------------|------------|
| BATS integration tests for investigate-event (prism evidence collection) | prism MCP returning CrowdStrike + ThreatIntel fixture data for org-a |
| BATS integration tests for assess-priority (prism baseline + NVD) | prism MCP returning historical detection baseline + NVD CVE fixture |
| BATS integration tests for monitoring-loop Stage 0 (sensor health) | prism MCP returning `prism_sensor_health` fixture (org × sensor status) |
| BATS integration tests for monitoring-loop Stage 1 (watermark ingest) | prism MCP returning paginated sensor events above watermark |
| BATS integration tests for monitoring-loop Stage 7 (sensor-silence) | prism MCP returning zero rows for a configured sensor (silence scenario) |
| Holdout scenarios HS-035..HS-044 (monitoring-loop 10 new scenarios) | All of the above; deterministic fixture data required |
| BATS tests for onboard-sensor (`SELECT 1` verification) | prism MCP returning success for a simple query |

---

## Dependency 2: Jira via jr CLI

### Candidacy Verdict

**YES — enhanced L2 stateful mock. Provider: secops-factory-built.**

Phase 0 BATS tests already mock jr CLI behavior using a mock `jr` binary that
records calls and returns fixture output. This is sufficient for simple skill
tests (read-ticket, update-jira basic operations).

The monitoring loop's §3.4 Jira-first decision tree requires **stateful behavior**
across jr calls within a single loop run:

1. `jr issue search` (JQL) — must return an issue list reflecting current state
2. `jr issue comment` — must be callable when a duplicate open ticket is found
3. `jr issue link` — must be callable when a related open ticket is found
4. `jr issue create` — must be callable when no matching ticket exists
5. `jr issue transition` — must not be called for auto-reopen (never-auto-reopen invariant)

Testing the four-branch decision tree requires the mock to respond differently
based on the current issue state (open duplicate / open related / resolved /
closed / absent). This is L2 (stateful): state is maintained across multiple
jr calls within a BATS test.

### Fidelity Level: L2 (Stateful)

The enhanced jr mock maintains a per-test issue registry in tmpfiles:
- `jr issue search` reads from a seeded fixture file (per-test scenario)
- `jr issue comment`, `jr issue create`, `jr issue link` append to a call log
  AND update the mock issue registry
- Test assertions check: (a) which jr commands were called, (b) in what order,
  (c) with what arguments

The mock does NOT need to implement:
- Real JQL parsing (fixture scenarios use pre-seeded issue lists per scenario)
- Jira field validation
- OAuth flow

This is L2 not L3 because there is no complex state machine — the four-branch
decision logic lives in the monitoring-loop skill, not in jr. The mock's only
job is to return predictable responses and record calls for assertion.

### Implementation Approach

Extend the existing BATS mock `jr` binary (located in BATS helpers) with:

1. **Scenario seeding**: A `MOCK_JR_SCENARIO` env var names a fixture directory
   containing `issues.json` (the search result fixture for this scenario) and
   optionally `issue-<key>.json` (per-issue detail fixtures)
2. **Stateful call recording**: Each invocation appends to `$MOCK_JR_CALL_LOG`
   (tmpfile, reset per test)
3. **Branch-triggering scenarios** (one fixture set per §3.4 branch):

| Scenario | `jr issue search` returns | Expected monitoring-loop action |
|----------|--------------------------|--------------------------------|
| `duplicate-open` | 1 open ticket, same root cause | `jr issue comment` called (comment marker, D-DEC-001) |
| `related-open` | 1 open ticket, different root cause | **Two sequential marker-authorized calls (D-022/D-020):** verdict-1 comment marker → `jr issue comment KEY1 "..."`; verdict-2 `["link"]` marker (ticket_id=KEY1, link_target_ticket_id=KEY2) → `jr issue link KEY1 KEY2` without `--type` flag (D-020 Iron Law). Mock asserts both calls in order; anti-fungibility: comment marker does NOT authorize link call. |
| `resolved-same` | 1 resolved ticket, same root cause | Human-surface (propose-reopen, no auto-transition) |
| `closed-same` | 1 closed ticket, same root cause | **Two sequential marker-authorized calls (D-022/D-020):** verdict-1 create marker → `jr issue create --project <key>` → NEW_KEY returned; verdict-2 `["link"]` marker (ticket_id=NEW_KEY, link_target_ticket_id=CLOSED_KEY) → `jr issue link NEW_KEY CLOSED_KEY`. Mock records both calls; test asserts link_target_ticket_id equals the ticket_id returned from create (D-022 Iron Law). |
| `no-match` | 0 tickets | `jr issue create` called (if TP disposition) |
| `blind-spot-open` | 1 open BLIND-SPOT ticket | `jr issue comment` on existing (not new creation) |
| `blind-spot-absent` | 0 BLIND-SPOT tickets | `jr issue create` with BLIND-SPOT label |
| `fp-auto-close` | **[NEW v1.2 — D-021]** 1 open ticket, disposition=FP, non-hard-floor scored_priority (LOW/MED), autonomy_enabled=true | `["close"]` marker issued → `jr issue move <ticket_id> <jira_close_state>` called; `<jira_close_state>` is CONFIG-driven from plugin state (e.g., "Done"); mock asserts the close command matches `CLOSE_STATE_ALLOWLIST` member; test verifies NO `jr issue comment` or other action is called instead. Asserts kill-switch NOT engaged (autonomy_enabled=true) and hard_floor_applies()=false (non-HIGH/CRIT). |

4. **Never-auto-reopen validation**: Test asserts `jr issue transition` is NOT
   called for the `resolved-same` and `closed-same` scenarios

5. **[NEW v1.2 — D-020/D-021/D-022 marker-scope routing alignment (P18-001/P18-005)]:** The
   mock `jr` binary must accept commands that arrive via the new `["link"]` (D-020), `["close"]`
   (D-021), and D-022 two-sequential-Write compound sequences:
   - `jr issue link KEY1 KEY2` — authorized via `["link"]` marker scope (D-020); mock records
     both KEY1 and KEY2 in `$MOCK_JR_CALL_LOG`; test asserts the command includes NO `--type`
     flag (D-020 Iron Law: `jr issue link` uses jr default "Relates"; `--type` is never
     loop-influenceable).
   - `jr issue move <ticket_id> <close_state>` — authorized via `["close"]` marker scope (D-021);
     mock records the call; `<close_state>` is CONFIG-driven (test must inject `MOCK_JIRA_CLOSE_STATE`
     from `CLOSE_STATE_ALLOWLIST = {"Done","Closed","Resolved"}`); test asserts the state value
     is the configured allowlist member, NOT a verdict-supplied value.
   - **D-022 compound sequences:** for `closed-same` (create+link) and `related-open` (comment+link),
     the mock must accept the two marker-authorized calls as independent sequential invocations
     (not a single call). The link call for `closed-same` MUST carry the `link_target_ticket_id`
     returned from the immediately preceding `jr issue create`. The mock records the full call
     sequence; test asserts order and argument correctness.
   - **`close` scope anti-fungibility:** the mock asserts that when `["close"]` authorizes
     `jr issue move`, no `jr issue comment`, `jr issue create`, or `jr issue link` is
     authorized by that same marker invocation.

### Test Surfaces That Depend on This DTU

| Test Surface | Dependency |
|-------------|------------|
| BATS tests for monitoring-loop Stage 7 (ticket action §3.4) | All 7 jr mock scenarios above |
| BATS tests for require-review D-005 marker mechanism | `jr issue comment` / `jr issue create` authorized via marker |
| BATS tests for sensor-silence BLIND-SPOT dedup (R-006) | `blind-spot-open` and `blind-spot-absent` scenarios |
| BATS tests for never-auto-reopen-closed invariant (§3.4 rule 4) | `closed-same` scenario: assert no `jr issue transition` call |
| BATS tests for D-020 link scope anti-fungibility | `related-open` scenario: assert `["link"]` marker authorizes ONLY `jr issue link`; comment marker does NOT authorize link call |
| **[NEW v1.2]** BATS tests for D-021 close scope (FP/BTP auto-close) | `fp-auto-close` scenario: assert `["close"]` marker → `jr issue move <ticket_id> <close_state>` with CONFIG-driven state from CLOSE_STATE_ALLOWLIST; hard_floor=false + autonomy_enabled=true guards exercised |
| **[NEW v1.2]** BATS tests for D-022 compound-action sequence ordering | `closed-same` (create+link): assert link verdict carries NEW_KEY from create result; `related-open` (comment+link): assert comment precedes link in call log |
| Holdout scenarios HS-036 (Jira-first correlation rules) | All §3.4 branches exercised end-to-end |

### Cost/Benefit

**Cost**: ~2-3 days extending the existing mock binary with scenario-based
stateful responses. No new infrastructure.

**Benefit**: All §3.4 ticket action branches testable deterministically without
a live Jira instance. Existing mock structure is well-understood by the team.
No risk of Jira API rate-limit interference in CI (ASM-007).

---

## Dependency 3: Tavily MCP

### Candidacy Verdict

**NO — no DTU required for core tests.**

**Rationale:**

1. **Graceful degradation path (D-DEC-009):** Tavily is classified `recommended`
   (not `required`) per D-DEC-009. The monitoring loop must implement a path
   where Stage 4 enrichment (Tavily call absent or empty response) produces a
   valid Indeterminate-or-lower-confidence disposition. This path is the primary
   test surface for enrichment: verify the loop handles missing enrichment
   correctly, not that Tavily returns a specific threat score.

2. **Core disposition logic is independent of enrichment:** Holdout scenarios
   HS-035..HS-044 test disposition correctness (TP/FP/BTP/Indeterminate), Jira
   ticket actions, and sensor-silence detection. None of these outcomes depend
   on the content of Tavily web search results. The sensor data from prism DTU
   drives the core assertions.

3. **MCP tool test interception:** Tavily is a Claude Code MCP tool
   (`mcp__tavily__*`). Its calls are made within the Claude agent session that
   executes the monitoring-loop skill. BATS tests that invoke `claude -p` do not
   intercept individual MCP tool calls — they observe the final structured output.
   Testing Tavily response content would require either live calls (non-deterministic)
   or a mechanism to inject fake MCP responses that secops-factory does not own.

4. **Existing pre-requisite for enrichment-path tests:** If specific enrichment-path
   integration tests are added in a future cycle, they would use prerecorded Tavily
   response fixtures stored in the secops-factory test data directory. These are L1
   (recorded fixture) tests, not behavioral clones, and they are out of scope for
   this feature cycle.

---

## Dependency 4: Perplexity MCP

### Candidacy Verdict

**NO — no DTU required for core tests.**

Same rationale as Tavily (dependency 3). Perplexity is used in Stage 4 enrichment
(`mcp__perplexity__perplexity_ask`) for external threat context on high-value
indicators. The graceful-degradation path is the primary test surface. No behavioral
clone needed.

---

## Dependency 5: OS Scheduler (cron / Task Scheduler)

### Candidacy Verdict

**NO — no test double needed.**

The monitoring loop is designed to be invoked ad-hoc as well as by a scheduler
(brief §4.3: "the loop can be triggered manually"). BATS tests invoke the loop
directly:

```bash
# BATS test invocation (no scheduler involved) — authoritative form per D-DEC-003
run claude -p "/monitoring-loop" \
  --strict-mcp-config \
  --mcp-config "${TEST_PRISM_MCP_CONFIG}" \
  --allowedTools "mcp__prism__*,mcp__tavily__tavily_search,mcp__tavily__tavily_extract,mcp__perplexity__perplexity_ask,mcp__perplexity__perplexity_search,Bash,Write,Read,Edit" \
  --output-format json \
  < /dev/null
# TEST_PRISM_MCP_CONFIG: path to per-test prism.mcp.json pointing to prism-dtu-demo-server
# --strict-mcp-config: prevents loading ~/.claude/prism.mcp.json (D-DEC-003 bare-mode equivalent)
# < /dev/null: prevents the Claude process from reading stdin (required for headless invocation)
```

The OS scheduler's only role is to invoke this command on a recurring interval.
There is no scheduler-specific behavior in the monitoring-loop code that needs
testing. The scheduling frequency and cron syntax are configuration, not logic.

ASM-004 (headless MCP loading) and ASM-005 (CLAUDE_PLUGIN_DATA writable from
scheduler context) are **operational assumptions**, not test doubles. They are
validated once manually (ASM-004: F2 gate per delta-analysis.md §3.2;
ASM-005: documented per-OS paths and tested with a simulated environment).

---

## Blocking Gaps

| Gap | Risk | Resolution Path |
|-----|------|----------------|
| **ASM-004 unvalidated**: `claude -p` headless invocation must load `settings.json` MCP servers (prism). If it does not, the monitoring-loop SKILL.md cannot reach prism MCP in CI. | HIGH — monitoring-loop stories cannot be authored until this is confirmed | Empirical validation before F2 completes (delta-analysis.md §3.2 gate). If false, D-DEC-003 must choose an alternative packaging. |
| **ASM-009 unvalidated**: cross-hook marker visibility — disposition-guard writes `${CLAUDE_PLUGIN_DATA}/markers/<uuid>.marker.json` in a PreToolUse hook subprocess; require-review reads the same directory in a separate PreToolUse hook subprocess. It is unvalidated whether two hook subprocesses within the same `claude` session share the same `${CLAUDE_PLUGIN_DATA}` filesystem view (no tmpfs isolation, no kernel namespace separation). If they don't share the view, every require-review check will find no marker and deny all Jira writes — the entire marker mechanism collapses silently. | HIGH — the disposition-guard → require-review marker exchange (D-DEC-001/D-DEC-012, VP-HOOK-029) is the core enforcement mechanism; if cross-hook filesystem access is isolated, the mechanism is non-functional | Formal-verifier must design a BATS test that writes a marker from a hook invocation and verifies it is readable from a second hook invocation within the same `claude` session before Wave 3 story merge. Resolution path: if isolated, D-DEC-003 must use an alternative (e.g., a shared sidecar process or env-passed nonce). VP-HOOK-029's ASM-009 cross-hook harness citation (BC-3.03.001 v1.18 / BC-10.01.001 v1.15 Invariant #10) is the verification anchor. |
| **prism-demo-bundle CI download**: The `prism-dtu-demo-server` binary is in the `prism-demo-bundle-*` release asset, not the main prism binary. CI must have a mechanism to download it. | MEDIUM — integration tests and holdout evaluation blocked in CI until available | Prism must publish the demo bundle as a GitHub Release asset alongside the main binary. secops-factory CI downloads it via the same mechanism as the main binary. This is a prism release engineering dependency. |
| **Test prism.toml isolation**: BATS tests must not use the developer's real `~/.config/prism/prism.toml`. Needs a per-test `PRISM_CONFIG_DIR` override. | MEDIUM — tests could corrupt real org config | Confirmed in story for activate skill shell helper BATS: use `--config-dir` pointing to a tmpdir. All BATS tests that invoke prism must pass this flag. |

---

## Summary

This cycle introduces **two** test infrastructure requirements:

**1. prism DTU stack (prism-side existing infrastructure, consumed by secops-factory):**
- `prism-dtu-demo-server` binary (from prism-demo-bundle release asset) boots 6 DTU
  sensor clones at stable ports
- `configs/prism-demo.toml` + `DEMO_FAKE_*` env vars route prism production mode
  through DTU endpoints
- secops-factory test fixtures configure org-a/org-b/org-c (seed=100/150/200) in a
  temp prism config dir
- Required for: F4 integration tests for prism-dependent skills; all 10 new holdout
  scenarios HS-035..HS-044

**2. Enhanced jr bash mock (secops-factory-built, L2 stateful):**
- Extends existing BATS mock jr binary with scenario-seeded issue registry and
  stateful call recording
- 7 fixture scenarios covering all §3.4 Jira-first decision tree branches
- Required for: F4 integration tests for monitoring-loop ticket action logic

**Neither Tavily, Perplexity, nor OS scheduler** require a test double. Enrichment
is graceful-degradation optional; the scheduler is bypassed by direct loop invocation.

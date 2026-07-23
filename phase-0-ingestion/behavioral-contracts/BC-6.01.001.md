---
document_type: behavioral-contract
level: L3
version: "1.7"
status: draft
producer: product-owner
timestamp: 2026-07-20T00:00:00
phase: f2
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/skills/activate/SKILL.md, plugins/secops-factory/tests/skills.bats, phase-f2-spec-evolution/architecture-delta.md]
input-hash: "COMPUTE-AT-COMMIT"
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/skills/activate/SKILL.md
subsystem: lifecycle-management
capability: CAP-LIFECYCLE-01
lifecycle_status: active
introduced: v0.7.0
modified: ["v1.1-D-DEC-003-PRISM-2026-07-20", "v1.2-FV-PROPOSED-DROP-2026-07-20", "v1.3-ADV-F2-P2-008-012-013-2026-07-20", "v1.4-ADV-F2-P3-010-2026-07-20", "v1.5-consistency-F3-changelog-correction-2026-07-21", "v1.6-ADV-F2-P9-008-2026-07-21", "v1.7-ADV-F2-P13-002-setup-time-charset-validation-2026-07-22"]
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-6.01.001: activate Skill — Per-Project Activation Lifecycle with Prism MCP Integration

> **Revision history:**
> - v1.7 (2026-07-22): Pass-13 adversarial remediation — P13-002 (CRITICAL, setup-time `jira_project_key` charset validation). (1) **Postcondition #12 updated — charset validation required:** activate MUST validate any configured `jira_project_key` against `^[A-Z][A-Z0-9]+$` at setup time. On mismatch (e.g., a key containing a hyphen such as `PRISM-DEMO`), activate MUST emit an explicit user-facing error ("Invalid Jira project key '<X>': Jira project keys must be uppercase alphanumeric with no hyphens or spaces — e.g., PRISMDEMO, SEC, SECOPS.") and refuse to complete activation. Fail-early rationale: a non-conformant key reaches the marker mechanism and causes PROJECT-KEY-CHARSET-DENY fail-closed drops on every comment/create/create-review marker issuance — validating at setup time prevents this class of livelock entirely. Cross-reference: D-DEC-008 architectural constraint (Jira project keys MUST be hyphen-free per `^[A-Z][A-Z0-9]+$`). (2) **EC-013 example updated:** example prompt text changed from `(e.g., SEC, PRISM-DEMO)` to `(e.g., SEC, PRISMDEMO, SECOPS)` to reflect valid hyphen-free examples only. (3) **EC-014 added:** hyphen-containing key rejected at setup time with explicit user-facing error. ADV-F2-P13-002.
> - v1.6 (2026-07-21): Pass-9 adversarial remediation — ADV-F2-P9-008 (OBS) jira_project_key as HARD Stage-0 precondition. The monitoring loop requires `jira_project_key` to be configured before it may run. A missing `jira_project_key` causes HARD-FLOOR-UNBINDABLE livelock on every hard-floor `create-review` verdict (disposition-guard STEP 3 denies every review marker because `jira_project_key` is null). (1) **Postcondition #12 added:** activate MUST prompt for and validate `jira_project_key` (non-empty string, Jira project key format) before completing. The monitoring-loop MUST NOT be scheduled or run without a valid `jira_project_key` configured in plugin state. If `jira_project_key` is absent when the loop starts, the loop MUST emit a fatal `MISSING-JIRA-PROJECT-KEY` error and exit immediately before processing any alerts. (See also BC-10.01.001 Precondition #9 v1.14.) (2) **EC-013 added:** jira_project_key absent at activation time — activate prompts user, validates format, blocks completion until populated.
> - v1.5 (2026-07-21): consistency-F3 changelog correction — v1.4 entry had identical left/right sides in the subcommand rename notation; corrected to `jr auth check` → `jr auth status` to accurately record the rename that was applied.
> - v1.4 (2026-07-20): ADV-F2-P3-010 (minor) GROUND TRUTH correction: `jr auth check` → `jr auth status` in PC#10, EC-010, test vectors, and purity classification (jr 0.5.0 subcommand is `jr auth status`; `jr auth check` does not exist).
> - v1.0 (2026-07-19): Initial extraction from `skills/activate/SKILL.md` at v0.9.0 HEAD (Step 0d).
> - v1.1 (2026-07-20): D-DEC-003/PRISM: **UPDATED** — Added five new behaviors: (1) locate-or-download prism binary; (2) `prism --version` >= v1.0.0-rc.1 version gate (VP-SKILL-051 assigned here); (3) DUAL MCP config write per D-DEC-003 — BOTH `~/.claude/settings.json` (interactive sessions) AND `~/.claude/prism.mcp.json` (cron/headless sessions); (4) `RUST_LOG=off` ALWAYS injected in both config locations (Invariant #5 — framing corruption prevention); (5) `jr auth status` BLOCKING gate with setup instructions on failure; AD-017 next-step credential instructions. Updated Invariant #2 narrow exception (project-level `settings.json` still never modified; global `~/.claude/settings.json` receives only `mcpServers.prism` key). No demo-project references (D-006). EC-008..EC-012 added.
> - v1.2 (2026-07-20): FV-PROPOSED-DROP: VP-SKILL-051 is now FINALIZED per verification-delta §1 — dropped `(PROPOSED)` qualifier from VP table row BATS test names.
> - v1.3 (2026-07-20): ADV-F2-P2-008/ADV-F2-P2-012/ADV-F2-P2-013: (1) GROUND TRUTH correction — prism binary download org changed from `prism-io/prism` to `drbothen/prism` in PC#8 (ADV-F2-P2-008). (2) MCP server invocation corrected: subcommand changed from `["mcp"]` to `["--config-dir","${CLAUDE_PLUGIN_DATA}/prism","start"]` in both settings.json and prism.mcp.json blocks; `PRISM_CONFIG_DIR` env var removed from both env blocks (config now passed via `--config-dir` arg, not env); `RUST_LOG=off` retained in both blocks per Invariant #5 (ADV-F2-P2-008). (3) Sensor base-URL reconciliation note added to PC#9 (ADV-F2-P2-013): per-sensor base URLs (`CROWDSTRIKE_BASE_URL`, `ARMIS_INSTANCE_URL`, etc.) are provisioned in per-sensor `<sensor_id>.sensor.toml` overlays via onboard-sensor (BC-6.01.004), NOT in the MCP env block; the env block carries only process-level config (RUST_LOG). (4) Revision history ordering corrected: v1.1 now precedes v1.2 (ADV-F2-P2-012).

## Preconditions

1. The skill is user-invoked only (`disable-model-invocation: true` in frontmatter). The LLM model is never dispatched for this skill. Confidence: verified by code analysis (`skills/activate/SKILL.md:frontmatter`) and BATS test `skills.bats:327-329`.
2. The target for activation state is `.claude/settings.local.json` (per-project, not shared `settings.json`). Confidence: verified by code analysis and BATS test `skills.bats:323-325`.
3. The skill announces itself verbatim before any other action. Confidence: verified by code analysis (Announce at Start section) and BATS test `skills.bats:331-334`.
4. **[NEW v1.1]** Network access is required to download the prism binary from GitHub Releases if it is not already installed at `which prism` or `${CLAUDE_PLUGIN_DATA}/bin/prism`. If network is unavailable and prism is not installed, the activation proceeds with an explicit warning: "Prism binary not available — MCP integration will not be configured. Re-run activate when network is available."

## Postconditions

1. After successful activation, `.claude/settings.local.json` contains `"agent": "secops-factory:orchestrator:orchestrator"` at the top level. Confidence: verified by code analysis (Step 4 merge block) and BATS test `skills.bats:319-322`.
2. The activation metadata block is written: `"secops-factory": {"activated_at": "<ISO 8601>", "activated_plugin_version": "<version>"}`. Confidence: verified by code analysis (Step 4 merge block).
3. All pre-existing keys in `settings.local.json` are preserved; the skill merges rather than overwrites. Confidence: verified by code analysis (Step 2: "parse with jq — never blind-overwrite") and Red Flag: "Touch only the `agent` key and the `secops-factory` block. Preserve everything else."
4. On Windows (native PowerShell/cmd, `$env:OS = Windows_NT`, not WSL/Git Bash), `hooks.json.windows` is copied to `hooks.json` to activate the `.ps1` hook variants. On macOS/Linux/WSL/Git Bash, `hooks.json` is left untouched. Confidence: verified by code analysis (Step 5).
5. The skill verifies the write with `jq` read-back before confirming success to the user. Confidence: verified by code analysis (Red Flag: "Activation failed silently, but I'll report success").
6. If `--dry-run` flag is provided, the proposed diff is printed but no file is written and no hooks variant is applied. Confidence: verified by code analysis (Dry-run mode section).
7. If an existing `agent` key points to a non-secops agent, the user is warned and asked to confirm before replacing. Confidence: verified by code analysis (Step 3) and Red Flag: "Another plugin's agent is set, mine is more important" → "Ask before replacing."

8. **[NEW v1.1] Prism binary install/verify:**

   - Check for prism binary at `which prism` (system PATH) or `${CLAUDE_PLUGIN_DATA}/bin/prism`.
   - If not found: download from GitHub Releases (`https://github.com/drbothen/prism/releases/latest`) to `${CLAUDE_PLUGIN_DATA}/bin/prism`; make executable.

   > **Previous (v1.1/v1.2):** `https://github.com/prism-io/prism/releases/latest`. Ground truth verified by orchestrator against the prism repo: the correct GitHub org is `drbothen` (ADV-F2-P2-008).
   - After install (or if already present), run `prism --version` via subprocess to retrieve the version string.
   - **Version gate:** If `prism --version` returns a version < `1.0.0-rc.1` (semantic version comparison), the activation halts with: "Prism binary version <version> does not meet minimum requirement v1.0.0-rc.1. Please upgrade." No MCP config is written until the version gate passes. (VP-SKILL-051 enforces this property.)
   - Verification is via subprocess `prism --version`, NOT via MCP ping — MCP may not be configured yet at this point.

9. **[NEW v1.1] DUAL MCP config write (D-DEC-003):**

   After the version gate passes, write the prism MCP server configuration to BOTH locations:

   - **`~/.claude/settings.json` (global user settings — interactive sessions):** Merge only the `mcpServers.prism` key. All pre-existing keys in `~/.claude/settings.json` MUST be preserved (jq merge, never blind-overwrite). Parse error on `~/.claude/settings.json` → stop, show error, do NOT overwrite (same guard as `settings.local.json`, EC-011). The `mcpServers.prism` block written:
     ```json
     {
       "mcpServers": {
         "prism": {
           "command": "prism",
           "args": ["--config-dir", "${CLAUDE_PLUGIN_DATA}/prism", "start"],
           "env": {
             "RUST_LOG": "off"
           }
         }
       }
     }
     ```

   - **`~/.claude/prism.mcp.json` (standalone MCP config — cron/headless sessions):** Write a complete MCP config file for use with `--strict-mcp-config --mcp-config ~/.claude/prism.mcp.json` (D-DEC-003 cron flag):
     ```json
     {
       "mcpServers": {
         "prism": {
           "command": "prism",
           "args": ["--config-dir", "${CLAUDE_PLUGIN_DATA}/prism", "start"],
           "env": {
             "RUST_LOG": "off"
           }
         }
       }
     }
     ```

   > **Previous (v1.1/v1.2) args + env (both blocks):** `"args": ["mcp"]` with `"env": {"RUST_LOG": "off", "PRISM_CONFIG_DIR": "${CLAUDE_PLUGIN_DATA}/prism"}`. Ground truth verified by orchestrator: prism MCP server subcommand is `start` (not `mcp`); config-dir is passed via `--config-dir` flag argument, NOT the `PRISM_CONFIG_DIR` environment variable. `PRISM_CONFIG_DIR` removed from env block (ADV-F2-P2-008).

   **Sensor base-URL reconciliation note (ADV-F2-P2-013):** Per-sensor base URLs (`CROWDSTRIKE_BASE_URL`, `ARMIS_INSTANCE_URL`, `CLAROTY_BASE_URL`, etc. — listed in brief §2.1) are provisioned in per-sensor `<sensor_id>.sensor.toml` overlays under `<spec_dir>/customers/<org_slug>/`, not in the MCP server env block. The env block carries only process-level configuration (`RUST_LOG`). The `onboard-sensor` skill (BC-6.01.004) manages per-sensor toml writes. This design is intentional: sensor URLs are customer-specific and must not be hardcoded into the global MCP config that all orgs share.

   After writing both files, verify via `prism --version` subprocess (not MCP ping) that the binary is still accessible. Report the dual-write result to the user.

10. **[NEW v1.1] `jr auth status` BLOCKING gate:**

    Run `jr auth status` after the prism config write. If `jr auth status` exits non-zero or indicates authentication failure, the activation halts with setup instructions:
    ```
    jr authentication is required before secops-factory can operate.
    Run: jr auth login
    Then re-run: /activate
    ```
    The `agent` key IS written to `settings.local.json` before this check (the prism config is part of the setup step, not the auth gate). However, the activation is not considered complete until `jr auth status` passes.

11. **[NEW v1.1] AD-017 credential setup instructions:**

    After successful `jr auth status`, if any prism sensors require credentials, display the AD-017 next-step instructions (per the format in the onboard-sensor skill, BC-6.01.004). Credentials are NEVER prompted in chat — the instruction text uses the piped-stdin pattern:
    ```
    echo "<credential_value>" | prism --config-dir <dir> credential set \
      --sensor <sensor_id> --name <credential_name> --org-slug <org_slug>
    ```
    This display is informational (no credential collection occurs during activation).

12. **[NEW v1.6; UPDATED v1.7 P13-002] `jira_project_key` HARD Stage-0 precondition with charset validation (P9-008 / P13-002 / architecture-delta v1.12/v1.16 §D-DEC-008):**

    Activate MUST prompt for and validate `jira_project_key` (non-empty string, valid Jira
    project key format — uppercase alphanumeric with no hyphens or spaces, e.g. `SEC`,
    `PRISMDEMO`, `SECOPS`) before completing. The monitoring-loop MUST NOT be scheduled or
    run without a valid `jira_project_key` configured in plugin state.

    **Charset validation (P13-002 CRITICAL):** The `jira_project_key` MUST match `^[A-Z][A-Z0-9]+$`.
    On mismatch, activate MUST emit an explicit user-facing error message and refuse to complete
    activation (fail-early):
    ```
    Invalid Jira project key '<X>': Jira project keys must be uppercase alphanumeric with no
    hyphens or spaces — e.g., PRISMDEMO, SEC, SECOPS.
    ```
    Rationale: a key with a hyphen (e.g., `PRISM-DEMO`) passes the non-empty format check but
    fails the `^[A-Z][A-Z0-9]+$` regex applied at every marker issuance site in disposition-guard
    (BC-3.03.001 P12-001/O7) — causing PROJECT-KEY-CHARSET-DENY fail-closed drops on every
    comment, create, and create-review marker. Catching this at setup time prevents livelock.
    Cross-reference: D-DEC-008 architectural constraint (Jira project keys MUST be hyphen-free
    per `^[A-Z][A-Z0-9]+$`; architecture-delta.md v1.16 §D-DEC-008).

    If `jira_project_key` is absent when the monitoring-loop starts (despite this gate),
    the loop MUST emit a fatal `MISSING-JIRA-PROJECT-KEY` error and exit immediately before
    processing any alerts (BC-10.01.001 Precondition #9).

    Rationale: a structurally absent `jira_project_key` causes HARD-FLOOR-UNBINDABLE livelock
    on every hard-floor `create-review` verdict — disposition-guard STEP 3 denies every review
    marker because the `jira_project_key` binding field is null; the monitoring-loop then
    re-documents indefinitely without ever writing a Jira ticket. Preventing the loop from
    starting without this field is strictly better than degrading to audit-only mode silently.

    The `jira_project_key` is persisted in plugin state (alongside other operational metadata)
    so that the cron wrapper can verify its presence at loop start time without user interaction.

## Invariants

1. **[Preserved v1.0]** Activation is always an explicit user action — the plugin being enabled never auto-activates. Confidence: verified by code analysis (Notes: "No hijack on enable" principle).

2. **[UPDATED v1.1]** The project-level `settings.json` (shared team settings, project root) is NEVER modified. Only `settings.local.json` (per-project, typically gitignored) receives the `agent` and `secops-factory` activation block. The global user `~/.claude/settings.json` is modified ONLY to write the `mcpServers.prism` key (D-DEC-003) — no other keys in `~/.claude/settings.json` are touched; all pre-existing keys are preserved via merge. The `~/.claude/prism.mcp.json` is a new write surface introduced in v1.1 (D-DEC-003 cron config).

   > **Previous (v1.0):** "`settings.json` (shared team settings) is never modified — only `settings.local.json` (per-project, typically gitignored)." The v1.1 narrow exception: `~/.claude/settings.json` (global user settings, distinct from project-level `settings.json`) receives the `mcpServers.prism` key only.

   Confidence: D-DEC-003 binding decision (architecture-delta.md v1.1).

3. **[Preserved v1.0]** If `settings.local.json` exists but is corrupt (fails jq parse), the skill shows the parse error and stops — it never overwrites a corrupt file. Confidence: verified by code analysis (Red Flag: "settings.local.json doesn't parse, I'll overwrite it" → "Never clobber a corrupt file."). This guard applies equally to `~/.claude/settings.json` (EC-011).
4. **[Preserved v1.0]** A SecOps Factory activation does not remove or disable other plugins (agents, skills, hooks remain available). Confidence: verified by code analysis (Notes: "Coexistence").

5. **[NEW v1.1] `RUST_LOG=off` MUST be injected in BOTH MCP config locations (`~/.claude/settings.json` mcpServers.prism.env AND `~/.claude/prism.mcp.json` mcpServers.prism.env) unconditionally.** Rationale: prism's default `RUST_LOG` output includes structured log lines on stderr that Claude Code's stdio MCP transport interprets as framing, causing MCP message parse failures. Setting `RUST_LOG=off` disables all stderr log output from the prism process. This invariant applies even in debug configurations — do NOT set `RUST_LOG` to any non-off value in the MCP env block. Confidence: D-DEC-003 framing-corruption rationale (architecture-delta.md v1.1 §D-DEC-003).

6. **[NEW v1.1]** No demo-project references. The activate skill MUST NOT reference, create, or link to any demo project directory, demo sensor configuration, or example data directory. Activation is scoped to the real project being set up. Confidence: D-006 naming constraint (architecture-delta.md v1.1 §D-DEC-006, extended to demo content prohibition).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `settings.local.json` does not exist | Start from `{}` and write activation block |
| EC-002 | `settings.local.json` exists with `agent: vsdd-factory:orchestrator:orchestrator` | Warn user which agent currently holds default; ask for confirmation before replacing |
| EC-003 | `settings.local.json` exists with `agent: secops-factory:orchestrator:orchestrator` | Already activated; confirm to user (idempotent re-run); still run prism version gate and dual-write check |
| EC-004 | `settings.local.json` is malformed JSON | Show parse error; stop; do not overwrite |
| EC-005 | `--dry-run` flag provided | Print proposed diff for ALL write operations (settings.local.json, settings.json mcpServers.prism key, prism.mcp.json); exit without writing |
| EC-006 | Running on Windows native shell | Copy `hooks.json.windows` to `hooks.json`; report which hooks variant was applied |
| EC-007 | Running on macOS/Linux | Leave `hooks.json` untouched; confirm `.sh` variant is active |
| EC-008 | Prism binary not found and network unavailable for download | Activate settings.local.json; warn "Prism binary not available — MCP integration skipped. Re-run activate when network is available."; skip postconditions #8–#11 |
| EC-009 | Prism binary found but version is v0.9.5 (< v1.0.0-rc.1) | Halt with "Prism binary version v0.9.5 does not meet minimum requirement v1.0.0-rc.1. Please upgrade."; no MCP config written |
| EC-010 | `jr auth status` returns non-zero (not authenticated) | Halt with setup instructions ("jr auth login; then re-run /activate"); agent key WAS written to settings.local.json but activation not complete |
| EC-011 | `~/.claude/settings.json` exists but is malformed JSON | Show parse error for `settings.json`; stop the MCP config write; do not overwrite; prism.mcp.json write is also skipped (both writes must succeed together) |
| EC-012 | Idempotent re-run: `~/.claude/settings.json` already has `mcpServers.prism` key with RUST_LOG=off | Merge is a no-op; confirm "prism MCP already configured — settings unchanged"; still run `jr auth status` |
| EC-013 | `jira_project_key` absent at activate time (user skips prompt or provides empty string) | Activate prompts user: "Enter your Jira project key (e.g., SEC, PRISMDEMO, SECOPS):"; validates non-empty + `^[A-Z][A-Z0-9]+$` charset; blocks completion until a valid value is provided or user explicitly cancels. If user cancels: activation halts with "jira_project_key is required before the monitoring-loop can run. Re-run /activate to complete setup." No partial state is written. |
| EC-014 | User provides `jira_project_key` containing a hyphen (e.g., `PRISM-DEMO`) — non-conformant to `^[A-Z][A-Z0-9]+$` | Activate emits user-facing error: "Invalid Jira project key 'PRISM-DEMO': Jira project keys must be uppercase alphanumeric with no hyphens or spaces — e.g., PRISMDEMO, SEC, SECOPS." Activation refuses to complete; user must supply a conformant key. No partial state is written. **(P13-002 fail-early requirement: bad key must not reach marker mechanism)** |

## Canonical Test Vectors

| Scenario | Expected Behavior | Category |
|----------|------------------|----------|
| No existing settings.local.json; prism v1.2.0 installed; jr authenticated | Write settings.local.json; dual-write settings.json mcpServers.prism + prism.mcp.json (both with RUST_LOG=off); jr auth status passes; display AD-017 instructions | happy-path |
| settings.local.json with other keys; prism installed; jr authenticated | Merge activation block; preserve other keys; dual MCP write | happy-path |
| settings.local.json with vsdd-factory agent | Warn; ask confirmation; replace only if user confirms | edge-case |
| Corrupt settings.local.json | Show parse error; stop | error |
| `--dry-run` | Print proposed diff for all 3 write targets; no file modification | edge-case |
| Prism v0.9.5 (version gate failure) | Halt with version error; no MCP config written | error (EC-009) |
| `jr auth status` fails | Halt with setup instructions; settings.local.json agent key was written | error (EC-010) |
| Corrupt `~/.claude/settings.json` | Show parse error; stop MCP write; do not overwrite | error (EC-011) |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-SKILL-021 | Skill targets settings.local.json (never project-level settings.json) | integration / BATS (`skills.bats:323-325`) |
| VP-SKILL-022 | Skill sets `"agent": "secops-factory:orchestrator:orchestrator"` | integration / BATS (`skills.bats:319-322`) |
| VP-SKILL-023 | disable-model-invocation: true is set | integration / BATS (`skills.bats:327-329`) |
| VP-SKILL-024 | Announce at Start present | integration / BATS (`skills.bats:331-334`) |
| VP-SKILL-025 | Red Flags table has >= 6 rows | integration / BATS (`skills.bats:335-338`) |
| VP-SKILL-051 | `prism --version` subprocess output is parsed and compared to minimum version `1.0.0-rc.1`; versions below minimum cause halt with version-gate error message (EC-009); versions at or above proceed to dual MCP write | integration / BATS (`@test "activate halts on prism version below minimum"`, `@test "activate proceeds with prism version at minimum"`) |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-LIFECYCLE-01 |
| L2 Domain Invariants | No hijack-on-enable; per-project activation scope; RUST_LOG=off MCP framing invariant (Invariant #5) |
| Architecture Module | C-2 (skill-procedures), C-25 (prism-mcp config writer) |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/skills/activate/SKILL.md` (~82 lines) |
| **Confidence** | high for v1.0 behavior (step-by-step procedure explicitly documented; exact JSON values for agent key and metadata block are specified; BATS tests at `skills.bats:318-338`); D-DEC-003 binding decision for v1.1 prism additions (not yet in source code; architect approval required) |
| **Extraction Date** | 2026-07-20 |

#### Evidence Types Used

- **type constraint**: `disable-model-invocation: true` — runtime enforcement that no LLM dispatch occurs
- **documentation**: exact JSON merge block with agent key value and metadata structure
- **guard clause**: corrupt file check (Red Flags) and competing agent check (Step 3)
- **documentation**: platform detection logic for hooks variant selection
- **D-DEC-003 binding decision**: dual MCP config write, RUST_LOG=off invariant, cron packaging
- **AD-017**: piped-stdin credential pattern for next-step instructions (display only, no credential collection during activate)

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads `settings.local.json` (filesystem), writes `settings.local.json`; v1.1 additions: reads/writes `~/.claude/settings.json` (mcpServers.prism key only), writes `~/.claude/prism.mcp.json`, executes `prism --version` subprocess, executes `jr auth status` subprocess, optionally downloads prism binary |
| **Global state access** | `~/.claude/settings.json` (global user settings — mcpServers.prism key only); `~/.claude/prism.mcp.json` (new file) |
| **Deterministic** | yes given same inputs (existing file content + platform + prism version) |
| **Thread safety** | not applicable |
| **Overall classification** | effectful shell (filesystem read/write + subprocess execution) |

#### Refactoring Notes

The JSON merge logic for both `settings.local.json` and `~/.claude/settings.json` is a pure function given the existing file content. The platform detection logic (Windows vs. not Windows) is also a pure predicate. The version comparison (`prism --version` string ≥ `1.0.0-rc.1`) is a pure function given the subprocess output.

**Undocumented behavior (ambiguity, carried from v1.0):** The `activated_plugin_version` in the metadata block requires reading `plugins/secops-factory/.claude-plugin/plugin.json` at activation time. If the plugin is installed but the version cannot be read (e.g., the file is missing), the skill's behavior is unspecified — the Red Flags do not cover this case.

**D-DEC-003 dual-write rationale:** The `~/.claude/settings.json` write ensures prism MCP is available in interactive Claude Code sessions. The `~/.claude/prism.mcp.json` write enables cron/headless sessions via `--strict-mcp-config --mcp-config ~/.claude/prism.mcp.json` (D-DEC-003 cron wrapper). Both files must have identical `mcpServers.prism` content including `RUST_LOG=off` (Invariant #5).

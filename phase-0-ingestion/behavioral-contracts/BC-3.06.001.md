---
document_type: behavioral-contract
level: L3
version: "1.2"
status: draft
producer: architect
timestamp: 2026-07-19T00:00:00
phase: 0d
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/hooks/session-greeting.sh, plugins/secops-factory/tests/hooks.bats]
input-hash: |
  e1068218d7d7a89f52d289020dbbbfaa832db0f78d01f55f5e351f74839cbc4b  plugins/secops-factory/hooks/session-greeting.sh
  b1a920bc4371563bf3d602117a9bcb8a2db99a8a55b6f399a1e37ff663ecd56a  plugins/secops-factory/hooks/session-greeting.ps1
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/hooks/session-greeting.sh
subsystem: enforcement-hooks
capability: CAP-ENFORCEMENT-06
lifecycle_status: active
introduced: v0.7.0
modified: ["v1.1-ADV-0-403-2026-07-19", "v1.2-ADV-0-507-2026-07-19"]
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-3.06.001: session-greeting Hook — Activation-Gated SessionStart Banner

## Preconditions

1. The hook receives a `SessionStart` event envelope via stdin as JSON, containing `cwd` (string — the project directory path). Confidence: verified by code analysis (`hooks/session-greeting.sh:22`).
2. The hook reads `.claude/settings.local.json` at `<cwd>/.claude/settings.local.json` to determine if the SecOps Factory orchestrator is the active default agent. Confidence: verified by code analysis (`hooks/session-greeting.sh:28-38`).
3. The activation gate key is: `settings.local.json` must exist AND its `.agent` field must equal exactly `"secops-factory:orchestrator:orchestrator"`. Confidence: verified by code analysis (`hooks/session-greeting.sh:35`).

## Postconditions

1. If `<cwd>/.claude/settings.local.json` does not exist, the hook exits 0 with no output (silent). Confidence: verified by code analysis (`hooks/session-greeting.sh:29`) and test `@test "session-greeting is silent when settings.local.json is absent"` (hooks.bats:190).
2. If the file exists but `.agent` does not equal `"secops-factory:orchestrator:orchestrator"`, the hook exits 0 with no output (silent). Confidence: verified by code analysis (`hooks/session-greeting.sh:35`) and test `@test "session-greeting is silent when factory is not activated"` (hooks.bats:197).
3. If the file exists and `.agent` equals `"secops-factory:orchestrator:orchestrator"`, the hook emits a JSON envelope containing `systemMessage` (banner text) and `hookSpecificOutput.additionalContext` (context for Morgan's first reply). Confidence: verified by code analysis (`hooks/session-greeting.sh:43-50`) and test `@test "session-greeting greets when factory is activated"` (hooks.bats:205).
4. The `systemMessage` always contains the string "Morgan here". Confidence: verified by code analysis (`hooks/session-greeting.sh:40`) and test `@test "session-greeting greets when factory is activated"` (hooks.bats:211 — `[[ "$output" == *"Morgan here"* ]]` assertion).
5. The `hookSpecificOutput.hookEventName` is always `"SessionStart"`. Confidence: verified by code analysis (`hooks/session-greeting.sh:45`) and test `@test "session-greeting greets when factory is activated"` (hooks.bats:212 — `[[ "$output" == *'"hookEventName":"SessionStart"'* ]]` assertion).
6. The `additionalContext` field instructs Morgan not to re-introduce itself on the first reply (it was already shown the banner). Confidence: verified by code analysis (`hooks/session-greeting.sh:41`).
7. If `settings.local.json` exists but is malformed JSON, the hook exits 0 with no output (fail-open). Confidence: verified by code analysis (`hooks/session-greeting.sh:33-38` — `jq` parse failure falls through to `exit 0`) and test `@test "session-greeting survives corrupt settings.local.json"` (hooks.bats:223).

## Invariants

1. The hook never modifies `settings.local.json` — it is read-only for this hook. Writing that file is the `activate` skill's responsibility. Confidence: verified by code analysis (no write operations in hook body).
2. The greeting is only emitted for the secops-factory orchestrator agent, never for other agents. Plugin enablement alone (without activation) does not trigger the greeting. Confidence: verified by code analysis and the explicit activation-gate logic.
3. If `jq` is unavailable, the hook falls back to `grep -qF` for the agent check and `printf` for the JSON output. The fallback path preserves the greeting behavior and activation gate. Confidence: verified by code analysis (`hooks/session-greeting.sh:21-24, 37-38, 48-50`).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `cwd` field missing from stdin JSON | `PROJECT_DIR` falls back to `$CLAUDE_PROJECT_DIR` or `$PWD`; check proceeds |
| EC-002 | `settings.local.json` absent | Silent exit 0 |
| EC-003 | `settings.local.json` has `agent: vsdd-factory:orchestrator:orchestrator` | Silent exit 0 (not secops-factory) |
| EC-004 | `settings.local.json` has `agent: secops-factory:orchestrator:orchestrator` | Emit greeting JSON with systemMessage |
| EC-005 | `settings.local.json` is malformed (`{` only) | Silent exit 0 (jq parse failure → fallthrough) |
| EC-006 | `jq` not available on PATH | Falls back to `grep -qF` for gate check; uses `printf` for JSON output; activation gate still works |
| EC-007 | Emitted JSON fails `jq .` parse | Test `@test "session-greeting emits valid JSON when activated"` (hooks.bats:216) verifies valid JSON output |

## Canonical Test Vectors

| Scenario | `settings.local.json` content | Expected Output |
|----------|-------------------------------|----------------|
| No settings file | (absent) | Empty stdout, exit 0 |
| Non-secops agent active | `{"agent": "vsdd-factory:orchestrator:orchestrator"}` | Empty stdout, exit 0 |
| SecOps orchestrator active | `{"agent": "secops-factory:orchestrator:orchestrator"}` | JSON with `systemMessage` containing "Morgan here", `hookEventName: "SessionStart"`, `additionalContext` present |
| Corrupt settings file | `this is not json {` | Empty stdout, exit 0 |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-HOOK-016 | Absent settings file always produces silent exit | integration / BATS |
| VP-HOOK-017 | Non-secops agent produces no greeting | integration / BATS |
| VP-HOOK-018 | secops-factory orchestrator agent produces valid greeting JSON | integration / BATS |
| VP-HOOK-019 | Corrupt settings file produces silent exit (fail-open) | integration / BATS |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-ENFORCEMENT-06 |
| L2 Domain Invariants | No hijack-on-enable (activation gate prevents greeting without explicit activation) |
| Architecture Module | C-17 (session-greeting-hook) |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/hooks/session-greeting.sh` (~51 lines) + `.ps1` sibling |
| **Confidence** | high — full activation-gate logic visible in source; BATS tests `@test "session-greeting is silent when settings.local.json is absent"` (hooks.bats:190), `@test "session-greeting is silent when factory is not activated"` (hooks.bats:197), `@test "session-greeting greets when factory is activated"` (hooks.bats:205), `@test "session-greeting emits valid JSON when activated"` (hooks.bats:216), `@test "session-greeting survives corrupt settings.local.json"` (hooks.bats:223) exercise 5 scenarios including corrupt file |
| **Extraction Date** | 2026-07-19 |

#### Evidence Types Used

- **guard clause**: `[ -f "$SETTINGS" ] || exit 0` — file existence gate (line 29)
- **guard clause**: `[ "$AGENT" = "secops-factory:orchestrator:orchestrator" ] || exit 0` — activation gate (line 35)
- **documentation**: header comment documents the no-hijack-on-enable design decision
- **inferred**: `additionalContext` field semantics are documented in the hook script's comment

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads stdin (cwd); reads `settings.local.json`; writes stdout (JSON) |
| **Global state access** | reads filesystem (settings file) |
| **Deterministic** | yes given same settings file content |
| **Thread safety** | not applicable |
| **Overall classification** | effectful shell (filesystem read) |

#### Refactoring Notes

The filesystem read (settings.local.json) makes this hook not purely pure — it depends on external state. However, the behavior is still deterministic given the settings file content. The activation gate logic (string comparison of agent field) could be extracted as a pure function. The JSON emission could be a pure formatting operation. Formal verification of the gate logic is feasible as a unit test against the parsing logic.

---
document_type: behavioral-contract
level: L3
version: "1.0"
status: draft
producer: architect
timestamp: 2026-07-19T00:00:00
phase: 0d
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/hooks/require-review.sh, plugins/secops-factory/tests/hooks.bats]
input-hash: ""
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/hooks/require-review.sh
subsystem: enforcement-hooks
capability: CAP-ENFORCEMENT-01
lifecycle_status: active
introduced: v0.7.0
modified: []
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-3.01.001: require-review Hook — Jira Field-Modification Gate

## Preconditions

1. The hook receives a Claude Code `PreToolUse/Bash` event envelope via stdin as JSON, containing `tool_input.command` (string). Confidence: verified by code analysis (`hooks/require-review.sh:39`).
2. `jq` is installed and available on `$PATH`. If absent, the hook exits with code 1 and an error to stderr; it never emits a `permissionDecision` envelope. Confidence: verified by code analysis (`hooks/require-review.sh:14-17`).
3. The hook is wired via `hooks.json` to fire on `PreToolUse` events for the `Bash` tool only. Confidence: verified by code analysis (`hooks/hooks.json`).

## Postconditions

1. If `tool_input.command` does not contain the substring `jr `, the hook emits `permissionDecision: allow` and exits 0. Confidence: verified by code analysis (`hooks/require-review.sh:42-44`).
2. If `tool_input.command` contains `jr issue edit`, `jr issue move`, `jr issue assign`, or `jr issue create`, the hook emits `permissionDecision: deny` with a reason string containing the phrase "review approval". Confidence: verified by code analysis (`hooks/require-review.sh:66-71`).
3. If `tool_input.command` contains any jr read-only subcommand (`jr issue view`, `jr issue list`, `jr issue comments`, `jr issue assets`, `jr issue transitions`, `jr sprint`, `jr board`, `jr project`, `jr me`, `jr auth`), the hook emits `permissionDecision: allow` and exits 0. Confidence: verified by code analysis (`hooks/require-review.sh:47-58`).
4. If `tool_input.command` contains `jr issue comment`, the hook emits `permissionDecision: allow` (posting review results is allowed without prior review approval). Confidence: verified by code analysis (`hooks/require-review.sh:61-63`) and test `hooks.bats:21-25`.
5. For any unrecognized `jr` subcommand not in the allow or deny lists, the hook emits `permissionDecision: allow` (fail-open). Confidence: verified by code analysis (`hooks/require-review.sh:73-74`).
6. The exit code is always 0 for all business-logic decisions (both allow and deny). Exit code 1 is reserved exclusively for missing `jq` dependency. Confidence: verified by code analysis (`hooks/require-review.sh:23, 35`).

## Invariants

1. The JSON output envelope structure is always `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"|"deny","permissionDecisionReason":"..."}}`. Confidence: verified by code analysis (`hooks/require-review.sh:22-35`).
2. The hook never makes network calls, never spawns subprocesses beyond `jq`, and never reads the filesystem — all decisions are made from the single stdin JSON envelope. Execution is bounded at < 100ms. Confidence: verified by code analysis (full file).
3. The hook is fail-open: any parse failure or unrecognized command results in allow, not deny. Confidence: verified by code analysis (`hooks/require-review.sh:73-74`).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `jq` not installed | Exit code 1, stderr message "jq is required but not found", no JSON output |
| EC-002 | Empty stdin / malformed JSON | `jq -r '.tool_input.command // empty'` returns empty string; command is not `jr `; emit allow |
| EC-003 | `jr issue comment` with long message | Allow — comment operations are explicitly whitelisted (`hooks/require-review.sh:61-63`) |
| EC-004 | `jr issue edit` preceded by review approval (human-context marker) | Deny — the hook has no memory of prior context; it checks only the current tool call command string. Review approval state is tracked by the skill layer, not the hook. |
| EC-005 | `jr issue move SEC-123 Enriched` | Deny — `jr issue move` matches the field-modifying blocklist |
| EC-006 | `jr auth login` | Allow — `jr auth` is explicitly in the read-only allowlist |
| EC-007 | `ls -la` (non-jr command) | Allow — fast path: no `jr ` substring |
| EC-008 | `jr issue assign SEC-123 @user` | Deny — `jr issue assign` is in the blocklist |

## Canonical Test Vectors

| Input (`tool_input.command`) | Expected Output | Category |
|------------------------------|----------------|----------|
| `ls -la` | `permissionDecision: allow` | happy-path |
| `jr issue view SEC-123` | `permissionDecision: allow` | happy-path |
| `jr issue comment SEC-123 "enrichment complete"` | `permissionDecision: allow` | happy-path |
| `jr issue edit SEC-123 --priority Critical` | `permissionDecision: deny`, reason contains "review approval" | error |
| `jr issue move SEC-123 Enriched` | `permissionDecision: deny` | error |
| `jr sprint list` | `permissionDecision: allow` | edge-case |
| `jr unknown-future-subcommand` | `permissionDecision: allow` | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-HOOK-001 | For all inputs where command contains `jr issue edit`, `jr issue move`, `jr issue assign`, or `jr issue create`, output always contains `"permissionDecision":"deny"` | integration / BATS |
| VP-HOOK-002 | Hook exit code is always 0 when jq is present (both allow and deny paths) | integration / BATS |
| VP-HOOK-003 | Non-jr commands always receive allow (fail-open invariant) | integration / BATS |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-ENFORCEMENT-01 |
| L2 Domain Invariants | Iron Law: NO JIRA UPDATE WITHOUT REVIEW APPROVAL FIRST |
| Architecture Module | C-12 (require-review-hook) |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/hooks/require-review.sh` (75 lines) + `.ps1` sibling |
| **Confidence** | high — explicit allow/deny logic fully visible in source; BATS tests at `tests/hooks.bats:9-38` exercise all documented paths |
| **Extraction Date** | 2026-07-19 |

#### Evidence Types Used

- **guard clause**: `if [[ "$COMMAND" != *"jr "* ]]; then emit_allow fi` — explicit fast-path allow (line 42-44)
- **guard clause**: blocklist match for `jr issue edit/move/assign/create` (lines 66-71)
- **type constraint**: JSON envelope structure enforced by `jq -nc` output template
- **assertion**: `command -v jq` check — fails hard if dependency missing (lines 14-17)
- **inferred**: PowerShell `.ps1` sibling is behaviorally identical (enforced by `parity.bats`)

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads stdin once; writes stdout (JSON envelope) |
| **Global state access** | none |
| **Deterministic** | yes — same input always produces same JSON output |
| **Thread safety** | not applicable (single-process hook invoked per tool event) |
| **Overall classification** | pure core (deterministic stdin→stdout transformer, no side effects) |

#### Refactoring Notes

The hook is already pure: it reads stdin, applies pattern matching to a string field, and emits a deterministic JSON response. Suitable for formal property verification of the allow/deny routing logic. No refactoring needed for formal verification.

**Undocumented behavior (ambiguity):** The hook does not parse the `--review-approved` flag or any session-context marker. The `update-jira` skill checks for a review-approval marker in conversation context before calling `jr issue edit`, but the hook itself always blocks `jr issue edit` unconditionally. This means the hook will also block a manually typed `jr issue edit` command regardless of review state. The review-approval gating is a two-layer system: skill-layer (checks context) and hook-layer (unconditional block). If the skill bypasses the hook by some other means, the Iron Law can be violated. This gap is noted for architecture attention.

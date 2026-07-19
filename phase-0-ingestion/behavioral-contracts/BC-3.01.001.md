---
document_type: behavioral-contract
level: L3
version: "1.1"
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
modified: ["v0.9.x-PR13-2026-07-19"]
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-3.01.001: require-review Hook — Jira Field-Modification Gate

> **Revision history:**
> - v1.0 (2026-07-19): Initial extraction from `require-review.sh` at v0.9.0 HEAD (Step 0d).
> - v1.1 (2026-07-19): Revised to reflect PR #13 (commit f450d9f) behavior changes — SEC-001 (`jr issue comment` moved from allow to deny) and SEC-002 (unknown jr subcommands changed from fail-open to fail-closed). Previous postconditions #4 and #5 and invariant #3 were stale.

## Preconditions

1. The hook receives a Claude Code `PreToolUse/Bash` event envelope via stdin as JSON, containing `tool_input.command` (string). Confidence: verified by code analysis (`hooks/require-review.sh:40`).
2. `jq` is installed and available on `$PATH`. If absent, the hook exits with code 1 and an error to stderr; it never emits a `permissionDecision` envelope. Confidence: verified by code analysis (`hooks/require-review.sh:14-17`).
3. The hook is wired via `hooks.json` to fire on `PreToolUse` events for the `Bash` tool only. Confidence: verified by code analysis (`hooks/hooks.json`).

## Postconditions

1. If `tool_input.command` does not contain the substring `jr `, the hook emits `permissionDecision: allow` and exits 0. Confidence: verified by code analysis (`hooks/require-review.sh:42-44`) and BATS test `hooks.bats:9-13`.
2. If `tool_input.command` contains any of `jr issue comment`, `jr issue edit`, `jr issue move`, `jr issue assign`, or `jr issue create`, the hook emits `permissionDecision: deny` with a reason string containing "review approval". The deny reason names all five blocked subcommands explicitly. Confidence: verified by code analysis (`hooks/require-review.sh:65-71`) and BATS tests `hooks.bats:21-26, 34-39, 41-45`.
3. If `tool_input.command` contains any jr read-only subcommand (`jr issue view`, `jr issue list`, `jr issue comments`, `jr issue assets`, `jr issue transitions`, `jr sprint`, `jr board`, `jr project`, `jr me`, `jr auth`), the hook emits `permissionDecision: allow` and exits 0. Confidence: verified by code analysis (`hooks/require-review.sh:47-59`) and BATS test `hooks.bats:15-19`.
4. For any `jr` subcommand that does not match the explicit read-only allowlist (postcondition #3) and does not match the explicit deny list (postcondition #2), the hook emits `permissionDecision: deny` with a reason instructing the operator to add the subcommand to the read-only allowlist if it is safe (fail-closed, SEC-002). Confidence: verified by code analysis (`hooks/require-review.sh:73-75`) and BATS test `hooks.bats:28-32`.
5. The exit code is always 0 for all business-logic decisions (both allow and deny). Exit code 1 is reserved exclusively for missing `jq` dependency. Confidence: verified by code analysis (`hooks/require-review.sh:23, 35`).

## Invariants

1. The JSON output envelope structure is always `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"|"deny","permissionDecisionReason":"..."}}`. Confidence: verified by code analysis (`hooks/require-review.sh:22-35`).
2. The hook never makes network calls, never spawns subprocesses beyond `jq`, and never reads the filesystem — all decisions are made from the single stdin JSON envelope. Execution is bounded at < 100ms. Confidence: verified by code analysis (full file).
3. The hook is fail-closed for all `jr` subcommands: any `jr` command that is not on the explicit read-only allowlist results in deny, not allow. Non-jr commands remain on a fast-path allow. This replaced the previous fail-open behavior as of PR #13 (SEC-002). Confidence: verified by code analysis (`hooks/require-review.sh:73-75`).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | `jq` not installed | Exit code 1, stderr message "jq is required but not found", no JSON output |
| EC-002 | Empty stdin / malformed JSON | `jq -r '.tool_input.command // empty'` returns empty string; command is not `jr `; emit allow |
| EC-003 | `jr issue comment SEC-123 "enrichment complete"` | Deny with reason containing "review approval" (SEC-001 — comment is a write to the authoritative Jira record) |
| EC-004 | `jr issue edit` with any arguments | Deny with reason containing "review approval" |
| EC-005 | `jr issue move SEC-123 Enriched` | Deny — `jr issue move` is in the write blocklist |
| EC-006 | `jr auth login` | Allow — `jr auth` is explicitly in the read-only allowlist |
| EC-007 | `ls -la` (non-jr command) | Allow — fast path: no `jr ` substring |
| EC-008 | `jr issue assign SEC-123 @user` | Deny — `jr issue assign` is in the write blocklist |
| EC-009 | `jr issue duplicate SEC-123` (unrecognized subcommand) | Deny with reason "Unrecognized jr subcommand. Add to the read-only allowlist..." (SEC-002 — fail-closed) |
| EC-010 | `jr issue changelog SEC-123` (read-only but not in allowlist) | Deny — not on read-only allowlist; operator must add it explicitly if safe |

## Canonical Test Vectors

| Input (`tool_input.command`) | Expected Output | Category |
|------------------------------|----------------|----------|
| `ls -la` | `permissionDecision: allow` | happy-path |
| `jr issue view SEC-123` | `permissionDecision: allow` | happy-path |
| `jr sprint list` | `permissionDecision: allow` | happy-path |
| `jr issue comment SEC-123 "enrichment complete"` | `permissionDecision: deny`, reason contains "review approval" | error |
| `jr issue edit SEC-123 --priority Critical` | `permissionDecision: deny`, reason contains "review approval" | error |
| `jr issue move SEC-123 Enriched` | `permissionDecision: deny` | error |
| `jr issue duplicate SEC-123` | `permissionDecision: deny`, reason contains "allowlist" | edge-case |
| `jr issue changelog SEC-123` | `permissionDecision: deny`, reason contains "allowlist" | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-HOOK-001 | For all inputs where command contains `jr issue comment`, `jr issue edit`, `jr issue move`, `jr issue assign`, or `jr issue create`, output always contains `"permissionDecision":"deny"` | integration / BATS |
| VP-HOOK-002 | Hook exit code is always 0 when jq is present (both allow and deny paths) | integration / BATS |
| VP-HOOK-003 | Any unrecognized `jr` subcommand receives deny (fail-closed invariant, SEC-002) | integration / BATS (`hooks.bats:28-32`) |

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
| **Path** | `plugins/secops-factory/hooks/require-review.sh` (76 lines, post-PR #13) + `.ps1` sibling |
| **Confidence** | high — explicit allow/deny logic fully visible in source; BATS tests at `tests/hooks.bats:9-45` exercise all documented paths including new SEC-001 and SEC-002 tests |
| **Extraction Date** | 2026-07-19 |
| **Last Verified Against** | commit f450d9f (PR #13 merge commit) |

#### Change Log (v1.0 → v1.1)

**PR #13 (commit f450d9f, 2026-07-19) — two behavioral changes:**

| Change | SEC ID | Old Behavior (v1.0) | New Behavior (v1.1) |
|--------|--------|---------------------|---------------------|
| `jr issue comment` routing | SEC-001 | Allow — comment was explicitly whitelisted (old postcondition #4) | Deny — moved into the write-operations block; reason contains "review approval" |
| Unknown jr subcommand routing | SEC-002 | Allow — fail-open (old postcondition #5 / invariant #3) | Deny — fail-closed; reason instructs operator to add to read-only allowlist if safe |

**Rationale (from PR #13 source comments):** `jr issue comment` posts to the authoritative Jira record and is therefore a write operation that must pass the same review gate as field edits. Unknown subcommands are denied rather than allowed to prevent future `jr` releases from adding write subcommands that would bypass the gate silently.

**BATS test changes:** `hooks.bats` test at line 21 changed from `"require-review allows jr issue comment"` → `"require-review blocks jr issue comment without review (SEC-001)"`. New test added at line 28: `"require-review blocks unknown mutation-shaped jr subcommand (SEC-002)"`.

#### Evidence Types Used

- **guard clause**: `if [[ "$COMMAND" != *"jr "* ]]; then emit_allow fi` — explicit fast-path allow for non-jr commands (`hooks/require-review.sh:43-45`)
- **guard clause**: explicit read-only allowlist with `emit_allow` (lines 47-59)
- **guard clause**: blocklist match for `jr issue comment/edit/move/assign/create` → emit_deny (lines 65-71)
- **guard clause**: fail-closed catch-all `emit_deny` for unrecognized jr subcommands (line 75)
- **type constraint**: JSON envelope structure enforced by `jq -nc` output template
- **assertion**: `command -v jq` check — fails hard if dependency missing (lines 14-17)
- **inferred**: PowerShell `.ps1` sibling is behaviorally identical (enforced by `parity.bats`; PS1 confirmed to have identical SEC-001 and SEC-002 logic at `require-review.ps1:56-65`)

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | reads stdin once; writes stdout (JSON envelope) |
| **Global state access** | none |
| **Deterministic** | yes — same input always produces same JSON output |
| **Thread safety** | not applicable (single-process hook invoked per tool event) |
| **Overall classification** | pure core (deterministic stdin→stdout transformer, no side effects) |

#### Refactoring Notes

The hook is pure: it reads stdin, applies pattern matching to a string field, and emits a deterministic JSON response. Suitable for formal property verification of the allow/deny routing logic. No refactoring needed for formal verification.

**Known limitation:** `jr issue changelog` is a read-only operation commonly used by `analyze-ticket-effort` skill (for effort reconstruction from timestamps) but is not in the current read-only allowlist. Under the new fail-closed behavior, `jr issue changelog SEC-123` will be denied. This is a correctness gap that will block the metrics pipeline. The allowlist in `require-review.sh` (and its `.ps1` sibling) should be extended to include `jr issue changelog` before the metrics skills are used in production. This is noted as a drift item for architecture attention.

**Resolved (v1.0 ambiguity):** The previous version noted the fail-open behavior as a gap where new jr write subcommands could bypass the gate. SEC-002 (fail-closed) resolves this — the hook now defaults to deny for any unrecognized jr subcommand.

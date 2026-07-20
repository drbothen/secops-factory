---
document_type: behavioral-contract
level: L3
version: "1.4"
status: draft
producer: architect
timestamp: 2026-07-19T00:00:00
phase: 0d
inputs: [phase-0-ingestion/project-discovery.md, phase-0-ingestion/recovered-architecture.md, plugins/secops-factory/hooks/bias-check-reminder.sh, plugins/secops-factory/tests/hooks.bats]
input-hash: "125eed3"
  a208d8c08d021738686076eaab0461f88f450b27851af4a845cb743371fc7d0e  plugins/secops-factory/hooks/bias-check-reminder.sh
  867b0fcf8eb7d443b54fa622d45a6645204b7d299a0f2e736de1bbd5cba2fa01  plugins/secops-factory/hooks/bias-check-reminder.ps1
traces_to: phase-0-ingestion/recovered-architecture.md
origin: recovered
extracted_from: plugins/secops-factory/hooks/bias-check-reminder.sh
subsystem: enforcement-hooks
capability: CAP-ENFORCEMENT-04
lifecycle_status: active
introduced: v0.7.0
modified: ["v1.1-ADV-0-403-2026-07-19", "v1.2-ADV-0-507-2026-07-19", "v1.3-ADV-0-703-2026-07-19", "v1.4-ADV-0-B01-2026-07-19"]
deprecated: null
deprecated_by: null
replacement: null
retired: null
removed: null
removal_reason: null
---

# Behavioral Contract BC-3.04.001: bias-check-reminder Hook — PostToolUse Advisory Bias Reminder

> **Revision history:**
> - v1.0 (2026-07-19): Initial extraction from `bias-check-reminder.sh` at v0.9.0 HEAD (Step 0d).
> - v1.1 (2026-07-19): ADV-0-403: Re-anchored BATS test references to current @test names.
> - v1.2 (2026-07-19): ADV-0-507: Normalized input-hash to dual-file block scalar (.sh + .ps1).
> - v1.4 (2026-07-19): ADV-0-B01: Updated all live hooks.bats line-number citations to current positions (PR #15 shifted bias-check-reminder tests +88 lines: :119→:207, :124→:212, :130→:218). hooks.bats references now use @test names for churn resilience.
> - v1.3 (2026-07-19): ADV-0-703: Upgraded PC#3 confidence from "inferred" to "verified against hooks.json §A-4 confirmed matcher = Bash|mcp__perplexity__*". Resolved Refactoring Notes ambiguity — hook fires on ALL PostToolUse Bash events AND every Perplexity MCP call; description "after research tool calls" understates the scope.

## Preconditions

1. The hook receives any JSON event via stdin (`PostToolUse` event for Bash and Perplexity tools). Confidence: verified by code analysis — the hook reads no fields from stdin (`hooks/bias-check-reminder.sh`).
2. The hook is non-blocking (advisory only): it writes to stderr, not stdout, and never emits a `permissionDecision` JSON envelope. Confidence: verified by code analysis (`hooks/bias-check-reminder.sh:10-15`).
3. The hook fires on `PostToolUse` events for ALL Bash tool calls and ALL Perplexity MCP tool calls (matcher = `Bash|mcp__perplexity__*`). Confidence: verified against hooks.json §A-4 confirmed matcher. Note: the hook description "after research tool calls" understates the actual trigger scope — the hook fires on every Bash call, not only research-oriented ones.

## Postconditions

1. The hook always exits 0. Confidence: verified by code analysis (`hooks/bias-check-reminder.sh:16`).
2. The hook writes exactly four cognitive bias reminders to stderr: Confirmation bias, Anchoring bias, Availability bias, Automation bias. Confidence: verified by code analysis (`hooks/bias-check-reminder.sh:10-14`).
3. The hook writes a reference path to stderr: `${CLAUDE_PLUGIN_ROOT}/data/cognitive-bias-patterns.md`. Confidence: verified by code analysis (`hooks/bias-check-reminder.sh:15`).
4. The hook produces no stdout output — stdout is always empty. Confidence: verified by code analysis and BATS test `@test "bias-check-reminder exits 0"` (hooks.bats:207) (`[ "$status" -eq 0 ]` only, no output check).

## Invariants

1. The hook output (stderr content) is static and does not vary based on input payload — the same four biases are always listed regardless of what tool call triggered the hook. Confidence: verified by code analysis (no stdin parsing in the hook body).
2. This hook never blocks any operation. It is purely advisory. Confidence: verified by code analysis — no `permissionDecision` envelope is emitted.
3. The hook does not depend on `jq` or any external tools. It uses only bash `echo` and `>&2` redirection. Confidence: verified by code analysis (no `command -v jq` guard).

## Edge Cases

| ID | Description | Expected Behavior |
|----|-------------|-------------------|
| EC-001 | Empty stdin | Exits 0, writes four bias lines to stderr — stdin is not read |
| EC-002 | Malformed JSON stdin | Exits 0 — stdin is not parsed |
| EC-003 | Called in CI environment with stderr suppressed | Exits 0; no observable effect |
| EC-004 | Called multiple times in rapid succession | Exits 0 each time; identical stderr output each time |

## Canonical Test Vectors

| Input (any stdin) | Expected stdout | Expected stderr | Category |
|-------------------|----------------|----------------|----------|
| `{}` | empty | Contains "Confirmation bias" | happy-path |
| `{}` | empty | Contains "Anchoring bias" | happy-path |
| `{}` | empty | Contains "Availability bias" | edge-case |
| `{}` | empty | Contains "Automation bias" | edge-case |

## Verification Properties

| VP-NNN | Property | Proof Method |
|--------|----------|-------------|
| VP-HOOK-010 | Hook always exits 0 regardless of input | integration / BATS |
| VP-HOOK-011 | Stderr contains "Confirmation bias" | integration / BATS |
| VP-HOOK-012 | Stderr contains "Anchoring bias" | integration / BATS |

## Traceability

| Field | Value |
|-------|-------|
| L2 Capability | CAP-ENFORCEMENT-04 |
| L2 Domain Invariants | Cognitive bias mitigation (advisory, not structural) |
| Architecture Module | C-15 (bias-check-reminder-hook) |
| Stories | TBD (filled by story-writer) |

---

### Brownfield-Specific Sections

#### Source Evidence

| Property | Value |
|----------|-------|
| **Path** | `plugins/secops-factory/hooks/bias-check-reminder.sh` (16 lines) + `.ps1` sibling |
| **Confidence** | high — simplest hook in the suite; no branching logic; BATS tests `@test "bias-check-reminder exits 0"` (hooks.bats:207), `@test "bias-check-reminder mentions confirmation bias on stderr"` (hooks.bats:212), `@test "bias-check-reminder mentions anchoring bias on stderr"` (hooks.bats:218) |
| **Extraction Date** | 2026-07-19 |

#### Evidence Types Used

- **type constraint**: hook is PostToolUse advisory — no permissionDecision output ever (enforced by hook type)
- **documentation**: four specific bias names are hardcoded

#### Purity Classification

| Property | Assessment |
|----------|-----------|
| **I/O operations** | writes stderr only |
| **Global state access** | none |
| **Deterministic** | yes — always same output |
| **Thread safety** | not applicable |
| **Overall classification** | pure core |

#### Refactoring Notes

Simplest possible hook. No refactoring needed. No ambiguities.

**Broader-than-described trigger scope (verified):** The hook fires on ALL `PostToolUse` Bash events AND ALL Perplexity MCP tool calls (matcher = `Bash|mcp__perplexity__*`, confirmed in hooks.json §A-4). The hook description "after research tool calls" understates the actual scope — the reminder fires after every Bash command (including non-research operations like `jr issue view`, `cat`, etc.). Since the hook is purely advisory (stderr-only, exit 0 always), the broader trigger scope is a documentation inaccuracy, not a behavioral defect. No remediation action required.

#!/usr/bin/env bash
# require-review.sh — PreToolUse hook that blocks JIRA field updates
# via jr CLI without review approval.
#
# Matches Bash tool calls. Only intervenes when the command contains
# jr CLI operations. Allows read-only jr commands (view, list, changelog,
# sprint, assets, version, etc.) and denies all write operations —
# including jr issue comment — as well as any unrecognized jr subcommands
# (fail-closed, SEC-002).
#
# The allowlist covers both plain forms (jr issue view KEY) and the
# --output json forms used by the metrics suite (jr --output json issue view KEY).
# Both forms are read-only; they differ only in output encoding.
#
# Emits a PreToolUse JSON envelope with permissionDecision.
# Deterministic, <100ms, no LLM.

set -euo pipefail

if ! command -v jq &>/dev/null; then
  echo "require-review.sh: jq is required but not found" >&2
  exit 1
fi

INPUT=$(cat)

emit_allow() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}\n'
  exit 0
}

emit_deny() {
  local reason="$1"
  jq -nc --arg reason "$reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

# Extract the command being run
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Fast path: not a jr command → allow immediately
if [[ "$COMMAND" != *"jr "* ]]; then
  emit_allow
fi

# _validate_marker_for_command COMMAND
#
# NOT-IMPLEMENTED (S-3.01 stub): Phase 2 iterative marker-consume algorithm with
# STEP 6 exact-type matching per BC-3.01.001 v1.25 D-DEC-001 v2.0.
#
# When implemented this function must:
#   - Scan ${CLAUDE_PLUGIN_DATA}/markers/*.marker.json for a valid unexpired
#     scoped marker (path-safety, JSON-parse, TTL, anchored command_pattern checks)
#   - Enforce STEP 6 exact-type matching:
#       link command   → only ticket_action_type == ["link"]   (D-020, AC-005)
#       close command  → only ticket_action_type == ["close"]  (D-021, AC-006)
#       close command_pattern bound to CLOSE_STATE_ALLOWLIST   (SM-63 kill, AC-010)
#   - On first successful atomic rename (mv): return 0 (allow)
#   - All candidates exhausted or any error: return 1 (deny, fail-closed)
#
# Returns: 0 = valid marker found and consumed; 1 = deny (no valid marker)
_validate_marker_for_command() {
  # NOT-IMPLEMENTED (S-3.01 stub): marker validation always fails until implementer
  # provides the iterative-consume + STEP 6 exact-type logic (BC-3.01.001 v1.25).
  return 1
}

# Block all jr write operations — requires review approval.
# ORDERING: write-block is evaluated BEFORE the read-only allowlist to prevent
# bypass via allowlist tokens embedded in write-command arguments (ADV-0-801).
# Example bypass (fixed): `jr issue edit KEY --summary "see jr board"` previously
# matched the "jr board" allowlist token and emitted allow before the deny block.
#
# Two families of write patterns:
#   (a) Plain forms:        jr issue edit KEY …
#   (b) --output json forms: jr --output json issue edit KEY …
# Both families are listed explicitly because the plain form "jr issue edit" is NOT
# a substring of "jr --output json issue edit" (the global flag sits between
# "jr" and "issue"), so each needs its own entry.
#
# jr issue comment is blocked (SEC-001): posting to the authoritative Jira record
# is a write operation that must go through the same review gate as field edits.
#
# Write-block entry count: currently 10 of 12.
# NOT-IMPLEMENTED (S-3.01 D-020): two link write-block entries not yet added here.
# When implemented, add the following to the condition below (→ 12 total entries):
#   [[ "$COMMAND" == *"jr issue link "* ]]        (trailing-space guard, plain form)
#   [[ "$COMMAND" == *"--output json issue link "* ]] (trailing-space guard, json form)
if [[ "$COMMAND" == *"jr issue comment "* ]] || \
   [[ "$COMMAND" == *"jr issue edit"* ]] || \
   [[ "$COMMAND" == *"jr issue move"* ]] || \
   [[ "$COMMAND" == *"jr issue assign"* ]] || \
   [[ "$COMMAND" == *"jr issue create"* ]] || \
   [[ "$COMMAND" == *"--output json issue comment "* ]] || \
   [[ "$COMMAND" == *"--output json issue edit"* ]] || \
   [[ "$COMMAND" == *"--output json issue move"* ]] || \
   [[ "$COMMAND" == *"--output json issue assign"* ]] || \
   [[ "$COMMAND" == *"--output json issue create"* ]]; then
  # NOT-IMPLEMENTED (S-3.01 stub): marker-validation branch (D-DEC-001 v2.0) not yet
  # wired here. When implemented, replace this unconditional deny with:
  #   if _validate_marker_for_command "$COMMAND"; then
  #     emit_allow
  #   fi
  # The STEP 6 exact-type matching (link→["link"], close→["close"]) is enforced
  # inside _validate_marker_for_command. Until implemented, all write operations deny.
  emit_deny "JIRA write operations require review approval. Run /review-enrichment or /adversarial-review-secops first to validate analysis quality. The jr issue comment/edit/move/assign/create commands are blocked until review passes quality thresholds."
fi

# Allow read-only jr operations without review.
#
# Two families of patterns:
#   (a) Plain forms:  jr issue view KEY, jr issue changelog KEY, etc.
#   (b) --output json forms: jr --output json issue view KEY, etc.
# Both families are read-only. They are listed separately because the plain form
# "jr issue view" is NOT a substring of "jr --output json issue view" (the global
# flag --output json sits between "jr" and "issue"), so each needs its own entry.
if [[ "$COMMAND" == *"jr issue view"* ]] || \
   [[ "$COMMAND" == *"jr issue list"* ]] || \
   [[ "$COMMAND" == *"jr issue comments"* ]] || \
   [[ "$COMMAND" == *"jr issue assets"* ]] || \
   [[ "$COMMAND" == *"jr issue transitions"* ]] || \
   [[ "$COMMAND" == *"jr issue changelog"* ]] || \
   [[ "$COMMAND" == *"jr assets search"* ]] || \
   [[ "$COMMAND" == *"jr assets view"* ]] || \
   [[ "$COMMAND" == *"jr sprint"* ]] || \
   [[ "$COMMAND" == *"jr board"* ]] || \
   [[ "$COMMAND" == *"jr project"* ]] || \
   [[ "$COMMAND" == *"jr me"* ]] || \
   [[ "$COMMAND" == *"jr auth"* ]] || \
   [[ "$COMMAND" == *"jr --version"* ]] || \
   [[ "$COMMAND" == *"--output json issue view"* ]] || \
   [[ "$COMMAND" == *"--output json issue list"* ]] || \
   [[ "$COMMAND" == *"--output json issue comments"* ]] || \
   [[ "$COMMAND" == *"--output json issue changelog"* ]] || \
   [[ "$COMMAND" == *"--output json issue assets"* ]] || \
   [[ "$COMMAND" == *"--output json assets search"* ]] || \
   [[ "$COMMAND" == *"--output json assets view"* ]]; then
  emit_allow
fi

# Unknown jr subcommand — fail-closed (SEC-002): deny rather than allow to prevent
# new write subcommands added in future jr releases from bypassing this gate.
emit_deny "Unrecognized jr subcommand. Add to the read-only allowlist in require-review.sh if this is a safe read-only operation."

#!/usr/bin/env bash
# require-review.sh — PreToolUse hook that blocks JIRA field updates
# via jr CLI without review approval.
#
# Matches Bash tool calls. Only intervenes when the command contains
# jr CLI operations. Allows read-only jr commands (view, list, sprint, etc.)
# and denies all write operations — including jr issue comment — as well as
# any unrecognized jr subcommands (fail-closed, SEC-002).
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

# Allow read-only jr operations without review
if [[ "$COMMAND" == *"jr issue view"* ]] || \
   [[ "$COMMAND" == *"jr issue list"* ]] || \
   [[ "$COMMAND" == *"jr issue comments"* ]] || \
   [[ "$COMMAND" == *"jr issue assets"* ]] || \
   [[ "$COMMAND" == *"jr issue transitions"* ]] || \
   [[ "$COMMAND" == *"jr sprint"* ]] || \
   [[ "$COMMAND" == *"jr board"* ]] || \
   [[ "$COMMAND" == *"jr project"* ]] || \
   [[ "$COMMAND" == *"jr me"* ]] || \
   [[ "$COMMAND" == *"jr auth"* ]]; then
  emit_allow
fi

# Block all jr write operations — requires review approval
# Includes: comment, edit, move, assign, create, and any unrecognized subcommand.
# jr issue comment is blocked (SEC-001): posting to the authoritative Jira record
# is a write operation that must go through the same review gate as field edits.
if [[ "$COMMAND" == *"jr issue comment"* ]] || \
   [[ "$COMMAND" == *"jr issue edit"* ]] || \
   [[ "$COMMAND" == *"jr issue move"* ]] || \
   [[ "$COMMAND" == *"jr issue assign"* ]] || \
   [[ "$COMMAND" == *"jr issue create"* ]]; then
  emit_deny "JIRA write operations require review approval. Run /review-enrichment or /adversarial-review-secops first to validate analysis quality. The jr issue comment/edit/move/assign/create commands are blocked until review passes quality thresholds."
fi

# Unknown jr subcommand — fail-closed (SEC-002): deny rather than allow to prevent
# new write subcommands added in future jr releases from bypassing this gate.
emit_deny "Unrecognized jr subcommand. Add to the read-only allowlist in require-review.sh if this is a safe read-only operation."

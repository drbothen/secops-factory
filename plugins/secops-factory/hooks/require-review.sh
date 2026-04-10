#!/usr/bin/env bash
# require-review.sh — PreToolUse hook that blocks JIRA field updates
# via jr CLI without review approval.
#
# Matches Bash tool calls. Only intervenes when the command contains
# `jr issue edit` or `jr issue move` (field-modifying operations).
# Allows `jr issue view`, `jr issue comment`, and all non-jr commands.
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

# Allow jr issue comment (posting enrichment/review results)
if [[ "$COMMAND" == *"jr issue comment"* ]]; then
  emit_allow
fi

# Block field-modifying operations without review approval
if [[ "$COMMAND" == *"jr issue edit"* ]] || \
   [[ "$COMMAND" == *"jr issue move"* ]] || \
   [[ "$COMMAND" == *"jr issue assign"* ]] || \
   [[ "$COMMAND" == *"jr issue create"* ]]; then
  emit_deny "JIRA field modifications require review approval. Run /review-enrichment or /adversarial-review-secops first to validate analysis quality. The jr issue edit/move/assign/create commands are blocked until review passes quality thresholds."
fi

# Unknown jr command — allow (fail-open for unrecognized subcommands)
emit_allow

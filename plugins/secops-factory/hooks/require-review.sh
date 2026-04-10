#!/usr/bin/env bash
# require-review.sh — PreToolUse hook that blocks JIRA field updates
# without review approval.
#
# The update-jira skill requires review approval before modifying tickets.
# This hook enforces that gate by checking for a review_approved flag in
# the tool input metadata.
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

# Extract fields from tool input
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // {}')
HAS_FIELDS=$(echo "$TOOL_INPUT" | jq -r 'if (.fields // {} | length) > 0 then "true" else "false" end')

# Comment-only operations (no field updates) are allowed without review
if [ "$HAS_FIELDS" = "false" ]; then
  emit_allow
fi

# For field updates, check for review approval marker in metadata
HAS_REVIEW=$(echo "$TOOL_INPUT" | jq -r '.metadata.review_approved // false')

if [ "$HAS_REVIEW" = "true" ]; then
  emit_allow
fi

emit_deny "JIRA field updates require review approval. Run /review-enrichment or /adversarial-review-secops first to validate analysis quality before updating ticket fields. The review-enrichment skill sets a review_approved marker in metadata when quality thresholds are met."

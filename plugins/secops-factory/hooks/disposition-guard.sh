#!/usr/bin/env bash
# disposition-guard.sh — PreToolUse hook that blocks writing an event
# investigation disposition without the "Alternatives Considered" section.
#
# This is the secops equivalent of vsdd-factory's protect-vp hook.
# A disposition without documented alternatives is vulnerable to
# confirmation bias — the analyst may have locked on the first hypothesis
# without genuinely considering other explanations.
#
# Emits a PreToolUse JSON envelope with permissionDecision.
# Deterministic, <100ms, no LLM.

set -euo pipefail

if ! command -v jq &>/dev/null; then
  echo "disposition-guard.sh: jq is required but not found" >&2
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

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty')

# Fast path: not an investigation file
if [[ "$FILE_PATH" != *"investigation"* ]]; then
  emit_allow
fi

# Check if the document contains a disposition
if ! echo "$CONTENT" | grep -qiF "Disposition"; then
  # No disposition section — this is an in-progress write, allow it
  emit_allow
fi

# Has a disposition — verify alternatives were considered
if ! echo "$CONTENT" | grep -qiF "Alternatives Considered"; then
  emit_deny "Investigation document contains a disposition but no 'Alternatives Considered' section. Before finalizing a disposition (TP/FP/BTP), you must document at least 2 alternative hypotheses with supporting and contradicting evidence for each. This prevents confirmation bias. See the investigate-event skill, Stage 4: Hypothesis Formation."
fi

emit_allow

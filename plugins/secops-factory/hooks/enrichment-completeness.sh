#!/usr/bin/env bash
# enrichment-completeness.sh — PreToolUse hook that blocks saving partial
# enrichment or investigation documents.
#
# When writing enrichment/investigation documents, verifies that all
# required sections are present before allowing the save.
#
# Emits a PreToolUse JSON envelope with permissionDecision.
# Deterministic, <100ms, no LLM.

set -euo pipefail

if ! command -v jq &>/dev/null; then
  echo "enrichment-completeness.sh: jq is required but not found" >&2
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

# Extract file path and content from tool input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty')

# Fast path: not an enrichment/investigation file
if [[ "$FILE_PATH" != *"enrichment"* ]] && [[ "$FILE_PATH" != *"investigation"* ]]; then
  emit_allow
fi

# Check required sections for enrichment documents
if [[ "$FILE_PATH" == *"enrichment"* ]]; then
  MISSING=""
  for section in "Executive Summary" "Vulnerability Details" "Severity Metrics" "Priority Assessment" "Remediation Guidance"; do
    if ! echo "$CONTENT" | grep -qF "$section"; then
      MISSING="${MISSING}${section}, "
    fi
  done

  if [ -n "$MISSING" ]; then
    MISSING="${MISSING%, }"
    emit_deny "Incomplete enrichment document. Missing required sections: ${MISSING}. Complete all 8 enrichment stages before saving. See /enrich-ticket for the full pipeline."
  fi
fi

# Check required sections for investigation documents
if [[ "$FILE_PATH" == *"investigation"* ]]; then
  MISSING=""
  for section in "Executive Summary" "Alert Details" "Disposition" "Next Actions"; do
    if ! echo "$CONTENT" | grep -qF "$section"; then
      MISSING="${MISSING}${section}, "
    fi
  done

  if [ -n "$MISSING" ]; then
    MISSING="${MISSING%, }"
    emit_deny "Incomplete investigation document. Missing required sections: ${MISSING}. Complete all 7 investigation stages before saving. See /investigate-event for the full pipeline."
  fi
fi

emit_allow

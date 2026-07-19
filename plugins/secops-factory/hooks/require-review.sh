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

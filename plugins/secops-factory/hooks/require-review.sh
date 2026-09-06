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
# Phase 2 iterative marker-consume algorithm with STEP 6 exact-type matching
# per BC-3.01.001 v1.25 D-DEC-001 v2.0.
#
# Algorithm:
#   STEP 1  Check CLAUDE_PLUGIN_DATA is set and markers directory exists.
#   STEP 2  Determine command type: "link" for jr issue link, "close" for jr issue move.
#   STEP 3  Iterate over *.marker.json files in the markers directory.
#   STEP 4  For each candidate: parse JSON, check TTL (expires_at_utc > now).
#   STEP 5  Anchored command_pattern check: command must match marker's regex.
#   STEP 6  Exact-type matching: link cmd → only ["link"] markers (D-020/AC-005);
#           close cmd → only ["close"] markers (D-021/AC-006).
#           CLOSE_STATE_ALLOWLIST binding is enforced in the marker's command_pattern
#           by the emitter (disposition-guard); STEP 5 naturally denies non-allowlisted
#           states (SM-63 kill / AC-010).
#   STEP 7  Atomic POSIX rename (mv) to consume the marker (single-use, D-DEC-001).
#   STEP 8  Append MARKER_USED entry to audit.log (Invariant #2).
#
# Returns: 0 = valid marker found and consumed; 1 = deny (no valid marker)
_validate_marker_for_command() {
  local cmd="$1"
  local plugin_data="${CLAUDE_PLUGIN_DATA:-}"
  [[ -n "$plugin_data" ]] || return 1
  local marker_dir="${plugin_data}/markers"
  [[ -d "$marker_dir" ]] || return 1

  # STEP 2: determine command type for STEP 6 exact-type matching (D-020/D-021)
  local cmd_type=""
  if [[ "$cmd" == *"jr issue link "* ]] || [[ "$cmd" == *"--output json issue link "* ]]; then
    cmd_type="link"
  elif [[ "$cmd" == *"jr issue move"* ]] || [[ "$cmd" == *"--output json issue move"* ]]; then
    cmd_type="close"
  fi

  # STEP 3: iterate candidate marker files
  local marker_file
  for marker_file in "${marker_dir}"/*.marker.json; do
    # Skip glob no-match expansion when no .marker.json files exist
    [[ -f "$marker_file" ]] || continue
    # Path safety: marker must reside directly inside marker_dir (no traversal)
    [[ "$marker_file" == "${marker_dir}/"* ]] || continue

    # STEP 4a: parse JSON into compact form for reliable string operations
    local marker_json
    marker_json=$(jq -c . "$marker_file" 2>/dev/null) || continue
    [[ -n "$marker_json" ]] || continue

    # STEP 4b: TTL check — expires_at_utc must be in the future (EC-017)
    local expires_at
    expires_at=$(printf '%s' "$marker_json" | jq -r '.expires_at_utc // empty' 2>/dev/null) || continue
    [[ -n "$expires_at" ]] || continue
    local now_ts
    now_ts=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    [[ "$expires_at" > "$now_ts" ]] || continue

    # STEP 5: anchored command_pattern match
    local command_pattern
    command_pattern=$(printf '%s' "$marker_json" | jq -r '.command_pattern // empty' 2>/dev/null) || continue
    [[ -n "$command_pattern" ]] || continue
    [[ "$cmd" =~ $command_pattern ]] || continue

    # STEP 6: exact-type matching for link/close anti-fungibility (D-020/D-021)
    if [[ -n "$cmd_type" ]]; then
      local ops_count op_val
      ops_count=$(printf '%s' "$marker_json" | jq -r '.authorized_operations | length' 2>/dev/null) || continue
      op_val=$(printf '%s' "$marker_json" | jq -r '.authorized_operations[0] // empty' 2>/dev/null) || continue
      # Guard: ops_count must be a non-negative integer before arithmetic comparison
      [[ "$ops_count" =~ ^[0-9]+$ ]] || continue
      if [[ "$cmd_type" == "link" ]]; then
        [[ "$ops_count" -eq 1 && "$op_val" == "link" ]] || continue
      elif [[ "$cmd_type" == "close" ]]; then
        [[ "$ops_count" -eq 1 && "$op_val" == "close" ]] || continue
      fi
    fi

    # STEP 7: atomic POSIX rename — single-use consume (D-DEC-001)
    local consumed
    consumed="${marker_file%.marker.json}.marker.used"
    mv "$marker_file" "$consumed" 2>/dev/null || continue

    # STEP 8: audit log (Invariant #2)
    local marker_id
    marker_id=$(printf '%s' "$marker_json" | jq -r '.marker_id // "unknown"' 2>/dev/null) || marker_id="unknown"
    printf '%s MARKER_USED marker_id=%s\n' \
      "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$marker_id" \
      >> "${marker_dir}/audit.log" 2>/dev/null || true

    return 0
  done

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
# Write-block entry count: 12 (10 base + 2 D-020 link entries added at v1.23).
# Plain forms (a) and --output json forms (b) are listed separately because
# "jr issue link" is not a substring of "jr --output json issue link".
if [[ "$COMMAND" == *"jr issue comment "* ]] || \
   [[ "$COMMAND" == *"jr issue edit"* ]] || \
   [[ "$COMMAND" == *"jr issue move"* ]] || \
   [[ "$COMMAND" == *"jr issue assign"* ]] || \
   [[ "$COMMAND" == *"jr issue create"* ]] || \
   [[ "$COMMAND" == *"jr issue link "* ]] || \
   [[ "$COMMAND" == *"--output json issue comment "* ]] || \
   [[ "$COMMAND" == *"--output json issue edit"* ]] || \
   [[ "$COMMAND" == *"--output json issue move"* ]] || \
   [[ "$COMMAND" == *"--output json issue assign"* ]] || \
   [[ "$COMMAND" == *"--output json issue create"* ]] || \
   [[ "$COMMAND" == *"--output json issue link "* ]]; then
  # D-DEC-001 v2.0: attempt marker-consume with STEP 6 exact-type matching.
  # _validate_marker_for_command returns 0 (allow+consume) or 1 (deny).
  if _validate_marker_for_command "$COMMAND"; then
    emit_allow
  fi
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

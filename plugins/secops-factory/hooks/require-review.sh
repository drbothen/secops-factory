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

# _structural_label_check CMD — return 0 if CMD carries --label REVIEW-REQUIRED
# or --label BLIND-SPOT as STANDALONE tokens (i.e. the actual --label argument,
# not text embedded inside another argument such as --summary).
#
# Implements BC-3.01.001 PC#2 step (6a) structural_label_check v2:
#   P9-001: backslash-escape-aware (index-based, handles \" in double-quotes)
#   P8-002: quote-aware state machine (UNQUOTED / IN_SINGLE / IN_DOUBLE)
#   P7-005: token-position check, not raw substring matching
#
# EC-024 false-deny prevention: "--label REVIEW-REQUIRED" appearing only inside
# a quoted --summary value is NOT a standalone token → returns 1 (allow) ✓
# SM-40 (double-space), SM-42 (single/double-quoted value), SM-43 (tab):
# all correctly tokenize to standalone --label + value tokens → returns 0 (deny) ✓
#
# Uses i=$(( i + 1 )) instead of (( i++ )) throughout to avoid set -e exit when
# the arithmetic expression evaluates to 0.
_structural_label_check() {
  local cmd="$1"
  local state="UNQUOTED"
  local cur_token=""
  local -a tokens=()
  local i=0 char next_char
  local len="${#cmd}"

  while [[ $i -lt $len ]]; do
    char="${cmd:$i:1}"
    case "$state" in
      UNQUOTED)
        if [[ "$char" == $'\\' ]] && [[ $(( i + 1 )) -lt $len ]]; then
          # Backslash in UNQUOTED: next char is literal, no state toggle (P9-001).
          # Fixes \' entering IN_SINGLE incorrectly.
          i=$(( i + 1 ))
          cur_token+="${cmd:$i:1}"
        elif [[ "$char" == "'" ]]; then
          state="IN_SINGLE"
        elif [[ "$char" == '"' ]]; then
          state="IN_DOUBLE"
        elif [[ "$char" == " " || "$char" == $'\t' ]]; then
          if [[ -n "$cur_token" ]]; then
            tokens+=("$cur_token")
            cur_token=""
          fi
        else
          cur_token+="$char"
        fi
        ;;
      IN_SINGLE)
        # No escaping inside single-quotes (bash parity); backslash is literal.
        if [[ "$char" == "'" ]]; then
          state="UNQUOTED"
        else
          cur_token+="$char"
        fi
        ;;
      IN_DOUBLE)
        if [[ "$char" == $'\\' ]] && [[ $(( i + 1 )) -lt $len ]]; then
          # Backslash in IN_DOUBLE: only \" and \\ are special (P9-001).
          next_char="${cmd:$(( i + 1 )):1}"
          if [[ "$next_char" == '"' ]]; then
            # \" → literal ", STAY IN_DOUBLE (fixes premature exit on escaped quote).
            cur_token+='"'
            i=$(( i + 1 ))
          elif [[ "$next_char" == $'\\' ]]; then
            # \\ → literal \, STAY IN_DOUBLE.
            cur_token+=$'\\'
            i=$(( i + 1 ))
          else
            # Other \X → backslash is literal; next char processed next iteration.
            cur_token+="$char"
          fi
        elif [[ "$char" == '"' ]]; then
          state="UNQUOTED"
        else
          cur_token+="$char"
        fi
        ;;
    esac
    i=$(( i + 1 ))
  done
  # Flush any remaining token at end of string.
  [[ -n "$cur_token" ]] && tokens+=("$cur_token")

  # Scan tokens for any --label form carrying a hard-floor label value.
  # Handled forms (Finding 2 / SEC-001 fix):
  #   --label REVIEW-REQUIRED / --label BLIND-SPOT    (two-token space-separated form)
  #   --label=REVIEW-REQUIRED                         (equals form, one token)
  #   -l REVIEW-REQUIRED                              (short flag, two tokens)
  #   -lREVIEW-REQUIRED                               (short flag, no space)
  #   --label REVIEW-REQUIRED,triage                  (comma-joined value)
  local j=0 ntokens="${#tokens[@]}"
  while [[ $j -lt $ntokens ]]; do
    local _tok="${tokens[$j]}"
    local _val=""
    if [[ "$_tok" == "--label="* ]]; then
      # Form: --label=VALUE (one token, equals sign)
      _val="${_tok#--label=}"
    elif [[ "${#_tok}" -gt 2 && "${_tok:0:2}" == "-l" ]]; then
      # Form: -lVALUE (short flag, no space, one token)
      _val="${_tok:2}"
    elif [[ "$_tok" == "--label" || "$_tok" == "-l" ]]; then
      # Form: --label VALUE or -l VALUE (two tokens; next token is value)
      if [[ $(( j + 1 )) -lt $ntokens ]]; then
        _val="${tokens[$(( j + 1 ))]}"
      fi
    fi
    if [[ -n "$_val" ]]; then
      local _part
      while IFS= read -r _part; do
        if [[ "$_part" == "REVIEW-REQUIRED" || "$_part" == "BLIND-SPOT" ]]; then
          return 0
        fi
      done < <(printf '%s\n' "$_val" | tr ',' '\n')
    fi
    j=$(( j + 1 ))
  done
  return 1
}

# _is_iso8601_utc TS — return 0 if TS is a well-formed ISO-8601 UTC timestamp
# (YYYY-MM-DDTHH:MM:SSZ) with in-range field values; return 1 otherwise.
# Used before lexicographic comparisons to fail-closed on malformed values
# (BC-3.01.001 PC#2 step 4b — F5 fix: malformed timestamps → skip marker → deny).
_is_iso8601_utc() {
  local ts="$1"
  [[ "$ts" =~ ^[0-9]{4}-[01][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-5][0-9]Z$ ]]
}

# _validate_marker_for_command COMMAND
#
# Phase 2 iterative marker-consume algorithm with STEP 6 exact-type matching
# per BC-3.01.001 v1.25 D-DEC-001 v2.0.
#
# Algorithm:
#   STEP 1  Check CLAUDE_PLUGIN_DATA is set and markers directory exists.
#   STEP 2  Determine command type: "link" / "close" / "create" for relevant subcommands.
#   I1      Consumer-side shell metachar guard: reject commands containing
#           ; | & ` $( before any marker processing (BC-3.01.001 PC#2 step 5).
#   I4      STEP 3 Phase 1: collect valid candidates with issued_at_utc for FIFO ordering.
#   I2      BC step (3): skip markers whose issued_at_utc is in the future (adversarial signal).
#   O1      STEP 4b: TTL — valid when expires_at_utc >= now (equality = still valid).
#           STEP 5  Anchored command_pattern check.
#   STEP 6  Exact-type matching: link → ["link"], close → ["close"] (D-020/D-021/AC-005/AC-006).
#           Close-state binding (Done/Closed/Resolved) enforced in the marker's command_pattern by the emitter.
#   C1      STEP 6a: create anti-fungibility — ["create"] marker must not authorize
#           hard-floor-labeled create (REVIEW-REQUIRED, BLIND-SPOT). EC-023 direction B / SM-37.
#   I4      STEP 3 Phase 2: sort candidates by issued_at_utc ascending, attempt atomic rename.
#   STEP 7  Atomic POSIX rename (mv) to consume the marker (single-use, D-DEC-001).
#   I3      STEP 8: complete audit log — op=, ticket=, org=, command_b64=; all attacker-
#           influenceable fields sanitized (strip 0x00-0x1f) to prevent log injection.
#
# Returns: 0 = valid marker found and consumed; 1 = deny (no valid marker)
_validate_marker_for_command() {
  local cmd="$1"
  local plugin_data="${CLAUDE_PLUGIN_DATA:-}"
  [[ -n "$plugin_data" ]] || return 1
  local marker_dir="${plugin_data}/markers"
  [[ -d "$marker_dir" ]] || return 1

  # I1: consumer-side shell metachar guard (BC-3.01.001 PC#2 step 5)
  # Reject any command that contains shell metacharacters — prevents tail injection.
  # Emitter-side tail-anchoring deferred to S-3.02 (VP-HOOK-024).
  # _subshell stores the two-character literal "$(" so the glob test is shellcheck-clean.
  # Assembled from two innocuous pieces to avoid SC2016 false-positive on literal '$(').
  # F2 (MAJOR): added > < \n — covers shell redirection (> /path, < /path) and process
  # substitution (>(cmd), <(cmd)), plus newline injection (BC-3.01.001 PC#2 step 5).
  local _subshell
  _subshell="$"'('
  if [[ "$cmd" == *';'* ]] || [[ "$cmd" == *'|'* ]] || \
     [[ "$cmd" == *'&'* ]] || [[ "$cmd" == *'`'* ]] || \
     [[ "$cmd" == *"${_subshell}"* ]] || \
     [[ "$cmd" == *'>'* ]] || [[ "$cmd" == *'<'* ]] || \
     [[ "$cmd" == *$'\n'* ]]; then
    return 1
  fi

  # STEP 2: determine command type for STEP 6 exact-type matching (D-020/D-021/C1)
  local cmd_type=""
  if [[ "$cmd" == *"jr issue link "* ]] || [[ "$cmd" == *"--output json issue link "* ]]; then
    cmd_type="link"
  elif [[ "$cmd" == *"jr issue move"* ]] || [[ "$cmd" == *"--output json issue move"* ]]; then
    cmd_type="close"
  elif [[ "$cmd" == *"jr issue create"* ]] || [[ "$cmd" == *"--output json issue create"* ]]; then
    cmd_type="create"
  elif [[ "$cmd" == *"jr issue update"* ]] || [[ "$cmd" == *"--output json issue update"* ]]; then
    cmd_type="update"
  elif [[ "$cmd" == *"jr issue comment "* ]] || [[ "$cmd" == *"--output json issue comment "* ]]; then
    cmd_type="comment"
  elif [[ "$cmd" == *"jr issue assign"* ]] || [[ "$cmd" == *"--output json issue assign"* ]]; then
    cmd_type="assign"
  elif [[ "$cmd" == *"jr issue label"* ]] || [[ "$cmd" == *"--output json issue label"* ]]; then
    cmd_type="label"
  elif [[ "$cmd" == *"jr issue delete"* ]] || [[ "$cmd" == *"--output json issue delete"* ]]; then
    cmd_type="delete"
  fi

  local now_ts
  now_ts=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

  # I4 Phase 1: collect valid candidates for FIFO ordering.
  # Each entry: "issued_at_utc|marker_file_path" (ISO-8601 sorts lexicographically = chronologically).
  local -a _candidates=()
  local _mf _mj _issued_at _expires_at _cmd_pattern _ops_count _op_val

  for _mf in "${marker_dir}"/*.marker.json; do
    # Skip glob no-match expansion when no .marker.json files exist
    [[ -f "$_mf" ]] || continue
    # Path safety: marker must reside directly inside marker_dir (no traversal)
    [[ "$_mf" == "${marker_dir}/"* ]] || continue

    # STEP 4a: parse JSON into compact form for reliable string operations
    _mj=$(jq -c . "$_mf" 2>/dev/null) || continue
    [[ -n "$_mj" ]] || continue

    # I2: BC step (3) — skip future-dated markers (adversarial signal)
    _issued_at=$(printf '%s' "$_mj" | jq -r '.issued_at_utc // empty' 2>/dev/null) || continue
    [[ -n "$_issued_at" ]] || continue
    # F5: validate format before lexicographic comparison (malformed → skip → fail-closed)
    _is_iso8601_utc "$_issued_at" || continue
    # If issued_at_utc > now → adversarial signal → skip this marker
    [[ "$_issued_at" > "$now_ts" ]] && continue

    # STEP 4b: TTL check — O1: valid when expires_at_utc >= now (equality = still valid)
    _expires_at=$(printf '%s' "$_mj" | jq -r '.expires_at_utc // empty' 2>/dev/null) || continue
    [[ -n "$_expires_at" ]] || continue
    # F5: validate format before lexicographic comparison (malformed → skip → fail-closed)
    _is_iso8601_utc "$_expires_at" || continue
    # Reject only when expires_at_utc < now (equal second is still valid per BC step 4)
    [[ "$_expires_at" > "$now_ts" ]] || [[ "$_expires_at" == "$now_ts" ]] || continue

    # STEP 5: anchored command_pattern match
    _cmd_pattern=$(printf '%s' "$_mj" | jq -r '.command_pattern // empty' 2>/dev/null) || continue
    [[ -n "$_cmd_pattern" ]] || continue
    [[ "$cmd" =~ $_cmd_pattern ]] || continue

    # STEP 6: exact-type matching for link/close/create anti-fungibility (D-020/D-021)
    _ops_count=$(printf '%s' "$_mj" | jq -r '.authorized_operations | length' 2>/dev/null) || continue
    _op_val=$(printf '%s' "$_mj" | jq -r '.authorized_operations[0] // empty' 2>/dev/null) || continue
    # Guard: ops_count must be a non-negative integer before arithmetic comparison
    [[ "$_ops_count" =~ ^[0-9]+$ ]] || continue

    if [[ "$cmd_type" == "link" ]]; then
      [[ "$_ops_count" -eq 1 && "$_op_val" == "link" ]] || continue
    elif [[ "$cmd_type" == "close" ]]; then
      [[ "$_ops_count" -eq 1 && "$_op_val" == "close" ]] || continue
    elif [[ "$cmd_type" == "create" ]]; then
      # Only ["create"] or ["create-review"] markers may authorize create commands
      [[ "$_ops_count" -eq 1 ]] || continue
      [[ "$_op_val" == "create" || "$_op_val" == "create-review" ]] || continue
    elif [[ -n "$cmd_type" ]]; then
      # All other write ops: require exact single-entry authorized_operations matching cmd_type
      [[ "$_ops_count" -eq 1 && "$_op_val" == "$cmd_type" ]] || continue
    else
      # cmd_type is empty — unknown write op → fail-closed (SEC-001)
      continue
    fi

    # STEP 6a: C1 create anti-fungibility — regular ["create"] marker must NOT authorize
    # a create command carrying a hard-floor review label.
    # Hard-floor labels: REVIEW-REQUIRED, BLIND-SPOT (EC-023 direction B / SM-37).
    # A ["create-review"] marker is required for those tickets.
    # F1 (CRITICAL): replaced naive raw-substring match with _structural_label_check —
    # a quote-aware (single + double), backslash-escape-aware, whitespace-collapsing
    # tokenizer. Fixes SM-40 (double-space), SM-42 (quoted value), SM-43 (tab).
    # EC-024 false-deny fix: the same tokenizer does NOT fire when --label text appears
    # only inside a quoted --summary value (not a standalone token). (P9-001/P8-002/P7-005)
    if [[ "$_op_val" == "create" ]]; then
      if _structural_label_check "$cmd"; then
        continue
      fi
    fi

    # Valid candidate — record for FIFO sorting
    _candidates+=("${_issued_at}|${_mf}")
  done

  # No valid candidates found → deny
  [[ ${#_candidates[@]} -gt 0 ]] || return 1

  # I4 Phase 2: sort candidates by issued_at_utc ascending (FIFO), attempt atomic consume.
  # ISO-8601 lexicographic order equals chronological order.
  local _sorted_cand _sorted_mf _consumed
  local _raw_marker_id _raw_ticket _raw_org _raw_op _audit_mj
  local _safe_marker_id _safe_ticket _safe_org _safe_op _command_b64

  while IFS= read -r _sorted_cand; do
    # Extract file path — everything after the first '|'
    _sorted_mf="${_sorted_cand#*|}"
    [[ -f "$_sorted_mf" ]] || continue

    # STEP 7: atomic POSIX rename — single-use consume (D-DEC-001)
    _consumed="${_sorted_mf%.marker.json}.marker.used"
    mv "$_sorted_mf" "$_consumed" 2>/dev/null || continue

    # STEP 8: complete audit log — I3 / Invariant #2 / VP-HOOK-024 / ADV-F2-013
    _audit_mj=$(jq -c . "$_consumed" 2>/dev/null) || _audit_mj=""
    if [[ -n "$_audit_mj" ]]; then
      _raw_marker_id=$(printf '%s' "$_audit_mj" | jq -r '.marker_id // "unknown"' 2>/dev/null) \
        || _raw_marker_id="unknown"
      _raw_ticket=$(printf '%s' "$_audit_mj" | jq -r '.ticket_id // ""' 2>/dev/null) \
        || _raw_ticket=""
      _raw_org=$(printf '%s' "$_audit_mj" | jq -r '.org_slug // ""' 2>/dev/null) \
        || _raw_org=""
      _raw_op=$(printf '%s' "$_audit_mj" | jq -r '.authorized_operations[0] // ""' 2>/dev/null) \
        || _raw_op=""
    else
      _raw_marker_id="unknown"; _raw_ticket=""; _raw_org=""; _raw_op=""
    fi

    # Sanitize: strip control chars (0x00-0x1f) from all attacker-influenceable fields
    # to prevent audit log injection (newline injection → forged MARKER_USED line).
    _safe_marker_id=$(printf '%s' "$_raw_marker_id" | tr -d '\000-\037')
    _safe_ticket=$(printf '%s' "$_raw_ticket" | tr -d '\000-\037')
    _safe_org=$(printf '%s' "$_raw_org" | tr -d '\000-\037')
    _safe_op=$(printf '%s' "$_raw_op" | tr -d '\000-\037')
    # base64-encode command for audit completeness; strip wrapping newlines (cross-platform)
    _command_b64=$(printf '%s' "$cmd" | base64 | tr -d '\n')

    # F4: fail-closed on audit-write failure — no allow without audit record
    # (BC-3.01.001 PC#2 step 8 + Invariant #2 / VP-HOOK-024).
    printf '%s MARKER_USED marker_id=%s op=%s ticket=%s org=%s command_b64=%s\n' \
      "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
      "$_safe_marker_id" "$_safe_op" "$_safe_ticket" "$_safe_org" "$_command_b64" \
      >> "${marker_dir}/audit.log" 2>/dev/null || return 1

    return 0
  done < <(printf '%s\n' "${_candidates[@]}" | sort)

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
  emit_deny "JIRA write operations require review approval. Run /review-enrichment or /adversarial-review-secops first to validate analysis quality. The jr issue link/comment/edit/move/assign/create commands are blocked until review passes quality thresholds."
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

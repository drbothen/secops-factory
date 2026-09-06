#!/usr/bin/env bats
# require-review-pass1-findings.bats
#
# BC-3.01.001 v1.25 — Pass-1 adversarial findings (S-3.01)
#
# Covers:
#   F1 (CRITICAL)  BC-3.01.001 PC#2 step (6a) structural_label_check bypass.
#                  EC-024/EC-025 canonical vectors. SM-40 (raw substring),
#                  SM-42 (non-quote-aware split), SM-43 (backslash-aware).
#                  Current implementation uses raw glob substring matching:
#                    [[ "$cmd" == *"--label REVIEW-REQUIRED"* ]]
#                  This is bypassed by whitespace variants (double-space, tab)
#                  and quoting variants (double-quote, single-quote).
#                  The same substring match also fires on summary TEXT that
#                  mentions the label string → false-deny (EC-024).
#
#   F2 (MAJOR)     BC-3.01.001 PC#2 step (5) metachar guard completeness.
#                  Current guard: ; | & ` $( — missing > < \n.
#                  Process substitution >(cmd) and <(cmd), shell redirection
#                  > /path and < /path, and space-then-newline all bypass the
#                  guard and satisfy the ( |$) boundary in the command_pattern →
#                  ALLOW (injection vector).
#
#   F4 (MEDIUM)    BC-3.01.001 PC#2 step (8) + Invariant #2: audit-write failure
#                  must fail closed (no allow-without-audit).
#                  Current: "|| true" swallows the write failure; return 0
#                  (allow) is reached unconditionally → ALLOW without record.
#
#   F5 (MEDIUM)    BC-3.01.001 PC#2 step (4b) lexicographic TTL safety.
#                  Malformed non-ISO-8601 expires_at_utc (e.g.
#                  "9999-99-99T99:99:99Z", "zzz") compares lexicographically
#                  greater than any real timestamp → passes TTL check → ALLOW.
#                  Fail-closed requires format validation before comparison.
#
#   F7 (OBS)       BC-3.01.001 write-block entry count = 12 (10 base + 2
#                  D-020 link entries). Regression guard: the current
#                  link-close suite asserts only >= 2 link entries.
#
# Red Gate target: F1 (×6), F2 (×5), F4 (×1), F5 (×2) = 14 tests FAIL
# against HEAD 2c81d1f (current require-review.sh).
# F7 (×1) is GREEN — the code already has 12 entries; this is a regression guard.
# Existing tests in require-review-security-gaps.bats and
# require-review-link-close.bats remain green.
#
# Test naming: test_BC_S_SS_NNN_<finding>_<assertion>

PLUGIN_ROOT="${BATS_TEST_DIRNAME}/../.."

# ── helpers ─────────────────────────────────────────────────────────────────

setup() {
  TEST_TMP=$(mktemp -d)
  MARKER_DIR="${TEST_TMP}/markers"
  mkdir -p "${MARKER_DIR}"
  export CLAUDE_PLUGIN_DATA="${TEST_TMP}"
}

teardown() {
  # Restore any chmod-000 files before removal so rm -rf can unlink them
  chmod -R u+rw "${TEST_TMP}" 2>/dev/null || true
  rm -rf "${TEST_TMP}"
}

# _run_hook CMD — pipe CMD as a PreToolUse/Bash JSON envelope to require-review.sh.
# Uses jq -R . to properly JSON-encode CMD (handles embedded quotes, $, etc.).
_run_hook() {
  local cmd="$1"
  local json
  json=$(printf '{"tool_input":{"command":%s}}' "$(printf '%s' "${cmd}" | jq -R .)")
  run bash -c 'printf "%s" "$1" | CLAUDE_PLUGIN_DATA="$2" "$3/hooks/require-review.sh"' \
      -- "${json}" "${CLAUDE_PLUGIN_DATA}" "${PLUGIN_ROOT}"
}

# _run_hook_raw JSON — pass a pre-built JSON string directly (used for commands
# that contain characters jq -R . cannot handle without splitting, e.g. literal
# newlines embedded as JSON \n escapes).
_run_hook_raw() {
  local json="$1"
  run bash -c 'printf "%s" "$1" | CLAUDE_PLUGIN_DATA="$2" "$3/hooks/require-review.sh"' \
      -- "${json}" "${CLAUDE_PLUGIN_DATA}" "${PLUGIN_ROOT}"
}

# _write_marker FILENAME JSON — write a marker file into the test marker dir.
_write_marker() {
  local filename="$1"
  local content="$2"
  printf "%s" "${content}" > "${MARKER_DIR}/${filename}"
}

# _future_ts — ISO-8601 UTC timestamp 300 s in the future (well within any TTL).
_future_ts() {
  if date --version 2>/dev/null | grep -q GNU; then
    date -u -d '+300 seconds' '+%Y-%m-%dT%H:%M:%SZ'
  else
    date -u -v+300S '+%Y-%m-%dT%H:%M:%SZ'
  fi
}

# _now_ts — current UTC timestamp.
_now_ts() {
  date -u '+%Y-%m-%dT%H:%M:%SZ'
}

# ── F1 (CRITICAL): structural_label_check bypass ───────────────────────────
#
# BC-3.01.001 PC#2 step (6a): a regular ["create"] marker MUST NOT authorize a
# create command that carries a hard-floor review label (REVIEW-REQUIRED or
# BLIND-SPOT). The implementation must use a quote-aware, whitespace-collapsing
# tokenizer (structural_label_check), not raw substring matching.
#
# Current code (step 6a):
#   if [[ "$cmd" == *"--label REVIEW-REQUIRED"* ]] || \
#      [[ "$cmd" == *"--label BLIND-SPOT"* ]]; then
#     continue
#   fi
#
# This raw glob match is bypassed by:
#   SM-40: double-space between --label and the value ("--label  REVIEW-REQUIRED")
#   SM-42: quoted value      ("--label \"REVIEW-REQUIRED\"" / "--label 'REVIEW-REQUIRED'")
#   SM-43: tab between token ("--label\tREVIEW-REQUIRED")
#
# EC-024: the same substring check fires when the label string appears only in
# the --summary text value (no actual --label flag) → false-deny (wrong DENY).

@test "test_BC_3_01_001_F1_SM40_double_space_review_required_bypasses_label_check" {
  # F1 CRITICAL / SM-40 / BC-3.01.001 PC#2 step (6a) / EC-024
  # ["create"] marker + "--label  REVIEW-REQUIRED" (double space) → must DENY.
  # Current: raw substring *"--label REVIEW-REQUIRED"* (single space) does not match
  # double-space variant → step 6a does not skip → marker consumed → ALLOW (BUG) → RED.
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "create-f1-dsp.marker.json" \
    '{"marker_id":"m-f1-dsp","ticket_id":null,"org_slug":"test","authorized_operations":["create"],"command_pattern":"^jr (--output json )?issue create --project PRISMDEMO( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue create --project PRISMDEMO --label  REVIEW-REQUIRED --summary test"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  [[ "$output" == *"review approval"* ]]
}

@test "test_BC_3_01_001_F1_SM42_double_quoted_review_required_bypasses_label_check" {
  # F1 CRITICAL / SM-42 / BC-3.01.001 PC#2 step (6a)
  # ["create"] marker + '--label "REVIEW-REQUIRED"' (double-quoted value) → must DENY.
  # Current: raw substring *"--label REVIEW-REQUIRED"* does not match the double-quoted
  # form (extra " characters around value) → step 6a skip missed → ALLOW (BUG) → RED.
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "create-f1-dq.marker.json" \
    '{"marker_id":"m-f1-dq","ticket_id":null,"org_slug":"test","authorized_operations":["create"],"command_pattern":"^jr (--output json )?issue create --project PRISMDEMO( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  # Outer single-quotes; embedded double-quotes are literal characters passed to jq.
  _run_hook 'jr issue create --project PRISMDEMO --label "REVIEW-REQUIRED" --summary test'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  [[ "$output" == *"review approval"* ]]
}

@test "test_BC_3_01_001_F1_SM42_single_quoted_review_required_bypasses_label_check" {
  # F1 CRITICAL / SM-42 / BC-3.01.001 PC#2 step (6a)
  # ["create"] marker + "--label 'REVIEW-REQUIRED'" (single-quoted value) → must DENY.
  # Current: raw substring *"--label REVIEW-REQUIRED"* does not match single-quoted
  # form → step 6a skip missed → ALLOW (BUG) → RED.
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "create-f1-sq.marker.json" \
    '{"marker_id":"m-f1-sq","ticket_id":null,"org_slug":"test","authorized_operations":["create"],"command_pattern":"^jr (--output json )?issue create --project PRISMDEMO( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  # Outer double-quotes; inner single-quotes are literal characters passed to jq.
  _run_hook "jr issue create --project PRISMDEMO --label 'REVIEW-REQUIRED' --summary test"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  [[ "$output" == *"review approval"* ]]
}

@test "test_BC_3_01_001_F1_SM43_tab_separated_review_required_bypasses_label_check" {
  # F1 CRITICAL / SM-43 / BC-3.01.001 PC#2 step (6a) / EC-025
  # ["create"] marker + "--label<TAB>REVIEW-REQUIRED" (tab separator) → must DENY.
  # Current: raw substring *"--label REVIEW-REQUIRED"* requires space, not tab →
  # tab variant bypasses check → ALLOW (BUG) → RED.
  local now future cmd_with_tab
  now=$(_now_ts); future=$(_future_ts)
  cmd_with_tab=$(printf 'jr issue create --project PRISMDEMO --label\tREVIEW-REQUIRED --summary test')
  _write_marker "create-f1-tab.marker.json" \
    '{"marker_id":"m-f1-tab","ticket_id":null,"org_slug":"test","authorized_operations":["create"],"command_pattern":"^jr (--output json )?issue create --project PRISMDEMO( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "${cmd_with_tab}"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  [[ "$output" == *"review approval"* ]]
}

@test "test_BC_3_01_001_F1_SM40_double_space_blind_spot_bypasses_label_check" {
  # F1 CRITICAL / SM-40 (BLIND-SPOT variant) / BC-3.01.001 PC#2 step (6a)
  # ["create"] marker + "--label  BLIND-SPOT" (double space) → must DENY.
  # Current: raw substring *"--label BLIND-SPOT"* (single space) does not match
  # double-space form → step 6a skip missed → ALLOW (BUG) → RED.
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "create-f1-bsdsp.marker.json" \
    '{"marker_id":"m-f1-bsdsp","ticket_id":null,"org_slug":"test","authorized_operations":["create"],"command_pattern":"^jr (--output json )?issue create --project PRISMDEMO( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue create --project PRISMDEMO --label  BLIND-SPOT --summary test"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  [[ "$output" == *"review approval"* ]]
}

@test "test_BC_3_01_001_F1_EC024_summary_text_label_must_not_trigger_false_deny" {
  # F1 CRITICAL / EC-024 (false-deny guard) / BC-3.01.001 PC#2 step (6a)
  # A create command with a valid ["create"] marker whose --summary TEXT mentions
  # the string "--label REVIEW-REQUIRED" (documentation/description) but carries
  # NO actual --label flag → must ALLOW.
  # Current: raw substring *"--label REVIEW-REQUIRED"* matches the substring within
  # the summary text → step 6a wrongly continues (skips marker) → DENY (BUG) → RED.
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "create-f1-ec024.marker.json" \
    '{"marker_id":"m-f1-ec024","ticket_id":null,"org_slug":"test","authorized_operations":["create"],"command_pattern":"^jr (--output json )?issue create --project PRISMDEMO( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  # Summary text MENTIONS the label string; no actual --label flag is present.
  _run_hook 'jr issue create --project PRISMDEMO --summary "use --label REVIEW-REQUIRED for high severity tickets"'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

# ── F2 (MAJOR): metachar guard completeness ────────────────────────────────
#
# BC-3.01.001 PC#2 step (5) scope contract: the consumer-side metachar guard
# must reject commands containing shell injection characters before any marker
# processing.
#
# Current guard (inside _validate_marker_for_command):
#   if [[ "$cmd" == *';'* ]] || [[ "$cmd" == *'|'* ]] || \
#      [[ "$cmd" == *'&'* ]] || [[ "$cmd" == *'`'* ]] || \
#      [[ "$cmd" == *"${_subshell}"* ]]; then
#     return 1
#   fi
#
# Missing guards: > (process substitution >(cmd), redirection > /path) and
# < (process substitution <(cmd), redirection < /path) and \n (newline).
#
# All five test vectors below satisfy the command_pattern ( |$) boundary via
# the space before the injection character, then bypass the current guard →
# marker consumed → ALLOW (injection gap).
#
# Each test uses a fresh ["link"] marker for SEC-200/SEC-201 through
# SEC-240/SEC-241.

@test "test_BC_3_01_001_F2_process_subst_out_link_allowed_bug" {
  # F2 MAJOR / BC-3.01.001 PC#2 step (5) — process substitution >(cmd).
  # ["link"] marker + "jr issue link SEC-200 SEC-201 >(sh -c 'id')" → must DENY.
  # ">" is not in the current metachar guard; space before ">" satisfies ( |$) in
  # command_pattern → STEP 5 matches → marker consumed → ALLOW (BUG) → RED.
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-f2-pso.marker.json" \
    '{"marker_id":"m-f2-pso","ticket_id":"SEC-200","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-200 SEC-201( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  # Outer double-quotes; single quotes inside are literal characters for jq.
  _run_hook "jr issue link SEC-200 SEC-201 >(sh -c 'id')"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "test_BC_3_01_001_F2_process_subst_in_link_allowed_bug" {
  # F2 MAJOR / BC-3.01.001 PC#2 step (5) — process substitution <(cmd).
  # ["link"] marker + "jr issue link SEC-210 SEC-211 <(cat /etc/passwd)" → must DENY.
  # "<" is not in the current metachar guard; space before "<" satisfies ( |$) →
  # STEP 5 matches → marker consumed → ALLOW (BUG) → RED.
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-f2-psi.marker.json" \
    '{"marker_id":"m-f2-psi","ticket_id":"SEC-210","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-210 SEC-211( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue link SEC-210 SEC-211 <(cat /etc/passwd)"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "test_BC_3_01_001_F2_redir_out_link_allowed_bug" {
  # F2 MAJOR / BC-3.01.001 PC#2 step (5) — shell output redirection > /path.
  # ["link"] marker + "jr issue link SEC-220 SEC-221 > /tmp/x" → must DENY.
  # ">" is not in the current metachar guard; space before ">" satisfies ( |$) →
  # STEP 5 matches → marker consumed → ALLOW (BUG) → RED.
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-f2-ro.marker.json" \
    '{"marker_id":"m-f2-ro","ticket_id":"SEC-220","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-220 SEC-221( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue link SEC-220 SEC-221 > /tmp/x"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "test_BC_3_01_001_F2_redir_in_link_allowed_bug" {
  # F2 MAJOR / BC-3.01.001 PC#2 step (5) — shell input redirection < /path.
  # ["link"] marker + "jr issue link SEC-230 SEC-231 < /tmp/x" → must DENY.
  # "<" is not in the current metachar guard; space before "<" satisfies ( |$) →
  # STEP 5 matches → marker consumed → ALLOW (BUG) → RED.
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-f2-ri.marker.json" \
    '{"marker_id":"m-f2-ri","ticket_id":"SEC-230","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-230 SEC-231( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue link SEC-230 SEC-231 < /tmp/x"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "test_BC_3_01_001_F2_newline_injection_space_before_lf_link_allowed_bug" {
  # F2 MAJOR / BC-3.01.001 PC#2 step (5) — space-then-newline injection.
  # ["link"] marker + "jr issue link SEC-240 SEC-241 \nrm -rf /tmp/x" → must DENY.
  # The JSON \n is decoded to a literal LF by jq -r. The space before LF satisfies
  # the ( |$) boundary in the command_pattern (bash =~ is not newline-aware for the
  # ( |$) group). The LF is not in the current metachar guard → STEP 5 matches →
  # marker consumed → ALLOW (BUG) → RED.
  # _run_hook_raw is used because jq -R . reads multi-line input as separate strings;
  # the \n is supplied as a JSON string escape instead.
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-f2-nl.marker.json" \
    '{"marker_id":"m-f2-nl","ticket_id":"SEC-240","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-240 SEC-241( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  # \n in the JSON value is decoded to a literal newline by jq -r in the hook.
  _run_hook_raw '{"tool_input":{"command":"jr issue link SEC-240 SEC-241 \nrm -rf /tmp/x"}}'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

# ── F4 (MEDIUM): audit-write failure must fail closed ──────────────────────
#
# BC-3.01.001 PC#2 step (8) + Invariant #2 (VP-HOOK-024):
#   Every marker consume MUST be accompanied by an audit record. If the write
#   fails the operation must be denied (no allow-without-audit).
#
# Current code (STEP 8):
#   printf '...' >> "${marker_dir}/audit.log" 2>/dev/null || true
#   return 0
#
# The "|| true" swallows a failed write; "return 0" (allow) is reached
# unconditionally regardless of audit status → ALLOW without audit record (BUG).
# A correct implementation would "return 1" (deny) when the audit write fails.

@test "test_BC_3_01_001_F4_audit_write_failure_must_deny_not_allow" {
  # F4 MEDIUM / BC-3.01.001 PC#2 step (8) / Invariant #2 / VP-HOOK-024
  # With audit.log made unwritable (chmod 000), a marker consume that cannot
  # record the audit event must result in DENY (fail-closed).
  # Current: "|| true" swallows the write error; "return 0" is reached → ALLOW
  # without audit (BUG) → RED.
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-f4-audit.marker.json" \
    '{"marker_id":"m-f4-audit","ticket_id":"SEC-300","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-300 SEC-400( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  # Pre-create audit.log then remove all permissions so the append fails.
  # The mv of the marker file operates on the directory (still writable) so it
  # succeeds; only the audit append to audit.log itself is blocked.
  touch "${MARKER_DIR}/audit.log"
  chmod 000 "${MARKER_DIR}/audit.log"
  _run_hook "jr issue link SEC-300 SEC-400"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

# ── F5 (MEDIUM): malformed timestamp fails closed ──────────────────────────
#
# BC-3.01.001 PC#2 step (4b): the TTL check uses lexicographic comparison of
# ISO-8601 strings. ISO-8601 dates sort lexicographically ≡ chronologically
# ONLY when the format is well-formed. A malformed value such as
# "9999-99-99T99:99:99Z" or "zzz" compares lexicographically greater than any
# real timestamp, so it always "passes" the TTL check.
#
# Current code:
#   [[ "$_expires_at" > "$now_ts" ]] || [[ "$_expires_at" == "$now_ts" ]] || continue
#
# "9999-99-99T99:99:99Z" > "2026-..." → TRUE → accepted.
# "zzz"                  > "2026-..." → TRUE ('z' > '2' in ASCII) → accepted.
# A correct implementation would validate the format with a regex before comparing.

@test "test_BC_3_01_001_F5_malformed_expires_impossible_date_fails_closed" {
  # F5 MEDIUM / BC-3.01.001 PC#2 step (4b) / lexicographic TTL safety
  # expires_at_utc = "9999-99-99T99:99:99Z" is syntactically ISO-8601-shaped but
  # month/day/hour/minute/second values are out of range (not a real timestamp).
  # Lexicographically "9999-..." > "2026-..." → current TTL check passes → ALLOW (BUG).
  # A structurally invalid timestamp must be treated as expired (fail-closed) → DENY.
  local now
  now=$(_now_ts)
  _write_marker "link-f5-9999.marker.json" \
    '{"marker_id":"m-f5-9999","ticket_id":"SEC-500","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-500 SEC-600( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"9999-99-99T99:99:99Z"}'
  _run_hook "jr issue link SEC-500 SEC-600"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  [[ "$output" == *"review approval"* ]]
}

@test "test_BC_3_01_001_F5_malformed_expires_non_iso_string_fails_closed" {
  # F5 MEDIUM / BC-3.01.001 PC#2 step (4b) / lexicographic TTL safety
  # expires_at_utc = "zzz" is not ISO-8601. Lexicographically "zzz" > "2026-..."
  # because 'z' (0x7a) > '2' (0x32) in ASCII → current TTL check passes → ALLOW (BUG).
  # A non-ISO value must be treated as expired (fail-closed) → DENY.
  local now
  now=$(_now_ts)
  _write_marker "link-f5-zzz.marker.json" \
    '{"marker_id":"m-f5-zzz","ticket_id":"SEC-501","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-501 SEC-601( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"zzz"}'
  _run_hook "jr issue link SEC-501 SEC-601"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  [[ "$output" == *"review approval"* ]]
}

# ── F7 (OBS): write-block entry count regression guard ─────────────────────
#
# BC-3.01.001 comment: "Write-block entry count: 12 (10 base + 2 D-020 link
# entries added at v1.23)."
# The require-review-link-close.bats suite asserts only >= 2 link entries
# (the two D-020 additions). This test asserts the full 12-entry count to
# catch accidental removal of any write-block guard in future refactors.
#
# GREEN on current code (the code already has exactly 12 entries).
# Becomes RED if any write-block entry is removed without updating this count.
#
# Grep strategy: filter non-comment lines that reference "$COMMAND" with ==
# and contain a write-only operation keyword. Write operations (comment, edit,
# move, assign, create, link) are distinct from read-only operations (view,
# list, comments, assets, transitions, changelog). The "comment " (with trailing
# space) pattern is distinct from "comments" in the read-only list.

@test "test_BC_3_01_001_F7_OBS_writeblock_contains_exactly_12_entries" {
  # F7 OBS / BC-3.01.001 write-block count / VP-HOOK-033 regression guard
  # Exactly 12 write-block conditions required: 6 plain-form + 6 --output-json-form,
  # one per write operation (comment, edit, move, assign, create, link).
  # GREEN now (code has 12); becomes RED if an entry is accidentally dropped.
  local count
  count=$(grep -v '^\s*#' "${PLUGIN_ROOT}/hooks/require-review.sh" \
    | grep 'COMMAND.*==' \
    | grep -cE '"jr issue (comment |edit|move|assign|create|link )|"--output json issue (comment |edit|move|assign|create|link )' || true)
  [ "${count}" -eq 12 ]
}

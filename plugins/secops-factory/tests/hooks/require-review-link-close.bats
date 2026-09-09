#!/usr/bin/env bats
# require-review-link-close.bats
#
# BC-3.01.001 v1.25 — D-020/D-021 Link+Close Anti-Fungibility (S-3.01)
#
# Covers:
#   AC-001  VP-HOOK-033 consumer / SM-57 kill — link write-block extension (→12 entries)
#   AC-002  VP-HOOK-035 consumer — close exact-type STEP-6 binding
#   AC-003  EC-026 — link cmd without link marker → DENY
#   AC-004  EC-027 — close cmd without close marker → DENY
#   AC-005  STEP-6 exact-type: link cmd → only ["link"] markers
#   AC-006  STEP-6 exact-type: close cmd → only ["close"] markers / SM-58 kill
#   AC-007  Single-use POSIX atomic rename (D-DEC-001)
#   AC-008  Non-interchangeability of link/close/create/comment marker types
#   AC-010  VP-HOOK-035 / SM-63 kill — CLOSE_STATE_ALLOWLIST consumer binding
#
# Red Gate target: ALL 27 tests fail against the S-3.01 stub which:
#   - has _validate_marker_for_command() returning 1 unconditionally
#   - has a 10-entry write-block (missing "jr issue link " and "--output json issue link ")
#   - has no STEP-6 exact-type matching
#   - has no CLOSE_STATE_ALLOWLIST binding
#
# Test naming follows BC-based convention: test_BC_S_SS_NNN_<assertion>

PLUGIN_ROOT="${BATS_TEST_DIRNAME}/../.."

# ── helpers ─────────────────────────────────────────────────────────────────

setup() {
  TEST_TMP=$(mktemp -d)
  MARKER_DIR="${TEST_TMP}/markers"
  mkdir -p "${MARKER_DIR}"
  export CLAUDE_PLUGIN_DATA="${TEST_TMP}"
}

teardown() {
  rm -rf "${TEST_TMP}"
}

# _run_hook CMD — pipe CMD as a PreToolUse/Bash JSON envelope to require-review.sh
# Uses jq -R . to properly JSON-escape CMD (handles embedded double quotes).
_run_hook() {
  local cmd="$1"
  local json
  json=$(printf '{"tool_input":{"command":%s}}' "$(printf '%s' "${cmd}" | jq -R .)")
  run bash -c 'printf "%s" "$1" | CLAUDE_PLUGIN_DATA="$2" "$3/hooks/require-review.sh"' \
      -- "${json}" "${CLAUDE_PLUGIN_DATA}" "${PLUGIN_ROOT}"
}

# _write_marker FILENAME JSON — write a marker file into the test marker dir
_write_marker() {
  local filename="$1"
  local content="$2"
  printf "%s" "${content}" > "${MARKER_DIR}/${filename}"
}

# _future_ts — ISO-8601 UTC timestamp 300 seconds in the future (well within TTL)
_future_ts() {
  if date --version 2>/dev/null | grep -q GNU; then
    date -u -d '+300 seconds' '+%Y-%m-%dT%H:%M:%SZ'
  else
    date -u -v+300S '+%Y-%m-%dT%H:%M:%SZ'
  fi
}

# _now_ts — current UTC timestamp
_now_ts() {
  date -u '+%Y-%m-%dT%H:%M:%SZ'
}

# ── AC-001: write-block extension — link entries present (VP-HOOK-033/SM-57) ──

@test "test_BC_3_01_001_AC001_SM57_link_plain_form_writeblocked_no_marker" {
  # AC-001 / VP-HOOK-033 / SM-57 kill — vd:1332
  # "jr issue link " must be in the write-block (deny reason "review approval"),
  # not reach the fail-closed path ("Unrecognized jr subcommand").
  # Stub: jr issue link NOT in write-block → fail-closed →
  # reason "Unrecognized jr subcommand" ≠ "review approval" → FAIL
  _run_hook "jr issue link SEC-42 SEC-99"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  [[ "$output" == *"review approval"* ]]
}

@test "test_BC_3_01_001_AC001_SM57_link_json_form_writeblocked_no_marker" {
  # AC-001 / VP-HOOK-033 / SM-57 kill — D-020/P18-001 --output json form (entry 12)
  # "--output json issue link " must be in the write-block; 12 total entries.
  # Stub: --output json issue link NOT in write-block → fail-closed → wrong reason → FAIL
  _run_hook "jr --output json issue link SEC-42 SEC-99"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  [[ "$output" == *"review approval"* ]]
}

@test "test_BC_3_01_001_AC001_writeblock_active_link_entry_count_is_2" {
  # AC-001 — BC-3.01.001 PC#2 requires exactly 12 write-block entries after D-020.
  # This test counts active (non-comment) lines in require-review.sh that contain
  # either new D-020 write-block pattern.
  # Stub: the two "jr issue link " entries appear ONLY in comments (not as active
  # conditions) → grep of non-comment lines returns 0 < 2 → FAIL
  local count
  count=$(grep -v '^\s*#' "${PLUGIN_ROOT}/hooks/require-review.sh" \
    | grep -c '"jr issue link "\|"--output json issue link "' || true)
  [ "${count}" -ge 2 ]
}

# ── AC-003 / EC-026: link command without link marker → DENY ─────────────────

@test "test_BC_3_01_001_AC003_EC026_link_cmd_empty_markerstore_deny" {
  # AC-003 / EC-026 — no marker in store; link command denied via write-block path.
  # Stub: jr issue link NOT in write-block → fail-closed → wrong reason → FAIL
  _run_hook "jr issue link SEC-123 SEC-456"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  [[ "$output" == *"review approval"* ]]
}

@test "test_BC_3_01_001_AC003_EC026A_comment_marker_step5_does_not_authorize_link_and_valid_link_allows" {
  # AC-003 / EC-026 direction A (step-5 denial) + AC-005 ALLOW (compound)
  #
  # Part A: ["comment"] marker (comment command_pattern) + jr issue link SEC-123 SEC-456
  # → DENY (step-5 anchored match fails; comment pattern does not match link command).
  # Part B: ["link"] marker + same link command → ALLOW.
  #
  # Part A trivially passes under stub (jr issue link hits fail-closed → deny).
  # Part B fails under stub (_validate_marker_for_command returns 1 → deny).
  # Compound test FAILS under stub because Part B assertion fails.
  #
  # Mechanism distinction for Part A: deny reason must come from write-block path
  # ("review approval"), not fail-closed — proving the command entered the write-block.
  # Stub fails this check (fail-closed gives "Unrecognized jr subcommand").

  local now
  now=$(_now_ts)
  local future
  future=$(_future_ts)

  # Part A: wrong-type marker present; DENY expected
  _write_marker "comment-ec026a.marker.json" \
    '{"marker_id":"m-ec026a","ticket_id":"SEC-123","org_slug":"test","authorized_operations":["comment"],"command_pattern":"^jr (--output json )?issue comment SEC-123 ","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue link SEC-123 SEC-456"
  deny_output="$output"
  deny_status="$status"

  # Part B: correct-type marker present; ALLOW expected (FAILS under stub)
  rm -f "${MARKER_DIR}/comment-ec026a.marker.json"
  _write_marker "link-ec026a.marker.json" \
    '{"marker_id":"m-link-ec026a","ticket_id":"SEC-123","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-123 SEC-456( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue link SEC-123 SEC-456"

  # Assertions
  [ "${deny_status}" -eq 0 ]
  [[ "${deny_output}" == *'"permissionDecision":"deny"'* ]]
  [[ "${deny_output}" == *"review approval"* ]]   # write-block path, not fail-closed
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "test_BC_3_01_001_AC005_AC008_SM58_step6_comment_marker_with_link_pattern_deny_and_link_marker_allows" {
  # AC-005 / AC-008 / SM-58 kill (STEP-6a link anti-fungibility cross-check-removed) — vd:1333
  #
  # SM-58 kill vector: a ["comment"] marker whose command_pattern MATCHES the link
  # command at step 5 (flexible pattern). Under correct implementation: step 5 PASSES;
  # step 6 fires — jr issue link → only ["link"] accepted; ["comment"] → CONTINUE; deny.
  # Under SM-58 (step 6 removed): step 5 passes → allow (WRONG → mutant caught).
  #
  # Part A: ["comment"] marker with link-matching pattern + link cmd → DENY (step-6 type).
  # Mechanism assertion: deny via write-block path ("review approval"), not fail-closed.
  # Stub: jr issue link NOT in write-block → fail-closed → wrong reason → FAILS on Part A.
  #
  # Part B: ["link"] marker + link cmd → ALLOW (FAILS under stub unconditionally).

  local now
  now=$(_now_ts)
  local future
  future=$(_future_ts)

  # Part A: SM-58 kill — ["comment"] marker with step-5-passing pattern → DENY via step 6
  _write_marker "comment-flexible-sm58.marker.json" \
    '{"marker_id":"m-sm58","ticket_id":"SEC-42","org_slug":"test","authorized_operations":["comment"],"command_pattern":"^jr (--output json )?issue (link|comment) SEC-42 ","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue link SEC-42 SEC-99"
  deny_output="$output"
  deny_status="$status"

  # Part B: correct ["link"] marker → ALLOW (FAILS under stub)
  rm -f "${MARKER_DIR}/comment-flexible-sm58.marker.json"
  _write_marker "link-sm58.marker.json" \
    '{"marker_id":"m-sm58-link","ticket_id":"SEC-42","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-42 SEC-99( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue link SEC-42 SEC-99"

  # Assertions
  [ "${deny_status}" -eq 0 ]
  [[ "${deny_output}" == *'"permissionDecision":"deny"'* ]]
  # Distinguishing mechanism assertion (SM-58 kill): deny via write-block path
  [[ "${deny_output}" == *"review approval"* ]]
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

# ── AC-005 / EC-001: valid link marker + link command → ALLOW ─────────────────

@test "test_BC_3_01_001_AC005_valid_link_marker_allows_link_command" {
  # AC-005 / EC-001 / VP-HOOK-033 happy path — D-020 accept path
  # Stub: _validate_marker_for_command returns 1 → unconditional deny → FAIL
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-happy.marker.json" \
    '{"marker_id":"m-link-h","ticket_id":"SEC-123","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-123 SEC-456( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue link SEC-123 SEC-456"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "test_BC_3_01_001_AC005_valid_link_marker_allows_link_json_form" {
  # AC-005 — --output json form of link command with matching link marker → ALLOW
  # Stub: --output json issue link not in write-block → fail-closed deny → FAIL
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-json.marker.json" \
    '{"marker_id":"m-link-j","ticket_id":"SEC-123","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-123 SEC-456( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr --output json issue link SEC-123 SEC-456"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

# ── AC-002 / EC-002: valid close marker + close command → ALLOW ───────────────

@test "test_BC_3_01_001_AC002_valid_close_marker_allows_close_command_done" {
  # AC-002 / EC-002 / VP-HOOK-035 happy path — D-021 accept path; Done ∈ allowlist
  # Stub: _validate_marker_for_command returns 1 → unconditional deny → FAIL
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "close-done.marker.json" \
    '{"marker_id":"m-close-d","ticket_id":"SEC-42","org_slug":"test","authorized_operations":["close"],"command_pattern":"^jr (--output json )?issue move SEC-42 (Done|Closed|Resolved)( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue move SEC-42 Done"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

# ── AC-004 / EC-027: close command with wrong-type marker → DENY ─────────────

@test "test_BC_3_01_001_AC004_EC027A_comment_marker_does_not_authorize_close_and_close_marker_allows" {
  # AC-004 / EC-027 direction A (step-5 denial) + AC-002 ALLOW (compound)
  #
  # Part A: ["comment"] marker + jr issue move SEC-123 Done → DENY (step-5: comment
  # pattern does not match move command). jr issue move IS write-blocked; stub denies.
  # Part A passes trivially under stub (unconditional deny). Compound Part B fails.
  #
  # Part B: ["close"] marker + same close command → ALLOW (FAILS under stub).

  local now future
  now=$(_now_ts); future=$(_future_ts)

  # Part A: wrong-type marker → DENY (trivially passes under stub)
  _write_marker "comment-ec027a.marker.json" \
    '{"marker_id":"m-ec027a","ticket_id":"SEC-123","org_slug":"test","authorized_operations":["comment"],"command_pattern":"^jr (--output json )?issue comment SEC-123 ","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue move SEC-123 Done"
  deny_output="$output"
  deny_status="$status"

  # Part B: correct-type close marker → ALLOW (FAILS under stub)
  rm -f "${MARKER_DIR}/comment-ec027a.marker.json"
  _write_marker "close-ec027a.marker.json" \
    '{"marker_id":"m-close-ec027a","ticket_id":"SEC-123","org_slug":"test","authorized_operations":["close"],"command_pattern":"^jr (--output json )?issue move SEC-123 (Done|Closed|Resolved)( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue move SEC-123 Done"

  # Assertions
  [ "${deny_status}" -eq 0 ]
  [[ "${deny_output}" == *'"permissionDecision":"deny"'* ]]
  [[ "${deny_output}" == *"review approval"* ]]
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

# ── AC-006: close cmd with wrong-type link marker → DENY via step 6 ──────────

@test "test_BC_3_01_001_AC006_link_marker_step6_does_not_authorize_close_and_close_marker_allows" {
  # AC-006 / EC-004 / STEP-6: close cmd → only ["close"] markers.
  # A ["link"] marker whose command_pattern matches the move command at step 5.
  # Correct impl: step 5 PASSES; step 6: ["link"] ≠ close → CONTINUE → deny.
  # Stub: _validate_marker_for_command returns 1 → deny (wrong mechanism).
  #
  # Compound: Part A → DENY (passes stub); Part B close marker → ALLOW (FAILS stub).

  local now future
  now=$(_now_ts); future=$(_future_ts)

  # Part A: ["link"] marker with flexible step-5-passing pattern → DENY via step 6
  _write_marker "link-flexible-move.marker.json" \
    '{"marker_id":"m-link-move","ticket_id":"SEC-123","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue (link|move) SEC-123 ","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue move SEC-123 Done"
  deny_output="$output"
  deny_status="$status"

  # Part B: ["close"] marker → ALLOW (FAILS under stub)
  rm -f "${MARKER_DIR}/link-flexible-move.marker.json"
  _write_marker "close-allow.marker.json" \
    '{"marker_id":"m-close-a","ticket_id":"SEC-123","org_slug":"test","authorized_operations":["close"],"command_pattern":"^jr (--output json )?issue move SEC-123 (Done|Closed|Resolved)( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue move SEC-123 Done"

  # Assertions
  [ "${deny_status}" -eq 0 ]
  [[ "${deny_output}" == *'"permissionDecision":"deny"'* ]]
  [[ "${deny_output}" == *"review approval"* ]]
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

# ── AC-005: link cmd with wrong-type close marker → DENY via step 6 ──────────

@test "test_BC_3_01_001_AC005_close_marker_step6_does_not_authorize_link" {
  # AC-005 / EC-003 / STEP-6: link cmd → only ["link"] markers.
  # ["close"] marker with link-matching pattern + link cmd → step 6 → DENY.
  # Under stub: jr issue link NOT in write-block → fail-closed → wrong reason → FAIL
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "close-flexible-link.marker.json" \
    '{"marker_id":"m-close-link","ticket_id":"SEC-123","org_slug":"test","authorized_operations":["close"],"command_pattern":"^jr (--output json )?issue (link|move) SEC-123 ","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue link SEC-123 SEC-456"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  # Mechanism: must enter write-block path (review approval), not fail-closed
  [[ "$output" == *"review approval"* ]]
}

# ── AC-008: create marker cannot authorize link command ───────────────────────

@test "test_BC_3_01_001_AC008_create_marker_does_not_authorize_link_cmd" {
  # AC-008 — non-interchangeability: ["create"] marker cannot authorize link cmd.
  # Stub: jr issue link NOT in write-block → fail-closed → wrong reason → FAIL
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "create-sec.marker.json" \
    '{"marker_id":"m-create","ticket_id":null,"org_slug":"test","authorized_operations":["create"],"command_pattern":"^jr (--output json )?issue create --project PRISMDEMO( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue link SEC-123 SEC-456"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  [[ "$output" == *"review approval"* ]]
}

# ── AC-008 / EC-026B: link marker cannot authorize comment command ────────────

@test "test_BC_3_01_001_AC008_EC026B_link_marker_does_not_authorize_comment_and_comment_marker_allows" {
  # AC-008 / EC-026 direction B (step-5 denial) + regression ALLOW (compound).
  # Part A: ["link"] marker (link command_pattern) + jr issue comment → DENY.
  # Part B: ["comment"] marker + jr issue comment → ALLOW (FAILS under stub).

  local now future
  now=$(_now_ts); future=$(_future_ts)

  # Part A: ["link"] marker → DENY on comment command (step-5 fails: link pattern ≠ comment cmd)
  _write_marker "link-ec026b.marker.json" \
    '{"marker_id":"m-link-ec026b","ticket_id":"SEC-123","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-123 SEC-456( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook 'jr issue comment SEC-123 "msg"'
  deny_output="$output"
  deny_status="$status"

  # Part B: correct ["comment"] marker → ALLOW (FAILS under stub)
  rm -f "${MARKER_DIR}/link-ec026b.marker.json"
  _write_marker "comment-ec026b.marker.json" \
    '{"marker_id":"m-comment-ec026b","ticket_id":"SEC-123","org_slug":"test","authorized_operations":["comment"],"command_pattern":"^jr (--output json )?issue comment SEC-123 ","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook 'jr issue comment SEC-123 "msg"'

  # Assertions
  [ "${deny_status}" -eq 0 ]
  [[ "${deny_output}" == *'"permissionDecision":"deny"'* ]]
  [[ "${deny_output}" == *"review approval"* ]]
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

# ── AC-007: single-use POSIX atomic rename (D-DEC-001) ───────────────────────

@test "test_BC_3_01_001_AC007_single_use_link_marker_replay_denied" {
  # AC-007 — first link consumption → ALLOW; second (replay) → DENY.
  # Stub: first run → _validate_marker_for_command returns 1 → deny → FAIL
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-su.marker.json" \
    '{"marker_id":"m-link-su","ticket_id":"SEC-10","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-10 SEC-20( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'

  # First use: ALLOW and consume marker
  _run_hook "jr issue link SEC-10 SEC-20"
  first_output="$output"
  first_status="$status"

  # Second use (replay): DENY — marker renamed to .used
  _run_hook "jr issue link SEC-10 SEC-20"

  [ "${first_status}" -eq 0 ]
  [[ "${first_output}" == *'"permissionDecision":"allow"'* ]]
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "test_BC_3_01_001_AC007_single_use_close_marker_replay_denied" {
  # AC-007 — close marker consumed on first use; second → DENY.
  # Stub: first run → deny → FAIL (asserts allow)
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "close-su.marker.json" \
    '{"marker_id":"m-close-su","ticket_id":"SEC-11","org_slug":"test","authorized_operations":["close"],"command_pattern":"^jr (--output json )?issue move SEC-11 Done( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'

  _run_hook "jr issue move SEC-11 Done"
  first_output="$output"
  first_status="$status"

  _run_hook "jr issue move SEC-11 Done"

  [ "${first_status}" -eq 0 ]
  [[ "${first_output}" == *'"permissionDecision":"allow"'* ]]
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

# ── AC-010 / SM-63 kill: CLOSE_STATE_ALLOWLIST consumer binding ───────────────

@test "test_BC_3_01_001_AC010_SM63_allowlisted_state_done_allows" {
  # AC-010(b) / VP-HOOK-035 / SM-63 kill — Done ∈ CLOSE_STATE_ALLOWLIST → ALLOW.
  # Stub: _validate_marker_for_command returns 1 → deny → FAIL
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "close-allowlist-done.marker.json" \
    '{"marker_id":"m-sm63-d","ticket_id":"SEC-42","org_slug":"test","authorized_operations":["close"],"command_pattern":"^jr (--output json )?issue move SEC-42 (Done|Closed|Resolved)( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue move SEC-42 Done"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "test_BC_3_01_001_AC010_SM63_non_allowlisted_wontfix_denies_and_done_allows" {
  # AC-010(a+b) / VP-HOOK-035 / SM-63 kill — compound test.
  #
  # Part A: WontFix ∉ CLOSE_STATE_ALLOWLIST → DENY (step-5 pattern mismatch).
  # Under SM-63 (allowlist removed): generic pattern accepts WontFix → ALLOW (wrong).
  #
  # Part A passes trivially under stub (stub denies all write-block commands).
  # Part B: Done ∈ CLOSE_STATE_ALLOWLIST → ALLOW (FAILS under stub → Red Gate).
  #
  # Both parts required for SM-63 kill: mutant accepts WontFix (Part A fails) while
  # correct implementation additionally accepts Done (Part B asserted).

  local now future
  now=$(_now_ts); future=$(_future_ts)

  # Part A: WontFix → DENY
  _write_marker "close-wontfix.marker.json" \
    '{"marker_id":"m-sm63-wf","ticket_id":"SEC-42","org_slug":"test","authorized_operations":["close"],"command_pattern":"^jr (--output json )?issue move SEC-42 (Done|Closed|Resolved)( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue move SEC-42 WontFix"
  deny_output="$output"
  deny_status="$status"

  # Part B: Done → ALLOW with a fresh marker (FAILS under stub)
  rm -f "${MARKER_DIR}/close-wontfix.marker.json"
  _write_marker "close-done-b.marker.json" \
    '{"marker_id":"m-sm63-db","ticket_id":"SEC-42","org_slug":"test","authorized_operations":["close"],"command_pattern":"^jr (--output json )?issue move SEC-42 (Done|Closed|Resolved)( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue move SEC-42 Done"

  # Assertions
  [ "${deny_status}" -eq 0 ]
  [[ "${deny_output}" == *'"permissionDecision":"deny"'* ]]
  [[ "${deny_output}" == *"review approval"* ]]
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "test_BC_3_01_001_AC010_SM63_allowlisted_state_closed_allows" {
  # AC-010(b) variant — Closed ∈ CLOSE_STATE_ALLOWLIST → ALLOW.
  # Stub: deny → FAIL
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "close-closed.marker.json" \
    '{"marker_id":"m-sm63-cl","ticket_id":"SEC-42","org_slug":"test","authorized_operations":["close"],"command_pattern":"^jr (--output json )?issue move SEC-42 (Done|Closed|Resolved)( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue move SEC-42 Closed"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "test_BC_3_01_001_AC010_SM63_allowlisted_state_resolved_allows" {
  # AC-010(b) variant — Resolved ∈ CLOSE_STATE_ALLOWLIST → ALLOW.
  # Stub: deny → FAIL
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "close-resolved.marker.json" \
    '{"marker_id":"m-sm63-res","ticket_id":"SEC-42","org_slug":"test","authorized_operations":["close"],"command_pattern":"^jr (--output json )?issue move SEC-42 (Done|Closed|Resolved)( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue move SEC-42 Resolved"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "test_BC_3_01_001_AC010_SM63_json_form_allowlisted_done_allows" {
  # AC-010(b) — --output json close form with Done → ALLOW.
  # Stub: deny → FAIL
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "close-json.marker.json" \
    '{"marker_id":"m-sm63-j","ticket_id":"SEC-42","org_slug":"test","authorized_operations":["close"],"command_pattern":"^jr (--output json )?issue move SEC-42 (Done|Closed|Resolved)( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr --output json issue move SEC-42 Done"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

# ── AC-007 / Invariant #2: consumed markers produce audit log entry ───────────

@test "test_BC_3_01_001_AC007_link_marker_consumed_writes_audit_log" {
  # AC-007 / BC-3.01.001 Invariant #2 — link allow must append MARKER_USED to audit.log.
  # Stub: deny (no allow) → audit log not written → assertion fails → FAIL
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-audit.marker.json" \
    '{"marker_id":"m-link-au","ticket_id":"SEC-50","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-50 SEC-60( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue link SEC-50 SEC-60"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
  [ -f "${MARKER_DIR}/audit.log" ]
  grep -q "MARKER_USED" "${MARKER_DIR}/audit.log"
}

@test "test_BC_3_01_001_AC007_close_marker_consumed_writes_audit_log" {
  # AC-007 / BC-3.01.001 Invariant #2 — close allow must append MARKER_USED.
  # Stub: deny → audit log not written → FAIL
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "close-audit.marker.json" \
    '{"marker_id":"m-close-au","ticket_id":"SEC-55","org_slug":"test","authorized_operations":["close"],"command_pattern":"^jr (--output json )?issue move SEC-55 Done( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue move SEC-55 Done"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
  [ -f "${MARKER_DIR}/audit.log" ]
  grep -q "MARKER_USED" "${MARKER_DIR}/audit.log"
}

# ── AC-009 regression: existing write paths unaffected after D-020/D-021 ─────

@test "test_BC_3_01_001_AC009_regression_valid_comment_marker_still_allows" {
  # AC-009 regression — existing ["comment"] marker still authorizes matching comment cmd.
  # Stub: _validate_marker_for_command returns 1 → deny → FAIL
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "comment-reg.marker.json" \
    '{"marker_id":"m-comment-reg","ticket_id":"SEC-123","org_slug":"test","authorized_operations":["comment"],"command_pattern":"^jr (--output json )?issue comment SEC-123 ","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook 'jr issue comment SEC-123 "enrichment complete"'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "test_BC_3_01_001_AC009_regression_create_review_marker_still_allows" {
  # AC-009 regression — existing ["create-review"] marker still authorizes review-labeled create.
  # Stub: deny → FAIL
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "create-review-reg.marker.json" \
    '{"marker_id":"m-cr-reg","ticket_id":null,"org_slug":"test","authorized_operations":["create-review"],"command_pattern":"^jr (--output json )?issue create --project PRISMDEMO --label (REVIEW-REQUIRED|BLIND-SPOT)( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue create --project PRISMDEMO --label REVIEW-REQUIRED --summary \"[REVIEW-REQUIRED] SEC-789 HIGH\""
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

# ── EC-017 parity: expired link/close markers → DENY ─────────────────────────

@test "test_BC_3_01_001_EC017_expired_link_marker_denied_and_valid_link_marker_allows" {
  # BC-3.01.001 EC-017 (link variant) — expired link marker; step-4 TTL check fails → deny.
  # Compound: Part A expired marker → DENY; Part B valid marker → ALLOW (FAILS stub).
  # Stub (Part A): jr issue link NOT in write-block → fail-closed → wrong reason → FAILS on Part A.

  local now future
  now=$(_now_ts); future=$(_future_ts)

  # Part A: expired link marker → DENY
  _write_marker "link-expired.marker.json" \
    '{"marker_id":"m-link-exp","ticket_id":"SEC-77","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-77 SEC-88( |$)","issued_at_utc":"2020-01-01T00:00:00Z","expires_at_utc":"2020-01-01T00:02:00Z"}'
  _run_hook "jr issue link SEC-77 SEC-88"
  deny_output="$output"
  deny_status="$status"

  # Part B: valid (non-expired) link marker → ALLOW (FAILS under stub)
  rm -f "${MARKER_DIR}/link-expired.marker.json"
  _write_marker "link-valid.marker.json" \
    '{"marker_id":"m-link-val","ticket_id":"SEC-77","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-77 SEC-88( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue link SEC-77 SEC-88"

  # Assertions
  [ "${deny_status}" -eq 0 ]
  [[ "${deny_output}" == *'"permissionDecision":"deny"'* ]]
  [[ "${deny_output}" == *"review approval"* ]]
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "test_BC_3_01_001_EC017_expired_close_marker_denied_and_valid_close_marker_allows" {
  # BC-3.01.001 EC-017 (close variant) — expired close marker; TTL check fails → deny.
  # Compound: Part A expired close → DENY; Part B valid close → ALLOW (FAILS stub).

  local now future
  now=$(_now_ts); future=$(_future_ts)

  # Part A: expired close marker → DENY
  _write_marker "close-expired.marker.json" \
    '{"marker_id":"m-close-exp","ticket_id":"SEC-77","org_slug":"test","authorized_operations":["close"],"command_pattern":"^jr (--output json )?issue move SEC-77 Done( |$)","issued_at_utc":"2020-01-01T00:00:00Z","expires_at_utc":"2020-01-01T00:02:00Z"}'
  _run_hook "jr issue move SEC-77 Done"
  deny_output="$output"
  deny_status="$status"

  # Part B: valid close marker → ALLOW (FAILS under stub)
  rm -f "${MARKER_DIR}/close-expired.marker.json"
  _write_marker "close-valid.marker.json" \
    '{"marker_id":"m-close-val","ticket_id":"SEC-77","org_slug":"test","authorized_operations":["close"],"command_pattern":"^jr (--output json )?issue move SEC-77 Done( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue move SEC-77 Done"

  # Assertions
  [ "${deny_status}" -eq 0 ]
  [[ "${deny_output}" == *'"permissionDecision":"deny"'* ]]
  [[ "${deny_output}" == *"review approval"* ]]
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

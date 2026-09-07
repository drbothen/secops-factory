#!/usr/bin/env bats
# require-review-ps1-behavioral.bats
#
# BC-3.01.001 v1.25 — Tier B: Behavioral parity tests for require-review.ps1
#
# All tests in this file are PWSH-GATED: they skip locally when pwsh is absent
# and are enforced in CI (ubuntu-latest has pwsh pre-installed).
#
# These tests mirror the key behavioral vectors exercised against require-review.sh
# but run against require-review.ps1. All tests are RED in CI against the current
# pre-port .ps1 (which has no marker logic, no metachar guard, no label check,
# no timestamp validation, and no audit write).
#
# Vectors covered (BC-3.01.001 v1.25):
#   BP-001  Valid link marker → ALLOW (AC-001 / AC-005)
#   BP-002  Valid close marker → ALLOW (AC-002 / AC-006)
#   BP-003  Valid create marker, no review label → ALLOW (EC-017)
#   BP-004  Comment marker for link command → DENY (EC-026 anti-fungibility)
#   BP-005  Create marker for link command → DENY (STEP-6 type check)
#   BP-006  Link marker for close command → DENY (STEP-6 / AC-006 / SM-58 kill)
#   BP-007  EC-024: summary text containing --label text → ALLOW (false-deny prev.)
#   BP-008  SM-40 double-space in --label arg → DENY with regular create marker (C1/F1)
#   BP-009  SM-42 single-quoted --label value → DENY (C1/F1 quote-aware tokenizer)
#   BP-010  SM-43 tab before label value → DENY (C1/F1 whitespace tokenizer)
#   BP-011  Metachar: semicolon chain injection → DENY (I1/step 5)
#   BP-012  Metachar: pipe injection → DENY (I1/step 5)
#   BP-013  Metachar: greater-than redirect → DENY (F2/step 5)
#   BP-014  Metachar: $( subshell injection → DENY (I1/step 5)
#   BP-015  Single-use replay → DENY (D-DEC-001 atomic rename)
#   BP-016  Future-dated issued_at_utc → DENY (I2 / BC step 3)
#   BP-017  Malformed expires_at_utc → DENY (F5 / BC step 4b)
#   BP-018  Audit record written on allow (VP-HOOK-024 / Invariant #2)
#
# Pass-4 adversarial findings (added after pass-4 review):
#   BP-022  pass-4 F1 MEDIUM: scalar-string authorized_operations → DENY (fail-open guard)
#   BP-023  pass-4 F2 MINOR:  Unicode digit in expires_at_utc → DENY (lax ISO regex guard)
#
# Test naming: test_BC_S_SS_NNN_<tier>_<vector>_<assertion>

PLUGIN_ROOT="${BATS_TEST_DIRNAME}/../.."

# ── pwsh guard ──────────────────────────────────────────────────────────────────
require_pwsh() {
  if ! command -v pwsh &>/dev/null; then
    skip "pwsh not installed — behavioral .ps1 parity tests run in CI"
  fi
}

# ── helpers ──────────────────────────────────────────────────────────────────────

setup() {
  TEST_TMP=$(mktemp -d)
  MARKER_DIR="${TEST_TMP}/markers"
  mkdir -p "${MARKER_DIR}"
  export CLAUDE_PLUGIN_DATA="${TEST_TMP}"
}

teardown() {
  chmod -R u+rw "${TEST_TMP}" 2>/dev/null || true
  rm -rf "${TEST_TMP}"
}

# _run_ps1_hook CMD — pipe CMD as a PreToolUse/Bash JSON envelope to require-review.ps1.
# Uses jq -R . to properly JSON-encode CMD (handles embedded quotes, $, etc.).
# stdin is explicitly closed via a redirect from /dev/null on the inner bash call;
# the pwsh process itself reads from the piped JSON, not from an interactive tty.
_run_ps1_hook() {
  local cmd="$1"
  local json
  json=$(printf '{"tool_input":{"command":%s}}' "$(printf '%s' "${cmd}" | jq -R .)")
  run bash -c 'printf "%s" "$1" | CLAUDE_PLUGIN_DATA="$2" pwsh -NoProfile -File "$3/hooks/require-review.ps1"' \
      -- "${json}" "${CLAUDE_PLUGIN_DATA}" "${PLUGIN_ROOT}"
}

# _write_marker FILENAME JSON — write a marker file into the test marker dir
_write_marker() {
  local filename="$1"
  local content="$2"
  printf "%s" "${content}" > "${MARKER_DIR}/${filename}"
}

# _future_ts — ISO-8601 UTC timestamp 300 s in the future
_future_ts() {
  if date --version 2>/dev/null | grep -q GNU; then
    date -u -d '+300 seconds' '+%Y-%m-%dT%H:%M:%SZ'
  else
    date -u -v+300S '+%Y-%m-%dT%H:%M:%SZ'
  fi
}

# _far_future_ts — ISO-8601 UTC timestamp 600 s in the future
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

# ── BP-001: valid link marker → ALLOW ──────────────────────────────────────────

@test "test_BC_3_01_001_BP001_ps1_valid_link_marker_allows" {
  # BP-001 / BC-3.01.001 AC-001 / AC-005 / D-020
  # Valid unexpired ["link"] marker matching the link command → ps1 must ALLOW.
  # Current .ps1 has no marker logic → unconditional deny from write-block → RED in CI.
  require_pwsh
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-bp001.marker.json" \
    "{\"marker_id\":\"m-bp001-link\",\"ticket_id\":\"SEC-100\",\"org_slug\":\"test\",\"authorized_operations\":[\"link\"],\"command_pattern\":\"^jr (--output json )?issue link SEC-100 SEC-200( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"
  _run_ps1_hook "jr issue link SEC-100 SEC-200"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

# ── BP-002: valid close marker → ALLOW ─────────────────────────────────────────

@test "test_BC_3_01_001_BP002_ps1_valid_close_marker_allows" {
  # BP-002 / BC-3.01.001 AC-002 / AC-006 / D-021
  # Valid unexpired ["close"] marker matching the close command → ps1 must ALLOW.
  # Current .ps1 has no marker logic → deny from write-block → RED in CI.
  require_pwsh
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "close-bp002.marker.json" \
    "{\"marker_id\":\"m-bp002-close\",\"ticket_id\":\"SEC-101\",\"org_slug\":\"test\",\"authorized_operations\":[\"close\"],\"command_pattern\":\"^jr (--output json )?issue move SEC-101 (Done|Closed|Resolved)( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"
  _run_ps1_hook "jr issue move SEC-101 Done"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

# ── BP-003: valid create marker, no review label → ALLOW ───────────────────────

@test "test_BC_3_01_001_BP003_ps1_valid_create_marker_no_review_label_allows" {
  # BP-003 / BC-3.01.001 PC#2 / EC-017
  # Valid ["create"] marker + create command with no hard-floor label → ALLOW.
  # Regular create commands (no REVIEW-REQUIRED / BLIND-SPOT) must be allowed
  # with a regular ["create"] marker.
  # Current .ps1 → deny from write-block → RED in CI.
  require_pwsh
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "create-bp003.marker.json" \
    "{\"marker_id\":\"m-bp003-create\",\"ticket_id\":null,\"org_slug\":\"test\",\"authorized_operations\":[\"create\"],\"command_pattern\":\"^jr (--output json )?issue create --project PRISMDEMO( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"
  _run_ps1_hook 'jr issue create --project PRISMDEMO --summary "FP: benign scan noise"'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

# ── BP-004: comment marker cannot authorize link command (EC-026) ───────────────

@test "test_BC_3_01_001_BP004_ps1_comment_marker_denied_for_link_command" {
  # BP-004 / BC-3.01.001 EC-026 anti-fungibility / AC-008
  # ["comment"] marker + link command → DENY (type mismatch at STEP-6 / step-5 pattern fail).
  # The comment marker's command_pattern is for comment, not link — step-5 match fails.
  # Current .ps1 denies because write-block (no marker logic), but for the wrong reason.
  # After port: must deny via step-5/STEP-6 mechanism, not just write-block.
  # Test passes in both pre-port (.ps1 denies from write-block) and post-port
  # (.ps1 denies via marker mechanism) — this test validates the behavioral outcome.
  require_pwsh
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "comment-bp004.marker.json" \
    "{\"marker_id\":\"m-bp004-comment\",\"ticket_id\":\"SEC-102\",\"org_slug\":\"test\",\"authorized_operations\":[\"comment\"],\"command_pattern\":\"^jr (--output json )?issue comment SEC-102 \",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"
  _run_ps1_hook "jr issue link SEC-102 SEC-200"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  [[ "$output" == *"review approval"* ]]
}

# ── BP-005: create marker cannot authorize link command (STEP-6) ────────────────

@test "test_BC_3_01_001_BP005_ps1_create_marker_denied_for_link_command" {
  # BP-005 / BC-3.01.001 STEP-6 exact-type / AC-005 / AC-008
  # ["create"] marker + link command → DENY (STEP-6: link accepts only ["link"] markers).
  # After port, this is enforced by STEP-6 exact-type match; pre-port it's enforced by
  # write-block. Both produce deny — the test verifies the behavioral outcome holds.
  require_pwsh
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "create-for-link-bp005.marker.json" \
    "{\"marker_id\":\"m-bp005-cfl\",\"ticket_id\":null,\"org_slug\":\"test\",\"authorized_operations\":[\"create\"],\"command_pattern\":\"^jr (--output json )?issue create --project PRISMDEMO( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"
  _run_ps1_hook "jr issue link SEC-103 SEC-201"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

# ── BP-006: link marker cannot authorize close command (AC-006 / SM-58) ─────────

@test "test_BC_3_01_001_BP006_ps1_link_marker_denied_for_close_command" {
  # BP-006 / BC-3.01.001 AC-006 / SM-58 kill / STEP-6 exact-type
  # ["link"] marker + close command → DENY (STEP-6: close accepts only ["close"] markers).
  # Tests non-interchangeability in close direction (AC-006).
  # Current .ps1 → deny from write-block → outcome correct, reason differs.
  require_pwsh
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-for-close-bp006.marker.json" \
    "{\"marker_id\":\"m-bp006-lfc\",\"ticket_id\":\"SEC-104\",\"org_slug\":\"test\",\"authorized_operations\":[\"link\"],\"command_pattern\":\"^jr (--output json )?issue link SEC-104 SEC-202( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"
  _run_ps1_hook "jr issue move SEC-104 Done"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

# ── BP-007: EC-024 summary text false-deny prevention → ALLOW ──────────────────

@test "test_BC_3_01_001_BP007_ps1_EC024_summary_text_label_string_allows" {
  # BP-007 / BC-3.01.001 EC-024 / P7-005 / P8-002
  # ["create"] marker + create command whose --summary VALUE contains the text
  # "--label REVIEW-REQUIRED" but has NO actual --label flag → must ALLOW.
  # Structural tokenizer must NOT fire on label strings inside --summary values.
  # Pre-port .ps1: denies via write-block (wrong reason, wrong level) → RED in CI.
  # Post-port: must allow (regular create marker, no hard-floor label token).
  require_pwsh
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "create-bp007-ec024.marker.json" \
    "{\"marker_id\":\"m-bp007-ec024\",\"ticket_id\":null,\"org_slug\":\"test\",\"authorized_operations\":[\"create\"],\"command_pattern\":\"^jr (--output json )?issue create --project PRISMDEMO( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"
  _run_ps1_hook 'jr issue create --project PRISMDEMO --summary "Alert mentions --label REVIEW-REQUIRED in body text"'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

# ── BP-008: SM-40 double-space bypass denied (C1/F1) ───────────────────────────

@test "test_BC_3_01_001_BP008_ps1_SM40_double_space_review_required_denied" {
  # BP-008 / BC-3.01.001 PC#2 step (6a) / SM-40 kill / C1 / F1 CRITICAL
  # ["create"] marker + "--label  REVIEW-REQUIRED" (double space between flag and value)
  # → must DENY (structural tokenizer collapses whitespace, still sees REVIEW-REQUIRED).
  # Current .ps1: no label check → marker consumed (write-block→marker path→ALLOW) → RED in CI.
  require_pwsh
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "create-bp008-sm40.marker.json" \
    "{\"marker_id\":\"m-bp008-sm40\",\"ticket_id\":null,\"org_slug\":\"test\",\"authorized_operations\":[\"create\"],\"command_pattern\":\"^jr (--output json )?issue create --project PRISMDEMO( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"
  _run_ps1_hook "$(printf '%s' "jr issue create --project PRISMDEMO --label  REVIEW-REQUIRED --summary test")"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  [[ "$output" == *"review approval"* ]]
}

# ── BP-009: SM-42 single-quoted label bypass denied (C1/F1) ────────────────────

@test "test_BC_3_01_001_BP009_ps1_SM42_single_quoted_review_required_denied" {
  # BP-009 / BC-3.01.001 PC#2 step (6a) / SM-42 kill / C1 / F1 CRITICAL / P8-002
  # ["create"] marker + "--label 'REVIEW-REQUIRED'" (single-quoted value) → must DENY.
  # Quote-aware tokenizer exits single-quote state correctly and sees REVIEW-REQUIRED token.
  # Current .ps1: no label check → ALLOW (BUG) → RED in CI.
  require_pwsh
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "create-bp009-sm42.marker.json" \
    "{\"marker_id\":\"m-bp009-sm42\",\"ticket_id\":null,\"org_slug\":\"test\",\"authorized_operations\":[\"create\"],\"command_pattern\":\"^jr (--output json )?issue create --project PRISMDEMO( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"
  _run_ps1_hook "jr issue create --project PRISMDEMO --label 'REVIEW-REQUIRED' --summary test"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  [[ "$output" == *"review approval"* ]]
}

# ── BP-010: SM-43 tab-separated label bypass denied (C1/F1) ────────────────────

@test "test_BC_3_01_001_BP010_ps1_SM43_tab_review_required_denied" {
  # BP-010 / BC-3.01.001 PC#2 step (6a) / SM-43 kill / C1 / F1 CRITICAL
  # ["create"] marker + "--label\tREVIEW-REQUIRED" (tab as separator) → must DENY.
  # Tokenizer treats tab as whitespace separator (same as space) — see standalone tokens.
  # Current .ps1: no label check → ALLOW (BUG) → RED in CI.
  require_pwsh
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "create-bp010-sm43.marker.json" \
    "{\"marker_id\":\"m-bp010-sm43\",\"ticket_id\":null,\"org_slug\":\"test\",\"authorized_operations\":[\"create\"],\"command_pattern\":\"^jr (--output json )?issue create --project PRISMDEMO( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"
  local tab_cmd
  tab_cmd=$(printf '%s\t%s' "--label" "REVIEW-REQUIRED")
  _run_ps1_hook "jr issue create --project PRISMDEMO ${tab_cmd} --summary test"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  [[ "$output" == *"review approval"* ]]
}

# ── BP-011: semicolon chain injection denied (I1 / step 5) ─────────────────────

@test "test_BC_3_01_001_BP011_ps1_I1_semicolon_injection_denied" {
  # BP-011 / BC-3.01.001 PC#2 step (5) / I1 MAJOR
  # Valid ["link"] marker + "jr issue link SEC-105 SEC-203 ; evil" → must DENY.
  # Consumer metachar guard must reject ; before any pattern match.
  # Current .ps1: no metachar guard → marker consumed → ALLOW (BUG) → RED in CI.
  require_pwsh
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-bp011-semi.marker.json" \
    "{\"marker_id\":\"m-bp011-semi\",\"ticket_id\":\"SEC-105\",\"org_slug\":\"test\",\"authorized_operations\":[\"link\"],\"command_pattern\":\"^jr (--output json )?issue link SEC-105 SEC-203( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"
  _run_ps1_hook 'jr issue link SEC-105 SEC-203 ; rm -rf /tmp/pwsh-test'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

# ── BP-012: pipe injection denied (I1 / step 5) ────────────────────────────────

@test "test_BC_3_01_001_BP012_ps1_I1_pipe_injection_denied" {
  # BP-012 / BC-3.01.001 PC#2 step (5) / I1 MAJOR
  # Valid ["link"] marker + "jr issue link SEC-106 SEC-204 | evil" → must DENY.
  # Current .ps1: no metachar guard → ALLOW (BUG) → RED in CI.
  require_pwsh
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-bp012-pipe.marker.json" \
    "{\"marker_id\":\"m-bp012-pipe\",\"ticket_id\":\"SEC-106\",\"org_slug\":\"test\",\"authorized_operations\":[\"link\"],\"command_pattern\":\"^jr (--output json )?issue link SEC-106 SEC-204( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"
  _run_ps1_hook 'jr issue link SEC-106 SEC-204 | cat /etc/passwd'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

# ── BP-013: greater-than redirect denied (F2 / step 5) ─────────────────────────

@test "test_BC_3_01_001_BP013_ps1_F2_gt_redirect_denied" {
  # BP-013 / BC-3.01.001 PC#2 step (5) / F2 MAJOR (F2 addition: > guard)
  # Valid ["link"] marker + "jr issue link ... > /tmp/exfil" → must DENY.
  # > covers both shell redirect and >() process substitution form.
  # Current .ps1: no metachar guard → ALLOW (BUG) → RED in CI.
  require_pwsh
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-bp013-gt.marker.json" \
    "{\"marker_id\":\"m-bp013-gt\",\"ticket_id\":\"SEC-107\",\"org_slug\":\"test\",\"authorized_operations\":[\"link\"],\"command_pattern\":\"^jr (--output json )?issue link SEC-107 SEC-205( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"
  _run_ps1_hook 'jr issue link SEC-107 SEC-205 > /tmp/exfil'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

# ── BP-014: dollar-paren subshell injection denied (I1 / step 5) ───────────────

@test "test_BC_3_01_001_BP014_ps1_I1_dollar_paren_injection_denied" {
  # BP-014 / BC-3.01.001 PC#2 step (5) / I1 MAJOR
  # Valid ["link"] marker + "jr issue link SEC-108 SEC-206 $(id)" → must DENY.
  # $( guard prevents command substitution injection.
  # Current .ps1: no metachar guard → ALLOW (BUG) → RED in CI.
  require_pwsh
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-bp014-sub.marker.json" \
    "{\"marker_id\":\"m-bp014-sub\",\"ticket_id\":\"SEC-108\",\"org_slug\":\"test\",\"authorized_operations\":[\"link\"],\"command_pattern\":\"^jr (--output json )?issue link SEC-108 SEC-206( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"
  _run_ps1_hook 'jr issue link SEC-108 SEC-206 $(id)'
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

# ── BP-015: single-use replay denied (D-DEC-001 atomic rename) ─────────────────

@test "test_BC_3_01_001_BP015_ps1_single_use_replay_denied" {
  # BP-015 / BC-3.01.001 D-DEC-001 / AC-007
  # First use of a valid ["link"] marker → ALLOW; second identical use → DENY.
  # Marker is consumed via atomic rename (.marker.json → .marker.used); replay fails.
  # Current .ps1: denies both uses (no marker logic) → first-use RED in CI.
  require_pwsh
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-bp015-su.marker.json" \
    "{\"marker_id\":\"m-bp015-su\",\"ticket_id\":\"SEC-109\",\"org_slug\":\"test\",\"authorized_operations\":[\"link\"],\"command_pattern\":\"^jr (--output json )?issue link SEC-109 SEC-207( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"

  # First use — must ALLOW (marker valid)
  _run_ps1_hook "jr issue link SEC-109 SEC-207"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]

  # Second use — must DENY (marker consumed)
  _run_ps1_hook "jr issue link SEC-109 SEC-207"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

# ── BP-016: future-dated issued_at_utc denied (I2 / BC step 3) ─────────────────

@test "test_BC_3_01_001_BP016_ps1_I2_future_issued_at_utc_denied" {
  # BP-016 / BC-3.01.001 PC#2 step (3) / I2 MEDIUM
  # Marker with issued_at_utc in the future → adversarial signal → DENY.
  # BC step (3): if issued_at_utc > now() → skip marker.
  # Current .ps1: no issued_at_utc check (entire marker logic absent) → RED in CI.
  require_pwsh
  local future far_future
  future=$(_future_ts); far_future=$(_far_future_ts)
  _write_marker "link-bp016-fi.marker.json" \
    "{\"marker_id\":\"m-bp016-fi\",\"ticket_id\":\"SEC-110\",\"org_slug\":\"test\",\"authorized_operations\":[\"link\"],\"command_pattern\":\"^jr (--output json )?issue link SEC-110 SEC-208( |$)\",\"issued_at_utc\":\"${future}\",\"expires_at_utc\":\"${far_future}\"}"
  _run_ps1_hook "jr issue link SEC-110 SEC-208"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  [[ "$output" == *"review approval"* ]]
}

# ── BP-017: malformed expires_at_utc denied fail-closed (F5 / BC step 4b) ──────

@test "test_BC_3_01_001_BP017_ps1_F5_malformed_expires_at_denied_failclosed" {
  # BP-017 / BC-3.01.001 PC#2 step (4b) / F5 MEDIUM
  # Marker with malformed expires_at_utc ("9999-99-99T99:99:99Z") → must DENY fail-closed.
  # Malformed non-ISO-8601 values compare lexicographically greater than real timestamps;
  # without format validation they bypass the TTL check → ALLOW (security bypass).
  # ISO-8601 format validation must reject before comparison.
  # Current .ps1: no marker logic → deny from write-block → correct outcome, wrong mechanism.
  # Post-port: deny via format-validation fail-closed path.
  require_pwsh
  local now
  now=$(_now_ts)
  _write_marker "link-bp017-malf.marker.json" \
    "{\"marker_id\":\"m-bp017-malf\",\"ticket_id\":\"SEC-111\",\"org_slug\":\"test\",\"authorized_operations\":[\"link\"],\"command_pattern\":\"^jr (--output json )?issue link SEC-111 SEC-209( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"9999-99-99T99:99:99Z\"}"
  _run_ps1_hook "jr issue link SEC-111 SEC-209"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
  [[ "$output" == *"review approval"* ]]
}

# ── BP-018: audit record written on allow (VP-HOOK-024 / Invariant #2) ──────────

@test "test_BC_3_01_001_BP018_ps1_VP024_audit_record_written_on_link_allow" {
  # BP-018 / BC-3.01.001 Invariant #2 / VP-HOOK-024 / ADV-F2-013
  # A valid ["link"] marker consumed → ALLOW and audit record written to audit.log.
  # Audit line must contain: MARKER_USED, op=, ticket=, org=, command_b64=.
  # Current .ps1: no marker logic, no audit write → RED in CI.
  require_pwsh
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-bp018-audit.marker.json" \
    "{\"marker_id\":\"m-bp018-audit\",\"ticket_id\":\"SEC-120\",\"org_slug\":\"testorg\",\"authorized_operations\":[\"link\"],\"command_pattern\":\"^jr (--output json )?issue link SEC-120 SEC-210( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"
  _run_ps1_hook "jr issue link SEC-120 SEC-210"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
  [ -f "${MARKER_DIR}/audit.log" ]
  grep -q "MARKER_USED" "${MARKER_DIR}/audit.log"
  grep -q " op="          "${MARKER_DIR}/audit.log"
  grep -q " ticket="      "${MARKER_DIR}/audit.log"
  grep -q " org="         "${MARKER_DIR}/audit.log"
  grep -q " command_b64=" "${MARKER_DIR}/audit.log"
}

# ── F-1: BP-019 — uppercase LINK subcommand with marker → ps1 must DENY ──────────

@test "test_BC_3_01_001_F1_BP019_ps1_uppercase_LINK_subcommand_with_marker_denied" {
  # F-1 / BC-3.01.001 STEP-2 write-block / SM-57 / case-sensitivity divergence (pass-2)
  #
  # "jr issue LINK SEC-1 SEC-2" (uppercase subcommand) WITH a valid ["link"] marker.
  # sh: case-sensitive write-block (*"jr issue link "*) misses uppercase LINK →
  #     falls through read-only list → fail-closed → DENY.
  # ps1 SHOULD deny to match sh, but currently:
  #   -like operator is case-insensitive → "LINK" matches "link" → write-block fires →
  #   marker consumed (STEP-5 case-insensitive match passes) → ALLOW (BUG).
  # This test asserts ps1 DENIES uppercase command → RED in CI until ps1 uses -clike/-cmatch.
  require_pwsh
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-f1-bp019.marker.json" \
    "{\"marker_id\":\"m-f1-bp019\",\"ticket_id\":\"SEC-1\",\"org_slug\":\"test\",\"authorized_operations\":[\"link\"],\"command_pattern\":\"^jr issue link SEC-1 SEC-2( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"
  _run_ps1_hook "jr issue LINK SEC-1 SEC-2"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

# ── F-2: BP-020 — ps1 STEP-6 isolation: ["comment"] flexible pattern + link cmd ──

@test "test_BC_3_01_001_F2_BP020_ps1_step6_comment_flexible_pattern_link_cmd_denied_and_link_marker_allows" {
  # F-2 / BC-3.01.001 STEP-6 exact-type / SM-58 ps1 analog / mutation-coverage gap (pass-2)
  #
  # SM-58 kill vector for ps1: a ["comment"] marker whose command_pattern DELIBERATELY
  # matches "jr issue link SEC-42 SEC-99" at STEP 5 (flexible (link|comment) pattern).
  # Correct ps1 STEP-6: cmdType='link', opVal='comment' → type mismatch → CONTINUE → DENY.
  # Mutation deleting the ps1 STEP-6 link block: STEP-5 passes, no rejection → ALLOW (wrong).
  #
  # Part A: ["comment"] marker with flexible pattern + link cmd → DENY via STEP-6.
  # Part B: correct ["link"] marker with same pattern + link cmd → ALLOW (step-5-passing path).
  #
  # Both parts GREEN with correct ps1 STEP-6. Part A is RED only if STEP-6 is deleted.
  require_pwsh
  local now future deny_output deny_status
  now=$(_now_ts); future=$(_future_ts)

  # Part A: ["comment"] marker, flexible step-5-passing pattern → DENY via STEP-6 type mismatch
  _write_marker "comment-f2-bp020.marker.json" \
    "{\"marker_id\":\"m-f2-bp020-comment\",\"ticket_id\":\"SEC-42\",\"org_slug\":\"test\",\"authorized_operations\":[\"comment\"],\"command_pattern\":\"^jr .*issue (link|comment) SEC-42( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"
  _run_ps1_hook "jr issue link SEC-42 SEC-99"
  deny_output="$output"
  deny_status="$status"

  # Part B: correct ["link"] marker with same flexible pattern + link cmd → ALLOW
  rm -f "${MARKER_DIR}/comment-f2-bp020.marker.json"
  _write_marker "link-f2-bp020.marker.json" \
    "{\"marker_id\":\"m-f2-bp020-link\",\"ticket_id\":\"SEC-42\",\"org_slug\":\"test\",\"authorized_operations\":[\"link\"],\"command_pattern\":\"^jr .*issue (link|comment) SEC-42( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"
  _run_ps1_hook "jr issue link SEC-42 SEC-99"

  # Assertions
  [ "${deny_status}" -eq 0 ]
  [[ "${deny_output}" == *'"permissionDecision":"deny"'* ]]
  [[ "${deny_output}" == *"review approval"* ]]
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

# ── F-2: BP-021 — ps1 STEP-6 isolation: ["link"] flexible pattern + close cmd ────

@test "test_BC_3_01_001_F2_BP021_ps1_step6_link_marker_flexible_pattern_close_cmd_denied_and_close_marker_allows" {
  # F-2 / BC-3.01.001 STEP-6 exact-type / AC-006 ps1 analog / mutation-coverage gap (pass-2)
  #
  # SM-58 kill vector (close direction) for ps1: a ["link"] marker whose command_pattern
  # DELIBERATELY matches "jr issue move SEC-42 Done" at STEP 5 (flexible (link|move) pattern).
  # Correct ps1 STEP-6: cmdType='close', opVal='link' → type mismatch → CONTINUE → DENY.
  # Mutation deleting the ps1 STEP-6 close block: STEP-5 passes, no rejection → ALLOW (wrong).
  #
  # Part A: ["link"] marker with (link|move) flexible pattern + close cmd → DENY via STEP-6.
  # Part B: correct ["close"] marker with same pattern + close cmd → ALLOW (confirms path).
  #
  # Both parts GREEN with correct ps1 STEP-6. Part A is RED only if STEP-6 is deleted.
  require_pwsh
  local now future deny_output deny_status
  now=$(_now_ts); future=$(_future_ts)

  # Part A: ["link"] marker, flexible (link|move) step-5-passing pattern → DENY via STEP-6
  _write_marker "link-f2-bp021.marker.json" \
    "{\"marker_id\":\"m-f2-bp021-link\",\"ticket_id\":\"SEC-42\",\"org_slug\":\"test\",\"authorized_operations\":[\"link\"],\"command_pattern\":\"^jr .*issue (link|move) SEC-42( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"
  _run_ps1_hook "jr issue move SEC-42 Done"
  deny_output="$output"
  deny_status="$status"

  # Part B: correct ["close"] marker with same flexible pattern + close cmd → ALLOW
  rm -f "${MARKER_DIR}/link-f2-bp021.marker.json"
  _write_marker "close-f2-bp021.marker.json" \
    "{\"marker_id\":\"m-f2-bp021-close\",\"ticket_id\":\"SEC-42\",\"org_slug\":\"test\",\"authorized_operations\":[\"close\"],\"command_pattern\":\"^jr .*issue (link|move) SEC-42( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"
  _run_ps1_hook "jr issue move SEC-42 Done"

  # Assertions
  [ "${deny_status}" -eq 0 ]
  [[ "${deny_output}" == *'"permissionDecision":"deny"'* ]]
  [[ "${deny_output}" == *"review approval"* ]]
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

# ── pass-4 F1 BP-022: scalar-string authorized_operations → DENY (MEDIUM fail-open) ──

@test "test_BC_3_01_001_pass4_BP022_ps1_scalar_string_authorized_operations_denied" {
  # pass-4 / BC-3.01.001 STEP-6 / Finding-1 MEDIUM (fail-open)
  #
  # Marker whose authorized_operations field is a JSON STRING "link" rather than
  # the required array ["link"].
  #
  # ps1 STEP-6 (require-review.ps1:237): @($mj.authorized_operations) wraps the
  # string into a 1-element PowerShell array → opsCount=1, opVal="link" → the
  # exact-type check (opsCount -eq 1 -and opVal -ceq 'link') passes → ALLOW (BUG).
  #
  # sh (require-review.sh:254-257): jq '.authorized_operations | length' on a
  # JSON string returns the character count (4 for "link"), not 1 → ops_count=4;
  # jq '.authorized_operations[0]' on a string returns null/empty → op_val="".
  # Guard [[ ops_count -eq 1 ]] fails → marker skipped → DENY (correct).
  #
  # This test asserts ps1 DENIES a link command paired with a scalar-string
  # authorized_operations marker → RED in CI until ps1 validates that
  # authorized_operations is a JSON array (not a scalar string) before STEP-6.
  require_pwsh
  local now future
  now=$(_now_ts); future=$(_future_ts)
  _write_marker "link-bp022-scalar.marker.json" \
    "{\"marker_id\":\"m-bp022-scalar\",\"ticket_id\":\"SEC-130\",\"org_slug\":\"test\",\"authorized_operations\":\"link\",\"command_pattern\":\"^jr (--output json )?issue link SEC-130 SEC-210( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}"
  _run_ps1_hook "jr issue link SEC-130 SEC-210"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

# ── pass-4 F2 BP-023: Unicode digit in expires_at_utc → DENY (MINOR lax ISO) ─────

@test "test_BC_3_01_001_pass4_BP023_ps1_unicode_digit_expires_at_utc_rejected" {
  # pass-4 / BC-3.01.001 STEP-4b / Finding-2 MINOR (lax ISO)
  #
  # Marker whose expires_at_utc contains a Unicode (non-ASCII) digit character in
  # the year position via JSON Unicode escape \uFF12 (U+FF12 FULLWIDTH DIGIT TWO,
  # "２").  The JSON value stored in the marker file is "\uFF12100-01-01T00:00:00Z"
  # which both jq and ConvertFrom-Json decode to the string "２100-01-01T00:00:00Z".
  #
  # ps1 Test-Iso8601Utc (require-review.ps1:43): regex uses .NET \d which matches
  # any Unicode decimal digit including U+FF12 → returns $true → expires_at_utc
  # passes format validation.  Ordinal comparison: "２100..." > current date
  # (U+FF12=65298 > U+0032=50) → marker not expired → all other checks pass → ALLOW (BUG).
  #
  # sh _is_iso8601_utc (require-review.sh:153): uses POSIX [0-9] which is ASCII-only;
  # "２100-01-01T00:00:00Z" does not match ^[0-9]{4}-... → validation fails →
  # marker skipped → DENY (correct, fail-closed).
  #
  # This test asserts ps1 DENIES (skips) the marker → RED in CI until ps1 uses
  # an ASCII-only digit class ([0-9] or (?-u:\d)) in Test-Iso8601Utc, preventing
  # Unicode digit bypass of timestamp format validation.
  require_pwsh
  local now
  now=$(_now_ts)
  # \uFF12 is a literal JSON Unicode escape — bash does NOT interpret \u, so the
  # escape is written as-is to the file.  jq and ConvertFrom-Json both decode it
  # to the fullwidth digit "２" (U+FF12).  The year field becomes "２100" which
  # satisfies .NET \d{4} but NOT sh's [0-9]{4}.
  _write_marker "link-bp023-unicode.marker.json" \
    "{\"marker_id\":\"m-bp023-unicode\",\"ticket_id\":\"SEC-131\",\"org_slug\":\"test\",\"authorized_operations\":[\"link\"],\"command_pattern\":\"^jr (--output json )?issue link SEC-131 SEC-211( |$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"\uFF12100-01-01T00:00:00Z\"}"
  _run_ps1_hook "jr issue link SEC-131 SEC-211"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

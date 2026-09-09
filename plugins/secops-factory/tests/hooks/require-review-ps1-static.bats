#!/usr/bin/env bats
# require-review-ps1-static.bats
#
# BC-3.01.001 v1.25 — Tier A: Static structural-parity checks for require-review.ps1
#
# These tests run locally WITHOUT pwsh. They inspect require-review.ps1 source text
# to verify the security-critical surface required by BC-3.01.001 v1.25 is present
# before any behavioral tests run. Finding F3 (human ruling: FULL cross-platform
# parity in scope for S-3.01) requires the .ps1 to implement the same security
# controls as require-review.sh — verified here structurally.
#
# Every test is RED against the current pre-port .ps1 and GREEN after the port.
#
# Traceability:
#   SP-001..003  BC-3.01.001 PC#2 write-block / D-020 / ADV-F2-P18-001 / SM-57
#   SP-004       BC-3.01.001 PC#2 step (6a) / P9-001 / P8-002 / P7-005 / F1 CRITICAL
#   SP-005..012  BC-3.01.001 PC#2 step (5) / F2 MAJOR
#   SP-013..014  BC-3.01.001 PC#2 step (3+4b) / F5 MEDIUM
#   SP-015       BC-3.01.001 Invariant #2 / VP-HOOK-024 / F4 MEDIUM
#   SP-016..018  BC-3.01.001 PC#2 step (6) / D-020 / D-021 / AC-005 / AC-006
#
# Test naming: test_BC_S_SS_NNN_<tier>_<finding>_<assertion>

PLUGIN_ROOT="${BATS_TEST_DIRNAME}/../.."
PS1_FILE="${PLUGIN_ROOT}/hooks/require-review.ps1"

# ── SP-001..003: write-block 12-entry check ────────────────────────────────────
# The $blocked array must have 12 entries: 10 base + 2 D-020 link entries.
# Current .ps1 has 10 entries (missing 'jr issue link ' and '--output json issue link ').

@test "test_BC_3_01_001_SP001_F3_ps1_write_block_link_plain_form_present" {
  # SP-001 / D-020 / ADV-F2-P18-001 / SM-57 kill
  # 'jr issue link ' (trailing-space guard) must appear in the $blocked array.
  # Prevents link commands from reaching the fail-closed path instead of the
  # write-block deny path — required for write-block entry count = 12 (BC PC#2).
  # ABSENT in current .ps1 (10-entry $blocked) → RED Gate.
  [ -f "$PS1_FILE" ]
  grep -q "'jr issue link '" "$PS1_FILE"
}

@test "test_BC_3_01_001_SP002_F3_ps1_write_block_link_json_form_present" {
  # SP-002 / D-020 / ADV-F2-P18-001
  # '--output json issue link ' (trailing-space guard) must appear in $blocked.
  # "jr issue link" is NOT a substring of "--output json issue link"; both forms
  # need explicit entries (BC-3.01.001 Invariant #4).
  # ABSENT in current .ps1 → RED Gate.
  [ -f "$PS1_FILE" ]
  grep -q "'--output json issue link '" "$PS1_FILE"
}

@test "test_BC_3_01_001_SP003_F3_ps1_write_block_all_12_entries_present" {
  # SP-003 / BC-3.01.001 PC#2 write-block count / D-020
  # All 12 write-block entries must be present (10 base + 2 D-020 link entries).
  # Fails if ANY entry is missing — in particular the two link entries are absent now.
  [ -f "$PS1_FILE" ]
  grep -q "'jr issue comment '"           "$PS1_FILE"
  grep -q "'jr issue edit'"               "$PS1_FILE"
  grep -q "'jr issue move'"               "$PS1_FILE"
  grep -q "'jr issue assign'"             "$PS1_FILE"
  grep -q "'jr issue create'"             "$PS1_FILE"
  grep -q "'jr issue link '"              "$PS1_FILE"
  grep -q "'--output json issue comment '" "$PS1_FILE"
  grep -q "'--output json issue edit'"    "$PS1_FILE"
  grep -q "'--output json issue move'"    "$PS1_FILE"
  grep -q "'--output json issue assign'"  "$PS1_FILE"
  grep -q "'--output json issue create'"  "$PS1_FILE"
  grep -q "'--output json issue link '"   "$PS1_FILE"
}

# ── SP-004: structural label-check equivalent ──────────────────────────────────
# BC-3.01.001 PC#2 step (6a): a quote-aware, backslash-escape-aware, whitespace-
# collapsing tokenizer (structural_label_check) is required for create anti-fungibility.
# Naive raw substring matching is bypassed by SM-40 (double-space), SM-42 (quoted
# value), SM-43 (tab). The tokenizer must track UNQUOTED / IN_SINGLE / IN_DOUBLE
# states. EC-024 false-deny prevention also requires this tokenizer.

@test "test_BC_3_01_001_SP004_F1_ps1_structural_label_check_equivalent_present" {
  # SP-004 / BC-3.01.001 PC#2 step (6a) / P9-001 / P8-002 / P7-005 / F1 CRITICAL
  # The .ps1 must contain a quote-aware tokenizer state machine — evidence of the
  # states UNQUOTED, IN_SINGLE, IN_DOUBLE (or equivalent) in the label check function.
  # A naive substring check is security-insufficient; the tokenizer is the
  # single enforcement point for create anti-fungibility (P8-003).
  # ABSENT in current .ps1 — no structural label check function exists → RED Gate.
  [ -f "$PS1_FILE" ]
  grep -qE "(UNQUOTED|IN_SINGLE|IN_DOUBLE|Invoke-StructuralLabel|Test-StructuralLabel)" "$PS1_FILE"
}

# ── SP-005..012: consumer-side metachar guard ──────────────────────────────────
# BC-3.01.001 PC#2 step (5) / F2 MAJOR: the consumer must reject commands containing
# any shell metachar before evaluating markers, preventing tail-injection bypasses.
# Required chars (exact set from .sh): ; | & backtick $( > < \n
# > and < also cover >( and <( process substitution (same guard).
# NONE of these guards exist in the current .ps1 → RED Gate for all SP-005..012.

@test "test_BC_3_01_001_SP005_F2_ps1_metachar_guard_semicolon" {
  # SP-005 / BC-3.01.001 PC#2 step (5) / F2 MAJOR
  # Guard must reject commands containing ; (semicolon chain injection vector).
  # Evidence: ';' appears as a single-quoted string literal in a Contains/conditional.
  [ -f "$PS1_FILE" ]
  grep -q "';'" "$PS1_FILE"
}

@test "test_BC_3_01_001_SP006_F2_ps1_metachar_guard_pipe" {
  # SP-006 / BC-3.01.001 PC#2 step (5) / F2 MAJOR
  # Guard must reject commands containing | (pipeline injection vector).
  # Evidence: '|' as a single-quoted string literal in guard context.
  [ -f "$PS1_FILE" ]
  grep -q "'|'" "$PS1_FILE"
}

@test "test_BC_3_01_001_SP007_F2_ps1_metachar_guard_ampersand" {
  # SP-007 / BC-3.01.001 PC#2 step (5) / F2 MAJOR
  # Guard must reject commands containing & (background/and-chain injection vector).
  # Evidence: '&' as a single-quoted string literal in guard context.
  [ -f "$PS1_FILE" ]
  grep -q "'&'" "$PS1_FILE"
}

@test "test_BC_3_01_001_SP008_F2_ps1_metachar_guard_backtick" {
  # SP-008 / BC-3.01.001 PC#2 step (5) / F2 MAJOR
  # Guard must reject commands containing backtick (shell command substitution injection).
  # PS1 uses backtick as escape char; the guard must treat it as a rejected LITERAL char.
  # Evidence: backtick appears as a single-quoted string literal (the char is not special
  # inside PS1 single-quoted strings).
  # Pattern constructed via printf to avoid bash backtick special-char handling.
  [ -f "$PS1_FILE" ]
  local bt
  bt=$(printf '\x60')
  grep -q "'${bt}'" "$PS1_FILE"
}

@test "test_BC_3_01_001_SP009_F2_ps1_metachar_guard_dollar_paren" {
  # SP-009 / BC-3.01.001 PC#2 step (5) / F2 MAJOR
  # Guard must reject commands containing '$(' (subshell expansion injection vector).
  # PS1 guards against this by checking the two-character sequence as a string literal.
  # Pattern constructed character by character to avoid bash command substitution.
  [ -f "$PS1_FILE" ]
  local dp
  dp=$(printf '%s%s%s%s' "'" '$' '(' "'")
  grep -qF "$dp" "$PS1_FILE"
}

@test "test_BC_3_01_001_SP010_F2_ps1_metachar_guard_greater_than" {
  # SP-010 / BC-3.01.001 PC#2 step (5) / F2 MAJOR (F2 addition)
  # Guard must reject commands containing > (shell redirect / >( process substitution).
  # Evidence: '>' as single-quoted string literal in guard context.
  [ -f "$PS1_FILE" ]
  grep -q "'>'" "$PS1_FILE"
}

@test "test_BC_3_01_001_SP011_F2_ps1_metachar_guard_less_than" {
  # SP-011 / BC-3.01.001 PC#2 step (5) / F2 MAJOR (F2 addition)
  # Guard must reject commands containing < (shell redirect / <( process substitution).
  # Evidence: '<' as single-quoted string literal in guard context.
  [ -f "$PS1_FILE" ]
  grep -q "'<'" "$PS1_FILE"
}

@test "test_BC_3_01_001_SP012_F2_ps1_metachar_guard_newline" {
  # SP-012 / BC-3.01.001 PC#2 step (5) / F2 MAJOR (F2 addition)
  # Guard must reject commands containing a newline character (newline injection vector).
  # PS1 canonical form: "`n" in a double-quoted string (backtick-n), or [char]10.
  # Pattern uses printf \x60 to obtain backtick without bash command-substitution risk.
  [ -f "$PS1_FILE" ]
  local nl_pat
  nl_pat=$(printf '"\x60n"')
  grep -qF "$nl_pat" "$PS1_FILE" || grep -qE '\[char\]10' "$PS1_FILE"
}

# ── SP-013..014: ISO-8601 timestamp validation ─────────────────────────────────
# BC-3.01.001 PC#2 step (3) + step (4b) / F5 MEDIUM:
# Both issued_at_utc and expires_at_utc must be validated against ISO-8601 UTC
# format BEFORE lexicographic comparison. Malformed values ("9999-99-99T99:99:99Z",
# "zzz") compare lexicographically greater than real timestamps, bypassing TTL check.
# Fail-closed requires format rejection before comparison (not after).

@test "test_BC_3_01_001_SP013_F5_ps1_iso8601_validation_function_present" {
  # SP-013 / BC-3.01.001 PC#2 step (3) / F5 MEDIUM
  # A PowerShell function to validate ISO-8601 UTC timestamps must exist.
  # Expected form: function Test-Iso8601Utc { param([string]$Ts); $Ts -match '^\d{4}-...' }
  # or equivalent. Used before lexicographic comparison of issued_at_utc AND expires_at_utc.
  # ABSENT in current .ps1 → RED Gate.
  [ -f "$PS1_FILE" ]
  grep -qE "(function\s+Test-Iso8601|function\s+Invoke-Iso8601|function\s+[A-Z][a-z]+-Iso8601)" "$PS1_FILE"
}

@test "test_BC_3_01_001_SP014_F5_ps1_iso8601_validation_applied_to_expires_at" {
  # SP-014 / BC-3.01.001 PC#2 step (4b) / F5 MEDIUM
  # The ISO-8601 validation must be applied specifically to expires_at_utc before
  # the TTL comparison (malformed expires bypasses TTL without prior validation).
  # The validation function must be called (or the regex applied) for expires_at_utc.
  # ABSENT in current .ps1 → RED Gate.
  [ -f "$PS1_FILE" ]
  # Evidence: expires_at_utc is checked via the validation function or a regex pattern
  grep -qE "(expires_at.*Test-Iso8601|Test-Iso8601.*expires_at|expires_at_utc.*-match.*\[0-9\])" "$PS1_FILE"
}

# ── SP-015: audit write fail-closed ───────────────────────────────────────────
# BC-3.01.001 Invariant #2 / VP-HOOK-024 / F4 MEDIUM:
# A complete audit record must be written to ${CLAUDE_PLUGIN_DATA}/markers/audit.log
# on every allow. The audit write must fail CLOSED: if the write fails, deny rather
# than swallow the error and allow (current .sh uses "|| return 1").

@test "test_BC_3_01_001_SP015_F4_ps1_audit_write_failclosed_present" {
  # SP-015 / BC-3.01.001 Invariant #2 / VP-HOOK-024 / F4 MEDIUM
  # The .ps1 must contain:
  #   1. A write to audit.log containing a MARKER_USED record (with all fields)
  #   2. Fail-closed on write failure (no | Out-Null or try/catch-swallow after write)
  # ABSENT in current .ps1 (no audit logic at all) → RED Gate.
  [ -f "$PS1_FILE" ]
  grep -q "audit.log" "$PS1_FILE"
  grep -q "MARKER_USED" "$PS1_FILE"
}

# ── SP-016..018: STEP-6 exact-type matching ────────────────────────────────────
# BC-3.01.001 PC#2 step (6) / D-020 / D-021 / AC-005 / AC-006:
# Each command type must accept ONLY the corresponding marker type:
#   link commands  → only ["link"] markers
#   close commands → only ["close"] markers
#   create commands → only ["create"] or ["create-review"] markers
# This prevents cross-type marker reuse (comment/create cannot authorize link/close).

@test "test_BC_3_01_001_SP016_step6_ps1_link_exact_type_matching_present" {
  # SP-016 / BC-3.01.001 PC#2 step (6) / D-020 / AC-005
  # The .ps1 must check authorized_operations[0] == "link" for link commands.
  # ABSENT in current .ps1 (no marker validation) → RED Gate.
  [ -f "$PS1_FILE" ]
  grep -q "authorized_operations" "$PS1_FILE"
  grep -qE '"link"' "$PS1_FILE"
}

@test "test_BC_3_01_001_SP017_step6_ps1_close_exact_type_matching_present" {
  # SP-017 / BC-3.01.001 PC#2 step (6) / D-021 / AC-006 / SM-58 kill
  # The .ps1 must check authorized_operations[0] == "close" for close commands.
  # ABSENT in current .ps1 → RED Gate.
  [ -f "$PS1_FILE" ]
  grep -qE '"close"' "$PS1_FILE"
}

@test "test_BC_3_01_001_SP018_step6_ps1_create_exact_type_matching_and_create_review_present" {
  # SP-018 / BC-3.01.001 PC#2 step (6) + step (6a) / C1 / SM-37 / D-DEC-012
  # The .ps1 must check authorized_operations[0] == "create" for regular create,
  # and must also accept "create-review" for review-labeled creates (D-DEC-012).
  # Step (6a) must use the structural label check to distinguish them.
  # ABSENT in current .ps1 → RED Gate.
  [ -f "$PS1_FILE" ]
  grep -qE '"create"' "$PS1_FILE"
  grep -q "create-review" "$PS1_FILE"
}

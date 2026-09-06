#!/usr/bin/env bats
# tests/skills/activate-close-state.bats
# S-6.03 — activate skill: CLOSE_STATE_ALLOWLIST + jira_project_key charset setup-time validation
# BC-6.01.001 v1.8  PC#12 (jira_project_key charset) + PC#13 (CLOSE_STATE_ALLOWLIST)
# ACs covered: AC-001..AC-008  (EC-001..EC-004, EC-013..EC-015)
# VPs covered: VP-SKILL-051 (prism version gate), VP-SKILL-076 activate leg
#
# Regression VPs VP-SKILL-021..025 are already exercised in ../skills.bats.
# They are NOT duplicated here.
#
# ALL tests in this file MUST FAIL (Red Gate) until S-6.03 implementation adds
# the required content to skills/activate/SKILL.md and creates
# hooks/prism-version-check.sh.

PLUGIN_ROOT="${BATS_TEST_DIRNAME}/../.."
SKILL="${PLUGIN_ROOT}/skills/activate/SKILL.md"
# prism-version-check.sh: helper script created by S-6.03 implementation.
PRISM_VERSION_CHECK="${PLUGIN_ROOT}/hooks/prism-version-check.sh"

# ─── AC-001 | BC-6.01.001 PC#13 ─ CLOSE_STATE_ALLOWLIST constant + config key ───

@test "test_BC_6_01_001_close_state_allowlist_constant_declared (AC-001, AC-003, AC-006)" {
    # BC-6.01.001 PC#13: activate MUST define the named constant CLOSE_STATE_ALLOWLIST.
    # The constant name must appear in SKILL.md so reviewers can verify it is CONFIG-side
    # only (D-021 — not verdict-influenceable at runtime). Fail-early at setup time (P18-005).
    # Mutant killed: allowlist-constant-absent → AC-006 hardcoded-set invariant violated.
    grep -qF "CLOSE_STATE_ALLOWLIST" "$SKILL"
}

@test "test_BC_6_01_001_close_state_config_key_present (AC-001)" {
    # BC-6.01.001 PC#13: activate prompts for and persists 'jira_close_state' as a
    # named config key. Without this key, disposition-guard cannot interpolate the close
    # state into the marker command_pattern — every FP/BTP auto-close verdict
    # would produce a CLOSE-STATE-DENY silently (livelock class).
    grep -qF "jira_close_state" "$SKILL"
}

# ─── AC-002 | BC-6.01.001 EC-015 ─ invalid close state error message ────────────

@test "test_BC_6_01_001_invalid_close_state_error_prefix (AC-002, EC-015)" {
    # BC-6.01.001 EC-015: user-facing error for jira_close_state outside the allowlist
    # must begin with the exact prefix "Invalid Jira close state" (BC canonical text).
    # No partial state may be written when this error fires.
    grep -qF "Invalid Jira close state" "$SKILL"
}

@test "test_BC_6_01_001_invalid_close_state_error_allowed_values (AC-002, EC-015)" {
    # BC-6.01.001 EC-015: error message must include "allowed values are Done, Closed, Resolved"
    # verbatim — this is the canonical error suffix from the BC that guides the operator.
    grep -qF "allowed values are Done, Closed, Resolved" "$SKILL"
}

# ─── AC-003 | BC-6.01.001 invariant ─ setup-time only, D-021 ─────────────────────

@test "test_BC_6_01_001_invariant_d021_config_side_reference (AC-003, AC-006)" {
    # BC-6.01.001 invariant + D-021: SKILL.md must document that jira_close_state is
    # "NOT verdict-influenceable" (exact BC wording from PC#13 security constraint).
    # This phrase must appear in the implementation prose, NOT just in a stub comment,
    # so reviewers can permanently verify the LLM injection surface is closed.
    # The current stub comment contains "D-021" but not this discriminating phrase.
    grep -qF "NOT verdict-influenceable" "$SKILL"
}

# ─── AC-004 | BC-6.01.001 PC#13 ─ complete allowlist set declared ────────────────

@test "test_BC_6_01_001_allowlist_complete_set_declared (AC-004, EC-001, EC-002, EC-003)" {
    # BC-6.01.001 PC#13: the exact allowlist set {"Done", "Closed", "Resolved"} must appear
    # verbatim in SKILL.md matching the canonical BC set notation.
    # EC-001: "Done" is valid; EC-002: "Closed" is valid; EC-003: "Resolved" is valid.
    # Mutant killed: incomplete-set → one valid value missing → operator cannot use it.
    grep -qF '{"Done", "Closed", "Resolved"}' "$SKILL"
}

# ─── AC-005 | BC-6.01.001 invariant ─ case-sensitive comparison ──────────────────

@test "test_BC_6_01_001_invariant_case_sensitive_match (AC-005, EC-004)" {
    # BC-6.01.001 invariant: allowlist check is case-sensitive.
    # "done", "DONE", "closed" are NOT valid — only exact title-case strings.
    # SKILL.md must document case-sensitivity to prevent implementers from adding
    # a case-insensitive comparison that broadens the injection surface.
    grep -qiE "case.?sensitive" "$SKILL"
}

# ─── AC-007 | BC-6.01.001 PC#12/EC-014 ─ jira_project_key charset ─ VP-SKILL-076 ──

@test "test_BC_6_01_001_project_key_config_key_present (AC-007, VP-SKILL-076 activate leg)" {
    # BC-6.01.001 PC#12 (P9-008/P13-002): activate prompts for and persists 'jira_project_key'.
    # VP-SKILL-076 activate leg — SM-54 kill: activate-side rejection of non-conformant key.
    # Without jira_project_key, every create-review marker DENIES at disposition-guard STEP 3
    # (HARD-FLOOR-UNBINDABLE livelock on every hard-floor verdict).
    grep -qF "jira_project_key" "$SKILL"
}

@test "test_BC_6_01_001_project_key_charset_regex_present (AC-007, EC-014, VP-SKILL-076)" {
    # BC-6.01.001 PC#12/P13-002 CRITICAL: jira_project_key MUST match ^[A-Z][A-Z0-9]+$ exactly.
    # The regex must appear verbatim in SKILL.md — it is the same pattern applied at every
    # marker issuance site in disposition-guard (BC-3.03.001 P12-001/O7).
    # Catching at setup time prevents PROJECT-KEY-CHARSET-DENY livelock (D-DEC-008).
    grep -qF '^[A-Z][A-Z0-9]+$' "$SKILL"
}

@test "test_BC_6_01_001_project_key_invalid_error_prefix (AC-007, EC-014)" {
    # BC-6.01.001 EC-014: user-facing error for a non-conformant jira_project_key must
    # begin "Invalid Jira project key" (BC canonical prefix).
    # Activation must refuse to complete; no partial state written (fail-early).
    grep -qF "Invalid Jira project key" "$SKILL"
}

@test "test_BC_6_01_001_project_key_no_hyphens_constraint_documented (AC-007, EC-014)" {
    # BC-6.01.001 EC-014: error message must state "no hyphens" so the operator
    # understands why PRISM-DEMO is rejected and can supply the conformant PRISMDEMO
    # (D-DEC-008 architectural constraint).
    grep -qF "no hyphens" "$SKILL"
}

@test "test_BC_6_01_001_project_key_hyphen_free_example_documented (AC-007, EC-013)" {
    # BC-6.01.001 EC-013 (updated v1.7): activate must show only hyphen-free examples.
    # PRISMDEMO must appear as a canonical example key (replaces the invalid PRISM-DEMO
    # that was removed in v1.7 to stop steering operators toward non-conformant keys).
    grep -qF "PRISMDEMO" "$SKILL"
}

# ─── AC-008 structural | BC-6.01.001 PC#8-9 ─ VP-SKILL-051 prism version gate ───
# These structural tests verify that SKILL.md documents the prism version gate.

@test "test_BC_6_01_001_prism_version_minimum_documented (AC-008, VP-SKILL-051)" {
    # BC-6.01.001 PC#8: activate compares prism --version output against minimum 1.0.0-rc.1.
    # Version gate string must appear in SKILL.md as the canonical gate value.
    # VP-SKILL-051 FINALIZED F1 (not new this cycle; vd:757).
    grep -qF "1.0.0-rc.1" "$SKILL"
}

@test "test_BC_6_01_001_prism_version_subprocess_call_documented (AC-008, VP-SKILL-051)" {
    # BC-6.01.001 PC#8: version check uses 'prism --version' subprocess, NOT MCP ping.
    # This distinction is critical: MCP is not yet configured at version-check time.
    grep -qF "prism --version" "$SKILL"
}

@test "test_BC_6_01_001_prism_version_gate_halt_message_documented (AC-008a, VP-SKILL-051)" {
    # BC-6.01.001 PC#8/EC-009: below-minimum halt message must include
    # "does not meet minimum requirement" — verbatim from the BC error specification.
    grep -qF "does not meet minimum requirement" "$SKILL"
}

@test "test_BC_6_01_001_prism_dual_mcp_write_prism_mcp_json_documented (AC-008b, AC-008c, VP-SKILL-051)" {
    # BC-6.01.001 PC#9: after version gate passes, activate writes prism.mcp.json
    # (D-DEC-003 cron/headless config). Both settings.json and prism.mcp.json must be written
    # (dual MCP write). The filename must appear in SKILL.md.
    grep -qF "prism.mcp.json" "$SKILL"
}

@test "test_BC_6_01_001_prism_rust_log_off_invariant_documented (VP-SKILL-051, BC-6.01.001 invariant #5)" {
    # BC-6.01.001 Invariant #5: RUST_LOG=off MUST be injected in BOTH MCP config locations
    # (settings.json and prism.mcp.json). Prevents prism stderr log lines from being
    # interpreted as framing by Claude Code's stdio MCP transport (framing corruption).
    grep -qF "RUST_LOG" "$SKILL"
}

# ─── AC-008 B-INT | VP-SKILL-051 ─ prism-version-check.sh behavioral vectors ───
# These behavioral integration tests exercise hooks/prism-version-check.sh using a
# mocked prism binary. The script does not exist until S-6.03 implementation creates it.
# All three tests MUST FAIL (Red Gate) until the script is created.
#
# Test vectors mirror BC-6.01.001 PC#8 + verification-delta §5 vd:1508
# "version below/at/above" triplet.

@test "test_BC_6_01_001_prism_version_check_script_below_minimum (AC-008a, VP-SKILL-051)" {
    # BC-6.01.001 PC#8/EC-009: prism 0.9.9 < 1.0.0-rc.1 → non-zero exit + version-gate error.
    # Discriminating kill: script must exit non-zero AND emit the BC-specified halt message.
    # settings.json and prism.mcp.json must NOT be written (verified by absence of output
    # indicating successful write).
    local tmpdir
    tmpdir="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nif [ "$1" = "--version" ]; then echo "prism 0.9.9"; fi\n' \
        > "$tmpdir/prism"
    chmod +x "$tmpdir/prism"
    run env PATH="$tmpdir:$PATH" bash "$PRISM_VERSION_CHECK" 2>&1
    rm -rf "$tmpdir"
    # F5 tightening: require exact exit code 1 (not just non-zero; exit 2 would indicate
    # a parse error, not a version-gate halt) and the BC-canonical halt phrase verbatim.
    # The loose '|| *"1.0.0-rc.1"*' fallback was removed: that pattern is also satisfied by
    # the success message, masking a hypothetical bug where the gate emits the wrong output.
    [ "$status" -eq 1 ]
    [[ "$output" == *"does not meet minimum requirement"* ]]
}

@test "test_BC_6_01_001_prism_version_check_script_at_minimum (AC-008b, VP-SKILL-051)" {
    # BC-6.01.001 PC#8: prism exactly 1.0.0-rc.1 meets the version gate → exit 0,
    # allowing the dual MCP write to proceed.
    # Boundary vector: the gate is >=, so the exact minimum must pass.
    local tmpdir
    tmpdir="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nif [ "$1" = "--version" ]; then echo "prism 1.0.0-rc.1"; fi\n' \
        > "$tmpdir/prism"
    chmod +x "$tmpdir/prism"
    run env PATH="$tmpdir:$PATH" bash "$PRISM_VERSION_CHECK" 2>&1
    rm -rf "$tmpdir"
    [ "$status" -eq 0 ]
}

@test "test_BC_6_01_001_prism_version_check_script_above_minimum (AC-008c, VP-SKILL-051)" {
    # BC-6.01.001 PC#8: prism 2.0.0 > 1.0.0-rc.1 passes the version gate → exit 0,
    # allowing the dual MCP write to proceed.
    local tmpdir
    tmpdir="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nif [ "$1" = "--version" ]; then echo "prism 2.0.0"; fi\n' \
        > "$tmpdir/prism"
    chmod +x "$tmpdir/prism"
    run env PATH="$tmpdir:$PATH" bash "$PRISM_VERSION_CHECK" 2>&1
    rm -rf "$tmpdir"
    [ "$status" -eq 0 ]
}

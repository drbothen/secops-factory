#!/usr/bin/env bats
# tests/skills/prism-version-check-adversarial.bats
# Adversarial-review red tests for S-6.03 — prism-version-check hook.
#
# Findings addressed:
#   F1 (MAJOR)  — semver_ge() uses lexicographic [[ > ]] for pre-release segments,
#                  producing wrong ordering for multi-digit rc numbers (rc.2 ">" rc.10).
#   F2 (MEDIUM) — prism-version-check.ps1 uses culture-insensitive -gt/-lt → parity
#                  divergence from sh for uppercase pre-release labels.
#   F4 (MEDIUM) — D-021 permanent guard: CLOSE_STATE_ALLOWLIST must never appear in
#                  verdict-emitting skill paths.
#   F5 (OBS)    — VP-SKILL-051 coverage gaps (absent, unparseable, rc.0, beta, release).
#
# BC: BC-6.01.001 PC#8, VP-SKILL-051, D-021
#
# RED (fail against current HEAD 0ab0aaf):
#   test_BC_6_01_001_F1_semver_ge_rc2_not_gte_rc10
#   test_BC_6_01_001_F1_semver_ge_rc10_gte_rc2
#   test_BC_6_01_001_F2_ps1_pre_release_comparison_ordinal
#
# GREEN (pass now — coverage or permanent guard):
#   test_BC_6_01_001_F1_semver_ge_release_gte_prerelease
#   test_BC_6_01_001_F4_d021_close_state_allowlist_config_side_only
#   test_BC_6_01_001_F5_prism_absent_exits_2
#   test_BC_6_01_001_F5_unparseable_version_exits_2
#   test_BC_6_01_001_F5_prism_rc0_below_minimum_halts
#   test_BC_6_01_001_F5_prism_beta_below_minimum_halts
#   test_BC_6_01_001_F5_release_satisfies_prerelease_minimum
#
# MUST NOT modify prism-version-check.sh, prism-version-check.ps1, SKILL.md,
# or any .factory/ artifact.

PLUGIN_ROOT="${BATS_TEST_DIRNAME}/../.."
PRISM_VERSION_CHECK="${PLUGIN_ROOT}/hooks/prism-version-check.sh"
PRISM_VERSION_CHECK_PS1="${PLUGIN_ROOT}/hooks/prism-version-check.ps1"

# ─── F1 — Pre-release semver NUMERIC ordering ────────────────────────────────
#
# The semver_ge() function at line 82 of prism-version-check.sh uses bash's
# lexicographic [[ > ]] operator to compare pre-release segments:
#
#   if [[ "$v1_pre" > "$v2_pre" ]]; then return 0; fi
#
# This is correct for single-digit comparisons (rc.1 < rc.2 < rc.9) but WRONG
# when a segment crosses to two digits:
#
#   [[ "rc.2" > "rc.10" ]] → TRUE  (ASCII '2'=0x32 > '1'=0x31 at position 3)
#   [[ "rc.10" > "rc.2" ]] → FALSE (ASCII '1'=0x31 < '2'=0x32 at position 3)
#
# Correct semver numeric ordering: rc.2 < rc.10.
#
# Strategy: extract the semver_ge() function body from the implementation script
# (awk range capture, written to a temp file) and call it directly.  This avoids
# needing a real/mocked prism binary and tests the comparator in isolation.
# The function extraction is sensitive to the actual implementation, so when the
# implementation is fixed, the tests automatically reflect the fix.

@test "test_BC_6_01_001_F1_semver_ge_rc2_not_gte_rc10 (F1, BC-6.01.001 PC#8, VP-SKILL-051)" {
    # RED: semver_ge("1.0.0-rc.2", "1.0.0-rc.10") must return 1 (not >=).
    # Current impl: [[ "rc.2" > "rc.10" ]] is TRUE → returns 0 (wrong).
    # A MIN_VERSION of 1.0.0-rc.10 must HALT an installed 1.0.0-rc.2.
    # Fails RED until F1 is fixed with numeric segment comparison.
    local tmpscript
    tmpscript="$(mktemp)"
    awk '/^semver_ge\(\) \{/,/^\}$/' "$PRISM_VERSION_CHECK" > "$tmpscript"
    printf '\nsemver_ge '"'"'1.0.0-rc.2'"'"' '"'"'1.0.0-rc.10'"'"'\n' >> "$tmpscript"
    run bash "$tmpscript"
    rm -f "$tmpscript"
    [ "$status" -eq 1 ]
}

@test "test_BC_6_01_001_F1_semver_ge_rc10_gte_rc2 (F1, BC-6.01.001 PC#8, VP-SKILL-051)" {
    # RED: semver_ge("1.0.0-rc.10", "1.0.0-rc.2") must return 0 (is >=).
    # Current impl: [[ "rc.10" > "rc.2" ]] is FALSE ('1' < '2') → returns 1 (wrong).
    # An installed 1.0.0-rc.10 MUST pass a MIN_VERSION of 1.0.0-rc.2.
    # Fails RED until F1 is fixed with numeric segment comparison.
    local tmpscript
    tmpscript="$(mktemp)"
    awk '/^semver_ge\(\) \{/,/^\}$/' "$PRISM_VERSION_CHECK" > "$tmpscript"
    printf '\nsemver_ge '"'"'1.0.0-rc.10'"'"' '"'"'1.0.0-rc.2'"'"'\n' >> "$tmpscript"
    run bash "$tmpscript"
    rm -f "$tmpscript"
    [ "$status" -eq 0 ]
}

@test "test_BC_6_01_001_F1_semver_ge_release_gte_prerelease (F1/F5, BC-6.01.001 PC#8, VP-SKILL-051)" {
    # GREEN (coverage / regression guard): semver_ge("1.0.0", "1.0.0-rc.1") must return 0.
    # Semver spec: a release version (no pre-release) is always > any pre-release of the
    # same major.minor.patch. The script handles this at:
    #   if [[ -z "$v1_pre" && -n "$v2_pre" ]]; then return 0; fi
    # This must remain true through the F1 numeric-ordering fix.
    local tmpscript
    tmpscript="$(mktemp)"
    awk '/^semver_ge\(\) \{/,/^\}$/' "$PRISM_VERSION_CHECK" > "$tmpscript"
    printf '\nsemver_ge '"'"'1.0.0'"'"' '"'"'1.0.0-rc.1'"'"'\n' >> "$tmpscript"
    run bash "$tmpscript"
    rm -f "$tmpscript"
    [ "$status" -eq 0 ]
}

# ─── F2 — ps1 parity: ordinal / case-sensitive pre-release comparison ─────────
#
# PowerShell's -gt/-lt string operators use the current culture's collation, which
# is case-insensitive by default (e.g., "RC.1" -gt "rc.1" evaluates as equal).
# Semver §11.4 requires case-sensitive ASCII-ordinal comparison for pre-release
# identifiers ('R' = 0x52 < 'r' = 0x72 → "RC.1" < "rc.1").
#
# Consequence: ps1 incorrectly ALLOWS an installed 1.0.0-RC.1 against a minimum
# 1.0.0-rc.1 (treated as equal; exits 0 instead of 1).
#
# Fix: use -cgt/-clt (PowerShell case-sensitive comparison) or
# [System.StringComparer]::Ordinal / [System.String]::CompareOrdinal().

@test "test_BC_6_01_001_F2_ps1_pre_release_comparison_ordinal (F2, VP-SKILL-051)" {
    # RED: ps1 must use an ordinal/case-sensitive comparison operator for pre-release
    # strings, not the culture-insensitive -gt/-lt default.
    # Accepted tokens: -cgt, -clt, -cge, -cle (PowerShell case-sensitive comparators),
    # CompareOrdinal, [System.StringComparer]::Ordinal, or StringComparison.Ordinal.
    # Grep returns non-zero → test fails RED until ps1 is fixed.
    grep -qE '(-cgt|-clt|-cge|-cle|CompareOrdinal|\[System\.StringComparer\]::Ordinal|StringComparison\.Ordinal)' \
        "$PRISM_VERSION_CHECK_PS1"
}

# ─── F4 — D-021 CLOSE_STATE_ALLOWLIST forbidden-dependency guard (PERMANENT) ──
#
# BC-6.01.001 Invariant + D-021: CLOSE_STATE_ALLOWLIST is a CONFIG-side constant
# that belongs ONLY in the activate skill. It must NEVER appear in any verdict-
# emitting skill (monitoring-loop, investigate-event, review-enrichment, etc.),
# because that would create an LLM-injectable verdict path (CWE-20 / P18-005).
#
# This is a permanent regression guard: it PASSES now (invariant holds at HEAD
# 0ab0aaf) and would FAIL on regression if someone incorrectly adds the constant
# to a verdict-emitting path.

@test "test_BC_6_01_001_F4_d021_close_state_allowlist_config_side_only (F4, D-021, GUARD)" {
    # GREEN (permanent guard — must PASS now and always):
    # Scan every SKILL.md under skills/ except activate/. If any file contains
    # CLOSE_STATE_ALLOWLIST, the D-021 invariant is violated and the test fails.
    local violations=0
    while IFS= read -r -d '' skill_file; do
        # CLOSE_STATE_ALLOWLIST is permitted only in the activate skill
        [[ "$skill_file" == *"/activate/SKILL.md" ]] && continue
        if grep -qF "CLOSE_STATE_ALLOWLIST" "$skill_file"; then
            printf 'D-021 VIOLATION: CLOSE_STATE_ALLOWLIST found in verdict path: %s\n' \
                "$skill_file" >&2
            violations=$((violations + 1))
        fi
    done < <(find "$PLUGIN_ROOT/skills" -name "SKILL.md" -print0 2>/dev/null)
    [ "$violations" -eq 0 ]
}

# ─── F5 — VP-SKILL-051 coverage vectors ───────────────────────────────────────
#
# BC-6.01.001 PC#8 defines three exit codes: 0 (pass), 1 (below minimum), 2 (error).
# The existing suite tests 0.9.9/1.0.0-rc.1/2.0.0 against the default MIN_VERSION.
# These additional vectors cover the error paths (exit 2) and boundary pre-releases.
# All five tests are GREEN against HEAD 0ab0aaf; they document correct behavior and
# guard against regressions introduced during the F1/F2 fixes.

@test "test_BC_6_01_001_F5_prism_absent_exits_2 (F5, BC-6.01.001 PC#8, VP-SKILL-051)" {
    # GREEN: prism not in PATH → exit 2 + "not found in PATH" error.
    # BC-6.01.001 PC#8: exit 2 distinguishes "tool missing" from "version too old" (exit 1).
    # Use a minimal PATH containing only /usr/bin and /bin to exclude any installed prism.
    run env PATH="/usr/bin:/bin" bash "$PRISM_VERSION_CHECK" 2>&1
    [ "$status" -eq 2 ]
    [[ "$output" == *"not found in PATH"* ]]
}

@test "test_BC_6_01_001_F5_unparseable_version_exits_2 (F5, BC-6.01.001 PC#8, VP-SKILL-051)" {
    # GREEN: prism outputs a non-semver string → exit 2 + "could not parse" error.
    # BC-6.01.001 PC#8: runtime parse failure is an error (exit 2), not a version mismatch.
    local tmpdir
    tmpdir="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nif [ "$1" = "--version" ]; then printf "not-a-version"; fi\n' \
        > "$tmpdir/prism"
    chmod +x "$tmpdir/prism"
    run env PATH="$tmpdir:$PATH" bash "$PRISM_VERSION_CHECK" 2>&1
    rm -rf "$tmpdir"
    [ "$status" -eq 2 ]
    [[ "$output" == *"could not parse"* ]]
}

@test "test_BC_6_01_001_F5_prism_rc0_below_minimum_halts (F5, BC-6.01.001 EC-009, VP-SKILL-051)" {
    # GREEN: 1.0.0-rc.0 < 1.0.0-rc.1 (min) → exit 1 + BC-canonical halt phrase.
    # BC-6.01.001 EC-009: the error message MUST contain "does not meet minimum requirement".
    # Verifies boundary: rc.0 is strictly below the 1-indexed minimum.
    local tmpdir
    tmpdir="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nif [ "$1" = "--version" ]; then echo "prism 1.0.0-rc.0"; fi\n' \
        > "$tmpdir/prism"
    chmod +x "$tmpdir/prism"
    run env PATH="$tmpdir:$PATH" bash "$PRISM_VERSION_CHECK" 2>&1
    rm -rf "$tmpdir"
    [ "$status" -eq 1 ]
    [[ "$output" == *"does not meet minimum requirement"* ]]
}

@test "test_BC_6_01_001_F5_prism_beta_below_minimum_halts (F5, BC-6.01.001 EC-009, VP-SKILL-051)" {
    # GREEN: 1.0.0-beta < 1.0.0-rc.1 (lexically 'b' < 'r') → exit 1 + halt phrase.
    # Additional pre-release label coverage: ensures non-rc identifiers are also gated.
    local tmpdir
    tmpdir="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nif [ "$1" = "--version" ]; then echo "prism 1.0.0-beta"; fi\n' \
        > "$tmpdir/prism"
    chmod +x "$tmpdir/prism"
    run env PATH="$tmpdir:$PATH" bash "$PRISM_VERSION_CHECK" 2>&1
    rm -rf "$tmpdir"
    [ "$status" -eq 1 ]
    [[ "$output" == *"does not meet minimum requirement"* ]]
}

@test "test_BC_6_01_001_F5_release_satisfies_prerelease_minimum (F5, BC-6.01.001 PC#8, VP-SKILL-051)" {
    # GREEN: installed release 1.0.0 satisfies a pre-release minimum 1.0.0-rc.1 → exit 0.
    # Semver: a release version is always > any pre-release of the same major.minor.patch.
    # E2E vector exercising the full script with a GA-release mock binary.
    local tmpdir
    tmpdir="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nif [ "$1" = "--version" ]; then echo "prism 1.0.0"; fi\n' \
        > "$tmpdir/prism"
    chmod +x "$tmpdir/prism"
    run env PATH="$tmpdir:$PATH" bash "$PRISM_VERSION_CHECK" 2>&1
    rm -rf "$tmpdir"
    [ "$status" -eq 0 ]
    [[ "$output" == *"meets minimum requirement"* ]]
}

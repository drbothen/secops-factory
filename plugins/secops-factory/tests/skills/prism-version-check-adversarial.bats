#!/usr/bin/env bats
# tests/skills/prism-version-check-adversarial.bats
# Adversarial-review red tests for S-6.03 — prism-version-check hook.
#
# Pass-1 findings addressed:
#   F1 (MAJOR)  — semver_ge() uses lexicographic [[ > ]] for pre-release segments,
#                  producing wrong ordering for multi-digit rc numbers (rc.2 ">" rc.10).
#   F2 (MEDIUM) — prism-version-check.ps1 uses culture-insensitive -gt/-lt → parity
#                  divergence from sh for uppercase pre-release labels.
#   F4 (MEDIUM) — D-021 permanent guard: CLOSE_STATE_ALLOWLIST must never appear in
#                  verdict-emitting skill paths.
#   F5 (OBS)    — VP-SKILL-051 coverage gaps (absent, unparseable, rc.0, beta, release).
#
# Pass-2 adversarial findings added (HEAD c54d048):
#   F1 (MAJOR)  — SKILL.md step 6 only invokes bash prism-version-check.sh; no native
#                  Windows invocation path (PowerShell) is provided or wired in
#                  hooks.json.windows for the prism version gate.
#   F2 (MAJOR)  — ps1 sets $ErrorActionPreference='Stop', then calls bare Write-Error
#                  before each 'exit 2'. Under Stop, Write-Error is TERMINATING — the
#                  exception propagates and 'exit 2' is never reached; gate exits 1
#                  instead of 2 for not-found and unparseable-version error paths.
#   F3 (MEDIUM) — sh semver_ge uses (( _s1 > _s2 )) for numeric pre-release fields;
#                  (( 08 > 10 )) treats 08 as invalid octal on bash → arithmetic error
#                  emitted to stderr and comparator returns wrong result (see parity.bats
#                  for the replacement test of the coincidentally-passing rc.08 test).
#   F4 (MEDIUM) — sh gate has 'set -euo pipefail'; assignment
#                  version_output="$(prism --version 2>&1)" has no '|| true' guard.
#                  When prism --version exits non-zero, set -e aborts the script at the
#                  assignment before the version string can be parsed.
#
# BC: BC-6.01.001 PC#8, VP-SKILL-051, D-021
#
# GREEN at HEAD c54d048 (all pass-1 findings fixed):
#   test_BC_6_01_001_F1_semver_ge_rc2_not_gte_rc10
#   test_BC_6_01_001_F1_semver_ge_rc10_gte_rc2
#   test_BC_6_01_001_F1_locale_utf8_uppercase_prerelease_wrong_allow  (F-1 fixed in c54d048)
#   test_BC_6_01_001_F2_ps1_pre_release_comparison_ordinal
#   test_BC_6_01_001_F1_semver_ge_release_gte_prerelease
#   test_BC_6_01_001_F4_d021_close_state_allowlist_config_side_only
#   test_BC_6_01_001_F5_prism_absent_exits_2
#   test_BC_6_01_001_F5_unparseable_version_exits_2
#   test_BC_6_01_001_F5_prism_rc0_below_minimum_halts
#   test_BC_6_01_001_F5_prism_beta_below_minimum_halts
#   test_BC_6_01_001_F5_release_satisfies_prerelease_minimum
#
# RED at HEAD c54d048 (pass-2 unfixed findings):
#   test_BC_6_01_001_F1_skill_md_step6_missing_windows_prism_gate     (pass-2 F1)
#   test_BC_6_01_001_F2_ps1_write_error_terminating_before_exit2      (pass-2 F2)
#   test_BC_6_01_001_F4_sh_prism_nonzero_exit_version_still_parsed    (pass-2 F4)
#
# MUST NOT modify prism-version-check.sh, prism-version-check.ps1, SKILL.md,
# or any .factory/ artifact.

PLUGIN_ROOT="${BATS_TEST_DIRNAME}/../.."
PRISM_VERSION_CHECK="${PLUGIN_ROOT}/hooks/prism-version-check.sh"
PRISM_VERSION_CHECK_PS1="${PLUGIN_ROOT}/hooks/prism-version-check.ps1"
SKILL_MD="${PLUGIN_ROOT}/skills/activate/SKILL.md"

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

# ─── F-1 locale — sh comparator is not locale-neutral (WRONG-ALLOW under UTF-8) ─
#
# prism-version-check.sh line 107-108 uses bash [[ > ]] / [[ < ]] for alphanumeric
# pre-release segments. Bash [[ > ]] respects LC_COLLATE. Under en_US.UTF-8:
#
#   [[ "RC" > "rc" ]] → TRUE  (uppercase sorts AFTER lowercase in UTF-8 collation)
#   [[ "RC" < "rc" ]] → FALSE
#
# → semver_ge("1.0.0-RC.1", "1.0.0-rc.1") returns 0 (WRONG-ALLOW, gate exits 0).
#
# With LC_ALL=C (ASCII order): 'R' (0x52) < 'r' (0x72) → [[ "RC" > "rc" ]] FALSE
# → semver_ge returns 1 (correct, gate exits 1).
#
# The script comment at line 106 says "caller sets LC_ALL=C", but SKILL.md:46
# (production caller) does NOT:
#   bash "${CLAUDE_PLUGIN_ROOT}/hooks/prism-version-check.sh"
#
# Fix: set LC_ALL=C at the top of prism-version-check.sh before any [[ ]] string
# comparison that is required to use ASCII-ordinal ordering.
#
# Traced: F-1, BC-6.01.001 PC#8, VP-SKILL-051.

@test "test_BC_6_01_001_F1_locale_utf8_uppercase_prerelease_wrong_allow (F-1, BC-6.01.001 PC#8, VP-SKILL-051)" {
    # RED: under a UTF-8 locale, semver_ge(1.0.0-RC.1, 1.0.0-rc.1) returns 0 (WRONG-ALLOW).
    # Gate MUST exit 1 for 1.0.0-RC.1 < 1.0.0-rc.1; currently exits 0 under UTF-8 locale.
    # Skips if no UTF-8 locale is available on the runner (fallback via locale -a).
    # Traced: F-1, BC-6.01.001 PC#8, VP-SKILL-051.

    local utf8_locale
    utf8_locale=$(locale -a 2>/dev/null | grep -i 'utf' | grep -iv 'posix' | head -1)
    if [[ -z "$utf8_locale" ]]; then
        skip "no UTF-8 locale available on this runner — F-1 locale test cannot run"
    fi

    local tmpdir
    tmpdir="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nif [ "$1" = "--version" ]; then echo "prism 1.0.0-RC.1"; fi\n' \
        > "$tmpdir/prism"
    chmod +x "$tmpdir/prism"

    # Run under UTF-8 locale — mirrors production SKILL.md:46 (no caller LC_ALL=C).
    local actual_status=0
    env LC_ALL="$utf8_locale" PATH="$tmpdir:$PATH" \
        bash "$PRISM_VERSION_CHECK" >/dev/null 2>&1 || actual_status=$?

    rm -rf "$tmpdir"

    # MUST exit 1: 1.0.0-RC.1 is below min 1.0.0-rc.1 (semver §11.4, ASCII 'R' < 'r').
    # RED until prism-version-check.sh sets LC_ALL=C internally to enforce ordinal ordering.
    [ "$actual_status" -eq 1 ]
}

# ─── Pass-2 F1 — Windows gate wiring gap in SKILL.md step 6 ─────────────────
#
# BC-6.01.001 PC#8 / VP-SKILL-051: the prism version gate MUST be enforced on
# every supported platform. SKILL.md step 6 (the activation procedure) specifies:
#
#   bash "${CLAUDE_PLUGIN_ROOT}/hooks/prism-version-check.sh"
#
# This is the only invocation given. On native Windows (no WSL, no Git Bash),
# bash is not available: step 6 silently skips the gate, allowing an incompatible
# prism version to pass. Step 8 correctly detects the Windows platform and
# switches to hooks.json.windows — but no parallel Windows branch exists in
# step 6 for the version gate.
#
# Resolution: step 6 must add a Windows branch invoking prism-version-check.ps1
# (mirroring step 8's platform detection), OR prism-version-check.ps1 must be
# wired as a setup-only hook in hooks.json.windows.
#
# Static test: fails RED until SKILL.md step 6 references prism-version-check.ps1
# for Windows OR hooks.json.windows includes prism-version-check.
# Traced: pass-2 F1, BC-6.01.001 PC#8, VP-SKILL-051.

@test "test_BC_6_01_001_F1_skill_md_step6_missing_windows_prism_gate (pass-2 F1, BC-6.01.001 PC#8, VP-SKILL-051)" {
    # RED: SKILL.md step 6 invokes only bash .../prism-version-check.sh.
    # On native Windows, bash is unavailable outside WSL/Git Bash → gate is silently
    # skipped, violating BC-6.01.001 PC#8.
    # Pass condition (either is sufficient):
    #   (a) SKILL.md step 6 references prism-version-check.ps1 (Windows branch), or
    #   (b) hooks.json.windows has a prism-version-check entry (wired as setup hook).
    # Currently neither is true → RED.
    local hooks_json_win="${PLUGIN_ROOT}/hooks/hooks.json.windows"

    local skill_has_ps1=0
    grep -q 'prism-version-check\.ps1' "$SKILL_MD" && skill_has_ps1=1

    local hooks_has_prism=0
    grep -q 'prism-version-check' "$hooks_json_win" && hooks_has_prism=1

    # At least one path must be wired for native-Windows operators
    [ "$skill_has_ps1" -eq 1 ] || [ "$hooks_has_prism" -eq 1 ]
}

# ─── Pass-2 F2 — ps1 Write-Error terminating under $ErrorActionPreference='Stop' ─
#
# BC-6.01.001 PC#8 defines three exit codes: 0 (pass), 1 (below minimum), 2 (error).
# prism-version-check.ps1 sets $ErrorActionPreference = 'Stop' (line 9) and then
# calls bare Write-Error before each 'exit 2':
#
#   Write-Error 'ERROR: prism binary not found in PATH'
#   exit 2
#
# Under $ErrorActionPreference='Stop', Write-Error is a TERMINATING error — it throws
# a System.Management.Automation.ErrorRecord exception. The 'exit 2' that follows is
# unreachable. The script exits with code 1 (unhandled terminating error), not 2,
# destroying the ability of callers to distinguish "tool missing" (exit 2) from
# "version too old" (exit 1).
#
# Fix: replace bare Write-Error with a non-terminating output mechanism before each
# 'exit 2'. Accepted patterns (non-terminating under Stop):
#   [Console]::Error.WriteLine('...')
#   Write-Host '...' -ForegroundColor Red
#   Write-Error '...' -ErrorAction Continue
#
# Static test: scans ps1 for at least one non-terminating error-output pattern.
# Fails RED until ps1 replaces Write-Error with a non-terminating alternative.
# Traced: pass-2 F2, BC-6.01.001 PC#8, VP-SKILL-051.

@test "test_BC_6_01_001_F2_ps1_write_error_terminating_before_exit2 (pass-2 F2, BC-6.01.001 PC#8, VP-SKILL-051)" {
    # RED: ps1 uses bare Write-Error (terminating under Stop) before each exit 2.
    # Assert that the ps1 uses at least one non-terminating error-output mechanism.
    # Accepted: [Console]::Error.Write*, Write-Host with -ForegroundColor Red,
    # or Write-Error with -ErrorAction Continue/SilentlyContinue override.
    # Currently none present → grep returns non-zero → test FAILS RED.
    grep -qE '\[Console\]::Error\.(Write|WriteLine)|Write-Host[^#]+-ForegroundColor\s+Red|Write-Error[^#]+-ErrorAction\s+(Continue|SilentlyContinue)' \
        "$PRISM_VERSION_CHECK_PS1"
}

# ─── Pass-2 F4 — sh set -e aborts on prism --version non-zero exit ────────────
#
# prism-version-check.sh line 10: set -euo pipefail
# prism-version-check.sh line 26: version_output="$(prism --version 2>&1)"
#
# The assignment at line 26 has no '|| true' guard. When 'prism --version' exits
# with a non-zero status (e.g., a debug build that returns exit 3 after printing a
# valid version string to stdout), 'set -e' causes the entire script to abort at the
# assignment point. The version string is captured in $version_output, but the
# subsequent parse / comparison logic is never reached.
#
# Consequence: a prism binary that happens to exit non-zero after printing its
# version is reported as a gate failure (non-0 exit from the script) rather than
# exit 0 (meets minimum). This is a false negative — valid versions are blocked.
#
# Fix: add '|| true' to the assignment:
#   version_output="$(prism --version 2>&1)" || true
#
# E2E test: mock prism prints "prism 2.0.0" (above minimum) and exits 3.
# Gate MUST exit 0. Currently exits 3 (set -e passes through prism's exit code).
# Traced: pass-2 F4, BC-6.01.001 PC#8, VP-SKILL-051.

@test "test_BC_6_01_001_F4_sh_prism_nonzero_exit_version_still_parsed (pass-2 F4, BC-6.01.001 PC#8, VP-SKILL-051)" {
    # RED: mock prism prints valid above-minimum version "prism 2.0.0" then exits 3.
    # set -e at line 10 aborts the script at the assignment on line 26; gate exits 3
    # instead of 0. The version string is never parsed.
    # Must exit 0 once '|| true' is added to the assignment.
    local tmpdir
    tmpdir="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nif [ "$1" = "--version" ]; then echo "prism 2.0.0"; exit 3; fi\n' \
        > "$tmpdir/prism"
    chmod +x "$tmpdir/prism"
    run env PATH="$tmpdir:$PATH" bash "$PRISM_VERSION_CHECK" 2>&1
    rm -rf "$tmpdir"
    # 2.0.0 >= minimum 1.0.0-rc.1: gate MUST exit 0.
    # RED until 'set -e' protection is added for the prism --version assignment.
    [ "$status" -eq 0 ]
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

# ─── Pass-3 findings (adversarial pass 3, S-6.03) ────────────────────────────
#
# M-2 (MEDIUM) — ps1 below/at/above + numeric-ordering triplet:
#   Mirrors the sh triplet for prism-version-check.ps1. pwsh-guarded (CI-only).
#   Kills boundary mutant: replacing -ge 0 with -gt 0 at ps1:103 causes the
#   at-minimum test to fail (cmp=0 would exit 1 instead of 0).
#   Traced: M-2, BC-6.01.001 PC#8, VP-SKILL-051.
#
# M-1 (MEDIUM) — ps1 valid-version-nonzero-exit:
#   Mirrors sh pass-2 F4. Mock prism outputs valid above-minimum version then
#   exits non-zero; ps1 must honor the printed version (exit 0). pwsh-guarded.
#   RED-in-CI: current ps1 try/catch exits 2 instead of 0. Traced: M-1, VP-SKILL-051.
#
# L-1 (LOW) — ps1 below-min clean stderr:
#   Static assertion: the below-min branch uses bare Write-Error before exit 1.
#   Under $ErrorActionPreference='Stop', Write-Error is terminating — exit 1 is
#   unreachable. Must use [Console]::Error.WriteLine (matching exit-2 paths).
#   RED now. Traced: L-1, BC-6.01.001 PC#8, VP-SKILL-051.
#
# L-2 (LOW) — sh main-version leading-zero patch:
#   E2E: mock prism 1.0.08 vs default MIN 1.0.0-rc.1. The patch comparison
#   (( pat1 > pat2 )) lacks 10# prefix; (( 08 > 0 )) is invalid octal → stderr
#   error. Gate exits 0 by accident (falls through to pre-release check), but
#   emits "value too great for base" to stderr. RED now. Traced: L-2, BC-6.01.001 PC#8.
#
# O-2 (process-gap) — broaden D-021 forbidden-dependency guard:
#   Extends the existing skills/ scan to also cover agents/**/*.md and hooks/.
#   PASSES now (CLOSE_STATE_ALLOWLIST only in activate + tests); guards future regressions.
#   Traced: O-2, D-021, BC-6.01.001 invariant.

# ─── M-2 — ps1 below/at/above triplet + numeric ordering (pwsh-guarded) ─────

@test "test_BC_6_01_001_M2_ps1_below_min_exits_1 (M-2, BC-6.01.001 PC#8, VP-SKILL-051)" {
    # pwsh-guarded: SKIP locally, enforce in CI.
    # GREEN in CI: installed 0.9.9 is below minimum 1.0.0-rc.1 → ps1 must exit 1.
    # Part of boundary mutant triplet: kills -ge 0 → -gt 0 mutation at ps1:103 via
    # the at-min sibling. This test verifies the below-min reject path is correct.
    if ! command -v pwsh &>/dev/null; then
        skip "pwsh not installed — ps1 parity tests run in CI"
    fi
    local tmpdir
    tmpdir="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nif [ "$1" = "--version" ]; then echo "prism 0.9.9"; fi\n' \
        > "$tmpdir/prism"
    chmod +x "$tmpdir/prism"
    run env PATH="$tmpdir:$PATH" pwsh -NoProfile -File "$PRISM_VERSION_CHECK_PS1" 2>&1
    rm -rf "$tmpdir"
    [ "$status" -eq 1 ]
}

@test "test_BC_6_01_001_M2_ps1_at_min_exits_0 (M-2, BC-6.01.001 PC#8, VP-SKILL-051)" {
    # pwsh-guarded: SKIP locally, enforce in CI.
    # GREEN in CI: installed 1.0.0-rc.1 (exactly equals minimum) → ps1 must exit 0.
    # KILLS BOUNDARY MUTANT: replacing -ge 0 with -gt 0 at ps1:103 makes
    # Compare-SemVer return 0 (equal) fail the -gt check → exits 1 (wrong).
    # The at-minimum case is the canonical mutation target for -ge vs -gt.
    if ! command -v pwsh &>/dev/null; then
        skip "pwsh not installed — ps1 parity tests run in CI"
    fi
    local tmpdir
    tmpdir="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nif [ "$1" = "--version" ]; then echo "prism 1.0.0-rc.1"; fi\n' \
        > "$tmpdir/prism"
    chmod +x "$tmpdir/prism"
    run env PATH="$tmpdir:$PATH" pwsh -NoProfile -File "$PRISM_VERSION_CHECK_PS1" 2>&1
    rm -rf "$tmpdir"
    [ "$status" -eq 0 ]
}

@test "test_BC_6_01_001_M2_ps1_above_min_exits_0 (M-2, BC-6.01.001 PC#8, VP-SKILL-051)" {
    # pwsh-guarded: SKIP locally, enforce in CI.
    # GREEN in CI: installed 2.0.0 is above minimum 1.0.0-rc.1 → ps1 must exit 0.
    # Completes the below/at/above triplet, mirroring the sh F5 coverage vectors.
    if ! command -v pwsh &>/dev/null; then
        skip "pwsh not installed — ps1 parity tests run in CI"
    fi
    local tmpdir
    tmpdir="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nif [ "$1" = "--version" ]; then echo "prism 2.0.0"; fi\n' \
        > "$tmpdir/prism"
    chmod +x "$tmpdir/prism"
    run env PATH="$tmpdir:$PATH" pwsh -NoProfile -File "$PRISM_VERSION_CHECK_PS1" 2>&1
    rm -rf "$tmpdir"
    [ "$status" -eq 0 ]
}

@test "test_BC_6_01_001_M2_ps1_numeric_ordering_rc2_lt_rc10 (M-2, BC-6.01.001 PC#8, VP-SKILL-051)" {
    # pwsh-guarded: SKIP locally, enforce in CI.
    # GREEN in CI: Compare-SemVer("1.0.0-rc.2", "1.0.0-rc.10") must return -1 (rc.2 < rc.10).
    # Numeric segment comparison: [int]2 < [int]10. Verifies ps1 does NOT use lexicographic
    # comparison (string "2" > "10" — wrong) but integer comparison (2 < 10 — correct).
    # Mirrors sh test_BC_6_01_001_F1_semver_ge_rc2_not_gte_rc10 using function extraction.
    # Traced: M-2, BC-6.01.001 PC#8, VP-SKILL-051.
    if ! command -v pwsh &>/dev/null; then
        skip "pwsh not installed — ps1 parity tests run in CI"
    fi
    local tmpscript
    tmpscript="$(mktemp /tmp/ps1-cmp-XXXXXX.ps1)"
    # Extract Split-SemVer and Compare-SemVer function definitions from ps1
    awk '/^function Split-SemVer/,/^\}$/' "$PRISM_VERSION_CHECK_PS1" > "$tmpscript"
    awk '/^function Compare-SemVer/,/^\}$/' "$PRISM_VERSION_CHECK_PS1" >> "$tmpscript"
    # Invoke comparator: rc.2 < rc.10 → returns -1 → exit 0 (test pass)
    printf '\n$cmp = Compare-SemVer "1.0.0-rc.2" "1.0.0-rc.10"\nif ($cmp -lt 0) { exit 0 } else { exit 1 }\n' \
        >> "$tmpscript"
    run pwsh -NoProfile -File "$tmpscript"
    rm -f "$tmpscript"
    # Compare-SemVer("rc.2","rc.10"): numeric [int]2 < [int]10 → returns -1 → exit 0
    [ "$status" -eq 0 ]
}

# ─── M-1 — ps1 valid-version-nonzero-exit (pwsh-guarded, RED in CI) ──────────

@test "test_BC_6_01_001_M1_ps1_valid_version_nonzero_prism_exit_passes (M-1, BC-6.01.001 PC#8, VP-SKILL-051)" {
    # pwsh-guarded: SKIP locally, RED in CI.
    # Mirrors sh pass-2 F4: mock prism outputs valid above-minimum version "prism 2.0.0"
    # then exits non-zero (exit 3). ps1 must honor the printed version and exit 0.
    # RED: current ps1 try/catch block exits 2 when prism exits non-zero under
    # $ErrorActionPreference='Stop', discarding the valid version string before
    # the semver comparison is reached.
    # Fix: add error-suppression equivalent of '|| true' for the prism --version call
    # (e.g., wrap exit-code in try/catch that only catches terminating errors, or
    # check $LASTEXITCODE separately from the captured output).
    # Traced: M-1, BC-6.01.001 PC#8, VP-SKILL-051.
    if ! command -v pwsh &>/dev/null; then
        skip "pwsh not installed — ps1 parity tests run in CI"
    fi
    local tmpdir
    tmpdir="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nif [ "$1" = "--version" ]; then echo "prism 2.0.0"; exit 3; fi\n' \
        > "$tmpdir/prism"
    chmod +x "$tmpdir/prism"
    run env PATH="$tmpdir:$PATH" pwsh -NoProfile -File "$PRISM_VERSION_CHECK_PS1" 2>&1
    rm -rf "$tmpdir"
    # 2.0.0 >= minimum 1.0.0-rc.1: gate MUST exit 0.
    # RED until ps1 handles prism non-zero exit without discarding the version output.
    [ "$status" -eq 0 ]
}

# ─── L-1 — ps1 below-min clean stderr (static, RED now) ──────────────────────

@test "test_BC_6_01_001_L1_ps1_below_min_uses_nonterminating_error_output (L-1, BC-6.01.001 PC#8, VP-SKILL-051)" {
    # RED: the below-min verdict branch (ps1 line 107) uses bare Write-Error before
    # exit 1. Under $ErrorActionPreference='Stop', Write-Error is a TERMINATING error —
    # it throws a System.Management.Automation.ErrorRecord exception and exit 1 is
    # never reached. The script exits with an unhandled exception code instead of 1,
    # preventing callers from distinguishing "version too old" (exit 1) from other errors.
    #
    # The exit-2 paths already use [Console]::Error.WriteLine (non-terminating) correctly.
    # The exit-1 path must be fixed to match that pattern.
    #
    # Static assertion: no bare Write-Error (without -ErrorAction qualifier) appears
    # on the line immediately before an exit statement in the ps1.
    # Fails RED until ps1 replaces Write-Error with [Console]::Error.WriteLine before exit 1.
    # Traced: L-1, BC-6.01.001 PC#8, VP-SKILL-051.
    run awk '
        /Write-Error/ && !/ErrorAction/ { flag = 1; next }
        flag && /^[[:space:]]*exit [0-9]/ { found = 1 }
        { flag = 0 }
        END { exit found ? 1 : 0 }
    ' "$PRISM_VERSION_CHECK_PS1"
    # awk exits 1 when violation found (bare Write-Error before exit) → test FAILS RED.
    # awk exits 0 when no violation (non-terminating output used) → test PASSES GREEN.
    [ "$status" -eq 0 ]
}

# ─── L-2 — sh main-version leading-zero patch (e2e, RED now) ──────────────────

@test "test_BC_6_01_001_L2_sh_main_version_leading_zero_patch_no_octal_error (L-2, BC-6.01.001 PC#8, VP-SKILL-051)" {
    # RED: semver_ge() uses (( pat1 > pat2 )) at lines 78-79 without the 10# base prefix.
    # When prism reports version 1.0.08, pat1="08". bash (( )) treats leading-zero
    # numerals as octal; 08 is invalid octal → bash emits "value too great for base
    # (error token is "08")" to stderr and the arithmetic expression returns 1 (false).
    # Both (( 08 > 0 )) and (( 08 < 0 )) fail → comparator falls through to the
    # pre-release check where the release (no pre-release) trivially beats the minimum
    # pre-release tag, so the gate exits 0 "by accident". But the octal error IS emitted.
    #
    # Contrast: pre-release numeric segments already use 10#$_s1 (lines 108-109).
    # The same fix must be applied to the main-version maj/min/pat comparisons.
    #
    # This test verifies two things:
    #   1. Gate exits 0 (1.0.8 decimal > 1.0.0-rc.1 — correct pass verdict).
    #   2. No "value too great for base" octal error in merged stderr.
    # Currently the gate exits 0 (accidental) but ALSO emits the octal error → FAILS RED
    # on assertion 2.
    # Traced: L-2, BC-6.01.001 PC#8, VP-SKILL-051.
    local tmpdir
    tmpdir="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nif [ "$1" = "--version" ]; then echo "prism 1.0.08"; fi\n' \
        > "$tmpdir/prism"
    chmod +x "$tmpdir/prism"
    run env PATH="$tmpdir:$PATH" bash "$PRISM_VERSION_CHECK" 2>&1
    rm -rf "$tmpdir"
    # 1.0.8 (decimal) > 1.0.0-rc.1: gate MUST exit 0.
    [ "$status" -eq 0 ]
    # No octal arithmetic error must appear in merged output.
    # RED until (( 10#$pat1 > 10#$pat2 )) is used in semver_ge() main-version comparison.
    [[ "$output" != *"value too great for base"* ]]
}

# ─── O-2 — broaden D-021 guard to agents/ and hooks/ (PASSES now, regression guard) ──

@test "test_BC_6_01_001_O2_d021_close_state_allowlist_no_verdict_path_anywhere (O-2, D-021, BC-6.01.001 invariant, GUARD)" {
    # GREEN (permanent regression guard — must PASS now and always):
    # CLOSE_STATE_ALLOWLIST is a CONFIG-side constant (D-021) that belongs ONLY in
    # skills/activate/SKILL.md. It must NEVER appear in any verdict-emitting path:
    #   - other skills/**/SKILL.md (excluding activate)
    #   - agents/**/*.md (any agent spec)
    #   - hooks/ (any hook file, .sh or .ps1 or JSON)
    # Presence in those paths creates an LLM-injectable verdict path (CWE-20 / P18-005).
    #
    # This test extends the scope of the existing D-021 guard (which only scanned
    # skills/) to also cover agents/ and hooks/ — catching future regressions anywhere
    # in the verdict-emitting surface.
    # Traced: O-2, D-021, BC-6.01.001 invariant.
    local violations=0

    # Scan skills/ (all SKILL.md files except activate)
    while IFS= read -r -d '' skill_file; do
        [[ "$skill_file" == *"/activate/SKILL.md" ]] && continue
        if grep -qF "CLOSE_STATE_ALLOWLIST" "$skill_file"; then
            printf 'D-021 VIOLATION in skill verdict path: %s\n' "$skill_file" >&2
            violations=$((violations + 1))
        fi
    done < <(find "$PLUGIN_ROOT/skills" -name "SKILL.md" -print0 2>/dev/null)

    # Scan agents/ (all .md files)
    while IFS= read -r -d '' agent_file; do
        if grep -qF "CLOSE_STATE_ALLOWLIST" "$agent_file"; then
            printf 'D-021 VIOLATION in agent path: %s\n' "$agent_file" >&2
            violations=$((violations + 1))
        fi
    done < <(find "$PLUGIN_ROOT/agents" -name "*.md" -print0 2>/dev/null)

    # Scan hooks/ (all files: .sh, .ps1, .json)
    while IFS= read -r -d '' hook_file; do
        if grep -qF "CLOSE_STATE_ALLOWLIST" "$hook_file"; then
            printf 'D-021 VIOLATION in hook: %s\n' "$hook_file" >&2
            violations=$((violations + 1))
        fi
    done < <(find "$PLUGIN_ROOT/hooks" -type f -print0 2>/dev/null)

    [ "$violations" -eq 0 ]
}

# ─── R-A1 — Unanchored regex fail-open (F-A regression, PR-review cycle 2) ───
#
# The extraction regex was originally unanchored:
#   grep -oE '[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?' | head -1
#
# This grabs the FIRST semver-like token anywhere in `prism --version 2>&1`,
# including embedded tokens in rustc build banners, RUST_LOG debug lines, or
# any other text preceding the real prism version.
#
# Reproduced on feature/S-6.03 @ 527b68e:
#   mock: "prism (rustc 1.75.0) version 0.5.0"
#   result: "prism 1.75.0 meets minimum requirement 1.0.0-rc.1"  exit=0
#   (0.5.0 prism passes the 1.0.0-rc.1 gate — fail-open)
#
# Fix: anchor to '^prism[[:space:]]+' on the first line only.  An output string
# that does not begin with "prism <semver>" on the first line MUST exit 2.
#
# Traced: F-A, BC-6.01.001 PC#8, VP-SKILL-051, PR review cycle 2.

@test "test_BC_6_01_001_R_A1_sh_rustc_banner_does_not_pass_gate (F-A, BC-6.01.001 PC#8, VP-SKILL-051)" {
    # Regression: "prism (rustc 1.75.0) version 0.5.0" must NOT pass the gate.
    # Unanchored regex would extract 1.75.0 (first semver token) → WRONG-ALLOW exit 0.
    # Anchored regex: '^prism[[:space:]]+[0-9]+...' does not match (after 'prism '
    # comes '(' not a digit) → version empty → exit 2.
    local tmpdir
    tmpdir="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nif [ "$1" = "--version" ]; then echo "prism (rustc 1.75.0) version 0.5.0"; fi\n' \
        > "$tmpdir/prism"
    chmod +x "$tmpdir/prism"

    local actual_status=0
    PATH="$tmpdir:$PATH" bash "$PRISM_VERSION_CHECK" >/dev/null 2>&1 || actual_status=$?

    rm -rf "$tmpdir"

    # MUST exit 2 (cannot parse) — NOT exit 0 (wrong-allow).
    [ "$actual_status" -eq 2 ]
}

@test "test_BC_6_01_001_R_A2_sh_log_line_before_version_does_not_pass_gate (F-A, BC-6.01.001 PC#8, VP-SKILL-051)" {
    # Regression: a RUST_LOG=debug line on line 1 followed by "prism 0.9.9" on
    # line 2 must NOT allow the gate to pass.  Only the first line is examined;
    # the second line (which contains the actual prism version) is not reached.
    # The first line ("DEBUG ... 1.75.0") would match the unanchored regex → WRONG-ALLOW.
    # After the anchored fix: the first line does not start with "prism <semver>" → exit 2.
    local tmpdir
    tmpdir="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nif [ "$1" = "--version" ]; then\n  printf '"'"'DEBUG [lib/core.rs:42] transport version 1.75.0\nprism 0.9.9\n'"'"'\nfi\n' \
        > "$tmpdir/prism"
    chmod +x "$tmpdir/prism"

    local actual_status=0
    PATH="$tmpdir:$PATH" bash "$PRISM_VERSION_CHECK" >/dev/null 2>&1 || actual_status=$?

    rm -rf "$tmpdir"

    # The debug line does NOT start with "prism <semver>", so exit 2 (cannot parse first line).
    # (The prism 0.9.9 line on line 2 is not examined — first-line-only policy.)
    [ "$actual_status" -eq 2 ]
}

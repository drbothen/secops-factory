#!/usr/bin/env bats
# secops-factory cross-platform parity tests
# Every hook ships as a .sh/.ps1 sibling pair. These tests feed identical
# payloads to both implementations and require identical stdout (JSON
# normalized via jq), stderr semantics, and exit codes.
#
# Requires pwsh (PowerShell Core). Skips gracefully when absent locally;
# CI runs on ubuntu-latest where pwsh is preinstalled.

PLUGIN_ROOT="${BATS_TEST_DIRNAME}/.."

require_pwsh() {
    if ! command -v pwsh &>/dev/null; then
        skip "pwsh not installed — parity tests run in CI"
    fi
}

# Run both siblings with the same stdin; store outputs and statuses.
run_pair() {
    local hook="$1" payload="$2"
    SH_OUT=$(echo "$payload" | bash "$PLUGIN_ROOT/hooks/$hook.sh" 2>/tmp/parity-sh-err); SH_STATUS=$?
    PS_OUT=$(echo "$payload" | pwsh -NoProfile -File "$PLUGIN_ROOT/hooks/$hook.ps1" 2>/tmp/parity-ps-err); PS_STATUS=$?
    SH_ERR=$(cat /tmp/parity-sh-err)
    PS_ERR=$(cat /tmp/parity-ps-err)
}

# Compare stdout as normalized JSON (key order independent).
assert_same_json() {
    [ -n "$SH_OUT" ] && [ -n "$PS_OUT" ]
    diff <(echo "$SH_OUT" | jq -S .) <(echo "$PS_OUT" | jq -S .)
}

@test "parity: every .sh hook has a .ps1 sibling" {
    for sh_hook in "$PLUGIN_ROOT"/hooks/*.sh; do
        base=$(basename "$sh_hook" .sh)
        [ -f "$PLUGIN_ROOT/hooks/$base.ps1" ]
    done
}

@test "parity: every .ps1 hook has a .sh sibling" {
    for ps_hook in "$PLUGIN_ROOT"/hooks/*.ps1; do
        base=$(basename "$ps_hook" .ps1)
        [ -f "$PLUGIN_ROOT/hooks/$base.sh" ]
    done
}

@test "parity: every script in scripts/ that is .sh or has no extension has a .ps1 sibling" {
    # SCRIPTS_ROOT is two levels up from the plugin: secops-factory/scripts/
    SCRIPTS_ROOT="$(cd "$PLUGIN_ROOT/../.." && pwd)/scripts"
    [ -d "$SCRIPTS_ROOT" ] || skip "scripts/ directory not found at $SCRIPTS_ROOT"
    for script in "$SCRIPTS_ROOT"/*; do
        [ -f "$script" ] || continue
        fname=$(basename "$script")
        # Skip .ps1 files (they are the counterparts we are checking FOR)
        [[ "$fname" == *.ps1 ]] && continue
        # Only enforce parity for .sh scripts and extension-less scripts
        if [[ "$fname" == *.sh ]]; then
            base="${fname%.sh}"
        else
            # Extension-less: treat as needing a .ps1 sibling
            [[ "$fname" == *.* ]] && continue  # skip other extensions (e.g., .py, .env)
            base="$fname"
        fi
        if [ ! -f "$SCRIPTS_ROOT/$base.ps1" ]; then
            echo "MISSING .ps1 counterpart for: scripts/$fname" >&2
            false
        fi
    done
}

@test "parity: every .ps1 script in scripts/ has a .sh or extension-less sibling" {
    SCRIPTS_ROOT="$(cd "$PLUGIN_ROOT/../.." && pwd)/scripts"
    [ -d "$SCRIPTS_ROOT" ] || skip "scripts/ directory not found at $SCRIPTS_ROOT"
    for ps_script in "$SCRIPTS_ROOT"/*.ps1; do
        [ -f "$ps_script" ] || continue
        base=$(basename "$ps_script" .ps1)
        # Accept either a .sh counterpart or an extension-less counterpart
        if [ ! -f "$SCRIPTS_ROOT/$base.sh" ] && [ ! -f "$SCRIPTS_ROOT/$base" ]; then
            echo "MISSING .sh or extension-less counterpart for: scripts/$base.ps1" >&2
            false
        fi
    done
}

@test "parity: hooks.json and hooks.json.windows declare the same hook set" {
    unix_hooks=$(jq -r '[.hooks[][].hooks[].command] | length' "$PLUGIN_ROOT/hooks/hooks.json")
    win_hooks=$(jq -r '[.hooks[][].hooks[].command] | length' "$PLUGIN_ROOT/hooks/hooks.json.windows")
    [ "$unix_hooks" = "$win_hooks" ]
    # Every windows command references a .ps1 sibling of a shipped .sh hook
    jq -r '.hooks[][].hooks[].command' "$PLUGIN_ROOT/hooks/hooks.json.windows" | while read -r cmd; do
        [[ "$cmd" == *"powershell.exe"* ]]
        [[ "$cmd" == *".ps1"* ]]
    done
}

@test "parity: require-review allow path" {
    require_pwsh
    run_pair require-review '{"tool_input": {"command": "ls -la"}}'
    [ "$SH_STATUS" -eq 0 ] && [ "$PS_STATUS" -eq 0 ]
    assert_same_json
}

@test "parity: require-review deny path" {
    require_pwsh
    run_pair require-review '{"tool_input": {"command": "jr issue edit SEC-1 --priority P1"}}'
    [ "$SH_STATUS" -eq 0 ] && [ "$PS_STATUS" -eq 0 ]
    assert_same_json
    [[ "$SH_OUT" == *'"permissionDecision":"deny"'* ]]
}

@test "parity: require-review read-only jr allow path" {
    require_pwsh
    run_pair require-review '{"tool_input": {"command": "jr issue view SEC-1"}}'
    [ "$SH_STATUS" -eq 0 ] && [ "$PS_STATUS" -eq 0 ]
    assert_same_json
}

@test "parity: enrichment-completeness allow (non-enrichment file)" {
    require_pwsh
    run_pair enrichment-completeness '{"tool_input": {"file_path": "/tmp/notes.md", "content": "hello"}}'
    [ "$SH_STATUS" -eq 0 ] && [ "$PS_STATUS" -eq 0 ]
    assert_same_json
}

@test "parity: enrichment-completeness deny (missing sections)" {
    require_pwsh
    run_pair enrichment-completeness '{"tool_input": {"file_path": "/tmp/enrichment-SEC-1.md", "content": "## Executive Summary\nonly this"}}'
    [ "$SH_STATUS" -eq 0 ] && [ "$PS_STATUS" -eq 0 ]
    assert_same_json
    [[ "$SH_OUT" == *'"permissionDecision":"deny"'* ]]
}

@test "parity: disposition-guard deny (disposition without alternatives)" {
    require_pwsh
    run_pair disposition-guard '{"tool_input": {"file_path": "/tmp/investigation-SEC-1.md", "content": "## Disposition\nTP high confidence"}}'
    [ "$SH_STATUS" -eq 0 ] && [ "$PS_STATUS" -eq 0 ]
    assert_same_json
    [[ "$SH_OUT" == *'"permissionDecision":"deny"'* ]]
}

@test "parity: disposition-guard allow (alternatives documented)" {
    require_pwsh
    run_pair disposition-guard '{"tool_input": {"file_path": "/tmp/investigation-SEC-1.md", "content": "## Disposition\nTP\n## Alternatives Considered\nFP: ruled out"}}'
    [ "$SH_STATUS" -eq 0 ] && [ "$PS_STATUS" -eq 0 ]
    assert_same_json
}

@test "parity: handoff-validator warns identically on empty result" {
    require_pwsh
    run_pair handoff-validator '{"result": ""}'
    [ "$SH_STATUS" -eq 0 ] && [ "$PS_STATUS" -eq 0 ]
    [ "$SH_ERR" = "$PS_ERR" ]
    [[ "$SH_ERR" == *"EMPTY output"* ]]
}

@test "parity: handoff-validator warns identically on short result" {
    require_pwsh
    run_pair handoff-validator '{"result": "looks fine"}'
    [ "$SH_STATUS" -eq 0 ] && [ "$PS_STATUS" -eq 0 ]
    [ "$SH_ERR" = "$PS_ERR" ]
    [[ "$SH_ERR" == *"suspiciously short"* ]]
}

@test "parity: bias-check-reminder stderr matches" {
    require_pwsh
    run_pair bias-check-reminder '{}'
    [ "$SH_STATUS" -eq 0 ] && [ "$PS_STATUS" -eq 0 ]
    [ "$SH_ERR" = "$PS_ERR" ]
}

@test "parity: session-greeting silent when not activated" {
    require_pwsh
    dir=$(mktemp -d)
    run_pair session-greeting "{\"cwd\": \"$dir\"}"
    [ "$SH_STATUS" -eq 0 ] && [ "$PS_STATUS" -eq 0 ]
    [ -z "$SH_OUT" ] && [ -z "$PS_OUT" ]
}

@test "parity: session-greeting greets identically when activated" {
    require_pwsh
    dir=$(mktemp -d)
    mkdir -p "$dir/.claude"
    echo '{"agent": "secops-factory:orchestrator:orchestrator"}' > "$dir/.claude/settings.local.json"
    run_pair session-greeting "{\"cwd\": \"$dir\"}"
    [ "$SH_STATUS" -eq 0 ] && [ "$PS_STATUS" -eq 0 ]
    assert_same_json
    [[ "$SH_OUT" == *"Morgan here"* ]]
}

# ---------------------------------------------------------------------------
# check-mcp-no-secrets parity tests
# ---------------------------------------------------------------------------

@test "check-mcp-no-secrets: .sh exits 0 on clean .mcp.json" {
    SCRIPTS_ROOT="$(cd "$PLUGIN_ROOT/../.." && pwd)/scripts"
    # Use template-based mktemp for macOS/Linux portability (no --suffix flag).
    clean_mcp=$(mktemp /tmp/check-mcp-clean-XXXXXX)
    printf '{"mcpServers":{"foo":{"type":"http","url":"https://api.example.com/mcp?key=${MY_KEY}"}}}\n' > "$clean_mcp"
    run bash "$SCRIPTS_ROOT/check-mcp-no-secrets.sh" "$clean_mcp"
    [ "$status" -eq 0 ]
    rm -f "$clean_mcp"
}

@test "check-mcp-no-secrets: .sh exits 1 when pplx- literal is present" {
    SCRIPTS_ROOT="$(cd "$PLUGIN_ROOT/../.." && pwd)/scripts"
    dirty_mcp=$(mktemp /tmp/check-mcp-dirty-XXXXXX)
    printf '{"mcpServers":{"perplexity":{"type":"http","headers":{"Authorization":"Bearer pplx-abc123defghijklmno"}}}}\n' > "$dirty_mcp"
    run bash "$SCRIPTS_ROOT/check-mcp-no-secrets.sh" "$dirty_mcp"
    [ "$status" -eq 1 ]
    rm -f "$dirty_mcp"
}

@test "check-mcp-no-secrets: .sh exits 1 when sk- generic literal is present" {
    SCRIPTS_ROOT="$(cd "$PLUGIN_ROOT/../.." && pwd)/scripts"
    dirty_mcp=$(mktemp /tmp/check-mcp-dirty-XXXXXX)
    printf '{"mcpServers":{"foo":{"type":"http","headers":{"Authorization":"Bearer sk-ABCDEFGHIJKLMNOPQRSTU"}}}}\n' > "$dirty_mcp"
    run bash "$SCRIPTS_ROOT/check-mcp-no-secrets.sh" "$dirty_mcp"
    [ "$status" -eq 1 ]
    rm -f "$dirty_mcp"
}

@test "check-mcp-no-secrets: .ps1 exits 0 on clean .mcp.json" {
    require_pwsh
    SCRIPTS_ROOT="$(cd "$PLUGIN_ROOT/../.." && pwd)/scripts"
    clean_mcp=$(mktemp /tmp/check-mcp-clean-XXXXXX)
    printf '{"mcpServers":{"foo":{"type":"http","url":"https://api.example.com/mcp?key=${MY_KEY}"}}}\n' > "$clean_mcp"
    run pwsh -NoProfile -File "$SCRIPTS_ROOT/check-mcp-no-secrets.ps1" "$clean_mcp"
    [ "$status" -eq 0 ]
    rm -f "$clean_mcp"
}

@test "check-mcp-no-secrets: .ps1 exits 1 when tvly- literal is present" {
    require_pwsh
    SCRIPTS_ROOT="$(cd "$PLUGIN_ROOT/../.." && pwd)/scripts"
    dirty_mcp=$(mktemp /tmp/check-mcp-dirty-XXXXXX)
    printf '{"mcpServers":{"tavily":{"type":"http","url":"https://api.tavily.com?tavilyApiKey=tvly-abc123defghijkl"}}}\n' > "$dirty_mcp"
    run pwsh -NoProfile -File "$SCRIPTS_ROOT/check-mcp-no-secrets.ps1" "$dirty_mcp"
    [ "$status" -eq 1 ]
    rm -f "$dirty_mcp"
}

# ---------------------------------------------------------------------------
# F2 parity: prism-version-check case-sensitive pre-release (VP-SKILL-051)
# ---------------------------------------------------------------------------
# Semver §11.4 requires case-sensitive ASCII comparison for pre-release identifiers.
# 'R' (0x52) < 'r' (0x72), so 1.0.0-RC.1 < 1.0.0-rc.1: an installed 1.0.0-RC.1 MUST
# NOT satisfy minimum 1.0.0-rc.1.
#
# sh (with LC_ALL=C): [[ "RC.1" > "rc.1" ]] is FALSE → exits 1 (correct).
# ps1 (-gt/-lt, culture-insensitive): "RC.1" == "rc.1" → returns equal → exits 0 (wrong).
#
# This test is RED in CI (where pwsh is available) until ps1 is fixed to use
# case-sensitive ordinal comparison (-cgt/-clt or CompareOrdinal).
# Skipped locally when pwsh is not installed (CI-only enforcement).

@test "parity: prism-version-check uppercase pre-release RC.1 halts on both platforms (F2, VP-SKILL-051)" {
    require_pwsh
    local tmpdir
    tmpdir="$(mktemp -d)"
    # Mock prism reporting an uppercase pre-release label (1.0.0-RC.1).
    # The bash shebang makes this mock executable on the Linux/macOS CI environment.
    printf '#!/usr/bin/env bash\nif [ "$1" = "--version" ]; then echo "prism 1.0.0-RC.1"; fi\n' \
        > "$tmpdir/prism"
    chmod +x "$tmpdir/prism"

    # Run sh with LC_ALL=C to ensure ASCII-ordinal comparison (not locale-dependent).
    SH_STATUS=0
    env LC_ALL=C PATH="$tmpdir:$PATH" bash "$PLUGIN_ROOT/hooks/prism-version-check.sh" \
        >/dev/null 2>&1 || SH_STATUS=$?

    # Run ps1 with the mock prism accessible in PATH.
    PS_STATUS=0
    env PATH="$tmpdir:$PATH" pwsh -NoProfile \
        -File "$PLUGIN_ROOT/hooks/prism-version-check.ps1" \
        >/dev/null 2>&1 || PS_STATUS=$?

    rm -rf "$tmpdir"

    # sh (LC_ALL=C): ASCII 'R' < 'r' → 1.0.0-RC.1 below min 1.0.0-rc.1 → exit 1
    [ "$SH_STATUS" -eq 1 ]
    # ps1 (-gt culture-insensitive): "RC.1" treated as equal to "rc.1" → exits 0 (wrong)
    # Assertion requires exit 1 → FAILS RED until ps1 uses ordinal/case-sensitive comparison
    [ "$PS_STATUS" -eq 1 ]
}

# ---------------------------------------------------------------------------
# F-1 parity (de-masked): prism-version-check production-invocation locale gap
# ---------------------------------------------------------------------------
# The existing test above forces env LC_ALL=C on the sh side, masking F-1: the
# production caller in SKILL.md:46 invokes sh with no locale override:
#
#   bash "${CLAUDE_PLUGIN_ROOT}/hooks/prism-version-check.sh"
#
# Under the system default locale (en_US.UTF-8 on this runner), bash [[ > ]] uses
# locale collation where uppercase letters sort AFTER lowercase ('R' > 'r'), so
# [[ "RC" > "rc" ]] is TRUE — semver_ge returns 0 (WRONG-ALLOW).
#
# This test mirrors the production invocation exactly and exposes the gap.
# Traced: F-1, BC-6.01.001 PC#8, VP-SKILL-051.
# Does NOT require pwsh — sh-only, exposes the sh locale gap directly.

@test "parity: prism-version-check production-invocation uppercase pre-release halts sh without caller locale (F-1, BC-6.01.001 PC#8, VP-SKILL-051)" {
    # RED (F-1): sh invoked as SKILL.md:46 does — no env LC_ALL=C override.
    # Under en_US.UTF-8, [[ "RC" > "rc" ]] → TRUE (locale collation) so semver_ge
    # returns 0 (WRONG-ALLOW) instead of 1. Gate must exit 1; currently exits 0.
    # Fails RED until prism-version-check.sh self-enforces LC_ALL=C internally.
    local tmpdir
    tmpdir="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nif [ "$1" = "--version" ]; then echo "prism 1.0.0-RC.1"; fi\n' \
        > "$tmpdir/prism"
    chmod +x "$tmpdir/prism"

    # Mirror SKILL.md:46 exactly — no LC_ALL override on the caller side.
    SH_STATUS=0
    PATH="$tmpdir:$PATH" bash "$PLUGIN_ROOT/hooks/prism-version-check.sh" \
        >/dev/null 2>&1 || SH_STATUS=$?

    rm -rf "$tmpdir"

    # Must halt (exit 1): semver §11.4 ASCII ordering requires 'R' (0x52) < 'r' (0x72).
    # RED until script self-enforces locale-neutral ordinal string comparison.
    [ "$SH_STATUS" -eq 1 ]
}

# ---------------------------------------------------------------------------
# Pass-2 F3 — sh semver_ge leading-zero numeric ordering (VP-SKILL-051)
# ---------------------------------------------------------------------------
# Replaces the coincidentally-passing "rc.08 passes gate" parity test.
# The old test only verified rc.08 passes a gate with minimum rc.1 (8 > 1 even
# with wrong octal interpretation) — it did not expose the real bug.
#
# Real bug: semver_ge uses (( _s1 > _s2 )) for numeric pre-release fields.
# Bash's (( )) arithmetic treats numbers with a leading zero as octal.
# '08' is not valid octal → bash emits "value too great for base (error token is
# "08")" to stderr; the arithmetic expression evaluates as false for BOTH
# (( 08 > 10 )) and (( 08 < 10 )), so the comparator falls through to return 0
# (equal). Consequence: semver_ge("1.0.0-rc.08", "1.0.0-rc.10") returns 0 (WRONG:
# should be 1, since decimal 8 < 10).
#
# This test extracts the semver_ge comparator directly and verifies correct ordering:
#   rc.08 < rc.10  → semver_ge("1.0.0-rc.08", "1.0.0-rc.10") must return 1
# and asserts that no "value too great for base" octal error is emitted.
# Traced: pass-2 F3, BC-6.01.001 PC#8, VP-SKILL-051.

@test "test_BC_6_01_001_F3_sh_semver_ge_rc08_lt_rc10_no_octal_error (pass-2 F3, BC-6.01.001 PC#8, VP-SKILL-051)" {
    # RED: (( 08 > 10 )) / (( 08 < 10 )) both fail with octal arithmetic error;
    # comparator falls through and returns 0 (WRONG-ALLOW). Must return 1 (rc.08 < rc.10).
    # Also: "value too great for base" must not appear in output.
    local tmpscript
    tmpscript="$(mktemp)"
    awk '/^semver_ge\(\) \{/,/^\}$/' "$PLUGIN_ROOT/hooks/prism-version-check.sh" > "$tmpscript"
    printf '\nsemver_ge '"'"'1.0.0-rc.08'"'"' '"'"'1.0.0-rc.10'"'"'\n' >> "$tmpscript"
    run bash "$tmpscript" 2>&1
    rm -f "$tmpscript"
    # rc.08 (decimal 8) < rc.10 (decimal 10): semver_ge must return 1 (not >=)
    [ "$status" -eq 1 ]
    # Octal arithmetic error must not be emitted
    [[ "$output" != *"value too great for base"* ]]
}

# ---------------------------------------------------------------------------
# Pass-2 F2 — ps1 exit-2 reachable: Write-Error terminating under Stop
# ---------------------------------------------------------------------------
# BC-6.01.001 PC#8 requires exit 2 for "tool missing" and "unparseable version"
# errors (distinguishable from exit 1 = "version too old").
# prism-version-check.ps1 sets $ErrorActionPreference = 'Stop' and then calls
# bare Write-Error before each 'exit 2'. Under Stop, Write-Error is TERMINATING:
# it throws a System.Management.Automation.ErrorRecord and 'exit 2' is never
# reached. The script exits 1 (unhandled terminating error), not 2.
#
# These CI-only tests verify the correct exit codes at runtime.
# Skipped locally when pwsh is absent (CI enforces with ubuntu-latest pwsh).
# Traced: pass-2 F2, BC-6.01.001 PC#8, VP-SKILL-051.

@test "test_BC_6_01_001_F2_ps1_prism_not_found_exits_2 (pass-2 F2, BC-6.01.001 PC#8, VP-SKILL-051)" {
    require_pwsh
    # RED: prism not in PATH → ps1 hits Write-Error 'not found in PATH' then exit 2.
    # Under $ErrorActionPreference='Stop', Write-Error is terminating; exit 2 is
    # unreachable. Script exits 1 (unhandled exception), not 2.
    # Must exit 2 to satisfy BC-6.01.001 PC#8 exit-code contract.
    run env PATH="/usr/bin:/bin" pwsh -NoProfile \
        -File "$PLUGIN_ROOT/hooks/prism-version-check.ps1" 2>&1
    [ "$status" -eq 2 ]
}

@test "test_BC_6_01_001_F2_ps1_unparseable_version_exits_2 (pass-2 F2, BC-6.01.001 PC#8, VP-SKILL-051)" {
    require_pwsh
    # RED: mock prism outputs non-semver string (exits 0) → ps1 regex match fails →
    # hits Write-Error 'could not parse' then exit 2. Under Stop, Write-Error is
    # terminating; exit 2 is unreachable. Script exits 1 instead of 2.
    local tmpdir
    tmpdir="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nif [ "$1" = "--version" ]; then printf "not-a-version"; fi\n' \
        > "$tmpdir/prism"
    chmod +x "$tmpdir/prism"
    run env PATH="$tmpdir:$PATH" pwsh -NoProfile \
        -File "$PLUGIN_ROOT/hooks/prism-version-check.ps1" 2>&1
    rm -rf "$tmpdir"
    # Must exit 2: parse failure is an error (BC-6.01.001 PC#8), not version mismatch.
    [ "$status" -eq 2 ]
}

# ---------------------------------------------------------------------------
# require-review marker-bearing parity tests (de-mask F3 false-greens)
#
# The existing parity tests above only feed marker-free vectors — no
# CLAUDE_PLUGIN_DATA is set, so neither .sh nor .ps1 enters the marker path.
# These new tests set up a real marker directory and feed marker-bearing
# commands, forcing both implementations through the marker-validation path.
# This exposes the divergence between the fully-ported .sh and the un-ported
# .ps1 (which has no marker logic): .sh allows; .ps1 denies.
#
# Tests are pwsh-gated (skip locally) and RED in CI until the .ps1 port is
# complete. They become GREEN when .sh and .ps1 emit identical JSON for
# every marker-bearing vector.
#
# Traceability: BC-3.01.001 v1.25 / F3 (finding) / D-020 / EC-023 / SM-37
# ---------------------------------------------------------------------------

# run_pair_with_env HOOK PAYLOAD PLUGIN_DATA — like run_pair but injects
# CLAUDE_PLUGIN_DATA so both hooks enter the marker-validation path.
run_pair_with_env() {
    local hook="$1" payload="$2" plugin_data="$3"
    SH_OUT=$(printf '%s' "$payload" | CLAUDE_PLUGIN_DATA="$plugin_data" bash "$PLUGIN_ROOT/hooks/$hook.sh" 2>/tmp/parity-sh-err); SH_STATUS=$?
    PS_OUT=$(printf '%s' "$payload" | CLAUDE_PLUGIN_DATA="$plugin_data" pwsh -NoProfile -File "$PLUGIN_ROOT/hooks/$hook.ps1" 2>/tmp/parity-ps-err); PS_STATUS=$?
    SH_ERR=$(cat /tmp/parity-sh-err)
    PS_ERR=$(cat /tmp/parity-ps-err)
}

# _parity_future_ts — ISO-8601 UTC +300s (cross-platform)
_parity_future_ts() {
    if date --version 2>/dev/null | grep -q GNU; then
        date -u -d '+300 seconds' '+%Y-%m-%dT%H:%M:%SZ'
    else
        date -u -v+300S '+%Y-%m-%dT%H:%M:%SZ'
    fi
}

@test "parity: require-review link command with valid link marker — marker-bearing divergence check" {
    # BC-3.01.001 v1.25 / F3 / D-020 / AC-001 / AC-005
    # Feeds a "jr issue link" command WITH a valid ["link"] marker to both hooks.
    # .sh (fully ported): consumes marker → emit allow.
    # .ps1 (un-ported): ignores marker (no marker logic) → deny from write-block.
    # assert_same_json FAILS on the divergence → test is RED in CI until port is done.
    # After port: both allow → JSON identical → test GREEN.
    require_pwsh
    local tmp marker_dir now future
    tmp=$(mktemp -d)
    marker_dir="${tmp}/markers"
    mkdir -p "$marker_dir"
    now=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    future=$(_parity_future_ts)
    printf '%s' "{\"marker_id\":\"m-par-link\",\"ticket_id\":\"SEC-300\",\"org_slug\":\"test\",\"authorized_operations\":[\"link\"],\"command_pattern\":\"^jr (--output json )?issue link SEC-300 SEC-400( |\\$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}" \
        > "${marker_dir}/link-par.marker.json"

    run_pair_with_env require-review \
        '{"tool_input":{"command":"jr issue link SEC-300 SEC-400"}}' \
        "$tmp"

    # .sh must allow (marker consumed) — assert so the failure is clearly diagnosable
    [ "$SH_STATUS" -eq 0 ] && [ "$PS_STATUS" -eq 0 ]
    [[ "$SH_OUT" == *'"permissionDecision":"allow"'* ]]

    # Parity gate: both must produce identical JSON — FAILS until ps1 port is done
    assert_same_json

    rm -rf "$tmp"
}

@test "parity: require-review create-review marker allows REVIEW-REQUIRED create — marker-bearing divergence check" {
    # BC-3.01.001 v1.25 / F3 / C1 / EC-023 direction A / D-DEC-012
    # Feeds "jr issue create --label REVIEW-REQUIRED" WITH a ["create-review"] marker.
    # .sh (ported): create-review marker authorizes review-labeled create → allow.
    # .ps1 (un-ported): no marker logic → deny from write-block → diverges.
    # assert_same_json FAILS → RED in CI; GREEN after port.
    require_pwsh
    local tmp marker_dir now future
    tmp=$(mktemp -d)
    marker_dir="${tmp}/markers"
    mkdir -p "$marker_dir"
    now=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    future=$(_parity_future_ts)
    printf '%s' "{\"marker_id\":\"m-par-crr\",\"ticket_id\":null,\"org_slug\":\"test\",\"authorized_operations\":[\"create-review\"],\"command_pattern\":\"^jr (--output json )?issue create --project PRISMDEMO( |\\$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}" \
        > "${marker_dir}/create-review-par.marker.json"

    run_pair_with_env require-review \
        '{"tool_input":{"command":"jr issue create --project PRISMDEMO --label REVIEW-REQUIRED --summary \"[REVIEW-REQUIRED] SEC-789 HIGH\""}}' \
        "$tmp"

    [ "$SH_STATUS" -eq 0 ] && [ "$PS_STATUS" -eq 0 ]
    # .sh must allow (create-review marker authorizes review-labeled create)
    [[ "$SH_OUT" == *'"permissionDecision":"allow"'* ]]

    # Parity gate — RED until port is done
    assert_same_json

    rm -rf "$tmp"
}

@test "parity: require-review regular create marker anti-fungibility REVIEW-REQUIRED — both deny, mechanism must agree post-port" {
    # BC-3.01.001 v1.25 / F3 / C1 / EC-023 direction B / SM-37 kill
    # Feeds "jr issue create --label REVIEW-REQUIRED" WITH a regular ["create"] marker.
    # Both .sh and .ps1 should deny (anti-fungibility: ["create"] cannot authorize
    # review-labeled create). .sh denies via STEP-6a structural label check.
    # .ps1 (un-ported): denies via write-block only (no marker, no STEP-6a check).
    # assert_same_json passes for deny outcome currently (both deny, same reason text).
    # This test ensures the parity holds for the anti-fungibility outcome post-port
    # and provides a regression guard. It is NOT a false-green because both deny.
    require_pwsh
    local tmp marker_dir now future
    tmp=$(mktemp -d)
    marker_dir="${tmp}/markers"
    mkdir -p "$marker_dir"
    now=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    future=$(_parity_future_ts)
    printf '%s' "{\"marker_id\":\"m-par-anti\",\"ticket_id\":null,\"org_slug\":\"test\",\"authorized_operations\":[\"create\"],\"command_pattern\":\"^jr (--output json )?issue create --project PRISMDEMO( |\\$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}" \
        > "${marker_dir}/create-anti-par.marker.json"

    run_pair_with_env require-review \
        '{"tool_input":{"command":"jr issue create --project PRISMDEMO --label REVIEW-REQUIRED --summary \"[REVIEW-REQUIRED] SEC-888 HIGH\""}}' \
        "$tmp"

    [ "$SH_STATUS" -eq 0 ] && [ "$PS_STATUS" -eq 0 ]
    [[ "$SH_OUT" == *'"permissionDecision":"deny"'* ]]
    [[ "$PS_OUT" == *'"permissionDecision":"deny"'* ]]

    # Both implementations must produce identical JSON for the deny case
    assert_same_json

    rm -rf "$tmp"
}

# ---------------------------------------------------------------------------
# F-1 (pass-2): case-sensitivity parity — mixed-case subcommand / pattern divergence
#
# Finding F-1: ps1 uses case-insensitive PowerShell operators (-like, -match, -eq)
# while sh uses case-sensitive bash operators (==, =~).
#
# Both tests are PWSH-GATED and RED in CI until ps1 is made case-sensitive.
# Traceability: BC-3.01.001 STEP-2 write-block + STEP-5 command_pattern / F-1 / SM-57
# ---------------------------------------------------------------------------

@test "parity: require-review F-1 uppercase LINK subcommand — sh fail-closed deny vs ps1 case-insensitive allow" {
    # F-1 / BC-3.01.001 STEP-2 / SM-57 write-block / case-sensitivity divergence (pass-2)
    #
    # Command: "jr issue LINK SEC-1 SEC-2" (uppercase subcommand), valid ["link"] marker.
    # sh (case-sensitive): write-block pattern *"jr issue link "* does NOT match uppercase
    #   LINK → falls through read-only list (no match) → fail-closed → DENY.
    # ps1 (case-insensitive): -like "*jr issue link *" MATCHES uppercase LINK →
    #   enters marker path → STEP-5 -match (case-insensitive) passes → ALLOW.
    # assert_same_json FAILS → RED in CI until ps1 uses case-sensitive operators.
    require_pwsh
    local tmp marker_dir now future
    tmp=$(mktemp -d)
    marker_dir="${tmp}/markers"
    mkdir -p "$marker_dir"
    now=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    future=$(_parity_future_ts)
    printf '%s' "{\"marker_id\":\"m-f1-uplink\",\"ticket_id\":\"SEC-1\",\"org_slug\":\"test\",\"authorized_operations\":[\"link\"],\"command_pattern\":\"^jr issue link SEC-1 SEC-2( |\\$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}" \
        > "${marker_dir}/f1-upper-subcommand.marker.json"

    run_pair_with_env require-review \
        '{"tool_input":{"command":"jr issue LINK SEC-1 SEC-2"}}' \
        "$tmp"

    [ "$SH_STATUS" -eq 0 ] && [ "$PS_STATUS" -eq 0 ]
    # sh must deny: case-sensitive write-block misses uppercase LINK → fail-closed
    [[ "$SH_OUT" == *'"permissionDecision":"deny"'* ]]

    # Parity gate: sh denies (fail-closed), ps1 allows (case-insensitive) → FAILS in CI
    assert_same_json

    rm -rf "$tmp"
}

@test "parity: require-review F-1 uppercase LINK in command_pattern — sh STEP-5 miss vs ps1 case-insensitive match" {
    # F-1 / BC-3.01.001 STEP-5 command_pattern match / case-sensitivity divergence (pass-2)
    #
    # Command: "jr issue link SEC-5 SEC-6" (normal lowercase), marker command_pattern
    # contains uppercase "LINK": ^jr issue LINK SEC-5 SEC-6( |$).
    # sh: write-block matches (lowercase ok), enters marker path, STEP-5 bash =~ is
    #   case-sensitive → "link" does NOT match "LINK" in pattern → marker skipped → DENY.
    # ps1: write-block matches, STEP-5 -match is case-insensitive → "link" MATCHES
    #   "LINK" pattern → ALLOW.
    # assert_same_json FAILS → RED in CI until ps1 uses case-sensitive -cmatch.
    require_pwsh
    local tmp marker_dir now future
    tmp=$(mktemp -d)
    marker_dir="${tmp}/markers"
    mkdir -p "$marker_dir"
    now=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    future=$(_parity_future_ts)
    # Uppercase "LINK" in command_pattern — matches case-insensitively in ps1, not in sh
    printf '%s' "{\"marker_id\":\"m-f1-uppatt\",\"ticket_id\":\"SEC-5\",\"org_slug\":\"test\",\"authorized_operations\":[\"link\"],\"command_pattern\":\"^jr issue LINK SEC-5 SEC-6( |\\$)\",\"issued_at_utc\":\"${now}\",\"expires_at_utc\":\"${future}\"}" \
        > "${marker_dir}/f1-upper-pattern.marker.json"

    run_pair_with_env require-review \
        '{"tool_input":{"command":"jr issue link SEC-5 SEC-6"}}' \
        "$tmp"

    [ "$SH_STATUS" -eq 0 ] && [ "$PS_STATUS" -eq 0 ]
    # sh must deny: STEP-5 bash =~ is case-sensitive, "link" does not match "LINK" pattern
    [[ "$SH_OUT" == *'"permissionDecision":"deny"'* ]]

    # Parity gate: sh denies (STEP-5 miss), ps1 allows (case-insensitive -match) → FAILS in CI
    assert_same_json

    rm -rf "$tmp"
}

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
# Leading-zero pre-release parity: 1.0.0-rc.08 (edge coverage, VP-SKILL-051)
# ---------------------------------------------------------------------------
# Semver disallows leading zeros in numeric identifiers, but both implementations
# must handle them consistently (fail-safe: treat 08 as integer 8, above minimum rc.1).
# This documents that sh and ps1 agree and neither accidentally blocks rc.08.
# Traced: BC-6.01.001 PC#8, VP-SKILL-051.

@test "parity: prism-version-check leading-zero pre-release rc.08 passes gate on both platforms (edge, BC-6.01.001 PC#8, VP-SKILL-051)" {
    require_pwsh
    local tmpdir
    tmpdir="$(mktemp -d)"
    printf '#!/usr/bin/env bash\nif [ "$1" = "--version" ]; then echo "prism 1.0.0-rc.08"; fi\n' \
        > "$tmpdir/prism"
    chmod +x "$tmpdir/prism"

    SH_STATUS=0
    env LC_ALL=C PATH="$tmpdir:$PATH" bash "$PLUGIN_ROOT/hooks/prism-version-check.sh" \
        >/dev/null 2>&1 || SH_STATUS=$?

    PS_STATUS=0
    env PATH="$tmpdir:$PATH" pwsh -NoProfile \
        -File "$PLUGIN_ROOT/hooks/prism-version-check.ps1" \
        >/dev/null 2>&1 || PS_STATUS=$?

    rm -rf "$tmpdir"

    # Both must agree: rc.08 → integer 8 > 1 (min rc.1) → satisfies gate → exit 0.
    [ "$SH_STATUS" -eq 0 ]
    [ "$PS_STATUS" -eq 0 ]
}

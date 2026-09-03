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

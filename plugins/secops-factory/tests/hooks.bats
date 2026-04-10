#!/usr/bin/env bats
# secops-factory hook tests
# Validates allow/block paths for all hooks using permissionDecision envelopes

PLUGIN_ROOT="${BATS_TEST_DIRNAME}/.."

# --- require-review hook ---

@test "require-review allows non-jr commands" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"ls -la\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "require-review allows jr read-only commands" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr issue view SEC-123\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "require-review allows jr issue comment" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr issue comment SEC-123 \\\"enrichment complete\\\"\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "require-review blocks jr issue edit without review" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr issue edit SEC-123 --priority Critical\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
    [[ "$output" == *"review approval"* ]]
}

@test "require-review blocks jr issue move without review" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr issue move SEC-123 Enriched\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

# --- enrichment-completeness hook ---

@test "enrichment-completeness allows non-enrichment files" {
    run bash -c 'echo "{\"tool_input\": {\"file_path\": \"/tmp/readme.md\", \"content\": \"hello\"}}" | "$1/hooks/enrichment-completeness.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "enrichment-completeness blocks incomplete enrichment" {
    run bash -c 'echo "{\"tool_input\": {\"file_path\": \"/tmp/enrichment-CVE-2024-1234.md\", \"content\": \"# Executive Summary\nSome text\"}}" | "$1/hooks/enrichment-completeness.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
    [[ "$output" == *"Missing required sections"* ]]
}

@test "enrichment-completeness allows complete enrichment" {
    CONTENT="# Executive Summary\n## Vulnerability Details\n## Severity Metrics\n## Priority Assessment\n## Remediation Guidance"
    run bash -c "echo '{\"tool_input\": {\"file_path\": \"/tmp/enrichment-CVE-2024-1234.md\", \"content\": \"$CONTENT\"}}' | \"\$1/hooks/enrichment-completeness.sh\"" -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

# --- bias-check-reminder hook (advisory, checks stderr) ---

@test "bias-check-reminder exits 0" {
    run bash -c 'echo "{}" | "$1/hooks/bias-check-reminder.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
}

@test "bias-check-reminder mentions confirmation bias on stderr" {
    local stderr_output
    stderr_output=$(echo '{}' | bash "$PLUGIN_ROOT/hooks/bias-check-reminder.sh" 2>&1 1>/dev/null)
    [[ "$stderr_output" == *"Confirmation bias"* ]] || [[ "$stderr_output" == *"confirmation bias"* ]]
}

@test "bias-check-reminder mentions anchoring bias on stderr" {
    local stderr_output
    stderr_output=$(echo '{}' | bash "$PLUGIN_ROOT/hooks/bias-check-reminder.sh" 2>&1 1>/dev/null)
    [[ "$stderr_output" == *"Anchoring bias"* ]] || [[ "$stderr_output" == *"anchoring bias"* ]]
}

# --- handoff-validator hook (SubagentStop, advisory) ---

@test "handoff-validator warns on empty result" {
    local stderr_output
    stderr_output=$(echo '{"result": ""}' | bash "$PLUGIN_ROOT/hooks/handoff-validator.sh" 2>&1 1>/dev/null)
    [[ "$stderr_output" == *"EMPTY output"* ]]
}

@test "handoff-validator warns on short result" {
    local stderr_output
    stderr_output=$(echo '{"result": "ok"}' | bash "$PLUGIN_ROOT/hooks/handoff-validator.sh" 2>&1 1>/dev/null)
    [[ "$stderr_output" == *"suspiciously short"* ]]
}

@test "handoff-validator silent on normal result" {
    local stderr_output
    stderr_output=$(echo '{"result": "Review complete. SUBSTANTIVE findings: 3 items requiring analyst attention. Overall quality score: 6.2/10."}' | bash "$PLUGIN_ROOT/hooks/handoff-validator.sh" 2>&1 1>/dev/null)
    [ -z "$stderr_output" ]
}

# --- disposition-guard hook (PreToolUse, blocking) ---

@test "disposition-guard allows non-investigation files" {
    run bash -c 'echo "{\"tool_input\": {\"file_path\": \"/tmp/readme.md\", \"content\": \"hello\"}}" | "$1/hooks/disposition-guard.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "disposition-guard allows investigation without disposition yet" {
    run bash -c 'echo "{\"tool_input\": {\"file_path\": \"/tmp/investigation-ALERT-001.md\", \"content\": \"# Alert Details\nSome evidence\"}}" | "$1/hooks/disposition-guard.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "disposition-guard blocks disposition without alternatives" {
    run bash -c 'echo "{\"tool_input\": {\"file_path\": \"/tmp/investigation-ALERT-001.md\", \"content\": \"# Disposition\nTrue Positive\n# Evidence\nSaw bad traffic\"}}" | "$1/hooks/disposition-guard.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
    [[ "$output" == *"Alternatives Considered"* ]]
}

@test "disposition-guard allows disposition with alternatives" {
    run bash -c 'echo "{\"tool_input\": {\"file_path\": \"/tmp/investigation-ALERT-001.md\", \"content\": \"# Disposition\nTrue Positive\n# Alternatives Considered\n1. FP due to scanner misconfiguration\n2. BTP from authorized pen test\"}}" | "$1/hooks/disposition-guard.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

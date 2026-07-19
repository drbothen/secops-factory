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

@test "require-review allows jr issue changelog plain form" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr issue changelog SEC-123\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "require-review allows jr issue changelog json form (metrics suite)" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr --output json issue changelog SEC-123\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "require-review allows jr --output json issue view (metrics suite)" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr --output json issue view SEC-123\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "require-review allows jr --output json issue list (metrics suite)" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr --output json issue list --jql project=SEC\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "require-review allows jr --output json issue comments (metrics suite)" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr --output json issue comments SEC-123\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "require-review allows jr assets search (CMDB)" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr --output json assets search objectType=Client\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "require-review allows jr assets view (CMDB)" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr --output json assets view SEC-001\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "require-review allows jr --version health check" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr --version\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "require-review blocks jr issue comment without review (SEC-001)" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr issue comment SEC-123 \\\"enrichment complete\\\"\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
    [[ "$output" == *"review approval"* ]]
}

@test "require-review blocks unknown mutation-shaped jr subcommand (SEC-002)" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr issue duplicate SEC-123\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
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

# --- ADV-0-801: precedence-bypass tests ---
# Write commands whose ARGUMENTS contain read-only allowlist tokens must still be DENIED.
# Previously the allowlist was evaluated before the write-block, so a write command
# whose argument string contained e.g. "jr board" would fire emit_allow before reaching
# the deny block. Correct ordering: write-block (deny) BEFORE allowlist (allow).

@test "require-review blocks edit with jr board in args (ADV-0-801 bypass)" {
    # 'jr board' substring appears in --summary arg; must still deny
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr issue edit SEC-1 --summary \\\"see jr board\\\"\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "require-review blocks comment with jr me in args (ADV-0-801 bypass — defeats SEC-001)" {
    # 'jr me' substring appears in comment body; must still deny
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr issue comment SEC-1 \\\"resolved per jr me policy\\\"\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "require-review blocks create with jr sprint in args (ADV-0-801 bypass)" {
    # 'jr sprint' substring appears in --summary arg; must still deny
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr issue create --project SEC --summary \\\"jr sprint planning\\\"\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "require-review blocks move with jr project in args (ADV-0-801 bypass)" {
    # 'jr project' substring appears in destination arg; must still deny
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr issue move SEC-1 \\\"jr project X\\\"\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

# --output json write forms — Invariant #4: plain write substring does NOT match
# when --output json global flag appears between "jr" and "issue".
# These must be explicitly listed in the write-block.

@test "require-review blocks jr --output json issue edit (write via --output json)" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr --output json issue edit SEC-1 --priority Critical\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "require-review blocks jr --output json issue create (write via --output json)" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr --output json issue create --project SEC --summary test\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "require-review blocks jr --output json issue comment (write via --output json)" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr --output json issue comment SEC-1 \\\"test\\\"\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "require-review blocks jr --output json issue move (write via --output json)" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr --output json issue move SEC-1 Done\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "require-review blocks jr --output json issue assign (write via --output json)" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr --output json issue assign SEC-1 user@example.com\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

# Regression: legitimate read-only must still be ALLOWED after the fix.

@test "require-review regression: jr issue view still allowed after ADV-0-801 fix" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr issue view SEC-1\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "require-review regression: jr --output json issue list still allowed after ADV-0-801 fix" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr --output json issue list --jql project=SEC\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "require-review regression: jr issue changelog still allowed after ADV-0-801 fix" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr issue changelog SEC-1\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"allow"'* ]]
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

# --- session-greeting hook (SessionStart, activation-gated) ---

setup_greeting_project() {
    GREET_DIR=$(mktemp -d)
    mkdir -p "$GREET_DIR/.claude"
}

@test "session-greeting is silent when settings.local.json is absent" {
    GREET_DIR=$(mktemp -d)
    run bash -c 'echo "{\"cwd\": \"$2\"}" | "$1/hooks/session-greeting.sh"' -- "$PLUGIN_ROOT" "$GREET_DIR"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "session-greeting is silent when factory is not activated" {
    setup_greeting_project
    echo '{"agent": "vsdd-factory:orchestrator:orchestrator"}' > "$GREET_DIR/.claude/settings.local.json"
    run bash -c 'echo "{\"cwd\": \"$2\"}" | "$1/hooks/session-greeting.sh"' -- "$PLUGIN_ROOT" "$GREET_DIR"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "session-greeting greets when factory is activated" {
    setup_greeting_project
    echo '{"agent": "secops-factory:orchestrator:orchestrator"}' > "$GREET_DIR/.claude/settings.local.json"
    run bash -c 'echo "{\"cwd\": \"$2\"}" | "$1/hooks/session-greeting.sh"' -- "$PLUGIN_ROOT" "$GREET_DIR"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"systemMessage"'* ]]
    [[ "$output" == *"Morgan here"* ]]
    [[ "$output" == *'"hookEventName":"SessionStart"'* ]]
    [[ "$output" == *'"additionalContext"'* ]]
}

@test "session-greeting emits valid JSON when activated" {
    setup_greeting_project
    echo '{"agent": "secops-factory:orchestrator:orchestrator"}' > "$GREET_DIR/.claude/settings.local.json"
    run bash -c 'echo "{\"cwd\": \"$2\"}" | "$1/hooks/session-greeting.sh" | jq .' -- "$PLUGIN_ROOT" "$GREET_DIR"
    [ "$status" -eq 0 ]
}

@test "session-greeting survives corrupt settings.local.json" {
    setup_greeting_project
    echo 'this is not json {' > "$GREET_DIR/.claude/settings.local.json"
    run bash -c 'echo "{\"cwd\": \"$2\"}" | "$1/hooks/session-greeting.sh"' -- "$PLUGIN_ROOT" "$GREET_DIR"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

# --- DI-004: disposition-guard heading-anchored fix ---
# Body text that merely mentions "Alternatives Considered" must NOT satisfy the
# anti-confirmation-bias gate; only a markdown heading does.

@test "disposition-guard body-text alternatives-considered (no heading) denies" {
    # RED: substring "Alternatives Considered" in body text — no heading present
    run bash -c 'echo "{\"tool_input\": {\"file_path\": \"/tmp/investigation-ALERT-001.md\", \"content\": \"# Disposition\nTrue Positive\n\nno Alternatives Considered needed here\"}}" | "$1/hooks/disposition-guard.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "disposition-guard heading-form alternatives-considered allows" {
    # GREEN: proper heading satisfies the gate
    run bash -c 'echo "{\"tool_input\": {\"file_path\": \"/tmp/investigation-ALERT-001.md\", \"content\": \"# Disposition\nTrue Positive\n## Alternatives Considered\n1. FP: ruled out\"}}" | "$1/hooks/disposition-guard.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

# --- DI-014: enrichment-completeness heading-anchored fix ---
# Section names mentioned in body prose must NOT pass the completeness gate.

@test "enrichment-completeness body-text section names (no headings) denies for enrichment" {
    # RED: all required section names appear in prose — no headings present
    run bash -c 'echo "{\"tool_input\": {\"file_path\": \"/tmp/enrichment-CVE-2024-1234.md\", \"content\": \"This covers Executive Summary, Vulnerability Details, Severity Metrics, Priority Assessment, and Remediation Guidance in prose only.\"}}" | "$1/hooks/enrichment-completeness.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "enrichment-completeness body-text section names (no headings) denies for investigation" {
    # RED: all required investigation section names appear in prose — no headings present
    run bash -c 'echo "{\"tool_input\": {\"file_path\": \"/tmp/investigation-ALERT-001.md\", \"content\": \"This covers Executive Summary, Alert Details, Disposition, and Next Actions in prose only.\"}}" | "$1/hooks/enrichment-completeness.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

# --- DI-007a: enrichment-completeness investigation branch coverage ---
# All 4 investigation sections: allow when all present, deny when any missing.

@test "enrichment-completeness allows complete investigation document" {
    CONTENT="# Executive Summary\n## Alert Details\n## Disposition\n## Next Actions"
    run bash -c "echo '{\"tool_input\": {\"file_path\": \"/tmp/investigation-ALERT-001.md\", \"content\": \"$CONTENT\"}}' | \"\$1/hooks/enrichment-completeness.sh\"" -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"allow"'* ]]
}

@test "enrichment-completeness denies investigation missing Alert Details" {
    CONTENT="# Executive Summary\n## Disposition\n## Next Actions"
    run bash -c "echo '{\"tool_input\": {\"file_path\": \"/tmp/investigation-ALERT-001.md\", \"content\": \"$CONTENT\"}}' | \"\$1/hooks/enrichment-completeness.sh\"" -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "enrichment-completeness denies investigation missing Next Actions" {
    CONTENT="# Executive Summary\n## Alert Details\n## Disposition"
    run bash -c "echo '{\"tool_input\": {\"file_path\": \"/tmp/investigation-ALERT-001.md\", \"content\": \"$CONTENT\"}}' | \"\$1/hooks/enrichment-completeness.sh\"" -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "enrichment-completeness denies investigation missing Disposition" {
    CONTENT="# Executive Summary\n## Alert Details\n## Next Actions"
    run bash -c "echo '{\"tool_input\": {\"file_path\": \"/tmp/investigation-ALERT-001.md\", \"content\": \"$CONTENT\"}}' | \"\$1/hooks/enrichment-completeness.sh\"" -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

@test "enrichment-completeness denies investigation missing Executive Summary" {
    CONTENT="## Alert Details\n## Disposition\n## Next Actions"
    run bash -c "echo '{\"tool_input\": {\"file_path\": \"/tmp/investigation-ALERT-001.md\", \"content\": \"$CONTENT\"}}' | \"\$1/hooks/enrichment-completeness.sh\"" -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
}

# --- DI-007b: hook section-name / template title sync guard ---
# Every section name hardcoded in the hooks must appear as a template section
# title. If the template is renamed and the hook is not updated this test breaks.

@test "enrichment-completeness hook enrichment sections match security-enrichment template" {
    for section in "Executive Summary" "Vulnerability Details" "Severity Metrics" "Priority Assessment" "Remediation Guidance"; do
        grep -qF "title: $section" "$PLUGIN_ROOT/templates/security-enrichment-tmpl.yaml"
    done
}

@test "enrichment-completeness hook investigation sections match event-investigation template" {
    for section in "Executive Summary" "Alert Details" "Disposition" "Next Actions"; do
        grep -qF "title: $section" "$PLUGIN_ROOT/templates/event-investigation-tmpl.yaml"
    done
}

# --- DI-007c: handoff-validator 39/40-char boundary ---

@test "handoff-validator warns on 39-char result (lower boundary)" {
    local result stderr_output
    result=$(printf '%39s' | tr ' ' 'x')
    stderr_output=$(echo "{\"result\": \"$result\"}" | bash "$PLUGIN_ROOT/hooks/handoff-validator.sh" 2>&1 1>/dev/null)
    [[ "$stderr_output" == *"suspiciously short"* ]]
}

@test "handoff-validator silent on 40-char result (boundary)" {
    local result stderr_output
    result=$(printf '%40s' | tr ' ' 'x')
    stderr_output=$(echo "{\"result\": \"$result\"}" | bash "$PLUGIN_ROOT/hooks/handoff-validator.sh" 2>&1 1>/dev/null)
    [ -z "$stderr_output" ]
}

# --- DI-005: require-review explicit positive-deny for assign and create ---

@test "require-review blocks jr issue assign without review (DI-005)" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr issue assign SEC-1 user@example.com\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
    [[ "$output" == *"review approval"* ]]
}

@test "require-review blocks jr issue create without review (DI-005)" {
    run bash -c 'echo "{\"tool_input\": {\"command\": \"jr issue create --project SEC --type Bug --summary test\"}}" | "$1/hooks/require-review.sh"' -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    [[ "$output" == *'"permissionDecision":"deny"'* ]]
    [[ "$output" == *"review approval"* ]]
}

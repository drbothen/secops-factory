#!/usr/bin/env bats
# secops-factory hook tests
# Validates allow/block paths for all 3 hooks

PLUGIN_ROOT="${BATS_TEST_DIRNAME}/.."

# --- require-review hook ---

@test "require-review allows comment-only operations" {
    echo '{"tool_input": {}}' | bash "$PLUGIN_ROOT/hooks/require-review.sh" | grep -qF '"allow"'
}

@test "require-review blocks field updates without review" {
    echo '{"tool_input": {"fields": {"priority": {"name": "Critical"}}}}' | bash "$PLUGIN_ROOT/hooks/require-review.sh" | grep -qF '"block"'
}

@test "require-review allows field updates with review approval" {
    echo '{"tool_input": {"fields": {"priority": {"name": "Critical"}}, "metadata": {"review_approved": true}}}' | bash "$PLUGIN_ROOT/hooks/require-review.sh" | grep -qF '"allow"'
}

# --- enrichment-completeness hook ---

@test "enrichment-completeness allows non-enrichment files" {
    echo '{"tool_input": {"file_path": "/tmp/readme.md", "content": "hello"}}' | bash "$PLUGIN_ROOT/hooks/enrichment-completeness.sh" | grep -qF '"allow"'
}

@test "enrichment-completeness blocks incomplete enrichment" {
    echo '{"tool_input": {"file_path": "/tmp/enrichment-CVE-2024-1234.md", "content": "# Executive Summary\nSome text"}}' | bash "$PLUGIN_ROOT/hooks/enrichment-completeness.sh" | grep -qF '"block"'
}

@test "enrichment-completeness allows complete enrichment" {
    CONTENT="# Executive Summary\n## Vulnerability Details\n## Severity Metrics\n## Priority Assessment\n## Remediation Guidance"
    echo "{\"tool_input\": {\"file_path\": \"/tmp/enrichment-CVE-2024-1234.md\", \"content\": \"$CONTENT\"}}" | bash "$PLUGIN_ROOT/hooks/enrichment-completeness.sh" | grep -qF '"allow"'
}

# --- bias-check-reminder hook ---

@test "bias-check-reminder outputs message" {
    echo '{}' | bash "$PLUGIN_ROOT/hooks/bias-check-reminder.sh" | grep -qF '"message"'
}

@test "bias-check-reminder mentions confirmation bias" {
    echo '{}' | bash "$PLUGIN_ROOT/hooks/bias-check-reminder.sh" | grep -qF 'confirmation bias'
}

@test "bias-check-reminder mentions anchoring bias" {
    echo '{}' | bash "$PLUGIN_ROOT/hooks/bias-check-reminder.sh" | grep -qF 'anchoring bias'
}

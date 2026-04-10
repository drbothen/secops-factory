#!/usr/bin/env bats
# integration.bats — Tests hooks with Claude Code's EXACT stdin/stdout protocol
#
# These tests use the full JSON shape Claude Code sends to hooks (BC-DRAFT-H04),
# NOT simplified test payloads. Each test documents the BC it validates.

PLUGIN_ROOT="${BATS_TEST_DIRNAME}/.."

# BC-DRAFT-H04: Hook scripts receive stdin JSON with common fields:
# {session_id, transcript_path, cwd, permission_mode, hook_event_name, tool_name, tool_input}
# The tool_input varies by tool.

# ==========================================================================
# require-review.sh — BC-DRAFT-H11 permissionDecision envelope
# ==========================================================================

@test "integration: require-review denies jr issue edit with full Claude Code payload" {
    # Simulates what Claude Code sends when the agent calls Bash with jr issue edit
    PAYLOAD='{
      "session_id": "sess_abc123",
      "transcript_path": "/tmp/transcript.jsonl",
      "cwd": "/Users/test/project",
      "permission_mode": "default",
      "hook_event_name": "PreToolUse",
      "tool_name": "Bash",
      "tool_input": {
        "command": "jr issue edit SEC-1234 --priority Critical"
      }
    }'
    run bash -c "echo '$PAYLOAD' | \"\$1/hooks/require-review.sh\"" -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    # BC-DRAFT-H11: must emit hookSpecificOutput with permissionDecision
    echo "$output" | jq -e '.hookSpecificOutput.permissionDecision == "deny"'
    echo "$output" | jq -e '.hookSpecificOutput.permissionDecisionReason | length > 0'
}

@test "integration: require-review allows jr issue view with full payload" {
    PAYLOAD='{
      "session_id": "sess_abc123",
      "transcript_path": "/tmp/transcript.jsonl",
      "cwd": "/Users/test/project",
      "permission_mode": "default",
      "hook_event_name": "PreToolUse",
      "tool_name": "Bash",
      "tool_input": {
        "command": "jr issue view SEC-1234"
      }
    }'
    run bash -c "echo '$PAYLOAD' | \"\$1/hooks/require-review.sh\"" -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    echo "$output" | jq -e '.hookSpecificOutput.permissionDecision == "allow"'
}

# ==========================================================================
# enrichment-completeness.sh — BC-DRAFT-H11 + content validation
# ==========================================================================

@test "integration: enrichment-completeness blocks partial Write with full payload" {
    PAYLOAD='{
      "session_id": "sess_def456",
      "transcript_path": "/tmp/transcript.jsonl",
      "cwd": "/Users/test/project",
      "permission_mode": "default",
      "hook_event_name": "PreToolUse",
      "tool_name": "Write",
      "tool_input": {
        "file_path": "/Users/test/project/.factory/enrichment-CVE-2024-9999.md",
        "content": "# Executive Summary\nCritical RCE in widget parser.\n\n## Vulnerability Details\nCVE-2024-9999 affects widget v3.x."
      }
    }'
    run bash -c "echo '$PAYLOAD' | \"\$1/hooks/enrichment-completeness.sh\"" -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    echo "$output" | jq -e '.hookSpecificOutput.permissionDecision == "deny"'
    echo "$output" | jq -e '.hookSpecificOutput.permissionDecisionReason | contains("Missing required sections")'
}

@test "integration: enrichment-completeness allows complete Write with full payload" {
    PAYLOAD='{
      "session_id": "sess_def456",
      "transcript_path": "/tmp/transcript.jsonl",
      "cwd": "/Users/test/project",
      "permission_mode": "default",
      "hook_event_name": "PreToolUse",
      "tool_name": "Write",
      "tool_input": {
        "file_path": "/Users/test/project/.factory/enrichment-CVE-2024-9999.md",
        "content": "# Executive Summary\nCritical RCE.\n\n## Vulnerability Details\nCVE-2024-9999.\n\n## Severity Metrics\nCVSS 9.8.\n\n## Priority Assessment\nP1 Critical.\n\n## Remediation Guidance\nPatch to v4.0."
      }
    }'
    run bash -c "echo '$PAYLOAD' | \"\$1/hooks/enrichment-completeness.sh\"" -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    echo "$output" | jq -e '.hookSpecificOutput.permissionDecision == "allow"'
}

@test "integration: enrichment-completeness ignores non-enrichment Write" {
    PAYLOAD='{
      "session_id": "sess_def456",
      "transcript_path": "/tmp/transcript.jsonl",
      "cwd": "/Users/test/project",
      "permission_mode": "default",
      "hook_event_name": "PreToolUse",
      "tool_name": "Write",
      "tool_input": {
        "file_path": "/Users/test/project/README.md",
        "content": "# Hello World"
      }
    }'
    run bash -c "echo '$PAYLOAD' | \"\$1/hooks/enrichment-completeness.sh\"" -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    echo "$output" | jq -e '.hookSpecificOutput.permissionDecision == "allow"'
}

# ==========================================================================
# disposition-guard.sh — BC-DRAFT-H11 + anti-confirmation-bias gate
# ==========================================================================

@test "integration: disposition-guard blocks disposition without alternatives" {
    PAYLOAD='{
      "session_id": "sess_ghi789",
      "transcript_path": "/tmp/transcript.jsonl",
      "cwd": "/Users/test/project",
      "permission_mode": "default",
      "hook_event_name": "PreToolUse",
      "tool_name": "Write",
      "tool_input": {
        "file_path": "/Users/test/project/.factory/investigation-ALERT-2024-001.md",
        "content": "# Executive Summary\nSuspicious traffic detected.\n\n## Alert Details\nSnort rule SID:1000001.\n\n## Disposition\nTrue Positive — confirmed C2 beacon.\n\n## Next Actions\nIsolate host."
      }
    }'
    run bash -c "echo '$PAYLOAD' | \"\$1/hooks/disposition-guard.sh\"" -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    echo "$output" | jq -e '.hookSpecificOutput.permissionDecision == "deny"'
    echo "$output" | jq -e '.hookSpecificOutput.permissionDecisionReason | contains("Alternatives Considered")'
}

@test "integration: disposition-guard allows disposition with alternatives" {
    PAYLOAD='{
      "session_id": "sess_ghi789",
      "transcript_path": "/tmp/transcript.jsonl",
      "cwd": "/Users/test/project",
      "permission_mode": "default",
      "hook_event_name": "PreToolUse",
      "tool_name": "Write",
      "tool_input": {
        "file_path": "/Users/test/project/.factory/investigation-ALERT-2024-001.md",
        "content": "# Executive Summary\nSuspicious traffic.\n\n## Alert Details\nSnort SID:1000001.\n\n## Alternatives Considered\n1. FP from misconfigured proxy\n2. BTP from authorized vuln scan\n\n## Disposition\nTrue Positive.\n\n## Next Actions\nIsolate."
      }
    }'
    run bash -c "echo '$PAYLOAD' | \"\$1/hooks/disposition-guard.sh\"" -- "$PLUGIN_ROOT"
    [ "$status" -eq 0 ]
    echo "$output" | jq -e '.hookSpecificOutput.permissionDecision == "allow"'
}

# ==========================================================================
# handoff-validator.sh — BC-DRAFT-H12 SubagentStop advisory
# ==========================================================================

@test "integration: handoff-validator warns on empty SubagentStop payload" {
    PAYLOAD='{
      "session_id": "sess_jkl012",
      "transcript_path": "/tmp/transcript.jsonl",
      "cwd": "/Users/test/project",
      "permission_mode": "default",
      "hook_event_name": "SubagentStop",
      "result": ""
    }'
    local stderr_output
    stderr_output=$(echo "$PAYLOAD" | bash "$PLUGIN_ROOT/hooks/handoff-validator.sh" 2>&1 1>/dev/null)
    [[ "$stderr_output" == *"EMPTY output"* ]]
}

@test "integration: handoff-validator silent on substantive SubagentStop result" {
    PAYLOAD='{
      "session_id": "sess_jkl012",
      "transcript_path": "/tmp/transcript.jsonl",
      "cwd": "/Users/test/project",
      "permission_mode": "default",
      "hook_event_name": "SubagentStop",
      "result": "Review complete. SECOPS-P1 findings: 4 SUBSTANTIVE items. Overall quality score: 6.8/10. Dimensions below threshold: Technical Accuracy (4.5/10), Completeness (4.8/10). Recommendation: REWORK REQUIRED."
    }'
    local stderr_output
    stderr_output=$(echo "$PAYLOAD" | bash "$PLUGIN_ROOT/hooks/handoff-validator.sh" 2>&1 1>/dev/null)
    [ -z "$stderr_output" ]
}

# ==========================================================================
# Output format validation — BC-DRAFT-H11 envelope structure
# ==========================================================================

@test "integration: all blocking hooks emit valid JSON with hookSpecificOutput" {
    # require-review deny (jr issue edit)
    out1=$(echo '{"tool_input":{"command":"jr issue edit SEC-1 --priority High"}}' | bash "$PLUGIN_ROOT/hooks/require-review.sh")
    echo "$out1" | jq -e '.hookSpecificOutput.hookEventName == "PreToolUse"'
    echo "$out1" | jq -e '.hookSpecificOutput | has("permissionDecision")'

    # enrichment-completeness deny
    out2=$(echo '{"tool_input":{"file_path":"/tmp/enrichment-x.md","content":"# Executive Summary"}}' | bash "$PLUGIN_ROOT/hooks/enrichment-completeness.sh")
    echo "$out2" | jq -e '.hookSpecificOutput.hookEventName == "PreToolUse"'

    # disposition-guard deny
    out3=$(echo '{"tool_input":{"file_path":"/tmp/investigation-x.md","content":"# Disposition\nTP"}}' | bash "$PLUGIN_ROOT/hooks/disposition-guard.sh")
    echo "$out3" | jq -e '.hookSpecificOutput.hookEventName == "PreToolUse"'
}

@test "integration: all allow envelopes emit valid JSON with hookSpecificOutput" {
    # require-review allow (non-jr command)
    out1=$(echo '{"tool_input":{"command":"ls -la"}}' | bash "$PLUGIN_ROOT/hooks/require-review.sh")
    echo "$out1" | jq -e '.hookSpecificOutput.permissionDecision == "allow"'

    # enrichment-completeness allow (non-enrichment file)
    out2=$(echo '{"tool_input":{"file_path":"/tmp/readme.md","content":"hi"}}' | bash "$PLUGIN_ROOT/hooks/enrichment-completeness.sh")
    echo "$out2" | jq -e '.hookSpecificOutput.permissionDecision == "allow"'

    # disposition-guard allow (non-investigation file)
    out3=$(echo '{"tool_input":{"file_path":"/tmp/readme.md","content":"hi"}}' | bash "$PLUGIN_ROOT/hooks/disposition-guard.sh")
    echo "$out3" | jq -e '.hookSpecificOutput.permissionDecision == "allow"'
}

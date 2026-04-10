#!/usr/bin/env bash
# Hook: require-review
# Type: PreToolUse on mcp__atlassian__updateJiraIssue
# Purpose: Block JIRA field updates without review approval marker
#
# The update-jira skill requires review approval before modifying tickets.
# This hook enforces that gate by checking for a review-approval marker
# in the tool input context.

set -euo pipefail

# Read the hook input from stdin (JSON with tool_name, tool_input)
INPUT=$(cat)

# Extract the tool input for inspection
TOOL_INPUT=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
tool_input = json.dumps(data.get('tool_input', {}))
print(tool_input)
" 2>/dev/null || echo "{}")

# Check if this is a comment-only operation (allowed without review)
IS_COMMENT=$(echo "$TOOL_INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
# If only adding a comment (no fields being updated), allow
fields = data.get('fields', {})
if not fields:
    print('true')
else:
    print('false')
" 2>/dev/null || echo "false")

if [ "$IS_COMMENT" = "true" ]; then
    # Allow comment-only operations (enrichment posting)
    cat <<'EOF'
{"decision": "allow", "reason": "Comment-only operation, no field updates"}
EOF
    exit 0
fi

# For field updates, check if the conversation context contains review approval
# The review-enrichment skill sets a marker when review passes quality thresholds
# Since hooks cannot read conversation state, we check for a review marker
# in the tool input metadata
HAS_REVIEW=$(echo "$TOOL_INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
# Check for review_approved flag in metadata
metadata = data.get('metadata', {})
if metadata.get('review_approved', False):
    print('true')
else:
    print('false')
" 2>/dev/null || echo "false")

if [ "$HAS_REVIEW" = "true" ]; then
    cat <<'EOF'
{"decision": "allow", "reason": "Review approval marker present"}
EOF
else
    cat <<'EOF'
{"decision": "block", "reason": "JIRA field updates require review approval. Run /review-enrichment first to validate analysis quality before updating ticket fields."}
EOF
fi

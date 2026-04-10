#!/usr/bin/env bash
# Hook: enrichment-completeness
# Type: PreToolUse on Write
# Purpose: Block saving partial enrichment as complete
#
# When writing enrichment documents, verify that all required sections
# are populated before allowing the save.

set -euo pipefail

INPUT=$(cat)

# Extract file path from tool input
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('file_path', ''))
" 2>/dev/null || echo "")

# Only check enrichment files
if [[ "$FILE_PATH" != *"enrichment"* ]] && [[ "$FILE_PATH" != *"investigation"* ]]; then
    cat <<'EOF'
{"decision": "allow", "reason": "Not an enrichment file"}
EOF
    exit 0
fi

# Extract content to check for completeness markers
CONTENT=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('content', ''))
" 2>/dev/null || echo "")

# Check for required sections in enrichment documents
if [[ "$FILE_PATH" == *"enrichment"* ]]; then
    MISSING_SECTIONS=""
    for section in "Executive Summary" "Vulnerability Details" "Severity Metrics" "Priority Assessment" "Remediation Guidance"; do
        if ! echo "$CONTENT" | grep -qF "$section"; then
            MISSING_SECTIONS="${MISSING_SECTIONS}${section}, "
        fi
    done

    if [ -n "$MISSING_SECTIONS" ]; then
        MISSING_SECTIONS="${MISSING_SECTIONS%, }"
        cat <<EOF
{"decision": "block", "reason": "Incomplete enrichment document. Missing required sections: ${MISSING_SECTIONS}. Complete all 8 enrichment stages before saving."}
EOF
        exit 0
    fi
fi

# Check for required sections in investigation documents
if [[ "$FILE_PATH" == *"investigation"* ]]; then
    MISSING_SECTIONS=""
    for section in "Executive Summary" "Alert Details" "Disposition" "Next Actions"; do
        if ! echo "$CONTENT" | grep -qF "$section"; then
            MISSING_SECTIONS="${MISSING_SECTIONS}${section}, "
        fi
    done

    if [ -n "$MISSING_SECTIONS" ]; then
        MISSING_SECTIONS="${MISSING_SECTIONS%, }"
        cat <<EOF
{"decision": "block", "reason": "Incomplete investigation document. Missing required sections: ${MISSING_SECTIONS}. Complete all 7 investigation stages before saving."}
EOF
        exit 0
    fi
fi

cat <<'EOF'
{"decision": "allow", "reason": "Enrichment document contains all required sections"}
EOF

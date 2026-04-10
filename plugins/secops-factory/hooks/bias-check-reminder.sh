#!/usr/bin/env bash
# Hook: bias-check-reminder
# Type: PostToolUse on mcp__perplexity__perplexity_search
# Purpose: Non-blocking reminder to check cognitive bias after research
#
# After Perplexity research completes, remind the analyst to check
# for cognitive biases in how they interpret the results.

set -euo pipefail

# PostToolUse hooks output a message, not a decision
cat <<'EOF'
{"message": "Cognitive bias reminder: After interpreting these research results, check for confirmation bias (seeking only confirming evidence), anchoring bias (locked to first metric found), and availability bias (over-weighting recent events). Reference: data/cognitive-bias-patterns.md"}
EOF

#!/usr/bin/env bash
# bias-check-reminder.sh — PostToolUse hook that reminds the analyst to
# check cognitive biases after Perplexity research completes.
#
# Advisory only — non-blocking. Outputs a stderr message.
# PostToolUse hooks do not use permissionDecision.

set -euo pipefail

echo "Cognitive bias reminder: After interpreting these research results, check for:" >&2
echo "  - Confirmation bias (seeking only evidence that supports your hypothesis)" >&2
echo "  - Anchoring bias (fixating on the first metric or severity score found)" >&2
echo "  - Availability bias (over-weighting recent similar incidents)" >&2
echo "  - Automation bias (over-trusting scanner/tool output without verification)" >&2
echo "Reference: \${CLAUDE_PLUGIN_ROOT}/data/cognitive-bias-patterns.md" >&2
exit 0

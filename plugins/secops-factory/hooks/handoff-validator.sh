#!/usr/bin/env bash
# handoff-validator.sh — SubagentStop hook that validates security-reviewer
# returns non-empty, substantive output.
#
# Ported from vsdd-factory. An empty or tiny reviewer return is the #1
# silent failure mode in adversarial convergence loops — it silently
# counts as "no findings" when the reviewer actually crashed or exhausted
# context.
#
# Non-blocking (advisory) — emits a warning on stderr if output is
# suspiciously short. SubagentStop hooks cannot block; they can only warn.

set -euo pipefail

if ! command -v jq &>/dev/null; then
  echo "handoff-validator.sh: jq is required but not found" >&2
  exit 1
fi

INPUT=$(cat)
RESULT=$(echo "$INPUT" | jq -r '.result // empty')
RESULT_LEN=${#RESULT}

if [ "$RESULT_LEN" -eq 0 ]; then
  echo "WARNING: Security reviewer returned EMPTY output. This likely indicates a sandbox denial, context exhaustion, or agent crash. The review pass should be re-run — do NOT treat empty output as 'no findings.'" >&2
elif [ "$RESULT_LEN" -lt 40 ]; then
  echo "WARNING: Security reviewer returned suspiciously short output (${RESULT_LEN} chars). Expected a substantive review with quality scores. Check for truncation or early termination." >&2
fi

exit 0

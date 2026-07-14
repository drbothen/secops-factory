# bias-check-reminder.ps1 — PostToolUse hook that reminds the analyst to
# check cognitive biases after Perplexity research completes.
#
# PowerShell sibling of bias-check-reminder.sh for native Windows hosts.
# Output and exit codes are identical to the bash implementation;
# the parity test suite (parity.bats) enforces this.
#
# Advisory only — non-blocking. Outputs a stderr message.
# PostToolUse hooks do not use permissionDecision.

$ErrorActionPreference = 'Stop'

[Console]::Error.WriteLine('Cognitive bias reminder: After interpreting these research results, check for:')
[Console]::Error.WriteLine('  - Confirmation bias (seeking only evidence that supports your hypothesis)')
[Console]::Error.WriteLine('  - Anchoring bias (fixating on the first metric or severity score found)')
[Console]::Error.WriteLine('  - Availability bias (over-weighting recent similar incidents)')
[Console]::Error.WriteLine('  - Automation bias (over-trusting scanner/tool output without verification)')
[Console]::Error.WriteLine('Reference: ${CLAUDE_PLUGIN_ROOT}/data/cognitive-bias-patterns.md')
exit 0

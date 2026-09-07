# AC-001..010: Full BATS suite green run
# Covers all AC regressions: link/close anti-fungibility, STEP-6 exact-type matching,
# CLOSE_STATE_ALLOWLIST binding, single-use atomic rename, write-block count (12),
# plus all existing VP-HOOK-001..024 regression guards.
# Expected: === All tests passed ===

Output docs/demo-evidence/S-3.01/AC-all-bats-suite.gif
Output docs/demo-evidence/S-3.01/AC-all-bats-suite.webm

Set FontFamily "FiraCode Nerd Font Mono"
Set Width 1000
Set Height 600
Set Padding 20
Set Shell "bash"

Hide
Type "cd $(git rev-parse --show-toplevel)"
Enter
Sleep 400ms
Show

Type "# S-3.01 BATS suite: link+close anti-fungibility + regression VPs"
Enter
Sleep 400ms
Type "plugins/secops-factory/tests/run-all.sh 2>&1 | tail -35"
Enter
Sleep 20s

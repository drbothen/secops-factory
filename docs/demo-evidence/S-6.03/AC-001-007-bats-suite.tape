# AC-001..007: full BATS suite — green run
# Evidence: CLOSE_STATE_ALLOWLIST doc-presence (AC-001..006), jira_project_key charset (AC-007),
# prism version-gate executable tests (AC-008 via adversarial BATS).
# All 103 tests expected to pass.

Output docs/demo-evidence/S-6.03/AC-001-007-bats-suite.gif
Output docs/demo-evidence/S-6.03/AC-001-007-bats-suite.webm

Set FontFamily "FiraCode Nerd Font Mono"
Set Width 1000
Set Height 550
Set Padding 20
Set Shell "bash"

Hide
Type "cd $(git rev-parse --show-toplevel)"
Enter
Sleep 300ms
Show

Type "# S-6.03 BATS suite: CLOSE_STATE_ALLOWLIST + jira_project_key + prism version gate"
Sleep 600ms
Enter
Type "plugins/secops-factory/tests/run-all.sh 2>&1 | tail -30"
Enter
Sleep 10s

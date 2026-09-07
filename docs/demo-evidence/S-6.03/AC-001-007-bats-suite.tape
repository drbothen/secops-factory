# AC-001..007: S-6.03 story BATS suites — green run
# Evidence: CLOSE_STATE_ALLOWLIST doc-presence (AC-001..006), jira_project_key charset (AC-007),
# prism version-gate executable tests (AC-008 via adversarial BATS).
# Scoped to this story's two suites for recording reliability (subset of full 75-test run).

Output docs/demo-evidence/S-6.03/AC-001-007-bats-suite.gif
Output docs/demo-evidence/S-6.03/AC-001-007-bats-suite.webm

Set FontFamily "FiraCode Nerd Font Mono"
Set Width 1000
Set Height 700
Set Padding 20
Set Shell "bash"

Hide
Type "cd $(git rev-parse --show-toplevel)"
Enter
Sleep 300ms
Show

Type "# S-6.03 BATS: activate-close-state + prism-version-check-adversarial"
Sleep 600ms
Enter
Type "bats plugins/secops-factory/tests/skills/activate-close-state.bats plugins/secops-factory/tests/skills/prism-version-check-adversarial.bats 2>&1 | tail -35"
Enter
Sleep 90s

# AC-001..009: full BATS coherence suite — green run
# Evidence: scored_priority enum discipline (AC-001..007), PC#6 band mapping,
# multi-org org_slug scoping static legs (AC-008), confidence tiers (AC-009).
# Suite: 51 tests — 50 passing + 1 pre-authorized DTU skip (VP-SKILL-070 behavioral leg).

Output docs/demo-evidence/S-4.02/AC-001-009-full-suite.gif
Output docs/demo-evidence/S-4.02/AC-001-009-full-suite.webm

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

Type "# S-4.02 assess-priority coherence suite (BC-4.05.001 v1.8) — 51 tests"
Sleep 600ms
Enter
Type "bats plugins/secops-factory/tests/skills/assess-priority-coherence.bats 2>&1 | tail -35"
Enter
Sleep 6s

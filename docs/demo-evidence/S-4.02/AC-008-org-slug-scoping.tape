# AC-008 / VP-SKILL-070: PrismQL org_slug scoping — static legs
# Evidence: PC#5a and PC#5d WHERE org_slug= clauses present; PC#5b NVD exempt (no org_slug);
# exactly 2 WHERE org_slug= clauses total in SKILL.md.
# Pre-authorized DTU behavioral leg (VP-SKILL-070 leg b) shown as expected skip.

Output docs/demo-evidence/S-4.02/AC-008-org-slug-scoping.gif
Output docs/demo-evidence/S-4.02/AC-008-org-slug-scoping.webm

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

Type "# AC-008 VP-SKILL-070: org_slug scoping in PC#5a, PC#5d (PC#5b NVD exempt)"
Sleep 600ms
Enter
Type "bats --filter 'AC-008|VP-SKILL-070' plugins/secops-factory/tests/skills/assess-priority-coherence.bats"
Enter
Sleep 4s

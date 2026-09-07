# AC-009 / VP-SKILL-071: confidence float→enum boundary consistency (D-DEC-011)
# Evidence: 0.75 → high, 0.749 → medium, 0.40 → medium, 0.399 → low;
# tier-inversion mutant guards; inconsistent pair documented as invalid.

Output docs/demo-evidence/S-4.02/AC-009-confidence-bands.gif
Output docs/demo-evidence/S-4.02/AC-009-confidence-bands.webm

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

Type "# AC-009 VP-SKILL-071: confidence float→enum D-DEC-011 boundary vectors"
Sleep 600ms
Enter
Type "bats --filter 'AC-009|VP-SKILL-071' plugins/secops-factory/tests/skills/assess-priority-coherence.bats"
Enter
Sleep 4s

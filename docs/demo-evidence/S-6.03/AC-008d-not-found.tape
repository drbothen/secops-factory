# AC-008d: prism version gate — prism binary NOT FOUND (→ exit 2)
# Evidence: AC-008 (VP-SKILL-051) error path — missing binary exits 2, not 1
# Run with default PATH (no prism installed): vhs docs/demo-evidence/S-6.03/AC-008d-not-found.tape

Output docs/demo-evidence/S-6.03/AC-008d-not-found.gif
Output docs/demo-evidence/S-6.03/AC-008d-not-found.webm

Set FontFamily "FiraCode Nerd Font Mono"
Set Width 1200
Set Height 500
Set Padding 30
Set Shell "bash"

Hide
Type "cd $(git rev-parse --show-toplevel)"
Enter
Sleep 300ms
Show

Type "# AC-008d: no prism in PATH -- expect exit 2 (distinct from version-too-old exit 1)"
Sleep 600ms
Enter
Type "plugins/secops-factory/hooks/prism-version-check.sh 2>&1; echo EXIT:$?"
Enter
Sleep 3s

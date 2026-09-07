# AC-008a: prism version gate — version BELOW minimum (0.9.9 → exit 1)
# Evidence: AC-008 (VP-SKILL-051) error path
# Run with: PATH=<mock-0.9.9>:$PATH vhs docs/demo-evidence/S-6.03/AC-008a-below-minimum.tape

Output docs/demo-evidence/S-6.03/AC-008a-below-minimum.gif
Output docs/demo-evidence/S-6.03/AC-008a-below-minimum.webm

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

Type "# AC-008a: prism 0.9.9 is BELOW minimum 1.0.0-rc.1 -- expect exit 1"
Sleep 600ms
Enter
Type "plugins/secops-factory/hooks/prism-version-check.sh 2>&1; echo EXIT:$?"
Enter
Sleep 3s

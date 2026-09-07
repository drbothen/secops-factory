# AC-008b: prism version gate — version AT minimum (1.0.0-rc.1 → exit 0)
# Evidence: AC-008 (VP-SKILL-051) success path — exact minimum accepted
# Run with: PATH=<mock-1.0.0-rc.1>:$PATH vhs docs/demo-evidence/S-6.03/AC-008b-at-minimum.tape

Output docs/demo-evidence/S-6.03/AC-008b-at-minimum.gif
Output docs/demo-evidence/S-6.03/AC-008b-at-minimum.webm

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

Type "# AC-008b: prism 1.0.0-rc.1 is AT minimum -- expect exit 0"
Sleep 600ms
Enter
Type "plugins/secops-factory/hooks/prism-version-check.sh 2>&1; echo EXIT:$?"
Enter
Sleep 3s

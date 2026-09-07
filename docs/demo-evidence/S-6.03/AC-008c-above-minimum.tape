# AC-008c: prism version gate — version ABOVE minimum (2.0.0 → exit 0)
# Evidence: AC-008 (VP-SKILL-051) success path — version well above minimum accepted
# Run with: PATH=<mock-2.0.0>:$PATH vhs docs/demo-evidence/S-6.03/AC-008c-above-minimum.tape

Output docs/demo-evidence/S-6.03/AC-008c-above-minimum.gif
Output docs/demo-evidence/S-6.03/AC-008c-above-minimum.webm

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

Type "# AC-008c: prism 2.0.0 is ABOVE minimum -- expect exit 0"
Sleep 600ms
Enter
Type "plugins/secops-factory/hooks/prism-version-check.sh 2>&1; echo EXIT:$?"
Enter
Sleep 3s

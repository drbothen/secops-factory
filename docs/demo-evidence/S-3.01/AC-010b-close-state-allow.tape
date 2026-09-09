# AC-010b: ["close"] marker + jr issue move Done → ALLOW
# Done ∈ CLOSE_STATE_ALLOWLIST={Done,Closed,Resolved}
# command_pattern matches → STEP 6 exact-type ["close"] → ALLOW; marker consumed atomically

Output docs/demo-evidence/S-3.01/AC-010b-close-state-allow.gif
Output docs/demo-evidence/S-3.01/AC-010b-close-state-allow.webm

Set FontFamily "FiraCode Nerd Font Mono"
Set Width 1200
Set Height 480
Set Padding 24
Set Shell "bash"

Hide
Type "cd $(git rev-parse --show-toplevel)"
Enter
Sleep 400ms
Show

Type "# AC-010b: close marker + Done (in allowlist) -- expect ALLOW"
Enter
Sleep 400ms
Type "docs/demo-evidence/S-3.01/demo-runner.sh close-allow"
Enter
Sleep 4s

# AC-010a: ["close"] marker + jr issue move WontFix → DENY
# WontFix ∉ CLOSE_STATE_ALLOWLIST={Done,Closed,Resolved}
# command_pattern bound to allowlisted states at emit time → pattern mismatch → DENY
# SM-63 kill: close-state-token-allowlist-removed mutant dies here

Output docs/demo-evidence/S-3.01/AC-010a-close-state-deny.gif
Output docs/demo-evidence/S-3.01/AC-010a-close-state-deny.webm

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

Type "# AC-010a: close marker + WontFix (not in allowlist) -- expect DENY"
Enter
Sleep 400ms
Type "docs/demo-evidence/S-3.01/demo-runner.sh close-deny"
Enter
Sleep 4s

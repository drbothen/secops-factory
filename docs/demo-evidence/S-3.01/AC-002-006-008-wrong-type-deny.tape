# AC-002 / AC-006 / AC-008: ["comment"] marker + jr issue link → DENY
# Anti-fungibility: wrong marker type cannot authorize link command
# AC-002: close exact-type STEP-6 binding (illustrated by wrong-type → deny)
# AC-006: STEP 6 exact-type: close cmd → ["close"] only; wrong-type → DENY
# AC-008: non-interchangeability of marker types enforced at runtime

Output docs/demo-evidence/S-3.01/AC-002-006-008-wrong-type-deny.gif
Output docs/demo-evidence/S-3.01/AC-002-006-008-wrong-type-deny.webm

Set FontFamily "FiraCode Nerd Font Mono"
Set Width 1100
Set Height 480
Set Padding 24
Set Shell "bash"

Hide
Type "cd $(git rev-parse --show-toplevel)"
Enter
Sleep 400ms
Show

Type "# AC-002/006/008: wrong-type marker (comment ops) + link cmd -- expect DENY"
Enter
Sleep 400ms
Type "docs/demo-evidence/S-3.01/demo-runner.sh wrong-type"
Enter
Sleep 4s

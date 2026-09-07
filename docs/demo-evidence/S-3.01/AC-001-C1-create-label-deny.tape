# AC-001 / C1: ["create"] marker + --label REVIEW-REQUIRED → DENY
# structural_label_check (C1): plain ["create"] marker cannot authorize a
# REVIEW-REQUIRED or BLIND-SPOT labeled issue create — requires ["create-review"]
# This is a write-block + STEP 6a anti-fungibility path (D-020 / SM-37)

Output docs/demo-evidence/S-3.01/AC-001-C1-create-label-deny.gif
Output docs/demo-evidence/S-3.01/AC-001-C1-create-label-deny.webm

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

Type "# AC-001/C1: create marker + REVIEW-REQUIRED label -- expect DENY"
Enter
Sleep 400ms
Type "docs/demo-evidence/S-3.01/demo-runner.sh create-label"
Enter
Sleep 4s

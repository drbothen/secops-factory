# AC-001 / AC-005 / AC-007: ["link"] marker + jr issue link SEC-1 SEC-2 → ALLOW
# AC-001: write-block (12 entries) + marker bypass via authorized link marker
# AC-005: STEP 6 exact-type match — ["link"] marker authorizes link command only
# AC-007: marker single-use POSIX atomic rename confirmed (1 .used file)

Output docs/demo-evidence/S-3.01/AC-001-005-007-link-allow.gif
Output docs/demo-evidence/S-3.01/AC-001-005-007-link-allow.webm

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

Type "# AC-001/005/007: valid link marker + link command -- expect ALLOW"
Enter
Sleep 400ms
Type "docs/demo-evidence/S-3.01/demo-runner.sh link-allow"
Enter
Sleep 4s

# handoff-validator.ps1 — SubagentStop hook that validates security-reviewer
# returns non-empty, substantive output.
#
# PowerShell sibling of handoff-validator.sh for native Windows hosts.
# Warning text and exit codes are identical to the bash implementation;
# the parity test suite (parity.bats) enforces this.
#
# Non-blocking (advisory) — emits a warning on stderr if output is
# suspiciously short. SubagentStop hooks cannot block; they can only warn.

$ErrorActionPreference = 'Stop'

$raw = [Console]::In.ReadToEnd()
$result = ''
try {
    $payload = $raw | ConvertFrom-Json
    if ($payload -and $payload.result) { $result = [string]$payload.result }
} catch {
    # Intentionally failing open: this is an advisory hook and must never block.
    # If the payload is malformed JSON, treat result as empty and emit the
    # EMPTY output warning below. $_ contains the parse error but is discarded.
    Write-Verbose "handoff-validator: ignoring JSON parse error — failing open (advisory hook)"
}

$len = $result.Length

if ($len -eq 0) {
    [Console]::Error.WriteLine("WARNING: Security reviewer returned EMPTY output. This likely indicates a sandbox denial, context exhaustion, or agent crash. The review pass should be re-run — do NOT treat empty output as 'no findings.'")
} elseif ($len -lt 40) {
    [Console]::Error.WriteLine("WARNING: Security reviewer returned suspiciously short output ($len chars). Expected a substantive review with quality scores. Check for truncation or early termination.")
}

exit 0

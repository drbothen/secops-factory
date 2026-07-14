# disposition-guard.ps1 — PreToolUse hook that blocks writing an event
# investigation disposition without the "Alternatives Considered" section.
#
# PowerShell sibling of disposition-guard.sh for native Windows hosts.
# JSON envelopes and exit codes are identical to the bash implementation;
# the parity test suite (parity.bats) enforces this.
#
# Emits a PreToolUse JSON envelope with permissionDecision.
# Deterministic, <100ms, no LLM.

$ErrorActionPreference = 'Stop'

function Emit-Allow {
    Write-Output '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
    exit 0
}

function Emit-Deny([string]$Reason) {
    $envelope = [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName            = 'PreToolUse'
            permissionDecision       = 'deny'
            permissionDecisionReason = $Reason
        }
    }
    Write-Output ($envelope | ConvertTo-Json -Compress -Depth 5)
    exit 0
}

$raw = [Console]::In.ReadToEnd()
$payload = $null
try { $payload = $raw | ConvertFrom-Json } catch { Emit-Allow }

$filePath = ''
$content = ''
if ($payload -and $payload.tool_input) {
    if ($payload.tool_input.file_path) { $filePath = [string]$payload.tool_input.file_path }
    if ($payload.tool_input.content)   { $content = [string]$payload.tool_input.content }
}

# Fast path: not an investigation file
if ($filePath -notlike '*investigation*') { Emit-Allow }

# Check if the document contains a disposition (case-insensitive, like grep -qiF)
if ($content.IndexOf('Disposition', [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
    # No disposition section — this is an in-progress write, allow it
    Emit-Allow
}

# Has a disposition — verify alternatives were considered
if ($content.IndexOf('Alternatives Considered', [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
    Emit-Deny "Investigation document contains a disposition but no 'Alternatives Considered' section. Before finalizing a disposition (TP/FP/BTP), you must document at least 2 alternative hypotheses with supporting and contradicting evidence for each. This prevents confirmation bias. See the investigate-event skill, Stage 4: Hypothesis Formation."
}

Emit-Allow

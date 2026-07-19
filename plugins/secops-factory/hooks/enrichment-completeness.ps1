# enrichment-completeness.ps1 — PreToolUse hook that blocks saving partial
# enrichment or investigation documents.
#
# PowerShell sibling of enrichment-completeness.sh for native Windows hosts.
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

# Fast path: not an enrichment/investigation file
if ($filePath -notlike '*enrichment*' -and $filePath -notlike '*investigation*') { Emit-Allow }

# Check required sections for enrichment documents.
# Sections must appear as markdown headings (^#{1,6}\s+<name>) so that body
# text merely mentioning a section name does not falsely satisfy the gate (DI-014).
if ($filePath -like '*enrichment*') {
    $missing = @()
    foreach ($section in @('Executive Summary', 'Vulnerability Details', 'Severity Metrics', 'Priority Assessment', 'Remediation Guidance')) {
        $escapedSection = [regex]::Escape($section)
        $hasHeading = ($content -split "`n") | Where-Object { $_ -match "^#{1,6}\s+$escapedSection" }
        if (-not $hasHeading) { $missing += $section }
    }
    if ($missing.Count -gt 0) {
        $list = $missing -join ', '
        Emit-Deny "Incomplete enrichment document. Missing required sections: $list. Complete all 8 enrichment stages before saving. See /enrich-ticket for the full pipeline."
    }
}

# Check required sections for investigation documents.
# Same heading-anchored check as enrichment (DI-014).
if ($filePath -like '*investigation*') {
    $missing = @()
    foreach ($section in @('Executive Summary', 'Alert Details', 'Disposition', 'Next Actions')) {
        $escapedSection = [regex]::Escape($section)
        $hasHeading = ($content -split "`n") | Where-Object { $_ -match "^#{1,6}\s+$escapedSection" }
        if (-not $hasHeading) { $missing += $section }
    }
    if ($missing.Count -gt 0) {
        $list = $missing -join ', '
        Emit-Deny "Incomplete investigation document. Missing required sections: $list. Complete all 7 investigation stages before saving. See /investigate-event for the full pipeline."
    }
}

Emit-Allow

# require-review.ps1 — PreToolUse hook that blocks JIRA field updates
# via jr CLI without review approval.
#
# PowerShell sibling of require-review.sh for native Windows hosts.
# JSON envelopes and exit codes are identical to the bash implementation;
# the parity test suite (parity.bats) enforces this.
# jr issue comment is now blocked (SEC-001). Unknown subcommands are fail-closed (SEC-002).
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

$command = ''
if ($payload -and $payload.tool_input -and $payload.tool_input.command) {
    $command = [string]$payload.tool_input.command
}

# Fast path: not a jr command -> allow immediately
if ($command -notlike '*jr *') { Emit-Allow }

# Allow read-only jr operations without review
$readOnly = @(
    'jr issue view', 'jr issue list', 'jr issue comments', 'jr issue assets',
    'jr issue transitions', 'jr sprint', 'jr board', 'jr project', 'jr me', 'jr auth'
)
foreach ($op in $readOnly) {
    if ($command -like "*$op*") { Emit-Allow }
}

# Block all jr write operations — requires review approval
# Includes: comment, edit, move, assign, create, and any unrecognized subcommand.
# jr issue comment is blocked (SEC-001): posting to the authoritative Jira record
# is a write operation that must go through the same review gate as field edits.
$blocked = @('jr issue comment', 'jr issue edit', 'jr issue move', 'jr issue assign', 'jr issue create')
foreach ($op in $blocked) {
    if ($command -like "*$op*") {
        Emit-Deny 'JIRA write operations require review approval. Run /review-enrichment or /adversarial-review-secops first to validate analysis quality. The jr issue comment/edit/move/assign/create commands are blocked until review passes quality thresholds.'
    }
}

# Unknown jr subcommand — fail-closed (SEC-002): deny rather than allow to prevent
# new write subcommands added in future jr releases from bypassing this gate.
Emit-Deny 'Unrecognized jr subcommand. Add to the read-only allowlist in require-review.ps1 if this is a safe read-only operation.'

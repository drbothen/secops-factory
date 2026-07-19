# require-review.ps1 — PreToolUse hook that blocks JIRA field updates
# via jr CLI without review approval.
#
# PowerShell sibling of require-review.sh for native Windows hosts.
# JSON envelopes and exit codes are identical to the bash implementation;
# the parity test suite (parity.bats) enforces this.
# jr issue comment is now blocked (SEC-001). Unknown subcommands are fail-closed (SEC-002).
# Allowlist expanded to cover jr issue changelog, jr assets, --output json forms (metrics suite).
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

# Block all jr write operations — requires review approval.
# ORDERING: write-block is evaluated BEFORE the read-only allowlist to prevent
# bypass via allowlist tokens embedded in write-command arguments (ADV-0-801).
# Example bypass (fixed): `jr issue edit KEY --summary "see jr board"` previously
# matched the "jr board" allowlist token and emitted allow before the deny block.
#
# Two families of write patterns:
#   (a) Plain forms:        jr issue edit KEY …
#   (b) --output json forms: jr --output json issue edit KEY …
# Both families are listed explicitly because the plain form "jr issue edit" is NOT
# a substring of "jr --output json issue edit" (the global flag sits between
# "jr" and "issue"), so each needs its own entry.
#
# jr issue comment is blocked (SEC-001): posting to the authoritative Jira record
# is a write operation that must go through the same review gate as field edits.
$blocked = @(
    # Plain forms
    'jr issue comment ', 'jr issue edit', 'jr issue move', 'jr issue assign', 'jr issue create',
    # --output json forms (Invariant #4: plain substrings do NOT match these)
    '--output json issue comment ', '--output json issue edit',
    '--output json issue move', '--output json issue assign', '--output json issue create'
)
foreach ($op in $blocked) {
    if ($command -like "*$op*") {
        Emit-Deny 'JIRA write operations require review approval. Run /review-enrichment or /adversarial-review-secops first to validate analysis quality. The jr issue comment/edit/move/assign/create commands are blocked until review passes quality thresholds.'
    }
}

# Allow read-only jr operations without review.
# Two families: plain forms (jr issue view KEY) and --output json forms
# (jr --output json issue view KEY). Both are read-only and need separate entries
# because "jr issue view" is NOT a substring of "jr --output json issue view".
$readOnly = @(
    # Plain forms
    'jr issue view', 'jr issue list', 'jr issue comments', 'jr issue assets',
    'jr issue transitions', 'jr issue changelog',
    'jr assets search', 'jr assets view',
    'jr sprint', 'jr board', 'jr project', 'jr me', 'jr auth', 'jr --version',
    # --output json forms (metrics suite: jr --output json <subcommand>)
    '--output json issue view', '--output json issue list',
    '--output json issue comments', '--output json issue changelog',
    '--output json issue assets',
    '--output json assets search', '--output json assets view'
)
foreach ($op in $readOnly) {
    if ($command -like "*$op*") { Emit-Allow }
}

# Unknown jr subcommand — fail-closed (SEC-002): deny rather than allow to prevent
# new write subcommands added in future jr releases from bypassing this gate.
Emit-Deny 'Unrecognized jr subcommand. Add to the read-only allowlist in require-review.ps1 if this is a safe read-only operation.'

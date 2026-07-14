# session-greeting.ps1 — SessionStart hook that greets the analyst when the
# SecOps Factory orchestrator is this project's default agent.
#
# PowerShell sibling of session-greeting.sh for native Windows hosts.
# JSON envelopes and exit codes are identical to the bash implementation;
# the parity test suite (parity.bats) enforces this.
#
# Activation-gated: only fires when .claude/settings.local.json sets
# agent = secops-factory:orchestrator:orchestrator. Silent no-op otherwise.

$ErrorActionPreference = 'Stop'

$raw = [Console]::In.ReadToEnd()

# Resolve the project dir: prefer the payload's cwd, fall back to env/PWD.
$projectDir = ''
try {
    $payload = $raw | ConvertFrom-Json
    if ($payload -and $payload.cwd) { $projectDir = [string]$payload.cwd }
} catch { }
if (-not $projectDir) {
    if ($env:CLAUDE_PROJECT_DIR) { $projectDir = $env:CLAUDE_PROJECT_DIR }
    else { $projectDir = (Get-Location).Path }
}

$settings = Join-Path $projectDir '.claude/settings.local.json'
if (-not (Test-Path $settings)) { exit 0 }

# Activation gate — exact match on the agent value.
$agent = ''
try {
    $cfg = Get-Content -Raw $settings | ConvertFrom-Json
    if ($cfg -and $cfg.agent) { $agent = [string]$cfg.agent }
} catch { exit 0 }
if ($agent -ne 'secops-factory:orchestrator:orchestrator') { exit 0 }

$banner = "[SecOps Factory] Morgan here - SOC companion active. Tell me what you're working on, or pick: 1) enrich ticket  2) investigate event  3) advisory  4) review work  5) health check"
$context = "SessionStart: the SecOps Factory orchestrator is active and the analyst was already shown Morgan's greeting banner with the 5-option menu (1=enrich ticket, 2=investigate event, 3=advisory, 4=review work, 5=health check). Do not re-introduce yourself from scratch; respond to the analyst's first message in-flow. A bare digit 1-5 selects the corresponding menu option."

$envelope = [ordered]@{
    systemMessage      = $banner
    hookSpecificOutput = [ordered]@{
        hookEventName     = 'SessionStart'
        additionalContext = $context
    }
}
Write-Output ($envelope | ConvertTo-Json -Compress -Depth 5)
exit 0

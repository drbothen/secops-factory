# factory-profile.ps1 — PowerShell 7 port of scripts/factory-profile
# Switch secops-factory between local / hybrid / cloud model backends.
#
#   factory-profile.ps1               show active profile + resolved tier mapping
#   factory-profile.ps1 local         switch to DGX Spark via Tailscale
#   factory-profile.ps1 hybrid        switch to frontier judgment + local execution
#   factory-profile.ps1 cloud         switch to all-cloud (Claude Platform on AWS)
#   factory-profile.ps1 doctor        health-check the active profile end to end
#
# Requires PowerShell 7+ (uses .NET Core string methods; will not run on PS 5.1).
# Env vars are read by Claude Code at process start, so a switch takes effect on
# the next `claude` launch. This script tells you when a restart is needed.

#Requires -Version 7.0
$ErrorActionPreference = 'Stop'

$ROOT = Split-Path -Parent $PSScriptRoot
$MARKER = Join-Path $ROOT '.factory-profile'
$PROFILES = Join-Path $ROOT 'profiles'
$VALID = @('local', 'hybrid', 'cloud')

function Write-Ok   { param($msg) Write-Host "  + $msg" -ForegroundColor Green }
function Write-Bad  { param($msg) Write-Host "  x $msg" -ForegroundColor Red }
function Write-Warn { param($msg) Write-Host "  ! $msg" -ForegroundColor Yellow }

function Get-ActiveProfile {
    if (Test-Path $MARKER) {
        return (Get-Content $MARKER -Raw).Trim()
    }
    return 'hybrid'
}

function Show-Profile {
    $p = Get-ActiveProfile
    Write-Host "`nactive profile: " -NoNewline
    Write-Host $p -ForegroundColor Cyan -NoNewline
    Write-Host "`n"

    $envFile = Join-Path $PROFILES "$p.env"
    $endpoint = '<provider default: AWS>'
    $opus     = '<provider default>'
    $sonnet   = '<provider default>'
    $haiku    = '<provider default>'

    if (Test-Path $envFile) {
        foreach ($line in (Get-Content $envFile)) {
            if ($line -match '^(?:export\s+)?ANTHROPIC_BASE_URL=(.+)$')                { $endpoint = $Matches[1].Trim("'`"") }
            if ($line -match '^(?:export\s+)?ANTHROPIC_DEFAULT_OPUS_MODEL=(.+)$')      { $opus     = $Matches[1].Trim("'`"") }
            if ($line -match '^(?:export\s+)?ANTHROPIC_DEFAULT_SONNET_MODEL=(.+)$')    { $sonnet   = $Matches[1].Trim("'`"") }
            if ($line -match '^(?:export\s+)?ANTHROPIC_DEFAULT_HAIKU_MODEL=(.+)$')     { $haiku    = $Matches[1].Trim("'`"") }
        }
    }

    Write-Host "  endpoint  $endpoint"
    Write-Host "  opus      $opus"
    Write-Host "  sonnet    $sonnet"
    Write-Host "  haiku     $haiku"

    switch ($p) {
        'local'  { Write-Host "`n  requires: scripts/litellm-gateway.sh up  +  Tailscale connection" }
        'hybrid' { Write-Host "`n  requires: scripts/litellm-gateway.sh up" }
    }
    Write-Host ""
}

function Invoke-Doctor {
    $p = Get-ActiveProfile
    $fail = $false
    Write-Host "`ndoctor -- profile: $p`n" -ForegroundColor Cyan

    $envFile = Join-Path $PROFILES "$p.env"
    $baseUrl  = ''
    $authTok  = ''
    $awsKey   = ''
    $opusM    = ''
    $sonnetM  = ''
    $haikuM   = ''

    if (Test-Path $envFile) {
        foreach ($line in (Get-Content $envFile)) {
            if ($line -match '^(?:export\s+)?ANTHROPIC_BASE_URL=(.+)$')                { $baseUrl  = $Matches[1].Trim("'`"") }
            if ($line -match '^(?:export\s+)?ANTHROPIC_AUTH_TOKEN=(.+)$')              { $authTok  = $Matches[1].Trim("'`"") }
            if ($line -match '^(?:export\s+)?ANTHROPIC_AWS_API_KEY=(.+)$')             { $awsKey   = $Matches[1].Trim("'`"") }
            if ($line -match '^(?:export\s+)?ANTHROPIC_DEFAULT_OPUS_MODEL=(.+)$')      { $opusM    = $Matches[1].Trim("'`"") }
            if ($line -match '^(?:export\s+)?ANTHROPIC_DEFAULT_SONNET_MODEL=(.+)$')    { $sonnetM  = $Matches[1].Trim("'`"") }
            if ($line -match '^(?:export\s+)?ANTHROPIC_DEFAULT_HAIKU_MODEL=(.+)$')     { $haikuM   = $Matches[1].Trim("'`"") }
        }
    }

    if ($baseUrl) {
        $headers = @{
            'Authorization' = "Bearer $authTok"
            'x-api-key'     = $authTok
        }
        try {
            $resp = Invoke-RestMethod -Uri "$baseUrl/v1/models" -Headers $headers `
                        -TimeoutSec 5 -ErrorAction Stop
            Write-Ok "endpoint reachable: $baseUrl"
            $served = ($resp.data | ForEach-Object { $_.id }) -join ' '
            foreach ($tier in @('opus', 'sonnet', 'haiku')) {
                $varName = "ANTHROPIC_DEFAULT_$($tier.ToUpper())_MODEL"
                $m = switch ($tier) { 'opus' { $opusM } 'sonnet' { $sonnetM } 'haiku' { $haikuM } }
                if (-not $m) { continue }
                if ($served -match [regex]::Escape($m)) {
                    Write-Ok "$($tier.PadRight(6)) $m"
                } else {
                    Write-Bad "$($tier.PadRight(6)) $m  -- NOT SERVED"; $fail = $true
                }
            }
            # live round-trip on the sonnet tier
            if ($sonnetM) {
                $body = @{
                    model      = $sonnetM
                    max_tokens = 8
                    messages   = @(@{ role = 'user'; content = 'Reply OK' })
                } | ConvertTo-Json -Depth 3
                try {
                    $rt = Invoke-RestMethod -Uri "$baseUrl/v1/messages" `
                              -Method Post -Body $body `
                              -ContentType 'application/json' `
                              -Headers @{ 'x-api-key' = $authTok; 'anthropic-version' = '2023-06-01' } `
                              -TimeoutSec 90 -ErrorAction Stop
                    if ($rt.type -eq 'message') {
                        Write-Ok '/v1/messages round-trip'
                    } else {
                        Write-Bad '/v1/messages round-trip FAILED'; $fail = $true
                    }
                } catch {
                    Write-Bad "/v1/messages round-trip FAILED: $_"; $fail = $true
                }
            }
        } catch {
            Write-Bad "endpoint UNREACHABLE: $baseUrl"
            if ($p -eq 'hybrid') { Write-Warn 'start it: scripts/litellm-gateway.sh up' }
            if ($p -eq 'local')  { Write-Warn 'start it: scripts/litellm-gateway.sh up  (and verify Tailscale)' }
            $fail = $true
        }
    } else {
        Write-Ok 'using provider default endpoint (AWS)'
        if ($awsKey) { Write-Ok 'AWS key present' } else { Write-Bad 'AWS key missing'; $fail = $true }
    }

    Write-Host ""
    if (-not $fail) {
        Write-Host 'all checks passed' -ForegroundColor Green
        exit 0
    } else {
        Write-Host 'checks failed' -ForegroundColor Red
        exit 1
    }
}

function Switch-Profile {
    param([string]$Target)
    $prev = Get-ActiveProfile
    Set-Content -Path $MARKER -Value $Target -NoNewline
    Write-Host "`nswitched: $prev -> " -NoNewline
    Write-Host $Target -ForegroundColor Cyan
    Write-Host ""
    Show-Profile

    if (Get-Command direnv -ErrorAction SilentlyContinue) {
        Write-Host "  run " -NoNewline
        Write-Host "direnv reload" -NoNewline -ForegroundColor Cyan
        Write-Host " (or cd out/in), then restart claude"
    } else {
        Write-Host "  restart claude to pick this up"
    }
    Write-Host ""
}

$cmd = if ($args.Count -gt 0) { $args[0] } else { 'show' }

switch ($cmd) {
    'show'   { Show-Profile }
    'doctor' { Invoke-Doctor }
    { $_ -in $VALID } { Switch-Profile $cmd }
    default {
        Write-Error "unknown: $cmd`nusage: factory-profile.ps1 [local|hybrid|cloud|doctor]"
        exit 2
    }
}

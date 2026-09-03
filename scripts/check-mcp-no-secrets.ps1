#Requires -Version 7
# Guard: fail if any tracked/staged .mcp.json contains literal API-key patterns.
#
# Patterns checked (all known provider key prefixes plus generic sk- keys):
#   pplx-               Perplexity
#   tvly-               Tavily
#   ctx7sk-             Context7
#   exa_[A-Za-z0-9]     Exa
#   sk-[A-Za-z0-9]{16,} generic (OpenAI-style / AWS-style short keys)
#
# Usage:
#   .\scripts\check-mcp-no-secrets.ps1              # checks repo-default file list
#   .\scripts\check-mcp-no-secrets.ps1 FILE...      # checks the given files instead
#
# Exit 0 = clean. Exit 1 = at least one literal key found.

param(
    [string[]]$Files = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Patterns that indicate a literal API key value.
$Patterns = @(
    'pplx-[A-Za-z0-9_-]'
    'tvly-[A-Za-z0-9_-]'
    'ctx7sk-[A-Za-z0-9_-]'
    'exa_[A-Za-z0-9]'
    'sk-[A-Za-z0-9]{16,}'
)

# Determine which files to check.
if ($Files.Count -gt 0) {
    $CheckFiles = $Files
}
else {
    $Root = (Resolve-Path (Join-Path $PSScriptRoot '..'))
    # Files tracked by git: both root .mcp.json and plugin sub-paths.
    $tracked = & git -C $Root ls-files '.mcp.json' '*.mcp.json' 2>$null
    $plugin  = & git -C $Root ls-files 'plugins/**/.mcp.json' 2>$null
    $all = ($tracked + $plugin) | Where-Object { $_ -ne '' } | Sort-Object -Unique
    $CheckFiles = $all | ForEach-Object { Join-Path $Root $_ } | Where-Object { Test-Path $_ }
}

if ($CheckFiles.Count -eq 0) {
    Write-Error 'check-mcp-no-secrets: no .mcp.json files found — nothing to check.'
    exit 0
}

$failures = 0

foreach ($file in $CheckFiles) {
    if (-not (Test-Path $file)) {
        Write-Error "SKIP (not found): $file"
        continue
    }
    $content = Get-Content -Raw $file
    $fileClean = $true
    foreach ($pat in $Patterns) {
        if ($content -match $pat) {
            Write-Error "FAIL: literal key pattern '$pat' found in: $file"
            $failures++
            $fileClean = $false
        }
    }
    if ($fileClean) {
        Write-Error "OK: $file"
    }
}

if ($failures -gt 0) {
    Write-Error ''
    Write-Error "check-mcp-no-secrets: $failures literal key pattern(s) found."
    Write-Error 'Run: bash scripts/migrate-mcp-keys.sh  (or .\scripts\migrate-mcp-keys.ps1 on Windows)'
    Write-Error 'to move keys to .envrc.secrets and replace with ${VAR} references.'
    exit 1
}

exit 0

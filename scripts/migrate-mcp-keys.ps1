# migrate-mcp-keys.ps1 — PowerShell port of scripts/migrate-mcp-keys.sh
# Move plaintext MCP API keys (Perplexity, Tavily, Context7, Exa) out of
# .mcp.json and into the gitignored secrets file, leaving ${VAR} refs behind.
# Claude Code expands ${VAR} in .mcp.json env/url/headers fields at load time.
#
# After this runs, .mcp.json is secret-free and can be tracked in git.
# Never prints key material — only lengths. Idempotent. Safe to re-run.
#
# Requires PowerShell 7+.

#Requires -Version 7.0
$ErrorActionPreference = 'Stop'

$ROOT    = Split-Path -Parent $PSScriptRoot
$MCP     = Join-Path $ROOT 'plugins' 'secops-factory' '.mcp.json'
$SECRETS = Join-Path $ROOT '.envrc.secrets'

if (-not (Test-Path $MCP))     { Write-Error "x $MCP not found"; exit 1 }
if (-not (Test-Path $SECRETS)) { Write-Error "x secrets file not found"; exit 1 }

$cfg    = Get-Content $MCP -Raw | ConvertFrom-Json -AsHashtable
$servers = if ($cfg.ContainsKey('mcpServers')) { $cfg['mcpServers'] } else { @{} }

$moves = [System.Collections.Generic.List[hashtable]]::new()

function Stash {
    param([string]$varName, [string]$value)
    $moves.Add(@{ VarName = $varName; Value = $value })
    return "`${$varName}"
}

# perplexity: may be stdio env block (legacy) or HTTP headers (current)
if ($servers.ContainsKey('perplexity')) {
    $p = $servers['perplexity']
    # Legacy stdio env block
    if ($p.ContainsKey('env') -and $p['env'].ContainsKey('PERPLEXITY_API_KEY')) {
        $val = $p['env']['PERPLEXITY_API_KEY']
        if ($val -and -not $val.StartsWith('${')) {
            $p['env']['PERPLEXITY_API_KEY'] = Stash 'PERPLEXITY_API_KEY' $val
        }
    }
    # HTTP headers — Authorization: Bearer <literal-key>
    if ($p.ContainsKey('headers') -and $p['headers'].ContainsKey('Authorization')) {
        $auth = $p['headers']['Authorization']
        if ($auth -match '^Bearer\s+([^\s$\{][^\s]*)$') {
            $literal = $Matches[1]
            $p['headers']['Authorization'] = "Bearer $(Stash 'PERPLEXITY_API_KEY' $literal)"
        }
    }
}

# tavily: key embedded in the HTTP url query string
if ($servers.ContainsKey('tavily')) {
    $t = $servers['tavily']
    if ($t.ContainsKey('url')) {
        if ($t['url'] -match 'tavilyApiKey=([^&"$\{][^&"]*)') {
            $literal = $Matches[1]
            $t['url'] = $t['url'] -replace [regex]::Escape($literal), (Stash 'TAVILY_API_KEY' $literal)
        }
    }
}

# context7: header
if ($servers.ContainsKey('context7')) {
    $c = $servers['context7']
    if ($c.ContainsKey('headers') -and $c['headers'].ContainsKey('CONTEXT7_API_KEY')) {
        $val = $c['headers']['CONTEXT7_API_KEY']
        if ($val -and -not $val.StartsWith('${')) {
            $c['headers']['CONTEXT7_API_KEY'] = Stash 'CONTEXT7_API_KEY' $val
        }
    }
}

# exa: key embedded in the HTTP url query string
if ($servers.ContainsKey('exa')) {
    $e = $servers['exa']
    if ($e.ContainsKey('url')) {
        if ($e['url'] -match 'exaApiKey=([^&"$\{][^&"]*)') {
            $literal = $Matches[1]
            $e['url'] = $e['url'] -replace [regex]::Escape($literal), (Stash 'EXA_API_KEY' $literal)
        }
    }
}

if ($moves.Count -eq 0) {
    Write-Host 'v .mcp.json already secret-free. Nothing to do.'
    exit 0
}

# Write order is intentional: secrets file first, then .mcp.json.
# If interrupted mid-run, the key is preserved in the secrets file and
# .mcp.json still holds plaintext — a safe state a re-run will clean up.

$lines = (Get-Content $SECRETS -Raw).Split("`n") | Where-Object { $_ -ne $null }

foreach ($move in $moves) {
    $varName = $move['VarName']
    # Remove existing export line for this var (idempotent)
    $lines = $lines | Where-Object { $_ -notmatch "^\s*export\s+$varName=" }
    # Single-quote wrap with embedded-single-quote escaping (CWE-116 / POSIX §2.2.2).
    # Splits on ' and wraps each piece; rejoins with the escaped sequence '\''.
    $escaped = $move['Value'] -replace "'", "'\\''"
    $lines += "export $varName='$escaped'"
}

$secretsContent = ($lines -join "`n").TrimEnd() + "`n"
[System.IO.File]::WriteAllText($SECRETS, $secretsContent)

# Set secrets file to owner-read/write only (600 equivalent on Windows: remove
# inherited ACEs, grant only the current user Full Control).
try {
    $acl = Get-Acl $SECRETS
    $acl.SetAccessRuleProtection($true, $false)   # disable inheritance, remove inherited
    $rule = [System.Security.AccessControl.FileSystemAccessRule]::new(
        [System.Security.Principal.WindowsIdentity]::GetCurrent().Name,
        'FullControl', 'Allow')
    $acl.SetAccessRule($rule)
    Set-Acl -Path $SECRETS -AclObject $acl
} catch {
    Write-Warning "migrate-mcp-keys: could not tighten permissions on $SECRETS — set manually to 600"
}

# Write updated .mcp.json
$jsonOut = $cfg | ConvertTo-Json -Depth 10
[System.IO.File]::WriteAllText($MCP, $jsonOut + "`n")

foreach ($move in $moves) {
    $len = $move['Value'].Length
    Write-Host "moved $($move['VarName']) ($len chars) -> secrets file; .mcp.json now references `$`{$($move['VarName'])`}"
}

# Verify no secret-shaped residue remains in .mcp.json
$mcpContent = Get-Content $MCP -Raw
$residue = [regex]::Matches($mcpContent, '(pplx-|tvly-|ctx7sk-|exa_)[A-Za-z0-9_-]{8,}')
if ($residue.Count -gt 0) {
    Write-Error 'x RESIDUE REMAINS in .mcp.json!'
    exit 1
}
Write-Host 'v .mcp.json is secret-free; safe to track in git.'
exit 0

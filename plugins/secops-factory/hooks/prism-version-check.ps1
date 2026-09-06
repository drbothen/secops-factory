# prism-version-check.ps1 — BC-6.01.001 PC#8 prism minimum version gate.
# PowerShell sibling of prism-version-check.sh for native Windows hosts.
# Minimum required version: 1.0.0-rc.1
#
# Exit 0  if installed prism --version >= 1.0.0-rc.1
# Exit 1  if installed prism --version < 1.0.0-rc.1
# Exit 2  if prism is not found or version cannot be parsed

$ErrorActionPreference = 'Stop'

$MinVersion = '1.0.0-rc.1'

# Locate prism
if (-not (Get-Command 'prism' -ErrorAction SilentlyContinue)) {
    Write-Error 'ERROR: prism binary not found in PATH'
    exit 2
}

# Capture prism --version output
try {
    $versionOutput = (& prism --version 2>&1) | Out-String
} catch {
    Write-Error "ERROR: failed to run prism --version: $_"
    exit 2
}

# Extract semver string: e.g. "prism 1.2.3-rc.4" -> "1.2.3-rc.4"
$match = [regex]::Match($versionOutput, '[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?')
if (-not $match.Success) {
    Write-Error ("ERROR: could not parse prism version from output: {0}" -f $versionOutput.Trim())
    exit 2
}
$version = $match.Value

# Split version into main and pre-release parts
function Split-SemVer([string]$v) {
    if ($v -match '^([0-9]+\.[0-9]+\.[0-9]+)-(.+)$') {
        return @{ Main = $Matches[1]; Pre = $Matches[2] }
    }
    return @{ Main = $v; Pre = '' }
}

function Compare-SemVer([string]$v1, [string]$v2) {
    # Returns 1 if v1 > v2, 0 if v1 == v2, -1 if v1 < v2
    $a = Split-SemVer $v1
    $b = Split-SemVer $v2

    $aParts = $a.Main -split '\.' | ForEach-Object { [int]$_ }
    $bParts = $b.Main -split '\.' | ForEach-Object { [int]$_ }

    for ($i = 0; $i -lt 3; $i++) {
        if ($aParts[$i] -gt $bParts[$i]) { return 1 }
        if ($aParts[$i] -lt $bParts[$i]) { return -1 }
    }

    # Same major.minor.patch — compare pre-release
    # Semver: no pre-release > any pre-release  (1.0.0 > 1.0.0-rc.1)
    if ($a.Pre -eq '' -and $b.Pre -ne '') { return 1 }
    if ($a.Pre -ne '' -and $b.Pre -eq '') { return -1 }
    if ($a.Pre -eq '' -and $b.Pre -eq '') { return 0 }

    # Both have pre-release — string comparison (handles rc.N)
    if ($a.Pre -gt $b.Pre) { return 1 }
    if ($a.Pre -lt $b.Pre) { return -1 }
    return 0
}

$cmp = Compare-SemVer $version $MinVersion
if ($cmp -ge 0) {
    Write-Host ("prism {0} meets minimum requirement {1}" -f $version, $MinVersion)
    exit 0
} else {
    Write-Error ("ERROR: prism {0} does not meet minimum requirement {1}" -f $version, $MinVersion)
    exit 1
}

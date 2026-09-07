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
    # Use non-terminating output so exit 2 is reached under $ErrorActionPreference='Stop'.
    [Console]::Error.WriteLine('ERROR: prism binary not found in PATH')
    exit 2
}

# Capture prism --version output.
# Mirror sh '|| true': lower ErrorActionPreference to Continue for this call so
# a non-zero exit from prism does NOT become a terminating error — the version
# string may still be parseable (e.g. a debug build that exits 3 after printing
# its version). Only exit 2 when the version is genuinely absent or unparseable.
$ErrorActionPreference = 'Continue'
$versionOutput = (& prism --version 2>&1) | Out-String
$ErrorActionPreference = 'Stop'

# Extract semver string: e.g. "prism 1.2.3-rc.4" -> "1.2.3-rc.4"
# ANCHORED extraction (F-A fix, mirrors prism-version-check.sh): inspect only the
# first line and require the literal "prism " prefix so that banner strings such as
# "prism (rustc 1.75.0) version 0.5.0" — where the rustc version appears before the
# prism version — cannot match ahead of the real version token.  Using a capture
# group [1] ensures the bare semver is extracted without the "prism " prefix.
$firstLine = ($versionOutput -split '\r?\n')[0]
$match = [regex]::Match($firstLine, '^prism\s+([0-9]+\.[0-9]+\.[0-9]+(?:-[a-zA-Z0-9.]+)?)')
if (-not $match.Success) {
    # Use non-terminating output so exit 2 is reached under $ErrorActionPreference='Stop'.
    [Console]::Error.WriteLine(("ERROR: could not parse prism version from output: {0}" -f $versionOutput.Trim()))
    exit 2
}
$version = $match.Groups[1].Value

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

    # Both have pre-release — compare per semver §11: split on dots, compare each
    # field: purely numeric identifiers compared numerically (so rc.2 < rc.10);
    # alphanumeric identifiers compared with [System.String]::CompareOrdinal for
    # case-sensitive ASCII ordering (semver §11.4, matches sh LC_ALL=C behaviour);
    # numeric < alphanumeric; larger set of fields > smaller when all preceding equal.
    $preParts1 = $a.Pre -split '\.'
    $preParts2 = $b.Pre -split '\.'
    $maxLen = [Math]::Max($preParts1.Length, $preParts2.Length)

    for ($j = 0; $j -lt $maxLen; $j++) {
        $s1 = if ($j -lt $preParts1.Length) { $preParts1[$j] } else { $null }
        $s2 = if ($j -lt $preParts2.Length) { $preParts2[$j] } else { $null }

        # One side exhausted: longer (more fields) is greater
        if ($null -eq $s1) { return -1 }
        if ($null -eq $s2) { return 1 }

        $n1IsNum = $s1 -match '^\d+$'
        $n2IsNum = $s2 -match '^\d+$'

        if ($n1IsNum -and $n2IsNum) {
            $n1 = [int]$s1; $n2 = [int]$s2
            if ($n1 -gt $n2) { return 1 }
            if ($n1 -lt $n2) { return -1 }
        } else {
            # numeric < alphanumeric (semver §11.4.1)
            if ($n1IsNum) { return -1 }
            if ($n2IsNum) { return 1 }
            # Both alphanumeric: ordinal case-sensitive comparison
            $cmp = [System.String]::CompareOrdinal($s1, $s2)
            if ($cmp -gt 0) { return 1 }
            if ($cmp -lt 0) { return -1 }
        }
    }
    return 0  # equal pre-release
}

$cmp = Compare-SemVer $version $MinVersion
if ($cmp -ge 0) {
    Write-Output ("prism {0} meets minimum requirement {1}" -f $version, $MinVersion)
    exit 0
} else {
    # Use non-terminating output so exit 1 is reached under $ErrorActionPreference='Stop'.
    [Console]::Error.WriteLine(("ERROR: prism {0} does not meet minimum requirement {1}" -f $version, $MinVersion))
    exit 1
}

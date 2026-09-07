# require-review.ps1 — PreToolUse hook that blocks JIRA field updates
# via jr CLI without review approval.
#
# PowerShell sibling of require-review.sh for native Windows hosts.
# JSON envelopes and exit codes are identical to the bash implementation;
# the parity test suite (parity.bats) enforces this.
# jr issue comment is now blocked (SEC-001). Unknown subcommands are fail-closed (SEC-002).
# Allowlist expanded to cover jr issue changelog, jr assets, --output json forms (metrics suite).
#
# Implements full BC-3.01.001 v1.25 marker-consume path (D-DEC-001 v2.0),
# including STEP 2-8: cmd_type detection, STEP-6 exact-type matching,
# structural_label_check equivalent (Test-StructuralLabelCheck), metachar guard,
# ISO-8601 validation (Test-Iso8601Utc), FIFO two-phase consume, atomic single-use
# (Move-Item rename), fail-closed audit.
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

# Test-Iso8601Utc TS — return $true if TS is a well-formed ISO-8601 UTC timestamp
# (YYYY-MM-DDTHH:MM:SSZ) with in-range field values; return $false otherwise.
# Used before lexicographic comparisons to fail-closed on malformed values
# (BC-3.01.001 PC#2 step 4b — F5 fix: malformed timestamps → skip marker → deny).
function Test-Iso8601Utc([string]$Ts) {
    if (-not ($Ts -cmatch '^[0-9]{4}-[01][0-9]-[0-3][0-9]T[0-2][0-9]:[0-5][0-9]:[0-5][0-9]Z\z')) {
        return $false
    }
    return $true
}

# Test-StructuralLabelCheck CMD — return $true if CMD carries --label REVIEW-REQUIRED
# or --label BLIND-SPOT as STANDALONE tokens (i.e. the actual --label argument,
# not text embedded inside another argument such as --summary).
#
# Implements BC-3.01.001 PC#2 step (6a) structural_label_check v2:
#   P9-001: backslash-escape-aware (index-based, handles \" in double-quotes)
#   P8-002: quote-aware state machine (UNQUOTED / IN_SINGLE / IN_DOUBLE)
#   P7-005: token-position check, not raw substring matching
#
# EC-024 false-deny prevention: "--label REVIEW-REQUIRED" appearing only inside
# a quoted --summary value is NOT a standalone token → returns $false (allow) ✓
# SM-40 (double-space), SM-42 (single/double-quoted value), SM-43 (tab):
# all correctly tokenize to standalone --label + value tokens → returns $true (deny) ✓
function Test-StructuralLabelCheck([string]$Cmd) {
    $state = 'UNQUOTED'
    $curToken = ''
    $tokens = [System.Collections.Generic.List[string]]::new()
    $i = 0
    $len = $Cmd.Length

    while ($i -lt $len) {
        $char = $Cmd[$i]
        switch ($state) {
            'UNQUOTED' {
                if ($char -eq '\' -and ($i + 1) -lt $len) {
                    # Backslash in UNQUOTED: next char is literal, no state toggle (P9-001)
                    $i++
                    $curToken += $Cmd[$i]
                }
                elseif ($char -eq "'") {
                    $state = 'IN_SINGLE'
                }
                elseif ($char -eq '"') {
                    $state = 'IN_DOUBLE'
                }
                elseif ($char -eq ' ' -or $char -eq "`t") {
                    if ($curToken.Length -gt 0) {
                        $tokens.Add($curToken)
                        $curToken = ''
                    }
                }
                else {
                    $curToken += $char
                }
            }
            'IN_SINGLE' {
                # No escaping inside single-quotes (bash parity); backslash is literal
                if ($char -eq "'") {
                    $state = 'UNQUOTED'
                }
                else {
                    $curToken += $char
                }
            }
            'IN_DOUBLE' {
                if ($char -eq '\' -and ($i + 1) -lt $len) {
                    # Backslash in IN_DOUBLE: only \" and \\ are special (P9-001)
                    $nextChar = $Cmd[$i + 1]
                    if ($nextChar -eq '"') {
                        # \" → literal ", STAY IN_DOUBLE
                        $curToken += '"'
                        $i++
                    }
                    elseif ($nextChar -eq '\') {
                        # \\ → literal \, STAY IN_DOUBLE
                        $curToken += '\'
                        $i++
                    }
                    else {
                        # Other \X → backslash is literal; next char processed next iteration
                        $curToken += $char
                    }
                }
                elseif ($char -eq '"') {
                    $state = 'UNQUOTED'
                }
                else {
                    $curToken += $char
                }
            }
        }
        $i++
    }
    # Flush any remaining token at end of string
    if ($curToken.Length -gt 0) {
        $tokens.Add($curToken)
    }

    # Scan tokens for any --label form carrying a hard-floor label value.
    # Handled forms (Finding 2 / SEC-001 fix):
    #   --label REVIEW-REQUIRED / --label BLIND-SPOT    (two-token space-separated form)
    #   --label=REVIEW-REQUIRED                         (equals form, one token)
    #   -l REVIEW-REQUIRED                              (short flag, two tokens)
    #   -lREVIEW-REQUIRED                               (short flag, no space)
    #   --label REVIEW-REQUIRED,triage                  (comma-joined value)
    $j = 0
    $ntokens = $tokens.Count
    while ($j -lt $ntokens) {
        $tok = $tokens[$j]
        $val = ''
        if ($tok -clike '--label=*') {
            # Form: --label=VALUE (one token, equals sign)
            $val = $tok.Substring('--label='.Length)
        }
        elseif ($tok.Length -gt 2 -and $tok.StartsWith('-l', [System.StringComparison]::Ordinal)) {
            # Form: -lVALUE (short flag, no space, one token)
            $val = $tok.Substring(2)
        }
        elseif ($tok -ceq '--label' -or $tok -ceq '-l') {
            # Form: --label VALUE or -l VALUE (two tokens; next token is value)
            if (($j + 1) -lt $ntokens) {
                $val = $tokens[$j + 1]
            }
        }
        if ($val.Length -gt 0) {
            foreach ($part in ($val -csplit ',')) {
                if ($part -ceq 'REVIEW-REQUIRED' -or $part -ceq 'BLIND-SPOT') {
                    return $true
                }
            }
        }
        $j++
    }
    return $false
}

# Invoke-ValidateMarkerForCommand CMD
#
# Phase 2 iterative marker-consume algorithm with STEP 6 exact-type matching
# per BC-3.01.001 v1.25 D-DEC-001 v2.0.
#
# Algorithm mirrors require-review.sh _validate_marker_for_command:
#   STEP 1  Check CLAUDE_PLUGIN_DATA is set and markers directory exists.
#   STEP 2  Determine command type: "link" / "close" / "create".
#   I1      Consumer-side shell metachar guard: reject ; | & ` $( > < \n
#   I4      STEP 3 Phase 1: collect valid candidates with issued_at_utc for FIFO ordering.
#   I2      BC step (3): skip markers whose issued_at_utc is in the future.
#   O1      STEP 4b: TTL — valid when expires_at_utc >= now.
#   STEP 5  Anchored command_pattern check.
#   STEP 6  Exact-type matching: link→["link"], close→["close"] (D-020/D-021/AC-005/AC-006).
#   C1      STEP 6a: create anti-fungibility via Test-StructuralLabelCheck.
#   I4      STEP 3 Phase 2: sort by issued_at_utc ascending, attempt atomic Move-Item.
#   STEP 7  Atomic rename to consume the marker (single-use, D-DEC-001).
#   I3      STEP 8: audit log — MARKER_USED record, control-char sanitized, fail-closed.
#
# Returns $true = valid marker found and consumed; $false = deny.
function Invoke-ValidateMarkerForCommand([string]$Cmd) {
    $pluginData = $env:CLAUDE_PLUGIN_DATA
    if ([string]::IsNullOrEmpty($pluginData)) { return $false }
    $markerDir = Join-Path $pluginData 'markers'
    if (-not (Test-Path $markerDir -PathType Container)) { return $false }

    # I1: consumer-side shell metachar guard (BC-3.01.001 PC#2 step 5)
    # Reject any command that contains shell metacharacters — prevents tail injection.
    # F2 (MAJOR): added > < \n — covers shell redirection and newline injection.
    foreach ($mc in @(';', '|', '&', '`', '$(', '>', '<')) {
        if ($Cmd.Contains($mc)) { return $false }
    }
    # Newline injection guard (F2 addition)
    if ($Cmd.Contains("`n")) { return $false }

    # STEP 2: determine command type for STEP 6 exact-type matching (D-020/D-021/C1)
    $cmdType = ''
    if ($Cmd -clike '*jr issue link *' -or $Cmd -clike '*--output json issue link *') {
        $cmdType = 'link'
    }
    elseif ($Cmd -clike '*jr issue move*' -or $Cmd -clike '*--output json issue move*') {
        $cmdType = 'close'
    }
    elseif ($Cmd -clike '*jr issue create*' -or $Cmd -clike '*--output json issue create*') {
        $cmdType = 'create'
    }
    elseif ($Cmd -clike '*jr issue update*' -or $Cmd -clike '*--output json issue update*') {
        $cmdType = 'update'
    }
    elseif ($Cmd -clike '*jr issue comment *' -or $Cmd -clike '*--output json issue comment *') {
        $cmdType = 'comment'
    }
    elseif ($Cmd -clike '*jr issue assign*' -or $Cmd -clike '*--output json issue assign*') {
        $cmdType = 'assign'
    }
    elseif ($Cmd -clike '*jr issue label*' -or $Cmd -clike '*--output json issue label*') {
        $cmdType = 'label'
    }
    elseif ($Cmd -clike '*jr issue delete*' -or $Cmd -clike '*--output json issue delete*') {
        $cmdType = 'delete'
    }

    $nowTs = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

    # I4 Phase 1: collect valid candidates for FIFO ordering.
    # Each entry: "issued_at_utc|marker_file_path" (ISO-8601 sorts lexicographically)
    $candidates = [System.Collections.Generic.List[string]]::new()

    # Use Where-Object instead of -Filter for compound-extension matching: on Linux PS7,
    # Get-ChildItem -Filter '*.marker.json' may return empty because the OS-level glob
    # only matches the last extension (.json), not the full compound extension (.marker.json).
    # PowerShell-side EndsWith is reliable on all platforms (case-sensitive, ordinal).
    $markerFiles = Get-ChildItem -Path $markerDir -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name.EndsWith('.marker.json', [System.StringComparison]::Ordinal) }
    foreach ($mf in $markerFiles) {
        # Path safety: marker must reside directly inside markerDir (no traversal)
        if ($mf.DirectoryName -ne $markerDir) { continue }

        $mj = $null
        $rawText = $null
        try {
            $rawText = Get-Content -Path $mf.FullName -Raw -ErrorAction Stop
            $mj = $rawText | ConvertFrom-Json -ErrorAction Stop
        }
        catch { continue }
        if ($null -eq $mj) { continue }

        # I2: BC step (3) — skip future-dated markers (adversarial signal)
        $issuedAt = [string]$mj.issued_at_utc
        if ([string]::IsNullOrEmpty($issuedAt)) { continue }
        # F5: validate format before lexicographic comparison (malformed → skip → fail-closed)
        if (-not (Test-Iso8601Utc $issuedAt)) { continue }
        # If issued_at_utc > now → adversarial signal → skip this marker
        if ([string]::CompareOrdinal($issuedAt, $nowTs) -gt 0) { continue }

        # STEP 4b: TTL check — O1: valid when expires_at_utc >= now (equality = still valid)
        $expires_at_utc = [string]$mj.expires_at_utc
        if ([string]::IsNullOrEmpty($expires_at_utc)) { continue }
        # F5: validate format before lexicographic comparison (malformed → skip → fail-closed)
        if (-not (Test-Iso8601Utc $expires_at_utc)) { continue }
        # Reject only when expires_at_utc < now (equal second is still valid per BC step 4)
        if ([string]::CompareOrdinal($expires_at_utc, $nowTs) -lt 0) { continue }

        # STEP 5: anchored command_pattern match
        $cmdPattern = [string]$mj.command_pattern
        if ([string]::IsNullOrEmpty($cmdPattern)) { continue }
        if ($Cmd -cnotmatch $cmdPattern) { continue }

        # STEP 6: exact-type matching for link/close/create anti-fungibility (D-020/D-021)
        # F1 (pass-4 MEDIUM fail-open): authorized_operations must be a genuine JSON array.
        # sh: jq length on a scalar string returns the string's character count (e.g. 4 for
        # "link"), which fails the ops_count==1 check → marker skipped → deny (fail-closed).
        # ps1 guard: check the RAW JSON text for the opening bracket instead of the parsed
        # object type. Some PS7 versions (7.0–7.2 on Ubuntu CI) unbox single-element arrays
        # ["link"] → scalar "link", making -isnot [System.Array] TRUE for valid markers and
        # causing every allowed operation to be silently skipped (fail-open to deny).
        # Raw-text check is reliable across all PS7 versions and preserves the fail-closed
        # semantic: a scalar JSON string "link" never has a `[` after the key colon.
        if ($rawText -cnotmatch '"authorized_operations"\s*:\s*\[') { continue }
        $ops = @($mj.authorized_operations)
        $opsCount = $ops.Count
        $opVal = if ($opsCount -gt 0) { [string]($ops[0]) } else { '' }
        # Guard: opsCount must be a non-negative integer
        if ($opsCount -lt 0) { continue }

        if ($cmdType -ceq 'link') {
            if (-not ($opsCount -eq 1 -and $opVal -ceq 'link')) { continue }
        }
        elseif ($cmdType -ceq 'close') {
            if (-not ($opsCount -eq 1 -and $opVal -ceq 'close')) { continue }
        }
        elseif ($cmdType -ceq 'create') {
            if ($opsCount -ne 1) { continue }
            if ($opVal -cne 'create' -and $opVal -cne 'create-review') { continue }
        }
        elseif ($cmdType -cne '') {
            # All other write ops: require exact single-entry authorized_operations matching cmdType
            if (-not ($opsCount -eq 1 -and $opVal -ceq $cmdType)) { continue }
        }
        else {
            # cmdType is empty — unknown write op → fail-closed (SEC-001)
            continue
        }

        # STEP 6a: C1 create anti-fungibility — regular ["create"] marker must NOT authorize
        # a create command carrying a hard-floor review label.
        # Hard-floor labels: REVIEW-REQUIRED, BLIND-SPOT (EC-023 direction B / SM-37).
        # A ["create-review"] marker is required for those tickets.
        # F1 (CRITICAL): Test-StructuralLabelCheck is a quote-aware (UNQUOTED/IN_SINGLE/IN_DOUBLE),
        # backslash-escape-aware, whitespace-collapsing tokenizer.
        # Fixes SM-40 (double-space), SM-42 (quoted value), SM-43 (tab).
        # EC-024 false-deny fix: label text inside a quoted --summary is NOT a standalone token.
        if ($opVal -ceq 'create') {
            if (Test-StructuralLabelCheck $Cmd) { continue }
        }

        # Valid candidate — record for FIFO sorting
        $candidates.Add("${issuedAt}|$($mf.FullName)")
    }

    # No valid candidates found → deny
    if ($candidates.Count -eq 0) { return $false }

    # I4 Phase 2: sort candidates by issued_at_utc ascending (FIFO), attempt atomic consume.
    # ISO-8601 lexicographic order equals chronological order.
    $sortedCandidates = $candidates | Sort-Object

    foreach ($cand in $sortedCandidates) {
        $pipIdx = $cand.IndexOf('|')
        $sortedMf = $cand.Substring($pipIdx + 1)
        if (-not (Test-Path $sortedMf -PathType Leaf)) { continue }

        # STEP 7: atomic rename — single-use consume (D-DEC-001)
        $consumed = [regex]::Replace($sortedMf, '\.marker\.json$', '.marker.used')
        try {
            Move-Item -Path $sortedMf -Destination $consumed -ErrorAction Stop
        }
        catch { continue }

        # STEP 8: complete audit log — I3 / Invariant #2 / VP-HOOK-024 / ADV-F2-013
        $auditMj = $null
        try {
            $auditMj = Get-Content -Path $consumed -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        }
        catch { $auditMj = $null }

        if ($null -ne $auditMj) {
            $rawMarkerId = if ($null -ne $auditMj.marker_id) { [string]$auditMj.marker_id } else { 'unknown' }
            $rawTicket   = if ($null -ne $auditMj.ticket_id)  { [string]$auditMj.ticket_id  } else { '' }
            $rawOrg      = if ($null -ne $auditMj.org_slug)   { [string]$auditMj.org_slug   } else { '' }
            $auditOps    = @($auditMj.authorized_operations)
            $rawOp       = if ($auditOps.Count -gt 0) { [string]($auditOps[0]) } else { '' }
        }
        else {
            $rawMarkerId = 'unknown'; $rawTicket = ''; $rawOrg = ''; $rawOp = ''
        }

        # Sanitize: strip control chars (0x00-0x1f) from all attacker-influenceable fields
        # to prevent audit log injection (newline injection → forged MARKER_USED line).
        $safeMarkerId = -join ($rawMarkerId.ToCharArray() | Where-Object { [int][char]$_ -ge 0x20 })
        $safeTicket   = -join ($rawTicket.ToCharArray()   | Where-Object { [int][char]$_ -ge 0x20 })
        $safeOrg      = -join ($rawOrg.ToCharArray()      | Where-Object { [int][char]$_ -ge 0x20 })
        $safeOp       = -join ($rawOp.ToCharArray()       | Where-Object { [int][char]$_ -ge 0x20 })
        # base64-encode command for audit completeness; strip wrapping newlines
        $commandB64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Cmd))

        # F4: fail-closed on audit-write failure — no allow without audit record
        # (BC-3.01.001 PC#2 step 8 + Invariant #2 / VP-HOOK-024).
        $auditTs   = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        $auditLine = "${auditTs} MARKER_USED marker_id=${safeMarkerId} op=${safeOp} ticket=${safeTicket} org=${safeOrg} command_b64=${commandB64}"
        $auditLog  = Join-Path $markerDir 'audit.log'
        try {
            Add-Content -Path $auditLog -Value $auditLine -ErrorAction Stop
        }
        catch { return $false }

        return $true
    }

    return $false
}

$raw = [Console]::In.ReadToEnd()
$payload = $null
try { $payload = $raw | ConvertFrom-Json } catch { Emit-Allow }

$command = ''
if ($payload -and $payload.tool_input -and $payload.tool_input.command) {
    $command = [string]$payload.tool_input.command
}

# Fast path: not a jr command -> allow immediately
if ($command -cnotlike '*jr *') { Emit-Allow }

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
#
# Write-block entry count: 12 (10 base + 2 D-020 link entries added at v1.23).
# Plain forms (a) and --output json forms (b) are listed separately because
# "jr issue link" is not a substring of "jr --output json issue link".
$blocked = @(
    'jr issue comment ',
    'jr issue edit',
    'jr issue move',
    'jr issue assign',
    'jr issue create',
    'jr issue link ',
    '--output json issue comment ',
    '--output json issue edit',
    '--output json issue move',
    '--output json issue assign',
    '--output json issue create',
    '--output json issue link '
)
foreach ($op in $blocked) {
    if ($command -clike "*$op*") {
        # D-DEC-001 v2.0: attempt marker-consume with STEP 6 exact-type matching.
        # Invoke-ValidateMarkerForCommand returns $true (allow+consume) or $false (deny).
        $markerValid = $false
        try {
            $markerValid = Invoke-ValidateMarkerForCommand $command
        }
        catch {
            $markerValid = $false
        }
        if ($markerValid) { Emit-Allow }
        Emit-Deny 'JIRA write operations require review approval. Run /review-enrichment or /adversarial-review-secops first to validate analysis quality. The jr issue link/comment/edit/move/assign/create commands are blocked until review passes quality thresholds.'
    }
}

# Allow read-only jr operations without review.
#
# Two families of patterns:
#   (a) Plain forms:  jr issue view KEY, jr issue changelog KEY, etc.
#   (b) --output json forms: jr --output json issue view KEY, etc.
# Both families are read-only. They are listed separately because the plain form
# "jr issue view" is NOT a substring of "jr --output json issue view" (the global
# flag --output json sits between "jr" and "issue"), so each needs its own entry.
$readOnly = @(
    'jr issue view', 'jr issue list', 'jr issue comments', 'jr issue assets',
    'jr issue transitions', 'jr issue changelog',
    'jr assets search', 'jr assets view',
    'jr sprint', 'jr board', 'jr project', 'jr me', 'jr auth', 'jr --version',
    '--output json issue view', '--output json issue list',
    '--output json issue comments', '--output json issue changelog',
    '--output json issue assets',
    '--output json assets search', '--output json assets view'
)
foreach ($op in $readOnly) {
    if ($command -clike "*$op*") { Emit-Allow }
}

# Unknown jr subcommand — fail-closed (SEC-002): deny rather than allow to prevent
# new write subcommands added in future jr releases from bypassing this gate.
Emit-Deny 'Unrecognized jr subcommand. Add to the read-only allowlist in require-review.ps1 if this is a safe read-only operation.'

# PSScriptAnalyzer settings for secops-factory CI
# https://github.com/PowerShell/PSScriptAnalyzer/blob/master/docs/Cmdlets/Invoke-ScriptAnalyzer.md#-settings
@{
    ExcludeRules = @(
        # PSUseBOMForUnicodeEncodedFile: excluded because this is a cross-platform
        # repo where .ps1 and .sh hook siblings are kept UTF-8 without BOM for
        # consistency. Adding BOM to .ps1 files would be inconsistent with the .sh
        # siblings and can confuse tooling on Linux/macOS (shellcheck, git, editors).
        'PSUseBOMForUnicodeEncodedFile',

        # PSUseApprovedVerbs: excluded because the flagged functions (Emit-Allow,
        # Emit-Deny) are script-internal helper functions, not exported module cmdlets.
        # PSUseApprovedVerbs targets Verb-Noun naming for discoverable exported commands
        # so users can find them with Get-Command. These helpers are private, never
        # exported, and intentionally named to mirror the .sh emit_allow/emit_deny
        # counterparts for cross-language parity readability. Renaming would silently
        # break the parity convention enforced by parity.bats.
        'PSUseApprovedVerbs'
    )
}

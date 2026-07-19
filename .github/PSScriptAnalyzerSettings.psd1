# PSScriptAnalyzer settings for secops-factory CI
# https://github.com/PowerShell/PSScriptAnalyzer/blob/master/docs/Cmdlets/Invoke-ScriptAnalyzer.md#-settings
@{
    ExcludeRules = @(
        # PSUseBOMForUnicodeEncodedFile is excluded because this is a cross-platform
        # repo where .ps1 and .sh hook siblings are kept UTF-8 without BOM for
        # consistency. Adding BOM to .ps1 files would be inconsistent with the .sh
        # siblings and can confuse tooling on Linux/macOS (shellcheck, git, editors).
        'PSUseBOMForUnicodeEncodedFile'
    )
}

$MT5Hash = "24F345EB9F291441AFE537834F9D8A19" # magic!
$MT5TerminalPath = "$Env:APPDATA\MetaQuotes\Terminal\$MT5Hash\MQL5"
if (!(Test-Path($MT5TerminalPath))) {
    Write-Error "MT5 terminal path not found: $MT5TerminalPath"
    exit
}

$deployRules = @(
    # deploy dependencies for live data
    [PSCustomObject]@{ 
        SourcePath = "$PSScriptRoot\Include"
        DestinationPath = "$MT5TerminalPath\Include\nng"
    },
    [PSCustomObject]@{
        SourcePath = "$PSScriptRoot\Libraries"
        DestinationPath = "$MT5TerminalPath\Libraries"
    },
    # deploy scripts
    [PSCustomObject]@{
        SourcePath = "$PSScriptRoot\Scripts"
        DestinationPath = "$MT5TerminalPath\Scripts\nng"
    }
);

$deployRules | ForEach-Object {
    $rule = $_
    Get-ChildItem -Path $_.SourcePath | Foreach-Object {
        $path = "$($rule.DestinationPath)\$($_.Name)"
        $target = "$($rule.SourcePath)\$($_.Name)"
        if (Test-Path $path) {
            $(Get-Item $path).Delete()
        }
        New-Item -ItemType SymbolicLink -Path $path -Target $target -Force
    }
}
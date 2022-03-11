$ErrorActionPreference = "Stop"

# Relies on PowerShell 7.3 - roughly equivalent to `set -e`
$PSNativeCommandUseErrorActionPreference = $true

Push-Location

Set-Location $PSScriptRoot
if (Test-Path public) { Remove-Item public -Recurse }
& hugo.exe

if (Test-Path ../pseale.github.io/hot-takes) { Remove-Item ../pseale.github.io/hot-takes -Recurse }
mkdir ../pseale.github.io/hot-takes
Copy-Item public/* ../pseale.github.io/hot-takes  -Recurse

Set-Location ../pseale.github.io
& git status

Pop-Location
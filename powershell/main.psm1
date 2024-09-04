# Theme
$themeName = "night-owl"
$themePath = Join-Path $env:POSH_THEMES_PATH "$themeName.omp.json"

if (Test-Path $themePath) {
    oh-my-posh init pwsh --config $themePath | Invoke-Expression
} else {
    Write-Host "Theme '$themeName' not found in '$env:POSH_THEMES_PATH'. Falling back to default theme."
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
} else {
  Write-Host "Chocolatey profile not found at '$ChocolateyProfile'"
}

# Character encoding (needed for special characters)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
1
# Load utils
Import-Module "$PSScriptRoot\utils.psm1"

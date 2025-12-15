$ErrorActionPreference = 'Stop'

$packageName = 'yisangsay'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

# Remove the executable and frames
$exePath = Join-Path $toolsDir "yisangsay.exe"
$framesDir = Join-Path $toolsDir "frames"

if (Test-Path $exePath) {
    Remove-Item $exePath -Force
}

if (Test-Path $framesDir) {
    Remove-Item $framesDir -Recurse -Force
}

# Chocolatey automatically removes the shim

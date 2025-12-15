$ErrorActionPreference = 'Stop'

$packageName = 'yisangsay'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$version = '0.1.2'
$url64 = "https://github.com/VectorSophie/yisangsay-rs/releases/download/v$version/yisangsay-x86_64-pc-windows-gnu.zip"

$packageArgs = @{
  packageName    = $packageName
  unzipLocation  = $toolsDir
  url64bit       = $url64
  checksum64     = 'e71521776c4e9bfaff48c1d98533c0f6be4cfba21a1868b13725118222530d79'
  checksumType64 = 'sha256'
}

Install-ChocolateyZipPackage @packageArgs

# The zip contains a directory yisangsay-x86_64-pc-windows-gnu
# Move the contents to the tools directory for easier access
$extractedDir = Join-Path $toolsDir "yisangsay-x86_64-pc-windows-gnu"

if (Test-Path $extractedDir) {
    # Move binary and frames to tools directory
    Copy-Item "$extractedDir\yisangsay.exe" -Destination $toolsDir -Force
    Copy-Item "$extractedDir\frames" -Destination $toolsDir -Recurse -Force

    # Clean up the extracted directory
    Remove-Item $extractedDir -Recurse -Force
}

# Create a shim for the executable
# Chocolatey automatically creates shims for .exe files in the tools directory
# No additional action needed

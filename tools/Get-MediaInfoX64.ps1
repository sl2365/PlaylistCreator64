[CmdletBinding()]
param(
    [string]$Version = "26.05",
    [string]$Destination = (Join-Path $PSScriptRoot "..\dll\x64")
)

$ErrorActionPreference = "Stop"
$uri = "https://mediaarea.net/download/binary/libmediainfo0/$Version/MediaInfo_DLL_${Version}_Windows_x64_WithoutInstaller.zip"
$tempRoot = Join-Path ([IO.Path]::GetTempPath()) ("PlaylistCreator-MediaInfo-" + [guid]::NewGuid())
$zip = Join-Path $tempRoot "MediaInfo-x64.zip"
$extract = Join-Path $tempRoot "extract"

try {
    New-Item -ItemType Directory -Force -Path $tempRoot, $extract, $Destination | Out-Null
    Write-Host "Downloading MediaInfo DLL x64 $Version..."
    Invoke-WebRequest -Uri $uri -OutFile $zip -UseBasicParsing
    Expand-Archive -Path $zip -DestinationPath $extract -Force

    $dll = Get-ChildItem -Path $extract -Filter MediaInfo.dll -File -Recurse | Select-Object -First 1
    if (-not $dll) { throw "MediaInfo.dll was not present in the downloaded archive." }

    $bytes = [IO.File]::ReadAllBytes($dll.FullName)
    if ($bytes.Length -lt 64 -or $bytes[0] -ne 0x4D -or $bytes[1] -ne 0x5A) { throw "Downloaded file is not a PE DLL." }
    $peOffset = [BitConverter]::ToInt32($bytes, 0x3C)
    $machine = [BitConverter]::ToUInt16($bytes, $peOffset + 4)
    if ($machine -ne 0x8664) { throw ("Expected x64 PE machine 0x8664, found 0x{0:X4}." -f $machine) }

    $target = Join-Path $Destination "MediaInfo.dll"
    Copy-Item $dll.FullName $target -Force
    $hash = (Get-FileHash $target -Algorithm SHA256).Hash
    Write-Host "Installed $target"
    Write-Host "SHA-256: $hash"
}
finally {
    Remove-Item $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

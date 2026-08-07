[CmdletBinding()]
param(
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Release",
    [switch]$FetchMediaInfo
)

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")

function Get-LatestSubdirectory {
    param([Parameter(Mandatory=$true)][string]$Path)

    if (-not (Test-Path $Path)) {
        return $null
    }

    return Get-ChildItem -Path $Path -Directory |
        Sort-Object { try { [version]$_.Name } catch { [version]"0.0" } } -Descending |
        Select-Object -First 1
}

try {
    Write-Host "Build configuration: $Configuration | x64"
    Write-Host "Project folder: $root"
    Write-Host ""

    $mediaInfo = Join-Path $root "dll\x64\MediaInfo.dll"
    if ($FetchMediaInfo -or -not (Test-Path $mediaInfo)) {
        Write-Host "x64 MediaInfo.dll is not present; downloading it now..."
        & (Join-Path $PSScriptRoot "Get-MediaInfoX64.ps1")
        if (-not $?) {
            throw "MediaInfo x64 download/install failed."
        }
        if (-not (Test-Path $mediaInfo)) {
            throw "MediaInfo download completed, but the expected x64 DLL was not found: $mediaInfo"
        }
        Write-Host "MediaInfo x64 is ready. Continuing with the compiler checks..."
    }
    else {
        Write-Host "Using existing x64 MediaInfo.dll: $mediaInfo"
    }

    Write-Host ""
    Write-Host "Checking Visual Studio C++ build tools..."

    $vswhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
    if (-not (Test-Path $vswhere)) {
        throw "Visual Studio Installer was not found. Install or repair Visual Studio Community 2026, then add the 'Desktop development with C++' workload."
    }

    # Do not require a particular MSVC component ID here. Visual Studio 2026
    # can install multiple serviced MSVC toolsets and their component IDs change.
    $installationPath = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild -property installationPath
    if (-not $installationPath) {
        throw "Visual Studio with MSBuild was not found. Open Visual Studio Installer and make sure Visual Studio Community 2026 is installed."
    }

    $msbuild = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe | Select-Object -First 1
    if (-not $msbuild -or -not (Test-Path $msbuild)) {
        throw "MSBuild was not found inside Visual Studio. Use Visual Studio Installer to repair or modify the Visual Studio Community 2026 installation."
    }

    Write-Host "Visual Studio: $installationPath"
    Write-Host "MSBuild: $msbuild"

    $vcToolsRoot = Join-Path $installationPath "VC\Tools\MSVC"
    $vcToolsVersionFile = Join-Path $installationPath "VC\Auxiliary\Build\Microsoft.VCToolsVersion.default.txt"
    $vcToolsDir = $null

    if (Test-Path $vcToolsVersionFile) {
        $vcToolsVersion = (Get-Content $vcToolsVersionFile -Raw).Trim()
        if ($vcToolsVersion) {
            $candidate = Join-Path $vcToolsRoot $vcToolsVersion
            if (Test-Path $candidate) {
                $vcToolsDir = Get-Item $candidate
            }
        }
    }

    if (-not $vcToolsDir) {
        $vcToolsDir = Get-LatestSubdirectory -Path $vcToolsRoot
    }

    if (-not $vcToolsDir) {
        throw "MSVC C++ Build Tools are missing. In Visual Studio Installer, add 'MSVC Build Tools for x64/x86 (Latest)'."
    }

    $cl = Join-Path $vcToolsDir.FullName "bin\Hostx64\x64\cl.exe"
    if (-not (Test-Path $cl)) {
        throw "The x64 C++ compiler is missing. In Visual Studio Installer, add 'MSVC Build Tools for x64/x86 (Latest)'."
    }
    Write-Host "x64 C++ compiler: OK ($($vcToolsDir.Name))"

    $mfcHeader = Join-Path $vcToolsDir.FullName "atlmfc\include\afxwin.h"
    $mfcLibDir = Join-Path $vcToolsDir.FullName "atlmfc\lib\x64"
    if (-not (Test-Path $mfcHeader) -or -not (Test-Path $mfcLibDir)) {
        throw "C++ MFC for x64 is missing. In Visual Studio Installer, add 'C++ MFC for x64/x86 (Latest MSVC)'."
    }
    Write-Host "C++ MFC x64: OK"

    $windowsKitsRoot = Join-Path ${env:ProgramFiles(x86)} "Windows Kits\10"
    $sdkIncludeRoot = Join-Path $windowsKitsRoot "Include"
    $sdkVersions = @()
    if (Test-Path $sdkIncludeRoot) {
        $sdkVersions = Get-ChildItem -Path $sdkIncludeRoot -Directory |
            Sort-Object { try { [version]$_.Name } catch { [version]"0.0" } } -Descending
    }

    $sdkVersion = $null
    foreach ($sdk in $sdkVersions) {
        $windowsHeader = Join-Path $sdk.FullName "um\Windows.h"
        $kernelLib = Join-Path $windowsKitsRoot ("Lib\{0}\um\x64\kernel32.lib" -f $sdk.Name)
        if ((Test-Path $windowsHeader) -and (Test-Path $kernelLib)) {
            $sdkVersion = $sdk.Name
            break
        }
    }

    if (-not $sdkVersion) {
        throw "A Windows SDK with x64 libraries is missing. In Visual Studio Installer, add the latest 'Windows 11 SDK'."
    }
    Write-Host "Windows SDK x64: OK ($sdkVersion)"
    Write-Host ""
    Write-Host "Build environment is ready. Starting compilation..."
    Write-Host ""

    & $msbuild (Join-Path $root "PlaylistCreator3.sln") /m /restore /t:Rebuild /p:Configuration=$Configuration /p:Platform=x64 /verbosity:minimal
    $result = $LASTEXITCODE
    if ($result -ne 0) {
        Write-Host ""
        Write-Host "MSBuild failed with error code $result."
        exit $result
    }

    $output = Join-Path $root "bin\x64\$Configuration\pc3.exe"
    if (-not (Test-Path $output)) {
        throw "MSBuild reported success, but the expected output was not found: $output"
    }

    Write-Host ""
    Write-Host "Build succeeded."
    Write-Host "Output: $output"
    exit 0
}
catch {
    Write-Host ""
    Write-Host "BUILD ERROR: $($_.Exception.Message)"
    exit 1
}

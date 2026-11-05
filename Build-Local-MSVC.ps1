# Builds the local eden-fefw source (this folder) with MSVC + Ninja, Release, x64.
# Run from any PowerShell window in the folder that holds this script and the source:
#   Set-ExecutionPolicy -Scope Process Bypass; .\Build-Local-MSVC.ps1
# Output goes to .\Eden-FEFW-local\eden.exe. The existing .\eden.exe is not touched.
# 1.12 build:  .\Build-Local-MSVC.ps1 -Version 1.12   (source eden-fefw-1.12, output Eden-FEFW-1.12-local)
# Shareable:   .\Build-Local-MSVC.ps1 -Version 1.12 -Portable
#              (any x64 CPU, VC++ runtime bundled, output FEFW-Stable-60FPS-Portable + .zip)

[CmdletBinding()]
param(
    [ValidateSet('kcode', '1.12')]
    [string]$Version = 'kcode',
    [ValidateSet('AVX512', 'AVX2', 'None')]
    [string]$RenderIsa = 'AVX512',          # Ryzen 7 9800X3D (Zen 5) supports AVX-512
    [ValidateSet('Auto', 'On', 'Off')]
    [string]$Pgo = 'Auto',                  # Auto: only with the compiler and source the profile was made with
    [switch]$Portable,                      # build for any x64 CPU and package it for other people
    [int]$Jobs = [Environment]::ProcessorCount,
    [switch]$Clean
)
if ($Portable) { $RenderIsa = 'None'; $Pgo = 'Off' }

$ErrorActionPreference = 'Stop'
$root      = $PSScriptRoot
$pgoDir    = Join-Path $root 'pgo-crowd-20261104'
if ($Version -eq '1.12') {
    $sourceDir = Join-Path $root 'eden-fefw-1.12'
    $buildDir  = Join-Path $root 'build-1.12'
    $outDir    = Join-Path $root 'Eden-FEFW-1.12-local'
    $zip       = Join-Path $root 'eden-fefw-1.12-local.zip'
    if (-not (Test-Path $sourceDir) -and (Test-Path $zip)) {
        Write-Host "Extracting $zip"
        Expand-Archive -LiteralPath $zip -DestinationPath $root
    }
} else {
    $sourceDir = Join-Path $root 'eden-fefw'
    $buildDir  = Join-Path $root 'build'    # must sit beside pgo-crowd-20261104 (profile path is ../)
    $outDir    = Join-Path $root 'Eden-FEFW-local'
}
if ($Portable) {
    $buildDir = "$buildDir-portable"
    $outDir   = Join-Path $root 'FEFW-Stable-60FPS-Portable'
}
$logFile   = Join-Path $root 'build-log.txt'
$pgoCompiler = '19.51.36260'
$toolLog   = Join-Path $root 'cmake-output.txt'

# Windows PowerShell's transcript misses native stderr, so run tools through cmd and tee everything.
function Invoke-Logged([string]$Exe, [string[]]$Argv) {
    $line = ($Argv | ForEach-Object { if ($_ -match '[\s"]' -or $_ -eq '') { '"' + $_ + '"' } else { $_ } }) -join ' '
    Write-Host "`n> $Exe $line" -ForegroundColor Cyan
    & cmd.exe /d /s /c "`"$Exe $line 2>&1`"" | Tee-Object -FilePath $toolLog -Append | Out-Host
    return $LASTEXITCODE
}

Start-Transcript -Path $logFile -Force | Out-Null
if (Test-Path $toolLog) { Remove-Item -LiteralPath $toolLog -Force }
try {
    foreach ($p in @($sourceDir, (Join-Path $sourceDir 'CMakeLists.txt'), (Join-Path $root 'cmake-options.txt'))) {
        if (-not (Test-Path -LiteralPath $p)) { throw "Missing: $p" }
    }

    # Enter the x64 MSVC environment if this isn't already a Developer PowerShell.
    if (-not (Get-Command cl.exe -ErrorAction SilentlyContinue)) {
        $vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
        if (-not (Test-Path $vswhere)) { throw 'Visual Studio not found (no vswhere.exe). Install VS with "Desktop development with C++".' }
        $vs = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
        if (-not $vs) { throw 'No Visual Studio install with the x64 C++ tools found.' }
        Write-Host "Using Visual Studio at $vs"
        Import-Module (Join-Path $vs 'Common7\Tools\Microsoft.VisualStudio.DevShell.dll')
        Enter-VsDevShell -VsInstallPath $vs -SkipAutomaticLocation -DevCmdArguments '-arch=x64 -host_arch=x64' | Out-Null
    }
    foreach ($tool in 'cl', 'cmake', 'ninja', 'git') {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            throw "'$tool' not found. cmake/ninja come with VS's 'C++ CMake tools for Windows' component; git with Git for Windows."
        }
    }

    $clBanner = (& cmd.exe /d /c 'cl 2>&1' | Out-String)
    if ($clBanner -notmatch '(19\.\d+\.\d+)') { throw 'Could not read the MSVC version.' }
    $clVersion = $Matches[1]
    if (((& cmake --version) | Select-Object -First 1) -notmatch '(\d+\.\d+\.\d+)') { throw 'Could not read the CMake version.' }
    $cmakeVersion = [version]$Matches[1]
    if ($cmakeVersion -lt [version]'3.31') { throw "CMake 3.31+ needed, found $cmakeVersion." }
    Write-Host "MSVC $clVersion, CMake $cmakeVersion, $Jobs jobs, renderer ISA $RenderIsa"

    $usePgo = switch ($Pgo) {
        'On'   { $true }
        'Off'  { $false }
        'Auto' { $Version -eq 'kcode' -and $clVersion -eq $pgoCompiler -and (Test-Path (Join-Path $pgoDir 'eden.pgd')) }
    }

    if ($Clean -and (Test-Path $buildDir)) { Remove-Item -LiteralPath $buildDir -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $buildDir | Out-Null

    if ($RenderIsa -eq 'None') {
        Write-Host 'Portable: no CPU-specific code, no PGO' -ForegroundColor Green
        $include = $null
    } elseif ($usePgo) {
        Write-Host 'PGO: on (profile matches this compiler)' -ForegroundColor Green
        $include = Join-Path $pgoDir 'link-profile.cmake'   # applies the profile and the renderer ISA
    } else {
        Write-Warning "PGO: off (the profile only matches the kcode source with MSVC $pgoCompiler; this is $Version with $clVersion). AVX-512 renderer files still apply."
        # The repo's include fails without a profile stage, so apply just the ISA part.
        $include = Join-Path $buildDir 'render-isa-only.cmake'
        @'
function(eden_render_isa_options)
    if(MSVC AND TARGET video_core AND EDEN_LOCAL_RENDER_ISA)
        foreach(unit IN ITEMS
                renderer_vulkan/vk_graphics_pipeline.cpp
                renderer_vulkan/vk_texture_cache_base.cpp
                renderer_vulkan/vk_buffer_cache.cpp
                renderer_vulkan/vk_rasterizer.cpp
                renderer_vulkan/vk_compute_pipeline.cpp)
            set_property(SOURCE "${CMAKE_SOURCE_DIR}/src/video_core/${unit}"
                TARGET_DIRECTORY video_core APPEND PROPERTY COMPILE_OPTIONS
                "/arch:${EDEN_LOCAL_RENDER_ISA}" /fp:precise)
        endforeach()
    endif()
endfunction()
cmake_language(DEFER CALL eden_render_isa_options)
'@ | Set-Content -LiteralPath $include -Encoding ASCII
    }

    $cmakeArgs = @('-S', $sourceDir, '-B', $buildDir, '-G', 'Ninja',
                   '-DCMAKE_EXE_LINKER_FLAGS:STRING=/machine:x64')
    foreach ($line in Get-Content -LiteralPath (Join-Path $root 'cmake-options.txt')) {
        $entry = $line.Trim()
        if ($entry -notmatch '^([A-Za-z0-9_]+):[A-Za-z0-9_]+=') { continue }
        $key = $Matches[1]
        if ($key -eq 'EDEN_LOCAL_RENDER_ISA') { continue }
        if ($key -eq 'EDEN_LOCAL_PROFILE_STAGE' -and -not $usePgo) { continue }
        if ($key -eq 'YUZU_TESTS') { $entry = 'YUZU_TESTS:BOOL=OFF' }   # not needed for eden.exe
        $cmakeArgs += "-D$entry"
    }
    if ($include) {
        $cmakeArgs += "-DEDEN_LOCAL_RENDER_ISA:STRING=$RenderIsa"
        $cmakeArgs += "-DCMAKE_PROJECT_yuzu_INCLUDE:FILEPATH=$include"
    }

    $code = Invoke-Logged 'cmake' $cmakeArgs
    if ($code) { throw "CMake configure failed ($code). See $toolLog" }

    $code = Invoke-Logged 'cmake' @('--build', $buildDir, '--target', 'yuzu', '--parallel', "$Jobs")
    if ($code) { throw "Build failed ($code). See $toolLog" }

    $exe = Join-Path $buildDir 'bin\eden.exe'
    if (-not (Test-Path $exe)) { throw "Build finished but $exe is missing." }

    if (Test-Path $outDir) { Remove-Item -LiteralPath $outDir -Recurse -Force }
    New-Item -ItemType Directory -Path $outDir | Out-Null
    Copy-Item -Path (Join-Path $buildDir 'bin\*') -Destination $outDir -Recurse -Force
    Copy-Item -LiteralPath (Join-Path $root 'LICENSE') -Destination $outDir -ErrorAction SilentlyContinue

    if ($Portable) {
        Remove-Item -LiteralPath (Join-Path $outDir 'eden.pdb') -ErrorAction SilentlyContinue
        # App-local VC++ runtime, so nobody needs to install the redistributable.
        if (-not $env:VCToolsRedistDir) { throw 'VCToolsRedistDir is not set; run from a normal PowerShell so the script sets up the VS environment.' }
        $crt = Get-ChildItem -Path (Join-Path $env:VCToolsRedistDir 'x64') -Directory -Filter 'Microsoft.VC*.CRT' |
               Select-Object -First 1
        if (-not $crt) { throw "VC++ runtime DLLs not found under $env:VCToolsRedistDir" }
        Copy-Item -Path (Join-Path $crt.FullName '*.dll') -Destination $outDir
        # GPL: ship the exact source alongside the binary.
        $srcZip = if ($Version -eq '1.12') { Join-Path $root 'eden-fefw-1.12-local.zip' } else { $null }
        if ($srcZip -and (Test-Path $srcZip)) { Copy-Item -LiteralPath $srcZip -Destination (Join-Path $outDir 'source.zip') }
        # The Fortune's Weave 60 fps cheat from this PC's profile, for others to copy into theirs.
        $fpsMod = Join-Path $env:APPDATA 'eden\load\04007EF01F8AE000\60fps'
        $hasFpsMod = Test-Path $fpsMod
        # Portable profile: a "user" folder next to eden.exe keeps keys, firmware, settings and
        # saves inside this folder instead of %APPDATA%\eden.
        $userDir = Join-Path $outDir 'user'
        New-Item -ItemType Directory -Force -Path $userDir | Out-Null
        'Eden keeps its settings, saves and shader cache in this folder. Delete it to use %APPDATA%\eden instead.' |
            Set-Content -LiteralPath (Join-Path $userDir 'README.txt') -Encoding ASCII
        # Pre-set settings (cleaned copy of this PC's: no paths, controller IDs or logins), including
        # the Fortune's Weave per-game profile with the 12 GB memory layout the game needs.
        $presetConfig = Join-Path $root 'portable-config'
        if (Test-Path $presetConfig) {
            Copy-Item -Path $presetConfig -Destination (Join-Path $userDir 'config') -Recurse
        } else {
            Write-Warning 'portable-config not found: the package will start with default settings, and Fortune''s Weave needs the 12 GB memory layout.'
        }
        if ($hasFpsMod) {
            $modDest = Join-Path $userDir 'load\04007EF01F8AE000'
            New-Item -ItemType Directory -Force -Path $modDest | Out-Null
            Copy-Item -LiteralPath $fpsMod -Destination $modDest -Recurse
        }
        $fpsText = if ($hasFpsMod) { @"

60 FPS MOD (Fortune's Weave) - already installed in user\load\04007EF01F8AE000\60fps.
It is on by default. If you have problems with it (uneven frame pacing, glitches),
DELETE the folder user\load\04007EF01F8AE000\60fps to go back to the normal 30 fps;
unticking it under Add-Ons isn't always enough.
It only works with the game version whose build ID starts DB93B0125F485060;
other versions just ignore it.
"@ } else { '' }
        @"
FEFW Stable with 60 FPS Patch - portable Windows x64 build
(Eden FE: Fortune's Weave fork, based on xDarkWindx eden-fefw $Version)

Runs on any 64-bit Windows 10/11 PC with a Vulkan-capable GPU. No CPU-specific code
and the Microsoft C++ runtime is included, so nothing needs installing.

GETTING STARTED
1. Extract this whole folder somewhere (not inside Program Files) and run eden.exe.
2. Add your game folder: double-click the empty game list and choose the folder.

No games, keys or firmware are included. Use your own copy of the game as loose files
(exefs/romfs), dumped from your own console.
Everything (settings, saves, shader cache) stays in the user\ folder here,
so this doesn't touch any other Eden install. To move it, move the whole folder.

SETTINGS are already set up, including a Fortune's Weave profile (right-click the game >
Properties) with the 12 GB memory layout the game needs, GPU mode Fast and asynchronous shaders.
Only controls need setting: Emulation > Configure > Controls.
$fpsText

Changes from upstream: the start-up check that clears empty save profile folders no longer
crashes when Windows refuses the delete, and never deletes a folder it could not read.

Licence: GPL-3.0-or-later (see LICENSE). The full source for this build is in source.zip.
Built with MSVC $clVersion on $(Get-Date -Format 'yyyy-MM-dd').
"@ | Set-Content -LiteralPath (Join-Path $outDir 'README.txt') -Encoding ASCII
        $pkg = "$outDir.zip"
        if (Test-Path $pkg) { Remove-Item -LiteralPath $pkg -Force }
        Compress-Archive -Path (Join-Path $outDir '*') -DestinationPath $pkg -CompressionLevel Optimal
        Write-Host "Package: $pkg" -ForegroundColor Green
    }

    Write-Host "`nBUILD SUCCEEDED: $outDir\eden.exe" -ForegroundColor Green
    Write-Host "MSVC $clVersion | PGO $(if ($usePgo) {'on'} else {'off'}) | renderer $RenderIsa"
}
catch {
    Write-Host "`nBUILD FAILED: $_" -ForegroundColor Red
    throw
}
finally {
    Stop-Transcript | Out-Null
}

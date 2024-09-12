# Copyright (C) 2018-2023 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
Param(
    [string]$Target = "x64",
    [switch]$Quiet
)

# Get VS name and path
$VS_Name=vswhere -latest -products * -property displayName
$VS_Path=vswhere -latest -products * -property installationPath

# Setup for MSVC
pushd "$VS_Path\VC\Auxiliary\Build\"
if($Target.equals("x86")) {
    cmd /c "vcvars32.bat&set" |
    foreach {
        if ($_ -match "=") {
            $v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
        }
    }
} else {
    cmd /c "vcvars64.bat&set" |
    foreach {
        if ($_ -match "=") {
            $v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
        }
    }
}
popd

if (!$Quiet) { Write-Host "`n$VS_Name environment variables set." -ForegroundColor Yellow }

$env:INCLUDE = $env:INCLUDE + ";" + [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","User")
$env:LIB = $env:LIB + ";" + [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","User")

if($Target.equals("clang-cl")) {
    if (!$Quiet) { Write-Host "`nSetup for clang-cl" -ForegroundColor Yellow }
    $env:CC="clang-cl"
    $env:CXX="clang-cl"
}
if($Target.equals("clang")) {
    if (!$Quiet) { Write-Host "`nSetup for clang" -ForegroundColor Yellow }
    $env:CC="clang"
    $env:CXX="clang"
    $env:LDFLAGS="-fuse-ld=lld"
}
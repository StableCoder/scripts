# Copyright (C) 2023-2025 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release",
    [string]$Version = "1.0.20",
    [string]$InstallDir = "C:/libsodium",
    [string]$EnvironmentVariableScope = "User" # use 'Machine' to set it machine-wide
)

$invocationDir = (Get-Item -Path "./").FullName

try {
    # Use a working directory, to keep our work self-contained
    Write-Host "Creating working directory"
    mkdir libsodium-workdir
    cd libsodium-workdir

    # Download/Extract the source code
    Write-Host "Downloading/extracting source"
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = "tls13"
    Invoke-WebRequest -Uri https://download.libsodium.org/libsodium/releases/libsodium-${Version}-stable-msvc.zip -OutFile libsodium.zip -UseBasicParsing
    7z x -aoa libsodium.zip
    cd libsodium

    # Remove the older install (if it exists)
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path $InstallDir

    # Install
    Write-Host "Installing"
    mkdir $InstallDir/include
    mkdir $InstallDir/bin
    mkdir $InstallDir/lib

    Copy-Item include/ -Destination $InstallDir/ -Recurse
    Copy-Item X64/$BuildType/v143/dynamic/*.dll -Destination $InstallDir/bin/
    Copy-Item X64/$BuildType/v143/dynamic/*.lib -Destination $InstallDir/lib/
    
    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path libsodium-workdir/ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";$InstallDir/bin" | ? { [System.Environment]::GetEnvironmentVariable("PATH","$EnvironmentVariableScope") -match $_ })) {
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","$EnvironmentVariableScope") + ";$InstallDir/bin", [System.EnvironmentVariableTarget]::$EnvironmentVariableScope )
    }
    if($null -eq ( ";$InstallDir/include" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","$EnvironmentVariableScope") -match $_ })) {
        [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","$EnvironmentVariableScope") + ";$InstallDir/include", [System.EnvironmentVariableTarget]::$EnvironmentVariableScope )
    }
    if($null -eq ( ";$InstallDir/lib" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","$EnvironmentVariableScope") -match $_ })) {
        [Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","$EnvironmentVariableScope") + ";$InstallDir/lib", [System.EnvironmentVariableTarget]::$EnvironmentVariableScope )
    }
} catch {
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path libsodium-workdir/ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
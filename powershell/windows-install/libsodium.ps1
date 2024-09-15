# Copyright (C) 2023-2024 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release",
    [string]$Version = "1.0.20"
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
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    Invoke-WebRequest -Uri https://download.libsodium.org/libsodium/releases/libsodium-${Version}-stable-msvc.zip -OutFile libsodium.zip -UseBasicParsing
    7z x -aoa libsodium.zip
    cd libsodium

    # Remove the older install (if it exists)
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path C:/libsodium

    # Install
    Write-Host "Installing"
    mkdir C:/libsodium/include
    mkdir C:/libsodium/bin
    mkdir C:/libsodium/lib

    Copy-Item include/ -Destination C:/libsodium/ -Recurse
    Copy-Item X64/$BuildType/v143/dynamic/*.dll -Destination C:/libsodium/bin/
    Copy-Item X64/$BuildType/v143/dynamic/*.lib -Destination C:/libsodium/lib/
    
    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path libsodium-workdir/ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";C:\\libsodium\\bin" | ? { [System.Environment]::GetEnvironmentVariable("PATH","Machine") -match $_ })) {
        # PATH
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\libsodium\bin", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\libsodium\\include" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") -match $_ })) {
        # CUSTOM_INCLUDE
        [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\libsodium\include", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\libsodium\\lib" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") -match $_ })) {
        # CUSTOM_LIB
        [Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\libsodium\lib", [System.EnvironmentVariableTarget]::Machine )
    }
} catch {
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path libsodium-workdir/ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
# Copyright (C) 2018-2024 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release",
    [string]$Version = "5.4.3"
)

$invocationDir = (Get-Item -Path "./").FullName

try{
    # Use a working directory, to keep our work self-contained
    Write-Host "Creating working directory"
    mkdir assimp-workdir
    cd assimp-workdir

    # Download/Extract the source code
    Write-Host "Downloading/extracting source"
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    Invoke-WebRequest -Uri https://github.com/assimp/assimp/archive/v${Version}.tar.gz -OutFile assimp.tar.gz -UseBasicParsing
    7z x -aoa assimp.tar.gz
    7z x -aoa assimp.tar
    cd assimp-${Version}

    # Configure/compile
    Write-Host "Configuring and compiling"
    cmake -B build -GNinja -DCMAKE_BUILD_TYPE="$BuildType" -DASSIMP_BUILD_ASSIMP_TOOLS=OFF -DASSIMP_BUILD_TESTS=OFF -DLIBRARY_SUFFIX="" -DCMAKE_INSTALL_PREFIX="C:/assimp"
    cmake --build build
    if($LastExitCode -ne 0) { throw }

    # Remove the older install (if it exists)
    Write-Host "Removing old install (if it exists)"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path C:/assimp

    # Install
    Write-Host "Installing"
    cmake --install build
    if($LastExitCode -ne 0) { throw }

    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path ./assimp-workdir/ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";C:\\assimp\\bin" | ? { [System.Environment]::GetEnvironmentVariable("PATH","Machine") -match $_ })) {
        # PATH
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\assimp\bin", [System.EnvironmentVariableTarget]::Machine )
    }
} catch {
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path assimp-workdir/ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
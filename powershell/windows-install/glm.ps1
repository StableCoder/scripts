# Copyright (C) 2018-2024 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release",
    [string]$Version = "1.0.1"
)

$invocationDir = (Get-Item -Path "./").FullName

try {
    # Use a working directory, to keep our work self-contained
    Write-Host "Creating working directory"
    mkdir glm-workdir
    cd glm-workdir

    # Download/Extract the source code
    Write-Host "Downloading/extracting source"
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    Invoke-WebRequest -Uri https://github.com/g-truc/glm/archive/refs/tags/${Version}.zip -OutFile glm.zip -UseBasicParsing
    7z x glm.zip
    cd glm-${Version}

    # Configure and Compile
    Write-Host "Configuring and compiling"
    cmake -B build -G Ninja -D CMAKE_BUILD_TYPE="$BuildType" -D BUILD_SHARED_LIBS=OFF -D CMAKE_INSTALL_PREFIX="C:/glm" -D GLM_BUILD_TESTS=OFF
    cmake --build build
    if($LastExitCode -ne 0) { throw }

    # Remove the older install (if it exists)
    Write-Host "Removing old install (if it exists)"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path C:/glm

    # Install
    Write-Host "Installing"
    cmake --install build
    if($LastExitCode -ne 0) { throw }

    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path glm-workdir/ -Recurse -ErrorAction SilentlyContinue
}
catch
{
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path glm-workdir/ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
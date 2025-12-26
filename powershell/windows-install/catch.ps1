# Copyright (C) 2018-2025 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release",
    [string]$Version = "3.11.0",
    [string]$InstallDir = "C:/catch2"
)

$invocationDir = (Get-Item -Path "./").FullName

try {
    # Use a working directory, to keep our work self-contained
    Write-Host "Creating working directory"
    mkdir catch2-workdir
    cd catch2-workdir

    # Download the single header directly to the destination
    Write-Host "Downloading/extracting source"
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = "tls13, tls12"
    Invoke-WebRequest -Uri https://github.com/catchorg/Catch2/archive/refs/tags/v${Version}.tar.gz -OutFile catch2.tar.gz -UseBasicParsing
    7z x -aoa catch2.tar.gz
    7z x -aoa catch2.tar
    cd Catch2-${Version}

    # Build library
    Write-Host "Configuring and compiling"
    cmake -B build -G Ninja -DCMAKE_BUILD_TYPE="$BuildType" -DCMAKE_INSTALL_PREFIX="$InstallDir" -DCMAKE_INSTALL_LIBDIR=lib -DCATCH_BUILD_EXAMPLES=OFF -DCATCH_ENABLE_COVERAGE=OFF -DCATCH_ENABLE_WERROR=OFF -DBUILD_TESTING=ON
    cmake --build build
    if($LastExitCode -ne 0) { throw }

    # Install the compiled lib
    Write-Host "Installing"
    cmake --install build
    if($LastExitCode -ne 0) { throw }

    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path catch2-workdir/ -Recurse -ErrorAction SilentlyContinue
}
catch
{
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path catch2-workdir/ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
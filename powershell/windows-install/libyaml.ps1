# Copyright (C) 2019-2025 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release",
    [string]$Version = "0.2.5",
    [string]$InstallDir = "C:/libyaml",
    [string]$EnvironmentVariableScope = "User" # use 'Machine' to set it machine-wide
)

$invocationDir = (Get-Item -Path "./").FullName

try {
    # Use a working directory, to keep our work self-contained
    Write-Host "Creating working directory"
    mkdir libyaml-workdir
    cd libyaml-workdir

    # Download/Extract the source code
    Write-Host "Downloading/extracting source"
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = "tls13, tls12"
    Invoke-WebRequest -Uri https://github.com/yaml/libyaml/archive/${Version}.tar.gz -OutFile libyaml.tar.gz -UseBasicParsing
    7z x -aoa libyaml.tar.gz
    Remove-Item -Path libyaml.tar.gz
    7z x -aoa libyaml.tar
    Remove-Item -Path libyaml.tar
    cd libyaml-${Version}

    # Configure/compile
    Write-Host "Configuring and compiling"
    cmake -B build -GNinja -DCMAKE_BUILD_TYPE="$BuildType" -DCMAKE_INSTALL_PREFIX="$InstallDir" -DBUILD_SHARED_LIBS=ON -DBUILD_TESTING=OFF
    cmake --build build
    if($LastExitCode -ne 0) { throw }

    # Install
    Write-Host "Installing"
    cmake --install build
    if($LastExitCode -ne 0) { throw }
    
    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path libyaml-workdir/ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";$InstallDir/bin" | ? { [System.Environment]::GetEnvironmentVariable("PATH","$EnvironmentVariableScope") -match $_ })) {
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","$EnvironmentVariableScope") + ";$InstallDir/bin", [System.EnvironmentVariableTarget]::$EnvironmentVariableScope )
    }
} catch {
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path libyaml-workdir/ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
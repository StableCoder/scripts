# Copyright (C) 2018-2025 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release",
    [string]$Version = "3.4",
    [string]$InstallDir = "C:/glfw",
    [string]$EnvironmentVariableScope = "User" # use 'Machine' to set it machine-wide
)

$invocationDir = (Get-Item -Path "./").FullName

try {   
    # Use a working directory, to keep our work self-contained
    Write-Host "Creating working directory"
    mkdir glfw-workdir
    cd glfw-workdir

    # Download/Extract the source code
    Write-Host "Downloading/extracting source"
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = "tls13, tls12"
    Invoke-WebRequest -Uri https://github.com/glfw/glfw/releases/download/${Version}/glfw-${Version}.zip -OutFile glfw-${Version}.zip -UseBasicParsing
    7z x glfw-${Version}.zip
    Remove-Item -Path glfw-${Version}.zip -Recurse -ErrorAction SilentlyContinue
    cd glfw-${Version}

    # Configure and Compile
    Write-Host "Configuring and compiling"
    cmake -B build -G Ninja -D CMAKE_BUILD_TYPE="$BuildType" -D BUILD_SHARED_LIBS=ON -D CMAKE_INSTALL_PREFIX="$InstallDir" -D GLFW_BUILD_EXAMPLES=OFF -D GLFW_BUILD_TESTS=OFF -D GLFW_BUILD_DOCS=OFF
    cmake --build build
    if($LastExitCode -ne 0) { throw }

    # Install
    Write-Host "Installing"
    cmake --install build
    if($LastExitCode -ne 0) { throw }
    
    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path glfw-workdir/ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";$InstallDir/bin" | ? { [System.Environment]::GetEnvironmentVariable("PATH","$EnvironmentVariableScope") -match $_ })) {
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","$EnvironmentVariableScope") + ";$InstallDir/bin", [System.EnvironmentVariableTarget]::$EnvironmentVariableScope )
    }
} catch {
    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path glfw-workdir/ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
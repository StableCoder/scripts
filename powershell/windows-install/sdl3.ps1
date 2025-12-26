# Copyright (C) 2025 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release",
    [string]$Version = "3.2.28",
    [string]$InstallDir = "C:/sdl3",
    [string]$EnvironmentVariableScope = "User" # use 'Machine' to set it machine-wide
)

$invocationDir = (Get-Item -Path "./").FullName

try {   
    # Use a working directory, to keep our work self-contained
    Write-Host "Creating working directory"
    mkdir sdl3-workdir
    cd sdl3-workdir

    # Download/Extract the source code
    Write-Host "Downloading/extracting source"
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = "tls13, tls12"
    Invoke-WebRequest -Uri https://github.com/libsdl-org/SDL/releases/download/release-${Version}/SDL3-${Version}.zip -OutFile sdl3-${Version}.zip -UseBasicParsing
    7z x sdl3-${Version}.zip
    Remove-Item -Path sdl3-${Version}.zip -Recurse -ErrorAction SilentlyContinue
    cd SDL3-${Version}

    # Configure and Compile
    Write-Host "Configuring and compiling"
    cmake -B build -G Ninja -D CMAKE_BUILD_TYPE="$BuildType" -D CMAKE_INSTALL_PREFIX="$InstallDir" -D SDL_TEST_LIBRARY=OFF
    cmake --build build
    if($LastExitCode -ne 0) { throw }

    # Install
    Write-Host "Installing"
    cmake --install build
    if($LastExitCode -ne 0) { throw }
    
    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path sdl3-workdir/ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";$InstallDir/bin" | ? { [System.Environment]::GetEnvironmentVariable("PATH","$EnvironmentVariableScope") -match $_ })) {
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","$EnvironmentVariableScope") + ";$InstallDir/bin", [System.EnvironmentVariableTarget]::$EnvironmentVariableScope )
    }
} catch {
    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path sdl3-workdir/ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
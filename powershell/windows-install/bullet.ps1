# Copyright (C) 2018-2025 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release",
    [string]$Version = "3.25",
    [string]$InstallDir = "C:/bullet",
    [string]$EnvironmentVariableScope = "User" # use 'Machine' to set it machine-wide
)

$invocationDir = (Get-Item -Path "./").FullName

try {
    # Use a working directory, to keep our work self-contained
    Write-Host "Creating working directory"
    mkdir bullet-workdir
    cd bullet-workdir
    
    # Download/Extract the source code
    Write-Host "Downloading/extracting source"
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = "tls13, tls12"
    Invoke-WebRequest -Uri https://github.com/bulletphysics/bullet3/archive/${Version}.tar.gz -OutFile bullet.tar.gz -UseBasicParsing
    7z x bullet.tar.gz
    7z x bullet.tar
    cd bullet3-${Version}

    # Configure and Compile
    Write-Host "Configuring and compiling"
    cmake -B build -G Ninja -D CMAKE_BUILD_TYPE="$BuildType" -D CMAKE_INSTALL_PREFIX="$InstallDir" -D BUILD_SHARED_LIBS=OFF  -D USE_MSVC_RUNTIME_LIBRARY_DLL=ON -D BUILD_BULLET3=OFF -D BUILD_BULLET2_DEMOS=OFF -D BUILD_EXTRAS=OFF -D BUILD_UNIT_TESTS=OFF -D BUILD_PYBULLET=OFF -D INSTALL_LIBS=ON -D CMAKE_POLICY_VERSION_MINIMUM="3.5"
    cmake --build build
    if($LastExitCode -ne 0) { throw }

    # Install
    Write-Host "Installing"
    cmake --install build
    if($LastExitCode -ne 0) { throw }
    
    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path ./bullet-workdir/ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";$InstallDir/bin" | ? { [System.Environment]::GetEnvironmentVariable("PATH","$EnvironmentVariableScope") -match $_ })) {
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","$EnvironmentVariableScope") + ";$InstallDir/bin", [System.EnvironmentVariableTarget]::$EnvironmentVariableScope )
    }
} catch {
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path bullet-workdir/ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
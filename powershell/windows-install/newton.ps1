# Copyright (C) 2019-2025 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release",
    [string]$Version = "3.14c",
    [string]$InstallDir = "C:/newton",
    [string]$EnvironmentVariableScope = "User" # use 'Machine' to set it machine-wide
)

$invocationDir = (Get-Item -Path "./").FullName

try {
    # Use a working directory, to keep our work self-contained
    Write-Host "Creating working directory"
    mkdir newton-workdir
    cd newton-workdir

    # Download/Extract the source code
    Write-Host "Downloading/extracting source"
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = "tls13, tls12"
    Invoke-WebRequest -Uri https://github.com/MADEAPPS/newton-dynamics/archive/master.zip -OutFile newton.zip -UseBasicParsing
    7z x newton.zip
    cd newton-dynamics-master
   
    # Create/enter a separate build directory
    Write-Host "Creating build directory"
    mkdir cmake-build
    cd cmake-build
    
    # Configure/compile
    cmake .. -G Ninja -DNEWTON_BUILD_SANDBOX_DEMOS=OFF -DCMAKE_BUILD_TYPE=Release
    ninja
    if($LastExitCode -ne 0) { throw }

    # Install bin/lib
    ninja install
    if($LastExitCode -ne 0) { throw }
    mkdir $InstallDir
    Copy-Item build/* -Destination $InstallDir/ -Recurse

    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path newton-workdir/ -Recurse -ErrorAction SilentlyContinue

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
    Remove-Item -Path newton-workdir/ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
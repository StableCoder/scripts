# Copyright (C) 2019-2025 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release",
    [string]$Version = "0.8.0",
    [string]$InstallDir = "C:/yaml-cpp",
    [string]$EnvironmentVariableScope = "User" # use 'Machine' to set it machine-wide
)

$invocationDir = (Get-Item -Path "./").FullName

try {
    # Use a working directory, to keep our work self-contained
    Write-Host "Creating working directory"
    mkdir yamlcpp-workdir
    cd yamlcpp-workdir

    # Download/Extract the source code
    Write-Host "Downloading/extracting source"
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = "tls13, tls12"
    Invoke-WebRequest -Uri https://github.com/jbeder/yaml-cpp/archive/refs/tags/${Version}.zip -OutFile yaml-cpp-${Version}.zip -UseBasicParsing
    7z x -aoa yaml-cpp-${Version}.zip
    cd yaml-cpp-${Version}

    # Configure and Compile
    Write-Host "Configuring and compiling"
    cmake -B build -G Ninja -D CMAKE_BUILD_TYPE="$BuildType" -D CMAKE_INSTALL_PREFIX="$InstallDir" -D YAML_BUILD_SHARED_LIBS=ON -D YAML_CPP_BUILD_CONTRIB=OFF -D YAML_CPP_BUILD_TESTS=OFF -D YAML_CPP_BUILD_TOOLS=OFF -D CMAKE_POLICY_VERSION_MINIMUM="3.5"
    cmake --build build
    if($LastExitCode -ne 0) { throw }
    
    # Install
    Write-Host "Installing"
    cmake --install build
    if($LastExitCode -ne 0) { throw }

    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path yamlcpp-workdir/ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";$InstallDir/bin" | ? { [System.Environment]::GetEnvironmentVariable("PATH","$EnvironmentVariableScope") -match $_ })) {
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","$EnvironmentVariableScope") + ";$InstallDir/bin", [System.EnvironmentVariableTarget]::$EnvironmentVariableScope )
    }
} catch {
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path yamlcpp-workdir/ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
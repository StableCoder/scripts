# Copyright (C) 2023-2024 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release",
    [string]$Version = "2.1.12-stable"
)

$invocationDir = (Get-Item -Path "./").FullName

try {
    # Use a working directory, to keep our work self-contained
    Write-Host "Creating working directory"
    mkdir libevent-workdir
    cd libevent-workdir

    # Download/Extract the source code
    Write-Host "Downloading/extracting source"
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    Invoke-WebRequest -Uri https://github.com/libevent/libevent/releases/download/release-${Version}/libevent-${Version}.tar.gz -OutFile libevent.tar.gz -UseBasicParsing
    7z x -aoa libevent.tar.gz
    Remove-Item -Path libevent.tar.gz
    7z x -aoa libevent.tar
    Remove-Item -Path libevent.tar
    cd libevent-${Version}

    # Configure/compile
    Write-Host "Configuring and compiling"
    cmake -B build -G Ninja -D BUILD_SHARED_LIBS=ON -D CMAKE_BUILD_TYPE="$BuildType" -D CMAKE_INSTALL_PREFIX="C:/libevent" -D EVENT__DISABLE_BENCHMARK=ON -D EVENT__DISABLE_OPENSSL=ON -D EVENT__DISABLE_REGRESS=ON -D EVENT__DISABLE_SAMPLES=ON -D EVENT__DISABLE_TESTS=ON -D EVENT__DISABLE_THREAD_SUPPORT=ON
    cmake --build build
    if($LastExitCode -ne 0) { throw }

    # Remove the older install (if it exists)
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path C:/libevent

    # Install
    Write-Host "Installing"
    cmake --install build
    if($LastExitCode -ne 0) { throw }
    
    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path libevent-workdir/ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";C:\\libevent\\lib" | ? { [System.Environment]::GetEnvironmentVariable("PATH","Machine") -match $_ })) {
        # PATH
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\libevent\lib", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\libevent\\include" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") -match $_ })) {
        # CUSTOM_INCLUDE
        [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\libevent\include", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\libevent\\lib" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") -match $_ })) {
        # CUSTOM_LIB
        [Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\libevent\lib", [System.EnvironmentVariableTarget]::Machine )
    }
} catch {
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path libevent-workdir/ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
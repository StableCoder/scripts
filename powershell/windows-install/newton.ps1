# Copyright (C) 2019-2024 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release",
    [string]$Version = "3.14c"
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

    # Remove the older install (if it exists)
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path C:/newton

    # Install bin/lib
    ninja install
    if($LastExitCode -ne 0) { throw }
    mkdir C:/newton
    Copy-Item build/* -Destination C:/newton/ -Recurse

    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path newton-workdir/ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";C:\\newton\\bin" | ? { [System.Environment]::GetEnvironmentVariable("PATH","Machine") -match $_ })) {
        # PATH
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\newton\bin", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\newton\\include" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") -match $_ })) {
        # CUSTOM_INCLUDE
        [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\newton\include", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\newton\\lib" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") -match $_ })) {
        # CUSTOM_LIB
        [Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\newton\lib", [System.EnvironmentVariableTarget]::Machine )
    }
} catch {
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path newton-workdir/ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
# Copyright (C) 2019-2025 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
Param(
    # By default, build release variants of libraries
    [string]$Version = "3.18.0",
    [string]$InstallDir = "C:/freeimage",
    [string]$EnvironmentVariableScope = "User" # use 'Machine' to set it machine-wide
)

$invocationDir = (Get-Item -Path "./").FullName

try {
    # Use a working directory, to keep our work self-contained
    Write-Host "Creating working directory"
    mkdir freeimage-workdir
    cd freeimage-workdir

    # Download/Extract the source code
    Write-Host "Downloading/extracting source"
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri "http://downloads.sourceforge.net/freeimage/FreeImage3180Win32Win64.zip" -OutFile FreeImage.zip -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
    7z x FreeImage.zip

    # Install
    Write-Host "Installing"
    mkdir $InstallDir/bin
    mkdir $InstallDir/include
    mkdir $InstallDir/lib

    Copy-Item FreeImage/Dist/x64/*.dll -Destination $InstallDir/bin
    Copy-Item FreeImage/Dist/x64/*.lib -Destination $InstallDir/lib
    Copy-Item FreeImage/Dist/x64/*.h -Destination $InstallDir/include -Recurse

    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path ./freeimage-workdir/ -Recurse -ErrorAction SilentlyContinue

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
}
catch
{
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path freeimage-workdir/ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
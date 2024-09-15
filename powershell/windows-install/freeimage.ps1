# Copyright (C) 2019-2024 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
Param(
    # By default, build release variants of libraries
    [string]$Version = "3.18.0"
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

    # Remove the older install (if it exists)
    Write-Host "Removing old install (if it exists)"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path C:/freeimage

    # Install
    Write-Host "Installing"
    mkdir C:/freeimage/bin
    mkdir C:/freeimage/include
    mkdir C:/freeimage/lib

    Copy-Item FreeImage/Dist/x64/*.dll -Destination C:/freeimage/bin
    Copy-Item FreeImage/Dist/x64/*.lib -Destination C:/freeimage/lib
    Copy-Item FreeImage/Dist/x64/*.h -Destination C:/freeimage/include -Recurse

    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path ./freeimage-workdir/ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";C:\\freeimage\\bin" | ? { [System.Environment]::GetEnvironmentVariable("PATH","Machine") -match $_ })) {
        # PATH
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\freeimage\bin", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\freeimage\\include" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") -match $_ })) {
        # CUSTOM_INCLUDE
        [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\freeimage\include", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\freeimage\\lib" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") -match $_ })) {
        # CUSTOM_LIB
        [Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\freeimage\lib", [System.EnvironmentVariableTarget]::Machine )
    }
}
catch
{
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path freeimage-workdir/ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release"
)

$invocationDir = (Get-Item -Path ".\").FullName

try {
    # Use a working directory, to keep our work self-contained
    mkdir openxr-workdir
    cd openxr-workdir

    # Download/Extract the source code
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    wget https://github.com/KhronosGroup/OpenXR-SDK/archive/release-${env:OPENXR_VER}.tar.gz -OutFile openxr.tar.gz -UseBasicParsing
    7z x -aoa openxr.tar.gz
    Remove-Item -Path openxr.tar.gz
    7z x -aoa openxr.tar
    Remove-Item -Path openxr.tar
    cd OpenXR-SDK-release-${env:OPENXR_VER}

    # Create/enter a separate build directory
    mkdir cmake-build
    cd cmake-build

    # Configure/compile
    cmake .. -GNinja -DCMAKE_BUILD_TYPE="$BuildType" -DCMAKE_INSTALL_PREFIX="C:\openxr-sdk" -DDYNAMIC_LOADER=ON
    ninja
    if($LastExitCode -ne 0) { throw }

    # Remove the older install (if it exists)
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path C:\openxr-sdk

    # Install bin/lib
    ninja install
    if($LastExitCode -ne 0) { throw }

    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path .\openxr-workdir\ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";C:\\openxr-sdk\\bin" | ? { [System.Environment]::GetEnvironmentVariable("PATH","Machine") -match $_ })) {
        # PATH
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\openxr-sdk\bin;C:\openxr-sdk\bin\Debug", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\openxr-sdk\\include" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") -match $_ })) {
        # CUSTOM_INCLUDE
        [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\openxr-sdk\include", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\openxr-sdk\\lib" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") -match $_ })) {
        # CUSTOM_LIB
        [Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\openxr-sdk\lib;C:\openxr-sdk\lib\Debug", [System.EnvironmentVariableTarget]::Machine )
    }
} catch {
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path .\openxr-workdir\ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
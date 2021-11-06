Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release"
)

$invocationDir = (Get-Item -Path ".\").FullName

try {
    # Use a working directory, to keep our work self-contained
    Write-Host "Creating working directory"
    mkdir bullet-workdir
    cd bullet-workdir
    
    # Download/Extract the source code
    Write-Host "Downloading/extracting source"
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    wget https://github.com/bulletphysics/bullet3/archive/${env:BULLET_VER}.tar.gz -OutFile bullet.tar.gz -UseBasicParsing
    7z x bullet.tar.gz
    7z x bullet.tar
    cd bullet3-${env:BULLET_VER}

    # Create/enter a separate build directory
    Write-Host "Creating build directory"
    mkdir cmake-build
    cd cmake-build

    # Configure/compile
    cmake .. -G Ninja -DCMAKE_BUILD_TYPE="$BuildType" -DBUILD_SHARED_LIBS=OFF -DUSE_MSVC_RUNTIME_LIBRARY_DLL=ON -DBUILD_BULLET3=OFF -DBUILD_BULLET2_DEMOS=OFF -DBUILD_EXTRAS=OFF -DBUILD_UNIT_TESTS=OFF -DBUILD_PYBULLET=OFF -DINSTALL_LIBS=ON -DCMAKE_INSTALL_PREFIX="C:\bullet"
    ninja
    if($LastExitCode -ne 0) { throw }

    # Remove the older install (if it exists)
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path C:\bullet

    ## Install
    ninja install
    if($LastExitCode -ne 0) { throw }
    
    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path .\bullet-workdir\ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";C:\\bullet\\bin" | ? { [System.Environment]::GetEnvironmentVariable("PATH","Machine") -match $_ })) {
        # PATH
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\bullet\bin", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\bullet\\include" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") -match $_ })) {
        # CUSTOM_INCLUDE
        [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\bullet\include", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\bullet\\lib" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") -match $_ })) {
        # CUSTOM_LIB
        [Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\bullet\lib", [System.EnvironmentVariableTarget]::Machine )
    }
} catch {
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path .\bullet-workdir\ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
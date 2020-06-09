Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release"
)

$invocationDir = (Get-Item -Path ".\").FullName

try {   
    # Use a working directory, to keep our work self-contained
    mkdir fmt-workdir
    cd fmt-workdir

    # Download/Extract the source code
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    wget https://github.com/fmtlib/fmt/archive/$env:FMT_VER.zip -OutFile fmt-$env:FMT_VER.zip -UseBasicParsing
    7z x fmt-$env:FMT_VER.zip
    Remove-Item -Path fmt-$env:FMT_VER.zip -Recurse -ErrorAction SilentlyContinue
    cd fmt-$env:FMT_VER

    # Create/enter a separate build directory
    mkdir cmake-build
    cd cmake-build

    # Configure Compile
    cmake .. -GNinja -DCMAKE_BUILD_TYPE="$BuildType" -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX="C:\fmt"
    ninja
    if($LastExitCode -ne 0) { throw }

    # Remove the older install (if it exists)
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path C:\fmt

    # Install the compiled lib
    ninja install
    if($LastExitCode -ne 0) { throw }
    
    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path .\fmt-workdir\ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";C:\\fmt\\bin" | ? { [System.Environment]::GetEnvironmentVariable("PATH","Machine") -match $_ })) {
        # PATH
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\fmt\bin", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\fmt\\include" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") -match $_ })) {
        # CUSTOM_INCLUDE
        [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\fmt\include", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\fmt\\lib" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") -match $_ })) {
        # CUSTOM_LIB

        [Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\fmt\lib", [System.EnvironmentVariableTarget]::Machine )
    }
} catch {
    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path .\fmt-workdir\ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release"
)

$invocationDir = (Get-Item -Path ".\").FullName

try {   
    # Use a working directory, to keep our work self-contained
    mkdir glfw-workdir
    cd glfw-workdir

    # Download/Extract the source code
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    wget https://github.com/glfw/glfw/releases/download/$env:GLFW_VER/glfw-$env:GLFW_VER.zip -OutFile glfw-$env:GLFW_VER.zip -UseBasicParsing
    7z x glfw-$env:GLFW_VER.zip
    Remove-Item -Path glfw-$env:GLFW_VER.zip -Recurse -ErrorAction SilentlyContinue
    cd glfw-$env:GLFW_VER

    # Create/enter a separate build directory
    mkdir cmake-build
    cd cmake-build

    # Configure Compile
    cmake .. -GNinja -DCMAKE_BUILD_TYPE="$BuildType" -DCMAKE_INSTALL_PREFIX="C:\glfw"
    ninja
    if($LastExitCode -ne 0) { throw }

    # Remove the older install (if it exists)
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path C:\glfw

    # Install the compiled lib
    ninja install
    if($LastExitCode -ne 0) { throw }
    
    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path .\glfw-workdir\ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";C:\\glfw\\bin" | ? { [System.Environment]::GetEnvironmentVariable("PATH","Machine") -match $_ })) {
        # PATH
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\glfw\bin", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\glfw\\include" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") -match $_ })) {
        # CUSTOM_INCLUDE
        [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\glfw\include", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\glfw\\lib" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") -match $_ })) {
        # CUSTOM_LIB

        [Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\glfw\lib", [System.EnvironmentVariableTarget]::Machine )
    }
} catch {
    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path .\glfw-workdir\ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
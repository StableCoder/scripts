Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release"
)

$invocationDir = (Get-Item -Path ".\").FullName

try {   
    # Use a working directory, to keep our work self-contained
    Write-Host "Creating working directory"
    mkdir glfw-workdir
    cd glfw-workdir

    # Download/Extract the source code
    Write-Host "Downloading/extracting source"
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    wget https://github.com/glfw/glfw/releases/download/$env:GLFW_VER/glfw-$env:GLFW_VER.zip -OutFile glfw-$env:GLFW_VER.zip -UseBasicParsing
    7z x glfw-$env:GLFW_VER.zip
    Remove-Item -Path glfw-$env:GLFW_VER.zip -Recurse -ErrorAction SilentlyContinue
    cd glfw-$env:GLFW_VER

    # Configure and Compile
    Write-Host "Configuring and compiling"
    cmake -B build -G Ninja -D CMAKE_BUILD_TYPE="$BuildType" -D BUILD_SHARED_LIBS=ON -D CMAKE_INSTALL_PREFIX="C:\glfw" -D GLFW_BUILD_EXAMPLES=OFF -D GLFW_BUILD_TESTS=OFF -D GLFW_BUILD_DOCS=OFF
    cmake --build build
    if($LastExitCode -ne 0) { throw }

    # Remove the older install (if it exists)
    Write-Host "Removing old install (if it exists)"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path C:\glfw

    # Install
    Write-Host "Installing"
    cmake --install build
    if($LastExitCode -ne 0) { throw }
    
    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path .\glfw-workdir\ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";C:\\glfw\\bin" | ? { [System.Environment]::GetEnvironmentVariable("PATH","Machine") -match $_ })) {
        # PATH
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\glfw\bin", [System.EnvironmentVariableTarget]::Machine )
    }
} catch {
    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path .\glfw-workdir\ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
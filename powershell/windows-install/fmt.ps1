Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release"
)

$invocationDir = (Get-Item -Path ".\").FullName

try {   
    # Use a working directory, to keep our work self-contained
    Write-Host "Creating working directory"
    mkdir fmt-workdir
    cd fmt-workdir

    # Download/Extract the source code
    Write-Host "Downloading/extracting source"
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    wget https://github.com/fmtlib/fmt/archive/$env:FMT_VER.zip -OutFile fmt-$env:FMT_VER.zip -UseBasicParsing
    7z x fmt-$env:FMT_VER.zip
    Remove-Item -Path fmt-$env:FMT_VER.zip -Recurse -ErrorAction SilentlyContinue
    cd fmt-$env:FMT_VER

    # Build library
    Write-Host "Building library"
    cmake -B build -G Ninja -D CMAKE_BUILD_TYPE="$BuildType" -D CMAKE_INSTALL_PREFIX="C:\fmt" -D FMT_DOC=OFF -D FMT_TEST=OFF
    cmake --build build
    if($LastExitCode -ne 0) { throw }

    # Remove the older install (if it exists)
    Write-Host "Removing old library"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path C:\fmt

    # Install the compiled lib
    Write-Host "Installing library"
    cmake --install build
    if($LastExitCode -ne 0) { throw }
    
    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path .\fmt-workdir\ -Recurse -ErrorAction SilentlyContinue
} catch {
    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path .\fmt-workdir\ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
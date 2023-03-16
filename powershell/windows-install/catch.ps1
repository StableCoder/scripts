Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release"
)

$invocationDir = (Get-Item -Path ".\").FullName

try {
    # Use a working directory, to keep our work self-contained
    Write-Host "Creating working directory"
    mkdir catch2-workdir
    cd catch2-workdir

    # Download the single header directly to the destination
    Write-Host "Downloading/extracting source"
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    wget https://github.com/catchorg/Catch2/archive/refs/tags/v${env:CATCH_VER}.tar.gz -OutFile catch2.tar.gz -UseBasicParsing
    7z x -aoa catch2.tar.gz
    7z x -aoa catch2.tar
    cd Catch2-${env:CATCH_VER}

    # Build library
    Write-Host "Building library"
    cmake -B build -G Ninja -DCMAKE_BUILD_TYPE="$BuildType" -DCMAKE_INSTALL_PREFIX="C:\catch2" -DCMAKE_INSTALL_LIBDIR=lib -DCATCH_BUILD_EXAMPLES=OFF -DCATCH_ENABLE_COVERAGE=OFF -DCATCH_ENABLE_WERROR=OFF -DBUILD_TESTING=ON
    cmake --build build
    if($LastExitCode -ne 0) { throw }

    # Remove the older install (if it exists)
    Write-Host "Removing old library"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path C:\catch2

    # Install the compiled lib
    Write-Host "Installing library"
    cmake --install build
    if($LastExitCode -ne 0) { throw }

    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path .\catch2-workdir\ -Recurse -ErrorAction SilentlyContinue
}
catch
{
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path .\catch2-workdir\ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
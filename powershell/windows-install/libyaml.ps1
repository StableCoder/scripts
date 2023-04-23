Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release"
)

$invocationDir = (Get-Item -Path ".\").FullName

try {
    # Use a working directory, to keep our work self-contained
    Write-Host "Creating working directory"
    mkdir libyaml-workdir
    cd libyaml-workdir

     # Download/Extract the source code
     Write-Host "Downloading/extracting source"
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    wget https://github.com/yaml/libyaml/archive/${env:LIBYAML_VER}.tar.gz -OutFile libyaml.tar.gz -UseBasicParsing
    7z x -aoa libyaml.tar.gz
    Remove-Item -Path libyaml.tar.gz
    7z x -aoa libyaml.tar
    Remove-Item -Path libyaml.tar
    cd libyaml-${env:LIBYAML_VER}

    # Configure/compile
    Write-Host "Configuring and compiling"
    cmake -B build -GNinja -DCMAKE_BUILD_TYPE="$BuildType" -DCMAKE_INSTALL_PREFIX="C:\libyaml" -DBUILD_SHARED_LIBS=ON -DBUILD_TESTING=OFF
    cmake --build build
    if($LastExitCode -ne 0) { throw }

    # Remove the older install (if it exists)
    Write-Host "Removing old install (if it exists)"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path C:\libyaml

    # Install
    Write-Host "Installing"
    cmake --install build
    if($LastExitCode -ne 0) { throw }
    
    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path .\libyaml-workdir\ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";C:\\libyaml\\bin" | ? { [System.Environment]::GetEnvironmentVariable("PATH","Machine") -match $_ })) {
        # PATH
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\libyaml\bin", [System.EnvironmentVariableTarget]::Machine )
    }
} catch {
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path .\libyaml-workdir\ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
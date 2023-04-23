Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release"
)

$invocationDir = (Get-Item -Path ".\").FullName

try {
    # Use a working directory, to keep our work self-contained
    Write-Host "Creating working directory"
    mkdir portaudio-workdir
    cd portaudio-workdir

    # Download/Extract the source code
    Write-Host "Downloading/extracting source"
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    wget http://files.portaudio.com/archives/pa_stable_v$env:PORTAUDIO_VER.tgz -OutFile pa_stable_v$env:PORTAUDIO_VER.tgz -UseBasicParsing
    7z x pa_stable_v$env:PORTAUDIO_VER.tgz
    7z x pa_stable_v$env:PORTAUDIO_VER.tar
    Rename-Item -Path portaudio -NewName portaudio-src
    cd portaudio-src

    # Configure/compile
    Write-Host "Configuring and compiling"
    cmake -B build -G Ninja -D CMAKE_BUILD_TYPE="$BuildType" -D CMAKE_INSTALL_PREFIX="C:\portaudio"
    cmake --build build
    if($LastExitCode -ne 0) { throw }

    # Remove the older install (if it exists)
    Write-Host "Removing old install (if it exists)"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path C:\portaudio

    # Install
    Write-Host "Installing"
    cmake --install build
    if($LastExitCode -ne 0) { throw }

    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path .\portaudio-workdir\ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";C:\\portaudio\\bin" | ? { [System.Environment]::GetEnvironmentVariable("PATH","Machine") -match $_ })) {
        # PATH
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\portaudio\bin", [System.EnvironmentVariableTarget]::Machine )
    }
}
catch
{
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path .\portaudio-workdir\ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
$invocationDir = (Get-Item -Path ".\").FullName

try {
    # Use a working directory, to keep our work self-contained
    mkdir portaudio-workdir
    cd portaudio-workdir

    # Download/Extract the source code
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    wget http://www.portaudio.com/archives/pa_stable_v$env:PORTAUDIO_VER.tgz -OutFile pa_stable_v$env:PORTAUDIO_VER.tgz -UseBasicParsing
    7z x pa_stable_v$env:PORTAUDIO_VER.tgz
    7z x pa_stable_v$env:PORTAUDIO_VER.tar
    Rename-Item -Path portaudio -NewName portaudio-src
    cd portaudio-src

    # Create/enter a separate build directory
    mkdir cmake-build
    cd cmake-build

    # Configure/compile
    cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="C:\portaudio"
    ninja

    # Remove the older install (if it exists)
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path C:\portaudio

    # Install bin/lib
    mkdir C:\portaudio\bin
    mkdir C:\portaudio\lib
    mkdir C:\portaudio\include
    Copy-Item -Path portaudio_x64.dll -Destination C:\portaudio\bin
    Copy-Item -Path portaudio_x64.lib -Destination C:\portaudio\lib
    cd ..
    Copy-Item include\* -Destination C:\portaudio\include -Recurse

    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path .\portaudio-workdir\ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";C:\\portaudio\\bin" | ? { [System.Environment]::GetEnvironmentVariable("PATH","Machine") -match $_ })) {
        # PATH
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\portaudio\bin", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\portaudio\\include" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") -match $_ })) {
        # CUSTOM_INCLUDE
        [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\portaudio\include", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\portaudio\\lib" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") -match $_ })) {
        # CUSTOM_LIB
        [Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\portaudio\lib", [System.EnvironmentVariableTarget]::Machine )
    }
}
catch
{
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path .\portaudio-workdir\ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
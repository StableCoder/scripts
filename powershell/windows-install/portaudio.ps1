try {
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
wget http://www.portaudio.com/archives/pa_stable_v$env:PORTAUDIO_VER.tgz -OutFile pa_stable_v$env:PORTAUDIO_VER.tgz -UseBasicParsing
7z x pa_stable_v$env:PORTAUDIO_VER.tgz
7z x pa_stable_v$env:PORTAUDIO_VER.tar
Remove-Item -Path .\pa_stable_v$env:PORTAUDIO_VER.tgz
Remove-Item -Path .\pa_stable_v$env:PORTAUDIO_VER.tar
Rename-Item -Path portaudio -NewName portaudio-src
cd portaudio-src
mkdir cbuild
cd cbuild
cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=C:/portaudio
ninja
# Install bin/lib
mkdir C:\portaudio\bin
mkdir C:\portaudio\lib
mkdir C:\portaudio\include
Copy-Item -Path portaudio_x64.dll -Destination C:\portaudio\bin
Copy-Item -Path portaudio_x64.lib -Destination C:\portaudio\lib
cd ..
Copy-Item include\* -Destination C:\portaudio\include -Recurse
cd ..
Remove-Item -Path portaudio-src -Recurse -ErrorAction SilentlyContinue

[Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\portaudio\bin", [System.EnvironmentVariableTarget]::Machine )
[Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\portaudio\include", [System.EnvironmentVariableTarget]::Machine )
[Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\portaudio\lib", [System.EnvironmentVariableTarget]::Machine )
}
catch
{
    exit 1
}
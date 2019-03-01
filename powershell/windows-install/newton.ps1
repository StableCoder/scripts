try {
    mkdir newton; cd newton
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    wget https://github.com/MADEAPPS/newton-dynamics/archive/newton-${env:NEWTON_VER}.tar.gz -OutFile newton.tar.gz -UseBasicParsing
    7z x newton.tar.gz
    Remove-Item -path newton.tar.gz
    7z x newton.tar
    Remove-Item -path newton.tar
    cd newton-dynamics-newton-${env:newton_VER}
    mkdir build; cd build
    cmake .. -G "Visual Studio 15 2017 Win64"  -DNEWTON_BUILD_SANDBOX_DEMOS=OFF
    cmake --build . --config Release --target install
    mkdir C:\newton
    Copy-Item build\* -Destination C:\newton\ -Recurse
    cd ../../..
    Remove-Item -path newton -Recurse -ErrorAction SilentlyContinue

    [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\newton\bin", [System.EnvironmentVariableTarget]::Machine )
    [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\newton\include", [System.EnvironmentVariableTarget]::Machine )
    [Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\newton\lib", [System.EnvironmentVariableTarget]::Machine )
}
catch
{
    exit 1
}
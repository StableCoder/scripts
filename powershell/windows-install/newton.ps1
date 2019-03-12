try {
    mkdir newton; cd newton
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    wget https://github.com/MADEAPPS/newton-dynamics/archive/master.zip -OutFile newton.zip -UseBasicParsing
    7z x newton.zip
    cd newton-dynamics-master
    mkdir build; cd build
    cmake .. -G Ninja -DNEWTON_BUILD_SANDBOX_DEMOS=OFF -DCMAKE_BUILD_TYPE=Release
    ninja
    ninja install
    mkdir C:\newton
    Copy-Item build\* -Destination C:\newton\ -Recurse
    cd ../../..
    Remove-Item -path newton -Recurse -ErrorAction SilentlyContinue

    [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\newton\bin", [System.EnvironmentVariableTarget]::Machine )
    [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\newton\include", [System.EnvironmentVariableTarget]::Machine )
    [Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\newton\lib", [System.EnvironmentVariableTarget]::Machine )
} catch {
    exit 1
}
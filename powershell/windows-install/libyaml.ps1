try {
    mkdir libyaml
    cd libyaml
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    wget https://github.com/yaml/libyaml/archive/${env:LIBYAML_VER}.tar.gz -OutFile libyaml.tar.gz -UseBasicParsing
    7z x -aoa libyaml.tar.gz
    Remove-Item -path libyaml.tar.gz
    7z x -aoa libyaml.tar
    Remove-Item -path libyaml.tar
    cd libyaml-${env:LIBYAML_VER}
    mkdir build; cd build
    cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="C:\libyaml" -DBUILD_SHARED_LIBS=ON -DBUILD_TESTING=OFF
    ninja
    ninja install
    cd ../../..
    Remove-Item -path .\libyaml\ -Recurse -ErrorAction SilentlyContinue

    [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\libyaml\bin", [System.EnvironmentVariableTarget]::Machine )
    [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\libyaml\include", [System.EnvironmentVariableTarget]::Machine )
    [Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\libyaml\lib", [System.EnvironmentVariableTarget]::Machine )
} catch {
    exit 1
}
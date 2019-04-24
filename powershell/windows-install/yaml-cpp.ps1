try {
    mkdir yaml-cpp-build
    cd yaml-cpp-build
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    wget https://github.com/jbeder/yaml-cpp/archive/master.zip -OutFile yaml-cpp.tar.gz -UseBasicParsing
    7z x -aoa yaml-cpp.tar.gz
    Remove-Item -path yaml-cpp.tar.gz
    7z x -aoa yaml-cpp.tar
    Remove-Item -path yaml-cpp.tar
    cd yaml-cpp-master
    mkdir build
    cd build
    cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="C:\yaml-cpp" -DBUILD_SHARED_LIBS=ON -DYAML_CPP_BUILD_CONTRIB=OFF -DYAML_CPP_BUILD_TESTS=OFF -DYAML_CPP_BUILD_TOOLS=OFF
    ninja
    ninja install
    cd ../../..
    Remove-Item -path .\yaml-cpp-build\ -Recurse -ErrorAction SilentlyContinue

    [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\yaml-cpp\bin", [System.EnvironmentVariableTarget]::Machine )
    [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\yaml-cpp\include", [System.EnvironmentVariableTarget]::Machine )
    [Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\yaml-cpp\lib", [System.EnvironmentVariableTarget]::Machine )
} catch {
    exit 1
}
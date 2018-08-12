try {
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
wget https://github.com/g-truc/glm/releases/download/$env:GLM_VER/glm-$env:GLM_VER.zip -OutFile glm.zip -UseBasicParsing
7z x glm.zip
Remove-Item -path glm.zip -Recurse -ErrorAction SilentlyContinue
Rename-Item -Path glm -NewName glm-src
cd glm-src
mkdir build
cd build
cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=C:\glm
ninja
ninja install
cd ../..
Remove-Item -path glm-src -Recurse -ErrorAction SilentlyContinue

[Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\glm\include", [System.EnvironmentVariableTarget]::Machine )
[Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\glm\include", [System.EnvironmentVariableTarget]::Machine )
}
catch
{
    exit 1
}
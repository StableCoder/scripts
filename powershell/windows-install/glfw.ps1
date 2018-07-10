C:\entrypoint.ps1
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
wget https://github.com/glfw/glfw/releases/download/$env:GLFW_VER/glfw-$env:GLFW_VER.zip -OutFile glfw-$env:GLFW_VER.zip -UseBasicParsing
7z x glfw-$env:GLFW_VER.zip
Remove-Item -path glfw-$env:GLFW_VER.zip -Recurse -ErrorAction SilentlyContinue
cd glfw-$env:GLFW_VER
mkdir build
cd build
cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=C:\glfw
ninja
ninja install
cd ../..
Remove-Item -path glfw-$env:GLFW_VER -Recurse -ErrorAction SilentlyContinue

[Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\glfw\bin", [System.EnvironmentVariableTarget]::Machine )
[Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\glfw\include", [System.EnvironmentVariableTarget]::Machine )
[Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\glfw\lib", [System.EnvironmentVariableTarget]::Machine )
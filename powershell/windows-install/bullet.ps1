try {
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
wget https://github.com/bulletphysics/bullet3/archive/${env:BULLET_VER}.tar.gz -OutFile bullet.tar.gz -UseBasicParsing
7z x bullet.tar.gz
Remove-Item -path bullet.tar.gz
7z x bullet.tar
Remove-Item -path bullet.tar
cd bullet3-${env:BULLET_VER}
mkdir build; cd build
cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release -DBUILD_BULLET2_DEMOS=OFF -DBUILD_CPU_DEMOS=OFF -DBUILD_BULLET3=OFF -DBUILD_CLSOCKET=OFF -DBUILD_CPU_DEMOS=OFF -DBUILD_ENET=OFF -DBUILD_OPENGL3_DEMOS=OFF -DBUILD_PYBULLET=OFF -DBUILD_PYBULLET_CLSOCKET=OFF -DBUILD_PYBULLET_ENET=OFF -DBUILD_UNIT_TESTS=OFF
ninja
mkdir C:\bullet\bin
mkdir C:\bullet\include
mkdir C:\bullet\lib
Copy-Item lib\* -Destination C:\bullet\lib
cd ..
Copy-Item src\* -Destination C:\bullet\include -Recurse
cd ..
Remove-Item -path bullet3-${env:BULLET_VER} -Recurse -ErrorAction SilentlyContinue

[Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\bullet\bin", [System.EnvironmentVariableTarget]::Machine )
[Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\bullet\include", [System.EnvironmentVariableTarget]::Machine )
[Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\bullet\lib", [System.EnvironmentVariableTarget]::Machine )
}
catch
{
    exit 1
}
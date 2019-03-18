try {
    mkdir bullet; cd bullet
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    wget https://github.com/bulletphysics/bullet3/archive/${env:BULLET_VER}.tar.gz -OutFile bullet.tar.gz -UseBasicParsing
    7z x bullet.tar.gz
    Remove-Item -path bullet.tar.gz
    7z x bullet.tar
    Remove-Item -path bullet.tar
    cd bullet3-${env:BULLET_VER}
    mkdir build; cd build
    cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DUSE_MSVC_RUNTIME_LIBRARY_DLL=ON -DBUILD_BULLET3=OFF -DBUILD_BULLET2_DEMOS=OFF -DBUILD_EXTRAS=OFF -DBUILD_UNIT_TESTS=OFF -DBUILD_PYBULLET=OFF -DINSTALL_LIBS=ON -DCMAKE_INSTALL_PREFIX=C:\bullet
    ninja
    ninja install
    cd ../../..
    Remove-Item -path bullet -Recurse -ErrorAction SilentlyContinue

    [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\bullet\bin", [System.EnvironmentVariableTarget]::Machine )
    [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\bullet\include", [System.EnvironmentVariableTarget]::Machine )
    [Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\bullet\lib", [System.EnvironmentVariableTarget]::Machine )
}
catch
{
    exit 1
}
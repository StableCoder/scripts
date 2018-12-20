try{
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
wget https://github.com/assimp/assimp/archive/v${env:ASSIMP_VER}.tar.gz -OutFile assimp.tar.gz -UseBasicParsing
7z x -aoa assimp.tar.gz
Remove-Item -path assimp.tar.gz
7z x -aoa assimp.tar
Remove-Item -path assimp.tar
cd assimp-${env:ASSIMP_VER} 
mkdir build; cd build
cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release -DASSIMP_BUILD_ASSIMP_TOOLS=OFF -DASSIMP_BUILD_TESTS=OFF
ninja
mkdir C:\assimp\bin
mkdir C:\assimp\include
mkdir C:\assimp\lib
Copy-Item code\*.dll -Destination C:\assimp\bin
Copy-Item code\*.lib -Destination C:\assimp\lib
Copy-Item include\* -Destination C:\assimp\include -Recurse
cd ..
Copy-Item include\* -Destination C:\assimp\include -Recurse
cd ..
Remove-Item -path assimp-${env:ASSIMP_VER} -Recurse -ErrorAction SilentlyContinue

[Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\assimp\bin", [System.EnvironmentVariableTarget]::Machine )
[Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\assimp\include", [System.EnvironmentVariableTarget]::Machine )
[Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\assimp\lib", [System.EnvironmentVariableTarget]::Machine )
}
catch
{
    exit 1
}
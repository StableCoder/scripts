try {
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
mkdir C:\usr\include
wget https://github.com/catchorg/Catch2/releases/download/v${env:CATCH_VER}/catch.hpp -OutFile C:\usr\include\catch.hpp
[Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\usr\include", [System.EnvironmentVariableTarget]::Machine )
}
catch
{
    exit 1
}
try {
    # Download the single header directly to the destination
    Write-Host "Downloading/extracting source"
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    mkdir C:\catch2\include
    wget https://github.com/catchorg/Catch2/releases/download/v${env:CATCH_VER}/catch.hpp -OutFile C:\catch2\include\catch.hpp
    
    if($null -eq ( ";C:\\catch2\\include" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") -match $_ })) {
        # CUSTOM_INCLUDE
        [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\catch2\include", [System.EnvironmentVariableTarget]::Machine )
    }
}
catch
{
    exit 1
}
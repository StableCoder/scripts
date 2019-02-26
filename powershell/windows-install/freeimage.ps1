try {
    Invoke-WebRequest -Uri "https://sourceforge.net/projects/freeimage/files/Binary Distribution/3.18.0/FreeImage3180Win32Win64.zip/download" -OutFile FreeImage.zip -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
    7z x FreeImage.zip

    mkdir C:\freeimage\bin
    mkdir C:\freeimage\include
    mkdir C:\freeimage\lib

    Copy-Item FreeImage\Dist\x64\*.dll -Destination C:\freeimage\bin
    Copy-Item FreeImage\Dist\x64\*.lib -Destination C:\freeimage\lib
    Copy-Item FreeImage\Dist\x64\*.h -Destination C:\freeimage\include -Recurse

    Remove-Item -path FreeImage* -Recurse -ErrorAction SilentlyContinue

    [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\freeimage\bin", [System.EnvironmentVariableTarget]::Machine )
    [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\freeimage\include", [System.EnvironmentVariableTarget]::Machine )
    [Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\freeimage\lib", [System.EnvironmentVariableTarget]::Machine )
}
catch
{
    exit 1
}
Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release"
)

$invocationDir = (Get-Item -Path ".\").FullName

try{
    # Use a working directory, to keep our work self-contained
    Write-Host "Creating working directory"
    mkdir assimp-workdir
    cd assimp-workdir

    # Download/Extract the source code
    Write-Host "Downloading/extracting source"
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    wget https://github.com/assimp/assimp/archive/v${env:ASSIMP_VER}.tar.gz -OutFile assimp.tar.gz -UseBasicParsing
    7z x -aoa assimp.tar.gz
    7z x -aoa assimp.tar
    cd assimp-${env:ASSIMP_VER} 

    # Create/enter a separate build directory
    Write-Host "Creating build directory"
    mkdir cmake-build
    cd cmake-build

    # Configure/compile
    cmake .. -GNinja -DCMAKE_BUILD_TYPE="$BuildType" -DASSIMP_BUILD_ASSIMP_TOOLS=OFF -DASSIMP_BUILD_TESTS=OFF -DLIBRARY_SUFFIX="" -DBUILD_TESTING=OFF
    ninja
    if($LastExitCode -ne 0) { throw }

    # Remove the older install (if it exists)
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path C:\assimp

    # Install
    mkdir C:\assimp\bin
    mkdir C:\assimp\include
    mkdir C:\assimp\lib
    Copy-Item bin\*.dll -Destination C:\assimp\bin
    Copy-Item lib\*.lib -Destination C:\assimp\lib
    Copy-Item include\* -Destination C:\assimp\include -Recurse
    cd ..
    Copy-Item include\* -Destination C:\assimp\include -Recurse

    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path .\assimp-workdir\ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";C:\\assimp\\bin" | ? { [System.Environment]::GetEnvironmentVariable("PATH","Machine") -match $_ })) {
        # PATH
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\assimp\bin", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\assimp\\include" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") -match $_ })) {
        # CUSTOM_INCLUDE
        [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\assimp\include", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\assimp\\lib" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") -match $_ })) {
        # CUSTOM_LIB
        [Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\assimp\lib", [System.EnvironmentVariableTarget]::Machine )
    }
} catch {
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path .\assimp-workdir\ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
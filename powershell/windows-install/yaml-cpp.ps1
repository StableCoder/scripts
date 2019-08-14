$invocationDir = (Get-Item -Path ".\").FullName

try {
    # Use a working directory, to keep our work self-contained
    mkdir build-workdir
    cd build-workdir

    # Download/Extract the source code
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    wget https://github.com/jbeder/yaml-cpp/archive/master.zip -OutFile yaml-cpp.zip -UseBasicParsing
    7z x -aoa yaml-cpp.zip
    cd yaml-cpp-master

    # Create/enter a separate build directory
    mkdir build
    cd build

    # Configure/compile
    cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="C:\yaml-cpp" -DBUILD_SHARED_LIBS=ON -DYAML_CPP_BUILD_CONTRIB=OFF -DYAML_CPP_BUILD_TESTS=OFF -DYAML_CPP_BUILD_TOOLS=OFF
    ninja

    # Remove the older install (if it exists)
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path C:\yaml-cpp
    
    ## Install the newly compiled library
    ninja install

    # Delete our working directory
    cd $invocationDir
    Remove-Item -path .\build-workdir\ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";C:\\yaml-cpp\\bin" | ? { [System.Environment]::GetEnvironmentVariable("PATH","Machine") -match $_ })) {
        # PATH
        Write-Host "Setting up PATH variable"
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\yaml-cpp\bin", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\yaml-cpp\\include" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") -match $_ })) {
        # CUSTOM_INCLUDE
        Write-Host "Setting up CUSTOM_INCLUDE variable"
        [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\yaml-cpp\include", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\yaml-cpp\\lib" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") -match $_ })) {
        # CUSTOM_LIB
        Write-Host "Setting up CUSTOM_LIB variable"
        [Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\yaml-cpp\lib", [System.EnvironmentVariableTarget]::Machine )
    }
} catch {
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -path .\build-workdir\ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
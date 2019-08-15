Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release"
)

$invocationDir = (Get-Item -Path ".\").FullName

try {
    # Use a working directory, to keep our work self-contained
    mkdir libyaml-workdir
    cd libyaml-workdir

     # Download/Extract the source code
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    wget https://github.com/yaml/libyaml/archive/${env:LIBYAML_VER}.tar.gz -OutFile libyaml.tar.gz -UseBasicParsing
    7z x -aoa libyaml.tar.gz
    Remove-Item -Path libyaml.tar.gz
    7z x -aoa libyaml.tar
    Remove-Item -Path libyaml.tar
    cd libyaml-${env:LIBYAML_VER}
   
    # Create/enter a separate build directory
    mkdir cmake-build
    cd cmake-build

    # Configure/compile
    cmake .. -GNinja -DCMAKE_BUILD_TYPE="$BuildType" -DCMAKE_INSTALL_PREFIX="C:\libyaml" -DBUILD_SHARED_LIBS=ON -DBUILD_TESTING=OFF
    ninja

    # Remove the older install (if it exists)
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path C:\newton

    # Install bin/lib
    ninja install
    
    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path .\libyaml-workdir\ -Recurse -ErrorAction SilentlyContinue

    # Setup the environment variables (Only if not found in the var already)
    if($null -eq ( ";C:\\libyaml\\bin" | ? { [System.Environment]::GetEnvironmentVariable("PATH","Machine") -match $_ })) {
        # PATH
        [Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\libyaml\bin", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\libyaml\\include" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") -match $_ })) {
        # CUSTOM_INCLUDE
        [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\libyaml\include", [System.EnvironmentVariableTarget]::Machine )
    }
    if($null -eq ( ";C:\\libyaml\\lib" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") -match $_ })) {
        # CUSTOM_LIB
        [Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:\libyaml\lib", [System.EnvironmentVariableTarget]::Machine )
    }
} catch {
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path .\libyaml-workdir\ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
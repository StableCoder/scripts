Param(
    [string]$InstallDir
)

# Download and install
wget http://releases.llvm.org/${env:LLVM_VER}/LLVM-${env:LLVM_VER}-win64.exe -OutFile llvm.exe -UseBasicParsing
.\llvm.exe /S /D="$InstallDir"
rm .\llvm.exe

# Setup environment
[Environment]::SetEnvironmentVariable( "LLVM_DIR", "$InstallDir", [System.EnvironmentVariableTarget]::Machine )
Copy-Item -Path entrypoint.ps1 -Destination C:\entrypoint.ps1
# Download and install
wget http://releases.llvm.org/${env:LLVM_VER}/LLVM-${env:LLVM_VER}-win64.exe -OutFile llvm.exe -UseBasicParsing
.\llvm.exe /S | Out-Null

# Setup environment
[Environment]::SetEnvironmentVariable( "LLVM_DIR", "C:\Program Files\LLVM", [System.EnvironmentVariableTarget]::Machine )
Copy-Item -Path entrypoint.ps1 -Destination C:\entrypoint.ps1

Remove-Item llvm.exe
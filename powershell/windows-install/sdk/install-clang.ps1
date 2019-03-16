# Download and install
choco install -y llvm

# Setup environment
Copy-Item -Path entrypoint.ps1 -Destination C:\entrypoint.ps1

Remove-Item llvm.exe
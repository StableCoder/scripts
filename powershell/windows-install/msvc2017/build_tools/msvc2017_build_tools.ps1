wget https://aka.ms/vs/15/release/vs_buildtools.exe -OutFile vs_buildtools.exe -UseBasicParsing
.\vs_buildtools.exe --quiet --wait --norestart --nocache --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.Windows10SDK.17134 | Out-Null
rm .\vs_buildtools.exe

Copy-Item -Path entrypoint.ps1 -Destination C:\entrypoint.ps1
Copy-Item -Path entrypoint.bat -Destination C:\entrypoint.bat
Write-Host "MSVC setup complete."
wget https://aka.ms/vs/15/release/vs_professional.exe -OutFile vs_professional.exe -UseBasicParsing
.\vs_professional.exe --quiet --wait --norestart --nocache --add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Component.VC.DiagnosticTools --add Microsoft.VisualStudio.Component.Static.Analysis.Tools --add Microsoft.VisualStudio.Component.Debugger.JustInTime --add Microsoft.VisualStudio.Component.NuGet --add Microsoft.VisualStudio.Component.VC.CMake.Project --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.17134 | Out-Null
rm .\vs_professional.exe

Copy-Item -Path entrypoint.ps1 -Destination C:\entrypoint.ps1
Copy-Item -Path entrypoint.bat -Destination C:\entrypoint.bat
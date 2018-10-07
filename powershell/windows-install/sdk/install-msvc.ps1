Param(
    [string]$VS_Package
)

# Download and install
wget https://aka.ms/vs/15/release/vs_$VS_Package.exe -OutFile $VS_Package.exe -UseBasicParsing
if($Target.equals("buildtools")) {
    .\vs_$VS_Package.exe --quiet --wait --norestart --nocache --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.Windows10SDK.17134 | Out-Null
} else {
    .\vs_$VS_Package.exe --quiet --wait --norestart --nocache --add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Component.VC.DiagnosticTools --add Microsoft.VisualStudio.Component.Static.Analysis.Tools --add Microsoft.VisualStudio.Component.Debugger.JustInTime --add Microsoft.VisualStudio.Component.NuGet --add Microsoft.VisualStudio.Component.VC.CMake.Project --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.17134 | Out-Null
}
rm .\vs_$VS_Package.exe

# Environment setup
[Environment]::SetEnvironmentVariable( "VS_PACKAGE", "$VS_Package", [System.EnvironmentVariableTarget]::Machine )
Copy-Item -Path entrypoint.ps1 -Destination C:\entrypoint.ps1
Write-Host "MSVC setup complete."
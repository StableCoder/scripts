Param(
    [string]$VS_Package = "BuildTools"
)

try {
    # Download and install
    wget https://aka.ms/vs/16/release/vs_$VS_Package.exe -OutFile .\vs_installer.exe -UseBasicParsing
    if($VS_Package.equals("BuildTools")) {
        Write-Host "MSVC for buildtools"
        .\vs_installer.exe --quiet --wait --norestart --nocache --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.Windows10SDK.$env:WIN10_SDK_VER --add Microsoft.VisualStudio.Component.VC.CoreBuildTools --add Microsoft.VisualStudio.Component.VC.Redist.14.Latest --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 | Out-Null
    } else {
        Write-Host "MSVC for $VS_Package"
        .\vs_installer.exe --quiet --wait --norestart --nocache --add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Component.VC.DiagnosticTools --add Microsoft.VisualStudio.Component.Static.Analysis.Tools --add Microsoft.VisualStudio.Component.Debugger.JustInTime --add Microsoft.VisualStudio.Component.NuGet --add Microsoft.VisualStudio.Component.VC.CMake.Project --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.$env:WIN10_SDK_VER | Out-Null
    }
    rm .\vs_installer.exe

    # Environment setup
    [Environment]::SetEnvironmentVariable( "VS_PACKAGE", "$VS_Package", [System.EnvironmentVariableTarget]::Machine )
    Copy-Item -Path entrypoint.ps1 -Destination C:\entrypoint.ps1
    
    Write-Host "MSVC setup complete."
} catch {
    Write-Host "MSVC setup failed."
    exit 1
}
# Copyright (C) 2023-2024 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
Param(
    [string]$VS_Package = "BuildTools",
    [string]$SDK_Version = "Windows10SDK.19041"
)

Write-Host "Visual Studio 2022 ($VS_Package)"

try {
    # Download and install
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri https://aka.ms/vs/17/release/vs_$VS_Package.exe -OutFile ./vs_installer.exe -UseBasicParsing
    if($VS_Package.equals("BuildTools")) {
        ./vs_installer.exe --quiet --wait --norestart --nocache `
            --add Microsoft.VisualStudio.Workload.VCTools `
            --add Microsoft.VisualStudio.Component.VC.CoreBuildTools `
            --add Microsoft.VisualStudio.Component.VC.Redist.14.Latest `
            --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
            --add Microsoft.VisualStudio.Component.VC.ASAN `
            --add Microsoft.VisualStudio.Component.$SDK_Version | Out-Null
    } else {
        ./vs_installer.exe --quiet --wait --norestart --nocache `
            --add Microsoft.VisualStudio.Workload.NativeDesktop `
            --add Microsoft.VisualStudio.Component.VC.DiagnosticTools `
            --add Microsoft.VisualStudio.Component.Static.Analysis.Tools `
            --add Microsoft.VisualStudio.Component.Debugger.JustInTime `
            --add Microsoft.VisualStudio.Component.NuGet `
            --add Microsoft.VisualStudio.Component.VC.CMake.Project `
            --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
            --add Microsoft.VisualStudio.Component.VC.ASAN `
            --add Microsoft.VisualStudio.Component.$SDK_Version | Out-Null
    }
    rm ./vs_installer.exe

    # Environment setup
    Copy-Item -Path entrypoint.ps1 -Destination ~/entrypoint.ps1
    
    Write-Host "Visual Studio 2022 ($VS_Package) setup complete."
} catch {
    Write-Host "Visual Studio 2022 ($VS_Package) setup failed."
    exit 1
}
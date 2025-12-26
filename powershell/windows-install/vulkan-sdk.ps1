# Copyright (C) 2018-2025 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
Param(
    [string]$Version = "",
    [string]$Arch = "X64",
    [string]$EnvironmentVariableScope = "User" # use 'Machine' to set it machine-wide
)

try {
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = "tls13, tls12"
    if ("${Version}" -eq "") {
        Write-Host "Installing latest Vulkan SDK"
        Invoke-WebRequest -Uri https://sdk.lunarg.com/sdk/download/latest/windows/vulkan-sdk.exe -OutFile VulkanSDK.exe -UseBasicParsing
    } else {
        Write-Host "Installing Vulkan SDK v${Version}"
        Invoke-WebRequest -Uri https://vulkan.lunarg.com/sdk/download/${Version}/windows/vulkansdk-windows-${Arch}-${Version}.exe -OutFile VulkanSDK.exe -UseBasicParsing
    }
    ./VulkanSDK.exe --root C:/VulkanSDK --accept-licenses --default-answer --confirm-command install | Out-Null
    Remove-Item VulkanSDK.exe
    Remove-Item -Path C:/VulkanSDK/Bin32 -Recurse -ErrorAction SilentlyContinue

    [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","$EnvironmentVariableScope") + ";C:/VulkanSDK/Include", [System.EnvironmentVariableTarget]::$EnvironmentVariableScope )
    [Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","$EnvironmentVariableScope") + ";C:/VulkanSDK/lib", [System.EnvironmentVariableTarget]::$EnvironmentVariableScope )
}
catch
{
    exit 1
}

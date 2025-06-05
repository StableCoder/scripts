# Copyright (C) 2020-2025 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
Param(
    [string]$Version = "",
    [string]$Arch = "X64"
)

try {
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = "tls13, tls12"
    if ("${Version}" -eq "") {
        # if no version specified, pull the latest
        Write-Host "Installing latest Vulkan Runtime"
        Invoke-WebRequest -Uri https://sdk.lunarg.com/sdk/download/latest/windows/vulkan-runtime-components.zip?Human=true -OutFile VulkanRuntime.zip -UseBasicParsing
    } else {
        Write-Host "Installing Vulkan Runtime v${Version}"
        Invoke-WebRequest -Uri https://vulkan.lunarg.com/sdk/download/${Version}/windows/VulkanRT-${Arch}-${Version}-Components.zip -OutFile VulkanRuntime.zip -UseBasicParsing
    }
    7z x VulkanRuntime.zip
    cd VulkanRT-*
    cp ./x64/* C:/VulkanSDK/Bin/

    cd ..
    Remove-Item VulkanRuntime.zip
    Remove-Item -Path VulkanRT-* -Recurse -ErrorAction SilentlyContinue
}
catch
{
    exit 1
}

# Copyright (C) 2018-2024 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
try {
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    Invoke-WebRequest -Uri https://sdk.lunarg.com/sdk/download/latest/windows/vulkan-sdk.exe?Human=true -OutFile VulkanSDK.exe -UseBasicParsing
    ./VulkanSDK.exe --root C:/VulkanSDK --accept-licenses --default-answer --confirm-command install | Out-Null
    Remove-Item VulkanSDK.exe
    Remove-Item -Path C:/VulkanSDK/Bin32 -Recurse -ErrorAction SilentlyContinue

    [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:/VulkanSDK/Include", [System.EnvironmentVariableTarget]::Machine )
    [Environment]::SetEnvironmentVariable( "CUSTOM_LIB", [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";C:/VulkanSDK/lib", [System.EnvironmentVariableTarget]::Machine )
}
catch
{
    exit 1
}

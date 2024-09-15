# Copyright (C) 2020-2024 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
try {
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    Invoke-WebRequest -Uri https://sdk.lunarg.com/sdk/download/latest/windows/vulkan-runtime-components.zip?Human=true -OutFile VulkanRuntime.zip -UseBasicParsing
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

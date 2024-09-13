# Copyright (C) 2018-2024 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
try {
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    Invoke-WebRequest -Uri https://bintray.com/jfrog/jfrog-cli-go/download_file?file_path=1.17.1%2Fjfrog-cli-windows-amd64%2Fjfrog.exe -OutFile jfrog.exe -UseBasicParsing
    mkdir "C:\Program Files\JFrog"
    Move-Item .\jfrog.exe -Destination "C:\Program Files\JFrog\jfrog.exe"
    [Environment]::SetEnvironmentVariable( "Path", [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";C:\Program Files\JFrog;", [System.EnvironmentVariableTarget]::Machine )
}
catch
{
    exit 1
}
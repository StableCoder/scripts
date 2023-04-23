Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release",
    [string]$Version = "0.9.9.8"
)

$invocationDir = (Get-Item -Path ".\").FullName

try {
    # Use a working directory, to keep our work self-contained
    Write-Host "Creating working directory"
    mkdir glm-workdir
    cd glm-workdir

    # Download/Extract the source code
    Write-Host "Downloading/extracting source"
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    wget https://github.com/g-truc/glm/releases/download/${Version}/glm-${Version}.zip -OutFile glm.zip -UseBasicParsing
    7z x glm.zip
    cd glm

    # Remove the older install (if it exists)
    Write-Host "Removing old install (if it exists)"
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path C:\glm

    # Install
    Write-Host "Installing"
    mkdir C:\glm
    mkdir C:\glm\include
    Copy-Item -Recurse .\glm C:\glm\include\
    Copy-Item -Recurse .\cmake C:\glm\

    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path .\glm-workdir\ -Recurse -ErrorAction SilentlyContinue
}
catch
{
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path .\glm-workdir\ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
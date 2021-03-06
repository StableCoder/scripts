Param(
    # By default, build release variants of libraries
    [string]$BuildType = "Release"
)

$invocationDir = (Get-Item -Path ".\").FullName

try {
    # Use a working directory, to keep our work self-contained
    mkdir glm-workdir
    cd glm-workdir

    # Download/Extract the source code
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    wget https://github.com/g-truc/glm/releases/download/$env:GLM_VER/glm-$env:GLM_VER.zip -OutFile glm.zip -UseBasicParsing
    7z x glm.zip
    cd glm

    # Remove the older install (if it exists)
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue -Path C:\glm
    mkdir C:\glm
    mkdir C:\glm\include

    # Install
    Copy-Item -Recurse .\glm\ C:\glm\include\

    # Delete our working directory
    cd $invocationDir
    Remove-Item -Path .\glm-workdir\ -Recurse -ErrorAction SilentlyContinue

    if($null -eq ( ";C:\\glm\\include" | ? { [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") -match $_ })) {
        # CUSTOM_INCLUDE
        [Environment]::SetEnvironmentVariable( "CUSTOM_INCLUDE", [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";C:\glm\include", [System.EnvironmentVariableTarget]::Machine )
    }
}
catch
{
    # Cleanup the failed build folder
    cd $invocationDir
    Remove-Item -Path .\glm-workdir\ -Recurse -ErrorAction SilentlyContinue
    exit 1
}
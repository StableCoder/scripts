Param(
    [string]$InstallDir = ".\"
)

try {
    wget https://cfhcable.dl.sourceforge.net/project/msys2/Base/x86_64/msys2-base-x86_64-$env:MSYS_VER.tar.xz -OutFile msys2.tar.gz -UseBasicParsing

    7z x msys2.tar.gz
    7z x msys2.tar
    Remove-Item -path msys2.tar.gz
    Remove-Item -path msys2.tar
    
    # Move to install location
    if(!$InstallDir.equals(".\")) {
        robocopy msys64 ${InstallDir}\msys64 /e /mov
    }

    # Update it
    Set-Alias bash "${InstallDir}msys64\usr\bin\bash.exe"
    $ErrorActionPreference = 'Continue'
    while (!$done) {
        bash -lc 'pacman --noconfirm -Syuu | tee /update.log'
        $done = (Get-Content ${InstallDir}msys64\update.log) -match 'there is nothing to do' | Measure-Object | ForEach-Object { $_.Count -eq 2 }
        $done = $done -or ($i -ge 5)
    }
    Remove-Item prefix\msys64\update.log -ea 0

    # General
    bash -lc 'pacman --noconfirm -S mingw64/mingw-w64-x86_64-make'

    # GCC
    bash -lc 'pacman --noconfirm -S mingw64/mingw-w64-x86_64-gcc mingw64/mingw-w64-x86_64-lcov'

    # Clang
    bash -lc 'pacman --noconfirm -S mingw64/mingw-w64-x86_64-clang mingw64/mingw-w64-x86_64-clang-analyzer mingw64/mingw-w64-x86_64-clang-tools-extra mingw64/mingw-w64-x86_64-llvm'

    # Clean the cache, saving a bit of space
    bash -lc 'pacman --noconfirm -Scc'

    Copy-Item -Path entrypoint.ps1 -Destination C:\entrypoint.ps1

    cd ${InstallDir}msys64

    [Environment]::SetEnvironmentVariable( "MSYS_DIR", "${pwd}", [System.EnvironmentVariableTarget]::Machine )

    Write-Host "MSYS installation successful."
}
catch
{
    Write-Host "MSYS installation failed."
    exit 1
}
# Powershell Scripts

This is a collection of useful powershell scripts, most notably for automating installation of programs for work environments or within Windows Containers. In this readme are also a few useful standalone commands.

#### Note

By default, Windows does not allow the execution of powershell scripts. To enable them one must first run:
```ps
# For just the current session:
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted

# or for all, ever:
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
```

## Installers

In the `install` folder is a set of scripts for installing a bunch of applications and libraries as well as various versions of Microsoft's Visual Studio through Powershell. This includes:
- Chocolatey (Along with git, svn, python, cmake, ninja, 7zip)
- GLFW3
- GLM
- MSYS2
- Portaudio
- VulkanSDK
- Qt4

### Updating a Visual Studio installation via CLI

After an initial installation of Visual Studio, localed on the local drive, typically at `C:\Program Files (x86)\Microsoft Visual Studio\Installer` will be the application `vs_installer.exe` which can then be used to modify an installation. To be noted, though, is that to modify an existing installation is the requirement that the installation directory must be added, such as:
```ps
<dir>\vs_installer.exe modify --installPath C:\<install-dir> --add Microsoft.VisualStudio.Component.VC.ATL --add Microsoft.VisualStudio.Component.VC.ATLMFC
```

## Useful Standalones

#### dos2unix/unix2dos

Every programmer's nightmare, line ending differences. These quick one-liners can solve that issue!

```ps
# dos2unix
$x = get-content -raw -path <FILE_NAME>; $x -replace "`r`n","`n" | set-content -path <FILE_NAME>

# unix2dos
$x = get-content -raw -path <FILE_NAME>; $x -replace "[^`r]`n","`r`n" | set-content -path <FILE_NAME>
```

#### Getting the windows release eg. 1709, 1803

```ps
(Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
```

#### Updating variables for the machine/process/user

```ps
# Machine
[Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\other\bin", [System.EnvironmentVariableTarget]::Machine )
# Process
[Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Process") + ";C:\other\bin", [System.EnvironmentVariableTarget]::Process )
# User
[Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","User") + ";C:\other\bin", [System.EnvironmentVariableTarget]::User )
```

#### Refresh the PATH in the current Powershell session

```ps
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
```

#### Turning Hyper-V On/Off

After the initial installation of Hyper-V, using these can allow turning it off and on with a restart of the computer, without (un)installing it from the features menu.

```ps
# Enable
bcdedit /set hypervisorlaunchtype auto

# Disable
bcdedit /set hypervisorlaunchtype off
```
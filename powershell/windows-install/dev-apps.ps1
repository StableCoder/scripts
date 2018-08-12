try {
# Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install popular programs
choco install -y 7zip cmake python git ninja svn

# Add new tools to machine path
[Environment]::SetEnvironmentVariable( "Path", [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";C:\Program Files\7-Zip;C:\Program Files\CMake\bin;C:\Program Files\Git\bin;C:\Python37;C:\Python37\Scripts", [System.EnvironmentVariableTarget]::Machine )
# Refresh path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Conan
pip install conan
}
catch
{
    exit 1
}
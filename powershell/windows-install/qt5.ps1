try {
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
wget http://mirror.csclub.uwaterloo.ca/qtproject/archive/online_installers/3.0/qt-unified-windows-x86-3.0.5-online.exe -OutFile qt5.exe -UseBasicParsing
.\qt5.exe --script .\qt5-noninteractive.qs
do { 
    "Waiting for Qt5 setup to end..."
    start-sleep 10 
    } while (gwmi -class win32_process | Where ProcessName -eq "qt5.exe")
Remove-Item -Path qt5.exe
[Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\Qt\5.11.1\msvc2017_64\bin", [System.EnvironmentVariableTarget]::Machine )
Write-Host "Qt5 install complete."
}
catch
{
    exit 1
}
wget http://mirror.csclub.uwaterloo.ca/qtproject/archive/online_installers/3.0/qt-unified-windows-x86-3.0.5-online.exe -OutFile qt5.exe -UseBasicParsing
.\qt5.exe --script .\qt5-noninteractive.qs
Remove-Item -Path qt5.exe

[Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\Qt\5.11.1\msvc2017_64\bin", [System.EnvironmentVariableTarget]::Machine )
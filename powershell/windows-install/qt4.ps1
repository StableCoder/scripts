try {
choco install -y activeperl

C:\entrypoint.ps1
wget https://download.qt.io/archive/qt/4.8/4.8.7/qt-everywhere-opensource-src-4.8.7.tar.gz -OutFile qt-src.tar.gz -UseBasicParsing
7z x qt-src.tar.gz
Remove-Item -path qt-src.tar.gz -Recurse -ErrorAction SilentlyContinue
7z x qt-src.tar
Remove-Item -path qt-src.tar -Recurse -ErrorAction SilentlyContinue

cd qt-everywhere-opensource-src-4.8.7
git apply --ignore-space-change --ignore-whitespace ..\qt4-2017.patch
cmd.exe /c "configure -release -make nmake -platform win32-msvc2017 -prefix c:\Qt-4.8.7 -opensource -confirm-license -opengl desktop -nomake examples -nomake tests -no-webkit"
nmake
nmake install
cd ..
Remove-Item -path qt-everywhere-opensource-src-4.8.7 -Recurse -ErrorAction SilentlyContinue

[Environment]::SetEnvironmentVariable( "PATH", [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";C:\Qt-4.8.7\bin", [System.EnvironmentVariableTarget]::Machine )
}
catch
{
    exit 1
}
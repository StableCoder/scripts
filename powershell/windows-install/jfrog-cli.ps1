try {
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
wget https://bintray.com/jfrog/jfrog-cli-go/download_file?file_path=1.17.1%2Fjfrog-cli-windows-amd64%2Fjfrog.exe -OutFile jfrog.exe -UseBasicParsing
mkdir "C:\Program Files\JFrog"
Move-Item .\jfrog.exe -Destination "C:\Program Files\JFrog\jfrog.exe"
[Environment]::SetEnvironmentVariable( "Path", [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";C:\Program Files\JFrog;", [System.EnvironmentVariableTarget]::Machine )
}
catch
{
    exit 1
}
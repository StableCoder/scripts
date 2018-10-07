Param(
    [string]$Target = "gcc"
)

$env:PATH = $env:PATH + ";" + [System.Environment]::GetEnvironmentVariable("MSYS_DIR","Machine") + "\usr\bin;" + [System.Environment]::GetEnvironmentVariable("MSYS_DIR","Machine") + "\mingw64\bin;"
$env:INCLUDE = $env:INCLUDE + ";" + [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("CUSTOM_INCLUDE","User")
$env:LIB = $env:LIB + ";" + [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("CUSTOM_LIB","User")

if($Target.equals("gcc")) {
    $env:CC="gcc"
    $env:CXX="g++"
}
if($Target.equals("clang")) {
    $env:CC="clang"
    $env:CXX="clang"
}
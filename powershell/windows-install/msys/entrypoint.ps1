Param(
    [string]$Target
)

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
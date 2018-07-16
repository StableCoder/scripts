Param(
    [string]$inFile
)

$x = get-content -raw -path $inFile; $x -replace "[^`r]`n","`r`n" | set-content -path $inFile
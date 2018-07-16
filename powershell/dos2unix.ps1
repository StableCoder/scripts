Param(
    [string]$inFile
)

$x = get-content -raw -path $inFile; $x -replace "`r`n","`n" | set-content -path $inFile
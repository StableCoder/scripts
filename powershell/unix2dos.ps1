# Copyright (C) 2018 George Cave.
#
# SPDX-License-Identifier: Apache-2.0
Param(
    [string]$inFile
)

$x = get-content -raw -path $inFile; $x -replace "[^`r]`n","`r`n" | set-content -path $inFile
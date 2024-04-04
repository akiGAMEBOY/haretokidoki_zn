---
title: "PowerShellで各種改行コードを変換する自作Function"
emoji: "😸"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: false
---
Get-Content -Path $pyscript_path ForEach-Object { $_ -Replace "`n", "`r`n" }
Set-Content -Path $pyscript_path 

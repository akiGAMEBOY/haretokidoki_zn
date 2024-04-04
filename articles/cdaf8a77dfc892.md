---
title: ""
emoji: "😸"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: []
published: false
---
Get-Content -Path $pyscript_path ForEach-Object { $_ -Replace "`n", "`r`n" }
Set-Content -Path $pyscript_path 

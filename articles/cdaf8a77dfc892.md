---
title: "PowerShellで各種改行コードを変換する自作Function"
emoji: "😸"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: false
---

変換可能な一覧と、"CRLF"や"LF"など作業者が認識しやすい文字列の引数により変換が可能とする。

```powershell:
Function RelaceReturncode {
    Param (
        [Parameter(Mandatory=$true)][ValidateSet("`r", "`r`n", "`n")][System.String]$before_code
        [Parameter(Mandatory=$true)][ValidateSet("`r", "`r`n", "`n")][System.String]$after_code
    )
}
Get-Content -Path $pyscript_path ForEach-Object { $_ -Replace "`n", "`r`n" }
Set-Content -Path $pyscript_path 
```
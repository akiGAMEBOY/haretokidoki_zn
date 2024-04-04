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
        [Parameter(Mandatory=$true)][ValidateSet("`r", "`r`n", "`n")][System.String]$before_code,
        [Parameter(Mandatory=$true)][ValidateSet("`r", "`r`n", "`n")][System.String]$after_code,
        [Parameter(Mandatory=$true)][System.String]$targetfile
        [System.String]$after_targetfile=''
    )

    # Before・Afterが異なる改行コードを指定しているかチェック
    if ($before_code -eq $after_code) {
        Write-Host '変換前 と 変換後 の改行コードが一緒です。処理を中断します。'
        return
    }

    # 変換処理
    $after_data = (Get-Content -Path $targetfile -Raw | ForEach-Object { $_ -Replace $before_code, $after_code })

    # 保存
    Set-Content -Path $targetfile -Value $after_data
}
```

---
title: "PowerShellで2つの配列を比較し同じ要素かチェックするFunction"
emoji: "👌"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: false
---

```powershell:
Function Test-ArrayEquality {
    param (
        [Parameter(Mandatory=$true)][System.Array]$Array1,
        [Parameter(Mandatory=$true)][System.Array]$Array2
    )
    
    # 比較（差異が無い場合、$null か 空の配列 が返る）
    $diffResult = (Compare-Object -ReferenceObject $Array1 -DifferenceObject $Array2 -SyncWindow 0)

    # 比較結果を評価
    if (($null -eq $diffResult) -or ($diffResult.Count -eq 0)) {
        return $true
    }
    else {
        return $false
    }
}
```

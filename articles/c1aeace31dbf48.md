---
title: "PowerShellで2つの配列を比較し同じ要素かチェックするFunction"
emoji: "👌"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: false
---

```powershell:要素数が一緒か
articles\45c5af7cbf7eb8.md
# 配列の種類を判定
function Get-ArrayType {
    param(
        $InputObject
    )
    
    [System.Collections.Hashtable]$arrayTypes = @{
        "OtherTypes" = -1
        "SingleArray" = 0
        "MultiLevel" = 1
        "MultiDimensional" = 2
    }

    # データがない場合
    if ($null -eq $InputObject) {
        return $arrayTypes["OtherTypes"]
    }

    # 一番外枠が配列ではない場合
    if ($InputObject -isnot [System.Array]) {
        return $arrayTypes["OtherTypes"]
    }

    # ジャグ配列（多段階配列）か判定
    $isMultiLevel = $false
    foreach ($element in $InputObject) {
        if ($element -is [System.Array]) {
            # 配列の中も配列で多段配列
            $isMultiLevel = $true
            break
        }
    }
    if ($isMultiLevel) {
        return $arrayTypes["MultiLevel"]
    }    
    
    # 多次元配列か判定
    if ($InputObject.Rank -ge 2) {
        # 2次元以上の場合
        return $arrayTypes["MultiDimensional"]
    }
    else {
        # 1次元の場合
        # 前提：冒頭の「-isnot [System.Array]」により配列であることは確認済みとなる。
        return $arrayTypes["SingleArray"]
    }
}
# 多次元配列の要素数を比較
Function Test-MultiDimensionalEquality {
    param (
        [Parameter(Mandatory=$true)]$Array1,
        [Parameter(Mandatory=$true)]$Array2
    )

    

    # 配列の次元数を比較
    $dimensionArray1 = $Array1.Rank
    $dimensionArray2 = $Array2.Rank

    if ($dimensionArray1 -ne $dimensionArray2) {
        return $false
    }

    # 各次元毎の要素数をチェック
    for ($i = 0; $i -lt $dimensionArray1; $i++) {
        if ($Array1.GetLength($i) -ne $Array2.GetLength($i)) {
            return $false
        }
    }

    # 要素数が一致
    return $true
}
```

```powershell:要素数と値すべて一緒か
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

## 関連記事

https://haretokidoki-blog.com/pasocon_powershell-startup/
https://zenn.dev/haretokidoki/articles/7e6924ff0cc960
https://zenn.dev/haretokidoki/articles/fb6830f9155de5

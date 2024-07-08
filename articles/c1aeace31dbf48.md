---
title: "PowerShellで2つの配列同士の要素数が同じかチェックするFunction"
emoji: "👌"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: false
---
## 概要

PowerShellでは2種類の配列、多次元配列 と ジャグ配列（多段配列） を宣言できます。
それら同じ種類の配列を2つPowerShellスクリプトのコードで取り扱う前に、配列同士の要素数が同一かチェックするシチュエーションがあり、それぞれのFunctionを作成しました。

実際のコードを含めて対応方法を紹介します。

## この記事のターゲット

- PowerShellユーザーの方
- 2つの多次元配列が同じ要素数かチェックしたい方
- 2つのジャグ配列（多段配列）が同じ要素数かチェックしたい方
- (おまけ)値を含め2つの配列のすべてを比較したい方

## 対応方法

下記の3つの方法を紹介。

- [2つの多次元配列の要素数をチェックするコード](#2つの多次元配列の要素数をチェックするコード)
- [2つのジャグ配列（多段配列）が同じ要素数かチェックするコード](#2つのジャグ配列多段配列が同じ要素数かチェックするコード)
- [配列のすべてを比較するコード](#配列のすべてを比較するコード)

### 2つの多次元配列の要素数をチェックするコード

```powershell:2つの多次元配列の要素数をチェックするFunction
#################################################################################
# 処理名　 | Get-ArrayType
# 機能　　 | 配列の種類を判定
#          | 参考情報：https://zenn.dev/haretokidoki/articles/45c5af7cbf7eb8
#--------------------------------------------------------------------------------
# 戻り値　 | System.Int32
#     　　 |  0: 単一配列, 1: ジャグ配列（多段配列）, 2: 多次元配列, -1:それ以外
# 引数　　 | InputObject
#################################################################################
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
# 多次元配列の要素数をチェック
Function Test-MultiDimensionalArrayEquality {
    param (
        [Parameter(Mandatory=$true)]$Array1,
        [Parameter(Mandatory=$true)]$Array2
    )

    # 多次元配列か判定
    $resultArrayType = (Get-ArrayType $Array1)
    if ($resultArrayType -ne 2) {
        Write-Warning "引数の「Array1」が多次元配列ではありません。[配列の判定結果: $($resultArrayType)]"
        return $false
    }
    $resultArrayType = (Get-ArrayType $Array2)
    if ($resultArrayType -ne 2) {
        Write-Warning "引数の「Array2」が多次元配列ではありません。[配列の判定結果: $($resultArrayType)]"
        return $false
    }

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

### 2つのジャグ配列（多段配列）が同じ要素数かチェックするコード

```powershell:2つのジャグ配列（多段配列）が同じ要素数かチェックするFunction
#################################################################################
# 処理名　 | Get-ArrayType
# 機能　　 | 配列の種類を判定
#          | 参考情報：https://zenn.dev/haretokidoki/articles/45c5af7cbf7eb8
#--------------------------------------------------------------------------------
# 戻り値　 | System.Int32
#     　　 |  0: 単一配列, 1: ジャグ配列（多段配列）, 2: 多次元配列, -1:それ以外
# 引数　　 | InputObject
#################################################################################
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

# ジャグ配列の要素数をチェック
Function Test-MultiLevelArrayEquality {
    param (
        [Parameter(Mandatory=$true)]$Array1,
        [Parameter(Mandatory=$true)]$Array2
    )

    # ャグ配列か判定
    $resultArrayType = (Get-ArrayType $Array1)
    if ($resultArrayType -ne 1) {
        Write-Warning "引数の「Array1」がジャグ配列（多次元配列）ではありません。[配列の判定結果: $($resultArrayType)]"
        return $false
    }
    $resultArrayType = (Get-ArrayType $Array2)
    if ($resultArrayType -ne 1) {
        Write-Warning "引数の「Array2」がジャグ配列（多次元配列）ではありません。[配列の判定結果: $($resultArrayType)]"
        return $false
    }

    # 配列の次元数を比較
    $levelArray1 = $Array1.Length
    $levelArray2 = $Array2.Length

    Write-Debug "`$levelArray1: [$($levelArray1)], `$levelArray2: [$($levelArray2)]"
    if ($levelArray1 -ne $levelArray2) {
        return $false
    }

    # 各次元毎の要素数をチェック
    for ($i = 0; $i -lt $Array1.Length; $i++) {
        Write-Debug "`$Array1[$($i)].Length: [$($Array1[$i].Length)], `$Array2[$($i)].Length: [$($Array2[$i].Length)]"
        if ($Array1[$i].Length -ne $Array2[$i].Length) {
            return $false
        }
        for ($j = 0; $j -lt $Array1[$i].Length; $j++) {
            Write-Debug "`$Array1[$($i)][$($j)]: [$($Array1[$i][$j])], `$Array2[$($i)][$($j)]: [$($Array2[$i][$j])]"
            if ($Array1[$i][$j] -ne $Array2[$i][$j]) {
                return $false
            }
        }
    }

    # 要素数が一致
    return $true
}
```

### 配列のすべてを比較するコード

おまけ。

今回は要素数にテーマを置いたシチュエーションですが、値も含めて配列をまるまる比較したい場合のコードも紹介。

```powershell:要素数だけでなく値を含めすべて比較するFunction
Function Test-ArrayEquality {
    param (
        [Parameter(Mandatory=$true)][System.Array]$Array1,
        [Parameter(Mandatory=$true)][System.Array]$Array2
    )
    
    # 比較（差異が無い場合、$null か 空の配列 が返る）
    $diffResult = (Compare-Object -ReferenceObject $Array1 -DifferenceObject $Array2 -SyncWindow 0)

    # 比較結果を評価
    return (($null -eq $diffResult) -or ($diffResult.Count -eq 0))
}
```

## まとめ

下記3つのFuncitonを紹介しました。

- 2つの多次元配列の要素数をチェックし論理型（`System.Boolean`）で返すFuncitonを作成
- 2つのジャグ配列（多次元配列）の要素数をチェックし論理型（`System.Boolean`）で返すFuncitonを作成
- 要素数だけでなく値もひっくるめて配列を比較するFunctionを作成

## 関連記事

https://haretokidoki-blog.com/pasocon_powershell-startup/
https://zenn.dev/haretokidoki/articles/7e6924ff0cc960
https://zenn.dev/haretokidoki/articles/fb6830f9155de5

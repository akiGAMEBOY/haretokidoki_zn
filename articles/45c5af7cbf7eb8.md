---
title: "PowerShellでジャグ配列か多次元配列か判定する方法"
emoji: "📘"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: false
---
PowerShellでジャグ配列（多段階配列）と多次元配列を判定するFunctionを以下に示します。このFunctionは、配列が多段階配列か多次元配列かを判定し、その情報を返します。

```powershell
function Get-ArrayType {
    param(
        $Array
    )
    
    [System.Collections.Hashtable]$arrayTypes = @{
        "OtherTypes" = -1
        "MultiLevel" = 1
        "MultiDimensional" = 2
    }

    # 多段階配列（ジャグ配列）か判定
    if ($Array -is [System.Array]) {
        foreach ($elementArray in $Array) {
            if ($elementArray -is [System.Array]) {
                # 配列の中も配列で多段配列
                return $arrayTypes["MultiLevel"]
            }
        }
    }
    
    # 多次元配列か判定
    if (($Array.GetType().Name) -eq 'Object[,]') {
        return $arrayTypes["MultiDimensional"]
    }

    return $arrayTypes["OtherTypes"]
}
```

```powershell
# 多段階配列（ジャグ配列）のテストデータ
$multiLevelArray = @( @(1, 2), @(3, 4, 5), @(6) )

# 多次元配列のテストデータ
$multiDimArray = New-Object 'object[,]' 2,2
$multiDimArray[0,0] = 1
$multiDimArray[0,1] = 2
$multiDimArray[1,0] = 3
$multiDimArray[1,1] = 4

# Functionのテスト
Write-Host "--- 多段階配列のテスト結果 ---`n"
# 文字列型の変数名を宣言
$variableName = 'multiLevelArray'
# 文字列型の変数名を使用して変数の値を取得
$variableValue = (Get-Variable -Name $variableName -ValueOnly)
switch ((Get-ArrayType -Array $variableValue)) {
    # 多段配列の場合
    "1" {
        Write-Host "`$$($variableName) は 多段配列 です。`n"
    }
    # 多次元配列の場合
    "2" {
        Write-Host "`$$($variableName) は 多次元配列 です。`n"
    }
    # それ以外
    "-1" {
        Write-Host "`$$($variableName) は 多段配列・多次元配列以外のデータ型 です。`n"
    }
}

Write-Host "--- 多次元配列のテスト結果 ---`n"
# 文字列型の変数名を宣言
$variableName = 'multiDimArray'
# 文字列型の変数名を使用して変数の値を取得
$variableValue = (Get-Variable -Name $variableName -ValueOnly)
switch ((Get-ArrayType -Array $variableValue)) {
    # 多段配列の場合
    "1" {
        Write-Host "`$$($variableName) は 多段配列 です。`n"
    }
    # 多次元配列の場合
    "2" {
        Write-Host "`$$($variableName) は 多次元配列 です。`n"
    }
    # それ以外
    "-1" {
        Write-Host "`$$($variableName) は 多段配列・多次元配列以外のデータ型 です。`n"
    }
}
```

このスクリプトを実行すると、多段階配列と多次元配列の両方に対して`Test-ArrayDimension` Functionが適用され、それぞれが多段階配列であるか、多次元配列であるかの結果が表示されます。結果は連想配列として返され、そのキーと値を列挙してコンソールに出力しています。

このテストデータとスクリプトを使用して、Functionが正しく動作するかどうかを確認することができます。必要に応じて、テストデータを変更してさらに多くのシナリオをテストすることも可能です。🔧

ソース: Copilot との会話、 2024/6/11
(1) Powershell Multidimensional Arrays - Stack Overflow. https://stackoverflow.com/questions/9397137/powershell-multidimensional-arrays.
(2) How do I find and get value from multi dimensional array in .... https://stackoverflow.com/questions/72278817/how-do-i-find-and-get-value-from-multi-dimensional-array-in-powershell.
(3) Checking if array is multidimensional or not? - Stack Overflow. https://stackoverflow.com/questions/145337/checking-if-array-is-multidimensional-or-not.
(4) about Arrays - PowerShell | Microsoft Learn. https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_arrays?view=powershell-7.4.
---
title: "PowerShellでジャグ配列か多次元配列かを判定するFunction"
emoji: "📘"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: false
---
## 概要

PowerShellでジャグ配列（多段階配列）と多次元配列を判定するFunctionを以下に示します。このFunctionは、配列が多段階配列か多次元配列かを判定し、その情報を返します。

## ジェネリックコードの特徴

今回のように複数のデータ型に対応したコードを[ジェネリックコード](https://ja.wikipedia.org/wiki/ジェネリックプログラミング)というらしい。
このジェネリックコードの特徴は以下のとおり。

- 柔軟性が高い
    異なるデータ型に対して同じ操作を行うことができるので、柔軟性が高い。
- 再利用性が高い
    異なるデータ型で同じクラスやメソッドを使用することができるので、再利用性が高い
- 保守性が向上
    1か所の変更で複数のデータ型のコードに反映されるため、保守性が向上する。
- パフォーマンスは低い
    データ型を抽象化し処理する事によりパフォーマンスのオーバーヘッドが発生する可能性あり。
- 可読性が高い
    コードを一元化し簡潔にコーディング可能で可読性も高い。

```powershell
function Get-ArrayType {
    param(
        $Array
    )
    
    [System.Collections.Hashtable]$arrayTypes = @{
        "OtherTypes" = -1
        "SingleArray" = 0
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
    if ($Array.Rank -eq 1) {
        return $arrayTypes["SingleArray"]
    }
    elseif ($Array.Rank -gt 1) {
        return $arrayTypes["MultiDimensional"]
    }

    return $arrayTypes["OtherTypes"]
}
```

```powershell:
# String型の1x2多次元配列
$stringArray1x2 = New-Object 'System.String[,]' 1,2
$stringArray1x2[0,0] = 'Hello'
$stringArray1x2[0,1] = 'World'

# Int32型の3x2多次元配列
$intArray3x2 = New-Object 'System.Int32[,]' 3,2
$intArray3x2[0,0] = 1
$intArray3x2[0,1] = 2
$intArray3x2[1,0] = 3
$intArray3x2[1,1] = 4
$intArray3x2[2,0] = 5
$intArray3x2[2,1] = 6

# Int32型の3x2多次元配列
$objectArray3x1 = New-Object 'System.Object[,]' 3,1
$objectArray3x1[0,0] = 'I am String.'
$objectArray3x1[1,0] = 1
$objectArray3x1[2,0] = 10.5


# 以前のテストデータと新しいテストデータをまとめた実行
$testData = @(
    @{ "Description" = "単一配列"; "Array" = @(1, 2, 3) },
    @{ "Description" = "多段階配列"; "Array" = @(@(1, 2), @(3, 4), @(5, 6)) },
    @{ "Description" = "String型1x2多次元配列"; "Array" = $stringArray1x2 },
    @{ "Description" = "Int32型3x2多次元配列"; "Array" = $intArray3x2 }
    @{ "Description" = "Object型3x1多次元配列"; "Array" = $objectArray3x1 }
)

foreach ($data in $testData) {
    $result = Get-ArrayType -Array $data["Array"]
    Write-Host "$($data["Description"])の結果: $result"
}
```
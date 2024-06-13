---
title: "[PowerShell]配列の種類（ジャグ配列 or 多次元配列）を判定するFunction"
emoji: "🐣"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: true
---
## 概要

PowerShellでジャグ配列（多段階配列）と多次元配列を判定するFunctionを紹介。
このFunctionは、引数のオブジェクトの中身を検証し、配列の種類を判定します。
判定した結果は、戻り値の数値で判断するつくりとなっています。

## 配列の種類をを判定するFunction

Functionを実行した際に戻ってくる数値は下記のとおり。

| 配列の種類 | 戻り値（数値） |
| ---- | ---- |
| 単一配列の場合 | 0 |
| ジャグ配列（多段階配列）の場合 | 1 |
| 多次元配列の場合 | 2 |
| 上記以外 | -1 |

```powershell:引数の配列を判定するFunction
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
```

## 実際に実行した結果

```powershell:テストデータの準備
# 単一の配列
$singleArray = @('あ', 'い', 'う')

# 多段階配列
$multiLevel = @(@(1, 2, 3), @(4, 5), @(6, 7, 8, 9))

# String型の1x2 多次元配列
$stringMultiDim1x2 = New-Object 'System.String[,]' 1,2
$stringMultiDim1x2[0,0] = 'Hello'
$stringMultiDim1x2[0,1] = 'World'

# Int32型の3x2 多次元配列
$intMultiDim3x2 = New-Object 'System.Int32[,]' 3,2
$intMultiDim3x2[0,0] = 1
$intMultiDim3x2[0,1] = 2
$intMultiDim3x2[1,0] = 3
$intMultiDim3x2[1,1] = 4
$intMultiDim3x2[2,0] = 5
$intMultiDim3x2[2,1] = 6

# Object型の3x1 多次元配列
$objectMultiDim3x1 = New-Object 'System.Object[,]' 3,1
$objectMultiDim3x1[0,0] = 'I am String.'
$objectMultiDim3x1[1,0] = 1
$objectMultiDim3x1[2,0] = 10.5

# テストデータを集約
$testData = @(
    @{ "Description" = "単一配列"; "InputObject" = $singleArray },
    @{ "Description" = "多段階配列"; "InputObject" = $multiLevel },
    @{ "Description" = "String型1x2多次元配列"; "InputObject" = $stringMultiDim1x2 },
    @{ "Description" = "Int32型3x2多次元配列"; "InputObject" = $intMultiDim3x2 }
    @{ "Description" = "Object型3x1多次元配列"; "InputObject" = $objectMultiDim3x1 }
)
```

上記で準備したテストデータを実行しました。

```powershell:コピー用
# 実行
foreach ($data in $testData) {
    $result = Get-ArrayType -InputObject $data["InputObject"]
    Write-Host "$($data["Description"])の結果: $result"
}
```

```powershell:実際に実行した結果
PS D:\Downloads> # 実行
>> foreach ($data in $testData) {
>>     $result = Get-ArrayType -InputObject $data["InputObject"]
>>     Write-Host "$($data["Description"])の結果: $result"
>> }
単一配列の結果: 0
多段階配列の結果: 1
String型1x2多次元配列の結果: 2
Int32型3x2多次元配列の結果: 2
Object型3x1多次元配列の結果: 2
PS D:\Downloads>
```

期待通りの結果となりました。
このFunctionで配列の種類を判定した後、同じデータ型にまとめる処理を入れることで、
複数のデータ型に対応したコードが作成できると思います。

## ジェネリックコードの特徴

今回のように複数のデータ型に対応するコードを[ジェネリックコード](https://ja.wikipedia.org/wiki/ジェネリックプログラミング)というらしいです。

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

対応するコード量は多くなりますが、その後の運用・メンテナンスの事を考慮すると初期導入時にがんばりたいポイントになりそうです。

## まとめ

- 配列の種類を戻り値（数値）で判定できるFunctionを作成した
- このFunctionを組み合わせることで複数のデータ型に対応するコードが実現できそう

## 関連記事

https://haretokidoki-blog.com/pasocon_powershell-startup/
https://zenn.dev/haretokidoki/articles/7e6924ff0cc960
https://zenn.dev/haretokidoki/articles/fb6830f9155de5

---
title: "PowerShellでジャグ配列（多次元配列）かリテラル配列（単一次元配列）か判定する方法"
emoji: "📘"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: false
---
PowerShellでジャグ配列（多次元配列の一種）とリテラル配列（単一次元配列）を判定する方法は、配列の各要素を調べて、それが配列かどうかを確認することです。例えば、以下のようなスクリプトを使用できます：

```powershell
# 配列を定義
$array = @(1, 2, @(3, 4), 5)

# 配列の各要素をチェック
foreach ($item in $array) {
    if ($item -is [array]) {
        Write-Host "ジャグ配列の要素: $item"
    } else {
        Write-Host "リテラル配列の要素: $item"
    }
}
```

このスクリプトは、配列の各要素がさらに配列であるかどうかをチェックし、その結果をコンソールに出力します。`-is` 演算子は、オブジェクトが特定の型であるかどうかをテストするために使用されます。この場合、`[array]`型であるかどうかをチェックしています。

また、配列がジャグ配列であるかどうかを判定する別の方法として、配列の要素数と、その要素が配列である場合の要素数を比較する方法もあります。例えば、以下のようにします：

```powershell
# 配列を定義
$jaggedArray = @( @(1, 2), @(3, 4) )
$literalArray = @(1, 2, 3, 4)

# 配列がジャグ配列かどうかをチェック
function Test-JaggedArray($array) {
    foreach ($element in $array) {
        if ($element -isnot [array]) {
            return $false
        }
    }
    return $true
}

# テスト実行
Write-Host "ジャグ配列: $(Test-JaggedArray $jaggedArray)"
Write-Host "リテラル配列: $(Test-JaggedArray $literalArray)"
```

この関数`Test-JaggedArray`は、配列のすべての要素が配列であるかどうかをチェックし、その結果に基づいて真偽値を返します。すべての要素が配列であれば`$true`を、そうでなければ`$false`を返します。

これらのスクリプトは、PowerShellで配列の型を判定するための基本的な方法を示しています。実際の使用状況に応じて、これらのスクリプトをカスタマイズして使用することができます。配列に関する詳細な情報は、[Microsoftの公式ドキュメント](^1^)で確認することができます。また、[Stack Overflow](^2^)には、実際の問題解決の例が多数投稿されており、参考になるでしょう。

ソース: Copilot との会話、 2024/6/11
(1) 配列について知りたかったことのすべて - PowerShell | Microsoft .... https://learn.microsoft.com/ja-jp/powershell/scripting/learn/deep-dives/everything-about-arrays?view=powershell-7.4.
(2) PowerShell - jagged array filtering with pipeline in pipeline. https://stackoverflow.com/questions/16458739/powershell-jagged-array-filtering-with-pipeline-in-pipeline.
(3) powershell - Creating a Jagged\Multidimensional array with a .... https://stackoverflow.com/questions/39799562/creating-a-jagged-multidimensional-array-with-a-single-array-inside-of-it.
(4) Everything you wanted to know about arrays - PowerShell. https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-arrays?view=powershell-7.4.

---
title: "PowerShellでジャグ配列か多次元配列か判定する方法"
emoji: "📘"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: false
---
PowerShellでジャグ配列（多段階配列）と多次元配列を判定するFunctionを以下に示します。このFunctionは、配列が多段階配列か多次元配列かを判定し、その情報を返します。

```powershell
function Test-ArrayDimension {
    param($array)
    $result = @{
        IsMultiLevel = $false
        IsMultiDimensional = $false
    }

    # 配列が多段階配列（ジャグ配列）かどうかを判定
    if ($array -is [array]) {
        foreach ($subArray in $array) {
            if ($subArray -is [array]) {
                $result['IsMultiLevel'] = $true
                break
            }
        }
    }

    # 配列が多次元配列かどうかを判定
    if ($array.GetType().Name -eq 'Object[,]') {
        $result['IsMultiDimensional'] = $true
    }

    return $result
}
```

このFunctionは、まず引数として渡された`$array`が配列であるかどうかをチェックします。配列であれば、その配列が多段階配列（ジャグ配列）であるかどうかを判定します。次に、`GetType().Name`メソッドを使用して、配列が多次元配列であるかどうかを判定します。

多次元配列は`.NET`の型を使用して作成されるため、`Object[,]`のような型名が返されます。このFunctionを使用することで、配列の種類を簡単に判定することができます。

テストとして、以下のような多段階配列と多次元配列を作成し、Functionを適用してみましょう。

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
Write-Host "多段階配列のテスト結果:"
$multiLevelResult = Test-ArrayDimension -array $multiLevelArray
$multiLevelResult.GetEnumerator() | ForEach-Object { Write-Host "$($_.Key): $($_.Value)" }

Write-Host "`n多次元配列のテスト結果:"
$multiDimResult = Test-ArrayDimension -array $multiDimArray
$multiDimResult.GetEnumerator() | ForEach-Object { Write-Host "$($_.Key): $($_.Value)" }
```

このスクリプトを実行すると、多段階配列と多次元配列の両方に対して`Test-ArrayDimension` Functionが適用され、それぞれが多段階配列であるか、多次元配列であるかの結果が表示されます。結果は連想配列として返され、そのキーと値を列挙してコンソールに出力しています。

このテストデータとスクリプトを使用して、Functionが正しく動作するかどうかを確認することができます。必要に応じて、テストデータを変更してさらに多くのシナリオをテストすることも可能です。🔧

ソース: Copilot との会話、 2024/6/11
(1) Powershell Multidimensional Arrays - Stack Overflow. https://stackoverflow.com/questions/9397137/powershell-multidimensional-arrays.
(2) How do I find and get value from multi dimensional array in .... https://stackoverflow.com/questions/72278817/how-do-i-find-and-get-value-from-multi-dimensional-array-in-powershell.
(3) Checking if array is multidimensional or not? - Stack Overflow. https://stackoverflow.com/questions/145337/checking-if-array-is-multidimensional-or-not.
(4) about Arrays - PowerShell | Microsoft Learn. https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_arrays?view=powershell-7.4.
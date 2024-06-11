---
title: "PowerShellでジャグ配列（多次元配列）かリテラル配列（単一次元配列）か判定する方法"
emoji: "📘"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: false
---
PowerShellで引数のオブジェクトがジャグ配列かリテラル配列かを判定するFunctionを以下に示します。このFunctionは、引数として渡されたオブジェクトが配列であるかどうかを判定し、配列であればさらにその配列がジャグ配列（配列の配列）であるかリテラル配列（単一次元配列）であるかを判定します。

```powershell
function Test-Array {
    param($array)
    $result = @{
        IsArray = $false
        IsJagged = $false
        IsLiteral = $false
    }

    # オブジェクトが配列かどうかを判定
    if ($array -is [array]) {
        $result['IsArray'] = $true

        # 配列がジャグ配列かリテラル配列かを判定
        $isJagged = $false
        foreach ($element in $array) {
            if ($element -is [array]) {
                $isJagged = $true
                break
            }
        }

        $result['IsJagged'] = $isJagged
        $result['IsLiteral'] = !$isJagged
    }

    return $result
}
```

このFunctionは、`$array`が配列である場合には`$result['IsArray']`を`$true`に設定します。その後、配列内の各要素をチェックし、いずれかの要素が配列であればジャグ配列と判定し、`$result['IsJagged']`を`$true`に設定します。もし配列内の要素がすべて配列でなければリテラル配列と判定し、`$result['IsLiteral']`を`$true`に設定します。

このFunctionを使用することで、引数として渡されたオブジェクトがジャグ配列かリテラル配列かを簡単に判定することができます。必要に応じて、このコードをカスタマイズしてご利用ください。🛠️

ソース: Copilot との会話、 2024/6/11
(1) “多次元配列（リテラル配列）”と“ジャグ配列”の要素数を .... https://zenn.dev/haretokidoki/articles/f79a5bb769973f.
(2) powershell - Get-Members for jagged array - Super User. https://superuser.com/questions/1746016/get-members-for-jagged-array.
(3) How to Check if a Variable is an Array in PowerShell?. https://powershellfaqs.com/check-if-a-variable-is-an-array-in-powershell/.
(4) PowerTip: Find if Variable Is Array - Scripting Blog [archived]. https://devblogs.microsoft.com/scripting/powertip-find-if-variable-is-array-2/.

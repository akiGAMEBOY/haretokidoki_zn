---
title: "文字列を対象に指定バイト位置から指定バイト数を抽出するFunction"
emoji: "🚪"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: false
---
## 概要

> 依頼内容
> 
> PowerShellで「文字列の特定の位置から指定した長さの部分文字列を取得」する方法をすべて提示してください。

> 回答
> 
> [1]: https://extan.jp/?p=10317 ""
> [2]: https://www.delftstack.com/ja/howto/powershell/powershell-substring-after-character/ ""
> [3]: https://forkful.ai/ja/powershell/strings/extracting-substrings/ ""
> [4]: https://step-learn.com/article/powershell/021-string-substring.html ""
> [5]: https://learn.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/select-object?view=powershell-7.3 ""
> 
> PowerShellで文字列の特定の位置から指定した長さの部分文字列を取得する方法は、主に`Substring`メソッドを使用します。以下にその使用方法を示します。
> 
> 1. **基本的なSubstringメソッド**:
>    文字列の特定の位置から指定した長さの部分文字列を取得します。
>    ```powershell
>    $string = "こんにちは、PowerShell！"
>    $substring = $string.Substring(0, 5) # 最初の5文字を取得
>    ```
> 
> 2. **IndexOfメソッドと組み合わせたSubstringメソッド**:
>    特定の文字や文字列が最初に現れる位置を見つけ、そこから部分文字列を取得します。
>    ```powershell
>    $string = "こんにちは、PowerShell！"
>    $start = $string.IndexOf("PowerShell")
>    $substring = $string.Substring($start, 10) # "PowerShell"の部分を取得
>    ```
> 
> 3. **LastIndexOfメソッドと組み合わせたSubstringメソッド**:
>    特定の文字や文字列が最後に現れる位置を見つけ、そこから部分文字列を取得します。
>    ```powershell
>    $string = "こんにちは、PowerShell！こんにちは、世界！"
>    $start = $string.LastIndexOf("こんにちは")
>    $substring = $string.Substring($start) # 最後の"こんにちは"から最後までの部分を取得
>    ```
> 
> これらの方法を使って、さまざまなシナリオで文字列の部分を抽出することができます。詳細な情報や他の方法については、PowerShellのドキュメントや技術記事を参照してください¹[1]²[2]³[3]⁴[4]。
> 
> ソース: Bing との会話 2024/4/26
> (1) PowerShellで文字列を切り出す方法3選！特定の文字以降/以前も .... https://extan.jp/?p=10317.
> (2) 文字列から PowerShell 部分文字列を抽出する | Delft スタック. https://www.delftstack.com/ja/howto/powershell/powershell-substring-after-character/.
> (3) PowerShell: 部分文字列の抽出. https://forkful.ai/ja/powershell/strings/extracting-substrings/.
> (4) PowerShell: 文字列の切り出し Substring. https://step-learn.com/article/powershell/021-string-substring.html.
> (5) undefined. https://learn.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/select-object?view=powershell-7.3.

```powershell:バイト数で文字列抽出するFunction
#################################################################################
# 処理名　 | ExtractByteSubstring
# 機能　　 | バイト数で文字列を抽出
#--------------------------------------------------------------------------------
# 戻り値　 | String（抽出した文字列）
# 引数　　 | target_str   : 対象文字列
# 　　　　 | start : 抽出開始するバイト位置
# 　　　　 | length: 指定バイト数
#################################################################################
Function ExtractByteSubstring {
    Param (
        [System.String]$target_str,
        [System.Int32]$start,
        [System.Int32]$length
    )

    $encoding = [System.Text.Encoding]::GetEncoding("Shift_JIS")

    # 文字列をバイト配列に変換
    [System.Byte[]]$all_bytes = $encoding.GetBytes($target_str)

    # 抽出するバイト配列を初期化
    $extracted_bytes = New-Object Byte[] $length

    # 指定されたバイト位置からバイト配列を抽出
    [System.Array]::Copy($all_bytes, $start, $extracted_bytes, 0, $length)

    # バイト配列から文字列に変換して返す
    return $encoding.GetString($extracted_bytes)
}
```

---
title: "文字列を対象に指定バイト位置から指定バイト数を抽出するFunction"
emoji: "🚪"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: false
---

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

    [System.Text.DBCSCodePageEncoding]$encoding = [System.Text.Encoding]::GetEncoding("Shift_JIS")

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

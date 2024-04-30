---
title: "[PowerShell]文字列のバイト数を取得する方法"
emoji: "🚪"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell", "bytes"]
published: false
---
## 概要

Excel関数、またはVBAでいうところの **LENB関数** のようにPowerShellでも文字列のバイト数を取得したいシチュエーションがあり、
Functionを自作しました。

## 環境

```powershell:PowerShellのバージョン
PS C:\Users\"ユーザー名"> $PSVersionTable

Name                           Value
----                           -----
PSVersion                      5.1.19041.4291
PSEdition                      Desktop
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0...}
BuildVersion                   10.0.19041.4291
CLRVersion                     4.0.30319.42000
WSManStackVersion              3.0
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1


PS C:\Users\"ユーザー名">
```

## なぜ文字列のバイト数を取得したいのか（= 実現したいこと）

コマンド結果のデータ型がオブジェクト型（`System.Object`）ではない場合は、項目名を指定した加工などは不可能です。

そのような、ただの文字列で返ってくるコマンド結果を加工する場合は、固定長データとして加工する必要があります。

固定長データを扱う際、コマンド結果がすべて英数字のみであれば、下記のようなLengthメソッドを使う事で、
簡単に桁数をカウントし制御が可能です。

```powershell:英数字だけの文字列の結果
PS C:\Users\"ユーザー名"> [System.String]$target_str = 'abcdefg'
PS C:\Users\"ユーザー名">
PS C:\Users\"ユーザー名"> $target_str.Length
7
PS C:\Users\"ユーザー名">
```

ただ、問題になってくるのが日本語などマルチバイトを含むデータがあった場合です。
単純にLengthメソッドを使用してしまうと、ズレが発生します。

```powershell:日本語（マルチバイト）を含む文字列の結果
PS C:\Users\"ユーザー名"> [System.String]$target_str = 'あいうabcd'
PS C:\Users\"ユーザー名">
PS C:\Users\"ユーザー名"> $target_str.Length
7
PS C:\Users\"ユーザー名">
```

このマルチバイトを含む文字列を固定長データとして制御する場合、「 **文字列をバイト数として取得** 」する事がが必要となりました。

:::details 文字列のバイト数が必要な具体的な例

より理解を深めたい方向けに具体的な例をあげて説明します。

まず、最初に英数字だけのコマンド結果を桁数（文字数）で配列に置き換えたい場合、

```:英数字だけのコマンド結果の例
PS C:\Users\"ユーザー名"> Get-Alphanumeric（架空のコマンドレット）
column01  column02  column03  
------------------------------
123456789012345678901234567890

PS C:\Users\"ユーザー名">
```

というコマンド結果を文字数でカウントすると下記のようになります。

| 桁数→ | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 英数字のみ - 項目名 | `c` | `o` | `l` | `u` | `m` | `n` | `0` | `1` | ` ` | ` ` | `c` |
| 英数字のみ - 値 | `1` | `2` | `3` | `4` | `5` | `6` | `7` | `8` | `9` | `0` | `1` |

この結果からも1桁目 ～ 10桁目までが 項目名`column01`のデータ、11桁目 ～ 20桁目までが 項目名`column02`のデータというように、
固定長データとして加工が可能。

表で置き換えると下記のようになります。

| `column01` | `column02` | `column03` |
| --- | --- | --- |
| `1234567890` | `1234567890` | `1234567890` |

ここまでのように英数字だけのコマンド結果であれば、Lengthメソッドだけで制御可能です。

-----

しかし、マルチバイト（日本語）を含むコマンド結果を文字数だけでは制御できません。
具体的な例をあげると、

```:日本語を含むコマンド結果の例
PS C:\Users\"ユーザー名"> Get-Multibyte（架空のコマンドレット）
項目0001  項目0002  項目0003  
------------------------------
あ12345678あ12345678あ12345678

PS C:\Users\"ユーザー名"> 
```

上記のようにマルチバイトを含んだコマンド結果の場合、文字数だけでカウントしてしまうと、

| 桁数→ | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 日本語含む - 項目名 | `項` | `目` | `0` | `0` | `0` | `1` | ` ` | ` ` | `項` | `目` | `0` |
| 日本語含む - 値 | `あ` | `1` | `2` | `3` | `4` | `5` | `6` | `7` | `8` | `あ` | `1` |

というように、項目名や値それぞれでズレが発生してしまいます。

10桁ごとに置き換えると下記のように。

| `項目0001  項目` | `0002  項目00` | `03  `<br>※ 4桁のみ |
| --- | --- | --- |
| `あ12345678あ` | `12345678あ1` | `2345678`<br>※ 7桁のみ |

以上、英数字のみのコマンド結果 と マルチバイトを含むコマンド結果 を例にあげた結果からも、
マルチバイトを含むコマンド結果 の場合は、Lengthメソッドのように文字数だけでは、固定長データとして制御できないことが理解できたと思います。

:::

## 自作Funciton「文字列を対象に指定バイト位置から指定バイト数を抽出するFunction」


## 参考情報

[Excel - LEN と LENB について](https://support.microsoft.com/ja-jp/office/len-関数-lenb-関数-29236f94-cedc-429d-affd-b5e33d2c67cb)

[VBA - Len と LenB について](https://learn.microsoft.com/ja-jp/office/vba/language/reference/user-interface-help/len-function)

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

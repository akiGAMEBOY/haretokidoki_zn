---
title: "PowerShellで文字列のバイト数を取得する方法（文字列抽出するFunctionも紹介）"
emoji: "🚪"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: true
---
## 概要

[Ruby bytesize](https://docs.ruby-lang.org/ja/latest/method/String/i/bytesize.html) や [VBA LenB](https://learn.microsoft.com/ja-jp/office/vba/language/reference/user-interface-help/len-function) 、[Excel LENB関数](https://support.microsoft.com/ja-jp/office/len-関数-lenb-関数-29236f94-cedc-429d-affd-b5e33d2c67cb) のようにPowerShellでも文字列のバイト数を取得したいシチュエーションがあり、
取得方法やPowerShellスクリプトなどに組み込めるFunctionも自作しました。

## 環境

### Windows OS

Windows 10 Pro環境

```powershell:Get-WmiObjectコマンド
PS C:\Users\"ユーザー名"> Get-CimInstance CIM_OperatingSystem

SystemDirectory     Organization BuildNumber RegisteredUser SerialNumber            Version
---------------     ------------ ----------- -------------- ------------            -------
C:\WINDOWS\system32              19045       XXXXX          00000-00000-00000-AAAAA 10.0.19045
                                             ^^^^^          ^^^^^ ^^^^^ ^^^^^ ^^^^^
                                             ↑マスク       ↑マスク

PS C:\Users\"ユーザー名">
```

### PowerShell

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

## バイト数を取得するシチュエーション（私の場合）

PowerShellにおけるコマンド結果のデータ型がオブジェクト型（`System.Object`）ではない場合は、項目名を指定した加工が面倒になります。

また、そのコマンド結果に日本語を始めとするマルチバイトの文字列が含まれるケースでは、単純な文字数だけでは制御できず、
バイト数の取得が必要となります。

以降から具体的な例をあげます。

文字数だけで固定長のデータを取り扱う場合、すべて英数字のみの文字列を制御するのであれば、実現可能です。
下記のようにLengthメソッドを使い文字数で制御。

```powershell:英数字だけの文字列の結果
PS C:\Users\"ユーザー名"> [System.String]$target_str = 'abcdefg'
PS C:\Users\"ユーザー名">
PS C:\Users\"ユーザー名"> $target_str.Length
7
PS C:\Users\"ユーザー名">
```

一方、英数字だけでなく日本語を含む文字列が対象だった場合、文字数でカウントすると下記の通りとなります。

```powershell:日本語（マルチバイト）を含む文字列の結果
PS C:\Users\"ユーザー名"> [System.String]$target_str = 'あいうabcd'
PS C:\Users\"ユーザー名">
PS C:\Users\"ユーザー名"> $target_str.Length
7
PS C:\Users\"ユーザー名">
```

このような文字列が複数あるデータを固定長データとして制御したい場合で、かつ各文字列におけるマルチバイト文字の挿入位置がバラバラだった場合、
文字数だけでは制御できません。

そこで今回のテーマ「 **文字列のバイト数を取得する方法** 」が必要となりました。

:::details “文字列のバイト数を取得”のより具体的な例

上記内容ではイメージができなかった方に向け、より具体的な例を記載します。

まず、最初に英数字だけのコマンド結果を文字数で配列に置き換えたい場合、

```:英数字だけのコマンド結果の例
PS C:\Users\"ユーザー名"> Write-Alphanumeric（← 架空のコマンドレット）
column01  column02  column03  
------------------------------
123456789012345678901234567890

PS C:\Users\"ユーザー名">
```

というコマンド結果があった場合、文字数でカウントすると下記のようになります。

| 文字数→ | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 英数字のみ - 項目名 | `c` | `o` | `l` | `u` | `m` | `n` | `0` | `1` | ` ` | ` ` | `c` |
| 英数字のみ - 値 | `1` | `2` | `3` | `4` | `5` | `6` | `7` | `8` | `9` | `0` | `1` |

この結果からも1文字目 ～ 10文字目までが 項目名`column01`のデータ、11文字目 ～ 20文字目までが 項目名`column02`のデータというように、
固定長データとして制御・加工が可能となります。

また、これを表に置き換えると下記のとおりに。

| `[column01]` | `[column02]` | `[column03]` |
| --- | --- | --- |
| `[1234567890]` | `[1234567890]` | `[1234567890]` |

ここまでの通り英数字だけの文字列は、文字数（Lengthメソッド）で制御可能です。

----

一方、マルチバイト文字（日本語）を含むコマンド結果の場合は、文字数だけでは制御できません。
具体的な例をあげると、

```:日本語を含むコマンド結果の例
PS C:\Users\"ユーザー名"> Write-Multibyte（← 架空のコマンドレット）
項目0001  項目0002  項目0003  
------------------------------
あ12345678あ12345678あ12345678

PS C:\Users\"ユーザー名"> 
```

上記のようにマルチバイトを含んだコマンド結果の場合、文字数だけでカウントしてしまうと、

| 文字数→ | 01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 10 | 11 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 日本語含む - 項目名 | `項` | `目` | `0` | `0` | `0` | `1` | ` ` | ` ` | `項` | `目` | `0` |
| 日本語含む - 値 | `あ` | `1` | `2` | `3` | `4` | `5` | `6` | `7` | `8` | `あ` | `1` |

というように、項目名や値それぞれでズレが発生してしまいます。

10文字ずつで表に置き換えると下記のとおり。

| `[項目0001  項目]` | `[0002  項目00]` | `[03␣␣]`<br>※ 4文字のみ |
| --- | --- | --- |
| `[あ12345678あ]` | `[12345678あ1]` | `[2345678]`<br>※ 7文字のみ |

以上が 英数字だけの文字列 と マルチバイトを含む文字列 を固定長データとして制御する場合の具体例でした。

これら結果からも、マルチバイトを含む文字列を固定長データとして取り扱う場合、バイト数の取得が必須となる事をご理解いただけたかと思います。

:::

## 対応方法

文字列のバイト数を取得する方法として下記の3つを紹介。

- [コマンドで文字列のバイト数を確認する方法](#コマンドで文字列のバイト数を確認する方法)
- [自作したFunctionで文字列のバイト数を確認する方法](#自作したFunctionで文字列のバイト数を確認する方法)
- [バイト数を指定し文字列を抽出する自作Function](#バイト数を指定し文字列を抽出する自作Function)

本記事の対応方法はすべて文字コード「`Shift JIS`」でバイト数をカウントしており、Shift JISのマルチバイトは「2バイト」として処理されています。

必要な場合は、`UTF-8` など他の文字コードに置き換えてご対応ください。
なお、マルチバイトのバイト数は、文字コードにより変化します。
（`UTF-8` であれば「3バイト」。）

### コマンドで文字列のバイト数を確認する方法

```powershell:コピー用
[System.String]$target_str = "対象の文字列"
$target_str.Length
$encoding = [System.Text.Encoding]::GetEncoding("Shift_JIS")
$encoding.GetByteCount($target_str)
```

```powershell:実際にコマンドを実行した結果
# 対象の文字列を指定
PS C:\Users\"ユーザー名"> [System.String]$target_str = 'あ12345678'
PS C:\Users\"ユーザー名">
# 文字の長さ（文字数）だと9文字
PS C:\Users\"ユーザー名"> $target_str.Length
9
PS C:\Users\"ユーザー名">
# 文字コードをSJISで設定
PS C:\Users\"ユーザー名"> $encoding = [System.Text.Encoding]::GetEncoding("Shift_JIS")
PS C:\Users\"ユーザー名">
# SJISのバイト数（System.Int32）を取得
PS C:\Users\"ユーザー名"> $encoding.GetByteCount($target_str)
10
PS C:\Users\"ユーザー名">
```

### 自作したFunctionで文字列のバイト数を確認する方法

コマンドで確認した内容をFunctionにすると下記のとおり。

```powershell:文字列のバイト数を取得するFunction
#################################################################################
# 処理名　 | GetSjisCount
# 機能　　 | 文字列全体のバイト数をShift JISで取得
#--------------------------------------------------------------------------------
# 戻り値　 | Int32（文字列のバイト数）
# 引数　　 | target_str: 対象文字列
#################################################################################
Function GetSjisCount {
    Param (
        [System.String]$target_str
    )

    # 文字コードをSJISで設定
    $encoding = [System.Text.Encoding]::GetEncoding("Shift_JIS")

    # 文字列のバイト数を返す
    return $encoding.GetByteCount($target_str)
}
```

```powershell:実際に実行した結果
PS C:\Users\"ユーザー名"> GetSjisCount '項目0001  '
10
PS C:\Users\"ユーザー名">
```

### バイト数を指定し文字列を抽出する自作Function

指定の文字数で抽出可能な[Substringメソッド](https://learn.microsoft.com/ja-jp/dotnet/api/system.string.substring)のバイト数版としてFunctionを自作してみました。

引数は、下記3つの指定で抽出可能に。

- `$target_str` が抽出対象の文字列
- `$start` が先頭位置からバイト数で数えた位置を抽出開始位置
- `$length` が抽出開始位置（`$start`）から数え抽出するバイト数

```powershell:バイト数で文字列抽出するFunction
#################################################################################
# 処理名　 | ExtractByteSubstring
# 機能　　 | バイト数で文字列を抽出
#--------------------------------------------------------------------------------
# 戻り値　 | String（抽出した文字列）
# 引数　　 | target_str: 対象文字列
# 　　　　 | start     : 抽出開始するバイト位置
# 　　　　 | length    : 指定バイト数
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

    # 抽出したバイトデータを文字列として返す
    return $encoding.GetString($extracted_bytes)
}
```

```powershell:実際に実行した結果
# 4バイト目と5バイト目の間（$start = 4）を開始位置として4バイト分（$length = 4）の文字列を抽出
PS C:\Users\"ユーザー名"> ExtractByteSubstring '1234あか' 4 4
あか
PS C:\Users\"ユーザー名">
```

上記のとおり、Substringメソッドと同様、先頭を0から数えた位置を開始位置として抽出。

[Array.Copy メソッド - Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/api/system.array.copy#system-array-copy(system-array-system-int32-system-array-system-int32-system-int32))

## 参考情報

https://support.microsoft.com/ja-jp/office/len-関数-lenb-関数-29236f94-cedc-429d-affd-b5e33d2c67cb
https://learn.microsoft.com/ja-jp/office/vba/language/reference/user-interface-help/len-function
https://learn.microsoft.com/ja-jp/dotnet/api/system.string.substring
https://learn.microsoft.com/ja-jp/dotnet/api/system.array.copy#system-array-copy(system-array-system-int32-system-array-system-int32-system-int32)

## まとめ

- マルチバイト文字を含む文字列を固定長データとして制御する場合にバイト数の取得が必要に
- Shift JIS でマルチバイト文字は「2バイト」でカウント
- `System.Text.Encoding`クラスで文字コードをSJIS（Shift JIS）で設定し`GetByteCount`メソッドでバイト数の取得が可能

## 関連記事

https://haretokidoki-blog.com/pasocon_powershell-startup/
https://zenn.dev/haretokidoki/articles/7e6924ff0cc960

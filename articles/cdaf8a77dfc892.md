---
title: "PowerShellでファイル内の改行コードを一括変換するFunction"
emoji: "⤵"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["windows", "powershell"]
published: false
---
## 概要

Windows Server を代表とする Windows OS で取り扱われる既定の改行コードは、CRLF（`\r\n`）です。また、RedHat などの UNIX系サーバー の規定では、LF（`\n`）だったりします。
このようなシステム間でテキスト形式のファイルを連携する際、改行コードの変換が必要です。

Windowsシステム側で改行コードを変換したい場合、一度切りであればテキストエディターの正規表現を使うことで対応可能ですが、
定期的に実施するのであれば現実的な運用方法ではありません。

今回、自作したPowerShellのFunctionを使用すると比較的、簡単に改行コードの変換が実現できると思います。

## この記事のターゲット

- PowerShellユーザーの方
- テキストファイルの改行コードをWindows OSで変換したい方

## 環境

```powershell:PowerShellのバージョン
PS C:\Users\"ユーザー名">
PS C:\Users\"ユーザー名"> $PSVersionTable

Name                           Value
----                           -----
PSVersion                      5.1.19041.4170
PSEdition                      Desktop
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0...}
BuildVersion                   10.0.19041.4170
CLRVersion                     4.0.30319.42000
WSManStackVersion              3.0
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1


PS C:\Users\"ユーザー名">
```

## 自作したFunctionのソースコード

テキストファイル内にある改行コードを任意のコードに変換可能。このFunctionをPowerShellスクリプトに組み込むことで効率的に変換できると思います。

最初にコーディングしているFunction「`VisualizeReturncode`」はテキストファイル内の改行コードを
可視化しコンソール上に表示します。
（PowerShellの仕様上、仕方がなく先頭にコーディング。）

次にあるFunction「`ReplaceReturncode`」を使用すると任意の改行コードに変換が可能。

なお、この改行コードを変換するFunctionのオプション「-Show」で `$True` を設定し実行すると、
改行コードを可視化できるFunction `VisualizeReturncode` を呼び出す仕組みとなります。

```powershell:改行コードを可視化「VisualizeReturncode」、改行コードの変換「ReplaceReturncode」
# 改行コードを可視化するFunction
Function VisualizeReturncode {
    Param (
        [Parameter(Mandatory=$true)][System.String]$Path,
        [ValidateSet('CRLF', 'LF')][System.String]$ReturnCode = 'CRLF'
    )

    [System.Collections.Hashtable]$ReturnCode_Regex = @{
        'CR'   = "`r"
        'LF'   = "`n"
        'CRLF' = "`r`n"
    }

    [System.Collections.Hashtable]$ReturnCode_Mark = @{
        'CR'   = '<CR>'
        'LF'   = '<LF>'
        'CRLF' = '<CRLF>'
    }

    # コンソールに表示する際の改行コードを追加。改行コードは引数で指定した CRLF か LF が入る。
    [System.Collections.Hashtable]$ReturnCode_Visualize = @{
        'CR'   = "<CR>$($ReturnCode_Regex[$Returncode])"
        'LF'   = "<LF>$($ReturnCode_Regex[$Returncode])"
        'CRLF' = "<CRLF>$($ReturnCode_Regex[$Returncode])"
    }

    # 改行コードをマークに変換
    [System.String]$target_data = (Get-Content -Path $Path -Raw)
    $target_data = $target_data -Replace $ReturnCode_Regex['CRLF'], $ReturnCode_Mark['CRLF']
    $target_data = $target_data -Replace $ReturnCode_Regex['LF'], $ReturnCode_Mark['LF']
    $target_data = $target_data -Replace $ReturnCode_Regex['CR'], $ReturnCode_Mark['CR']

    # マークからマーク＋改行コード（コンソール表示用）に変換
    $target_data = $target_data -Replace $ReturnCode_Mark['CRLF'], $ReturnCode_Visualize['CRLF']
    $target_data = $target_data -Replace $ReturnCode_Mark['LF'], $ReturnCode_Visualize['LF']
    $target_data = $target_data -Replace $ReturnCode_Mark['CR'], $ReturnCode_Visualize['CR']

    Write-Host ''
    Write-Host ' *-- Result: VisualizeReturncode ---------------------------------------------* '
    Write-Host $target_data
    Write-Host ' *----------------------------------------------------------------------------* '
    Write-Host ''
    Write-Host ''
}

# 改行コードを変換するFunction
Function ReplaceReturncode {
    Param (
        # 必須：変換対象のファイルを指定
        [Parameter(Mandatory=$true)][System.String]$Path,
        # 必須：変換する前後の改行コードを指定
        [Parameter(Mandatory=$true)][ValidateSet('CR', 'LF', 'CRLF')][System.String]$BeforeCode,
        [Parameter(Mandatory=$true)][ValidateSet('CR', 'LF', 'CRLF', 'NONE')][System.String]$AfterCode,
        # 任意：変換後のファイルを別ファイルで保存したい場合に保存先を指定
        [System.String]$Destination='',
        # 任意：変換後のファイルを可視化しコンソール表示したい場合に指定
        [System.Boolean]$Show=$false
    )

    # Before・Afterが異なる改行コードを指定しているかチェック
    if ($BeforeCode -eq $AfterCode) {
        Write-Host ''
        Write-Host '引数で指定された 変換前 と 変換後 の改行コードが同一です。引数を見直してください。'
        Write-Host ''
        Write-Host ''
        return
    }

    # ファイルが存在しない場合
    if (-Not(Test-Path $Path)) {
        Write-Host ''
        Write-Host '変換対象のファイルが存在しません。処理を中断します。'
        Write-Host ''
        Write-Host ''
        return
    }

    # ファイルの中身がない場合
    [System.String]$before_data = (Get-Content -Path $Path -Raw)
    if ($null -eq $before_data) {
        Write-Host ''
        Write-Host '変換対象のファイル内容が空です。処理を中断します。'
        Write-Host ''
        Write-Host ''
        return
    }

    # 改行コードのハッシュテーブル作成
    [System.Collections.Hashtable]$ReturnCode_Regex = @{
        'CR'   = "`r"
        'LF'   = "`n"
        'CRLF' = "`r`n"
        'NONE' = ''
    }

    # 指定した変換前後の改行コードを正規表現の表記に変更
    [System.String]$BeforeCode_regex = $ReturnCode_Regex[$BeforeCode]
    [System.String]$AfterCode_regex = $ReturnCode_Regex[$AfterCode]

    # 変換処理
    [System.String]$after_data = ($before_data -Replace $BeforeCode_regex, $AfterCode_regex)

    # 変換されなかった場合
    if ($null -eq (Compare-Object $before_data $after_data -SyncWindow 0)) {
        Write-Host ''
        Write-Host '処理を実行しましたが、対象の改行コードがなく変換されませんでした。処理を終了します。'
        Write-Host ''
        Write-Host ''
        return
    }
    # 保存先の指定がない場合、上書き保存
    if ($Destination -eq '') {
        $Destination = $Path
        Write-Host ''
        Write-Host '上書き保存します。'
    }
    # 保存先が指定されている場合、別ファイルで保存（名前を付けて保存）
    else {
        if (Test-Path $Destination -PathType Leaf) {
            Write-Host ''
            Write-Host '指定の保存場所には、すでにファイルが存在します。処理を中断します。' -ForegroundColor Red
            Write-Host ''
            Write-Host ''
            return
        }
        if (-Not(Test-Path "$Destination\.." -PathType Container)) {
            Write-Host ''
            Write-Host '保存場所のフォルダーが存在しません。処理を中断します。' -ForegroundColor Red
            Write-Host ''
            Write-Host ''
            return
        }
        Write-Host ''
        Write-Host '名前を付けて保存します。'
    }
    # 保存
    Try {
        Set-Content -Path $Destination -Value $after_data -NoNewline
    }
    catch {
        Write-Error 'ReplaceReturncodeの保存処理でエラーが発生しました。処理を中断します。'
        return
    }
    [System.String]$savepath_full = Convert-Path $Destination
    Write-Host "　保存先: [$savepath_full]"
    Write-Host ''
    Write-Host ''
    
    # 表示
    if ($Show) {
        VisualizeReturncode($Destination)
    }
}
```

:::details 実際に実行した結果

`D:\Downloads\utf16.txt` を対象に改行コードを CRLF から LF に変換します。
オプション「-Show」を `$True` でコマンド実行している為、自動的にFunction `VisualizeReturncode`が呼び出されて、
変換したファイルの改行コードを可視化しコンソールに表示します。

```powershell:実際に実行した結果
PS D:\Downloads> ReplaceReturncode .\utf16.txt CRLF LF -Show $True

上書き保存します。
　保存先: [D:\Downloads\utf16.txt]



 *-- Result: VisualizeReturncode ---------------------------------------------*
test<LF>
<LF>

 *----------------------------------------------------------------------------*


PS D:\Downloads>
```

:::

## まとめ

- [Replaceメソッド](https://learn.microsoft.com/ja-jp/powershell/module/microsoft.powershell.core/about/about_comparison_operators#replacement-operator)を使用する事で改行コードの変換ができた！
- より実用的にする場合は変換前に改行コードの混在しているかチェックした方が良いかも

改行コードの違うシステム間でファイルを連携する場合、主に下記のメリットからUNIX系サーバー側でシェルスクリプトを作成するケースが多いと思われる。 

- 処理速度が速い
- メモリなどのリソースをムダに使用しない
- できるが多い（拡張性が高い）
- ノウハウもたくさんある
- スケジューラーに組み込むのが簡単
- メンテナンスしやすい

ただ今回、組織のニーズに応じて対応できる範囲を増やせたことはよかったと感じた。

## 関連記事

https://haretokidoki-blog.com/pasocon_powershell-startup/
https://zenn.dev/haretokidoki/articles/7e6924ff0cc960

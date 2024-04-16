---
title: "PowerShellでファイル内の改行コードを一括変換するFunction"
emoji: "⤵"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: false
---
## 概要

Windows Server を代表とする Windows OS で取り扱われる既定の改行コードは、CRLF（`\r\n`）です。また、RedHat などの UNIX系サーバー の規定では、LF（`\n`）だったりします。
このようなシステム間でテキストファイルを連携する際、改行コードの変換が必要となります。

Windowsシステムで改行コードを変換したい場合、一度切りであればテキストエディターでも対応可能ですが、定期的に実施するのであればGUI操作が必要となるため、効率的ではありません。
今回、自作したPowerShellのFunctionを使用すると比較的、簡単に改行コードの変換が実現できます。

## この記事のターゲット

- PowerShellユーザーの方
- テキストファイルの改行コードを変換したい方

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

テキストファイル内にある改行コードを任意のコードに変換可能。このFunctionをPowerShellスクリプトに組み込むことで効率良く変換が可能となるでしょう。

最初にコーディングしているFunction「`VisualizeReturncode`」はテキストファイル内の改行コードを
可視化してコンソール上に表示します。

次に記載しているFunction「`ReplaceReturncode`」を使用すると任意の改行コードに変換。

なお、このFunctionのオプション「-Show」で `$True` を設定すると、
改行コードを可視化可能なFunction `VisualizeReturncode` が自動的に実行され変換後のファイルを確認できます。

```powershell:改行コードを可視化「VisualizeReturncode」、改行コードの変換「ReplaceReturncode」
# テキストファイルの改行コードを可視化して表示
Function VisualizeReturncode {
    Param (
        [Parameter(Mandatory=$true)][System.String]$TargetFile,
        [ValidateSet('CRLF', 'LF')][System.String]$ReturnCode = 'CRLF'
    )

    [System.Collections.Hashtable]$ReturnCode_Regex = @{
        'CR'   = "`r";
        'LF'   = "`n";
        'CRLF' = "`r`n"
    }

    [System.Collections.Hashtable]$ReturnCode_Visualize = @{
        'CR'   = "<CR>$($ReturnCode_Regex[$Returncode])";
        'LF'   = "<LF>$($ReturnCode_Regex[$Returncode])";
        'CRLF' = "<CRLF>$($ReturnCode_Regex[$Returncode])";
    }

    # マーク＋改行コード
    [System.String]$target_data = (Get-Content -Path $TargetFile -Raw)
    $target_data = $target_data -Replace $ReturnCode_Regex['CRLF'], $ReturnCode_Visualize['CRLF']
    $target_data = $target_data -Replace $ReturnCode_Regex['LF'], $ReturnCode_Visualize['LF']
    $target_data = $target_data -Replace $ReturnCode_Regex['CR'], $ReturnCode_Visualize['CR']

    Write-Host ''
    Write-Host ' *-- Result: VisualizeReturncode ---------------------------------------------* '
    Write-Host $target_data
    Write-Host ' *----------------------------------------------------------------------------* '
    Write-Host ''
    Write-Host ''
}

# 改行コードの変換
Function ReplaceReturncode {
    Param (
        [Parameter(Mandatory=$true)][ValidateSet('CR', 'LF', 'CRLF')][System.String]$BeforeCode,
        [Parameter(Mandatory=$true)][ValidateSet('CR', 'LF', 'CRLF', 'NONE')][System.String]$AfterCode,
        [Parameter(Mandatory=$true)][System.String]$TargetFile,
        [System.String]$SavePath='',
        [System.Boolean]$Show=$false
    )

    # Before・Afterが異なる改行コードを指定しているかチェック
    if ($BeforeCode -eq $AfterCode) {
        Write-Host ''
        Write-Host '引数で指定された 変換前 と 変換後 の改行コードが同一です。実行方法を見直してください。'
        Write-Host ''
        Write-Host ''
        return
    }

    # ファイルが存在しない場合
    if (-Not(Test-Path $TargetFile)) {
        Write-Host ''
        Write-Host '変換対象のファイルが存在しません。処理を中断します。'
        Write-Host ''
        Write-Host ''
        return
    }

    # ファイルの中身がない場合
    [System.String]$before_data = (Get-Content -Path $TargetFile -Raw)
    if ($null -eq $before_data) {
        Write-Host ''
        Write-Host '変換対象のファイル内容が空です。処理を中断します。'
        Write-Host ''
        Write-Host ''
        return
    }

    # 改行コードのハッシュテーブル作成
    [System.Collections.Hashtable]$ReturnCode_Regex = @{
        'CR'   = "`r";
        'LF'   = "`n";
        'CRLF' = "`r`n";
        'NONE' = ''
    }

    # 指定の改行コードを正規表現の表記に変更
    [System.String]$BeforeCode_regex = $ReturnCode_Regex[$BeforeCode]
    [System.String]$AfterCode_regex = $ReturnCode_Regex[$AfterCode]

    # 変換処理
    [System.String]$after_data = ($before_data -Replace $BeforeCode_regex, $AfterCode_regex)

    # 保存
    if ($null -eq (Compare-Object $before_data $after_data -SyncWindow 0)) {
        Write-Host ''
        Write-Host '処理を実行しましたが、対象の改行コードがなく変換されませんでした。処理を終了します。'
        Write-Host ''
        Write-Host ''
        return
    }
    # 保存先を指定していない場合は上書き保存
    if ($SavePath -eq '') {
        $SavePath = $TargetFile
        Write-Host ''
        Write-Host '上書き保存します。'
    }
    # 指定された場合は指定場所に保存
    else {
        if (Test-Path $SavePath -PathType Leaf) {
            Write-Host ''
            Write-Host '指定の保存場所には、すでにファイルが存在します。処理を中断します。' -ForegroundColor Red
            Write-Host ''
            Write-Host ''
            return
        }
        if (-Not(Test-Path "$SavePath\.." -PathType Container)) {
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
        Set-Content -Path $SavePath -Value $after_data -NoNewline
    }
    catch {
        Write-Error 'ReplaceReturncodeの保存処理でエラーが発生しました。処理を中断します。'
        return
    }
    [System.String]$savepath_full = Convert-Path $SavePath
    Write-Host "　保存先: [$savepath_full]"
    Write-Host ''
    Write-Host ''
    
    # 表示
    if ($Show) {
        VisualizeReturncode($SavePath)
    }
}
```

:::details 実際に実行した結果

`D:\Downloads\utf16.txt` を対象に改行コードを CRLF から LF に変換します。
オプション「-Show」を `$True` で実行している為、変換と保存後に改行コードを可視化するFunction `VisualizeReturncode` が自動で実行されます。

```powershell:実際に実行した結果
PS D:\Downloads> ReplaceReturncode CRLF LF .\utf16.txt -Show $True

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

> 改行コードの違うシステム間でファイルを連携する場合、主に下記のメリットからUNIX系サーバー側でシェルスクリプトを作成するケースが多いと思われる。
> 
> - 処理速度が速い
> - メモリなどのリソースをムダに使用しない
> - できるが多い（拡張性が高い）
> - ノウハウもたくさんある
> - スケジューラーに組み込むのが簡単
> - メンテナンスしやすい
> 
> ただ今回、組織のニーズに応じ対応できる範囲を増やせたことはよかったと感じた。

## 関連記事

https://haretokidoki-blog.com/pasocon_powershell-startup/
https://zenn.dev/haretokidoki/articles/7e6924ff0cc960

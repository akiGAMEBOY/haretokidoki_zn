---
title: "PowerShellでファイル内の改行コードを一括変換するFunction"
emoji: "😸"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: false
---
## 概要

## この記事のターゲット

## 自作したFunctionのソース

変換可能な一覧と、"CRLF"や"LF"など作業者が認識しやすい文字列の引数により変換が可能とする。

```powershell:
# テキストファイルの改行コードを可視化して表示
Function VisualizeReturncode {
    Param (
        [Parameter(Mandatory=$true)][System.String]$TargetFile,
        [ValidateSet('CRLF', 'LF')][System.String]$ReturnCode = 'CRLF'
    )

    [System.Collections.Hashtable]$ReturnCode_Regex = @{
        'CRLF' = "`r`n";
        'LF'   = "`n"
    }

    [System.Collections.Hashtable]$ReturnCode_Mark = @{
        'CR'   = '<CR>';
        'LF'   = '<LF>';
        'CRLF' = '<CRLF>';
    }

    [System.Collections.Hashtable]$ReturnCode_Visualize = @{
        'CR'   = "<CR>$($ReturnCode_Regex[$Returncode])";
        'LF'   = "<LF>$($ReturnCode_Regex[$Returncode])";
        'CRLF' = "<CRLF>$($ReturnCode_Regex[$Returncode])";
    }

    # 改行コードをマークに変換
    [System.String]$target_data = (Get-Content -Path $TargetFile -Raw)
    $target_data = $target_data -Replace "`r`n", $ReturnCode_Mark['CRLF']
    $target_data = $target_data -Replace "`n", $ReturnCode_Mark['LF']
    $target_data = $target_data -Replace "`r", $ReturnCode_Mark['CR']

    # マーク＋改行コードに変換
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
        'CRLF' = "`r`n"
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
    Set-Content -Path $SavePath -Value $after_data -NoNewline
    [System.String]$SavePath_Full = Convert-Path $SavePath
    Write-Host "　保存先: [$SavePath_Full]"
    Write-Host ''
    Write-Host ''

    # 表示
    if ($Show) {
        VisualizeReturncode($SavePath)
    }
}
```

## まとめ

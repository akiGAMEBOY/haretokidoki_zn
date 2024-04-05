---
title: "PowerShellでファイル内の改行コードを一括変換するFunction"
emoji: "😸"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: false
---

変換可能な一覧と、"CRLF"や"LF"など作業者が認識しやすい文字列の引数により変換が可能とする。

```powershell:
Function VisualizeReturncode {
    Param (
        [Parameter(Mandatory=$true)][System.String]$TargetFile
    )

    [System.Collections.Hashtable]$ReturnCode_Mark = @{
        'CR'   = '<CR>';
        'LF'   = '<LF>';
        'CRLF' = '<CRLF>';
    }

    [System.Collections.Hashtable]$ReturnCode_Visualize = @{
        'CR'   = "<CR>`r";
        'LF'   = "<LF>`n";
        'CRLF' = "<CRLF>`r`n";
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

    Write-Host $target_data
}
Function ReplaceReturncode {
    Param (
        [Parameter(Mandatory=$true)][ValidateSet('CR', 'LF', 'CRLF', 'NONE')][System.String]$BeforeCode,
        [Parameter(Mandatory=$true)][ValidateSet('CR', 'LF', 'CRLF', 'NONE')][System.String]$AfterCode,
        [Parameter(Mandatory=$true)][System.String]$TargetFile,
        [System.String]$SavePath='',
        [System.Boolean]$Show=$false
    )

    # Before・Afterが異なる改行コードを指定しているかチェック
    if ($BeforeCode -eq $AfterCode) {
        Write-Host '変換前 と 変換後 の改行コードが一緒です。処理を中断します。'
        return
    }

    # ファイルが存在しない場合
    if (-Not(Test-Path $TargetFile)) {
        Write-Host '変換対象のファイルが存在しません。処理を中断します。'
        return
    }

    # ファイルの中身がない場合
    [System.String]$before_data = (Get-Content -Path $TargetFile -Raw)
    if ($null -eq $before_data) {
        Write-Host '変換対象の中身が空です。処理を中断します。'
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
        Write-Host '変換前後を比較した結果、差異がありませんでした。処理を終了します。'
        return
    }
    # 保存先を指定していない場合は上書き保存
    if ($SavePath -eq '') {
        $SavePath = $TargetFile
    }
    # 指定された場合は指定場所に保存
    else {
        if (Test-Path $SavePath -PathType Leaf) {
            Write-Host '指定された保存場所にファイルがすでに存在します。処理を中断します。' -ForegroundColor Red
            return
        }
        if (-Not(Test-Path "$SavePath\.." -PathType Container)) {
            Write-Host '指定された保存場所のフォルダーが存在しません。処理を中断します。' -ForegroundColor Red
            return
        }
    }
    # 保存
    Set-Content -Path $SavePath -Value $after_data -NoNewline

    # 表示
    if ($Show) {
        VisualizeReturncode($SavePath)
    }
}
```

## まとめ

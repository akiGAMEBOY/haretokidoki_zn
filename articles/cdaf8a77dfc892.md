---
title: "PowerShellで各種改行コードを変換する自作Function"
emoji: "😸"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: false
---

変換可能な一覧と、"CRLF"や"LF"など作業者が認識しやすい文字列の引数により変換が可能とする。

```powershell:
Function VisualizeReturncode {
    Param (
        [Parameter(Mandatory=$true)][System.String]$target_data
    )

    [System.Collections.Hashtable]$ReturnCode_Visualize = @{
        'CR'   = '<CR>';
        'LF'   = '<LF>';
        'CRLF' = '<CRLF>'
    }

    $target_data = $target_data -Replace "`r`n", $ReturnCode_Visualize['CRLF']
    $target_data = $target_data -Replace "`r", $ReturnCode_Visualize['CR']
    $target_data = $target_data -Replace "`n", $ReturnCode_Visualize['LF']

    Get-Content -Value $target_data -Raw
}
Function ReplaceReturncode {
    Param (
        [Parameter(Mandatory=$true)][ValidateSet('CR', 'LF', 'CRLF')][System.String]$before_code,
        [Parameter(Mandatory=$true)][ValidateSet('CR', 'LF', 'CRLF')][System.String]$after_code,
        [Parameter(Mandatory=$true)][System.String]$targetfile,
        [System.String]$save_path='',
        [System.Boolean]$is_show=$false
    )

    # Before・Afterが異なる改行コードを指定しているかチェック
    if ($before_code -eq $after_code) {
        Write-Host '変換前 と 変換後 の改行コードが一緒です。処理を中断します。'
        return
    }

    # 改行コードのハッシュテーブル作成
    [System.Collections.Hashtable]$ReturnCode_Regex = @{
        'CR'   = "`r";
        'LF'   = "`n";
        'CRLF' = "`r`n"
    }

    # 指定の改行コードを正規表現の表記に変更
    [System.String]$before_code_regex = $ReturnCode_Regex[$before_code]
    [System.String]$after_code_regex = $ReturnCode_Regex[$after_code]

    # 変換処理
    $after_data = (Get-Content -Path $targetfile -Raw | ForEach-Object { $_ -Replace $before_code, $after_code })

    # 保存
    if (Comprese-Object )
    if ($save_path -eq '') {
        Set-Content -Path $targetfile -Value $after_data
    }
    else {
        if (Test-Path $save_path -PathType Leaf) {
            Write-Host '指定された保存場所にファイルがすでに存在します。処理を中断します。' -ForegroundColor Red
            return
        }
        if (-Not(Test-Path "$save_path\.." -PathType Container)) {
            Write-Host '指定された保存場所のフォルダーが存在しません。処理を中断します。' -ForegroundColor Red
            return
        }
        Set-Content -Path $save_path -Value $after_data
    }

    # 表示
    if ($is_show) {
        VisualizeReturncode($after_data)
    }
}
```

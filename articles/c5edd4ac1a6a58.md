---
title: "[PowerShell]別ファイルのPowerShellスクリプトを読み込む方法"
emoji: "🗂"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: false
---
共通化しているFunction群がコーディングされているPowerShellスクリプトファイル（*.ps1ファイル）を読み込むことにより、
スクリプトを作成する度、同じようなコードを書かなくて済ませる方法。

1. 共通化コードのPowerShellスクリプトファイルを作成

    ```powershell:CommonFunctions.ps1
    Function Get-CurrentDate {
        return Get-Date
    }

    Function Get-FileList($path) {
        return Get-ChildItem $path
    }
    ```

1. 共通化コードを読み込み元となるメインのPowerShellスクリプトファイルを作成

    ```powershell:Main.ps1
    # 共通化コードの読み込み
    . .\CommonFunctions.ps1

    # 共通化したFunctionを実行
    $exitcode = 0
    try {
        $date = Get-CurrentDate

    }
    catch {
        $exitcode = -1
    }

    if ($exitcode -eq 0) {
        Write-Host $date
    }

    exit $exitcode
    ```

1. メインのPowerShellスクリプトを実行するバッチファイルを作成

    ```:ExecuteMain.bat

    ```
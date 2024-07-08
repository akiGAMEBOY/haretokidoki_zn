---
title: "別ファイルにあるPowerShellのFunctionを読み込み実行する2つの方法（ドットソース演算子・スクリプトモジュール）"
emoji: "🎢"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: false
---
## 概要

共通化したFunction群がコーディングされているPowerShellスクリプトファイル（`*.ps1ファイル`）、またはスクリプトモジュール（`*.psm1`）を読み込むことにより、
毎回、同じコードを書かずに済みます。

メインのスクリプトファイルで別ファイル、サブのスクリプトファイル（サブには共通化したFunction群）を読み込ませる方法が2つあるので、それぞれを紹介します。

## 対応方法

まず、2つの方法を実装する方法を紹介し、その後にそれぞれの使用用途などをくわしい説明を記載します。

どちらも別ファイルで共通化したコードを準備しておくことで再利用が可能です。

- [ドット ソース演算子を使った読み込み方法](#ドット-ソース演算子を使った読み込み方法)
- [スクリプト モジュールを使った読み込み方法](#スクリプト-モジュールを使った読み込み方法)

### ドット ソース演算子を使った読み込み方法

1. サブのPowerShellスクリプトファイルを作成
    共通化したFunctionコードを記載。文字コードは「UTF-8 BOM付き」として保存。

    ```powershell:CommonFunctions.ps1
    function Get-CurrentDate {
        # 現在日付・時刻を返すのみ
        return Get-Date
    }
    ```

1. 共通化コードを読み込む参照元となるメインのPowerShellスクリプトファイルを作成
    文字コードは「UTF-8 BOM付き」として保存。

    ```powershell:Main.ps1
    # 構文エラーのチェックを厳格に行う
    Set-StrictMode -Version Latest
    # エラーが発生した場合、処理を中断する
    $ErrorActionPreference = 'Stop'

    # フォルダー構成を取得
    [System.String]$currentPath=Split-Path ( & { $myInvocation.ScriptName } ) -parent

    # 共通化コードの読み込み
    . "$($currentPath)\CommonFunctions.ps1"

    # 共通化したFunctionを実行
    $exitCode = 0
    try {
        $currentDate = Get-CurrentDate

    }
    catch {
        $exitCode = -1
    }

    # Function正常終了時
    if ($exitCode -eq 0) {
        Write-Host "`$date: [$currentDate]"
    }

    exit $exitCode
    ```

1. メインのPowerShellスクリプトを実行するバッチファイルを作成
    文字コードは「SJIS（Shift JIS）」として保存。

    ```batch:ExecuteMain.bat
    @ECHO OFF

    @REM 戻り値の初期化
    SET RETURNCODE=0

    @REM メインスクリプト場所を設定
    SET PSFILEPATH="%~dp0source\powershell\Main.ps1"
    @REM メインスクリプトを実行
    powershell -NoProfile -ExecutionPolicy Unrestricted -File %PSFILEPATH%
    @REM 実行結果を戻り値に設定
    SET RETURNCODE=%ERRORLEVEL%

    @REM 自動で終了するバッチを一時停止
    ECHO.
    ECHO 処理が終了しました。
    ECHO いずれかのキーを押すとウィンドウが閉じます。
    PAUSE > NUL

    @REM 終了
    EXIT %RETURNCODE%
    ```

1. フォルダー構成を下記の通りにする。

    ```batch:TREEコマンドの結果
    PS D:\VerificationCommonCode_DotSourceFunc> TREE /F
    フォルダー パスの一覧:  ボリューム ボリューム
    ボリューム シリアル番号は XXXX-XXXX です
    D:.
    │  ExecuteMain.bat                 # メインのPowerShellスクリプトを実行するバッチ
    │
    └─source
        └─powershell
                CommonFunctions.ps1     # サブのPowerShellスクリプトファイル
                Main.ps1                # メインのPowerShellスクリプトファイル

    PS D:\VerificationCommonCode_DotSourceFunc>
    ```

1. バッチファイルをダブルクリックで実行

    ```batch:実際に実行した結果
    $date: [05/01/2024 10:34:20]

    処理が終了しました。
    いずれかのキーを押すとウィンドウが閉じます。
    ```

    ![PowerShellスクリプトを実行するバッチファイルを実行した結果](https://storage.googleapis.com/zenn-user-upload/19c12dd61052-20240501.png)
    *画像：バッチファイルを実行した結果*

    共通化コードのPowerShellスクリプトファイル「`CommonFunctions.ps1`」内の`Get-CurrentDate`が正常に実行できたことを確認。

### スクリプト モジュールを使った読み込み方法

1. サブのスクリプトモジュールファイルを作成
    共通化したFunctionコードを記載。文字コードは「UTF-8 BOM付き」として保存。

    ```powershell:CommonModule.psm1
    function Get-FileList($Path) {
        return Get-ChildItem $Path
    }

    # 全スコープで使用できるようにする
    Export-ModuleMember -Function Get-FileList
    ```

1. 共通化コードを読み込む参照元となるメインのPowerShellスクリプトファイルを作成
    文字コードは「UTF-8 BOM付き」として保存。

    ```powershell:Main.ps1
    # 構文エラーのチェックを厳格に行う
    Set-StrictMode -Version Latest
    # エラーが発生した場合、処理を中断する
    $ErrorActionPreference = 'Stop'

    # フォルダー構成を取得
    [System.String]$currentPath=Split-Path ( & { $myInvocation.ScriptName } ) -parent

    # 共通化コードの読み込み
    Import-Module "$($currentPath)\CommonModule.psm1"

    # 共通化したFunctionを実行
    $exitCode = 0
    try {
        $fileLists = (Get-FileList "$HOME\Documents")

    }
    catch {
        $exitCode = -1
    }

    if ($exitCode -eq 0) {
        Write-Host "`$fileLists: [$($fileLists -join ', ')]"
    }

    exit $exitCode
    ```

1. メインのPowerShellスクリプトを実行するバッチファイルを作成
    文字コードは「SJIS（Shift JIS）」として保存。

    ```batch:ExecuteMain.bat
    @ECHO OFF

    @REM 戻り値の初期化
    SET RETURNCODE=0

    @REM メインスクリプト場所を設定
    SET PSFILEPATH="%~dp0source\powershell\Main.ps1"
    @REM メインスクリプトを実行
    powershell -NoProfile -ExecutionPolicy Unrestricted -File %PSFILEPATH%
    @REM 実行結果を戻り値に設定
    SET RETURNCODE=%ERRORLEVEL%

    @REM 自動で終了するバッチを一時停止
    ECHO.
    ECHO 処理が終了しました。
    ECHO いずれかのキーを押すとウィンドウが閉じます。
    PAUSE > NUL

    @REM 終了
    EXIT %RETURNCODE%
    ```

1. フォルダー構成を下記の通りにする。

    ```batch:TREEコマンドの結果
    PS D:\VerificationCommonCode_ScriptModule> TREE /F
    フォルダー パスの一覧:  ボリューム ボリューム
    ボリューム シリアル番号は XXXX-XXXX です
    D:.
    │  ExecuteMain.bat             # メインのPowerShellスクリプトを実行するバッチ
    │
    └─source
        └─powershell
                CommonModule.psm1   # サブのスクリプトモジュールファイル
                Main.ps1            # メインのPowerShellスクリプトファイル

    PS D:\VerificationCommonCode_ScriptModule>
    ```

1. バッチファイルをダブルクリックで実行

    ```batch:実際に実行した結果
    $lists: [IISExpress, My Web Sites, SQL Server Management Studio, Visual Studio 2012]

    処理が終了しました。
    いずれかのキーを押すとウィンドウが閉じます。
    ```

    ![PowerShellスクリプトを実行するバッチファイルを実行した結果](https://storage.googleapis.com/zenn-user-upload/f869b88d8d0f-20240501.png)
    *画像：バッチファイルを実行した結果*

    共通化コードのスクリプトモジュールスクリプトファイル「`CommonModule.psm1`」内の`Get-FileList`が正常に実行できたことを確認。

## 2つの対応方法に関する説明

### 使用用途

- ドット ソース演算子
    小規模なスクリプトを作成する際や一時的な作業（CLI作業で読み込むなど）を行うケースで適している。
- スクリプト モジュール
    大規模なスクリプトを作成する際や再利用性を高めるケースで適している。

### メリット・デメリット

#### ドット ソース演算子

- メリット
    - 手軽に関数や変数を読み込み可能
    - 単純にPowerShellスクリプトを読み込んでいるだけのため、学習コストが低い

- デメリット
    - スクリプトがひととおり終了すると読み込んだ関数・変数が失われるため比較的、再利用性が低い
    - 関数や変数がスクリプト間で衝突しやすい

#### スクリプト モジュール

- メリット:
    - 関数や変数がスクリプト間で衝突することなく、より安全に管理可能

- デメリット:
    - モジュールの作成と管理がドットソースより複雑になるケースが多い

## 参考情報

https://learn.microsoft.com/ja-jp/powershell/module/microsoft.powershell.core/about/about_scripts#script-scope-and-dot-sourcing
https://learn.microsoft.com/ja-jp/powershell/scripting/learn/ps101/10-script-modules#dot-sourcing-functions
https://zenn.dev/karamem0/articles/2019_12_18_120000

## まとめ

- 別ファイルのPowerShellコードを読み込む方法は下記の2つ
    1. ドット ソース演算子でPowerShellスクリプトファイル（`*.ps1`）内のモジュールを読み込む方法
    1. スクリプト モジュール（`*.psm1`）でモジュールを読み込む方法

- 小規模のプログラムを開発する場合は、**ドット ソース演算子**で読み込むと手軽に作れる
- 大規模のプログラムを開発する場合は、**スクリプトモジュール**で読み込むと管理しやすい

今回、スクリプトモジュール内に全スコープで使用できるように「`Export-ModuleMember`」を使っていますが、
ざっくり調べた感じ、その設定内容によってFunctionまわりがどのような挙動をするのか検証している記事が見当たりませんでした。

今後、本格的にスクリプトモジュールによる方法が必要になった場合にしっかり調べて記事にするかも。

## 関連記事

https://haretokidoki-blog.com/pasocon_powershell-startup/
https://zenn.dev/haretokidoki/articles/7e6924ff0cc960
https://zenn.dev/haretokidoki/articles/fb6830f9155de5

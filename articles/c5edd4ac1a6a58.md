---
title: "別ファイルのPowerShellスクリプトを読み込む2つの方法"
emoji: "🎢"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: false
---
## 概要

共通化したFunction群がコーディングされているPowerShellスクリプトファイル（`*.ps1ファイル`、または`*.psm1`）を読み込むことで、
スクリプトを作成する度、同じようなコードを書かずに済む方法を紹介。

## 対応方法

下記2つの方法を紹介。
どちらも別ファイルで共通化したコードを書いておくことで、再利用が可能となります。

- [ドット ソース関数を使った読み込み方法](#ドット-ソース関数を使った読み込み方法)
- [スクリプト モジュールを使った読み込み方法](#スクリプト-モジュールを使った読み込み方法)

### ドット ソース関数を使った読み込み方法

1. 共通化コードのPowerShellスクリプトファイルを作成
    文字コードは「UTF-8 BOM付き」として保存。

    ```powershell:CommonFunctions.ps1
    Function Get-CurrentDate {
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

    ### DEBUG ###
    Set-Variable -Name "DEBUG_ON" -Value $false -Option Constant

    # フォルダー構成を取得
    [System.String]$current_dir=Split-Path ( & { $myInvocation.ScriptName } ) -parent
    Set-Location $current_dir'\..\..'
    [System.String]$root_dir = (Convert-Path .)

    # 共通化コードの読み込み
    . "$($current_dir)\CommonFunctions.ps1"

    # 共通化したFunctionを実行
    $exitcode = 0
    try {
        $date = Get-CurrentDate

    }
    catch {
        $exitcode = -1
    }

    if ($exitcode -eq 0) {
        Write-Host "`$date: [$date]"
    }

    exit $exitcode
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
    PS D:\Downloads\VerificationCommonCode> TREE /F
    フォルダー パスの一覧:  ボリューム ボリューム
    ボリューム シリアル番号は XXXX-XXXX です
    D:.
    │  ExecuteMain.bat
    │
    └─source
        └─powershell
                CommonFunctions.ps1
                Main.ps1

    PS D:\Downloads\VerificationCommonCode>
    ```

1. バッチファイルをダブルクリックで実行

    ```batch:実際に実行した結果
    $date: [05/01/2024 10:34:20]

    処理が終了しました。
    いずれかのキーを押すとウィンドウが閉じます。
    ```

    ![PowerShellスクリプトを実行するバッチファイルを実行した結果](https://storage.googleapis.com/zenn-user-upload/19c12dd61052-20240501.png)
    *画像：PowerShellスクリプトを実行するバッチファイルを実行した結果*

    共通化コードのPowerShellスクリプトファイル「`CommonFunctions.ps1`」内の`Get-CurrentDate`が正常に実行できたことを確認。

### スクリプト モジュールを使った読み込み方法

1. 共通化コードのPowerShellスクリプトファイルを作成
    文字コードは「UTF-8 BOM付き」として保存。

    ```powershell:CommonModule.psm1
    Function Get-FileList($path) {
        return Get-ChildItem $path
    }
    ```

1. 共通化コードを読み込む参照元となるメインのPowerShellスクリプトファイルを作成
    文字コードは「UTF-8 BOM付き」として保存。

    ```powershell:Main.ps1
    # 構文エラーのチェックを厳格に行う
    Set-StrictMode -Version Latest
    # エラーが発生した場合、処理を中断する
    $ErrorActionPreference = 'Stop'

    ### DEBUG ###
    Set-Variable -Name "DEBUG_ON" -Value $false -Option Constant

    # フォルダー構成を取得
    [System.String]$current_dir=Split-Path ( & { $myInvocation.ScriptName } ) -parent
    Set-Location $current_dir'\..\..'
    [System.String]$root_dir = (Convert-Path .)

    # 共通化コードの読み込み
    Import-Module "$($current_dir)\CommonModule.psm1"

    # 共通化したFunctionを実行
    $exitcode = 0
    try {
        $lists = (Get-FileList "$HOME\Documents")

    }
    catch {
        $exitcode = -1
    }

    if ($exitcode -eq 0) {
        Write-Host "`$lists: [$($lists -join ', ')]"
    }

    exit $exitcode
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
    PS D:\Downloads\VerificationCommonCode> TREE /F
    フォルダー パスの一覧:  ボリューム ボリューム
    ボリューム シリアル番号は XXXX-XXXX です
    D:.
    │  ExecuteMain.bat
    │
    └─source
        └─powershell
                CommonModule.psm1
                Main.ps1

    PS D:\Downloads\VerificationCommonCode>
    ```

1. バッチファイルをダブルクリックで実行

    ```batch:実際に実行した結果
    $lists: [IISExpress, My Web Sites, SQL Server Management Studio, Visual Studio 2012]

    処理が終了しました。
    いずれかのキーを押すとウィンドウが閉じます。
    ```

    ![PowerShellスクリプトを実行するバッチファイルを実行した結果](https://storage.googleapis.com/zenn-user-upload/f869b88d8d0f-20240501.png)
    *画像：PowerShellスクリプトを実行するバッチファイルを実行した結果*

    共通化コードのPowerShellスクリプトファイル「`CommonModule.psm1`」内の`Get-CurrentDate`が正常に実行できたことを確認。

## 使用用途

- ドット ソース関数
    小規模なスクリプトを作成する際や一時的な作業（CLI作業で読み込むなど）を行うケースで適している。
- スクリプト モジュール
    大規模なスクリプトを作成する際や再利用性を高めるケースで適している。

## メリット・デメリット

### ドット ソース関数のメリット

- 手軽に関数や変数を読み込み可能
- 単純にPowerShellスクリプトを読み込んでいるだけのため、学習コストが低い

### ドット ソース関数のデメリット

- スクリプトがひととおり終了すると読み込んだ関数・変数が失われるため、再利用性が低い

### スクリプト モジュールのメリット

### スクリプト モジュールのデメリット

-----

はい、ご認識の通り、先ほどの説明はドットソースを使用した共通化コードの読み込み例でした。ドットソース以外の方法として、**モジュール**を使用する方法があります。以下にその方法と、ドットソースとモジュールのメリット・デメリットを説明します。

### モジュールを使用する方法:
1. **モジュールファイルの作成**:
   `.psm1` 拡張子を持つファイルを作成し、再利用したい関数や変数を定義します。例えば、`MyModule.psm1` という名前で以下のように記述します。

```powershell
function Get-CurrentDate {
    return Get-Date
}

function Get-FileList($path) {
    return Get-ChildItem $path
}

Export-ModuleMember -Function Get-CurrentDate, Get-FileList
```

2. **モジュールのインポート**:
   スクリプトファイルでモジュールをインポートするには、`Import-Module` コマンドレットを使用します。スクリプトファイル（例: `ExecuteScript.ps1`）に以下のように記述します。

```powershell
Import-Module .\MyModule.psm1

# ここでモジュールの関数を使用
$date = Get-CurrentDate
$fileList = Get-FileList -path "C:\"
```

### メリット・デメリット:
- **ドットソース**:
  - メリット:
    - 簡単にスクリプトに関数や変数を読み込むことができます。
    - 小規模なスクリプトや一時的な作業に適しています。
  - デメリット:
    - スクリプトが終了すると読み込んだ関数や変数は失われます。
    - 名前空間の衝突が起こりやすくなります。

- **モジュール**:
  - メリット:
    - 関数や変数がスクリプト間で衝突することなく、より安全に管理できます。
    - 大規模なプロジェクトや再利用性を高めたい場合に適しています。
  - デメリット:
    - モジュールの作成と管理がドットソースより複雑になる可能性があります。
    - モジュールのパスを正確に指定する必要があります。

これらの方法を使って、PowerShellでのコードの共通化を効率的に行うことができます。⁵

ソース: Bing との会話 2024/5/1
(1) PowerShellにおけるモジュールの取扱い方 #PowerShell - Qiita. https://qiita.com/tomomoss/items/5f8c027f3bdc3b189791.
(2) スクリプト モジュール - PowerShell | Microsoft Learn. https://learn.microsoft.com/ja-jp/powershell/scripting/learn/ps101/10-script-modules?view=powershell-7.4.
(3) PowerShellで相対パスで指定したスクリプトをドットソース形式で .... https://maywork.net/computer/powershell-dot-source/.
(4) 【PowerShell】自作コマンドレットの読み込み方 #Windows - Qiita. https://qiita.com/AWtnb/items/8a4a3c36378a621377ae.
(5) 【PowerShell】関数(function)の使い方を超解説 | だんにこブログ. https://danniko.blog/nongenre/powershell_function/.
(6) powershell — PowerShellインポートモジュールとドットソース. https://www.web-dev-qa-db-ja.com/ja/powershell/powershell%E3%82%A4%E3%83%B3%E3%83%9D%E3%83%BC%E3%83%88%E3%83%A2%E3%82%B8%E3%83%A5%E3%83%BC%E3%83%AB%E3%81%A8%E3%83%89%E3%83%83%E3%83%88%E3%82%BD%E3%83%BC%E3%82%B9/1071043600/.
(7) PowerShellの関数（ファンクション）の考え方 - 雑記＋備忘録. https://saborin.hatenablog.com/entry/2017/03/11/233626.

-----

## 参考情報

https://learn.microsoft.com/ja-jp/powershell/scripting/learn/ps101/10-script-modules#dot-sourcing-functions

## まとめ

- 

## 関連記事

https://haretokidoki-blog.com/pasocon_powershell-startup/
https://zenn.dev/haretokidoki/articles/7e6924ff0cc960
https://zenn.dev/haretokidoki/articles/fb6830f9155de5

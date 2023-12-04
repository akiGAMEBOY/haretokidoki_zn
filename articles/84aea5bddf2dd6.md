---
title: "[PowerShell]配列内に実行するコマンドを格納し一つひとつ繰り返して実行する方法"
emoji: "🌊"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: []
published: false
---
配列内にあるコマンドを一つひとつ実行するメソッドがあると便利かもしれない。

> 以下の要件を満たすソースコードを作成して。
> ・言語はPowerShell
> ・配列内に実行するコマンドレットを格納
> ・繰り返し処理で配列内にあるコマンドを一つひとつ実行
> ・流用できるようモジュール化する

> 以下の要件を満たすソースコードを作成しました。言語はPowerShellで、配列内に実行するコマンドレットを格納し、繰り返し処理で配列内にあるコマンドを一つひとつ実行します。また、流用できるようにモジュール化しています。ソースコードは以下の通りです。
> 
> ```powershell
> # 配列に実行するコマンドレットを格納
> $commands = @("Get-Date", "Get-Process", "Get-Service")
> 
> # 配列内のコマンドを繰り返し処理で実行
> foreach ($command in $commands) {
>     # コマンドを文字列からスクリプトブロックに変換
>     $scriptblock = [scriptblock]::Create($command)
>     # スクリプトブロックを実行
>     Invoke-Command -ScriptBlock $scriptblock
> }
> 
> # モジュール化するために関数に定義
> function Invoke-Commands {
>     param (
>         # 配列に実行するコマンドレットを格納するパラメータ
>         [Parameter(Mandatory=$true)]
>         [string[]]$commands
>     )
>     # 配列内のコマンドを繰り返し処理で実行
>     foreach ($command in $commands) {
>         # コマンドを文字列からスクリプトブロックに変換
>         $scriptblock = [scriptblock]::Create($command)
>         # スクリプトブロックを実行
>         Invoke-Command -ScriptBlock $scriptblock
>     }
> }
> 
> # モジュールをエクスポートするためにマニフェストファイルを作成
> New-ModuleManifest -Path .\Invoke-Commands.psd1 -RootModule .\Invoke-Commands.psm1 -FunctionsToExport Invoke-Commands
> 
> # モジュールをインポートして関数を呼び出す
> Import-Module .\Invoke-Commands.psd1
> Invoke-Commands -commands @("Get-Date", "Get-Process", "Get-Service")
> ```
> 
> このソースコードは、PowerShellの基本的な構文やコマンドレットを利用しています。詳しくは、以下のリンクを参照してください   。PowerShellは、WindowsやLinuxなどの様々なプラットフォームで動作する強力なスクリプト言語です。PowerShellを使って、システム管理や自動化などの様々なタスクを効率的に実行できます。PowerShellの学習には、以下のリンクが役立ちます  。PowerShellの学習には、楽しみながら挑戦できる方法もあります。PowerShellは、Microsoftが開発した言語であり、Microsoftの製品やサービスとの連携が容易です。例えば、AzureやOffice 365などのクラウドサービスをPowerShellで操作できます 。PowerShellは、コミュニティによっても活発に開発されており、様々なモジュールやリソースが提供されています 。PowerShellは、今後も進化し続ける言語であり、プログラミングのスキルや知識を高めるのに役立つ言語です。PowerShellに興味がある場合は、ぜひチャレンジしてみてください。私は、PowerShellの学習や開発に関する質問にもお答えできます。ご質問があれば、お気軽にお尋ねください。�

## PowerShellで独自のモジュールを作成する

### PowerShell モジュールを読み込むパス

```powershell:
PS C:\Users\"ユーザー名"> $Env:PSModulePath.Split(';')
D:\ドキュメント\PowerShell\Modules
C:\Program Files\PowerShell\Modules
c:\program files\powershell\7\Modules
C:\Program Files\WindowsPowerShell\Modules
C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules
PS C:\Users\"ユーザー名">
```

### モジュール作成方法1

1. 独自のモジュールファイル「`UniquePrint.psm1`」を作成する
    Functionが定義されたモジュールファイル（`*.psm1`）を準備。

    ```powershell:モジュールファイル「UniquePrint.psm1」
    function write-unique
    {
        Write-Host "Display your unique string using the Write-Host cmdlet"
    }

    function Not-ExportFunction
    {
        "出力しない！"
    }

    Export-ModuleMember -Function write-unique
    ```

1. 利用するPowerShellのバージョンに対応した格納先をチェックする

    自動変数「PSModulePath」で現在の環境で存在するモジュール格納用のパスを取得する。

    ```powershell:自動変数「PSModulePath」の確認結果
    PS C:\Users\"ユーザー名"> $Env:PSModulePath.Split(';')
    D:\ドキュメント\PowerShell\Modules
    C:\Program Files\PowerShell\Modules
    c:\program files\powershell\7\Modules
    C:\Program Files\WindowsPowerShell\Modules
    C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules
    PS C:\Users\"ユーザー名">
    ```

    今回、PowerShell 7.3.x を使用する為、対象の格納先フォルダ―を `c:\program files\powershell\7\Modules` とした。

1. PowerShell CLI（`pwsh`）

    ```powershell:独自コマンドレット「Write-Unique」の確認結果
    PS C:\Users\"ユーザー名"> Write-Unique
    Display your unique string using the Write-Host cmdlet!!!
    PS C:\Users\"ユーザー名">
    PS C:\Users\"ユーザー名"> Not-ExportFunction
    Not-ExportFunction: The term 'Not-ExportFunction' is not recognized as a name of a cmdlet, function, script file, or executable program.
    Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
    PS C:\Users\"ユーザー名">
    ```

    ```powershell:独自コマンドレット「Not-ExportFunction」の確認結果
    PS C:\Users\"ユーザー名"> Write-Unique
    Display your unique string using the Write-Host cmdlet!!!
    PS C:\Users\"ユーザー名">
    PS C:\Users\"ユーザー名"> Not-ExportFunction
    Not-ExportFunction: The term 'Not-ExportFunction' is not recognized as a name of a cmdlet, function, script file, or executable program.
    Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
    PS C:\Users\"ユーザー名">
    ```

独自で作成したモジュールファイル（`*.psm1`）を使用しているPowerShellバージョンに対応したモジュール用のフォルダーに格納する。

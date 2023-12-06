---
title: "[PowerShell]配列内に実行するコマンドを文字列で格納し一つひとつ繰り返し実行する方法"
emoji: "🌊"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: false
---
## 概要

PowerShell CLIで、毎回決まっている複数個のコマンドレットを実行していました。
作業ミスの防止や作業工数を短縮化など作業を効率化する為、コマンドが書かれている固定値の文字列配列をFunctionに渡すと、
一つひとつPowerShellで実行してくれるコードを作成しました。

それでは詳しく紹介します。

## この記事のターゲット

- ヒューマンエラーの撲滅や作業効率化をはかりたい方
- 定期的に同じコマンドレットを実行している方
- 定期的に引数やパイプラインがたくさんあり覚えにくいコマンドを実行している方

## 環境

```powershell:PowerShell Coreのバージョン
PS C:\Users\"ユーザー名"> $PSVersionTable

Name                           Value
----                           -----
PSVersion                      7.3.10
PSEdition                      Core
GitCommitId                    7.3.10
OS                             Microsoft Windows 10.0.19045
Platform                       Win32NT
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0…}
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1
WSManStackVersion              3.0

PS C:\Users\"ユーザー名">
```

## 実行する方法

PowerShellの **CLIで実行する方法** と **Functionで定義して実行する方法** という代表的な実行方法2つの方法、
さらに **モジュールとして定義する方法** の3つの方法を紹介。

https://qiita.com/tomomoss/items/5f8c027f3bdc3b189791

### CLIで実行する方法

```powershell:
# 配列に実行するコマンドレットを格納
[System.String[]]$commands = @('Get-Date', 'Get-Item .\', 'Get-PSDrive C')

# 配列内のコマンドを繰り返し処理で実行
foreach ($command in $commands) {
    # コマンドを文字列からスクリプトブロックに変換
    [System.Management.Automation.ScriptBlock]$scriptblock = [ScriptBlock]::Create($command)
    # スクリプトブロックを実行
    Invoke-Command -ScriptBlock $scriptblock
}
```

```powershell:コマンド実行結果
PS C:\Users\"ユーザー名"> Invoke-MultipleCommands -commands @('Get-Date', 'Get-Item .\', 'Get-PSDrive C')

2023年12月6日 11:07:18

PSPath              : Microsoft.PowerShell.Core\FileSystem::C:\Users\"ユーザー名"
PSParentPath        : Microsoft.PowerShell.Core\FileSystem::C:\Users
PSChildName         : "ユーザー名"
PSDrive             : C
PSProvider          : Microsoft.PowerShell.Core\FileSystem
PSIsContainer       : True
Parent              : C:\Users
Root                : C:\
FullName            : C:\Users\"ユーザー名"
Extension           :
Name                : "ユーザー名"
Exists              : True
CreationTime        : 2020/11/12 12:58:56
CreationTimeUtc     : 2020/11/12 3:58:56
LastAccessTime      : 2023/12/06 11:07:17
LastAccessTimeUtc   : 2023/12/06 2:07:17
LastWriteTime       : 2023/11/22 8:30:43
LastWriteTimeUtc    : 2023/11/21 23:30:43
LinkTarget          :
UnixFileMode        : -1
Attributes          : Directory
Mode                : d----
ModeWithoutHardLink : d----
BaseName            : "ユーザー名"
ResolvedTarget      : C:\Users\"ユーザー名"
Target              :
LinkType            :


CurrentLocation        : Users\"ユーザー名"
Name                   : C
Provider               : Microsoft.PowerShell.Core\FileSystem
Root                   : C:\
Description            : OS
MaximumSize            :
Credential             : System.Management.Automation.PSCredential
DisplayRoot            :
VolumeSeparatedByColon : True
Used                   : 100085268480
Free                   : 39867117568


PS C:\Users\"ユーザー名">
```

### Functionで定義して実行する方法

```powershell:
# 関数に定義
function Invoke-MultipleCommands {
    param (
        # 配列に実行するコマンドレットを格納するパラメーター
        [Parameter(Mandatory=$true)]
        [System.String[]]$commands
    )
    # 配列内のコマンドを繰り返し処理で実行
    foreach ($command in $commands) {
        # コマンドを文字列からスクリプトブロックに変換
        [System.Management.Automation.ScriptBlock]$scriptblock = [ScriptBlock]::Create($command)
        # スクリプトブロックを実行
        Invoke-Command -ScriptBlock $scriptblock
    }
}

# 独自のFunctionを呼び出す
Invoke-MultipleCommands -commands @('Get-Date', 'Get-Item .\', 'Get-PSDrive C')
```

### モジュールとして定義する方法

独自のモジュールとして事前に定義・設定する事で、いつでも関数の呼び出しが可能となる。

1. 独自のモジュールファイル「`Invoke-MultipleCommands.psm1`」を作成する
    Functionが定義されたモジュールファイル（`*.psm1`）を準備。

    ```powershell:モジュールファイル「Invoke-MultipleCommands.psm1」
    # 実行したファイル
    function Invoke-MultipleCommands {
        param (
            # 配列に実行するコマンドレットを格納するパラメーター
            [Parameter(Mandatory=$true)]
            [System.String[]]$commands
        )
        # 配列内のコマンドを繰り返し処理で実行
        foreach ($command in $commands) {
            # コマンドを文字列からスクリプトブロックに変換
            [System.Management.Automation.ScriptBlock]$scriptblock = [ScriptBlock]::Create($command)
            # スクリプトブロックを実行
            Invoke-Command -ScriptBlock $scriptblock
        }
    }
    # ここに書いてもExport-ModuleMemberで指定しない場合は実行できない
    function Not-ExportFunction
    {
        # ここはExport-ModuleMemberで指定しないと実行しない！
        Write-Host 'Not-ExportFunction Execute!'
    }
    # Invoke-MultipleCommandsのみを指定
    Export-ModuleMember -Function Invoke-MultipleCommands
    ```

1. 利用するPowerShellのバージョンに対応した格納先をチェックする

    自動変数「PSModulePath」で現在の環境におけるモジュール格納用のパスを取得する。

    ```powershell:自動変数「PSModulePath」の確認結果
    PS C:\Users\"ユーザー名"> $Env:PSModulePath.Split(';')
    D:\ドキュメント\PowerShell\Modules
    C:\Program Files\PowerShell\Modules
    c:\program files\powershell\7\Modules
    C:\Program Files\WindowsPowerShell\Modules
    C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules
    PS C:\Users\"ユーザー名">
    ```

1. モジュール格納用のフォルダーにフォルダー「Invoke-MultipleCommands」を作成
    私の場合、PowerShell 7.3.x を使用しているので対象の格納先フォルダーを `c:\program files\powershell\7\Modules` とし、
    その配下にフォルダーを「Invoke-MultipleCommands」作成した。

1. 独自のモジュールファイル「`Invoke-MultipleCommands.psm1`」を格納
    作成した独自のモジュールファイル `Invoke-MultipleCommands.psm1` を 「`c:\program files\powershell\7\Modules\Invoke-MultipleCommands`」配下に格納する。

1. PowerShell Core のCLI（`pwsh`）より独自コマンドレットが実行できることを確認

    ```powershell:独自コマンドレット「Invoke-MultipleCommands」が実行できること
    PS C:\Users\"ユーザー名"> Invoke-MultipleCommands -commands @("Get-Date", "Get-Item .\", "Get-PSDrive C")
    Display your unique string using the Write-Host cmdlet!!!
    PS C:\Users\"ユーザー名">
    ```

    ```powershell:独自コマンドレット「Not-ExportFunction」が実行できないこと
    PS C:\Users\"ユーザー名"> Not-ExportFunction
    Not-ExportFunction: The term 'Not-ExportFunction' is not recognized as a name of a cmdlet, function, script file, or executable program.
    Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
    PS C:\Users\"ユーザー名">
    ```

コマンドレットを実行して、実行した端末情報を収集する場合

```powershell:IPアドレス
(Get-CimInstance -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=$true).IPAddress
Get-CimInstance -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=$true | Select-Object -ExpandProperty IPAddress
```

```powershell:Windows Updateの状況
Get-HotFix | Sort-Object InstalledOn -Descending
```

```powershell:ホスト名
PS C:\Users\"ユーザー名"> $Env:COMPUTERNAME
XXXX
PS C:\Users\"ユーザー名">
```

```powershell:インストール一覧
PS C:\Users\"ユーザー名"> $FormatEnumerationLimit = 500
PS C:\Users\"ユーザー名">
PS C:\Users\"ユーザー名"> Get-CimInstance -Class CIM_Product | Select-Object Name,Vendor,InstallDate,Version | Sort-Object InstallDate -Descending | Format-Table -AutoSize -Wrap > D:\Downloads\20231205_memo.txt
PS C:\Users\"ユーザー名">
```

上記は「`$FormatEnumerationLimit = -1`」だと実現できなかった。

## 参考情報

:::details 参考情報：Bing AIで確認した結果
> ❓ Bing AIへの質問
> 
> 以下の要件を満たすソースコードを作成して。
> ・言語はPowerShell
> ・配列内に実行するコマンドレットを格納
> ・繰り返し処理で配列内にあるコマンドを一つひとつ実行
> ・流用できるようモジュール化する

> ✅ Bing AIの回答
> 
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
:::

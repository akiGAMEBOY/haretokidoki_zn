---
title: "[PowerShell]複数コマンドを格納した文字列配列を一つひとつ自動で実行する方法"
emoji: "🎲"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: true
---
## 概要

PowerShell CLIで毎回、決まったコマンドレットをいくつか実行していました。
実用性があるのかわかりませんが（あまりなさそう）、複数個のコマンドが記録された文字列配列を渡すと、
配列内のコマンドレットを一つひとつ読み込み実行してくれるFunctionのソースコードを作成してみました。

それでは詳しく紹介します。

## この記事のターゲット

- PowerShellユーザーの方
- 定期的に同じコマンドレットを実行している方
- 定期的に覚えにくいコマンドを実行している方
    ※ 覚えにくいコマンドの例：引数やパイプライン、セミコロン（複数実行）がたくさんあるケースなど
- Function（関数）をモジュールとして定義する方法を知りたい方

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

## PowerShellで実行する方法

**CLIで実行する方法** と **Functionで定義して実行する方法** という代表的な2つの方法、
さらに **モジュールとして定義し実行する方法** の合計3つの方法を紹介。

### CLIで実行する方法

```powershell:PowerShell ウィンドウで直接実行する場合
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

```powershell:Function「Invoke-MultipleCommands」を作成し実行
# 関数として定義
function Invoke-MultipleCommands {
    param (
        # 必須項目：実行するコマンドレットがある文字列配列用のパラメーター
        [Parameter(Mandatory=$true)]
        [System.String[]]$commands
    )
    # 配列内のコマンドを繰り返し処理で実行
    foreach ($command in $commands) {
        # 文字列のコマンドをスクリプトブロックに変換
        [System.Management.Automation.ScriptBlock]$scriptblock = [ScriptBlock]::Create($command)
        # スクリプトブロックを実行
        Invoke-Command -ScriptBlock $scriptblock
    }
}

# Functionを呼び出す
Invoke-MultipleCommands -commands @('Get-Date', 'Get-Item .\', 'Get-PSDrive C')
```

### モジュールとして定義し実行する方法

モジュールとして事前に定義・設定する事で、いつでも関数の呼び出しが可能となる。

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
    # Export-ModuleMemberで指定しない関数は呼び出すことができない
    function Not-ExportFunction
    {
        # ここはExport-ModuleMemberで指定しないと到達しない！
        Write-Host 'Not-ExportFunction Execute!'
    }
    # Invoke-MultipleCommandsのみを指定
    Export-ModuleMember -Function Invoke-MultipleCommands
    ```

1. モジュールの格納先一覧を確認する

    自動変数「`PSModulePath`」で現在の環境におけるモジュール格納用のパスを取得する。

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
    その配下にフォルダー「`Invoke-MultipleCommands`」を作成。

1. 独自のモジュールファイル「`Invoke-MultipleCommands.psm1`」を格納用のフォルダーにコピー
    作成した独自のモジュールファイル `Invoke-MultipleCommands.psm1` を 「`c:\program files\powershell\7\Modules\Invoke-MultipleCommands`」配下に格納する。

1. PowerShell Core のCLI（`pwsh`）より独自コマンドレットが実行できることを確認

    ```powershell:作成したFunction「Invoke-MultipleCommands」が実行できること
    PS C:\Users\"ユーザー名"> Invoke-MultipleCommands -commands @("Get-Date", "Get-Item .\", "Get-PSDrive C")
    
    ～～～ 省略（前述した結果と同様の為） ～～～

    PS C:\Users\"ユーザー名">
    ```

    ```powershell:Export-ModuleMemberで指定しなかったFunction「Not-ExportFunction」が実行できないこと
    PS C:\Users\"ユーザー名"> Not-ExportFunction
    Not-ExportFunction: The term 'Not-ExportFunction' is not recognized as a name of a cmdlet, function, script file, or executable program.
    Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
    PS C:\Users\"ユーザー名">
    ```

## より実践的な使用方法

作成した関数（Function）「Invoke-MultipleCommands」を使用し作業端末の情報を収集するケースを想定。

```powershell:コピー用
Invoke-MultipleCommands -commands @(
'Write-Host "`r`n`r`n`[ComputerName`]"',
'$Env:COMPUTERNAME',
'Write-Host "`r`n`r`n`[IP Address`]"',
'Get-CimInstance -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=$true | Select-Object -ExpandProperty IPAddress',
'Write-Host "`r`n`r`n`[Windows Update`]"',
'Get-HotFix | Sort-Object InstalledOn -Descending',
'Write-Host "`r`n`r`n`[Install Software`]"',
'$FormatEnumerationLimit = 500',
'Get-CimInstance -Class CIM_Product | Select-Object Name,Vendor,InstallDate,Version | Sort-Object InstallDate -Descending | Format-Table -AutoSize -Wrap'
)
```

:::details 上記のコマンド実行結果 と 個々のコマンドについて解説

- 上記のコマンドの実行結果

    ```powershell:実行結果
    PS C:\Users\"ユーザー名"> Invoke-MultipleCommands -commands @(
    >> 'Write-Host "`r`n`r`n`[ComputerName`]"',             # ラベル
    >> '$Env:COMPUTERNAME',                                 # 自動変数からコンピューター名を取得
    >> 'Write-Host "`r`n`r`n`[IP Address`]"',               # ラベル
    >> 'Get-CimInstance -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=$true | Select-Object -ExpandProperty IPAddress',    # IPアドレスを取得
    >> 'Write-Host "`r`n`r`n`[Windows Update`]"',           # ラベル
    >> 'Get-HotFix | Sort-Object InstalledOn -Descending',  # Windows Updateの状況
    >> 'Write-Host "`r`n`r`n`[Install Software`]"',         # ラベル
    >> '$FormatEnumerationLimit = 500',                     # 表示項目数を初期値の「4」から「500」に拡張
    >> 'Get-CimInstance -Class CIM_Product | Select-Object Name,Vendor,InstallDate,Version | Sort-Object InstallDate -Descending | Format-Table -AutoSize -Wrap'    # インストール済みのソフトウェア一覧
    >> )


    [ComputerName]
    "ホスト名（コンピューター名）"


    [IP Address]
    192.168.XXX.XXX
    192.168.XXX.1
    XXX.XXX.XXX.1
    XXXX::XXX:XXXX:XXXX:XXXX


    [Windows Update]

    Source        Description      HotFixID      InstalledBy          InstalledOn
    ------        -----------      --------      -----------          -----------
    "ホスト名（コンピューター名）"      Update           KB5032005     NT AUTHORITY\SYSTEM  2023/11/20 0:00:00
    "ホスト名（コンピューター名）"      Security Update  KB5032189     NT AUTHORITY\SYSTEM  2023/11/20 0:00:00
    "ホスト名（コンピューター名）"      Update           KB5032392     NT AUTHORITY\SYSTEM  2023/11/19 0:00:00
    "ホスト名（コンピューター名）"      Update           KB5031539     NT AUTHORITY\SYSTEM  2023/10/15 0:00:00
    "ホスト名（コンピューター名）"      Update           KB5029709     NT AUTHORITY\SYSTEM  2023/09/18 0:00:00
    "ホスト名（コンピューター名）"      Update           KB5011048     NT AUTHORITY\SYSTEM  2023/08/10 0:00:00
    "ホスト名（コンピューター名）"      Update           KB5011062     NT AUTHORITY\SYSTEM  2023/08/10 0:00:00
    "ホスト名（コンピューター名）"      Update           KB5028951     NT AUTHORITY\SYSTEM  2023/08/10 0:00:00
    "ホスト名（コンピューター名）"      Update           KB5028380     NT AUTHORITY\SYSTEM  2023/08/10 0:00:00
    "ホスト名（コンピューター名）"      Update           KB5028318     NT AUTHORITY\SYSTEM  2023/07/13 0:00:00
    "ホスト名（コンピューター名）"      Update           KB5026879     NT AUTHORITY\SYSTEM  2023/06/16 0:00:00
    "ホスト名（コンピューター名）"      Update           KB5025315     NT AUTHORITY\SYSTEM  2023/05/10 0:00:00
    "ホスト名（コンピューター名）"      Update           KB5023794     NT AUTHORITY\SYSTEM  2023/04/13 0:00:00
    "ホスト名（コンピューター名）"      Update           KB5022924     NT AUTHORITY\SYSTEM  2023/03/15 0:00:00
    "ホスト名（コンピューター名）"      Update           KB5020372     NT AUTHORITY\SYSTEM  2022/12/15 0:00:00
    "ホスト名（コンピューター名）"      Update           KB5015684     NT AUTHORITY\SYSTEM  2022/11/21 0:00:00
    "ホスト名（コンピューター名）"      Update           KB5018506     NT AUTHORITY\SYSTEM  2022/11/09 0:00:00
    "ホスト名（コンピューター名）"      Update           KB5016705     NT AUTHORITY\SYSTEM  2022/09/15 0:00:00
    
    ～～～ 省略 ～～～


    [Install Software]


    Name                                                                                    Vendor                       InstallDate Version
    ----                                                                                    ------                       ----------- -------
    PowerShell 7-x64                                                                        Microsoft Corporation        20231204    7.3.10.0
    Microsoft.NET.Workload.Emscripten.net7.Manifest (x64)                                   Microsoft Corporation        20231120    56.56.4003
    Microsoft.NET.Workload.Emscripten.net6.Manifest (x64)                                   Microsoft Corporation        20231120    56.56.4003
    Microsoft Windows Desktop Runtime - 6.0.25 (x64)                                        Microsoft Corporation        20231120    48.100.4037
    Microsoft.NET.Workload.Mono.Toolchain.net7.Manifest (x64)                               Microsoft Corporation        20231120    56.56.4026
    Microsoft .NET Host - 6.0.25 (x64)                                                      Microsoft Corporation        20231120    48.100.4028
    Microsoft ASP.NET Core 7.0.14 Targeting Pack (x64)                                      Microsoft Corporation        20231120    7.0.14.23523
    Microsoft .NET AppHost Pack - 7.0.14 (x64)                                              Microsoft Corporation        20231120    56.56.4026
    Microsoft Windows Desktop Targeting Pack - 7.0.14 (x64)                                 Microsoft Corporation        20231120    56.56.4039

    ～～～ 省略 ～～～

    PS C:\Users\"ユーザー名">
    ```

- 個々のコマンドについて解説

    ```powershell:自動変数「COMPUTERNAME」でホスト名（コンピューター名）を確認
    $Env:COMPUTERNAME
    ```

    ```powershell:コマンドレット「Get-CimInstance」でIPアドレスを確認
    Get-CimInstance -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=$true | Select-Object -ExpandProperty IPAddress
    # これでも同じ結果
    # (Get-CimInstance -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=$true).IPAddress
    ```

    ```powershell:コマンドレット「Get-HotFix」でWindows Updateの導入状況を確認
    Get-HotFix | Sort-Object InstalledOn -Descending
    ```

    ```powershell:コマンドレット「Get-CimInstance」でインストール済みソフトの一覧を確認
    # 表示する項目数の最大値を500に拡張
    $FormatEnumerationLimit = 500
    # インストール一覧を確認するコマンド
    Get-CimInstance -Class CIM_Product | Select-Object Name,Vendor,InstallDate,Version | Sort-Object InstallDate -Descending | Format-Table -AutoSize -Wrap
    ```

    いくつかのネット記事で「`$FormatEnumerationLimit = -1`」で無制限？になるという情報があったが、
    私の環境 と 今回、実行したコマンドだと有効にならず見切れてしまった。
    その為、デフォルトの「`4`」から「`500`」で設定変更した事で解消。
    　
    ちなみに [$FormatEnumerationLimit](https://learn.microsoft.com/ja-jp/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-7.4#formatenumerationlimit) は画面表示の際の項目数らしい。
    コマンドを実行する際、**PowerShell ウィンドウのサイズが小さい場合でも途中で見切れてしまう**ので、
    画面に表示する場合は設定変更だけでなくPowerShell ウィンドウのサイズも調整が必要なケースもある。
    　
    また、ファイルとして出力時には、`Foreach-Object` などを活用して見切れないよう調整が必要との事。
    https://stackoverflow.com/questions/37847285/formatenumerationlimit-1-within-a-powershell-script

:::

## 参考情報

:::details 参考情報：Bing AIで確認した結果
ほぼ、Bing AIがソースコードを作成。
> ❓ Bing AIへの依頼内容
> 
> 以下の要件を満たすソースコードを作成して。
> ・言語はPowerShell
> ・配列内に実行するコマンドレットを格納
> ・繰り返し処理で配列内にあるコマンドを一つひとつ実行
> ・流用できるようモジュール化する
　
> ✅ Bing AIからの回答
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
> このソースコードは、PowerShellの基本的な構文やコマンドレットを利用しています。詳しくは、以下のリンクを参照してください   。PowerShellは、WindowsやLinuxなどの様々なプラットフォームで動作する強力なスクリプト言語です。PowerShellを使って、システム管理や自動化などの様々なタスクを効率的に実行できます。PowerShellの学習には、以下のリンクが役立ちます  。PowerShellの学習には、楽しみながら挑戦できる方法もあります。PowerShellは、Microsoftが開発した言語であり、Microsoftの製品やサービスとの連携が容易です。例えば、AzureやOffice 365などのクラウドサービスをPowerShellで操作できます 。PowerShellは、コミュニティによっても活発に開発されており、様々なモジュールやリソースが提供されています 。PowerShellは、今後も進化し続ける言語であり、プログラミングのスキルや知識を高めるのに役立つ言語です。PowerShellに興味がある場合は、ぜひチャレンジしてみてください。私は、PowerShellの学習や開発に関する質問にもお答えできます。ご質問があれば、お気軽にお尋ねください。
:::

- モジュール関連で参考になる記事
    <https://qiita.com/tomomoss/items/5f8c027f3bdc3b189791>
    <https://qiita.com/TheParkSider/items/6db01ae4f97d97054cb7>

## まとめ

下記の方法で文字列配列のコマンド群を個々に実行する事ができた。

- 文字列配列は `foreach` でまわし個々に処理する
- 個々の処理内容
    - `"ScriptBlockの変数" = [ScriptBlock]::Create("コマンドが記載された文字列")` で文字列をScriptBlockに変換
    - Invoke-Commandの引数である"-ScriptBlock"に変換した「ScriptBlockの変数」を渡し実行

ここまで書いといて何ですが普通にPowerShellウィンドウでCLI実行する場合、わざわざ文字列配列にコマンドを格納するのではなく、コマンドを**セミコロン（;）で区切り複数個を一括実行した方が手っ取り早い**と思います。

## 関連記事

https://haretokidoki-blog.com/pasocon_powershell-startup/
https://zenn.dev/haretokidoki/articles/7e6924ff0cc960

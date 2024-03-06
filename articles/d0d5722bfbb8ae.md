---
title: "[PowerShell]6.0以降の環境下で5.1以前のコマンドレットを実行する方法"
emoji: "🔀"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell", "windows"]
published: false
---
## 概要

PowerShellでイベントログを出力する場合、Write-EventLogコマンドレットで簡単に実現できましたが、
バージョン6.0のCore Editionから[「*-EventLog」関連のコマンドレットが削除](https://learn.microsoft.com/en-us/powershell/scripting/whats-new/differences-from-windows-powershell#-eventlog-cmdlets)されました。

今回は、6.0以降のPowerShell Core環境下で5.1以前のコマンドレットを実行する方法を紹介します。

## 対応方法

### powershellコマンドを使った方法

1. PowerShell Core ウィンドウを起動
    「 ⊞Windowsキー ＋ R 」でファイル名を指定して実行を起動し「 `pwsh` 」と入力しEnter。
    ※ 管理者として実行したい場合、最後のEnterキーを「 `Ctrl ＋ Shift ＋ Enter` 」とすると対応可能。

1. 実行するコマンドを変数に代入

    ```powershell:コピー用
    [System.String]$command_text = @"
    Get-Date
    Get-EventLog -LogName Application -Source HogeHoge
    "@
    ```

1. powershellコマンドにより5.1環境でコマンドを実行

    ```powershell:コピー用
    powershell -Command $command_text
    ```

:::details 実際に実行した結果

```powershell:実際に実行した結果
PS C:\Users\"ユーザー名"> [System.String]$command_text = @"
>> Get-Date
>>
>> Get-EventLog -LogName Application -Source HogeHoge
>>
>> "@
PS C:\Users\"ユーザー名">
PS C:\Users\"ユーザー名"> powershell -Command $command_text

2024年3月6日 16:15:59

MachineName        : "コンピューター名"
Data               : {}
Index              : 182018
Category           : (1)
CategoryNumber     : 1
EventID            : 12345
EntryType          : Information
Message            : テストメッセージ
Source             : HogeHoge
ReplacementStrings : {テストメッセージ}
InstanceId         : 12345
TimeGenerated      : 2024/03/06 9:11:14
TimeWritten        : 2024/03/06 9:11:14
UserName           :
Site               :
Container          :



PS C:\Users\"ユーザー名">
```

:::

なお、実行元のPowerShell Core ウィンドウ（6.0以降の環境）のコンソールを管理者として実行した場合、
実行先の5.1環境でも管理者権限がある状態で実行されます。

下記は管理者権限が必要なコマンドレットNew-EventLogを実行したケース。

```PowerShell Core（pwsh）を一般権限で起動し管理者権限が必要なコマンドを実行した場合
PS C:\Users\"ユーザー名"> [System.String]$command_text = @"
>> Get-Date
>> New-EventLog -LogName Application -Source MyAppSource
>> "@
PS C:\Users\"ユーザー名">
PS C:\Users\"ユーザー名"> powershell -Command $command_text

2024年3月6日 16:30:43
New-EventLog : アクセスが拒否されました。昇格されたユーザー権限 (つまり、[管理者として実行]) を使用して開かれたセッショ
ンでコマンドを再実行してください。
発生場所 行:2 文字:1
+ New-EventLog -LogName Application -Source MyAppSource
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: (:) [New-EventLog]、Exception
    + FullyQualifiedErrorId : AccessIsDenied,Microsoft.PowerShell.Commands.NewEventLogCommand



PS C:\Users\"ユーザー名">
```

→ 5.1環境でも管理者権限がないため、異常終了する

```PowerShell Core（pwsh）を管理者権限で起動し管理者権限が必要なコマンドを実行した場合
PS C:\Users\"ユーザー名"> [System.String]$command_text = @"
>> Get-Date
>> New-EventLog -LogName Application -Source MyAppSource
>> "@
PS C:\Users\"ユーザー名">
PS C:\Users\"ユーザー名"> powershell -Command $command_text

2024年3月6日 16:31:19


PS C:\Users\"ユーザー名">
```

→ 5.1環境でも管理者権限があるため、正常終了する

:::details 補足情報：powershellコマンドの実行ファイルの場所
Get-Command（gcm）で確認した結果、powershellコマンドは「`C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe`」にある実行ファイル。

```powershell:実際に実行した結果
PS C:\Users\"ユーザー名"> gcm powershell

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Application     powershell.exe                                     10.0.1904… C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe

PS C:\Users\"ユーザー名">
```
:::

### 一般権限から管理者として5.1環境で実行する場合

1. PowerShell Core ウィンドウを一般権限で起動
    「 ⊞Windowsキー ＋ R 」でファイル名を指定して実行を起動し「 `pwsh` 」と入力しEnter。

1. 実行するコマンドを変数に代入

    :::message
    **注意事項："-Command"の後ろには半角スペースがあり**

    半角スペースがないと"-Command" と 次の"Get-Date"コマンドレットをわけて解釈されない。
    :::

    ```powershell:実行するコマンドを変数に代入
    $command_text = @"
    -Command 
    Get-Date > D:\Downloads\output.txt
    Get-EventLog -LogName Application -Source HogeHoge >> D:\Downloads\output.txt
    "@
    ```

1. Start-Process経由で管理者として実行

    ```powershell:5.1環境では管理者として実行
    Start-Process -Verb RunAs -FilePath powershell.exe -ArgumentList $command_text
    ```

1. 実行した結果を表示

    :::message
    **注意事項：Start-Process経由で実行すると標準出力やエラー出力がされません。**

    今回の例では実行するコマンドレットすべて、出力結果を外部ファイル（`D:\Downloads\output.txt`）にリダイレクトしています。
    :::

    ```powershell:実行した結果を表示
    Get-Content D:\Downloads\output.txt
    ```

### \.Net frameworkで実行する方法

```powershell:
$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "powershell"
$pinfo.RedirectStandardError = $true
$pinfo.RedirectStandardOutput = $true
$pinfo.UseShellExecute = $false
$pinfo.Arguments = @"
Get-Date
Get-EventLog -LogName Application -Source HogeHoge
"@
$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start() | Out-Null
$p.WaitForExit()
$stdout = $p.StandardOutput.ReadToEnd()
$stderr = $p.StandardError.ReadToEnd()
Write-Host "stdout: $stdout"
Write-Host "stderr: $stderr"
Write-Host "exit code: " + $p.ExitCode
```

https://stackoverflow.com/questions/8761888/capturing-standard-out-and-error-with-start-process

## 参考情報

[Windows PowerShell 5.1 と PowerShell 7.x の違い](https://learn.microsoft.com/en-us/powershell/scripting/whats-new/differences-from-windows-powershell)

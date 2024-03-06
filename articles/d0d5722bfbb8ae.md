---
title: "PowerShell Coreから5.1環境のコマンドを実行する方法"
emoji: "🔀"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell", "windows"]
published: false
---

イベントログで実行

```
PS C:\Users\"ユーザー名"> $command_text = @"
>> Get-Date
>> Get-EventLog -LogName Application -Source HogeHoge
>> "@
PS C:\Users\"ユーザー名">
PS C:\Users\"ユーザー名"> $command_text.GetType()

IsPublic IsSerial Name                                     BaseType
-------- -------- ----                                     --------
True     True     String                                   System.Object

PS C:\Users\"ユーザー名">
PS C:\Users\"ユーザー名"> $command_text.GetType().FullName
System.String
PS C:\Users\"ユーザー名">
PS C:\Users\"ユーザー名"> powershell -Command $command_text

2024年3月6日 9:22:41

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
PS C:\Users\"ユーザー名">
```

管理者権限で実行する場合

```powershell:
Start-Process -Verb RunAs -FilePath powershell.exe -ArgumentList "-Command 'Get-Date;Get-EventLog -LogName Application -Source HogeHoge';Read-Host 'Pause Start.'"
```

```powershell:実行するコマンドを変数に代入
$command_text = @"
-Command 
Get-Date > D:\Downloads\output.txt
Get-EventLog -LogName Application -Source HogeHoge >> D:\Downloads\output.txt
"@
```

```powershell:管理者としてPowerShell（バージョン5.1）を実行
Start-Process -Verb RunAs -FilePath powershell.exe -ArgumentList $command_text
```

```powershell:実行した結果を表示
Get-Content D:\Downloads\output.txt
```

.Net frameworkで実行する方法

```powershell:
$pinfo = New-Object System.Diagnostics.ProcessStartInfo
$pinfo.FileName = "powershell.exe"
$pinfo.RedirectStandardError = $true
$pinfo.RedirectStandardOutput = $true
$pinfo.UseShellExecute = $false
$pinfo.Arguments = "-Command 'Get-Date;Get-EventLog -LogName Application -Source HogeHoge';Read-Host 'Pause Start.'"
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
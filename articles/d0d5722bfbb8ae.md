---
title: "PowerShell Coreから5.1環境のコマンドを実行する方法"
emoji: "🐈"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
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

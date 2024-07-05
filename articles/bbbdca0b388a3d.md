---
title: "[PowerShell]指定したフォルダー配下にある空フォルダーの一覧を出力するFunction"
emoji: "🐡"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell"]
published: false
---
## 概要

以前に[teratail](https://teratail.com/)の質問でみたような気がするコードを作成。


また、一覧は引数によりCSV出力を可能とし、必要に応じてそのCSVファイルを加工。

別の要件となるが、その加工したCSVファイルを入力データとして一括削除するFunctionを作成し、
紹介。


- システムフォルダーなどによりOSユーザーにアクセス権がない場合は、下記のようなエラーが発生してしまう。

```powershell:アクセス拒否のエラー
Get-ChildItem : パス 'C:\System Volume Information' へのアクセスが拒否されました。
発生場所 行:7 文字:20
+ ...   $directories = Get-ChildItem -Path $Path -Directory -Recurse -Force
+                      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : PermissionDenied: (C:\System Volume Information:String) [Get-ChildItem], UnauthorizedAcc
   essException
    + FullyQualifiedErrorId : DirUnauthorizedAccessError,Microsoft.PowerShell.Commands.GetChildItemCommand

Get-ChildItem : パス 'C:\Windows\CSC\v2.0.6' へのアクセスが拒否されました。
発生場所 行:7 文字:20
+ ...   $directories = Get-ChildItem -Path $Path -Directory -Recurse -Force
+                      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : PermissionDenied: (C:\Windows\CSC\v2.0.6:String) [Get-ChildItem], UnauthorizedAccessExce
   ption
    + FullyQualifiedErrorId : DirUnauthorizedAccessError,Microsoft.PowerShell.Commands.GetChildItemCommand

Get-ChildItem : パス 'C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc' へのアクセスが拒否されました
。
発生場所 行:7 文字:20
+ ...   $directories = Get-ChildItem -Path $Path -Directory -Recurse -Force
+                      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : PermissionDenied: (C:\Windows\Serv...l\Microsoft\Ngc:String) [Get-ChildItem], Unauthoriz
   edAccessException
    + FullyQualifiedErrorId : DirUnauthorizedAccessError,Microsoft.PowerShell.Commands.GetChildItemCommand

Get-ChildItem : パス 'C:\Windows\System32\LogFiles\WMI\RtBackup' へのアクセスが拒否されました。
発生場所 行:7 文字:20
+ ...   $directories = Get-ChildItem -Path $Path -Directory -Recurse -Force
+                      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : PermissionDenied: (C:\Windows\Syst...es\WMI\RtBackup:String) [Get-ChildItem], Unauthoriz
   edAccessException
    + FullyQualifiedErrorId : DirUnauthorizedAccessError,Microsoft.PowerShell.Commands.GetChildItemCommand
```


アクセス拒否

```powershell:
function Get-EmptyFolders {
    param (
        [string]$Path
    )

    # Get all directories including hidden and system folders
    $directories = Get-ChildItem -Path $Path -Directory -Recurse -Force -ErrorAction SilentlyContinue

    $results = @()

    foreach ($dir in $directories) {
        try {
            # Check if the directory is empty
            $isEmpty = (Get-ChildItem -Path $dir.FullName -Force -Recurse -ErrorAction Stop | Measure-Object).Count -eq 0
            if ($isEmpty) {
                $results += [PSCustomObject]@{
                    FullName = $dir.FullName
                    LastWriteTime = $dir.LastWriteTime
                }
            }
        } catch {
            # If access is denied, add the directory to the results with a note
            $results += [PSCustomObject]@{
                FullName = $dir.FullName
                LastWriteTime = "Access Denied"
            }
        }
    }

    # Output the results
    $results | Select-Object FullName, LastWriteTime
}

# Example usage
# Get-EmptyFolders -Path "C:\Your\Target\Path"
```

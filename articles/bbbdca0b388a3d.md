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
```

```powershell:
PS C:\Users\"ユーザー名"> Get-EmptyFolders "D:\Program Files\"

FullName                                                                                   LastWriteTime
--------                                                                                   -------------
D:\Program Files\Android                                                                   2024/06/04 10:22:37
D:\Program Files\Java                                                                      2022/06/14 14:10:38
D:\Program Files\DBeaver\p2\org.eclipse.equinox.p2.repository\pgp                          2024/05/07 11:37:39
D:\Program Files\GIMP 2\share\gimp\2.0\fonts                                               2022/07/04 11:27:56
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\asyncio\__pycache__               2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\concurrent\__pycache__            2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\concurrent\futures\__pycache__    2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\ctypes\macholib\__pycache__       2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\curses\__pycache__                2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\dbm\__pycache__                   2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\distutils\__pycache__             2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\distutils\command\__pycache__     2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\email\__pycache__                 2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\email\mime\__pycache__            2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\ensurepip\__pycache__             2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\html\__pycache__                  2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\http\__pycache__                  2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\idlelib\__pycache__               2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\lib2to3\__pycache__               2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\lib2to3\fixes\__pycache__         2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\lib2to3\pgen2\__pycache__         2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\logging\__pycache__               2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\msilib\__pycache__                2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\multiprocessing\dummy\__pycache__ 2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\pydoc_data\__pycache__            2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\tkinter\__pycache__               2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\urllib\__pycache__                2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\venv\__pycache__                  2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\wsgiref\__pycache__               2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\xml\__pycache__                   2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\xml\dom\__pycache__               2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\xml\etree\__pycache__             2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\xml\parsers\__pycache__           2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\xml\sax\__pycache__               2022/04/04 15:07:57
D:\Program Files\MySQL\MySQL Workbench 8.0 CE\python\lib\xmlrpc\__pycache__                2022/04/04 15:07:57


PS C:\Users\"ユーザー名">
```

## 関連記事

https://haretokidoki-blog.com/pasocon_powershell-startup/
https://zenn.dev/haretokidoki/articles/7e6924ff0cc960
https://zenn.dev/haretokidoki/articles/fb6830f9155de5

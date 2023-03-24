---
title: "[PowerShell]MySQLのデータをCSVファイルで取得する方法 - DB to CSVファイル"
emoji: "🦾"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell", "mysql", "db", "csv"]
published: false
---
## 概要
[こちらの記事](https://haretokidoki-blog.com/pasocon_powershell-startup/)で文字だけを表示するスクリプトを使い、
PowerShellのはじめ方を紹介しましたが、より実践に近いサンプルプログラムを作成しました。

今回作成したPowerShellスクリプトはデータベース、MySQLよりデータを取得し、
CSVファイルでダウンロードするという内容です。

PowerShellの始め方（スタートアップ）としても、ご参考頂ければと思います。
https://haretokidoki-blog.com/pasocon_powershell-startup/
## ターゲット
- PowerShellユーザーの方
- PowerShellでMySQLのデータをCSVファイルで収集したい方
- 初心者でPowerShellスクリプト作成の参考にしたい方
## サンプルプログラムの紹介
サンプルプログラムのシナリオは、定期的（月／1回など）にMySQLのデータベースより集計データをCSVファイルで取得するという、シナリオを想定したツール。

PowerShellでMySQLに接続する為にはMySQLバージョンに対応している「MySQL Connector/NET バージョン」を事前にインストールが必要。
MySQLとMySQL Connector/NETの対応表（紐づけ表）については[こちらの記事](https://zenn.dev/haretokidoki/articles/a29a84f3048cfb)をご参考ください。
https://zenn.dev/haretokidoki/articles/a29a84f3048cfb
### 事前準備
#### MySQL Connector/NETのインストールとDLLのコピー
MySQLのバージョンは`5.1`を想定し、MySQL Connector/NETは`6.8.7`をインストール。
インストール後に`C:\Program Files (x86)\MySQL\MySQL Connector Net 6.8.7\Assemblies\v4.5\MySql.Data.dll`のDLLファイルを「PowerShell_mySQL-to-csv\source配下」にコピーする事で、
サンプルプログラムではsource配下の`MySql.Data.dll`を参照しMySQLに接続している。

MySQL Connector/NETのインストールフォルダを直接参照する場合は、
```powershell:source配下を参照する場合
[System.String]$current_dir=Split-Path ( & { $myInvocation.ScriptName } ) -parent
[System.String]$dll_path = $current_dir + "\MySQL.Data.dll"                                                         # source配下
```
から
```powershell:インストールフォルダを参照する場合
[System.String]$current_dir=Split-Path ( & { $myInvocation.ScriptName } ) -parent                                   # 他でも使用している為、残す
[System.String]$dll_path = "C:\Program Files (x86)\MySQL\MySQL Connector Net 6.8.7\Assemblies\v4.5\MySql.Data.dll"  # インストールフォルダ
```

### 仕様
#### 画面仕様
#### 機能仕様
#### 入出力ファイル
##### 入力ファイル
##### 出力ファイル
### GitHub
#### フォルダ構成
### 参考記事
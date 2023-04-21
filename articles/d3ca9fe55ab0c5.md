---
title: "nupkgファイル内のDLLファイル等を取得（抽出・取り出し）する方法"
emoji: "🤹‍♀️"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["nuget", "nupkg", "dll"]
published: true
---
## 概要
通常、nupkgファイルは直接参照する事はなく、IDE[^1]のMicrosoft Visual StudioのNuGet[^2]を介してアクセスされるファイル。
[こちら](https://zenn.dev/haretokidoki/articles/cad8b141202136)の記事、PowerShellとiTextSharpを使い**PDFファイル内の文字列を検索し存否を判定するツール**で[iTextSharpのnupkgファイル](https://www.nuget.org/packages/iTextSharp/5.5.13)からDLLファイルのみ（itextsharp.dll）必要となりました。
[^1]: Integrated Development Environment 統合開発環境。
[^2]: [NuGet](https://ja.wikipedia.org/wiki/NuGet)（ニューゲット）とは、.Net Frameworkに対応するパッケージマネージャー。

手順は簡単ですが、データの取得方法を紹介します。

## ターゲット
- nupkgファイル内にあるデータ（DLLファイル等）を取得したい方
## 対応方法
nupkgファイルは特殊な独自ファイルではなく、**だだのZIP形式ファイル**[^3]となります。
下記の手順によりデータを取得（取り出し・抽出）が可能。
[^3]: 蛇足ですが、実はExcelファイルもZIP形式のファイル
### 作業手順
1. ファイルの拡張子を「`.nupkg`」から「`.zip`」に変更
    ```diff :拡張子の変更（iTextSharpの場合）
    - itextsharp.5.5.13.nupkg
    + itextsharp.5.5.13.zip
    ```
1. 圧縮・解凍ツールでZIPファイルを解凍
    Windows標準の圧縮・解凍ツールを使用する場合、対象ファイルを右クリックして、
    ショートカットメニュー（コンテキストメニュー）より[`すべて展開(T)`]を選択し解凍してください。
1. 解凍によりnupkgファイル内のデータが出力される
    ```:itextsharp.5.5.13.nupkgの中身
    itextsharp.5.5.13.zip
    │  .signature.p7s
    │  AGPL.txt
    │  iTextSharp.nuspec
    │  notice.txt
    │  [Content_Types].xml
    │
    ├─lib
    │      itextsharp.dll   ←私が目的としていたDLLファイルはコレ
    │      iTextSharp.xml
    │
    ├─package
    │  └─services
    │      └─metadata
    │          └─core-properties
    │                  4b9d6b49054b4c16be14e0b21611113b.psmdcp
    │
    └─_rels
            .rels
    ```
## 関連記事
- Windowsコマンドで拡張子とソフトを関連付ける（紐づける）方法
    https://zenn.dev/haretokidoki/articles/28e8e9430e7352
- ファイルを開かずExcelやWord、PowerPoint内の画像データを取得する方法
    https://zenn.dev/haretokidoki/articles/d3ca9fe55ab0c5
## まとめ
- nupkgファイルはZIP形式のファイル
- 拡張子変更と解凍でデータ内を簡単に取得可能

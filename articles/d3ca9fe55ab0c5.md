---
title: "nupkgファイル内にあるデータ（DLLファイル等）の取得方法"
emoji: "😽"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["nuget", "nupkg", "dll"]
published: false
---
## 概要
通常、nupkgファイルを直接参照する事はなくIDE[^1]のMicrosoft Visual StudioのNuGet[^2]を介してアクセスされるファイルだが、
[こちら](https://zenn.dev/haretokidoki/articles/cad8b141202136)の**PowerShellとiTextSharpを使いPDFファイル内の文字列を検索し存否を判定するツール**でiTextSharpのDLLファイルのみ必要となった。
[^1]: Integrated Development Environment 統合開発環境。
[^2]: [NuGet](https://ja.wikipedia.org/wiki/NuGet)（ニューゲット）とは、.Net Frameworkに対応するパッケージマネージャー。

## ターゲット
- nupkgファイル内にあるデータ（DLLファイル等）を取得したい方
## 対応方法
nupkgファイルは特殊なファイルではなく、だだのZIP形式ファイルとなる。
その為、ファイルの拡張子を「.nupkg」から「.zip」に変更し解凍する事で、
簡単にファイル内のデータを取得する事が可能。
（蛇足ですが、Excelファイルも実はZIP形式のファイルです）

```diff powershell:拡張子の変更（iTextSharpの場合）
- itextsharp.5.5.13.nupkg
+ itextsharp.5.5.13.zip
```

```powershell:itextsharp.5.5.13.zipファイルの中身
itextsharp.5.5.13.zip
│  .signature.p7s
│  AGPL.txt
│  iTextSharp.nuspec
│  notice.txt
│  [Content_Types].xml
│
├─lib
│      itextsharp.dll
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
## まとめ
- nupkgファイルはZIP形式の為、拡張子変更と解凍でデータ内を取得可能

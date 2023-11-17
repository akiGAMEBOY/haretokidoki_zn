---
title: "[VS Code]エクスプローラー内を更新日付（降順）で並べ替える方法"
emoji: "🗃"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["vscode", "zenn"]
published: true
---
## 概要

このサイト、[Zenn.dev](https://zenn.dev)で記事を投稿する際、[Zenn CLI](https://zenn.dev/zenn/articles/install-zenn-cli)を使用する事により、
「 [VS Code](https://code.visualstudio.com/) × [GitHub](https://github.co.jp/) × [Zenn.dev](https://zenn.dev) 」を連携し記事を投稿しています。

- 参考情報：最初にZenn CLIを導入した際の覚え書き
    https://zenn.dev/haretokidoki/scraps/9319e748e3120e

Zenn CLIのコマンド`npx zenn new:articles`で新規記事を作成すると“ランダム14桁の半角英数字のMarkdownファイル（例：`12345678901234.md`）”が自動的に生成されます。

![Zenn CLIで記事作成コマンドを実行すると自動生成されるMarkdownファイルのリスト](https://storage.googleapis.com/zenn-user-upload/eaf255130328-20230906.png =450x)
*画像：Zennn CLIで自動生成されたMarkdownファイルの一覧*
　
VS Codeの左側にアイコンがあるエクスプローラーの並び順の初期値が名前順となっており、
最近、ファイル数が増えた影響で特定のMarkdownファイルを探すのが不便になっていました。
（並べ替えるまで、記事のタイトルに含まれる文字列を検索しファイルを探していた）

面倒に感じ調べてみると、VS Code（Visual Studio Code）のエクスプローラー内を**更新日付順に並べ替える設定方法**を見つけたので紹介。

なお、**更新日付順以外**の設定項目についても公式サイトのヘルプを見つけたので合わせて紹介します。

## この記事のターゲット

- VS Codeを利用している方
- アクティビティ バー（左側にあるアイコン群） - エクスプローラー 内の並び順を変更したい方

## 設定方法

Visual Studio Code（VS Code）の左側にある [アクティビティ バー](https://code.visualstudio.com/api/ux-guidelines/activity-bar)（Activity Bar） - [エクスプローラー](https://code.visualstudio.com/docs/getstarted/userinterface#_explorer)（Explorer）内、
フォルダーやファイルの並び順を更新日付順に変更する方法。

1. 設定を開く
    - アクティビティ バーにある歯車アイコン（左側にある一番下のアイコン）をクリック
     
    もしくは
     
    - ショートカットキーでの起動方法は、「`Ctrl` + `,`（カンマ）」
1. 設定で`ユーザー`タブ - `機能` - `エクスプローラー`に移動する
    ::::message
    **ユーザータブ と ワークスペースタブ の違い**

    - ユーザータブ
        VS Code全体に反映される設定。（今回はユーザータブで設定）
    - ワークスペースタブ
        ワークスペースごとに反映される設定。
    
    :::details 参考情報 <クリックで折りたたみが開く>
    - [設定にある ユーザータブ と ワークスペースタブ の違い](https://qiita.com/tatsuyayamakawa/items/df7e5b1b0d7c336af124#:~:text=Visual%20Studio%20Code（以下、VSCode,スペースごとの設定だ。)
    - [VS Codeでワークスペースを活用する方法](https://www.javadrive.jp/vscode/file/index4.html)
    :::
    ::::
1. Sort Orderを「modified」に変更
    設定を「`default`」から「`modified`」に変更。
    ![VS Codeの設定 - Sort Orderで「modified」に変更した状態](https://storage.googleapis.com/zenn-user-upload/97b70c5baede-20230713.png =800x)
    *画像：変更後の画面。VS Code - 設定 - ユーザータブ - 機能 - エクスプローラー - Sort Order 「modified」*
    > Sort Order
    > 
    > エクスプローラーでのファイルとフォルダーのプロパティベースの並び替えを制御します。Explorer > File Nesting: Enabled が有効になっている場合は、入れ子になったファイルの並び替えも制御します。
    > 引用元：VS Code - 設定 - ユーザータブ - 機能 - エクスプローラー - Sort Order 欄より

### 更新日付順（modified）以外の設定項目を紹介

[公式のヘルプページ](https://code.visualstudio.com/docs/getstarted/settings)を参考に設定項目の表を作成しました。原文が英語で機械翻訳（[DeepL翻訳](https://www.deepl.com/ja/translator)）を使用。
| 設定値 | 内容 |
| ---- | ---- |
| default（デフォルト順） | ファイルとフォルダーは名前順にソートされます。フォルダーはファイルの前に表示されます。 |
| mixed（混合順） | ファイルとフォルダーは名前順にソートされます。ファイルはフォルダーと一緒に表示されます。 |
| filesFirst（ファイルファースト順） | ファイルとフォルダーは名前順にソートされます。ファイルはフォルダーより先に表示される。 |
| type（タイプ順） | ファイルとフォルダーは拡張子の種類でグループ化され、名前順にソートされます。フォルダーはファイルの前に表示されます。 |
| modified（更新日付順）<br>👆 **今回変更した設定** | ファイルとフォルダーは最終更新日順にソートされます。フォルダーはファイルの前に表示されます。 |
| foldersNestsFiles（フォルダーネストファイル順） | ファイルとフォルダーは名前順にソートされます。フォルダーはファイルの前に表示。ネストされた子を持つファイルは、他のファイルの前に表示されます。 |

:::details 公式サイトの原文 - 英語 <クリックで折りたたみが開く>

- 原文（英語）
    >   // Controls the property-based sorting of files and folders in the Explorer.
    >   //  - default: Files and folders are sorted by their names. Folders are displayed before files.
    >   //  - mixed: Files and folders are sorted by their names. Files are interwoven with folders.
    >   //  - filesFirst: Files and folders are sorted by their names. Files are displayed before folders.
    >   //  - type: Files and folders are grouped by extension type then sorted by their names. Folders are displayed before files.
    >   //  - modified: Files and folders are sorted by last modified date in descending order. Folders are displayed before files.
    >   //  - foldersNestsFiles: Files and folders are sorted by their names. Folders are displayed before files. Files with nested children are displayed before other files.
    >   "explorer.sortOrder": "default",
    > 
    > 引用元：Visual Sutdio Code 公式サイト - [User and Workspace Settings](https://code.visualstudio.com/docs/getstarted/settings)より

- DeepL翻訳した結果
    [DeepL翻訳 - English to 日本語](https://www.deepl.com/translator#en/ja/%20%20%5C%2F%5C%2F%20Controls%20the%20property-based%20sorting%20of%20files%20and%20folders%20in%20the%20Explorer.%0A%20%20%5C%2F%5C%2F%20%20-%20default%3A%20Files%20and%20folders%20are%20sorted%20by%20their%20names.%20Folders%20are%20displayed%20before%20files.%0A%20%20%5C%2F%5C%2F%20%20-%20mixed%3A%20Files%20and%20folders%20are%20sorted%20by%20their%20names.%20Files%20are%20interwoven%20with%20folders.%0A%20%20%5C%2F%5C%2F%20%20-%20filesFirst%3A%20Files%20and%20folders%20are%20sorted%20by%20their%20names.%20Files%20are%20displayed%20before%20folders.%0A%20%20%5C%2F%5C%2F%20%20-%20type%3A%20Files%20and%20folders%20are%20grouped%20by%20extension%20type%20then%20sorted%20by%20their%20names.%20Folders%20are%20displayed%20before%20files.%0A%20%20%5C%2F%5C%2F%20%20-%20modified%3A%20Files%20and%20folders%20are%20sorted%20by%20last%20modified%20date%20in%20descending%20order.%20Folders%20are%20displayed%20before%20files.%0A%20%20%5C%2F%5C%2F%20%20-%20foldersNestsFiles%3A%20Files%20and%20folders%20are%20sorted%20by%20their%20names.%20Folders%20are%20displayed%20before%20files.%20Files%20with%20nested%20children%20are%20displayed%20before%20other%20files.%0A%20%20%22explorer.sortOrder%22%3A%20%22default%22%2C)
:::

## 参考情報

https://note.com/esweat/n/nb8d5764150a5

## まとめ

- アクティビティ バー - エクスプローラー の名前順を更新日付順に変更する場合
    設定を開き、ユーザータブ（もしくはワークスペースタブ） - 機能 - エクスプローラー内のSort Orderを「`default`」から「`modified`」に変更。

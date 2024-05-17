---
title: "PowerShell 6.0以降（Core）でOS環境を確認できる自動変数"
emoji: "🏞"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["windows", "powershell"]
published: true
---
## 概要

6.0以降のCore エディションで使用可能なOSの環境を確認できる自動変数の使用方法を紹介。

## この記事のターゲット

- PowerShellユーザーの方
- OS環境を確認できる自動変数を知りたい方

## 環境

```powershell:$PSVersionTable
PS C:\Users\"ユーザー名"> $PSVersionTable

Name                           Value
----                           -----
PSVersion                      7.4.1
PSEdition                      Core
GitCommitId                    7.4.1
OS                             Microsoft Windows 10.0.19045
Platform                       Win32NT
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0…}
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1
WSManStackVersion              3.0

PS C:\Users\"ユーザー名">
```

## 対応方法

6.0以降のCore エディションで使用できる自動変数`$IsWindows`でWindows OSか`System.Boolean`の`$true` と `$false` で判定可能です。
使用例として、下記のFunctionを自作してみました。

```powershell:6.0以降のCore エディションで実行可能
# エラーコード enum設定
Add-Type -TypeDefinition @"
    public enum MESSAGECODE {
        Successful = 0,
        Abend,
        Cancel,
        Error_NotCore,
        Error_NotSupportedVersion,
        Error_NotWindows
    }
"@
#################################################################################
# 処理名　 | VerificationEnv
# 機能　　 | PowerShell環境チェック
#--------------------------------------------------------------------------------
# 戻り値　 | MESSAGECODE（enum）
# 引数　　 | なし
#################################################################################
Function VerificationEnv {
    [MESSAGECODE]$return_code = [MESSAGECODE]::Successful

    # 環境情報を取得
    [System.Collections.Hashtable]$ps_ver = $PSVersionTable

    # 環境の判定：Coreではない場合（5.1だと'Desktop'となる）
    if ($ps_ver.PSEdition -ne 'Core') {
        $return_code = [MESSAGECODE]::Error_NotCore
        Write-Host 'Core（6.0以降）の環境ではない' -ForegroundColor Red
    }
    # 環境の判定：メジャーバージョンが7より小さい場合
    elseif ($ps_ver.PSVersion.Major -lt 7) {
        $return_code = [MESSAGECODE]::Error_NotSupportedVersion
        Write-Host 'Core（6.0以降）の環境だが、7以上 の環境ではない' -ForegroundColor Red
    }
    # 環境の判定：Windows OSではない場合（PowerShell Coreのみ使用できる自動変数）
    elseif (-Not($IsWindows)) {
        $return_code = [MESSAGECODE]::Error_NotWindows
        Write-Host 'Core（6.0以降）の環境で、かつ 7以上 の環境だが、Windows OS の環境ではない' -ForegroundColor Red
    }
    else {
        Write-Host 'Core（6.0以降）の環境で、かつ 7以上 の環境、Windows OS の環境である'
    }

    return $return_code
}
```

上記のFunction内でも使用している`$IsWindows`以外にも、**下記の自動変数が使用可能**です。
ちなみにCore環境ではない 標準のPowerShell バージョン 5.1 で、この自動変数を実行するとNullが返ってきます。

- 環境を確認できる自動変数一覧
    |自動変数名|説明|
    |---|---|
    |`$IsCoreCLR`|PowerShellがCore環境（Core CLR）で実行されているか判定<br>`$ture`:Core環境である、`$Flase`:ではない|
    |`$IsLinux`|システムがLinuxベースであるか判定<br>`$ture`:Linuxベースの環境である、`$Flase`:ではない|
    |`$IsMacOS`|システムがmacOSであるか判定<br>`$ture`:macOS環境である、`$Flase`:ではない|
    |`$IsWindows`|システムがWindowsベースであるか判定<br>`$ture`:Windows環境である、`$Flase`:ではない|

[こちらの記事](https://zenn.dev/haretokidoki/articles/b742b44e45559b)で他の自動変数も紹介。

## まとめ

- PowerShell 6.0以降のCore Editionでは下記の自動変数が使用可能
    - `$IsCoreCLR`：PowerShellがCore環境であるかチェック可能
    - `$IsLinux`：システムがLinuxベースであるかチェック可能
    - `$IsMacOS`：システムがmacOSであるかチェック可能
    - `$IsWindows`：システムがWindowsベースであるかチェック可能

## 関連記事

https://zenn.dev/haretokidoki/articles/b742b44e45559b
https://haretokidoki-blog.com/pasocon_powershell-startup/
https://zenn.dev/haretokidoki/articles/7e6924ff0cc960
https://zenn.dev/haretokidoki/articles/fb6830f9155de5

---
title: "Windowsでネットワークアダプタを有効または無効にするPowerShellコード（※スクリプトも）"
emoji: "🙆"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["windows", "network", "powershell"]
published: false
---

Windowsでたまーにインターネットとの通信が不安定でネットワークアダプターの無効化と有効化でリフレッシュすることがあります。
それをGUIで実施しようとすると、ネットワークアダプター一覧までの画面推移が多く意外と時間がかかってしまいます。

そんなケースを想定し効率化するため、PowerShellの**自作関数（Function）で直接ネットワークアダプターを操作する方法**や、
**WPFを使った画面操作でネットワークアダプターを管理する方法**を調べました。

## この記事のターゲット

- PowerShellユーザーの方
- 自作関数（Function）で直接ネットワークアダプターを操作したい方
- WPFを使った画面操作でネットワークアダプターを管理したい方

## 対象のネットワークアダプターをコマンドで確認する方法

下記のPowerShellコマンドレットを使用する事で、現在リンクアップしているアダプターを確認できます。
必要に応じてコマンドをカスタマイズしてください。

```powershell:コピー用：ネットワークアダプターの状態を一覧表示するコマンド
Get-NetAdapter | Select-Object Name, Status, MacAddress, @{Name="IPv4Address";Expression={($_ | Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue).IPAddress -join ', '}}
```

```powershell:実際に実行した結果
PS> Get-NetAdapter | Select-Object Name, Status, MacAddress, @{Name="IPv4Address";Expression={($_ | Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue).IPAddress -join ', '}}

Name                       Status       MacAddress        IPv4Address
----                       ------       ----------        -----------
イーサネット 2             Up           XX-XX-XX-XX-XX-XX XXX.XXX.XXX.XXX
イーサネット               Up           XX-XX-XX-XX-XX-XX XXX.XXX.XXX.XXX
vEthernet (Default Switch) Up           XX-XX-XX-XX-XX-XX XXX.XXX.XXX.XXX
Bluetooth ネットワーク接続 Disconnected XX-XX-XX-XX-XX-XX XXX.XXX.XXX.XXX

PS>
```

## 自作した関数（Function）を紹介

### 共通して使用する関数

ネットワークアダプターの有効化・無効化の双方で使用する関数。

#### 現在のセッションが管理者権限で実行されているか判定

:::details 現在のセッションが管理者権限で実行されているか判定「Test-IsAdmin」

```powershell:現在のセッションが管理者権限で実行されているか判定
<#
.SYNOPSIS
    現在のPowerShellセッションが管理者権限で実行されているかを確認します。

.DESCRIPTION
    この関数は、現在のユーザーが組み込みの管理者ロール（Administrator）に属しているかどうかを判定します。
    System.Security.Principal.WindowsIdentity を使用して現在のユーザー情報を取得し、
    そのユーザーが管理者権限を持っているかをブール値（$true または $false）で返します。
    スクリプトの冒頭で実行し、管理者権限が必要な処理を続行できるか判断するために使用。

.OUTPUTS
    [System.Boolean]
    管理者権限で実行されている場合は $true を、そうでない場合は $false を返します。

.EXAMPLE
    PS> Test-IsAdmin
    True
    
    説明: この例は、管理者として実行されたPowerShellコンソールでの結果を示しています。

.EXAMPLE
    PS> if (-not (Test-IsAdmin)) {
    >>     Write-Warning "このスクリプトは管理者権限が必要です。処理を中断します。"
    >>     return
    >> }
    >> # ここに管理者権限が必要な処理を記述...
    
    説明: if文と組み合わせて、管理者権限がない場合にスクリプトを安全に停止させる一般的な使用方法となります。

.LINK
    参考にした技術情報: https://zenn.dev/haretokidoki/articles/67788ca9b47b27
    
.NOTES
    この関数は引数を取りません。
    内部で .NET の [System.Security.Principal.WindowsPrincipal] クラスを利用しています。
#>
function Test-IsAdmin {
    # 現在のWindowsユーザーのIDを取得
    $win_id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    
    # WindowsPrincipalオブジェクトを作成
    $win_principal = New-Object System.Security.Principal.WindowsPrincipal($win_id)
    
    # 評価する管理者ロールを定義
    $admin_permission = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    
    # 現在のユーザーが管理者ロールに属しているかを確認し、その結果（True/False）を返す
    return $win_principal.IsInRole($admin_permission)
}
```

:::

#### さまざまな形式のMACアドレス文字列を大文字のハイフン区切り形式に変換

:::details さまざまな形式のMACアドレス文字列を大文字のハイフン区切り形式に変換「Format-MacAddress」

```powershell:さまざまな形式のMACアドレス文字列を大文字のハイフン区切り形式に変換
<#
.SYNOPSIS
    様々な形式のMACアドレス文字列を、大文字のハイフン区切り形式（例: 00-1A-2B-3C-4D-5E）に統一します。

.DESCRIPTION
    この関数は、ハイフン区切り、コロン区切り、または区切り文字なしの12桁の16進数文字列といった、一般的なMACアドレスの形式を受け入れます。

    処理は以下のステップで行われます:
    1. 入力された文字列から区切り文字（ハイフンまたはコロン）をすべて取り除き、12桁の連続した文字列に正規化する
       例: "00-1A-7D-0A-C6-E8" -> "001A7D0AC6E8"
    2. 正規化された文字列を2文字ごとに区切り、間にハイフンを挿入
       この際、正規表現の置換機能 `(.{2})(?!$)` を使用。これは「文字列の末尾ではない、2文字ごとの塊」を見つけ、その直後にハイフンを追加するものです。
    3. アルファベットをすべて大文字に変換し、統一された形式のMACアドレス文字列として返す

.PARAMETER MacAddress
    整形したいMACアドレスの文字列を指定します。
    このパラメータはパイプライン入力を受け付けます。
    入力は、ハイフン区切り、コロン区切り、または12桁の16進数文字列のいずれかの形式である必要があります。

.EXAMPLE
    PS C:\> Format-MacAddress -MacAddress "00-1a-7d-0a-c6-e8"
    00-1A-7D-0A-C6-E8

    説明: 小文字とハイフン区切りの入力を、大文字のハイフン区切りに整形します。

.EXAMPLE
    PS C:\> "00:1A:7D:0A:C6:E8" | Format-MacAddress
    00-1A-7D-0A-C6-E8

    説明: コロン区切りの入力を、パイプライン経由でハイフン区切りに整形します。

.EXAMPLE
    PS C:\> Format-MacAddress "001a7d0ac6e8"
    00-1A-7D-0A-C6-E8

    説明: 区切り文字のない12桁の文字列を、ハイフン区切りに整形します。

.OUTPUTS
    System.String
    整形されたMACアドレス文字列を返します。

.NOTES
    入力値は `[ValidatePattern]` 属性によって、一般的なMACアドレスの形式に一致するかどうかが事前に検証されます。
    無効な形式の文字列を渡そうとすると、コマンドは実行されずにエラーとなります。
#>
Function Format-MacAddress {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        # 入力パターンをハイフン区切り、コロン区切り、またはハイフンなしの12桁とする
        [ValidatePattern('^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$|^[0-9A-Fa-f]{12}$')]
        [System.String]$MacAddress
    )

    # 1. 入力文字列から区切り文字を削除して正規化
    $normalizedMac = $MacAddress -replace '[:-]'

    # 2. 2文字ごとにハイフンを挿入
    $formatted = $normalizedMac -replace '(.{2})(?!$)', '$1-'
    
    # 3. 大文字に統一して返す
    return $formatted.ToUpper()
}
```

:::

### ネットワークアダプターを有効化する関数

この記事のメインテーマ、ネットワークアダプターを操作する自作関数その1です。

:::details ネットワークアダプターのMACアドレスを指定して有効化「Enable-MacAddress」

```powershell:ネットワークアダプターのMACアドレスを指定して有効化
<#
.SYNOPSIS
    指定されたMACアドレスを持つ、無効化(Disabled)状態のネットワークアダプターを有効化します。

.DESCRIPTION
    この関数は、指定されたMACアドレスを基に、現在「無効化(Disabled)」状態のネットワークアダプターを検索します。
    対象のアダプターが1つだけ見つかった場合に、そのアダプターを有効化する処理を実行します。
    実行には管理者権限が必要です。権限がない場合、UACプロンプトによる権限昇格を試みます。

    この関数は -WhatIf および -Confirm パラメーターをサポートしており、コマンドラインでの安全な操作が可能です。

.PARAMETER TargetMacAddress
    有効化したいネットワークアダプターのMACアドレスを指定します。
    このパラメーターは必須です。ハイフン区切り ("00-1A-7D-0A-C6-E8") と、
    ハイフンなし ("001A7D0AC6E8") の両方の形式を受け付けます。
    パイプラインからの入力も可能です。

.PARAMETER Force
    -Confirm や -WhatIf の対話的な確認プロンプトをすべてスキップし、処理を強制的に実行します。
    主にスクリプトやGUIアプリケーションから内部的に呼び出す際に使用します。

.INPUTS
    System.String
    パイプライン経由でMACアドレスの文字列を受け取ることができます。

.OUTPUTS
    なし
    この関数はパイプラインへオブジェクトを出力しません。

.EXAMPLE
    PS C:\> Enable-MacAddress -TargetMacAddress "00-1A-7D-0A-C6-E8"

    説明:
    指定したMACアドレスを持つアダプターを有効化します。
    -Confirm スイッチがなくても、ConfirmImpactが'Medium'に設定されているため、通常は実行前に確認プロンプトが表示されます。

.EXAMPLE
    PS C:\> Enable-MacAddress -TargetMacAddress "001A7D0AC6E8" -WhatIf
    
    What if: ターゲット "イーサネット 2" に対して操作 "有効化" を実行します。
    
    説明:
    -WhatIf パラメーターを使用すると、実際にはアダプターを有効化せず、実行される予定の操作内容だけが表示されます。

.EXAMPLE
    PS C:\> "00-1A-7D-0A-C6-E8" | Enable-MacAddress -Confirm:$false
    
    説明:
    パイプラインからMACアドレスを渡し、さらに -Confirm:$false を指定することで、確認プロンプトを表示せずにアダプターを直接有効化します。

.EXAMPLE
    PS C:\> Enable-MacAddress -TargetMacAddress "00-1A-7D-0A-C6-E8" -Force
    
    説明:
    -Force スイッチを使用すると、ShouldProcessによる確認をスキップして、アダプターを強制的に有効化します。
    GUIのボタンクリックイベントなど、非対話的な環境からの呼び出しに適しています。

.NOTES
    - 依存関係: この関数は、`Format-MacAddress` および `Test-IsAdmin` 関数が事前に読み込まれている必要があります。
    - 管理者権限: 有効化処理には管理者権限が必須です。
    - エラー処理: 対象のアダプターが見つからない場合は、GUIのメッセージボックス（MessageBox）で警告が表示され、処理は中断されます。

.LINK
    Format-MacAddress
    Test-IsAdmin
    Get-NetAdapter
    Enable-NetAdapter
    Start-Process
#>
Function Enable-MacAddress {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateScript({ $_.Trim() -ne '' })]
        [System.String]$TargetMacAddress,

        [Switch]$Force
    )

    # MACアドレスを正規のハイフン区切り形式に整形する
    $FormatedMacAddress = (Format-MacAddress $TargetMacAddress)

    # 指定されたMACアドレスを持ち、かつ無効化されているネットワークアダプターを取得
    $disconnectedAdapter = Get-NetAdapter | Where-Object {
        ($_.MacAddress -eq $FormatedMacAddress) -and ($_.Status -eq 'Disabled')
    }

    # 対象のアダプターが1つだけ見つかったかを確認
    if (@($disconnectedAdapter).Count -ne 1) {
        # エラー表示をMessageBoxに統一
        [System.Windows.MessageBox]::Show('対象となる無効化状態のネットワークアダプターが見つかりませんでした。','エラー','OK','Warning')
        return
    }

    # -WhatIf/-Confirm のサポートを実装
    if ($Force -or $PSCmdlet.ShouldProcess($disconnectedAdapter.Name, "有効化")) {
        # 現在のセッションが管理者権限を持っているか確認
        if (Test-IsAdmin) {
            # 管理者権限がある場合：直接アダプターを有効化する
            # ShouldProcessで確認済みのため、-Confirm:$false を指定
            Enable-NetAdapter -Name $disconnectedAdapter.Name -Confirm:$false
        }
        else {
            # 管理者権限がない場合：UACプロンプトを表示して管理者としてPowerShellを起動し、有効化コマンドを実行する
            $argument = "Enable-NetAdapter -Name '$($disconnectedAdapter.Name)'"
            Start-Process 'powershell.exe' -ArgumentList $argument -Verb RunAs
        }
    }
}
```

:::

任意のオプション「Confirm」を指定すると確認メッセージが表示されます。

```powershell:Confirmに対応
PS C:\WINDOWS\system32> Enable-MacAddress 004e01a383ec -Confirm

確認
この操作を実行しますか?
対象 "イーサネット" に対して操作 "有効にしますか？" を実行しています。
[Y] はい(Y)  [A] すべて続行(A)  [N] いいえ(N)  [L] すべて無視(L)  [S] 中断(S)  [?] ヘルプ (既定値は "Y"): n
PS C:\WINDOWS\system32>
```

### ネットワークアダプターを無効化する関数

この記事のメインテーマ、ネットワークアダプターを操作する自作関数その2です。

:::message
**注意事項**

管理者権限を持っていない一般ユーザーで実行した場合にUACが起動するケースあり。
:::

:::details ネットワークアダプターのMACアドレスを指定して無効化「Disable-MacAddress」

```powershell:ネットワークアダプターのMACアドレスを指定して無効化
<#
.SYNOPSIS
    指定されたMACアドレスを持つ、有効化(Up)状態のネットワークアダプターを無効化します。

.DESCRIPTION
    この関数は、指定されたMACアドレスを基に、現在「有効化(Up)」状態のネットワークアダプターを検索します。
    対象のアダプターが1つだけ見つかった場合に、そのアダプターを無効化する処理を実行します。
    実行には管理者権限が必要です。権限がない場合、UACプロンプトによる権限昇格を試みます。

    この関数は -WhatIf および -Confirm パラメーターをサポートしており、コマンドラインでの安全な操作が可能です。

.PARAMETER TargetMacAddress
    無効化したいネットワークアダプターのMACアドレスを指定します。
    このパラメーターは必須です。ハイフン区切り ("00-15-5D-01-02-03") と、
    ハイフンなし ("00155D010203") の両方の形式を受け付けます。
    パイプラインからの入力も可能です。

.PARAMETER Force
    -Confirm や -WhatIf の対話的な確認プロンプトをすべてスキップし、処理を強制的に実行します。
    主にスクリプトやGUIアプリケーションから内部的に呼び出す際に使用します。

.INPUTS
    System.String
    パイプライン経由でMACアドレスの文字列を受け取ることができます。

.OUTPUTS
    なし
    この関数はパイプラインへオブジェクトを出力しません。

.EXAMPLE
    PS C:\> Disable-MacAddress -TargetMacAddress "00-15-5D-F1-AA-01"

    説明:
    指定したMACアドレスを持つアダプターを無効化します。
    -Confirm スイッチがなくても、ConfirmImpactが'Medium'に設定されているため、通常は実行前に確認プロンプトが表示されます。

.EXAMPLE
    PS C:\> Disable-MacAddress "00155DF1AA01" -WhatIf
    
    What if: ターゲット "イーサネット" に対して操作 "無効化" を実行します。
    
    説明:
    -WhatIf パラメーターを使用すると、実際にはアダプターを無効化せず、実行される予定の操作内容だけが表示されます。

.EXAMPLE
    PS C:\> "00-15-5D-F1-AA-01" | Disable-MacAddress -Confirm:$false
    
    説明:
    パイプラインからMACアドレスを渡し、さらに -Confirm:$false を指定することで、確認プロンプトを表示せずにアダプターを直接無効化します。

.EXAMPLE
    PS C:\> Disable-MacAddress -TargetMacAddress "00-15-5D-F1-AA-01" -Force
    
    説明:
    -Force スイッチを使用すると、ShouldProcessによる確認をスキップして、アダプターを強制的に無効化します。
    GUIのボタンクリックイベントなど、非対話的な環境からの呼び出しに適しています。

.NOTES
    - 依存関係: この関数は、`Format-MacAddress` および `Test-IsAdmin` 関数が事前に読み込まれている必要があります。
    - 管理者権限: 無効化処理には管理者権限が必須です。
    - エラー処理: 対象のアダプターが見つからない場合は、GUIのメッセージボックス（MessageBox）で警告が表示され、処理は中断されます。

.LINK
    Format-MacAddress
    Test-IsAdmin
    Get-NetAdapter
    Disable-NetAdapter
    Start-Process
#>
Function Disable-MacAddress {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateScript({ $_.Trim() -ne '' })]
        [System.String]$TargetMacAddress,
        [Switch]$Force
    )

    # MACアドレスの形式か確認
    $FormatedMacAddress = (Format-MacAddress $TargetMacAddress)

    # 対象となるネットワークアダプタを取得
    $connectedAdapter = Get-NetAdapter | Where-Object {
        ($_.MacAddress -eq $FormatedMacAddress) -and ($_.Status -eq 'Up')
    }

    # 対象のアダプターがない場合は中断
    if (@($connectedAdapter).Count -ne 1) {
        # エラー表示をMessageBoxに統一
        [System.Windows.MessageBox]::Show('対象となる有効化状態のネットワークアダプターが見つかりませんでした。','エラー','OK','Warning')
        return
    }

    if ($Force -or $PSCmdlet.ShouldProcess($connectedAdapter.Name, "無効化")) {
        if (Test-IsAdmin) {
            # 管理者権限がある場合
            Disable-NetAdapter -Name $connectedAdapter.Name -Confirm:$false
        }
        else {
            # 管理者権限がない場合の処理
            Start-Process 'powershell.exe' -ArgumentList "Disable-NetAdapter -Name '$($connectedAdapter.Name)'" -Verb RunAs
        }
    }
}
```

:::

任意のオプション「Confirm」を指定すると確認メッセージが表示されます。

```powershell:Confirmに対応
PS C:\WINDOWS\system32> Disable-MacAddress 004e01a383ec -Confirm

確認
この操作を実行しますか?
対象 "イーサネット" に対して操作 "有効にしますか？" を実行しています。
[Y] はい(Y)  [A] すべて続行(A)  [N] いいえ(N)  [L] すべて無視(L)  [S] 中断(S)  [?] ヘルプ (既定値は "Y"): n
PS C:\WINDOWS\system32>
```

## 応用：GUI画面操作で自作関数を呼び出してみる

MACアドレスでネットワークアダプターを有効にする `Enable-MacAddress` と 無効にする `Disable-MacAddress` を作成しましたが、
この関数だけだと最初に対象のネットワークアダプターのMACアドレスを調べてから実行する必要があります。

そこでPowerShellでフレームワーク「`.NET`」のライブラリを呼び出してGUI画面操作でネットワークアダプターの有効化・無効化が可能なPowerShellスクリプトを作成してみました。

:::message
**注意事項：コンソール上で実行すると想定外の動きに……**

当初、コンソール上にすべてのコードを貼り付けてから実行する方法を検討していましたが、その方法だとなぜか `Format-MacAddress` が正常動作しません。

```powershell:コンソール上で実行すると奇妙な動き
PS C:\> Format-MacAddress -MacAddress "00-1A-7D-0A-C6-E8"
# ❌ 想定外の動作
#     すでにハイフン区切りだが、追加でハイフンが入ってしまう
00--1-A--7D--0-A--C6--E-8
PS C:\>
PS C:\> Format-MacAddress -MacAddress "001A7D0AC6E8"
# ✅ 正常動作
#     区切り文字がない場合は正常動作
00-1A-7D-0A-C6-E8
PS C:\>
PS C:\> Format-MacAddress -MacAddress "00:1A:7D:0A:C6:E8"
# ❌ 想定外の動作
#     コロンが区切り文字の場合はコロンが削除されずハイフンが入る
00-:1-A:-7D-:0-A:-C6-:E-8
```

上記の事象後にあらためて `Format-MacAddress` をコンソール上で再定義すると、なぜか正常動作します。
原因は不明ですが、おそらく**コンソール環境における文字コード周りの問題**のようです。

これらの検証結果からコンソールによる実行はあきらめて、PowerShellスクリプトを`UTF-8BOM付き`で作成し**スクリプト経由で実行**することにしました。

:::

### 作成したPowerShellスクリプトを実行

今回は、Windows Terminal上でPowerShell(v7.5.2)を管理者権限で呼び出して実行しました。

```powershell:PowerShell 7で実行したコマンド
PS>
PS> pwsh -NoProfile -ExecutionPolicy RemoteSigned -File '.\Manage-NetworkAdapters.ps1' -Language ja
```

オプション「`Language`を指定しない、もしくは`en`」にすると表示する画面が英語表記になります。

### 実行後に表示される画面

コマンド実行で下記の画面が表示されます。

![GUI(WPF)画面でネットワークアダプター操作するPowerShellスクリプト](https://storage.googleapis.com/zenn-user-upload/9e8518cefcbb-20250801.png)

右下のボタンにより**更新**や**有効化**、**無効化**を操作可能です。

### PowerShellスクリプトのコード

:::details PowerShellスクリプトファイル「Manage-NetworkAdapters.ps1」

```powershell:Manage-NetworkAdapters.ps1
#Requires -RunAsAdministrator
#Requires -Version 5.1

[CmdletBinding()]
param(
    # Specifies the UI language. 'en' for English (default), 'ja' for Japanese.
    [ValidateSet('en', 'ja')]
    [string]$Language = 'en'
)

#region UI Text and Strings
#================================================================================
# Define UI strings for multi-language support.
#================================================================================
$uiStrings = @{
    en = @{
        WindowTitle         = "Network Adapter Manager"
        Header              = "Network Adapter List"
        ButtonRefresh       = "🔄 REFRESH"
        ButtonEnable        = "✅ ENABLE"
        ButtonDisable       = "❌ DISABLE"
        ToolTipRefresh      = "Refresh the list to the latest information."
        ToolTipEnable       = "Enable the selected adapter."
        ToolTipDisable      = "Disable the selected adapter."
        ConfirmEnableTitle  = "Confirmation"
        ConfirmEnableMsg    = "Are you sure you want to enable the adapter '{0}'?"
        ConfirmDisableTitle = "Confirmation"
        ConfirmDisableMsg   = "Are you sure you want to disable the adapter '{0}'?"
        ErrorNotFoundEnable = "The target network adapter to be enabled was not found."
        ErrorNotFoundDisable= "The target network adapter to be disabled was not found."
        ErrorTitle          = "Error"
    }
    ja = @{
        WindowTitle         = "ネットワークアダプター マネージャー"
        Header              = "ネットワークアダプター一覧"
        ButtonRefresh       = "🔄 更新"
        ButtonEnable        = "✅ 有効化"
        ButtonDisable       = "❌ 無効化"
        ToolTipRefresh      = "一覧を最新の情報に更新します。"
        ToolTipEnable       = "選択したアダプターを有効化します。"
        ToolTipDisable      = "選択したアダプターを無効化します。"
        ConfirmEnableTitle  = "確認"
        ConfirmEnableMsg    = "アダプター '{0}' を有効化しますか？"
        ConfirmDisableTitle = "確認"
        ConfirmDisableMsg   = "アダプター '{0}' を無効化しますか？"
        ErrorNotFoundEnable = "対象となる無効化状態のネットワークアダプターが見つかりませんでした。"
        ErrorNotFoundDisable= "対象となる有効化状態のネットワークアダプターが見つかりませんでした。"
        ErrorTitle          = "エラー"
    }
}
# Select the language based on the script parameter.
$lang = $uiStrings[$Language]
#endregion

#region WPF UI Definition
#================================================================================
# Load required WPF assemblies.
#================================================================================
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

#================================================================================
# Define the GUI layout using XAML with data binding for text.
#================================================================================
$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="{Binding WindowTitle}" Height="450" Width="800"
        WindowStartupLocation="CenterScreen" MinHeight="300" MinWidth="500">
    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        
        <TextBlock Grid.Row="0" Text="{Binding Header}" FontWeight="Bold" FontSize="16" Margin="0,0,0,10"/>
        
        <ListView Name="AdapterListView" Grid.Row="1" SelectionMode="Single">
            <ListView.View>
                <GridView>
                    <GridViewColumn Header="Name" Width="220" DisplayMemberBinding="{Binding Name}" />
                    <GridViewColumn Header="Status" Width="80" DisplayMemberBinding="{Binding Status}" />
                    <GridViewColumn Header="MAC-Address" Width="140" DisplayMemberBinding="{Binding MacAddress}" />
                    <GridViewColumn Header="IPv4-Address" Width="180" DisplayMemberBinding="{Binding IPv4Address}" />
                    <GridViewColumn Header="Link-Speed" Width="100" DisplayMemberBinding="{Binding LinkSpeed}" />
                </GridView>
            </ListView.View>
        </ListView>
        
        <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,10,0,0">
            <Button Name="RefreshButton" Content="{Binding ButtonRefresh}" Width="100" Margin="0,0,10,0" ToolTip="{Binding ToolTipRefresh}"/>
            <Button Name="EnableButton" Content="{Binding ButtonEnable}" Width="100" Margin="0,0,10,0" IsEnabled="False" ToolTip="{Binding ToolTipEnable}"/>
            <Button Name="DisableButton" Content="{Binding ButtonDisable}" Width="100" IsEnabled="False" ToolTip="{Binding ToolTipDisable}"/>
        </StackPanel>
    </Grid>
</Window>
"@
#endregion

#region Backend Functions
#================================================================================
# Utility and Core Logic Functions
#================================================================================
function Test-IsAdmin {
    $win_id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $win_principal = New-Object System.Security.Principal.WindowsPrincipal($win_id)
    $admin_permission = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    return $win_principal.IsInRole($admin_permission)
}

Function Format-MacAddress {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidatePattern('^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$|^[0-9A-Fa-f]{12}$')]
        [System.String]$MacAddress
    )
    $normalizedMac = $MacAddress -replace '[:-]'
    $formatted = $normalizedMac -replace '(.{2})(?!$)', '$1-'
    return $formatted.ToUpper()
}

Function Enable-MacAddress {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateScript({ $_.Trim() -ne '' })]
        [System.String]$TargetMacAddress,
        [Switch]$Force
    )
    $FormatedMacAddress = (Format-MacAddress $TargetMacAddress)
    $disconnectedAdapter = Get-NetAdapter | Where-Object { ($_.MacAddress -eq $FormatedMacAddress) -and ($_.Status -eq 'Disabled') }

    if (@($disconnectedAdapter).Count -ne 1) {
        [System.Windows.MessageBox]::Show($lang.ErrorNotFoundEnable, $lang.ErrorTitle, 'OK', 'Warning')
        return
    }

    if ($Force -or $PSCmdlet.ShouldProcess($disconnectedAdapter.Name, "Enable")) {
        if (Test-IsAdmin) {
            Enable-NetAdapter -Name $disconnectedAdapter.Name -Confirm:$false
        }
        else {
            $argument = "Enable-NetAdapter -Name '$($disconnectedAdapter.Name)'"
            Start-Process 'powershell.exe' -ArgumentList $argument -Verb RunAs
        }
    }
}

Function Disable-MacAddress {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateScript({ $_.Trim() -ne '' })]
        [System.String]$TargetMacAddress,
        [Switch]$Force
    )
    $FormatedMacAddress = (Format-MacAddress $TargetMacAddress)
    $connectedAdapter = Get-NetAdapter | Where-Object { ($_.MacAddress -eq $FormatedMacAddress) -and ($_.Status -eq 'Up') }

    if (@($connectedAdapter).Count -ne 1) {
        [System.Windows.MessageBox]::Show($lang.ErrorNotFoundDisable, $lang.ErrorTitle, 'OK', 'Warning')
        return
    }
    
    if ($Force -or $PSCmdlet.ShouldProcess($connectedAdapter.Name, "Disable")) {
        if (Test-IsAdmin) {
            Disable-NetAdapter -Name $connectedAdapter.Name -Confirm:$false
        }
        else {
            $argument = "Disable-NetAdapter -Name '$($connectedAdapter.Name)'"
            Start-Process 'powershell.exe' -ArgumentList $argument -Verb RunAs
        }
    }
}
#endregion

#region GUI Initialization and Event Handlers
#================================================================================
# Load UI elements from XAML and wire up events.
#================================================================================
try {
    $Window = [Windows.Markup.XamlReader]::Parse($xaml)
}
catch {
    Write-Error "XAML loading failed: $($_.Exception.Message)"
    return
}

# Set the DataContext for the window to enable data binding for UI strings.
# * Convert the Hashtable to a PSCustomObject so that WPF can recognize its properties for data binding.
$Window.DataContext = New-Object -TypeName PSObject -Property $lang

$AdapterListView = $Window.FindName("AdapterListView")
$RefreshButton = $Window.FindName("RefreshButton")
$EnableButton = $Window.FindName("EnableButton")
$DisableButton = $Window.FindName("DisableButton")

Function Update-AdapterList {
    $selectedIndex = $AdapterListView.SelectedIndex
    
    # Get adapter list and calculate IPv4 address using a calculated property.
    $adapters = Get-NetAdapter -IncludeHidden | Select-Object Name, Status, MacAddress, @{Name="IPv4Address";Expression={($_ | Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue).IPAddress -join ', '}}, LinkSpeed
    $AdapterListView.ItemsSource = $adapters
    
    # Restore previous selection if valid.
    if ($selectedIndex -ne -1 -and $selectedIndex -lt $AdapterListView.Items.Count) {
        $AdapterListView.SelectedIndex = $selectedIndex
    }
}

# --- Event Handlers ---
$AdapterListView.add_SelectionChanged({
    $selectedItem = $AdapterListView.SelectedItem
    if ($null -ne $selectedItem) {
        $EnableButton.IsEnabled = ($selectedItem.Status -eq 'Disabled')
        $DisableButton.IsEnabled = ($selectedItem.Status -eq 'Up')
    }
    else {
        $EnableButton.IsEnabled = $false
        $DisableButton.IsEnabled = $false
    }
})

$RefreshButton.add_Click({
    Update-AdapterList
})

$EnableButton.add_Click({
    $selectedItem = $AdapterListView.SelectedItem
    if ($null -ne $selectedItem) {
        $mac = $selectedItem.MacAddress
        # Format the confirmation message using the selected language.
        $message = [string]::Format($lang.ConfirmEnableMsg, $selectedItem.Name)
        $result = [System.Windows.MessageBox]::Show($message, $lang.ConfirmEnableTitle, "YesNo", "Question")
        if ($result -eq 'Yes') {
            Enable-MacAddress -TargetMacAddress $mac -Force
            Start-Sleep -Seconds 1
            Update-AdapterList
        }
    }
})

$DisableButton.add_Click({
    $selectedItem = $AdapterListView.SelectedItem
    if ($null -ne $selectedItem) {
        $mac = $selectedItem.MacAddress
        # Format the confirmation message using the selected language.
        $message = [string]::Format($lang.ConfirmDisableMsg, $selectedItem.Name)
        $result = [System.Windows.MessageBox]::Show($message, $lang.ConfirmDisableTitle, "YesNo", "Question")
        if ($result -eq 'Yes') {
            Disable-MacAddress -TargetMacAddress $mac -Force
            Start-Sleep -Seconds 1
            Update-AdapterList
        }
    }
})

#================================================================================
# Initialize and show the main window.
#================================================================================
Update-AdapterList
$Window.ShowDialog() | Out-Null
#endregion
```

:::

## まとめ

- 共通して使用する自作関数
    - 「`Test-IsAdmin`」で現在のセッションが管理者権限で実行されているか判定
    - 「`Format-MacAddress`」でさまざまな形式のMACアドレス文字列を大文字のハイフン区切り形式に変換
- ネットワークアダプターを有効化／無効化する自作関数
    - 「`Enable-MacAddress`」でネットワークアダプターを有効化
    - 「`Disable-MacAddress`」でネットワークアダプターを無効化
- GUI画面でネットワークアダプターを管理するPowerShellスクリプト
    - 「`Manage-NetworkAdapters.ps1`」でネットワークアダプターをGUIで管理

## 関連記事

https://haretokidoki-blog.com/pasocon_powershell-startup/
https://zenn.dev/haretokidoki/articles/7e6924ff0cc960
https://zenn.dev/haretokidoki/articles/fb6830f9155de5

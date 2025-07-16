---
title: "Windowsでネットワークアダプタを有効または無効にするPowerShellコード"
emoji: "🙆"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["windows", "network", "powershell"]
published: false
---

ネットワークアダプターの状態を一覧表示するコマンド。

```powershell:ネットワークアダプターの状態を一覧表示するコマンド
Get-NetAdapter | Select-Object Name, Status, MacAddress, @{Name="IPv4Address";Expression={($_ | Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue).IPAddress -join ', '}}
```

## コード

### 共通して使用する関数

ネットワークアダプターの有効化・無効化の双方で使用する関数。

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

```powershell:MACアドレスの文字列をハイフン区切りの表記に変換（すでにハイフン区切りの場合はそのまま返す）
<#
.SYNOPSIS
    MACアドレスの文字列を、標準的なハイフン区切り形式 (XX-XX-XX-XX-XX-XX) に整形します。

.DESCRIPTION
    この関数は、ハイフン区切り、またはハイフンなしの12桁のMACアドレス文字列を受け取ります。
    入力文字列がすでに正しいハイフン区切り形式の場合、処理を行わずにそのままの値を返します。
    入力文字列がハイフンなしの12桁の場合、2桁ごとにハイフンを挿入して "XX-XX-XX-XX-XX-XX" の形式に変換します。

    ValidatePattern属性により、入力は正しいMACアドレスの形式であることが保証されます。

.PARAMETER MacAddress
    整形対象のMACアドレス文字列を指定します。
    ハイフン区切り ("00-1A-7D-0A-C6-E8") またはハイフンなし ("001A7D0AC6E8") の形式を受け付けます。
    大文字・小文字は区別されません。このパラメーターは必須で、パイプラインからの入力も受け付けます。

.INPUTS
    System.String
    パイプライン経由でMACアドレス文字列を受け取ることができます。

.OUTPUTS
    System.String
    ハイフンで区切られた標準形式のMACアドレス文字列を返します。

.EXAMPLE
    PS C:\> Format-MacAddress -MacAddress "001A7D0AC6E8"

    00-1A-7D-0A-C6-E8

    説明: ハイフンなしのMACアドレス文字列を、ハイフン区切り形式に変換します。

.EXAMPLE
    PS C:\> Format-MacAddress -MacAddress "00-4E-01-A3-83-EC"

    00-4E-01-A3-83-EC

    説明: すでにハイフン区切り形式のため、何も処理されずにそのまま返されます。

.EXAMPLE
    PS C:\> "001A7D0AC6E8" | Format-MacAddress

    00-1A-7D-0A-C6-E8

    説明: パイプライン経由でハイフンなしのMACアドレスを渡し、整形する例です。

.NOTES
    - パラメーターの `ValidatePattern` 属性により、不正な文字や長さの文字列が渡されると、関数が実行される前にエラーが発生します。
    - 効率化のため、入力がすでにハイフン区切り形式である場合は、早期リターンによって不要な文字列置換処理をスキップします。
#>
Function Format-MacAddress {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        # 入力パターンをハイフン区切り、またはハイフンなしの12桁に限定
        [ValidatePattern('(^([0-9A-Fa-f]{2}-){5}[0-9A-Fa-f]{2}$)|(^([0-9A-Fa-f]){12}$)')]
        [System.String]$MacAddress
    )

    # 既にハイフン区切り形式 (例: 00-1A-7D-0A-C6-E8) の場合は、何もせずそのまま返す
    if ($MacAddress -like '*-*-*-*-*-*') {
        return $MacAddress
    }
    
    # ハイフンなしの12桁の16進数文字列であれば、2桁ごとにハイフンを挿入する
    # 正規表現の置換機能を使用して、2文字ごとにハイフンを追加し、末尾の不要なハイフンを削除する
    $formatted = $MacAddress -replace '(.{2})', '$1-' -replace '-$'

    # 整形後のMACアドレスを返す
    return $formatted
}
```

### ネットワークアダプターを有効化する関数

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

```powershell:Confirmに対応したFunction
PS C:\WINDOWS\system32> Enable-MacAddress 004e01a383ec -Confirm

確認
この操作を実行しますか?
対象 "イーサネット" に対して操作 "有効にしますか？" を実行しています。
[Y] はい(Y)  [A] すべて続行(A)  [N] いいえ(N)  [L] すべて無視(L)  [S] 中断(S)  [?] ヘルプ (既定値は "Y"): n
PS C:\WINDOWS\system32>
```

### ネットワークアダプターを無効化する関数

```powershell:ネットワークアダプターのMACアドレスを指定して無効化するFunction
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

一般ユーザーで実行すると、UACが起動し「はい」を選択。新しいウィンドウが管理者権限で開いた後にメッセージ（``）が起動する。
可能であれば動画で掲載した方がわかりやすい。

```powershell:
PS C:\WINDOWS\system32> Disable-MacAddress 004e01a383ec -Confirm

確認
この操作を実行しますか?
対象 "イーサネット" に対して操作 "有効にしますか？" を実行しています。
[Y] はい(Y)  [A] すべて続行(A)  [N] いいえ(N)  [L] すべて無視(L)  [S] 中断(S)  [?] ヘルプ (既定値は "Y"): n
PS C:\WINDOWS\system32>
```

## 応用：画面でネットワークアダプター一覧を表示し操作

★正常に動かない。

```powershell
#Requires -RunAsAdministrator
#Requires -Version 5.1

#region WPFとXAMLの定義
# --------------------------------------------------
# WPFアセンブリの読み込み
# --------------------------------------------------
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# --------------------------------------------------
# XAML: GUIのレイアウトを定義
# --------------------------------------------------
[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="ネットワークアダプター マネージャー" Height="450" Width="700"
        WindowStartupLocation="CenterScreen" MinHeight="300" MinWidth="500">
    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        
        <TextBlock Grid.Row="0" Text="ネットワークアダプター一覧" FontWeight="Bold" FontSize="16" Margin="0,0,0,10"/>
        
        <ListView Name="AdapterListView" Grid.Row="1" SelectionMode="Single">
            <ListView.View>
                <GridView>
                    <GridViewColumn Header="名前" Width="180" DisplayMemberBinding="{Binding Name}" />
                    <GridViewColumn Header="状態" Width="80" DisplayMemberBinding="{Binding Status}" />
                    <GridViewColumn Header="MACアドレス" Width="140" DisplayMemberBinding="{Binding MacAddress}" />
                    <GridViewColumn Header="IPv4アドレス" Width="150" DisplayMemberBinding="{Binding IPv4Address}" />
                    <GridViewColumn Header="リンク速度" Width="100" DisplayMemberBinding="{Binding LinkSpeed}" />
                </GridView>
            </ListView.View>
        </ListView>
        
        <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,10,0,0">
            <Button Name="RefreshButton" Content="🔄 更新" Width="100" Margin="0,0,10,0" ToolTip="一覧を最新の情報に更新します"/>
            <Button Name="EnableButton" Content="✅ 有効化" Width="100" Margin="0,0,10,0" IsEnabled="False" ToolTip="選択したアダプターを有効化します"/>
            <Button Name="DisableButton" Content="❌ 無効化" Width="100" IsEnabled="False" ToolTip="選択したアダプターを無効化します"/>
        </StackPanel>
    </Grid>
</Window>
'@
#endregion

#region 提示された関数群 (バックエンドロジック)
# --------------------------------------------------
# 共通して使用する関数
# --------------------------------------------------
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

Function Format-MacAddress {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        # 入力パターンをハイフン区切り、またはハイフンなしの12桁に限定
        [ValidatePattern('(^([0-9A-Fa-f]{2}-){5}[0-9A-Fa-f]{2}$)|(^([0-9A-Fa-f]){12}$)')]
        [System.String]$MacAddress
    )

    # 既にハイフン区切り形式 (例: 00-1A-7D-0A-C6-E8) の場合は、何もせずそのまま返す
    if ($MacAddress -like '*-*-*-*-*-*') {
        return $MacAddress
    }
    
    # ハイフンなしの12桁の16進数文字列であれば、2桁ごとにハイフンを挿入する
    # 正規表現の置換機能を使用して、2文字ごとにハイフンを追加し、末尾の不要なハイフンを削除する
    $formatted = $MacAddress -replace '(.{2})', '$1-' -replace '-$'

    # 整形後のMACアドレスを返す
    return $formatted
}

# --------------------------------------------------
# ネットワークアダプターを有効化する関数
# --------------------------------------------------
Function Enable-MacAddress {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateScript({ $_.Trim() -ne '' })]
        [System.String]$TargetMacAddress,

        ### 変更点 ###
        # GUIからの強制実行用スイッチを追加
        [Switch]$Force
    )
    $FormatedMacAddress = (Format-MacAddress $TargetMacAddress)
    $disconnectedAdapter = Get-NetAdapter | Where-Object { ($_.MacAddress -eq $FormatedMacAddress) -and ($_.Status -eq 'Disabled') }

    if (@($disconnectedAdapter).Count -ne 1) {
        ### 変更点 ###
        # エラー表示をMessageBoxに統一
        [System.Windows.MessageBox]::Show('対象となる無効化状態のネットワークアダプターが見つかりませんでした。','エラー','OK','Warning')
        return
    }

    ### 変更点 ###
    # -Forceスイッチが指定された場合はShouldProcessをスキップする
    if ($Force -or $PSCmdlet.ShouldProcess($disconnectedAdapter.Name, "有効化")) {
        if (Test-IsAdmin) {
            Enable-NetAdapter -Name $disconnectedAdapter.Name -Confirm:$false
        }
        else {
            $argument = "Enable-NetAdapter -Name '$($disconnectedAdapter.Name)'"
            Start-Process 'powershell.exe' -ArgumentList $argument -Verb RunAs
        }
    }
}

# --------------------------------------------------
# ネットワークアダプターを無効化する関数
# --------------------------------------------------
Function Disable-MacAddress {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateScript({ $_.Trim() -ne '' })]
        [System.String]$TargetMacAddress,
        
        ### 変更点 ###
        # GUIからの強制実行用スイッチを追加
        [Switch]$Force
    )
    $FormatedMacAddress = (Format-MacAddress $TargetMacAddress)
    $connectedAdapter = Get-NetAdapter | Where-Object { ($_.MacAddress -eq $FormatedMacAddress) -and ($_.Status -eq 'Up') }

    if (@($connectedAdapter).Count -ne 1) {
        ### 変更点 ###
        # エラー表示をMessageBoxに統一
        [System.Windows.MessageBox]::Show('対象となる有効化状態のネットワークアダプターが見つかりませんでした。','エラー','OK','Warning')
        return
    }
    
    ### 変更点 ###
    # -Forceスイッチが指定された場合はShouldProcessをスキップする
    if ($Force -or $PSCmdlet.ShouldProcess($connectedAdapter.Name, "無効化")) {
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

#region GUIの初期化とイベントハンドラ
# --------------------------------------------------
# XAMLからUI要素を読み込む
# --------------------------------------------------
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
try {
    $Window = [Windows.Markup.XamlReader]::Load($reader)
}
catch {
    Write-Error "XAMLの読み込みに失敗しました: $($_.Exception.Message)"
    return
}

# --------------------------------------------------
# UI要素を変数に格納
# --------------------------------------------------
$AdapterListView = $Window.FindName("AdapterListView")
$RefreshButton = $Window.FindName("RefreshButton")
$EnableButton = $Window.FindName("EnableButton")
$DisableButton = $Window.FindName("DisableButton")

# --------------------------------------------------
# アダプター一覧を更新する関数
# --------------------------------------------------
Function Update-AdapterList {
    # 選択状態を一時保存
    $selectedIndex = $AdapterListView.SelectedIndex
    
    # データソースを更新
    $AdapterListView.ItemsSource = Get-NetAdapter -IncludeHidden | Select-Object Name, Status, MacAddress, @{Name="IPv4Address";Expression={($_ | Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue).IPAddress -join ', '}}, LinkSpeed
    
    # 選択状態を復元
    if ($selectedIndex -ne -1 -and $selectedIndex -lt $AdapterListView.Items.Count) {
        $AdapterListView.SelectedIndex = $selectedIndex
    }
}

# --------------------------------------------------
# イベントハンドラを定義
# --------------------------------------------------
# ListViewの選択が変更されたときの処理
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

# 更新ボタンがクリックされたときの処理
$RefreshButton.add_Click({
    Update-AdapterList
})

# 有効化ボタンがクリックされたときの処理
$EnableButton.add_Click({
    $selectedItem = $AdapterListView.SelectedItem
    if ($null -ne $selectedItem) {
        $mac = $selectedItem.MacAddress
        $result = [System.Windows.MessageBox]::Show("アダプター '$($selectedItem.Name)' を有効化しますか？", "確認", "YesNo", "Question")
        if ($result -eq 'Yes') {
            ### 変更点 ###
            # -Forceスイッチを付けて関数を呼び出す
            Write-Host "`$mac: $mac"
            Enable-MacAddress -TargetMacAddress $mac -Force
            Start-Sleep -Seconds 1
            Update-AdapterList
        }
    }
})

# 無効化ボタンがクリックされたときの処理
$DisableButton.add_Click({
    $selectedItem = $AdapterListView.SelectedItem
    if ($null -ne $selectedItem) {
        $mac = $selectedItem.MacAddress
        $result = [System.Windows.MessageBox]::Show("アダプター '$($selectedItem.Name)' を無効化しますか？", "確認", "YesNo", "Question")
        if ($result -eq 'Yes') {
            ### 変更点 ###
            # -Forceスイッチを付けて関数を呼び出す
            Write-Host "`$mac: $mac"
            Disable-MacAddress -TargetMacAddress $mac -Force
            Start-Sleep -Seconds 1
            Update-AdapterList
        }
    }
})

# --------------------------------------------------
# ウィンドウの初期化と表示
# --------------------------------------------------
# 起動時にアダプター一覧を読み込む
Update-AdapterList

# ウィンドウを表示
$Window.ShowDialog() | Out-Null
#endregion
```

## 関連記事

https://haretokidoki-blog.com/pasocon_powershell-startup/
https://zenn.dev/haretokidoki/articles/7e6924ff0cc960
https://zenn.dev/haretokidoki/articles/fb6830f9155de5

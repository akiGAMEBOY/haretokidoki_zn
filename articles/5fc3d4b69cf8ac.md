---
title: "Windowsでネットワークアダプタを有効または無効にするPowerShellコード"
emoji: "🙆"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["windows", "network", "powershell"]
published: false
---

WPFで画面を作ってみる？

```powershell:
Get-NetAdapter | Select-Object Name, Status, MacAddress, @{Name="IPv4Address";Expression={($_ | Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue).IPAddress -join ', '}}
```

## コード

### 共通関数

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
    この関数は、ハイフン区切り、またはハイフンなしのMACアドレス文字列を受け取ります。
    引数がハイフンなしの12桁の16進数文字列の場合、2桁ごとにハイフンを挿入して "XX-XX-XX-XX-XX-XX" の形式に変換します。
    すでにハイフン区切り形式の場合は、そのままの文字列を返します。
    入力文字列は ValidatePattern 属性により、正しいMACアドレスの形式であることが検証されます。

.PARAMETER MacAddress
    整形対象のMACアドレス文字列を指定します。
    ハイフン区切り ("00-1A-7D-0A-C6-E8") またはハイフンなし ("001A7D0AC6E8") の形式を受け付けます。
    大文字・小文字は区別されません。このパラメーターは必須で、パイプラインからの入力も受け付けます。

.INPUTS
    System.String
    パイプライン経由でMACアドレス文字列を受け取ることができます。

.OUTPUTS
    System.String
    ハイフンで区切られた形式のMACアドレス文字列を返します。

.EXAMPLE
    PS> Format-MacAddress -MacAddress "001A7D0AC6E8"
    
    00-1A-7D-0A-C6-E8
    
    説明: ハイフンなしのMACアドレス文字列を、ハイフン区切り形式に変換します。

.EXAMPLE
    PS> Format-MacAddress -MacAddress "00-4E-01-A3-83-EC"
    
    00-4E-01-A3-83-EC
    
    説明: すでにハイフン区切り形式のMACアドレスは、変更されずにそのまま返されます。

.EXAMPLE
    PS> (Get-NetAdapter -Name "イーサネット").MacAddress | Format-MacAddress
    
    00-4E-01-A3-83-EC

    説明: 他のコマンドレットから取得したMACアドレスをパイプラインで渡し、整形します。
    (この例では、元の形式がハイフン区切りなので結果は変わりませんが、パイプラインの使用法を示しています。)

.NOTES
    正規表現による入力検証 (`ValidatePattern`) を行っているため、不正な文字や長さの文字列が渡されると、コマンド実行前にエラーが発生します。
#>
Function Format-MacAddress {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidatePattern('(^([0-9A-Fa-f]{2}-){5}[0-9A-Fa-f]{2}$)|(^([0-9A-Fa-f]){12}$)')]
        [System.String]$MacAddress
    )

    # ハイフンなしの12桁の16進数文字列であれば、2桁ごとにハイフンを挿入する
    if ($MacAddress -match '^([0-9A-Fa-f]){12}$') {
        # 正規表現の置換機能を使用して、2文字ごとにハイフンを追加し、末尾の不要なハイフンを削除する
        $MacAddress = $MacAddress -replace '(.{2})', '$1-' -replace '-$'
    }

    # 整形後のMACアドレスを返す
    return $MacAddress
}
```

### 有効化

```powershell:ネットワークアダプターのMACアドレスを指定して有効化
<#
.SYNOPSIS
    指定されたMACアドレスを持つ、無効化（Disabled）状態のネットワークアダプターを有効化します。

.DESCRIPTION
    この関数は、指定されたMACアドレスを基に、現在無効化されているネットワークアダプターを検索します。
    対象のアダプターが1つだけ見つかった場合に、そのアダプターを有効化する処理を実行します。
    
    現在のセッションが管理者権限で実行されていない場合、UAC（ユーザーアカウント制御）のプロンプトを表示し、
    ユーザーの承認を得てから管理者権限でアダプターを有効化する処理を試みます。
    
    この関数は -WhatIf および -Confirm パラメーターをサポートしています。

.PARAMETER TargetMacAddress
    有効化したいネットワークアダプターのMACアドレスを指定します。
    このパラメーターは必須です。ハイフン区切りの形式 ("00-1A-7D-0A-C6-E8") と、
    ハイフンなしの12桁の形式 ("001A7D0AC6E8") の両方を受け付けます。

.INPUTS
    None
    この関数はパイプラインからの入力を受け付けません。

.OUTPUTS
    None
    この関数はパイプラインへオブジェクトを出力しません。

.EXAMPLE
    PS C:\> Enable-MacAddress -TargetMacAddress "00-1A-7D-0A-C6-E8"
    
    確認
    この操作を実行しますか?
    ターゲット "イーサネット 2" に対して操作 "有効にしますか？" を実行しています。
    [Y] はい(Y)  [A] すべて続行(A)  [N] いいえ(N)  [L] すべて無視(L)  [S] 中断(S)  [?] ヘルプ (既定値は "Y"):
    
    説明:
    指定されたMACアドレスを持つ無効化されたアダプターを有効にします。
    ConfirmImpact が 'Medium' に設定されているため、実行前に確認プロンプトが表示されます。

.EXAMPLE
    PS C:\> Enable-MacAddress -TargetMacAddress "001A7D0AC6E8" -WhatIf
    
    What if: ターゲット "イーサネット 2" に対して操作 "有効にしますか？" を実行します。
    
    説明:
    -WhatIf パラメーターを使用すると、実際にはアダプターを有効化せず、実行される予定の操作内容だけが表示されます。

.EXAMPLE
    PS C:\> Enable-MacAddress -TargetMacAddress "00-1A-7D-0A-C6-E8" -Confirm:$false
    
    説明:
    -Confirm:$false を指定することで、確認プロンプトを表示せずにアダプターを直接有効化します。

.NOTES
    - 依存関係: この関数は、`Format-MacAddress` および `Test-IsAdmin` 関数が事前に読み込まれている必要があります。
    - 管理者権限: 有効化処理には管理者権限が必要です。権限がない場合はUACによる昇格プロンプトが表示されます。
    - エラー処理: 対象のアダプターが見つからない、または複数見つかった場合は、警告メッセージと共に現在のアダプター一覧が表示され、処理は中断されます。

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
        [Parameter(Mandatory=$true)]
        [ValidateScript({ $_.Trim() -ne '' })]
        [System.String]$TargetMacAddress
    )

    # MACアドレスを正規のハイフン区切り形式に整形する
    $FormatedMacAddress = (Format-MacAddress $TargetMacAddress)

    # 指定されたMACアドレスを持ち、かつ無効化されているネットワークアダプターを取得
    $disconnectedAdapter = Get-NetAdapter | Where-Object {
        ($_.MacAddress -eq $FormatedMacAddress) -and ($_.Status -eq 'Disabled')
    }

    # 対象のアダプターが1つだけ見つかったかを確認
    if (@($disconnectedAdapter).Count -ne 1) {
        Write-Warning '対象となる無効化状態のネットワークアダプターが見つかりませんでした。'
        Write-Host ''
        Write-Host '▼ 現在のネットワークアダプターを表示'
        (Get-NetAdapter | Format-Table -Property Name, Status, MacAddress, LinkSpeed -Autosize -Wrap)
        Write-Host ''
        return
    }

    # -WhatIf/-Confirm のサポートを実装
    if ($PSCmdlet.ShouldProcess($disconnectedAdapter.Name, "有効化")) {
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

### 無効化

```powershell:ネットワークアダプターのMACアドレスを指定して無効化するFunction
#################################################################################
# 処理名　 | Test-IsAdmin
# 機能　　 | PowerShellが管理者として実行しているか確認
#          | 参考情報：https://zenn.dev/haretokidoki/articles/67788ca9b47b27
#--------------------------------------------------------------------------------
# 戻り値　 | Boolean（True: 管理者権限あり, False: 管理者権限なし）
# 引数　　 | -
#################################################################################
Function Test-IsAdmin {
    $win_id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $win_principal = new-object System.Security.Principal.WindowsPrincipal($win_id)
    $admin_permission = [System.Security.Principal.WindowsBuiltInRole]::Administrator
    return $win_principal.IsInRole($admin_permission)
}

# MACアドレスの表記に変換
Function Format-MacAddress {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [ValidatePattern('(^([0-9A-Fa-f]{2}-){5}[0-9A-Fa-f]{2}$)|(^([0-9A-Fa-f]){12}$)')]
        [System.String]$MacAddress
    )

    # 引数が英数字のみ12桁の場合、ハイフンを挿入
    if ($MacAddress -match '^([0-9A-Fa-f]){12}$') {
        $MacAddress = $MacAddress -replace '(.{2})', '$1-' -replace '-$'
    }

    return $MacAddress
}

# 対象のネットワークアダプターを無効にする
Function Disable-MacAddress {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({ $_.Trim() -ne '' })]
        [System.String]$TargetMacAddress
    )

    # MACアドレスの形式か確認
    $FormatedMacAddress = (Format-MacAddress $TargetMacAddress)

    # 対象となるネットワークアダプタを取得
    $connectedAdapter = Get-NetAdapter | Where-Object {
        ($_.MacAddress -eq $FormatedMacAddress) -and ($_.Status -eq 'Up')
    }

    # 対象のアダプターがない場合は中断
    if (@($connectedAdapter).Count -ne 1) {
        Write-Warning '対象となる有効化状態のネットワークアダプターが見つかりませんでした。'
        Write-Host ''
        Write-Host '▼ 現在のネットワークアダプターを表示'
        (Get-NetAdapter | Format-Table -Property Name, Status, MacAddress, LinkSpeed -Autosize -Wrap)
        Write-Host ''
        return
    }

    if ($PSCmdlet.ShouldProcess($connectedAdapter.Name, "無効にしますか？")) {
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

## 関連記事

https://haretokidoki-blog.com/pasocon_powershell-startup/
https://zenn.dev/haretokidoki/articles/7e6924ff0cc960
https://zenn.dev/haretokidoki/articles/fb6830f9155de5

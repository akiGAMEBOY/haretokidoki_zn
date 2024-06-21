---
title: "Windowsでネットワークアダプタを有効または無効にするPowerShellコード"
emoji: "🙆"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["windows", "network", "powershell"]
published: false
---

```powershell
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
function Format-MacAddress {
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
function Enable-MacAddress {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({ $_.Trim() -ne '' })]
        [System.String]$TargetMacAddress
    )

    if (-not (Test-IsAdmin)) {
        Write-Warning 'ネットワークアダプターの有効化は管理者権限が必要です。処理を中断します。'
        return
    }

    # MACアドレスの形式か確認
    $FormatedMacAddress = (Format-MacAddress $TargetMacAddress)

    # 現在のインターネットに接続中のネットワークアダプタを取得
    $disconnectedAdapter = Get-NetAdapter | Where-Object {
        ($_.MacAddress -eq $FormatedMacAddress) -and ($_.Status -eq 'Disabled')
    }

    # 対象のアダプターがない場合は中断
    if (@($disconnectedAdapter).Count -ne 1) {
        Write-Warning '対象となる無効化状態のネットワークアダプターが見つかりませんでした。'
        Write-Host '▼ 現在のネットワークアダプターを表示'
        (Get-NetAdapter | Format-Table -Property Name, Status, MacAddress, LinkSpeed -Autosize -Wrap)
        return
    }

    if ($PSCmdlet.ShouldProcess($disconnectedAdapter.Name, "無効にしますか？")) {
        Enable-NetAdapter -Name $disconnectedAdapter.Name -Confirm:$false
    }
}
```

```powershell:

    # 現在のインターネットに接続中のネットワークアダプタを取得
    $connectedAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }

    # 複数のアダプタがUp状態か確認
    if ($connectedAdapters.Count -gt 1) {
        # アダプタの一覧を出力して処理を中断
        Write-Output "複数のネットワークアダプタが接続中です。"
        $connectedAdapters | Format-Table -Property Name, Status, InterfaceDescription
        return
    }

    # 接続中のアダプタがあるか確認
    if ($connectedAdapters) {
        # 接続中のアダプタを無効にする
        if ($this.ShouldProcess($connectedAdapters.Name, "無効にしますか？")) {
            Disable-NetAdapter -Name $connectedAdapters.Name -Confirm:$false
        }
    } else {
        # 引数で指定されたアダプタを無効にする
        if ($this.ShouldProcess($AdapterName, "無効にしますか？")) {
            Disable-NetAdapter -Name $AdapterName -Confirm:$false
        }
    }
}

```powershell
function Disable-NetworkAdapter {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [System.String]$AdapterName=''
    )

    # 現在のインターネットに接続中のネットワークアダプタを取得
    $connectedAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }

    # 複数のアダプタがUp状態か確認
    if ($connectedAdapters.Count -gt 1) {
        # アダプタの一覧を出力して処理を中断
        Write-Output "複数のネットワークアダプタが接続中です。"
        $connectedAdapters | Format-Table -Property Name, Status, InterfaceDescription
        return
    }

    # 接続中のアダプタがあるか確認
    if ($connectedAdapters) {
        # 接続中のアダプタを無効にする
        if ($this.ShouldProcess($connectedAdapters.Name, "無効にしますか？")) {
            Disable-NetAdapter -Name $connectedAdapters.Name -Confirm:$false
        }
    } else {
        # 引数で指定されたアダプタを無効にする
        if ($this.ShouldProcess($AdapterName, "無効にしますか？")) {
            Disable-NetAdapter -Name $AdapterName -Confirm:$false
        }
    }
}

# 使用例
# Disable-NetworkAdapter -AdapterName "Ethernet"
```

---

下記に要件にそったPowerShellのFunctionを生成してください。
・Functionでは、引数にネットワークアダプタの指定が可能とする。
・Functionを実行すると現在のインターネットに接続中のネットワークアダプタがあれば特定
・上記で特定したネットワークアダプタを無効にして終了
・現在のインターネットに接続中でない場合は、引数で指定されたネットワークアダプタを無効にする。
・アダプタを有効や無効する際に特定のメソッド「System.Management.Automation.Cmdlet.ShouldProcess」で確認を求める作りとする

---

PowerShellでご要望に応じたFunctionを以下に示します。このFunctionは、引数としてネットワークアダプタを受け取り、インターネットに接続中のアダプタを無効にするか、接続されていない場合は指定されたアダプタを無効にします。また、`ShouldProcess`メソッドを使用して、アダプタを無効にする前に確認を行います。

```powershell
Function Disable-NetworkAdapter {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$AdapterName
    )

    # 現在のインターネットに接続中のネットワークアダプタを取得
    $connectedAdapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Get-NetConnectionProfile

    # 接続中のアダプタがあるか確認
    if ($connectedAdapter) {
        # 接続中のアダプタを無効にする
        if ($this.ShouldProcess($connectedAdapter.Name, "無効にしますか？")) {
            Disable-NetAdapter -Name $connectedAdapter.Name -Confirm:$false
        }
    } else {
        # 引数で指定されたアダプタを無効にする
        if ($this.ShouldProcess($AdapterName, "無効にしますか？")) {
            Disable-NetAdapter -Name $AdapterName -Confirm:$false
        }
    }
}

# 使用例
# Disable-NetworkAdapter -AdapterName "Ethernet"
```

このFunctionを実行する前に、実行ポリシーが適切に設定されていることを確認してください。また、`Disable-NetAdapter`コマンドレットを使用するためには、管理者権限が必要です。ご注意ください。

---

承知しました。複数のアダプタがUp状態の場合に処理を中断し、アダプタの一覧を出力するようにFunctionを修正しました。以下が更新されたコードです。

```powershell
Function Disable-NetworkAdapter {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$AdapterName
    )

    # 現在のインターネットに接続中のネットワークアダプタを取得
    $connectedAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Get-NetConnectionProfile

    # 複数のアダプタがUp状態か確認
    if ($connectedAdapters.Count -gt 1) {
        # アダプタの一覧を出力して処理を中断
        Write-Output "複数のネットワークアダプタが接続中です。"
        $connectedAdapters | Format-Table -Property Name, Status, InterfaceDescription
        return
    }

    # 接続中のアダプタがあるか確認
    if ($connectedAdapters) {
        # 接続中のアダプタを無効にする
        if ($this.ShouldProcess($connectedAdapters.Name, "無効にしますか？")) {
            Disable-NetAdapter -Name $connectedAdapters.Name -Confirm:$false
        }
    } else {
        # 引数で指定されたアダプタを無効にする
        if ($this.ShouldProcess($AdapterName, "無効にしますか？")) {
            Disable-NetAdapter -Name $AdapterName -Confirm:$false
        }
    }
}

# 使用例
# Disable-NetworkAdapter -AdapterName "Ethernet"
```

このFunctionを使用する際は、PowerShellの実行ポリシーが適切に設定されていること、および管理者権限で実行していることを再度確認してください。また、`ShouldProcess`メソッドを使用するためには、`CmdletBinding`属性がFunctionに適用されている必要があります。ご注意ください。
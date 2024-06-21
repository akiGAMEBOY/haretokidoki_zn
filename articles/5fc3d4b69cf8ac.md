---
title: "Windowsでネットワークアダプタを有効または無効にするPowerShellコード"
emoji: "🙆"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["windows", "network", "powershell"]
published: false
---

```powershell:ネットワークアダプターのMACアドレスを指定して有効化するFunction
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

    if ($PSCmdlet.ShouldProcess($disconnectedAdapter.Name, "有効にしますか？")) {
        Enable-NetAdapter -Name $disconnectedAdapter.Name -Confirm:$false
    }
}
```

上記のコードでは、Enable-NetAdapterが管理者権限が必要な為、「$PSCmdlet.ShouldProcess($disconnectedAdapter.Name, "有効にしますか？")」の処理を追加している意味がないかも。

★ 以降、無効化を対応。

```powershell:ネットワークアダプターのMACアドレスを指定して有効化するFunction
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

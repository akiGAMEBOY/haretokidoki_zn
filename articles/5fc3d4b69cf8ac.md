---
title: "Windowsでネットワークアダプタを有効または無効にするPowerShellコード"
emoji: "🙆"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["windows", "network", "powershell"]
published: false
---

## コード

### 有効化

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

# 対象のネットワークアダプターを有効にする
function Enable-MacAddress {
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({ $_.Trim() -ne '' })]
        [System.String]$TargetMacAddress
    )

    # MACアドレスの形式か確認
    $FormatedMacAddress = (Format-MacAddress $TargetMacAddress)

    # 対象となるネットワークアダプタを取得
    $disconnectedAdapter = Get-NetAdapter | Where-Object {
        ($_.MacAddress -eq $FormatedMacAddress) -and ($_.Status -eq 'Disabled')
    }

    # 対象のアダプターがない場合は中断
    if (@($disconnectedAdapter).Count -ne 1) {
        Write-Warning '対象となる無効化状態のネットワークアダプターが見つかりませんでした。'
        Write-Host ''
        Write-Host '▼ 現在のネットワークアダプターを表示'
        (Get-NetAdapter | Format-Table -Property Name, Status, MacAddress, LinkSpeed -Autosize -Wrap)
        Write-Host ''
        return
    }

    if ($PSCmdlet.ShouldProcess($disconnectedAdapter.Name, "有効にしますか？")) {
        if (Test-IsAdmin) {
            # 管理者権限がある場合
            Enable-NetAdapter -Name $disconnectedAdapter.Name -Confirm:$false
        }
        else {
            # 管理者権限がない場合の処理
            Start-Process 'powershell.exe' -ArgumentList "Enable-NetAdapter -Name '$($disconnectedAdapter.Name)'" -Verb RunAs
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
function Disable-MacAddress {
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
```

## 関連記事

https://haretokidoki-blog.com/pasocon_powershell-startup/
https://zenn.dev/haretokidoki/articles/7e6924ff0cc960
https://zenn.dev/haretokidoki/articles/fb6830f9155de5

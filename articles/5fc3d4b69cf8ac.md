---
title: "Windowsでネットワークアダプタを有効または無効にするPowerShellコード"
emoji: "🙆"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["windows", "network", "powershell"]
published: false
---

```powershell
Function Disable-NetworkAdapter {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$AdapterName
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
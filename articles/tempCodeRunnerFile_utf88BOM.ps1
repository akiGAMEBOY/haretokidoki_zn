Function InputForm {
    param (
        [System.String]$target_folder
    )

    # アセンブリ読み込み（フォーム用）
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    [System.String[]]$input_parameters = @()

    # フォームの作成
    [System.String]$prompt_title = 'タイトル：対象フォルダーを入力'
    [System.String]$prompt_message = '参照するフォルダーを入力してください。'
    [System.Windows.Forms.Form]$form = New-Object System.Windows.Forms.Form
    $form.Text = $prompt_title
    [System.UInt32[]]$form_size = @(550, 300)
    $form.Size = New-Object System.Drawing.Size($form_size[0],$form_size[1])
    $form.StartPosition = 'CenterScreen'
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false

    [System.String]$font_family = 'ＭＳ ゴシック'
    [System.Int32]$font_size = 12

    # ラベル作成
    [System.Windows.Forms.Label]$label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(20, 20)
    $label.Size = New-Object System.Drawing.Size(350, 50)
    $label.Text = $prompt_message
    [System.Drawing.Font]$font = New-Object System.Drawing.Font($font_family, $font_size)
    $label.Font = New-Object System.Drawing.Font($font_family, $font_size)

    # テキストボックスの作成 ★ここから★ --->
    [System.Windows.Forms.TextBox]$textbox = New-Object System.Windows.Forms.TextBox
    $textbox.Location = New-Object System.Drawing.Point(40, 80)

    # 100でマルチラインをオンの場合
    $textbox.Size = New-Object System.Drawing.Size(350, 100)
    $textbox.Multiline = $true

    $textbox.Text = $target_folder
    $textbox.Font = New-Object System.Drawing.Font($font_family, $font_size)
    # <--- ★ここまで★

    # 参照ボタンの作成
    [System.Windows.Forms.Button]$btnRefer = New-Object System.Windows.Forms.Button
    $btnRefer.Location = New-Object System.Drawing.Point(420, 80)
    $btnRefer.Size = New-Object System.Drawing.Size(75,25)
    $btnRefer.Text = '参照'

    # OKボタンの作成
    [System.Windows.Forms.Button]$btnOkay = New-Object System.Windows.Forms.Button
    $btnOkay.Location = New-Object System.Drawing.Point(355, 210)
    $btnOkay.Size = New-Object System.Drawing.Size(75,30)
    $btnOkay.Text = 'OK'
    $btnOkay.DialogResult = [System.Windows.Forms.DialogResult]::OK

    # Cancelボタンの作成
    [System.Windows.Forms.Button]$btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Location = New-Object System.Drawing.Point(440,210)
    $btnCancel.Size = New-Object System.Drawing.Size(75,30)
    $btnCancel.Text = 'キャンセル'
    $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

    # ボタンの紐づけ
    # $form.AcceptButton = $btnOkay
    # $form.CancelButton = $btnCancel

    # フォームに紐づけ
    $form.Controls.Add($label)
    $form.Controls.Add($textbox)
    $form.Controls.Add($btnRefer)
    # $form.Controls.Add($btnOkay)
    # $form.Controls.Add($btnCancel)

    # フォーム表示
    [System.Boolean]$is_Selected = ($form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK)
    $form = $null

    return $is_Selected
}
# 実行
InputForm 'D:\Downloads'

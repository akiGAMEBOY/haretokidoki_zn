---
title: "PowerShellでExcelマクロ有効ブック（*.xlsm）のVBAコードを取得する方法"
emoji: "👋"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["powershell", "excel"]
published: false
---

```powershell
# Excelアプリケーションを起動
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false

# Excelファイルを開く
$workbook = $excel.Workbooks.Open("C:\path\to\your\file.xlsm")

# VBAプロジェクトを取得
$vbaProject = $workbook.VBProject

# 各モジュールのコードを抽出
foreach ($component in $vbaProject.VBComponents) {
    $componentName = $component.Name
    $code = $component.CodeModule.Lines(1, $component.CodeModule.CountOfLines)
    
    # コードをファイルに保存
    $outputPath = "C:\path\to\output\folder\$componentName.txt"
    Set-Content -Path $outputPath -Value $code
}

# Excelを閉じる
$workbook.Close($false)
$excel.Quit()

# COMオブジェクトの解放
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
```
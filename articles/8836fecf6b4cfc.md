---
title: "Pythonとpipパッケージのバージョン確認＆一括アップデート方法"
emoji: "🐍"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["python", "pip"]
published: true
---
## 概要

仮想の開発環境を立ち上げて`pip list`でインストール済みのパッケージ一覧を確認した結果、
**pip**自体が更新可能な状態でした。
pip以外のパッケージについても一括でアップデートしたいと思い調べた内容を紹介します。

## この記事のターゲット

- Python 初級者・初学者の方
- Pythonのパッケージ管理システム「pip」で一括アップデートしたい方

## 環境

### ホスト（物理）OSのスペック

Windows 10 Pro 環境にOracle VM VirtualBoxをインストール。
  | 種類 | 内容 |
  | ---- | ---- |
  | CPU | [Intel(R) Core(TM) i3-8100T CPU @ 3.10GHz](https://www.intel.co.jp/content/www/jp/ja/products/sku/129944/intel-core-i38100t-processor-6m-cache-3-10-ghz/specifications.html) |
  | CPU世代 | 第8世代 |
  | コア数 | 4 コア |
  | スレッド数 | 4 スレッド |
  | メモリー | 16GB |

### ゲスト（仮想）OSの割り当て

VirtualBox内のゲストOSもWindows 10 Pro 環境。
  | 種類 | 内容 |
  | ---- | ---- |
  | プロセッサー数<br>（仮想環境に割り当てるコア数） | 2 コア |
  | メモリー<br>（仮想環境に割り当てているメモリーサイズ） | 4 GB |

:::details 参考情報：VirtualBoxで設定可能なプロセッサー最大値 と 物理CPUのコア数（もしくはスレッド数）と差異あり（クリック・タップで折りたたみが開く）
[こちら](https://superuser.com/questions/540407/why-does-virtualbox-show-more-cpus-than-available)の情報を参考にするとVirtualBoxの`Processor`の設定値は、
多くとも物理CPUの `スレッド数 - 1`（スレッド数が4の場合は、3が最大値） にしないといけない。
仮に物理CPUのスレッド数以上で設定してしまうと、ホストOSの挙動がおかしくなる可能性ありとの事。
そもそも何故、VirtualBox側でスレッド数を超える値が設定可能なのかという点は、よくわからなかった。

- 参考情報
    <https://superuser.com/questions/540407/why-does-virtualbox-show-more-cpus-than-available>
    <https://atmarkit.itmedia.co.jp/ait/articles/1010/14/news128.html#:~:text=VirtualBoxの仕様では,倍までしか設定できない。>
:::

### IDE

#### VS Code 本体

```powershell:コピー用
code -v
```

```powershell:VS Code 1.80.0
PS C:\XXXX> code -v
1.80.0
660393deaaa6d1996740ff4880f1bad43768c814
x64
PS C:\XXXX> 
```

https://www.curict.com/item/00/007bbb1.html

#### VS Code 拡張機能

```powershell:コピー用
code --list-extensions --show-versions
```

```powershell:VS Code 拡張機能の一覧
PS C:\XXXX> code --list-extensions --show-versions
GrapeCity.gc-excelviewer@4.2.57
MS-CEINTL.vscode-language-pack-ja@1.80.2023070509
ms-python.flake8@2023.6.0
ms-python.isort@2023.10.0
ms-python.python@2023.12.0
ms-python.vscode-pylance@2023.7.10
PS C:\XXXX>
```

https://motamemo.com/vscode/vscode-tips/list-extensions-versions/

## [Python]バージョンを確認する方法

下記の通り`python -V`（もしくは`--version`、`-VV`）の引数（オプション）を指定することで、
バージョンを確認可能。

```powershell:コピー用
python -V
python --version
python -VV
```

```powershell:pythonバージョン確認コマンド
PS C:\XXXX> python -V
Python 3.10.5
PS C:\XXXX>
PS C:\XXXX> python --version
Python 3.10.5
PS C:\XXXX>
PS C:\XXXX> python -VV
Python 3.10.5 (tags/v3.10.5:f377153, Jun  6 2022, 16:14:13) [MSC v.1929 64 bit (AMD64)]
PS C:\XXXX>
```

::::details 補足事項：間違えて小文字のブイ（v）を指定した場合（クリック・タップで折りたたみが開く）

- 間違えた場合はverbose（詳細）モードが起動
    間違えて`python -v`と小文字のブイ（v）で入力してしまうと、
    Pythonのverbose（詳細）モードが起動する。
    
    verboseモードでは、python環境が立ち上がり手動でプログラムの検証が可能となる。

- 解決方法
  **verboseモードを終了したい場合**、「`Ctrl` + `Z`」で“^Z”を入力し`Enter`キーを入力する事で終了できる。

  :::details 実行例：verboseモードの起動と終了（クリック・タップで折りたたみが開く）

  ```powershell
  PS C:\XXXX> python -v 👈 間違えて小文字のブイ（v）で実行すると起動。
  import _frozen_importlib # frozen
  import _imp # builtin
  import '_thread' # <class '_frozen_importlib.BuiltinImporter'>
  import '_warnings' # <class '_frozen_importlib.BuiltinImporter'>
  import '_weakref' # <class '_frozen_importlib.BuiltinImporter'>
  import '_io' # <class '_frozen_importlib.BuiltinImporter'>
  import 'marshal' # <class '_frozen_importlib.BuiltinImporter'>
  import 'nt' # <class '_frozen_importlib.BuiltinImporter'>
  import 'winreg' # <class '_frozen_importlib.BuiltinImporter'>
  import '_frozen_importlib_external' # <class '_frozen_importlib.FrozenImporter'>
  # installing zipimport hook
  import 'time' # <class '_frozen_importlib.BuiltinImporter'>
  import 'zipimport' # <class '_frozen_importlib.FrozenImporter'>
  # installed zipimport hook
  # C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\encodings\__pycache__\__init__.cpython-310.pyc matches C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\encodings\__init__.py
  # code object from 'C:\\Users\\Administrator\\AppData\\Local\\Programs\\Python\\Python310\\lib\\encodings\\__pycache__\\__init__.cpython-310.pyc'  
  # C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\__pycache__\codecs.cpython-310.pyc matches C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\codecs.py
  # code object from 'C:\\Users\\Administrator\\AppData\\Local\\Programs\\Python\\Python310\\lib\\__pycache__\\codecs.cpython-310.pyc'
  import '_codecs' # <class '_frozen_importlib.BuiltinImporter'>
  import 'codecs' # <_frozen_importlib_external.SourceFileLoader object at 0x000001270F87EE00>
  # C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\encodings\__pycache__\aliases.cpython-310.pyc matches C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\encodings\aliases.py
  # code object from 'C:\\Users\\Administrator\\AppData\\Local\\Programs\\Python\\Python310\\lib\\encodings\\__pycache__\\aliases.cpython-310.pyc'   
  import 'encodings.aliases' # <_frozen_importlib_external.SourceFileLoader object at 0x000001270FC543A0>
  import 'encodings' # <_frozen_importlib_external.SourceFileLoader object at 0x000001270F87EC50>
  # C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\encodings\__pycache__\utf_8.cpython-310.pyc matches C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\encodings\utf_8.py
  # code object from 'C:\\Users\\Administrator\\AppData\\Local\\Programs\\Python\\Python310\\lib\\encodings\\__pycache__\\utf_8.cpython-310.pyc'
  import 'encodings.utf_8' # <_frozen_importlib_external.SourceFileLoader object at 0x000001270F87E9B0>
  # C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\encodings\__pycache__\cp932.cpython-310.pyc matches C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\encodings\cp932.py
  # code object from 'C:\\Users\\Administrator\\AppData\\Local\\Programs\\Python\\Python310\\lib\\encodings\\__pycache__\\cp932.cpython-310.pyc'     
  import '_codecs_jp' # <class '_frozen_importlib.BuiltinImporter'>
  import '_multibytecodec' # <class '_frozen_importlib.BuiltinImporter'>
  import 'encodings.cp932' # <_frozen_importlib_external.SourceFileLoader object at 0x000001270FC544F0>
  import '_signal' # <class '_frozen_importlib.BuiltinImporter'>
  # C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\__pycache__\io.cpython-310.pyc matches C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\io.py
  # code object from 'C:\\Users\\Administrator\\AppData\\Local\\Programs\\Python\\Python310\\lib\\__pycache__\\io.cpython-310.pyc'
  # C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\__pycache__\abc.cpython-310.pyc matches C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\abc.py
  # code object from 'C:\\Users\\Administrator\\AppData\\Local\\Programs\\Python\\Python310\\lib\\__pycache__\\abc.cpython-310.pyc'
  import '_abc' # <class '_frozen_importlib.BuiltinImporter'>
  import 'abc' # <_frozen_importlib_external.SourceFileLoader object at 0x000001270FC54B50>
  import 'io' # <_frozen_importlib_external.SourceFileLoader object at 0x000001270FC54940>
  # C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\__pycache__\site.cpython-310.pyc matches C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\site.py
  # code object from 'C:\\Users\\Administrator\\AppData\\Local\\Programs\\Python\\Python310\\lib\\__pycache__\\site.cpython-310.pyc'
  # C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\__pycache__\os.cpython-310.pyc matches C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\os.py
  # code object from 'C:\\Users\\Administrator\\AppData\\Local\\Programs\\Python\\Python310\\lib\\__pycache__\\os.cpython-310.pyc'
  # C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\__pycache__\stat.cpython-310.pyc matches C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\stat.py
  # code object from 'C:\\Users\\Administrator\\AppData\\Local\\Programs\\Python\\Python310\\lib\\__pycache__\\stat.cpython-310.pyc'
  import '_stat' # <class '_frozen_importlib.BuiltinImporter'>
  import 'stat' # <_frozen_importlib_external.SourceFileLoader object at 0x000001270FC56DA0>
  # C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\__pycache__\_collections_abc.cpython-310.pyc matches C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\_collections_abc.py
  # code object from 'C:\\Users\\Administrator\\AppData\\Local\\Programs\\Python\\Python310\\lib\\__pycache__\\_collections_abc.cpython-310.pyc'     
  import '_collections_abc' # <_frozen_importlib_external.SourceFileLoader object at 0x000001270FC570D0>
  # C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\__pycache__\ntpath.cpython-310.pyc matches C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\ntpath.py
  # code object from 'C:\\Users\\Administrator\\AppData\\Local\\Programs\\Python\\Python310\\lib\\__pycache__\\ntpath.cpython-310.pyc'
  # C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\__pycache__\genericpath.cpython-310.pyc matches C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\genericpath.py
  # code object from 'C:\\Users\\Administrator\\AppData\\Local\\Programs\\Python\\Python310\\lib\\__pycache__\\genericpath.cpython-310.pyc'
  import 'genericpath' # <_frozen_importlib_external.SourceFileLoader object at 0x000001270FC9DB10>
  import 'ntpath' # <_frozen_importlib_external.SourceFileLoader object at 0x000001270FC57280>
  import 'os' # <_frozen_importlib_external.SourceFileLoader object at 0x000001270FC559C0>
  # C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\__pycache__\_sitebuiltins.cpython-310.pyc matches C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\_sitebuiltins.py
  # code object from 'C:\\Users\\Administrator\\AppData\\Local\\Programs\\Python\\Python310\\lib\\__pycache__\\_sitebuiltins.cpython-310.pyc'
  import '_sitebuiltins' # <_frozen_importlib_external.SourceFileLoader object at 0x000001270FC56A10>
  Processing user site-packages
  Processing global site-packages
  Adding directory: 'C:\\Users\\Administrator\\AppData\\Local\\Programs\\Python\\Python310'
  Adding directory: 'C:\\Users\\Administrator\\AppData\\Local\\Programs\\Python\\Python310\\lib\\site-packages'
  Processing .pth file: 'C:\\Users\\Administrator\\AppData\\Local\\Programs\\Python\\Python310\\lib\\site-packages\\distutils-precedence.pth'        
  # C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\site-packages\_distutils_hack\__pycache__\__init__.cpython-310.pyc matches C:\Users\Administrator\AppData\Local\Programs\Python\Python310\lib\site-packages\_distutils_hack\__init__.py
  # code object from 'C:\\Users\\Administrator\\AppData\\Local\\Programs\\Python\\Python310\\lib\\site-packages\\_distutils_hack\\__pycache__\\__init__.cpython-310.pyc'
  import '_distutils_hack' # <_frozen_importlib_external.SourceFileLoader object at 0x000001270FC9EB30>
  Processing .pth file: 'C:\\Users\\Administrator\\AppData\\Local\\Programs\\Python\\Python310\\lib\\site-packages\\easy-install.pth'
  import 'site' # <_frozen_importlib_external.SourceFileLoader object at 0x000001270FC55360>
  Python 3.10.5 (tags/v3.10.5:f377153, Jun  6 2022, 16:14:13) [MSC v.1929 64 bit (AMD64)] on win32
  Type "help", "copyright", "credits" or "license" for more information.
  import 'atexit' # <class '_frozen_importlib.BuiltinImporter'>
  >>> 
  >>> ^Z 👈 Ctrl + Zで“^Z”を入力しEnterキーで終了。

  # clear builtins._
  # clear sys.path
  # clear sys.argv
  # clear sys.ps1
  # clear sys.ps2
  # clear sys.last_type
  # clear sys.last_value
  # clear sys.last_traceback
  # clear sys.path_hooks
  # clear sys.path_importer_cache
  # clear sys.meta_path
  # clear sys.__interactivehook__
  # restore sys.stdin
  # restore sys.stdout
  # restore sys.stderr
  # cleanup[2] removing sys
  # cleanup[2] removing builtins
  # cleanup[2] removing _frozen_importlib
  # cleanup[2] removing _imp
  # cleanup[2] removing _thread
  # cleanup[2] removing _warnings
  # cleanup[2] removing _weakref
  # cleanup[2] removing _io
  # cleanup[2] removing marshal
  # cleanup[2] removing nt
  # cleanup[2] removing winreg
  # cleanup[2] removing _frozen_importlib_external
  # cleanup[2] removing time
  # cleanup[2] removing zipimport
  # destroy zipimport
  # cleanup[2] removing _codecs
  # cleanup[2] removing codecs
  # cleanup[2] removing encodings.aliases
  # cleanup[2] removing encodings
  # destroy encodings
  # cleanup[2] removing encodings.utf_8
  # cleanup[2] removing _codecs_jp
  # cleanup[2] removing _multibytecodec
  # cleanup[2] removing encodings.cp932
  # cleanup[2] removing _signal
  # cleanup[2] removing _abc
  # cleanup[2] removing abc
  # cleanup[2] removing io
  # cleanup[2] removing __main__
  # destroy __main__
  # cleanup[2] removing _stat
  # cleanup[2] removing stat
  # cleanup[2] removing _collections_abc
  # destroy _collections_abc
  # cleanup[2] removing genericpath
  # cleanup[2] removing ntpath
  # cleanup[2] removing os.path
  # cleanup[2] removing os
  # cleanup[2] removing _sitebuiltins
  # cleanup[2] removing _distutils_hack
  # destroy _distutils_hack
  # cleanup[2] removing site
  # destroy site
  # cleanup[2] removing atexit
  # destroy _signal
  # destroy _sitebuiltins
  # destroy io
  # destroy atexit
  # cleanup[3] wiping os
  # destroy abc
  # destroy ntpath
  # cleanup[3] wiping genericpath
  # cleanup[3] wiping stat
  # cleanup[3] wiping _stat
  # destroy _stat
  # cleanup[3] wiping _abc
  # cleanup[3] wiping encodings.cp932
  # cleanup[3] wiping _multibytecodec
  # cleanup[3] wiping _codecs_jp
  # destroy _codecs_jp
  # cleanup[3] wiping encodings.utf_8
  # cleanup[3] wiping encodings.aliases
  # cleanup[3] wiping codecs
  # cleanup[3] wiping _codecs
  # cleanup[3] wiping time
  # cleanup[3] wiping _frozen_importlib_external
  # cleanup[3] wiping winreg
  # cleanup[3] wiping nt
  # cleanup[3] wiping marshal
  # cleanup[3] wiping _io
  # cleanup[3] wiping _weakref
  # cleanup[3] wiping _warnings
  # cleanup[3] wiping _thread
  # cleanup[3] wiping _imp
  # cleanup[3] wiping _frozen_importlib
  # destroy _weakref
  # cleanup[3] wiping sys
  # cleanup[3] wiping builtins
  # destroy winreg
  # destroy _frozen_importlib_external
  # destroy _imp
  # destroy io
  # destroy marshal
  # destroy time
  # destroy _warnings
  # destroy os
  # destroy stat
  # destroy genericpath
  # destroy nt
  # destroy _abc
  # destroy _frozen_importlib
  # destroy codecs
  # destroy sys
  # destroy encodings.aliases
  # destroy encodings.utf_8
  # destroy encodings.cp932
  # destroy _codecs
  # destroy builtins
  # destroy _multibytecodec
  # clear sys.audit hooks
  PS C:\XXXX> 👈 通常のプロンプトに戻った
  ```

:::
::::

## [pip]インストール済みの全パッケージを一覧で確認する方法

パッケージ管理システム「pip」では、`pip list`でインストール済みのパッケージ一覧を表示可能。

```powershell:コピー用
pip list
```

```powershell:インストール済みの全パッケージを一覧表示するコマンド（更新前）
PS C:\XXXX> pip list
Package                   Version
------------------------- --------
altgraph                  0.17.3
arrow                     1.2.3
autopep8                  2.0.2
Babel                     2.12.1
binaryornot               0.4.4
cachetools                5.3.1
certifi                   2023.5.7
chardet                   5.1.0
charset-normalizer        3.2.0
click                     8.1.4
colorama                  0.4.6
cookiecutter              2.2.3
EasyProcess               1.1
entrypoint2               1.1
et-xmlfile                1.1.0
flake8                    6.0.0
future                    0.18.3
idna                      3.4
Jinja2                    3.1.2
jinja2-time               0.2.0
lxml                      4.9.3
MarkupSafe                2.1.3
mccabe                    0.7.0
MouseInfo                 0.1.3
mss                       9.0.1
mypy                      1.4.1
mypy-extensions           1.0.0
numpy                     1.25.1
openpyxl                  3.1.2
packaging                 23.1
pandas                    2.0.3
pefile                    2023.2.7
Pillow                    10.0.0
pip                       23.1.2
pip-review                1.3.0
pyasn1                    0.5.0
PyAutoGUI                 0.9.54
pycodestyle               2.10.0
pycryptodome              3.18.0
pyflakes                  3.0.1
PyGetWindow               0.0.9
pyinstaller               5.13.0
pyinstaller-hooks-contrib 2023.5
PyMsgBox                  1.0.9
pyperclip                 1.8.2
PyRect                    0.2.0
pyscreenshot              3.1
PyScreeze                 0.1.29
pysmb                     1.2.9.1
python-dateutil           2.8.2
python-slugify            8.0.1
pytweening                1.0.7
pytz                      2023.3
pywin32-ctypes            0.2.2
PyYAML                    6.0
requests                  2.31.0
setuptools                68.0.0
six                       1.16.0
text-unidecode            1.3
tkcalendar                1.6.1
tkinterdnd2               0.3.0
tqdm                      4.65.0
ttkthemes                 3.2.2
typing_extensions         4.7.1
tzdata                    2023.3
urllib3                   2.0.3

[notice] A new release of pip is available: 23.1.2 -> 23.2
[notice] To update, run: python.exe -m pip install --upgrade pip
PS C:\XXXX>
```

## [pip]更新可能なパッケージのみ一括アップデートする方法

1. pipで更新可能なパッケージを確認
    `pip list -o`（もしくは`--outdated`）でインストール済みのパッケージ内で、
    更新があるパッケージを一覧表示する。

    ```powershell:コピー用
    pip list -o
    ```

    ```powershell:更新可能なパッケージの一覧表示コマンド
    PS C:\XXXX> pip list -o
    Package Version Latest Type
    ------- ------- ------ -----
    click   8.1.4   8.1.6  wheel
    pip     23.1.2  23.2   wheel
    PyYAML  6.0     6.0.1  wheel

    [notice] A new release of pip is available: 23.1.2 -> 23.2
    [notice] To update, run: python.exe -m pip install --upgrade pip
    PS C:\XXXX> 
    ```

    :::details 補足情報：最新に更新済みのパッケージのみ確認する場合（クリック・タップで折りたたみが開く）
    `pip list -u`（もしくは`--uptodate`）でインストール済みのパッケージ内で、
    更新済みのパッケージのみ（更新可能なパッケージは非表示）一覧表示する。

    ```powershell
    PS C:\XXXX> pip list -u
    Package                   Version
    ------------------------- --------
    altgraph                  0.17.3
    arrow                     1.2.3
    autopep8                  2.0.2
    Babel                     2.12.1
    binaryornot               0.4.4
    cachetools                5.3.1
    certifi                   2023.5.7
    chardet                   5.1.0
    charset-normalizer        3.2.0
    colorama                  0.4.6
    cookiecutter              2.2.3
    EasyProcess               1.1
    entrypoint2               1.1
    et-xmlfile                1.1.0
    flake8                    6.0.0
    future                    0.18.3
    idna                      3.4
    Jinja2                    3.1.2
    jinja2-time               0.2.0
    lxml                      4.9.3
    MarkupSafe                2.1.3
    mccabe                    0.7.0
    MouseInfo                 0.1.3
    mss                       9.0.1
    mypy                      1.4.1
    mypy-extensions           1.0.0
    numpy                     1.25.1
    openpyxl                  3.1.2
    packaging                 23.1
    pandas                    2.0.3
    pefile                    2023.2.7
    Pillow                    10.0.0
    pip-review                1.3.0
    pyasn1                    0.5.0
    PyAutoGUI                 0.9.54
    pycodestyle               2.10.0
    pycryptodome              3.18.0
    pyflakes                  3.0.1
    PyGetWindow               0.0.9
    pyinstaller               5.13.0
    pyinstaller-hooks-contrib 2023.5
    PyMsgBox                  1.0.9
    pyperclip                 1.8.2
    PyRect                    0.2.0
    pyscreenshot              3.1
    PyScreeze                 0.1.29
    pysmb                     1.2.9.1
    python-dateutil           2.8.2
    python-slugify            8.0.1
    pytweening                1.0.7
    pytz                      2023.3
    pywin32-ctypes            0.2.2
    requests                  2.31.0
    setuptools                68.0.0
    six                       1.16.0
    text-unidecode            1.3
    tkcalendar                1.6.1
    tkinterdnd2               0.3.0
    toml                      0.10.2
    tomli                     2.0.1
    tqdm                      4.65.0
    ttkthemes                 3.2.2
    typing_extensions         4.7.1
    tzdata                    2023.3
    urllib3                   2.0.3

    [notice] A new release of pip is available: 23.1.2 -> 23.2
    [notice] To update, run: python.exe -m pip install --upgrade pip
    PS C:\XXXX> 
    ```

    :::
1. pip-reviewコマンドで一括アップデート
    pip支援パッケージ「pip-review」により更新可能なパッケージを一括してアップデート可能。
    なお、pip-reviewコマンドでは下記の2種類の方法でアップデートできる。
    - すべてのパッケージを一括してアップデートする方法
    - パッケージごとに更新有無を選択しアップデートする方法

    :::details 参考情報：pip-reviewをインストールしていない場合（クリック・タップで折りたたみが開く）
    インストールしていない場合、pipコマンドで`pip-review`を導入する。

    ```powershell
    PS C:\XXXX> pip install pip-review
    ```

    :::
    - オプション「--auto」で**すべてをアップデート**する場合

        ```powershell:コピー用
        pip-review --auto
        ```

        ```powershell:すべてのパッケージのアップデートコマンド
        PS C:\XXXX> pip-review --auto
        ```

        :::details 参考情報：アップデートが無かった場合の表示（クリック・タップで折りたたみが開く）

        ```powershell
        PS C:\XXXX> pip-review --auto                                                                   
        Everything up-to-date
        PS C:\XXXX> 
        ```

        :::
    - オプション「--interactive」で**パッケージごとに更新有無を選択**する場合

        ```powershell:コピー用
        pip-review --interactive
        ```

        ```powershell:パッケージごとに更新有無を選択するアップデートコマンド
        PS C:\XXXX> pip-review --interactive
        click==8.1.6 is available (you have 8.1.4)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit y
        pip==23.2 is available (you have 23.1.2)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        PyYAML==6.0.1 is available (you have 6.0)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        Requirement already satisfied: click in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (8.1.4)
        Collecting click
        Downloading click-8.1.6-py3-none-any.whl (97 kB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 97.9/97.9 kB 1.9 MB/s eta 0:00:00
        Requirement already satisfied: pip in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (23.1.2)
        Collecting pip
        Downloading pip-23.2-py3-none-any.whl (2.1 MB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 2.1/2.1 MB 8.3 MB/s eta 0:00:00
        Requirement already satisfied: PyYAML in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (6.0)
        Collecting PyYAML
        Downloading PyYAML-6.0.1-cp310-cp310-win_amd64.whl (145 kB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 145.3/145.3 kB 8.4 MB/s eta 0:00:00
        Requirement already satisfied: colorama in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from click) (0.4.6)
        Installing collected packages: PyYAML, pip, click
        Attempting uninstall: PyYAML
            Found existing installation: PyYAML 6.0
            Uninstalling PyYAML-6.0:
            Successfully uninstalled PyYAML-6.0
        Attempting uninstall: pip
            Found existing installation: pip 23.1.2
            Uninstalling pip-23.1.2:
            Successfully uninstalled pip-23.1.2
        Attempting uninstall: click
            Found existing installation: click 8.1.4
            Uninstalling click-8.1.4:
            Successfully uninstalled click-8.1.4
        Successfully installed PyYAML-6.0.1 click-8.1.6 pip-23.2
        PS C:\XXXX>
        ```

1. アップデートが完了した事を確認

    ```powershell:コピー用
    pip list
    ```

    ```powershell:インストール済みの全パッケージを一覧表示するコマンド（更新後）
    PS C:\XXXX> pip list
    Package                   Version
    ------------------------- --------
    altgraph                  0.17.3
    arrow                     1.2.3
    autopep8                  2.0.2
    Babel                     2.12.1
    binaryornot               0.4.4
    cachetools                5.3.1
    certifi                   2023.5.7
    chardet                   5.1.0
    charset-normalizer        3.2.0
    click                     8.1.6        👈 今回、更新
    colorama                  0.4.6
    cookiecutter              2.2.3
    EasyProcess               1.1
    entrypoint2               1.1
    et-xmlfile                1.1.0
    flake8                    6.0.0
    future                    0.18.3
    idna                      3.4
    Jinja2                    3.1.2
    jinja2-time               0.2.0
    lxml                      4.9.3
    MarkupSafe                2.1.3
    mccabe                    0.7.0
    MouseInfo                 0.1.3
    mss                       9.0.1
    mypy                      1.4.1
    mypy-extensions           1.0.0
    numpy                     1.25.1
    openpyxl                  3.1.2
    packaging                 23.1
    pandas                    2.0.3
    pefile                    2023.2.7
    Pillow                    10.0.0
    pip                       23.2        👈 今回、更新
    pip-review                1.3.0
    pyasn1                    0.5.0
    PyAutoGUI                 0.9.54
    pycodestyle               2.10.0
    pycryptodome              3.18.0
    pyflakes                  3.0.1
    PyGetWindow               0.0.9
    pyinstaller               5.13.0
    pyinstaller-hooks-contrib 2023.5
    PyMsgBox                  1.0.9
    pyperclip                 1.8.2
    PyRect                    0.2.0
    pyscreenshot              3.1
    PyScreeze                 0.1.29
    pysmb                     1.2.9.1
    python-dateutil           2.8.2
    python-slugify            8.0.1
    pytweening                1.0.7
    pytz                      2023.3
    pywin32-ctypes            0.2.2
    PyYAML                    6.0.1         👈 今回、更新
    requests                  2.31.0
    setuptools                68.0.0
    six                       1.16.0
    text-unidecode            1.3
    tkcalendar                1.6.1
    tkinterdnd2               0.3.0
    toml                      0.10.2
    tomli                     2.0.1
    tqdm                      4.65.0
    ttkthemes                 3.2.2
    typing_extensions         4.7.1
    tzdata                    2023.3
    urllib3                   2.0.3
    PS C:\XXXX>
    ```

## 参考情報

https://python.softmoco.com/devenv/how-to-check-python-version-windows.php#:~:text=コマンドプロンプトで%20python%20,することができます。
https://magazine.techacademy.jp/magazine/46571
https://pkunallnet.com/pcinfo/windows/pipupdate/
https://dragstar.hatenablog.com/entry/2016/09/02/113243

## まとめ

- Pythonのバージョン確認するコマンド
    `python -V` 👈 大文字のブイ
- pipでインストール済みのパッケージをすべて確認するコマンド
    `pip list`
- pipでインストール済みのパッケージ内で更新可能なパッケージを確認するコマンド
    `pip list -o`
- pipでインストール済みのパッケージ内で更新可能なパッケージをアップデートするコマンド
    - すべてをアップデートする場合
        `pip-review --auto`
    - パッケージごと更新有無を選択する場合
        `pip-review --interactive`

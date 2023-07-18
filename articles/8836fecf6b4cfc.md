---
title: "Pythonとpipパッケージのバージョン確認 & 一括アップデート方法"
emoji: "🐍"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["python", "pip"]
published: true
---
## 概要
仮想の開発環境を久しぶりに立ち上げて`pip list`でインストール済みのパッケージ一覧を確認した結果、
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

:::details 参考情報：VirtualBoxで設定可能なプロセッサー最大値 と 物理CPUのコア数（もしくはスレッド数）と差異あり
[こちら](https://superuser.com/questions/540407/why-does-virtualbox-show-more-cpus-than-available)の情報を参考にするとVirtualBoxの`Processor`の設定値は、
多くとも物理CPUの `スレッド数 - 1`（スレッド数が4の場合は、3が最大値） にしないといけない。
仮に物理CPUのスレッド数以上で設定してしまうと、ホストOSの挙動がおかしくなる可能性ありとの事。
そもそも何故、VirtualBox側でスレッド数を超える値が設定可能なのかという点は、よくわからなかった。
- 参考情報
    https://superuser.com/questions/540407/why-does-virtualbox-show-more-cpus-than-available
    https://atmarkit.itmedia.co.jp/ait/articles/1010/14/news128.html#:~:text=VirtualBoxの仕様では,倍までしか設定できない。
:::
### IDE
#### VS Code 本体
```powershell
PS C:\XXXX> code -v
1.80.0
660393deaaa6d1996740ff4880f1bad43768c814
x64
PS C:\XXXX> 
```
https://www.curict.com/item/00/007bbb1.html#:~:text=Visual%20Studio%20Codeのバージョン,オプションを使用します。
#### VS Code 拡張機能
```powershell
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
::::details 補足事項：間違えて小文字のブイ（v）を指定した場合
- 間違えた場合はverbose（詳細）モードが起動
    間違えて`python -v`と小文字のブイ（v）で入力してしまうと、
    Pythonのverbose（詳細）モードが起動する。
    
    verboseモードでは、python環境が立ち上がり手動でプログラムの検証が可能となる。

- 解決方法
  **verboseモードを終了したい場合**、「`Ctrl` + `Z`」で“^Z”を入力し`Enter`キーを入力する事で終了できる。

  :::details 実行例：verboseモードの起動と終了
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
```powershell:インストール済みの全パッケージを一覧表示するコマンド（更新前）
PS C:\XXXX> pip list
Package                   Version
------------------------- ---------
altgraph                  0.17.3
arrow                     1.2.3
autopep8                  2.0.1
Babel                     2.11.0
binaryornot               0.4.4
cachetools                5.3.0
certifi                   2022.12.7
chardet                   5.1.0
charset-normalizer        3.0.1
click                     8.1.3
colorama                  0.4.6
cookiecutter              2.1.1
et-xmlfile                1.1.0
flake8                    6.0.0
future                    0.18.3
idna                      3.4
Jinja2                    3.1.2
jinja2-time               0.2.0
lxml                      4.9.2
MarkupSafe                2.1.2
mccabe                    0.7.0
MouseInfo                 0.1.3
mypy                      1.0.0
mypy-extensions           1.0.0
numpy                     1.24.2
openpyxl                  3.1.1
packaging                 23.0
pandas                    1.5.3
pefile                    2023.2.7
Pillow                    9.4.0
pip                       23.0
pip-review                1.3.0
pyasn1                    0.4.8
PyAutoGUI                 0.9.53
pycodestyle               2.10.0
pycryptodome              3.17
pyflakes                  3.0.1
PyGetWindow               0.0.9
pyinstaller               5.8.0
pyinstaller-hooks-contrib 2023.0
PyMsgBox                  1.0.9
pyperclip                 1.8.2
PyRect                    0.2.0
PyScreeze                 0.1.28
pysmb                     1.2.9.1
python-dateutil           2.8.2
python-slugify            8.0.0
pytweening                1.0.4
pytz                      2022.7.1
pywin32-ctypes            0.2.0
PyYAML                    6.0
requests                  2.28.2
setuptools                67.3.2
six                       1.16.0
text-unidecode            1.3
tkcalendar                1.6.1
tkinterdnd2               0.3.0
tqdm                      4.64.1
ttkthemes                 3.2.2
typing_extensions         4.5.0
urllib3                   1.26.14

[notice] A new release of pip is available: 23.0 -> 23.1.2
[notice] To update, run: python.exe -m pip install --upgrade pip
PS C:\XXXX>
```

## [pip]更新可能なパッケージのみ一括アップデートする方法
1. pipで更新可能なパッケージを確認
    `pip list -o`（もしくは`--outdated`）でインストール済みのパッケージ内で、
    更新があるパッケージを一覧表示する。
    ```powershell:更新可能なパッケージの一覧表示コマンド
    PS C:\XXXX> pip list -o
    ```
    :::details 補足情報：最新に更新済みのパッケージのみ確認する場合
    `pip list -u`（もしくは`--uptodate`）でインストール済みのパッケージ内で、
    更新済みのパッケージのみ（更新可能なパッケージは非表示）一覧表示する。
    ```powershell
    PS C:\XXXX> pip list -u
    ```
    :::
1. pip-reviewコマンドで一括アップデート
    pip支援パッケージ「pip-review」により更新可能なパッケージを一括してアップデート可能。
    なお、pip-reviewコマンドでは下記の2種類の方法でアップデートできる。
    - すべてのパッケージを一括してアップデートする方法
    - パッケージごとに更新有無を選択しアップデートする方法

    :::details 参考情報：pip-reviewをインストールしていない場合
    インストールしていない場合、pipコマンドで`pip-review`を導入する。
    ```powershell
    PS C:\XXXX> pip install pip-review
    ```
    :::
    - オプション「--auto」で**すべてをアップデート**する場合
        ```powershell:すべてのパッケージのアップデートコマンド
        PS C:\XXXX> pip-review --auto
        ```
        :::details 参考情報：アップデートが無かった場合の表示
        ```powershell
        PS C:\XXXX> pip-review --auto                                                                   
        Everything up-to-date
        PS C:\XXXX> 
        ```
        :::
    - オプション「--interactive」で**パッケージごとに更新有無を選択**する場合
        ```powershell:パッケージごとに更新有無を選択するアップデートコマンド - 省略あり
        PS C:\XXXX> pip-review --interactive
        autopep8==2.0.2 is available (you have 2.0.1)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit y
        Babel==2.12.1 is available (you have 2.11.0)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        cachetools==5.3.1 is available (you have 5.3.0)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        certifi==2023.5.7 is available (you have 2022.12.7)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        charset-normalizer==3.2.0 is available (you have 3.0.1)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        click==8.1.4 is available (you have 8.1.3)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        
        ～ 省略 ～

        typing_extensions==4.7.1 is available (you have 4.5.0)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        urllib3==2.0.3 is available (you have 1.26.14)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        Requirement already satisfied: autopep8 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (2.0.1)
        Collecting autopep8
        Downloading autopep8-2.0.2-py2.py3-none-any.whl (45 kB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 45.2/45.2 kB 554.3 kB/s eta 0:00:00
        Requirement already satisfied: Babel in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (2.11.0)
        Collecting Babel
        Downloading Babel-2.12.1-py3-none-any.whl (10.1 MB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 10.1/10.1 MB 7.4 MB/s eta 0:00:00
        Requirement already satisfied: cachetools in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (5.3.0)
        Collecting cachetools
        Downloading cachetools-5.3.1-py3-none-any.whl (9.3 kB)
        Requirement already satisfied: certifi in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (2022.12.7)
        
        ～ 省略 ～

        Collecting tzdata>=2022.1
        Downloading tzdata-2023.3-py2.py3-none-any.whl (341 kB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 341.8/341.8 kB 10.7 MB/s eta 0:00:00
        Requirement already satisfied: pygetwindow>=0.0.5 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from PyAutoGUI) (0.0.9)
        Requirement already satisfied: pymsgbox in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from PyAutoGUI) (1.0.9)
        Requirement already satisfied: mouseinfo in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from PyAutoGUI) (0.1.3)
        Requirement already satisfied: altgraph in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from pyinstaller) (0.17.3)
        Requirement already satisfied: pefile>=2022.5.30 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from pyinstaller) (2023.2.7)
        Collecting pyscreenshot
        Downloading pyscreenshot-3.1-py3-none-any.whl (28 kB)
        Requirement already satisfied: text-unidecode>=1.3 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from python-slugify) (1.3)
        Requirement already satisfied: idna<4,>=2.5 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from requests) (3.4)
        Requirement already satisfied: chardet>=3.0.2 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from binaryornot>=0.4.4->cookiecutter) (5.1.0)
        Requirement already satisfied: pyrect in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from pygetwindow>=0.0.5->PyAutoGUI) (0.2.0)
        Requirement already satisfied: six>=1.5 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from python-dateutil>=2.8.2->pandas) (1.16.0)
        Requirement already satisfied: pyperclip in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from mouseinfo->PyAutoGUI) (1.8.2)
        Collecting mss
        Downloading mss-9.0.1-py3-none-any.whl (22 kB)
        Collecting entrypoint2
        Downloading entrypoint2-1.1-py2.py3-none-any.whl (9.9 kB)
        Collecting EasyProcess
        Downloading EasyProcess-1.1-py3-none-any.whl (8.7 kB)
        Building wheels for collected packages: PyAutoGUI, PyScreeze
        Building wheel for PyAutoGUI (pyproject.toml) ... done
        Created wheel for PyAutoGUI: filename=PyAutoGUI-0.9.54-py3-none-any.whl size=37601 sha256=cc5057c3905bdeafe8485347005d969b7ff6cf98f70c31141ef03df8b94047bc
        Stored in directory: c:\users\administrator\appdata\local\pip\cache\wheels\23\a7\1c\5a51aaff3bbe110be4ddf766d429cc9d2fae7a72fc1b843e56
        Building wheel for PyScreeze (pyproject.toml) ... done
        Created wheel for PyScreeze: filename=PyScreeze-0.1.29-py3-none-any.whl size=13485 sha256=cde2baab75fd783a396cc512b1599a89cf58c583e981925483b3f12565df168c
        Stored in directory: c:\users\administrator\appdata\local\pip\cache\wheels\43\aa\46\e91ba85339451aeec47733e4038d7ed73c0b4b633c6270a2ba
        Successfully built PyAutoGUI PyScreeze
        Installing collected packages: pytz, pytweening, entrypoint2, EasyProcess, urllib3, tzdata, typing_extensions, tqdm, setuptools, pywin32-ctypes, python-slugify, pyinstaller-hooks-contrib, pycryptodome, pyasn1, pip, Pillow, packaging, openpyxl, numpy, mss, MarkupSafe, lxml, click, charset-normalizer, certifi, cachetools, Babel, autopep8, requests, pyscreenshot, pyinstaller, pandas, mypy, PyScreeze, cookiecutter, PyAutoGUI
        Attempting uninstall: pytz
            Found existing installation: pytz 2022.7.1
            Uninstalling pytz-2022.7.1:
            Successfully uninstalled pytz-2022.7.1
        Attempting uninstall: pytweening
            Found existing installation: pytweening 1.0.4
            Uninstalling pytweening-1.0.4:
            Successfully uninstalled pytweening-1.0.4
        DEPRECATION: pytweening is being installed using the legacy 'setup.py install' method, because it does not have a 'pyproject.toml' and the 'wheel' package is not installed. pip 23.1 will enforce this behaviour change. A possible replacement is to enable the '--use-pep517' option. Discussion 
        can be found at https://github.com/pypa/pip/issues/8559
        Running setup.py install for pytweening ... done
        Attempting uninstall: urllib3
            Found existing installation: urllib3 1.26.14
            Uninstalling urllib3-1.26.14:
            Successfully uninstalled urllib3-1.26.14
        Attempting uninstall: typing_extensions
            Found existing installation: typing_extensions 4.5.0
            Uninstalling typing_extensions-4.5.0:
            Successfully uninstalled typing_extensions-4.5.0
        Attempting uninstall: tqdm
            Found existing installation: tqdm 4.64.1
            Uninstalling tqdm-4.64.1:
            Successfully uninstalled tqdm-4.64.1
        
        ～ 省略 ～

        Attempting uninstall: PyScreeze
            Found existing installation: PyScreeze 0.1.28
            Uninstalling PyScreeze-0.1.28:
            Successfully uninstalled PyScreeze-0.1.28
        Attempting uninstall: cookiecutter
            Found existing installation: cookiecutter 2.1.1
            Uninstalling cookiecutter-2.1.1:
            Successfully uninstalled cookiecutter-2.1.1
            Successfully uninstalled PyAutoGUI-0.9.53
        Successfully installed Babel-2.12.1 EasyProcess-1.1 MarkupSafe-2.1.3 Pillow-10.0.0 PyAutoGUI-0.9.54 PyScreeze-0.1.29 autopep8-2.0.2 cachetools-5.3.1 certifi-2023.5.7 charset-normalizer-3.2.0 click-8.1.4 cookiecutter-2.2.3 entrypoint2-1.1 lxml-4.9.3 mss-9.0.1 mypy-1.4.1 numpy-1.25.1 openpyxl-3.1.2 packaging-23.1 pandas-2.0.3 pip-23.1.2 pyasn1-0.5.0 pycryptodome-3.18.0 pyinstaller-5.13.0 pyinstaller-hooks-contrib-2023.5 pyscreenshot-3.1 python-slugify-8.0.1 pytweening-1.0.7 pytz-2023.3 pywin32-ctypes-0.2.2 requests-2.31.0 setuptools-68.0.0 tqdm-4.65.0 typing_extensions-4.7.1 tzdata-2023.3 urllib3-2.0.3
        PS C:\XXXX>
        ```
        ::: details 参考情報：パッケージごとに更新有無を選択するアップデートコマンド - すべての結果を表示
        上記は省略したコマンド結果だが、ここでは省略せずに、すべてのコマンド結果を表示。
        ```powershell
        PS C:\XXXX> pip-review --interactive
        autopep8==2.0.2 is available (you have 2.0.1)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit y
        Babel==2.12.1 is available (you have 2.11.0)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        cachetools==5.3.1 is available (you have 5.3.0)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        certifi==2023.5.7 is available (you have 2022.12.7)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        charset-normalizer==3.2.0 is available (you have 3.0.1)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        click==8.1.4 is available (you have 8.1.3)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        cookiecutter==2.2.3 is available (you have 2.1.1)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        lxml==4.9.3 is available (you have 4.9.2)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        MarkupSafe==2.1.3 is available (you have 2.1.2)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        mypy==1.4.1 is available (you have 1.0.0)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        numpy==1.25.1 is available (you have 1.24.2)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        openpyxl==3.1.2 is available (you have 3.1.1)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        packaging==23.1 is available (you have 23.0)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        pandas==2.0.3 is available (you have 1.5.3)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        Pillow==10.0.0 is available (you have 9.4.0)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        pip==23.1.2 is available (you have 23.0)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        pyasn1==0.5.0 is available (you have 0.4.8)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        PyAutoGUI==0.9.54 is available (you have 0.9.53)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        pycryptodome==3.18.0 is available (you have 3.17)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        pyinstaller==5.13.0 is available (you have 5.8.0)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        pyinstaller-hooks-contrib==2023.5 is available (you have 2023.0)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        PyScreeze==0.1.29 is available (you have 0.1.28)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        python-slugify==8.0.1 is available (you have 8.0.0)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        pytweening==1.0.7 is available (you have 1.0.4)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        pytz==2023.3 is available (you have 2022.7.1)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        pywin32-ctypes==0.2.2 is available (you have 0.2.0)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        requests==2.31.0 is available (you have 2.28.2)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        setuptools==68.0.0 is available (you have 67.3.2)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        tqdm==4.65.0 is available (you have 4.64.1)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        typing_extensions==4.7.1 is available (you have 4.5.0)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        urllib3==2.0.3 is available (you have 1.26.14)
        Upgrade now? [Y]es, [N]o, [A]ll, [Q]uit (y) y
        Requirement already satisfied: autopep8 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (2.0.1)
        Collecting autopep8
        Downloading autopep8-2.0.2-py2.py3-none-any.whl (45 kB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 45.2/45.2 kB 554.3 kB/s eta 0:00:00
        Requirement already satisfied: Babel in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (2.11.0)
        Collecting Babel
        Downloading Babel-2.12.1-py3-none-any.whl (10.1 MB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 10.1/10.1 MB 7.4 MB/s eta 0:00:00
        Requirement already satisfied: cachetools in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (5.3.0)
        Collecting cachetools
        Downloading cachetools-5.3.1-py3-none-any.whl (9.3 kB)
        Requirement already satisfied: certifi in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (2022.12.7)
        Collecting certifi
        Downloading certifi-2023.5.7-py3-none-any.whl (156 kB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 157.0/157.0 kB 3.1 MB/s eta 0:00:00
        Requirement already satisfied: charset-normalizer in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (3.0.1)
        Collecting charset-normalizer
        Downloading charset_normalizer-3.2.0-cp310-cp310-win_amd64.whl (96 kB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 96.9/96.9 kB 2.7 MB/s eta 0:00:00
        Requirement already satisfied: click in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (8.1.3)
        Collecting click
        Downloading click-8.1.4-py3-none-any.whl (98 kB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 98.2/98.2 kB 5.5 MB/s eta 0:00:00
        Requirement already satisfied: cookiecutter in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (2.1.1)
        Collecting cookiecutter
        Downloading cookiecutter-2.2.3-py3-none-any.whl (39 kB)
        Requirement already satisfied: lxml in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (4.9.2)
        Collecting lxml
        Downloading lxml-4.9.3-cp310-cp310-win_amd64.whl (3.8 MB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 3.8/3.8 MB 7.8 MB/s eta 0:00:00
        Requirement already satisfied: MarkupSafe in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (2.1.2)
        Collecting MarkupSafe
        Downloading MarkupSafe-2.1.3-cp310-cp310-win_amd64.whl (17 kB)
        Requirement already satisfied: mypy in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (1.0.0)
        Collecting mypy
        Downloading mypy-1.4.1-cp310-cp310-win_amd64.whl (8.8 MB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 8.8/8.8 MB 7.6 MB/s eta 0:00:00
        Requirement already satisfied: numpy in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (1.24.2)
        Collecting numpy
        Downloading numpy-1.25.1-cp310-cp310-win_amd64.whl (15.0 MB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 15.0/15.0 MB 4.6 MB/s eta 0:00:00
        Requirement already satisfied: openpyxl in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (3.1.1)
        Collecting openpyxl
        Downloading openpyxl-3.1.2-py2.py3-none-any.whl (249 kB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 250.0/250.0 kB 16.0 MB/s eta 0:00:00
        Requirement already satisfied: packaging in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (23.0)
        Collecting packaging
        Downloading packaging-23.1-py3-none-any.whl (48 kB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 48.9/48.9 kB 2.6 MB/s eta 0:00:00
        Requirement already satisfied: pandas in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (1.5.3)
        Collecting pandas
        Downloading pandas-2.0.3-cp310-cp310-win_amd64.whl (10.7 MB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 10.7/10.7 MB 5.6 MB/s eta 0:00:00
        Requirement already satisfied: Pillow in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (9.4.0)
        Collecting Pillow
        Downloading Pillow-10.0.0-cp310-cp310-win_amd64.whl (2.5 MB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 2.5/2.5 MB 3.5 MB/s eta 0:00:00
        Requirement already satisfied: pip in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (23.0)
        Collecting pip
        Downloading pip-23.1.2-py3-none-any.whl (2.1 MB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 2.1/2.1 MB 8.2 MB/s eta 0:00:00
        Requirement already satisfied: pyasn1 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (0.4.8)
        Collecting pyasn1
        Downloading pyasn1-0.5.0-py2.py3-none-any.whl (83 kB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 83.9/83.9 kB 4.6 MB/s eta 0:00:00
        Requirement already satisfied: PyAutoGUI in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (0.9.53)
        Collecting PyAutoGUI
        Downloading PyAutoGUI-0.9.54.tar.gz (61 kB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 61.2/61.2 kB 1.6 MB/s eta 0:00:00
        Installing build dependencies ... done
        Getting requirements to build wheel ... done
        Preparing metadata (pyproject.toml) ... done
        Requirement already satisfied: pycryptodome in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (3.17)
        Collecting pycryptodome
        Downloading pycryptodome-3.18.0-cp35-abi3-win_amd64.whl (1.7 MB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 1.7/1.7 MB 9.2 MB/s eta 0:00:00
        Requirement already satisfied: pyinstaller in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (5.8.0)
        Collecting pyinstaller
        Downloading pyinstaller-5.13.0-py3-none-win_amd64.whl (1.3 MB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 1.3/1.3 MB 7.3 MB/s eta 0:00:00
        Requirement already satisfied: pyinstaller-hooks-contrib in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (2023.0)
        Collecting pyinstaller-hooks-contrib
        Downloading pyinstaller_hooks_contrib-2023.5-py2.py3-none-any.whl (273 kB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 273.1/273.1 kB 5.6 MB/s eta 0:00:00
        Requirement already satisfied: PyScreeze in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (0.1.28)
        Collecting PyScreeze
        Downloading PyScreeze-0.1.29.tar.gz (25 kB)
        Installing build dependencies ... done
        Getting requirements to build wheel ... done
        Preparing metadata (pyproject.toml) ... done
        Requirement already satisfied: python-slugify in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (8.0.0)
        Collecting python-slugify
        Downloading python_slugify-8.0.1-py2.py3-none-any.whl (9.7 kB)
        Requirement already satisfied: pytweening in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (1.0.4)
        Collecting pytweening
        Downloading pytweening-1.0.7.tar.gz (168 kB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 168.2/168.2 kB 4.9 MB/s eta 0:00:00
        Preparing metadata (setup.py) ... done
        Requirement already satisfied: pytz in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (2022.7.1)
        Collecting pytz
        Downloading pytz-2023.3-py2.py3-none-any.whl (502 kB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 502.3/502.3 kB 4.5 MB/s eta 0:00:00
        Requirement already satisfied: pywin32-ctypes in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (0.2.0)
        Collecting pywin32-ctypes
        Downloading pywin32_ctypes-0.2.2-py3-none-any.whl (30 kB)
        Requirement already satisfied: requests in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (2.28.2)
        Collecting requests
        Downloading requests-2.31.0-py3-none-any.whl (62 kB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 62.6/62.6 kB 1.6 MB/s eta 0:00:00
        Requirement already satisfied: setuptools in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (67.3.2)
        Collecting setuptools
        Using cached setuptools-68.0.0-py3-none-any.whl (804 kB)
        Requirement already satisfied: tqdm in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (4.64.1)
        Collecting tqdm
        Downloading tqdm-4.65.0-py3-none-any.whl (77 kB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 77.1/77.1 kB 4.5 MB/s eta 0:00:00
        Requirement already satisfied: typing_extensions in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (4.5.0)
        Collecting typing_extensions
        Downloading typing_extensions-4.7.1-py3-none-any.whl (33 kB)
        Requirement already satisfied: urllib3 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (1.26.14)
        Collecting urllib3
        Downloading urllib3-2.0.3-py3-none-any.whl (123 kB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 123.6/123.6 kB 3.7 MB/s eta 0:00:00
        Requirement already satisfied: tomli in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from autopep8) (2.0.1)
        Requirement already satisfied: pycodestyle>=2.10.0 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from autopep8) (2.10.0)
        Requirement already satisfied: colorama in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from click) (0.4.6)
        Requirement already satisfied: arrow in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from cookiecutter) (1.2.3)
        Requirement already satisfied: pyyaml>=5.3.1 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from cookiecutter) (6.0)
        Requirement already satisfied: Jinja2<4.0.0,>=2.7 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from cookiecutter) (3.1.2)
        Requirement already satisfied: binaryornot>=0.4.4 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from cookiecutter) (0.4.4)
        Requirement already satisfied: mypy-extensions>=1.0.0 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from mypy) (1.0.0)
        Requirement already satisfied: et-xmlfile in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from openpyxl) (1.1.0)
        Requirement already satisfied: python-dateutil>=2.8.2 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from pandas) (2.8.2)
        Collecting tzdata>=2022.1
        Downloading tzdata-2023.3-py2.py3-none-any.whl (341 kB)
            ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 341.8/341.8 kB 10.7 MB/s eta 0:00:00
        Requirement already satisfied: pygetwindow>=0.0.5 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from PyAutoGUI) (0.0.9)
        Requirement already satisfied: pymsgbox in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from PyAutoGUI) (1.0.9)
        Requirement already satisfied: mouseinfo in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from PyAutoGUI) (0.1.3)
        Requirement already satisfied: altgraph in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from pyinstaller) (0.17.3)
        Requirement already satisfied: pefile>=2022.5.30 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from pyinstaller) (2023.2.7)
        Collecting pyscreenshot
        Downloading pyscreenshot-3.1-py3-none-any.whl (28 kB)
        Requirement already satisfied: text-unidecode>=1.3 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from python-slugify) (1.3)
        Requirement already satisfied: idna<4,>=2.5 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from requests) (3.4)
        Requirement already satisfied: chardet>=3.0.2 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from binaryornot>=0.4.4->cookiecutter) (5.1.0)
        Requirement already satisfied: pyrect in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from pygetwindow>=0.0.5->PyAutoGUI) (0.2.0)
        Requirement already satisfied: six>=1.5 in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from python-dateutil>=2.8.2->pandas) (1.16.0)
        Requirement already satisfied: pyperclip in c:\users\administrator\appdata\local\programs\python\python310\lib\site-packages (from mouseinfo->PyAutoGUI) (1.8.2)
        Collecting mss
        Downloading mss-9.0.1-py3-none-any.whl (22 kB)
        Collecting entrypoint2
        Downloading entrypoint2-1.1-py2.py3-none-any.whl (9.9 kB)
        Collecting EasyProcess
        Downloading EasyProcess-1.1-py3-none-any.whl (8.7 kB)
        Building wheels for collected packages: PyAutoGUI, PyScreeze
        Building wheel for PyAutoGUI (pyproject.toml) ... done
        Created wheel for PyAutoGUI: filename=PyAutoGUI-0.9.54-py3-none-any.whl size=37601 sha256=cc5057c3905bdeafe8485347005d969b7ff6cf98f70c31141ef03df8b94047bc
        Stored in directory: c:\users\administrator\appdata\local\pip\cache\wheels\23\a7\1c\5a51aaff3bbe110be4ddf766d429cc9d2fae7a72fc1b843e56
        Building wheel for PyScreeze (pyproject.toml) ... done
        Created wheel for PyScreeze: filename=PyScreeze-0.1.29-py3-none-any.whl size=13485 sha256=cde2baab75fd783a396cc512b1599a89cf58c583e981925483b3f12565df168c
        Stored in directory: c:\users\administrator\appdata\local\pip\cache\wheels\43\aa\46\e91ba85339451aeec47733e4038d7ed73c0b4b633c6270a2ba
        Successfully built PyAutoGUI PyScreeze
        Installing collected packages: pytz, pytweening, entrypoint2, EasyProcess, urllib3, tzdata, typing_extensions, tqdm, setuptools, pywin32-ctypes, python-slugify, pyinstaller-hooks-contrib, pycryptodome, pyasn1, pip, Pillow, packaging, openpyxl, numpy, mss, MarkupSafe, lxml, click, charset-normalizer, certifi, cachetools, Babel, autopep8, requests, pyscreenshot, pyinstaller, pandas, mypy, PyScreeze, cookiecutter, PyAutoGUI
        Attempting uninstall: pytz
            Found existing installation: pytz 2022.7.1
            Uninstalling pytz-2022.7.1:
            Successfully uninstalled pytz-2022.7.1
        Attempting uninstall: pytweening
            Found existing installation: pytweening 1.0.4
            Uninstalling pytweening-1.0.4:
            Successfully uninstalled pytweening-1.0.4
        DEPRECATION: pytweening is being installed using the legacy 'setup.py install' method, because it does not have a 'pyproject.toml' and the 'wheel' package is not installed. pip 23.1 will enforce this behaviour change. A possible replacement is to enable the '--use-pep517' option. Discussion 
        can be found at https://github.com/pypa/pip/issues/8559
        Running setup.py install for pytweening ... done
        Attempting uninstall: urllib3
            Found existing installation: urllib3 1.26.14
            Uninstalling urllib3-1.26.14:
            Successfully uninstalled urllib3-1.26.14
        Attempting uninstall: typing_extensions
            Found existing installation: typing_extensions 4.5.0
            Uninstalling typing_extensions-4.5.0:
            Successfully uninstalled typing_extensions-4.5.0
        Attempting uninstall: tqdm
            Found existing installation: tqdm 4.64.1
            Uninstalling tqdm-4.64.1:
            Successfully uninstalled tqdm-4.64.1
        Attempting uninstall: setuptools
            Found existing installation: setuptools 67.3.2
            Uninstalling setuptools-67.3.2:
            Successfully uninstalled setuptools-67.3.2
        Attempting uninstall: pywin32-ctypes
            Found existing installation: pywin32-ctypes 0.2.0
            Uninstalling pywin32-ctypes-0.2.0:
            Successfully uninstalled pywin32-ctypes-0.2.0
        Attempting uninstall: python-slugify
            Found existing installation: python-slugify 8.0.0
            Uninstalling python-slugify-8.0.0:
            Successfully uninstalled python-slugify-8.0.0
        Attempting uninstall: pyinstaller-hooks-contrib
            Found existing installation: pyinstaller-hooks-contrib 2023.0
            Uninstalling pyinstaller-hooks-contrib-2023.0:
            Successfully uninstalled pyinstaller-hooks-contrib-2023.0
        Attempting uninstall: pycryptodome
            Found existing installation: pycryptodome 3.17
            Uninstalling pycryptodome-3.17:
            Successfully uninstalled pycryptodome-3.17
        Attempting uninstall: pyasn1
            Found existing installation: pyasn1 0.4.8
            Uninstalling pyasn1-0.4.8:
            Successfully uninstalled pyasn1-0.4.8
        Attempting uninstall: pip
            Found existing installation: pip 23.0
            Uninstalling pip-23.0:
            Successfully uninstalled pip-23.0
        Attempting uninstall: Pillow
            Found existing installation: Pillow 9.4.0
            Uninstalling Pillow-9.4.0:
            Successfully uninstalled Pillow-9.4.0
        Attempting uninstall: packaging
            Found existing installation: packaging 23.0
            Uninstalling packaging-23.0:
            Successfully uninstalled packaging-23.0
        Attempting uninstall: openpyxl
            Found existing installation: openpyxl 3.1.1
            Uninstalling openpyxl-3.1.1:
            Successfully uninstalled openpyxl-3.1.1
        Attempting uninstall: numpy
            Found existing installation: numpy 1.24.2
            Uninstalling numpy-1.24.2:
            Successfully uninstalled numpy-1.24.2
        Attempting uninstall: MarkupSafe
            Found existing installation: MarkupSafe 2.1.2
            Uninstalling MarkupSafe-2.1.2:
            Successfully uninstalled MarkupSafe-2.1.2
        Attempting uninstall: lxml
            Found existing installation: lxml 4.9.2
            Uninstalling lxml-4.9.2:
            Successfully uninstalled lxml-4.9.2
        Attempting uninstall: click
            Found existing installation: click 8.1.3
            Uninstalling click-8.1.3:
            Successfully uninstalled click-8.1.3
        Attempting uninstall: charset-normalizer
            Found existing installation: charset-normalizer 3.0.1
            Uninstalling charset-normalizer-3.0.1:
            Successfully uninstalled charset-normalizer-3.0.1
        Attempting uninstall: certifi
            Found existing installation: certifi 2022.12.7
            Uninstalling certifi-2022.12.7:
            Successfully uninstalled certifi-2022.12.7
        Attempting uninstall: cachetools
            Found existing installation: cachetools 5.3.0
            Uninstalling cachetools-5.3.0:
            Successfully uninstalled cachetools-5.3.0
        Attempting uninstall: Babel
            Found existing installation: Babel 2.11.0
            Uninstalling Babel-2.11.0:
            Successfully uninstalled Babel-2.11.0
        Attempting uninstall: autopep8
            Found existing installation: autopep8 2.0.1
            Uninstalling autopep8-2.0.1:
            Successfully uninstalled autopep8-2.0.1
        Attempting uninstall: requests
            Found existing installation: requests 2.28.2
            Uninstalling requests-2.28.2:
            Successfully uninstalled requests-2.28.2
        Attempting uninstall: pyinstaller
            Found existing installation: pyinstaller 5.8.0
            Uninstalling pyinstaller-5.8.0:
            Successfully uninstalled pyinstaller-5.8.0
        Attempting uninstall: pandas
            Found existing installation: pandas 1.5.3
            Uninstalling pandas-1.5.3:
            Successfully uninstalled pandas-1.5.3
        Attempting uninstall: mypy
            Found existing installation: mypy 1.0.0
            Uninstalling mypy-1.0.0:
            Successfully uninstalled mypy-1.0.0
        Attempting uninstall: PyScreeze
            Found existing installation: PyScreeze 0.1.28
            Uninstalling PyScreeze-0.1.28:
            Successfully uninstalled PyScreeze-0.1.28
        Attempting uninstall: cookiecutter
            Found existing installation: cookiecutter 2.1.1
            Uninstalling cookiecutter-2.1.1:
            Successfully uninstalled cookiecutter-2.1.1
            Successfully uninstalled PyAutoGUI-0.9.53
        Successfully installed Babel-2.12.1 EasyProcess-1.1 MarkupSafe-2.1.3 Pillow-10.0.0 PyAutoGUI-0.9.54 PyScreeze-0.1.29 autopep8-2.0.2 cachetools-5.3.1 certifi-2023.5.7 charset-normalizer-3.2.0 click-8.1.4 cookiecutter-2.2.3 entrypoint2-1.1 lxml-4.9.3 mss-9.0.1 mypy-1.4.1 numpy-1.25.1 openpyxl-3.1.2 packaging-23.1 pandas-2.0.3 pip-23.1.2 pyasn1-0.5.0 pycryptodome-3.18.0 pyinstaller-5.13.0 pyinstaller-hooks-contrib-2023.5 pyscreenshot-3.1 python-slugify-8.0.1 pytweening-1.0.7 pytz-2023.3 pywin32-ctypes-0.2.2 requests-2.31.0 setuptools-68.0.0 tqdm-4.65.0 typing_extensions-4.7.1 tzdata-2023.3 urllib3-2.0.3
        PS C:\XXXX>
        ```
1. アップデートが完了した事を確認
    ```powershell:インストール済みの全パッケージを一覧表示するコマンド（更新後）
    PS C:\XXXX> pip list
    Package                   Version
    ------------------------- --------
    altgraph                  0.17.3
    arrow                     1.2.3
    autopep8                  2.0.2		👈 今回、更新
    Babel                     2.12.1	👈 今回、更新
    binaryornot               0.4.4
    cachetools                5.3.1		👈 今回、更新
    certifi                   2023.5.7	👈 今回、更新
    chardet                   5.1.0
    charset-normalizer        3.2.0		👈 今回、更新
    click                     8.1.4		👈 今回、更新
    colorama                  0.4.6
    cookiecutter              2.2.3		👈 今回、更新
    EasyProcess               1.1
    entrypoint2               1.1
    et-xmlfile                1.1.0
    flake8                    6.0.0
    future                    0.18.3
    idna                      3.4
    Jinja2                    3.1.2
    jinja2-time               0.2.0
    lxml                      4.9.3		👈 今回、更新
    MarkupSafe                2.1.3		👈 今回、更新
    mccabe                    0.7.0
    MouseInfo                 0.1.3
    mss                       9.0.1
    mypy                      1.4.1		👈 今回、更新
    mypy-extensions           1.0.0
    numpy                     1.25.1	👈 今回、更新
    openpyxl                  3.1.2		👈 今回、更新
    packaging                 23.1		👈 今回、更新
    pandas                    2.0.3		👈 今回、更新
    pefile                    2023.2.7
    Pillow                    10.0.0	👈 今回、更新
    pip                       23.1.2	👈 今回、更新
    pip-review                1.3.0
    pyasn1                    0.5.0		👈 今回、更新
    PyAutoGUI                 0.9.54	👈 今回、更新
    pycodestyle               2.10.0
    pycryptodome              3.18.0	👈 今回、更新
    pyflakes                  3.0.1
    PyGetWindow               0.0.9
    pyinstaller               5.13.0	👈 今回、更新
    pyinstaller-hooks-contrib 2023.5	👈 今回、更新
    PyMsgBox                  1.0.9
    pyperclip                 1.8.2
    PyRect                    0.2.0
    pyscreenshot              3.1
    PyScreeze                 0.1.29	👈 今回、更新
    pysmb                     1.2.9.1
    python-dateutil           2.8.2
    python-slugify            8.0.1		👈 今回、更新
    pytweening                1.0.7		👈 今回、更新
    pytz                      2023.3	👈 今回、更新
    pywin32-ctypes            0.2.2		👈 今回、更新
    PyYAML                    6.0
    requests                  2.31.0	👈 今回、更新
    setuptools                68.0.0	👈 今回、更新
    six                       1.16.0
    text-unidecode            1.3
    tkinterdnd2               0.3.0
    toml                      0.10.2
    tomli                     2.0.1
    tqdm                      4.65.0	👈 今回、更新
    ttkthemes                 3.2.2
    typing_extensions         4.7.1		👈 今回、更新
    tzdata                    2023.3
    urllib3                   2.0.3		👈 今回、更新
    PS C:\XXXX>
    ```
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

## 参考情報
https://python.softmoco.com/devenv/how-to-check-python-version-windows.php#:~:text=コマンドプロンプトで%20python%20--,することができます。
https://magazine.techacademy.jp/magazine/46571
https://pkunallnet.com/pcinfo/windows/pipupdate/
https://dragstar.hatenablog.com/entry/2016/09/02/113243
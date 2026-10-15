# codenv

macOS 上寫 C++ / Python 作業用的終端機環境。輸入 `codenv` 選好檔案，畫面會切成兩格或三格（第一次使用時選，之後可以用 `codenv layout` 換）：

<img src="docs/layouts.png" alt="兩種畫面：兩格是左邊 vim 寫程式、右邊 F10 執行結果；三格是左邊 AI 或終端機、右上 vim、右下執行結果" width="100%">

- **F9** 存檔並檢查有沒有打錯，**F10** 編譯並執行，結果顯示在旁邊的執行結果那格
- 錯的地方在 vim 裡畫紅色底線，錯誤訊息開頭直接寫「第 幾 行」
- Windows 寫的程式（Dev-C++ 等）也能跑：`#include <bits/stdc++.h>`、`conio.h` 的 `getch()`、`system("pause")`、`system("cls")`，Big5 編碼的中文也不會變亂碼
- 操作習慣跟 Windows 上的 C++ 編輯器一樣：Ctrl+S 存檔、Ctrl+Z 復原、滑鼠或 Shift+方向鍵選取、Ctrl+C / Ctrl+V 複製貼上、Tab 整塊縮排
- 打 `(` `[` `"` 自動補上另一半，`{` 再按 Enter 自動補上 `}`；貼上程式碼縮排不會亂
- 執行檔放在旁邊的 `bin` 資料夾，跟程式碼分開

圖文版網站：https://olilllioli287.github.io/codenv/ （純文字版給 AI 讀：[docs/guide.md](docs/guide.md)）
純文字版（可以下載離線看）：[說明.txt](說明.txt)

## 安裝

打開 Mac 內建的「終端機」（按 Cmd+空白鍵，輸入「終端機」，按 Enter），貼上這一行，按 Enter：

```
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/olilllioli287/codenv/main/get.sh)"
```

它會檢查並自動安裝缺少的東西，已經裝過的會跳過：

| 順序 | 自動裝 | 做什麼用 |
|---|---|---|
| 1 | Homebrew | 用一行指令安裝軟體的工具；沒有編譯器的話會順便裝 |
| 2 | 編譯器（Command Line Tools） | 把 C++ 翻譯成電腦能執行的程式 |
| 3 | tmux | 把一個視窗切成兩格或三格 |
| 4 | iTerm2 | 之後寫程式用的終端機 App |
| 5 | codenv 設定 | vim、tmux 的設定和 `codenv` 指令 |

- 出現 `Password:` 時輸入開機密碼按 Enter（打字時畫面不會出現任何字，這是正常的）。只要輸入這一次。
- 第一次大約 15～40 分鐘，大部分時間在下載。電腦接上電源、連上穩定的 Wi-Fi，跑的時候不要打其他字。
- 最後出現「完成」，iTerm 會自動打開（問「確定要打開嗎」就按「打開」）。**之後都用 iTerm。**
- 中途停下來或出錯，再執行一次同一行，會從沒裝好的地方接著做。還是不行，照下面的「手動安裝」一步一步補。

原本就有的 `~/.vimrc`、`~/.tmux.conf` 會先備份成 `檔名.bak-日期時間`。

### 讓 F9、F10 可以直接按

MacBook 最上排預設是亮度、音量，直接按 F10 是「靜音」。二選一：

- 每次一起按住 `fn`，例如 fn + F10。
- 系統設定 → 鍵盤 → 鍵盤快速鍵… → 功能鍵 → 打開「將 F1、F2 等鍵作為標準功能鍵使用」。

### 一行裝不起來時：手動安裝

上面那一行會自動做下面這五步。它中途失敗、或想自己一步一步來，就照順序做。一次只貼一行指令，等出現新的一行 `%` 再貼下一行。

### 手動 1　編譯器（約 10～30 分鐘）

它負責把 C++ 翻譯成電腦能執行的程式。下一步的 Homebrew 沒有它就裝不起來。

1. 按 ⌘Cmd + 空白鍵，輸入「終端機」，按 Enter。
2. 執行下面這行，跳出小視窗後按「安裝」→「同意」，等到出現「已安裝軟體」按「完成」：
   ```
   xcode-select --install
   ```
3. 確認：執行 `clang++ --version`，看到 `Apple clang version ...` 就成功了。出現 `already installed` 代表本來就裝過，直接做下一步。

### 手動 2　Homebrew（約 5～15 分鐘）

用一行指令安裝軟體的工具，後面的 tmux、iTerm2 都要靠它。

1. 執行：
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
2. 出現 `Password:` 輸入開機密碼；出現 `Press RETURN/ENTER to continue` 按 Enter；之後什麼都不要按，等到 `Installation successful!`。
3. **最重要，很多人漏掉：** 成功訊息下面的 `Next steps:` 有兩三行指令，要複製貼上執行。M 系列晶片通常是這三行（以畫面為準）：
   ```
   echo >> ~/.zprofile
   echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> ~/.zprofile
   eval "$(/opt/homebrew/bin/brew shellenv zsh)"
   ```
4. 確認：執行 `brew --version`，看到 `Homebrew 4.x.x` 就成功了。出現 `command not found: brew` 代表第 3 點還沒做。

### 手動 3　tmux（約 1～3 分鐘）

負責把視窗切成兩格或三格。

```
brew install tmux
```

確認：`tmux -V` 看到 `tmux 3.x`。

### 手動 4　iTerm2（約 1～3 分鐘）

比較好用的終端機 App，codenv 的按鍵是照它設計的。

```
brew install --cask iterm2
```

到「應用程式」資料夾打開 iTerm（問「確定要打開嗎」就按「打開」）。**之後都用 iTerm，不用內建的「終端機」。**

### 手動 5　codenv 設定（約 1 分鐘）

在 **iTerm** 裡執行：

```
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/olilllioli287/codenv/main/get.sh)"
```

看到 `已安裝 ~/.vimrc`、`已安裝 ~/.tmux.conf`、`已安裝 ~/.codenv.zsh` 和最後的 `完成` 就成功了。按 Cmd+Q 完全關掉 iTerm 再打開。

原本就有的 `~/.vimrc`、`~/.tmux.conf` 會先備份成 `檔名.bak-日期時間`。中途出現「沒有裝成」的話，看畫面寫哪一樣，回去補裝那一步，再執行一次這行。

## 第一次使用

1. 在 iTerm 輸入 `codenv` 按 Enter。第一次會先問畫面要幾格：輸入 `2`（左邊寫程式、右邊看結果）或 `3`（多一格放 AI 或終端機）。選完會記住，之後不會再問。
2. 按 `n` 新增資料夾（例如 `cpp`），再輸入它前面的數字選進去。
3. 按 `n` 新增檔案，輸入 `hello.cpp`。畫面會照你選的格數切好，vim 已經打開。
4. 按 `i` 開始打字，打完按 `Esc`。按 F9 檢查、F10 執行。在執行結果那格按 `Esc` 跳回 vim。

程式放在 `~/programming_language` 底下。

## 常用按鍵

| 按鍵 | 在哪裡 | 做什麼 |
|---|---|---|
| `i` / `Esc` | vim | 開始打字 / 停止打字 |
| F9 | vim | 存檔＋檢查錯誤 |
| F10 | vim | 存檔＋編譯＋執行 |
| Ctrl+S | vim | 存檔 |
| Ctrl+Z / Ctrl+Y | vim | 復原 / 重做 |
| 滑鼠拖曳、雙擊，或 Shift+方向鍵 | vim | 選取文字；選取後直接打字會取代它，Backspace 刪掉 |
| Ctrl+C / Ctrl+X / Ctrl+V | vim | 複製 / 剪下 / 貼上（跟 Mac 共用剪貼簿，Cmd+V 也能貼上） |
| Tab / Shift+Tab | vim | 選取多行時整塊增加 / 減少縮排；打字時 Shift+Tab 減少這行縮排 |
| Ctrl+F | vim | 搜尋，按 Enter 跳過去，再按 `n` 找下一個 |
| `:q` / `:q!` | vim | 關掉 / 不存檔直接關掉 |
| `Esc` | 執行結果那格 | 跳回 vim |
| Ctrl+C | 執行結果那格 | 停止跑不完的程式 |
| Ctrl+A 放開再按 `\|` / `-` | tmux | 左右 / 上下切格 |
| Ctrl+A 放開再按 `h` `j` `k` `l` 或方向鍵 | tmux | 移到左 / 下 / 上 / 右那格 |

**開著注音等中文輸入法時也能直接用 Ctrl+A**：按下 Ctrl+A 的瞬間會自動切成英文，指令做完再切回原本的輸入法（由安裝時編譯的小程式 `~/.codenv-ime` 負責）。按完 Ctrl+A 稍等一下再按下一個鍵比較保險；萬一沒裝成，按 Ctrl+A 之前先切成英文。

滑鼠可以點選格子、滾輪捲動、拖曳分隔線。vim 以外的格子（例如執行結果）要反白複製文字時，按住 Option 再拖曳，再按 Cmd+C。

## 選用設定

- **tmux-kit（另外裝的小工具包）：** Ctrl+A 連按兩次的中文選單、在 iTerm 裡按 Cmd+Ctrl+A 用滑鼠排列格子、Claude Code 回完分頁反白。第一次輸入 `codenv` 時會介紹一次，也可以隨時執行 `zsh -c "$(curl -fsSL https://raw.githubusercontent.com/olilllioli287/tmux-kit/main/get.sh)"` 安裝，見 [tmux-kit](https://github.com/olilllioli287/tmux-kit)。
- **換畫面格數：** 輸入 `codenv layout` 重新選，或直接輸入 `codenv layout 2`（兩格）、`codenv layout 3`（三格）。下次開 `codenv` 就會用新的排法。
- **三格時左邊自動開 AI：** 執行 `open -e ~/.codenv.zsh`，把 `CODENV_AI=''` 改成例如 `CODENV_AI='claude'`，存檔後重開 iTerm。
- **一樣的配色：** iTerm → Settings → Profiles → Other Actions → Import JSON Profiles，在選檔視窗按 ⌘Cmd + Shift + G，輸入 `~/.codenv-kit/iterm-profile.json`。匯入後選中 `codenv`，再按 Other Actions → Set as Default。

## 更新

再執行一次第 5 步那一行。原本的設定會自動備份，`~/.codenv.zsh` 裡設定過的資料夾和 AI 指令會保留。做完把開著的 vim 關掉再打開。

想換回舊版：`ls ~/.vimrc.bak-*` 找到想要的備份，用 `cp ~/.vimrc.bak-日期時間 ~/.vimrc` 複製回來。

## 遇到問題

到 [Issues](https://github.com/olilllioli287/codenv/issues) 按 **New issue**，寫下你做了什麼、看到什麼，可以直接貼上截圖（需要 GitHub 帳號）。

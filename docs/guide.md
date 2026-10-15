# codenv 完整說明（純文字版）

> 這份檔案是 codenv 網站（https://olilllioli287.github.io/codenv/）的全部內容整理成的純文字，方便 AI 或離線閱讀。
> 原始碼：https://github.com/olilllioli287/codenv


---

codenv_

在 Mac 上寫 C++ / Python 作業的終端機環境。輸入 `codenv` 選好檔案，畫面就切成寫程式和看結果的兩格（或多一格放 AI）。按 F9 檢查、F10 執行，錯在哪一行直接標出來。

新手上路：從零開始安裝 已經有工具：一行安裝 GitHub（https://github.com/olilllioli287/codenv）

（圖：兩種畫面：兩格是左邊 vim 寫程式、右邊 F10 執行結果；三格是左邊 AI 或終端機、右上 vim、右下執行結果）

F9 檢查、F10 執行

F9 存檔並檢查有沒有打錯，F10 編譯後直接在旁邊那格執行。程式要輸入資料也是在那格打。

錯在哪一行，直接標出來

錯誤畫紅色底線、警告畫黃色底線；訊息開頭寫「第 6 行」，系統檔案的雜訊都過濾掉。

跟 Windows 編輯器一樣的操作

Ctrl+S 存檔、Ctrl+Z 復原、滑鼠選取後直接打字取代、Ctrl+C / Ctrl+V 複製貼上、Tab 整塊縮排。

兩格或三格

第一次開 codenv 時選。沒有用 AI 就選兩格；有的話選三格，左邊多一格放 AI。

中文輸入法開著也能用

注音、威注音開著時按 Ctrl+A，會自動切成英文，tmux 指令做完再切回來。

用滑鼠排列格子

在 iTerm 裡按 Cmd+Ctrl+A 叫出排列視窗，把格子、分頁拖來拖去就排好，不用記 tmux 指令。看說明

用 AI 一步一步學

一段給 Gemini、ChatGPT、Claude 的記憶，讓 AI 知道你是剛學 C++ 的新生，不會一次丟一整支程式。拿這段記憶

搭配工具：圖片預覽 image-shelf

三格模式左邊用 Claude Code 的話，貼上的截圖會顯示成縮圖，點一下還能畫圈標註。看介紹

自動補括號

打 `(` `[` `"` 自動補另一半，`{` 再按 Enter 自動補上 `}`；貼上的程式碼縮排不會亂。

---

Download

# 下載與安裝

第一次在這台 Mac 上安裝、還沒有編譯器、Homebrew、tmux、iTerm2 的話，請先看新手上路，照順序一步一步做。

## 一行安裝

工具都裝好之後，在 iTerm 執行下面這一行。它會從 GitHub 下載最新版的 codenv，放在 `~/.codenv-kit`，再自動安裝。

```
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/olilllioli287/codenv/main/get.sh)"
```

看到類似這樣就成功

下載 codenv 最新版…

```
已安裝 ~/.vimrc
已安裝 ~/.tmux.conf
已安裝 ~/.codenv-ime(中文輸入法開著時,Ctrl+A 也能用)
已安裝 ~/.codenv-board(用滑鼠排列格子的視窗)
已設定 Cmd+Ctrl+A:在 iTerm 裡按一下叫出排列視窗,再按一下收起來(登入時自動在背景啟動)
已安裝 ~/.codenv-compat(Windows 寫的程式也能跑,例如 bits/stdc++.h、system("pause"))
已安裝 ~/.codenv.zsh
已在 ~/.zshrc 加上 source ~/.codenv.zsh

完成。關掉 iTerm(⌘Q)重開,輸入 codenv 就能使用
```

原本就有的 `~/.vimrc`、`~/.tmux.conf` 會先備份成「檔名.bak-日期時間」，不會不見。

## 更新

再執行一次上面那一行就好。有變動的設定檔會先備份；你在 `~/.codenv.zsh` 設定過的程式資料夾、AI 指令、畫面格數都會保留。做完把開著的 vim 關掉再打開。

以前用 AirDrop 拿 `codenv-kit.zip` 安裝的人，也是執行同一行更新。

## 其他下載方式

- 原始碼：github.com/olilllioli287/codenv（https://github.com/olilllioli287/codenv）

- 整包下載：codenv-main.zip（https://github.com/olilllioli287/codenv/archive/refs/heads/main.zip）。解壓縮後，在 iTerm 輸入 `zsh` 加一個空白，把資料夾裡的 `install.sh` 拖進視窗，按 Enter。

- 純文字版安裝說明（可以離線看）：說明.txt（https://github.com/olilllioli287/codenv/blob/main/%E8%AA%AA%E6%98%8E.txt）

## 在 GitHub 上找下載

GitHub 上每個專案的頁面都長得差不多，要下載東西看這三個地方：

| 位置 | 做什麼 | codenv 的用法 |
| --- | --- | --- |
| 綠色的 Code 按鈕 | 按下去選 Download ZIP，下載整個專案目前的最新版 | 沒辦法用一行安裝時才需要 |
| 右邊的 Releases | 作者打包好的正式版本，一個版本一個，附更新說明和下載檔 | codenv 沒有使用 Releases，一行安裝永遠拿最新版；版本紀錄看發行日誌 |
| 上方的 Issues 分頁 | 回報問題、提建議的地方 | 遇到 bug 就到這裡（https://github.com/olilllioli287/codenv/issues）按 New issue |

專案的使用授權寫在檔案列表裡的 `LICENSE`，以及右邊的 About 欄位。codenv 是 MIT 授權，可以自由下載、修改成自己的習慣，詳見使用手冊的「改成自己的習慣」。

## 搭配工具：圖片預覽 image-shelf

給三格模式左邊用 Claude Code 的人。在終端機裡貼上截圖，Claude Code 只會顯示成 `[Image #3]`，貼了幾張就分不清哪張是哪張；而 Claude Code 內建的圖片顯示在 iTerm2 和 tmux 裡看不到。image-shelf 把貼上的圖片排成縮圖，放在輸入框上方。

- 看得到貼了什麼：每張圖都顯示成真正的縮圖，超過一排可以左右滑。

- 點一下就能標註：畫筆、圓圈、方框、箭頭、文字、裁切、旋轉，Claude 收到的是標註過的版本。問「第 5 行為什麼有錯」時，可以直接把錯誤訊息圈起來。

- 不會擋住畫面：切到別的 App、切 tmux 分頁、Claude 正在回答時會自動隱藏。

安裝方式：在 Claude Code 的輸入框（不是終端機）打下面這行，問要不要加入來源時按 [y]，範圍選 user。第一次貼圖會花幾秒準備。

```
/plugin install image-shelf --marketplace olilllioli287/claude-code-image-shelf
```

需要 macOS、Command Line Tools、Claude Code 2.1.292 以後；iTerm2 要開「螢幕錄製」權限。說明、示範動畫和版本都在 GitHub：claude-code-image-shelf（https://github.com/olilllioli287/claude-code-image-shelf），各版本的更新說明在頁面右邊的 Releases（https://github.com/olilllioli287/claude-code-image-shelf/releases）（目前最新 v0.1.2）。

## 系統需求

| 項目 | 需要什麼 | 怎麼裝 |
| --- | --- | --- |
| 作業系統 | macOS（Apple 晶片或 Intel 都可以） | — |
| 編譯器 | Command Line Tools（含 g++、swiftc、python3） | 新手上路第 2 步 |
| tmux | 3.4 以上 | 新手上路第 4 步 |
| 終端機 | iTerm2 | 新手上路第 4 步 |

---

Support

# 支持 codenv

codenv 免費、開放原始碼（MIT 授權），沒有收費或捐款管道。想幫忙的話，下面這些事最有用。

回報問題

遇到 bug 或看不懂的地方，到 GitHub Issues（https://github.com/olilllioli287/codenv/issues） 按 New issue，寫下你做了什麼、看到什麼，可以直接貼截圖（需要 GitHub 帳號）。

給一顆星

在 GitHub 頁面（https://github.com/olilllioli287/codenv）右上角按 Star，讓更多同學找得到。

分享給同學

把這個網站的網址傳給也在寫作業的人。照著新手上路做，不用再找人一個一個幫忙裝。

一起改進

會改程式的話，歡迎直接修改後送 Pull Request；想到好用的功能，也可以開 Issue 提議。

---

Release Notes

# 發行日誌

每次更新多了什麼、修了什麼。想更新到最新版，看下載頁的更新。

2026-10-15

## 用滑鼠排列格子的視窗、在 iTerm 裡按 Cmd+Ctrl+A 叫出來、選單可以用滑鼠點

- 【新功能】排列視窗：一個 Mac 視窗，把所有工作階段、分頁和格子畫成小縮圖。把格子拖到別的分頁就搬過去，拖到「新 window」就拆成新的分頁；分頁拖到另一個分頁上會交換位置，拖到別的工作階段會搬過去，也可以開新的工作階段。點一下格子切換過去，雙擊名字或按右鍵可以改名、換排列方式。

- 【新功能】在 iTerm 裡按 [Cmd]+[Ctrl]+[A] 叫出排列視窗，再按一次收起來。在別的 App 按不會有反應，那個 App 自己的 Cmd+Ctrl+A 照常能用；排列視窗開著時切到別的 App，它會自動收起來。登入時會自動在背景準備好，不用開任何權限。從 Ctrl+A 兩下的選單選「用滑鼠排列格子」也能打開。

- 【新功能】工作階段可以改名：在排列視窗按工作階段那一行的「改名」，或雙擊它的名字；Ctrl+A 兩下的選單也多了「幫這個工作階段取名」。改的是左下角「Session 0」那塊的名字，中文也可以。

- 【修正】iTerm 開成全螢幕時按 Cmd+Ctrl+A，排列視窗會跑到別的桌面，看起來像沒反應。現在會直接疊在眼前的畫面上。

- 【修正】Ctrl+A 兩下的選單用滑鼠點不到選項，而且滑鼠一移出選單，選單就消失。現在滑鼠移到哪裡選單都留著，點選項就執行，點選單外面才關掉。

2026-10-14

## 模塊化排列：把格子搬來搬去、幫格子取名

- 【新功能】Ctrl+A 兩下的選單多了「模塊化排列(搬動格子、取名)…」，點進去是第二層選單：把這格搬到別的分頁、把別的分頁的格子搬進來、把這格拆成新的分頁，以及左右並排、上下堆疊、左邊一大格、方格四種排法。

- 【新功能】可以幫格子取名，名字顯示在那格上方（中文也可以）。分頁裡沒有取名的格子時，名字列會自動收起來，不佔畫面。

2026-10-14

## 選單可以搬動分頁、重新編號、關掉整個工作階段

- 【新功能】Ctrl+A 兩下的選單多了：列出所有分頁並切換過去（其他工作階段的分頁也列在裡面）、這個分頁往左移 / 往右移、分頁重新編號（關掉分頁後留下的空號，例如 1 2 4 變成 1 2 3）、關掉整個工作階段。

- 【新功能】幫分頁取名的輸入框改成空的，直接打新名字就好，不用先刪掉舊的名字；什麼都沒打就按 Enter 不會改。

- 【改進】關掉整個工作階段，或關掉它最後一個分頁時，還有別的工作階段的話會直接切過去，不會跳出 tmux。

2026-10-14

## vim 教學、幫分頁取名

- 【新功能】網站多了 vim 教學 一頁：模式、存檔與離開、移動游標、刪除複製、搜尋取代、寫程式好用的按鍵、卡住時怎麼辦，還有 vim 內建的中文練習 vimtutor。

- 【新功能】Ctrl+A 兩下的選單多了「幫這個分頁取名」，可以把最下面的 `[1] zsh` 改成 `[1] 作業一` 這種名字，中文也可以。Ctrl+A → [,] 也改成同樣的中文提示。

- 【修正】tmux 最下面的輸入框（例如取名的時候）按一下 Esc 就會取消；原本按幾次都關不掉，看起來像卡住。

2026-10-14

## 一開檔就顯示已存檔、存檔時閃一下，Claude Code 那格按 Ctrl+S 不會讓訊息不見

- 【新功能】用 vim 打開 .cpp 或 .py 時，執行結果那格第一行直接顯示 `✓ 已存檔`，不用先按 F9。那格裡有程式在跑、或還留著上次的輸出時，不會動它。

- 【新功能】按 Ctrl+S（或 Cmd+S）存檔時，那一行會反白閃一下；本來就存好了再按也會閃，看得出有存到。

- 【修正】在打字中（INSERT）按 Ctrl+S 存檔，那一行有時會停在 `● 未儲存`，現在會正確變成 `✓ 已存檔`。

- 【修正】在 Claude Code 那格按 Ctrl+S（或照編輯快捷鍵設定好的 Cmd+S），原本會把打到一半的訊息收起來，看起來像不見了。現在跟執行結果那格一樣，只顯示「要存程式請回到 vim 按 Ctrl+S」，打的字不會動。

2026-10-13

## 看得出有沒有存檔、有 error 時先不顯示 warning

- 【新功能】按 F9 後執行結果那格最後的 `✓ code is ok` 那一行，會跟著程式現在的狀態改變：一改程式就變成 `● 未儲存`，存檔後變成 `✓ 已存檔`，再按 F9 / F10 又顯示檢查結果。改了又用 Ctrl+Z 復原回存檔時的樣子，會變回原本的狀態。上面的錯誤訊息不會動。

- 【改進】程式有 error 時，先不顯示 warning（連同它後面的 note），最後用一行灰字說還有幾個。這些 warning 常常是 error 連帶造成的，例如多打一個字讓編譯器把下一行看錯，修好 error 後通常會一起消失；沒消失的話再按 F9 就會顯示。

- 【新功能】想用 Mac 習慣的 Cmd+S 存檔，可以在 iTerm 加一條按鍵設定，做法在編輯快捷鍵下面。

2026-10-12

## 整數除以 0 會提示、放大畫面時的 F9 / F10

- 【修正】Apple Silicon 的 Mac 上，整數除以 0 不會當掉，只會默默得到錯的答案（Windows 會當掉）。現在 F10 執行時會停下來，印出 `runtime error: division by zero` 和第幾行。固定大小的陣列索引超出範圍（例如 `int a[3]` 用到 `a[5]`）也一樣。整數溢位照常跑，跟 Windows 一樣。

- 【修正】用 Ctrl+A 選單把 vim 那格放大後按 F9 / F10，結果原本會開在新的一格，每按一次多一格。現在會先還原，結果照樣顯示在原本那格。

- 【改進】Python 的縮排錯誤（IndentationError、TabError）、少冒號、引號或括號沒關、`invalid syntax` 下面加上中文說明（新舊版 Python 的訊息都認得），縮排錯誤也會在 vim 裡標出是哪一行（原本標不出來）。

- 【新功能】`#include <conio.h>` 也能用了：`getch()`（按一個鍵就繼續，不用按 Enter）、`getche()`、`kbhit()`、`clrscr()` 跟 Windows 一樣。方向鍵這類特殊鍵送出的代碼跟 Windows 不同。

- 【新功能】`system("color 0A")` 會換文字顏色（背景不換），程式結束後自動換回來；`system("title …")` 不再出現 command not found。

- 【新功能】跟 Windows 一樣用 Ctrl+Z 結束輸入（例如 `while (cin >> x)` 一直讀數字的迴圈）。Mac 上原本要按 Ctrl+D，按 Ctrl+Z 程式會一直等；現在在執行結果那格按 Ctrl+Z 會自動換成 Ctrl+D。

- 【修正】在執行結果那格或命令列按 Ctrl+S（Windows 的存檔習慣），終端機會停止輸出，看起來像當掉（要按 Ctrl+Q 才恢復）。現在只有 vim 會收到 Ctrl+S，其他格按下去會顯示「要存程式請回到 vim 按 Ctrl+S」。

- 【改進】F10 出現英文的 `Undefined symbols`（連結錯誤）時，下面用中文說明：`main` 打錯字（例如 `mian`），或是哪個函式只有宣告、沒有寫出內容。

- 【修正】沒有選取文字時按 Ctrl+X，原本會把游標下的數字減 1（例如 `10` 變 `9`），程式被改了也看不出來。現在沒有選取時 Ctrl+X 什麼都不做，選取後照樣是剪下。

- 【修正】關掉 iTerm 再輸入 `codenv` 接回原本的畫面時，「這個檔案在下方 [1] 分頁已經開著」的提示會被畫面放大清掉。現在會顯示在最下面，動一下游標就消失。

2026-10-12

## Esc 不再慢一拍、Big5 中文、Python 自動縮排、關掉 iTerm 後接回原本的畫面

- 【修正】在 vim 裡按 Esc 要等大約 1 秒才回到一般模式（游標和 `-- INSERT --` 慢一拍才變）。現在馬上切換。

- 【新功能】老師給的 Windows 檔案，中文是 Big5 編碼，原本打開是一堆亂碼。現在會正常顯示，存檔（Ctrl+S、F9、F10）時自動轉成 Mac 用的 UTF-8，執行時印出的中文也不會變亂碼。

- 【修正】直接關掉 iTerm 時，tmux 和裡面的 vim 其實還開在背景；再開 iTerm 輸入 `codenv` 選同一個檔案，只能唯讀，而且找不到原本的 vim。現在 `codenv` 會接回背景的畫面，新的分頁開在旁邊，舊的分頁在最下面看得到。

- 【改進】Python 打完 `if`、`for`、`def` 這行的冒號按 Enter，下一行自動多縮一層（原本要自己按 Tab，忘了就出現 IndentationError）。

- 【修正】vim 那格關掉之後，在執行結果那格按 Esc 會跳出英文的 `returned 1` 畫面。現在 Esc 照常傳給程式。

- 【改進】同一個檔案在別的分頁開著時，提示會說是哪一個分頁、怎麼切過去（Ctrl+A 再按分頁編號）。畫面太窄、一行放不下的提示不會再跳出英文的 Press ENTER。

2026-10-12

## Windows 寫的程式也能跑

- 【新功能】`#include <bits/stdc++.h>` 在 Mac 上也能編譯（Dev-C++、Code::Blocks 常用，Mac 的編譯器原本沒有）。

- 【新功能】`system("pause")` 跟 Windows 一樣顯示「請按任意鍵繼續 . . .」並等你按鍵；`system("cls")` 會清除畫面。原本會出現英文的 command not found。

- 【改進】程式的輸出不等換行就馬上顯示：`cout` 後面沒接 `endl` 的字不會跑到「請按任意鍵繼續」後面，程式當掉前印的字也看得到。

- 【改進】用到 `conio.h`、`windows.h` 這些 Windows 才有的檔案時，錯誤訊息下面用中文說明要改成什麼。

2026-10-12

## 引號自動補全、vim 沒正常關掉時的處理

- 【修正】打 Python 的 `print(f"x = {x}")` 或 C++ 的 `'"'` 時，自動補的引號會多出一個。現在會看游標是不是在字串裡，在字串裡打 `"` 就是收尾。

- 【改進】vim 沒有正常關掉（例如直接關掉 iTerm）之後再打開同一個檔案，不會再跳出一大段英文：沒有沒存的修改就直接打開；有的話用中文問要不要救回來。同一個檔案在別的格子還開著時，這裡改成唯讀打開並提醒。

- 【改進】還沒有檔名，或檔案是唯讀時按 Ctrl+S，改用中文說明，不再出現英文的 E32 / E45。

- 【改進】還沒裝 tmux 時輸入 `codenv`，一開始就告訴你怎麼裝（原本要選完檔案才出現英文錯誤）。

2026-10-12

## 中文輸入法、Windows 操作習慣、兩格模式

- 【新功能】中文輸入法（注音、威注音等）開著時，按 Ctrl+A 會自動切成英文，tmux 指令做完再切回原本的輸入法。

- 【新功能】Ctrl+A 連按兩次叫出中文選單：分割、關掉這格、放大、分頁，用 ↑↓ 和 Enter 操作。

- 【新功能】vim 操作跟 Windows 上的 C++ 編輯器一樣：Ctrl+S 存檔、Ctrl+Z 復原、Ctrl+Y 重做、滑鼠或 Shift+方向鍵選取後直接打字取代、Ctrl+C / X / V 複製剪下貼上、Tab / Shift+Tab 整塊縮排、Ctrl+F 搜尋。

- 【新功能】打 `(` `[` `"` 自動補另一半；在行首按 ← 會跳到上一行結尾。

- 【新功能】畫面可以選兩格（左邊寫程式、右邊看結果）或三格，第一次開 codenv 時問，之後用 `codenv layout` 換。

- 【新功能】按 F10 產生的執行檔改放在旁邊的 `bin` 資料夾，跟程式碼分開。

- 【新功能】放上 GitHub，安裝和更新都改成一行指令。

- 【新功能】自己的設定可以寫在 `~/.vimrc.local`、`~/.tmux.conf.local`，更新時不會被蓋掉。

- 【新功能】使用手冊新增「用 AI 輔助學習」：一段給 Gemini 等 AI 的記憶，讓它知道你是新生、一步一步教。

- 【新功能】網站改版：下載、新手上路、常見問題、使用手冊、技術文書分頁，可以搜尋。

- 【修正】Ctrl+Z 會讓 vim 縮到背景「不見」；Ctrl+S 會在程式裡插入看不見的字元。

- 【修正】程式停不下來時按 Ctrl+C，執行結果那格會整格消失。

- 【修正】選檔案時打錯字，會建出沒有副檔名的空檔案。

- 【修正】關掉格子、關掉分頁時要打 y 確認，中文輸入法開著打不出來；改成按 Enter 確定。

- 【修正】還沒有檔名時按 F9 / F10，訊息看不懂。

- 【改進】程式當掉時說明常見原因（記憶體存取錯誤、除以 0、例外沒處理、main 回傳不是 0）。

2026-10-11

## F9 檢查錯誤、錯誤訊息好讀

- 【新功能】F9 從「只存檔」改成存檔並檢查錯誤，結果顯示在執行結果那格，最後一行用顏色標出 ok 或 error。

- 【新功能】錯的地方在 vim 裡畫紅色底線、警告畫黃色底線。

- 【新功能】錯誤訊息開頭的「檔名:行:字:」改成「第 幾 行:」，並拿掉系統檔案的雜訊。

- 【新功能】打 `{` 再按 Enter 自動補上 `}`；已經有對應的 `}` 就不重複補。

- 【新功能】貼上程式碼時縮排不會亂掉；程式執行到一半出錯時用紅字提醒。

- 【新功能】tmux 支援 Ctrl+Enter 這類組合鍵（給左邊用 Claude Code 的人）。

2026-10-06

## 第一版

- 【新功能】`codenv` 指令：用數字選資料夾和檔案，自動排好三格畫面。

- 【新功能】F10 編譯並執行，在執行結果那格按 Esc 跳回 vim。

- 【新功能】安裝手冊網站與 `codenv-kit.zip` 安裝包（10/07 補上選單防呆：資料夾名稱像檔名時會提醒）。

---

Onboarding

# 新手上路：從零開始安裝

照順序做，前面的沒裝好，後面的會裝不起來。不用一次做完：下次回來，看看自己做到哪一步，每一步最後都有確認的方法。

## 開始前先準備

- 電腦接上電源，連上穩定的 Wi-Fi。第 2、3 步要下載 1～2 GB，可能要 20～60 分鐘。

- 知道這台 Mac 的開機密碼。過程中會要你輸入。輸入密碼時畫面不會出現任何字，連星號都沒有，打完直接按 [Enter]。

- 每個指令右邊有「複製」按鈕。按下去後，到終端機按 [⌘ Cmd] + [V] 貼上，再按 [Enter]。一次只做一行，等它跑完、出現新的一行 `%` 再做下一行。

| 步驟 | 要裝什麼 | 必須先完成 |
| --- | --- | --- |
| 2 | 編譯器（Command Line Tools） | 無，最先裝 |
| 3 | Homebrew | 第 2 步 |
| 4 | tmux、iTerm2 | 第 3 步 |
| 5 | codenv | 第 2～4 步，而且要在 iTerm 裡做 |

1

## 打開「終端機」

約 1 分鐘

- 按 [⌘ Cmd] + [空白鍵]，畫面中間會出現搜尋框（Spotlight）。

- 輸入「終端機」或 `Terminal`，按 [Enter]。

- 最後一行長得像 `名字@電腦名稱 ~ %`。這個 `%` 代表「我在等你輸入指令」。

2

## 安裝編譯器（Command Line Tools）

10～30 分鐘，大部分時間在下載

編譯器負責把你寫的 C++ 翻譯成電腦能執行的程式，也附帶第 5 步要用的工具。第 3 步的 Homebrew 沒有它就裝不起來，所以最先裝。

```
xcode-select --install
```

- 跳出小視窗後按「安裝」，再按「同意」。

- 等進度條跑完，出現「已安裝軟體」後按「完成」。

確認有裝好

```
clang++ --version
```

看到類似這樣就成功

```
Apple clang version 17.0.0 (clang-1700.0.13.5)
```

如果出現 already installed

代表這台電腦本來就裝過了，直接做第 3 步。

3

## 安裝 Homebrew

5～15 分鐘

Homebrew 是 Mac 上「用一行指令安裝軟體」的工具，第 4 步要靠它。

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

- 出現 `Password:` 時，輸入開機密碼，按 [Enter]。

- 出現 `Press RETURN/ENTER to continue` 時，按 [Enter]。

- 之後什麼都不要按，等到出現 `==> Installation successful!`。

最重要的一步，很多人漏掉

成功訊息下面的 `==> Next steps:` 有兩三行指令，要複製貼上執行，不然終端機找不到 brew。M 系列晶片的 Mac 通常是下面這三行（以你畫面上的為準），可以一起貼上：

```
echo >> ~/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv zsh)"
```

確認有裝好

```
brew --version
```

看到類似這樣就成功

```
Homebrew 4.x.x
```

4

## 安裝 tmux 和 iTerm2

3～5 分鐘

tmux 負責把一個視窗切成兩格或三格。iTerm2 是比較好用的終端機 App，之後都用它取代內建的「終端機」。

```
brew install tmux
```

跑完、出現新的 `%` 後，再執行：

```
brew install --cask iterm2
```

確認有裝好

```
tmux -V
```

看到類似這樣就成功

```
tmux 3.5a
```

到「應用程式」資料夾找到 iTerm，點兩下打開。第一次打開如果問「確定要打開嗎？」，按「打開」。

5

## 安裝 codenv

約 1 分鐘，要在 iTerm 裡做

在 iTerm 裡執行下面這一行。它會從 GitHub 下載最新版的 codenv 並自動安裝：

```
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/olilllioli287/codenv/main/get.sh)"
```

看到最後一行「完成」就成功

```
已安裝 ~/.vimrc
已安裝 ~/.tmux.conf
已安裝 ~/.codenv-ime(中文輸入法開著時,Ctrl+A 也能用)
已安裝 ~/.codenv-board(用滑鼠排列格子的視窗)
已設定 Cmd+Ctrl+A:在 iTerm 裡按一下叫出排列視窗,再按一下收起來(登入時自動在背景啟動)
已安裝 ~/.codenv-compat(Windows 寫的程式也能跑,例如 bits/stdc++.h、system("pause"))
已安裝 ~/.codenv.zsh
已在 ~/.zshrc 加上 source ~/.codenv.zsh

完成。關掉 iTerm(⌘Q)重開,輸入 codenv 就能使用
```

最後出現「還缺 tmux」或「還缺編譯器」

代表第 4 步或第 2 步沒裝好。回去補裝，再執行一次上面那行。

6

## 讓 F9、F10 可以直接按

約 1 分鐘

MacBook 最上面那排鍵預設是調亮度、音量，直接按 F10 其實是「靜音」。選一種解法：

- 每次一起按住 [fn]（左下角有地球圖示那顆），例如 [fn] + [F10]。

- 改成預設就是 F 鍵：系統設定 → 鍵盤 → 鍵盤快速鍵… → 功能鍵 → 打開「將 F1、F2 等鍵作為標準功能鍵使用」。改了以後，調音量反而要按 [fn]。

7

## 第一次使用：寫一支 Hello

約 5 分鐘

- 按 [⌘ Cmd] + [Q] 完全關掉 iTerm，再重新打開。

- 輸入 `codenv` 按 [Enter]。第一次會先問畫面要幾格：輸入 [2]（左邊寫程式、右邊看結果，沒有用 AI 的話選這個）或 [3]（多一格放 AI 或終端機）。選完會記住。

- 按 [n] [Enter] 新增資料夾，輸入名稱（例如 `cpp`）。清單出現 `1) cpp` 後，輸入 [1] [Enter]。

- 按 [n] [Enter] 新增檔案，輸入 `hello.cpp`（一定要有副檔名）。畫面會切好，vim 已經打開。

- 按 [i] 開始打字（左下角出現 `-- INSERT --`），把下面這段打進去，打完按 [Esc]。練習的話建議自己打，不要貼。

```
#include <iostream>
using namespace std;

int main()
{
	cout << "Hello C++" << endl;
	return 0;
}
```

- 按 [F9] 存檔並檢查，按 [F10] 編譯並執行。

- 執行結果那格（兩格是右邊、三格是右下）出現 `Hello C++` 就成功了。在那格按 [Esc] 會跳回 vim。

程式有錯的時候

程式不會執行，錯誤訊息出現在執行結果那格，vim 裡錯的地方畫紅色底線。怎麼看錯誤訊息，請看使用手冊的 F9 與 F10。

8

## 選用設定

換畫面格數：輸入 `codenv layout` 重新選，或直接打 `codenv layout 2`、`codenv layout 3`。

三格時左邊自動開 AI：執行下面這行，用「文字編輯」打開設定檔，把 `CODENV_AI=''` 改成例如 `CODENV_AI='claude'`，存檔後重開 iTerm。

```
open -e ~/.codenv.zsh
```

一樣的配色：iTerm 選單 → Settings → Profiles → 左下角 Other Actions → Import JSON Profiles，在選檔視窗按 [⌘ Cmd] + [Shift] + [G]，輸入 `~/.codenv-kit/iterm-profile.json`。匯入後選中 `codenv`，再按 Other Actions → Set as Default。

---

FAQ

# 常見問題

找不到答案的話，到 GitHub Issues（https://github.com/olilllioli287/codenv/issues） 發問，附上截圖會比較快找到原因。

## 安裝

**問：** 安裝途中不小心打了別的指令

終端機在跑的時候，你打的字會先被記著，等目前的工作跑完才執行。如果自動又跑了一次 Homebrew 安裝，出現 `Press RETURN/ENTER to continue or any other key to abort` 時按 [q] 取消。出現 `command not found: brew` 就照第 3 步的 Next steps 做。

**問：** 下載跑很久，好像卡住了

停在 `Downloading Command Line Tools` 很久是正常的，這一包很大。只要沒有出現紅字或 `Error`，就繼續等。今天沒時間等完，可以直接關掉視窗，下次重新做那一步就好，已經裝好的部分不會重來。

**問：** codenv: command not found

新設定還沒生效。按 [⌘ Cmd] + [Q] 完全關掉 iTerm 再打開。還是不行的話，確認第 5 步最後有出現「完成」。

**問：** 第 5 步出現「下載失敗」或 Could not resolve host

代表連不上 GitHub。確認 Wi-Fi 有連上，等一下再執行一次同一行。學校網路連不上的話，可以改用手機熱點試試。

**問：** 第 5 步最後出現「還缺 tmux」或「還缺編譯器」

代表第 4 步或第 2 步沒裝好。回去補裝，再執行一次第 5 步那行。

## 使用

**問：** 按 F10 沒反應，或音量跳出來

看新手上路第 6 步，要搭配 [fn] 鍵，或改系統設定。另外確認游標在 vim 那格（先用滑鼠點一下）。

**問：** 程式停不下來，一直印東西

在執行結果那格按 [Ctrl]+[C] 停止程式，會出現「已用 Ctrl+C 停止程式」。通常是迴圈的條件永遠成立，例如 `for` 的第二格寫錯。

**問：** 程式一直在讀輸入，要怎麼告訴它「輸入完了」

例如 `while (cin >> x)` 或 Python 的 `for line in sys.stdin`。輸入完最後一筆按 [Enter]，再按 [Ctrl]+[Z]（跟 Windows 一樣；Mac 原本的按法是 [Ctrl]+[D]，兩個都可以）。

**問：** 執行結果那格不見了

在 vim 裡按 [F10]，會自動重開一格（兩格模式開在右邊，三格模式開在 vim 下面）。

**問：** 出現紅字 code is error，後面還有 exit code

代表程式有執行，但不是正常結束。常見的幾種在使用手冊有對照表，例如 139 是記憶體存取錯誤（陣列索引超出範圍、指標沒設定好）。

**問：** 老師給的程式（Windows 寫的）在 Mac 上不能跑

`#include <bits/stdc++.h>`、`system("pause")`、`system("cls")` 在 codenv 裡跟 Windows 一樣能用（要更新到最新版）。`pause` 會顯示「請按任意鍵繼續 . . .」，在執行結果那格按任意鍵繼續。

打開時中文是一堆亂碼的話，更新到最新版再打開：codenv 認得 Windows 的 Big5 編碼，會正常顯示，按 [Ctrl]+[S] 或 F9 / F10 存檔時轉成 Mac 用的格式。

`system("color 0A")` 會換文字顏色，`system("title …")` 不會出錯。`conio.h` 的 `getch()`、`kbhit()` 在 codenv 裡也能用（要更新到最新版）。`windows.h`（`Sleep()` 等）是 Windows 才有的，Mac 上沒有；按 F9 時錯誤訊息下面會用黃字說明要改成什麼。

**問：** 選檔案時打了檔名，它說「請輸入檔案前面的數字…」

檔名要有副檔名，例如 `hw1.cpp` 或 `hw1.py`。沒有副檔名的話，F9、F10 不知道該用 C++ 還是 Python。

## vim

**問：** vim 底下出現一堆紅字，或一直打不出字

先按兩下 [Esc] 回到一般模式。要打字就按 [i]。想放棄這次的修改離開，輸入 `:q!` 按 [Enter]。其他狀況見 vim 教學的「卡住了怎麼辦」。

**問：** vim 突然不見了，畫面出現 zsh: suspended vim

這是舊版按到 Ctrl+Z 的結果，vim 只是被丟到背景。輸入 `fg` 按 [Enter] 就會回來。更新到最新版後，Ctrl+Z 改成「復原」，不會再發生。

**問：** 打開檔案時問「要救回來嗎?」，或出現 Swap file … already exists

代表上次 vim 沒有正常關掉（例如直接關掉 iTerm），留下了還沒存檔的修改。按 [1] 救回來（接著出現的英文說明按 [Enter] 就好，確認內容沒問題再按 [Ctrl]+[S] 存檔），按 [2] 不要，用之前存好的內容。

打開時顯示「這個檔案在下方 [1] 分頁已經開著」或「另一個 vim 正在編輯這個檔案」，代表同一個檔案在別的格子或分頁還開著，這裡只能看不能存。按 [Ctrl]+[A] 再按提示裡的分頁編號切過去改，或先把那個 vim 關掉（`:q`）再開。直接關掉 iTerm 時 vim 其實還開在背景，再輸入 `codenv` 就會接回來，舊的分頁在最下面。

還在用舊版、看到一大段英文（Swap file … already exists）的話：確定沒有在別處開著，想救回修改按 [R]，不需要就按 [D]。更新到最新版就不會再出現這段英文。

**問：** 想把程式碼複製到別的地方（例如上傳作業）

在 vim 裡用滑鼠選取，或用 [Shift]+方向鍵選取，再按 [Ctrl]+[C]，就會複製到 Mac 的剪貼簿，到別的 App 按 [⌘ Cmd]+[V] 貼上。不要用 Option 拖曳整個畫面，那樣會連行號和旁邊的格子一起複製。

## tmux 與輸入法

**問：** 中文輸入法開著時，Ctrl+A 之後按的字沒反應

新版會在按下 Ctrl+A 時自動切成英文。按完 Ctrl+A 稍等一下再按下一個鍵比較保險；如果還是沒反應，改按 [Ctrl]+[A] 兩次叫出選單，用 ↑↓ 和 Enter 操作，不受輸入法影響。

**問：** 不小心按到 Ctrl+A，之後打的字怪怪的

按一下 [Esc] 取消就好。

**問：** 想關掉另一個工作階段（例如列表裡多出來的 1）

先切過去再關：按 [Ctrl]+[A] 兩次，選「列出所有分頁,切換過去」，用 [↑] [↓] 移到那個工作階段（例如 `1: 1 windows`）按 [Enter]。左下角藍底變成它的名字後，再按 [Ctrl]+[A] 兩次，選「關掉整個工作階段」按 [Enter]，就會切回原本的工作階段。關掉前確認裡面沒有還要用的程式。

**問：** Ctrl+A 兩下的選單，用滑鼠點不到，或一動滑鼠就不見

舊版的問題，執行一次更新就好。tmux 開著的話會直接載入新設定，不用重開。

**問：** 按 Cmd+Ctrl+A 沒有出現排列視窗

先執行一次更新，看安裝的訊息：有「已設定 Cmd+Ctrl+A」或「Cmd+Ctrl+A(叫出排列視窗)已經設定好了」才是裝好了；出現「~/.codenv-board 沒有裝成」代表缺編譯器，照新手上路第 2 步補裝。

別的 App 也用了 Cmd+Ctrl+A 的話，先搶到的那個才有效。這時可以從 Ctrl+A 兩下的選單選「用滑鼠排列格子」打開。

Cmd+Ctrl+A 只在 iTerm（或 Mac 內建的「終端機」）在最前面時有效，在別的 App 按不會有反應，這是故意的。舊版在全螢幕的 iTerm 裡按，排列視窗會開在別的桌面，看起來像沒反應；更新後就會疊在眼前的畫面上。

**問：** 想用滑鼠反白執行結果的文字

按住 [Option] 再拖曳，然後按 [⌘ Cmd] + [C]。

---

Manual

# 使用手冊

安裝好之後，日常會用到的指令和按鍵都在這裡。

1

## codenv 指令

| 指令 | 做什麼 |
| --- | --- |
| `codenv` | 用數字選資料夾、選檔案，開好寫程式的畫面。按 [n] 新增資料夾或檔案，[q] 取消，直接按 [Enter] 是先不開檔案。 |
| `codenv layout` | 重新選畫面要兩格還是三格。 |
| `codenv layout 2` | 直接設成兩格：左邊寫程式、右邊看結果。 |
| `codenv layout 3` | 直接設成三格：左邊 AI 或終端機、右上寫程式、右下看結果。 |

程式放在 `~/programming_language` 底下，每個資料夾是一個科目或一次作業。新檔名一定要有副檔名（`.cpp` 或 `.py`）。

2

## F9 與 F10

- [F9]：存檔，並檢查有沒有打錯。結果顯示在執行結果那格，最後一行用顏色標出 `✓ code is ok`、`⚠ code has warnings` 或 `✗ code is error`。游標留在 vim。之後一改程式，這一行會變成 `● 未儲存`，存檔後變成 `✓ 已存檔`，看一眼就知道有沒有存。剛用 vim 打開程式時，這一行一開始就是 `✓ 已存檔`；按 Ctrl+S 存檔時它會反白閃一下，本來就存好了也會閃。

- [F10]：存檔、編譯、執行。有錯就跟 F9 一樣只顯示錯誤；沒錯就在執行結果那格執行，游標跳過去，程式要輸入資料就在那裡打。按 [Esc] 跳回 vim。

- C++ 用 `g++ -std=c++17 -Wall` 編譯，執行檔放在旁邊的 `bin` 資料夾。Python 用 `python3` 執行。

### 怎麼看錯誤訊息

第 6 行: error:

```
 expected ';' in 'for' statement specifier
    6 |         for(r=1,r=r+1,r<10)
      |                           ^
```

第一行：錯在第幾行、種類（`error` 是錯誤，不改就不能執行；`warning` 是提醒，可以執行但可能有問題）、說明。第二行把那行程式抄出來，`^` 指出編譯器發現問題的位置。真正打錯的地方常常在 `^` 前面一點。同一行在 vim 裡也會畫上紅色底線。

錯誤很多時，先修第一個 error 再按一次 F9：後面的訊息常常是第一個錯連帶造成的。有 error 時 warning 先不顯示，最後會用一行灰字說還有幾個。

3

## 程式當掉時的訊息

程式有執行、但不是正常結束時，最後會出現紅字 `✗ code is error` 和原因：

| exit code | 意思 | 常見原因 |
| --- | --- | --- |
| 130 | 用 Ctrl+C 停止（不算錯） | 程式停不下來時自己按的 |
| 134 | 程式中止 | 有例外（exception）沒有被處理 |
| 86 | 程式做了不允許的事 | 整數除以 0、陣列索引超出範圍。上面的 `runtime error` 那行會寫出第幾行（`檔名:行:字`） |
| 138、139 | 記憶體存取錯誤 | 陣列索引超出範圍、指標沒設定好、遞迴太深 |
| 其他 | 回傳值不是 0 | C++ 的 main 裡 `return 1`；Python 則看上面的錯誤訊息 |

4

## vim 基本操作

vim 有兩種主要模式：一般模式打的字是指令，輸入模式打的字才會進到檔案。左下角出現 `-- INSERT --` 代表在輸入模式。

| 按鍵 | 做什麼 |
| --- | --- |
| [i] | 進入輸入模式，開始打字 |
| [Esc] | 回到一般模式 |
| `:w` | 存檔（沒有檔名時用 `:w hw1.cpp` 取名存檔） |
| `:q` / `:q!` / `:wq` | 關掉 / 不存檔直接關掉 / 存檔後關掉 |
| `:e!` | 放棄還沒存的修改，回到上次存檔的內容 |
| `u` | 復原（一般模式） |
| `:e 檔名` | 打開另一個檔案 |
| `:vsplit 檔名` | 左右分兩格，在新的一格打開檔案 |
| [O] / [o] | 在這行上面 / 下面開一行新的並開始打字 |

更多按鍵（移動、刪除複製、搜尋取代、卡住時怎麼辦）在 vim 教學。

5

## 編輯快捷鍵

這些按鍵跟 Windows 上的 C++ 編輯器（Dev-C++、Visual Studio）一樣，打字時也能用。

| 按鍵 | 做什麼 |
| --- | --- |
| [Ctrl]+[S] | 存檔 |
| [Ctrl]+[Z] / [Ctrl]+[Y] | 復原 / 重做 |
| 滑鼠拖曳、雙擊、[Shift]+方向鍵 | 選取文字；選取後直接打字會取代它，[Backspace] 刪掉 |
| [Ctrl]+[C] / [X] / [V] | 複製 / 剪下 / 貼上，跟 Mac 共用剪貼簿（[⌘ Cmd]+[V] 也能貼上） |
| [Tab] / [Shift]+[Tab] | 選取多行時整塊增加 / 減少縮排；打字時 Shift+Tab 減少這行的縮排 |
| [Ctrl]+[F] | 搜尋：打要找的字按 Enter，再按 [n] 找下一個 |
| [fn]+[←] / [→] | 跳到行首 / 行尾（Home / End） |
| 打 `(` `[` `"` | 自動補上另一半；打 `)` 會直接跳過已經有的那個；在空括號中間按 Backspace 兩個一起刪 |
| `{` 再按 [Enter] | 自動補上 `}`，游標停在中間縮排好的那行 |

做不到的

⌘ Cmd 開頭的快捷鍵（⌘Z、⌘S、⌘C）會被 iTerm 自己攔走，傳不到 vim，請用上面的 Ctrl 版本。Ctrl+A 全選也不行，因為 Ctrl+A 是 tmux 的指令鍵。

想用 Cmd+S 存檔

在 iTerm 加一條按鍵設定，讓 Cmd+S 送出 Ctrl+S：按 [⌘ Cmd]+[,] 打開設定 → 上方的 Profiles → Keys 分頁的 Key Mappings → 按清單下方的 + → 點 Keyboard Shortcut 的格子後按 Cmd+S → Action 選 Send Hex Code，欄位填 `0x13` → 下面的選單不要選 Apply to current session（只對目前分頁有效）→ 按 OK。馬上就能用，不用重開 iTerm。在 Claude Code 那格按 Cmd+S 不會存檔，只會顯示「要存程式請回到 vim 按 Ctrl+S」，打到一半的訊息不會不見。

6

## tmux 入門

tmux 負責把一個終端機視窗切成好幾格，而且讓程式在背景繼續跑。先認識三個名詞：

| 名詞 | 是什麼 | 例子 |
| --- | --- | --- |
| 格子（pane） | 畫面上被切開的每一塊，各自跑一個程式 | vim 一格、執行結果一格 |
| 分頁（window） | 一整個畫面，裡面可以有好幾格；像瀏覽器的分頁 | 每次輸入 `codenv` 就開一個新分頁 |
| 工作階段（session） | 一組分頁。關掉 iTerm 也不會消失，可以再接回來 | 最下面狀態列左邊的「Session 0」 |

### 最下面那條狀態列

Session 0| [1] zsh [2] cpp

藍底是工作階段的名字；後面的 `[1] zsh`、`[2] cpp` 是分頁，數字是編號，按 [Ctrl]+[A] 再按數字就能切過去。

### 暫時離開，等一下再回來

按 [Ctrl]+[A] → [d] 會離開 tmux，回到一般的終端機，但裡面的程式、打到一半的檔案都還在背景。要回去就輸入：

```
tmux attach
```

### 往上看之前的輸出

在那一格用滑鼠滾輪往上捲就好。也可以按 [Ctrl]+[A] → [[] 進入捲動模式，用方向鍵或 [PageUp] 移動，按 [q] 離開。每一格最多記得最近 10000 行。

7

## tmux 快捷鍵

tmux 的快捷鍵都是兩段式：先按 [Ctrl]+[A]，兩個都放開，再按下一個鍵。按錯了按 [Esc] 取消。

### 格子

| 按鍵 | 做什麼 |
| --- | --- |
| [Ctrl]+[A] → [|] | 左右分割（右邊開一格，資料夾跟目前這格一樣） |
| [Ctrl]+[A] → [-] | 上下分割（下面開一格） |
| [Ctrl]+[A] → 方向鍵 或 [h] [j] [k] [l] | 移到左 / 下 / 上 / 右那格（方向鍵可以連按） |
| [Ctrl]+[A] → [o] | 依序換到下一格 |
| [Ctrl]+[A] → [q] | 在每一格上顯示編號，馬上按數字就跳過去 |
| [Ctrl]+[A] → [Ctrl]+[h] [j] [k] [l] | 把邊界往左 / 下 / 上 / 右推（按住 Ctrl 可以連續推） |
| [Ctrl]+[A] → [z] | 把這格放大到整個畫面 / 還原 |
| [Ctrl]+[A] → [!] | 把這格拆出去，變成獨立的分頁 |
| [Ctrl]+[A] → [x] | 關掉這格（會再問一次，按 Enter 確定、Esc 取消） |

### 分頁

| 按鍵 | 做什麼 |
| --- | --- |
| [Ctrl]+[A] → [c] | 開一個新的分頁 |
| [Ctrl]+[A] → [n] / [p] | 下一個 / 上一個分頁 |
| [Ctrl]+[A] → [1]～[9] | 直接切到第幾個分頁 |
| [Ctrl]+[A] → [w] | 列出所有分頁和格子，用 ↑↓ 選、Enter 切過去（右邊會預覽內容） |
| [Ctrl]+[A] → [,] | 幫目前的分頁改名字（跟選單的「幫這個分頁取名」一樣） |
| [Ctrl]+[A] → [&] | 關掉整個分頁（會再問一次，按 Enter 確定） |

### 其他

| 按鍵 | 做什麼 |
| --- | --- |
| [Ctrl]+[A] 連按兩次 | 叫出中文選單，見下一節 |
| [Ctrl]+[A] → [d] | 暫時離開 tmux（程式繼續在背景跑），用 `tmux attach` 回來 |
| [Ctrl]+[A] → [[] | 捲動模式，往上看之前的輸出，[q] 離開 |
| [Ctrl]+[A] → [m]，或 [F5] | 開關滑鼠功能（預設是開的） |
| [Ctrl]+[A] → [r] | 重新讀取 tmux 設定（改了設定檔之後用） |
| [Ctrl]+[A] → [a] | 把 Ctrl+A 本身傳給程式（例如命令列跳到行首） |
| [Ctrl]+[A] → [?] | 列出所有快捷鍵（英文），[q] 離開 |
| [Ctrl]+[A] → [:] | 直接打 tmux 指令（要打英文；中文輸入法開著的話先切成英文） |

8

## Ctrl+A 兩下的選單

連按兩次 [Ctrl]+[A]，畫面中間會跳出這個選單。不用記快捷鍵，也不受中文輸入法影響：

上下分割:下面開一格

放大這格 / 還原

關掉這格

開新分頁

下一個分頁

上一個分頁

列出所有分頁,切換過去

幫這個分頁取名

這個分頁往左移

這個分頁往右移

分頁重新編號(補上空號)

用滑鼠排列格子(開視窗,Cmd+Ctrl+A)

模塊化排列(搬動格子、取名)…

幫這個工作階段取名

關掉整個工作階段

開關滑鼠功能

- 用 [↑] [↓] 移動反白的那一行，按 [Enter] 執行；也可以直接用滑鼠點。滑鼠移到選單外面，選單也會留著，點選單外面才會關掉。

- 按 [Esc] 關掉選單，什麼都不做。

- 選「關掉這格」會再問一次，按 [Enter] 確定。

- 選「幫這個分頁取名」，最下面會出現輸入框，直接打新名字（中文也可以）按 [Enter] 就好；什麼都沒打就按 [Enter]，或按 [Esc]，名字都不會變。改的是最下面 `[1] zsh` 這種分頁名稱。

- 選「幫這個工作階段取名」用法一樣，改的是左下角「Session 0」那塊的名字（工作階段名稱）。

- 「列出所有分頁,切換過去」會列出每個工作階段和底下的分頁，用 [↑] [↓] 選、[Enter] 切過去，[Esc] 離開。這個畫面是 tmux 內建的，所以是英文。

- 「往左移 / 往右移」跟旁邊的分頁交換位置，畫面會跟著移過去；「重新編號」把空號補起來，例如 1 2 4 變成 1 2 3。

- 「用滑鼠排列格子」打開排列視窗，跟按 [Cmd]+[Ctrl]+[A] 一樣。

- 「模塊化排列(搬動格子、取名)…」會再打開一個選單：
  - 「把這格搬到別的分頁」：接著選要搬去哪個分頁，這格會排在那個分頁的右邊。
  - 「把別的格子搬進這個分頁」：接著選要搬哪一格。在分頁那一行按 [→] 可以展開，看到裡面的每一格；直接選分頁的話，搬的是那個分頁目前選到的那格。
  - 「把這格拆出去,變成新的分頁」：只有一格的分頁不用拆。
  - 四種排法：左右並排、上下堆疊、左邊一大格右邊幾小格、排成方格。排完還可以用滑鼠拖格子的邊界調大小。
  - 「幫這格取名」：名字會顯示在那格上方，搬到別的分頁也會跟著；「拿掉這格的名字」後，分頁裡沒有名字了，名字列就收起來。

- 「關掉整個工作階段」會關掉目前這個工作階段裡所有分頁的程式（包括 Claude Code），救不回來，所以會再問一次，按 [Enter] 確定。還有別的工作階段的話會直接切過去。

9

## 用滑鼠排列格子（排列視窗）

格子、分頁多起來以後，用快捷鍵搬來搬去不好記。排列視窗把每個工作階段、分頁和格子畫成小縮圖，直接用滑鼠拖。

### 打開和收起

- 在 iTerm 裡按 [Cmd]+[Ctrl]+[A] 打開，再按一次收起來。在別的 App 按不會有反應，不會搶走那個 App 自己的快捷鍵。

- 切到別的 App 時，排列視窗會自動收起來；切回 iTerm 再按一次就出現。

- 也可以從 Ctrl+A 兩下的選單選「用滑鼠排列格子(開視窗,Cmd+Ctrl+A)」。

- 按 [Esc]、[Cmd]+[W] 或左上角的紅色按鈕都是收起來，下次按 Cmd+Ctrl+A 馬上出現。

- 視窗浮在 iTerm 上面，第一下就能直接拖，不用先點一下視窗。

- iTerm 開成全螢幕也一樣，視窗會疊在現在的畫面上，不會跳到別的桌面。

### 可以做的事

| 想做的事 | 怎麼做 |
| --- | --- |
| 把格子搬到別的分頁 | 把格子拖到那個分頁的卡片上 |
| 把格子放到另一格旁邊 | 拖到那一格上面（那格比較寬就左右放，比較高就上下放） |
| 把格子拆成新的分頁 | 拖到虛線框「新 window」，或在格子上按右鍵選「拆出去,變成新的 window」 |
| 交換兩個分頁的位置 | 按住分頁卡片的標題列拖到另一個分頁上 |
| 把分頁搬到別的工作階段 | 拖到那個工作階段的名字，或它的「新 window」 |
| 開新的工作階段 | 按右上角「新增 session」；把分頁或格子拖到這個按鈕或最下面的「新 session」，會開新的工作階段裝它 |
| 切換過去 | 點一下格子 |
| 改名字 | 雙擊分頁名字或格子，或按右鍵選改名；格子的名字留空就是拿掉。工作階段按它那一行的「改名」，或雙擊「Session …」 |
| 換排列方式 | 在分頁卡片上按右鍵，選左右並排、上下堆疊、左邊一大格、排成方格 |
| 工作階段改名、新增分頁、重新編號 | 工作階段那一行右邊的按鈕 |

視窗裡的 session、window、pane 就是 tmux 的工作階段、分頁、格子（見 tmux 入門）。分頁名字旁邊的橘色小點代表那裡有新的動靜，例如 Claude 回覆完了。

不想要 Cmd+Ctrl+A

在 iTerm 執行下面兩行，就會關掉、以後登入也不會再啟動；排列視窗還是可以從選單打開。想恢復，再執行一次一行安裝就好。

```
launchctl bootout gui/$UID/io.github.olilllioli287.codenv-board
mkdir -p ~/codenv-removed && mv ~/Library/LaunchAgents/io.github.olilllioli287.codenv-board.plist ~/codenv-removed/
```

10

## 中文輸入法

注音、威注音這類輸入法開著時，你按的字母會先被拿去組字。codenv 的處理方式：

- Ctrl+A 指令：按下 Ctrl+A 的瞬間自動切成英文，指令做完再切回原本的輸入法。按完 Ctrl+A 稍等一下再按下一個鍵比較保險。

- 選單：Ctrl+A 連按兩次叫出的選單只用方向鍵、Enter、Esc，完全不受輸入法影響。

- vim 的快捷鍵：Ctrl+S、Ctrl+Z、F9、F10 這些組合鍵和功能鍵，輸入法不會攔，照常能用。

11

## 滑鼠

- 點一下切換到那一格；滾輪上下捲動；拖曳格子之間的分隔線調整大小。

- 想把格子搬到別的分頁、交換分頁位置，按 [Cmd]+[Ctrl]+[A] 用排列視窗拖曳。

- 在 vim 裡點一下移動游標，拖曳或雙擊選取文字，再按 Ctrl+C 複製。

- 在 vim 以外的格子（例如執行結果）想反白複製文字，要按住 [Option] 再拖曳，然後按 [⌘ Cmd]+[C]。

12

## 改成自己的習慣

codenv 是 MIT 授權，可以照自己的習慣改。最簡單的方法：把自己的設定寫在 `.local` 檔。codenv 更新時會整個換掉 `~/.vimrc` 和 `~/.tmux.conf`，但不會動到 `.local` 檔，你的設定會一直保留。

| 想改的 | 寫在這個檔 | 什麼時候生效 |
| --- | --- | --- |
| vim | `~/.vimrc.local` | 下次打開 vim |
| tmux | `~/.tmux.conf.local` | 按 Ctrl+A → r 重新讀取 |
| codenv 的資料夾、AI、格數 | `~/.codenv.zsh` 開頭的三行 | 重開 iTerm（更新時會保留） |

例如想讓 vim 的行號顯示成「離游標幾行」，用下面這行打開（沒有這個檔會自動建立）：

```
touch ~/.vimrc.local && open -e ~/.vimrc.local
```

在裡面寫 `set relativenumber`，存檔後重開 vim。寫在 `.local` 的設定會蓋過 codenv 的同一項設定。

想改得更多（例如改 F10 的行為），可以在 GitHub 上 fork 一份到自己的帳號來改，做法見技術文書的「原始碼與授權」。

13

## 用 AI 輔助學習

用 AI 問程式問題時，先讓它知道「你是剛開始學 C++ 的新生、希望一步一步來」，它就不會一次丟一整支程式或一堆看不懂的名詞。下面這段是給 AI 的「記憶」，貼一次之後，每次對話它都會記得。

### Gemini

- 打開 Gemini 的「將個人化記憶匯入 Gemini」頁面。

- 第 1 格的提示詞不用理它。

- 按下面方塊右邊的「複製」，貼到第 2 格「把你的資訊貼到這裡…」。

- 按「新增個人化記憶」。

```
使用者是大學一年級新生，正在修「計算機程式（一）」，課程教 C++，課本是 Savitch 的《Absolute C++》。使用者沒有任何程式基礎，第一次學寫程式，很多基本概念和名詞都還不懂。

課程內容依序是：第 1 章 C++ 基礎（cout、cin、變數、整數除法、%、型別轉換、++ 和 --、小數位數），第 2 章流程控制（if、switch、while、for、巢狀迴圈），第 3 章陣列（加總、最大最小值、搜尋、排序、矩陣）。成績有 60% 是三次上機考，要在電腦上自己把程式打出來、編譯、執行，考試用的編輯器是 Dev-C++；另外筆試 30%、作業 10%。

教使用者時的方式：
- 一律用繁體中文（台灣用語）回答。
- 一次只教一個概念或一個步驟，確認使用者懂了、做完了，再進下一步。不要一次丟出很多內容或一整支完整程式。
- 先用白話講，再補正式說法。專有名詞第一次出現時，用一句話解釋它是什麼。
- 解釋「為什麼」，不要只給答案。
- 使用者要練習上機考，所以寫作業或練習題時，先給提示和思考方向，讓使用者自己打程式；使用者卡住或主動要求時，再給更完整的程式碼。
- 每次出現使用者沒看過的新指令（例如 cout、for、rand），附上一個很短的範例和它的執行結果。
- 使用者貼出錯誤訊息或程式時，先說明那段訊息是什麼意思、錯在第幾行，再說下一步怎麼改，一次只改一個地方。
- 提醒使用者：上機考是電腦自動比對輸出，多一個或少一個空白都算錯，輸出格式要跟題目一模一樣。
- 語氣溫和、冷靜，像有耐心的學長姐。不要過度稱讚，也不要講空泛的鼓勵；使用者的理解有錯時，直接但友善地指出來。
- 使用者看起來很累或說看不懂時，把步驟拆得更小、講得更短。
```

內容用「使用者」而不是「我、你」，是因為 Gemini 的匯入頁面要求用第三人稱。如果考試用的不是 Dev-C++，把那一句改成自己實際用的編輯器。

讓 AI 讀懂 codenv：想問 AI 關於 codenv 的問題時，把這個網址給它：`https://raw.githubusercontent.com/olilllioli287/codenv/main/docs/guide.md`。這是整個網站的純文字版，AI 比較讀得懂。AI 連不上網的話，打開這個網址按 ⌘S 存成檔案，再上傳給它。

ChatGPT、Claude 也能用：貼到 ChatGPT 的「自訂指令」或 Claude 專案的「指示」欄位，效果一樣。

不要放個人資料

匯入的內容會存在服務商的紀錄裡，可能被拿去改進他們的服務。這段只寫了「新生、學 C++、希望怎麼被教」；自己加內容時，不要放名字、學號這類資料。

還有一點：上機考不能用 AI，最後還是要自己會打。讓 AI 給提示、自己動手寫，比直接拿答案有用得多。

14

## 換回舊版設定

每次安裝或更新，有變動的設定檔都會先備份成「檔名.bak-日期時間」。先列出備份檔：

```
ls ~/.vimrc.bak-* ~/.tmux.conf.bak-*
```

再把想要的那份複製回來（把 `日期時間` 換成上面列出來的那串數字），然後重開 vim：

```
cp ~/.vimrc.bak-日期時間 ~/.vimrc
```

15

## 解除安裝

下面的做法是把 codenv 的檔案搬到家目錄的 `codenv-removed` 資料夾，不是直接刪除，想恢復時再搬回來就好。

```
mkdir -p ~/codenv-removed
launchctl bootout gui/$UID/io.github.olilllioli287.codenv-board
mv ~/Library/LaunchAgents/io.github.olilllioli287.codenv-board.plist ~/.codenv.zsh ~/.codenv-ime ~/.codenv-ime.swift ~/.codenv-board ~/.codenv-board.swift ~/.codenv-compat ~/.codenv-kit ~/codenv-removed/
```

第二行關掉在背景等 Cmd+Ctrl+A 的排列視窗。有些檔案沒裝過的話，會出現 No such file 或找不到，不影響。

- 執行 `open -e ~/.zshrc`，刪掉 `# codenv 程式練習環境` 和 `source ~/.codenv.zsh` 這兩行，存檔。

- `~/.vimrc` 和 `~/.tmux.conf` 想換回安裝前的樣子，照換回舊版設定把最早的那份備份複製回來；安裝前本來沒有的話，可以把它們也搬進 `codenv-removed`。

- 自己建過 `~/.vimrc.local`、`~/.tmux.conf.local` 的話，也可以一起搬走。

- 關掉 iTerm 再打開。寫過的程式在 `~/programming_language`，不會被動到。

---

vim

# vim 教學

codenv 寫程式的那格就是 vim。平常用 Ctrl+S、滑鼠、方向鍵就能寫作業；這頁介紹 vim 本來的按鍵，學會幾個之後改程式會快很多。不用一次背完，挑用得到的就好。

1

## 先認識 vim

vim 是在終端機裡用的文字編輯器，幾乎每台 Mac 和 Linux 都有。它的特色是不用滑鼠，靠鍵盤上的字母就能移動、刪除、複製，所以要先分清楚「現在打的字是指令還是內容」，也就是下一節的模式。

codenv 在 vim 上加了 Windows 編輯器的習慣（見使用手冊的編輯快捷鍵），完全不學 vim 指令也能寫作業。這頁的按鍵是 vim 原本就有的，兩種可以混著用。

```
  1 #include <iostream>
  2 using namespace std;
  3 
  4 int main() {
  5     cout << "Hello" << endl;
  6 }
-- INSERT --
```

- 左邊的數字是行號。F9 的錯誤訊息說「第 5 行」，就看這裡。

- 最下面一行顯示現在的模式（例如 `-- INSERT --`），按 [:] 打的指令也會出現在這裡。

- 按 F9 後，有錯的地方畫紅色底線，警告畫黃色底線。

- 有沒有存檔，看執行結果那格的 `✓ 已存檔` / `● 未儲存`。

2

## 模式

同一個按鍵在不同模式做的事不一樣。例如 [x] 在輸入模式會打出 x，在一般模式是刪掉一個字。

| 模式 | 怎麼進去 | 最下面顯示 | 這時打字會怎樣 |
| --- | --- | --- | --- |
| 一般模式 | 按 [Esc] | （什麼都沒有） | 字母是指令，例如 [x] 刪掉一個字、[dd] 刪掉一行 |
| 輸入模式 | 按 [i]（或 [a]、[o]、[O]） | `-- INSERT --` | 打的字進到檔案裡 |
| 選取模式 | 滑鼠拖曳，或 [Shift]+方向鍵 | `-- SELECT --` | 打字會取代選到的內容；[Ctrl]+[C] 複製 |
| 視覺模式 | 一般模式按 [v]（整行選按 [V]） | `-- VISUAL --` | 用方向鍵擴大範圍，按 [y] 複製、[d] 刪除、[>] 增加縮排 |
| 指令列 | 一般模式按 [:] | `:` 和你打的指令 | 打完按 [Enter] 執行，按 [Esc] 取消 |

不知道現在在哪個模式

按兩下 [Esc]，一定會回到一般模式。要打字再按 [i]。

注音開著時

一般模式的指令是英文字母，注音開著時會被拿去組字。下指令前先把輸入法切成英文；Ctrl 開頭的按鍵和 F9、F10 不受影響。

3

## 開檔、存檔、離開

這些都在一般模式打，打完按 [Enter]。

| 指令 | 做什麼 |
| --- | --- |
| [Ctrl]+[S] 或 `:w` | 存檔 |
| `:w hw2.cpp` | 存成 hw2.cpp。還沒有檔名時就是取名存檔；已經有檔名的話是另外存一份，畫面上編輯的還是原本的檔案 |
| `:e hw2.cpp` | 打開另一個檔案（不存在就開一個新的，存檔後才會真的建立） |
| `:e!` | 放棄還沒存的修改，回到上次存檔的內容 |
| `:q` | 離開（有沒存的修改時會拒絕） |
| `:q!` | 不存檔，直接離開 |
| `:wq` | 存檔後離開 |

出現 E37

改過還沒存，就打 `:q` 或 `:e` 別的檔案，最下面會出現 `E37: No write since last change (add ! to override)`，意思是「有改過還沒存」。要留著就先存檔；不要的話在指令後面加 `!`。注意 `:q!`、`:e!` 丟掉的修改，按 Ctrl+Z 也救不回來。

4

## 移動游標

方向鍵和滑鼠在每個模式都能用。下面這些在一般模式用，比按很多次方向鍵快。

| 按鍵 | 做什麼 |
| --- | --- |
| [h] [j] [k] [l] | 左、下、上、右（手不用離開字母區） |
| [w] / [b] | 往後 / 往前跳一個字 |
| [^] / [$] | 跳到這行第一個字 / 行尾（[fn]+[←] / [→] 也可以） |
| [gg] / [G] | 跳到第一行 / 最後一行 |
| `:12` | 跳到第 12 行，對照錯誤訊息的行號時很好用 |
| [%] | 游標在括號上時，跳到配對的另一半，可以看 `{` 是在哪裡關掉的 |
| [Ctrl]+[D] / [Ctrl]+[U] | 往下 / 往上捲半頁 |

前面加數字可以重複：[5j] 往下 5 行，[3w] 往後 3 個字。

5

## 刪除、複製、貼上

都在一般模式用。

| 按鍵 | 做什麼 |
| --- | --- |
| [x] | 刪掉游標上的字 |
| [dd] | 刪掉整行（刪掉的內容可以用 [p] 貼回來，等於剪下） |
| [yy] | 複製整行 |
| [p] / [P] | 貼在游標後面 / 前面；複製的是整行時，貼在下一行 / 上一行 |
| [dw] | 刪到下一個字前面 |
| [cw] | 改掉這個字：刪到字尾，直接進入輸入模式 |
| [r] 再按一個字 | 把游標上的字換成那個字（例如把 `,` 換成 `;`） |
| [A] / [I] | 跳到行尾 / 行首開始打字（補分號很方便） |
| [o] / [O] | 在下面 / 上面開新的一行開始打字 |
| [u] 或 [Ctrl]+[Z] | 復原 |
| [Ctrl]+[R] 或 [Ctrl]+[Y] | 重做（Ctrl+R 是 vim 原本的，Ctrl+Y 是 codenv 加的） |
| [.] | 重複上一次的修改，例如刪了一行後按 [.] 再刪一行 |
| [>>] / [<<] | 這行增加 / 減少縮排 |

數字一樣能用：[3dd] 刪三行，[5yy] 複製五行。

貼到別的 App

[dd]、[yy] 拿到的內容存在 vim 自己的暫存區，只能在 vim 裡用 [p] 貼上。要貼到別的 App（例如上傳作業），選取後按 [Ctrl]+[C]。

6

## 搜尋與取代

| 按鍵 | 做什麼 |
| --- | --- |
| `/main` 再按 [Enter]（或 [Ctrl]+[F]） | 往下找 main，打字的同時就會先跳到第一個符合的地方 |
| [n] / [N] | 下一個 / 上一個 |
| [*] | 找游標所在的這個字，例如看一個變數還在哪裡用到 |
| `:%s/cnt/count/g` | 整個檔案的 cnt 全部換成 count |
| `:%s/cnt/count/gc` | 一個一個問：[y] 換、[n] 跳過、[q] 停止 |

只換完整的字

`:%s/cnt/count/g` 會把名字裡含 cnt 的也一起換掉（例如 `cnt2` 變成 `count2`）。只換完整的 cnt，要寫成 `:%s/\<cnt\>/count/g`。

7

## 寫程式好用的功能

| 按鍵 | 做什麼 |
| --- | --- |
| [F9] / [F10] | 檢查 / 執行，見使用手冊的 F9 與 F10 |
| `:12` | 照錯誤訊息跳到第 12 行 |
| [%] | 檢查括號有沒有配對：跳到的不是你想的那個，就是少了或多了括號 |
| [gg=G] | 整個檔案重新排縮排，C++ 縮排亂掉時很好用（Python 的縮排決定程式意思，不要用） |
| [Ctrl]+[N] | 打字時自動補完：打出變數名稱的前幾個字再按，會列出檔案裡出現過的字；再按 [Ctrl]+[N] 換下一個，選到就直接繼續打字 |
| [gd] | 游標在變數上時，跳到它宣告的地方 |
| `:vsplit hw2.cpp` | 左右分兩格，對照著看另一個檔案。按 [Ctrl]+[W] 再按 [w] 切換（也可以用滑鼠點），`:q` 關掉游標所在的那格 |

8

## 卡住了怎麼辦

| 狀況 | 怎麼辦 |
| --- | --- |
| 打的字變成指令，畫面亂跳、行被刪掉 | 現在在一般模式。先按 [u]（或 [Ctrl]+[Z]）把剛剛的動作復原，再按 [i] 開始打字 |
| 最下面出現 `recording @q` | 不小心按到 [q]，開始錄製巨集了。再按一次 [q] 停止 |
| 最下面出現 `Press ENTER or type command to continue` | 按 [Enter] 就好 |
| 跳出一個小視窗，裡面是之前打過的指令 | 不小心按到 [q] [:]，輸入 `:q` 按 [Enter] 關掉 |
| `E37: No write since last change` | 有改過還沒存，見上面的開檔、存檔、離開 |
| `E45: 'readonly' option is set` | 這個檔案現在只能看不能存，常見原因是同一個檔案在別的地方開著，見常見問題 |
| 畫面上殘留奇怪的字 | 按 [Ctrl]+[L] 重畫畫面 |
| 怎麼按都不對 | 按兩下 [Esc]，輸入 `:q!` 不存檔離開，再重新打開（沒存的修改會不見） |

9

## 用 vimtutor 練習

vim 內建一份互動練習 vimtutor，有中文版。照著做大約 30 分鐘，練習用的是複製出來的檔案，不會動到你的程式。在沒有在用的一格（例如三格模式左邊那格，或用 Ctrl+A 兩下的選單開新分頁）輸入：

```
LANG=zh_TW.UTF-8 vimtutor
```

前面的 `LANG=zh_TW.UTF-8` 是要它用中文版；只打 `vimtutor` 的話會照 Mac 的語言設定，可能出現英文版。練習時用的是原版 vim，codenv 加的 Ctrl+S、Ctrl+Z 這些在裡面不能用，照教學用 `:w`、[u] 就好。練習完輸入 `:q!` 離開。

---

Technical Docs

# 技術文書

給想知道 codenv 怎麼運作、或想自己修改的人。原始碼都在 GitHub（https://github.com/olilllioli287/codenv）。

1

## 安裝了哪些檔案

| 位置 | 用途 |
| --- | --- |
| `~/.vimrc` | vim 設定：F9 / F10、錯誤底線、編輯快捷鍵、自動補括號 |
| `~/.tmux.conf` | tmux 設定：Ctrl+A 指令、中文選單、執行結果那格按 Esc 跳回 vim |
| `~/.codenv.zsh` | `codenv` 指令本體，以及 `CODENV_ROOT`、`CODENV_AI`、`CODENV_LAYOUT` 三個設定 |
| `~/.zshrc` | 加上一行 `source ~/.codenv.zsh`，讓終端機認得 codenv |
| `~/.codenv-ime` | 切換輸入法的小程式（安裝時從 `codenv-ime.swift` 編譯），原始碼副本在 `~/.codenv-ime.swift` |
| `~/.codenv-board` | 排列視窗（安裝時從 `codenv-board.swift` 編譯），原始碼副本在 `~/.codenv-board.swift` |
| `~/Library/LaunchAgents/io.github.olilllioli287.codenv-board.plist` | 登入時在背景啟動 `~/.codenv-board --daemon`，在 iTerm 裡按 Cmd+Ctrl+A 才會有效 |
| `~/.codenv-compat/` | 讓 Windows 寫的程式也能跑：`include/bits/stdc++.h`、`include/conio.h`（`getch()`、`kbhit()`）、讓輸出馬上顯示的 `include/codenv-unbuffered.h`，以及 `system("pause")`、`system("cls")`、`system("color …")`、`system("title …")` 用到的 `bin/pause`、`bin/cls`、`bin/color`、`bin/title` |
| `~/.vimrc.local`、`~/.tmux.conf.local` | 自己的設定（自己建立；codenv 不會動到） |
| `~/.codenv-kit/` | 一行安裝下載的完整安裝包，iTerm 配色檔也在這裡 |

2

## 一行安裝的流程

- `get.sh` 從 GitHub 下載 main 分支的壓縮檔，解到 `~/.codenv-kit`（舊的會先移除），再執行裡面的 `install.sh`。

- `install.sh` 比對 `vimrc`、`tmux.conf`：內容一樣就跳過，不一樣就先備份再覆蓋。

- 用 `swiftc` 編譯 `codenv-ime.swift`；原始碼沒變就不重編，沒有編譯器就跳過（其他功能不受影響）。

- 同樣編譯 `codenv-board.swift`，再寫入 LaunchAgent 的 plist，用 `launchctl bootstrap` 啟動；排列視窗重編過或 plist 改過才重新啟動。用假的 `HOME` 測試安裝時不會設定 LaunchAgent。

- 把 `compat/` 複製成 `~/.codenv-compat`（內容一樣就跳過；不一樣就整個資料夾換成新版，新版刪掉的檔案不會留下來）。

- 安裝新的 `codenv.zsh` 前，先讀出舊檔裡的 `CODENV_ROOT`、`CODENV_AI`、`CODENV_LAYOUT`，裝好後填回去。

- tmux 正在執行的話，直接 `source-file` 載入新設定。

3

## F9 / F10 背後做了什麼

- 在檔案所在的資料夾執行 `g++ -std=c++17 -Wall`（F9 加 `-fsyntax-only` 只檢查；F10 輸出到 `bin/檔名`）。Python 用 `py_compile` 檢查。

- 編譯器訊息只留下跟自己檔案有關的部分，系統標頭檔的 note 全部拿掉；每則訊息開頭的「檔名:行:字:」改寫成「第 N 行:」，並用 `matchaddpos` 在 vim 裡畫底線。

- 執行結果那格是 tmux 右下（或右邊）的 pane，用 `respawn-pane` 重開並執行程式，跑完回到 shell。pane 被關掉時會依 `@codenv_layout` 在右邊或下面重開。

- 執行指令前先 `trap : INT`：Ctrl+C 只停掉程式，外層 shell 留著，那格才不會跟著消失。

- F10 編譯時加 `-fsanitize=integer-divide-by-zero,bounds -fno-sanitize-recover=all`，執行時設 `UBSAN_OPTIONS=exitcode=86:abort_on_error=0`：arm64 的整數除以 0 不會產生 SIGFPE，沒有這個檢查只會得到 0。不開 `signed-integer-overflow`，溢位的行為跟 Windows 一樣。

- 程式結束後檢查 exit code，130 以外的非 0 值用紅字標示，並說明常見原因。

- Windows 相容：編譯時加 `-I ~/.codenv-compat/include`（提供 `bits/stdc++.h`，以及用 `termios` 暫時切成不等 Enter、不回顯的 `conio.h`；`getch()` 直接 `read()` 鍵盤，不經過 `cin` 的緩衝區，跟 Windows 一樣讀不到前面留下的 Enter）和 `-include codenv-unbuffered.h`（程式開始前 `setvbuf(stdout, nullptr, _IONBF, 0)`，輸出不等換行就顯示）；執行時把 `~/.codenv-compat/bin` 放進 `PATH`，`system("pause")`、`system("cls")` 才找得到指令。Python 加 `PYTHONUNBUFFERED=1`。用到 `windows.h` 時在錯誤訊息下面加一行中文說明。

- Python：`py_compile` 的縮排錯誤格式是 `Sorry: IndentationError: … (檔名, line N)`，跟一般的 `File "…", line N` 不同，兩種都抓行號；常見的幾種錯誤加一行中文說明。

- 有 error 時，`warning` 和跟在它後面的 `note` 不顯示，最後加一行灰字說隱藏了幾個；只有 warning 時照常全部顯示。

- 存檔狀態：`BufWritePost`、`TextChanged`、`TextChangedI` 判斷檔案現在是已存檔、未儲存，還是剛檢查過（記在 `b:code_state`，狀態沒變就不做事）。改變時用 `tmux capture-pane` 找執行結果那格畫面上的狀態行，再直接寫進那格的終端機（`pane_tty`）：`ESC 7` 記住游標、移到那一行清掉重寫、`ESC 8` 放回游標，所以不會打斷那格的 shell。找不到狀態行就不改。剛打開 .cpp / .py、那格又只有提示字元（是 shell、沒有子程序、畫面上每行都一樣）時，用 `tmux respawn-pane` 重開那格，先印出狀態再進 shell。存檔時寫一次加上反白（`ESC [7m`）的同一行，0.25 秒後再寫回一般的樣子。

- 連結錯誤：訊息裡有 `Undefined symbols` 時，從 `"名稱", referenced from` 抓出找不到的函式，`_main` 另外提示 main 打錯字。

4

## 輸入法自動切換（codenv-ime）

輸入法會在按鍵送進終端機之前就把字母拿去組字，tmux 收不到。Ctrl 組合鍵不會被攔，所以在按下 Ctrl+A 時切換最可靠：

- tmux 的 `prefix` 設成 `None`，改用 `bind -n C-a` 自己處理：先在背景執行 `~/.codenv-ime tmux-prefix`，再 `switch-client -T prefix`。

- `codenv-ime` 用 macOS 的 Text Input Sources API（`TISSelectInputSource`）切到 ABC 鍵盤；本來就是英文時什麼都不做。

- 之後每隔一小段時間問 tmux `#{client_prefix}`，變回 0（指令做完）就切回原本的輸入法；如果這段時間你自己換過輸入法，就不切。

- 從按下 Ctrl+A 到切成英文大約 0.1 秒。沒有 `~/.codenv-ime` 時，Ctrl+A 照常運作。

5

## 排列視窗（codenv-board）

- SwiftUI 寫的 Mac App，原始碼只有一個檔案 `codenv-board.swift`。每秒用 `tmux list-panes -a -F …` 讀出所有工作階段、分頁、格子的位置和大小，畫成縮圖；拖曳中暫停更新，免得拖到一半目標不見。

- 放開滑鼠後執行對應的 tmux 指令：`join-pane`（搬格子）、`break-pane`（拆成新分頁）、`swap-window` / `move-window`（交換或搬分頁）、`new-session`（新的工作階段）、`select-layout`、`rename-window`；格子名字寫進 `@codenv-pane-name`，跟選單的模塊化排列共用。

- 同一個 tmux 只開一個視窗：用 socket 路徑算出一個 pid 檔，已經有在跑的就發 distributed notification 請它出來，自己結束。

- `--daemon`：LaunchAgent 在登入時啟動（`RunAtLoad`；不正常結束時自動重啟），平常是沒有 Dock 圖示的背景 App。快捷鍵用 Carbon 的 `RegisterEventHotKey` 註冊，不需要「輔助使用」權限；認的是 A 那顆鍵的位置，輸入法開著也有效。只有 iTerm 或「終端機」（或排列視窗自己）在最前面時才註冊，看 `NSWorkspace.didActivateApplicationNotification` 換到別的 App 就 `UnregisterEventHotKey` 放掉，讓那個 App 自己用，視窗開著的話也一起收起來。Esc、Cmd+W、Cmd+Q 只把視窗收起來，並停止每秒更新。

- 背景啟動時沒有 `$TMUX`，就用 tmux 預設的 socket（`/private/tmp/tmux-<uid>/default`）；也沒有 `LANG`，所以 tmux 指令都加 `-u`，中文名字才不會變成底線。從選單打開時，會把 tmux client 名稱交給背景的視窗，點格子時切換的是你按選單的那個 iTerm 視窗；用快捷鍵打開時切換最近用過的那個。

6

## tmux 改了哪些設定

codenv 沒有用 TPM 之類的第三方外掛，全部的改動都寫在 `~/.tmux.conf` 這一個檔案裡。跟剛裝好的 tmux 比，差別如下：

| 項目 | 原版 tmux | codenv |
| --- | --- | --- |
| 指令鍵 | Ctrl+B | Ctrl+A，按下時自動把中文輸入法切成英文（`bind -n C-a` 加上 `codenv-ime`） |
| 中文選單 | 沒有 | Ctrl+A 連按兩次（`display-menu -O -M`）。用鍵盤叫出的選單 tmux 預設不收滑鼠，`-M` 讓它收；tmux 把滑鼠移動當成「沒按鍵的放開」，沒有 `-O` 的話滑鼠一移出選單就會關掉 |
| 左右 / 上下分割 | `%` / `"`，新格子回到家目錄 | `|` / `-`，新格子留在目前的資料夾 |
| 移動到旁邊那格 | 方向鍵 | 方向鍵，加上 `h` `j` `k` `l` |
| 調整格子大小 | Ctrl+方向鍵 | Ctrl+`h` `j` `k` `l`，可以連按 |
| 關掉格子 / 分頁的確認 | 打 `y` | 按 Enter（`confirm-before -y`），中文輸入法開著也能確定 |
| 滑鼠 | 關 | 開（點選格子、滾輪捲動、拖曳邊界）；Ctrl+A m 或 F5 切換 |
| 分頁改名 | Ctrl+B `,`，英文提示 | Ctrl+A `,` 或選單的「幫這個分頁取名」，中文提示。名字先存進 `@codenv-name` 再用 `#{@codenv-name}` 取出，名字裡有 `#` 也照原樣顯示（選單裡的指令會先被展開一次，所以那邊寫成 `##`） |
| 工作階段改名 | Ctrl+B `$`，英文提示 | 選單的「幫這個工作階段取名」，中文提示，做法跟分頁改名一樣（暫存在 `@codenv-sname`）。排列視窗的「改名」用 `rename-session` |
| 分頁編號 | 從 0 開始 | 從 1 開始，跟鍵盤數字鍵的順序一樣 |
| 捲動紀錄 | 2000 行 | 10000 行 |
| 捲動模式的按鍵 | emacs 風格 | vi 風格（跟 vim 一樣用 h j k l） |
| 狀態列 | 綠色，右邊有時鐘 | 黑底，左邊藍底顯示工作階段名稱；分頁名稱不會自動改掉 |
| Esc | 直接傳給程式 | 在執行結果那格按 Esc 跳回 vim（`@cpprun` / `@cppvim`；vim 那格不在了就照常送出），其他格子照常 |
| Ctrl+Z | 傳給程式 | 在執行結果那格、程式還在跑時換成 Ctrl+D（結束輸入，跟 Windows 的 Ctrl+Z 一樣） |
| Ctrl+S | 傳給程式（終端機會停止輸出，Ctrl+Q 才恢復） | 只傳給 vim 這類編輯器；其他格（包括 Claude Code，它的 Ctrl+S 會把打到一半的訊息收起來）顯示中文說明 |
| Home / End | 直接傳給程式 | 轉成 Ctrl+A / Ctrl+E，vim 和命令列都會跳到行首 / 行尾 |
| Ctrl+Enter 這類組合鍵 | 不一定傳得到 | 開啟延伸按鍵（`extended-keys on`），給 Claude Code 用 |
| 關掉工作階段後 | 跳出 tmux，回到一般的終端機 | 還有別的工作階段就切過去（`detach-on-destroy off`）；選單的「關掉整個工作階段」用 `confirm-before` 再問一次 |
| 搬動分頁 | 要自己打 `swap-window`、`move-window -r` | 選單的往左移 / 往右移（`swap-window -d -t :-1` / `:+1`，用 `window_start_flag` / `window_end_flag` 擋住最邊邊）、重新編號（`move-window -r`） |
| 模塊化排列 | 要自己打 `join-pane`、`break-pane`、`select-layout` | 選單裡的第二層選單（`display-menu` 裡再開 `display-menu`，指令會被展開兩次，要留到最後才展開的 `#` 寫成 `####`）。搬格子用 `choose-tree` 選目的地，這一格用 `@視窗代號.格子編號` 指定，因為 `choose-tree` 會把指令裡的 `%1` 這類字換成選到的項目，會跟 `%格子代號` 撞在一起 |
| 格子名字 | 上方沒有名字列 | 名字存在格子的 `@codenv-pane-name`，`pane-border-format` 顯示名字（沒取名的顯示編號）；`window-layout-changed` hook 檢查分頁裡有沒有取名的格子，有才開 `pane-border-status top` |
| 不在 tmux 裡輸入 codenv | — | 有沒人在看的工作階段（關掉 iTerm 留下的）就接回去，新分頁開在旁邊；沒有才開新的工作階段 |
| 自己的設定 | — | 最後讀取 `~/.tmux.conf.local`（`source-file -q`，沒有這個檔也不會出錯） |

7

## vim 設定重點

- Windows 式選取：`selectmode=mouse,key`、`keymodel=startsel,stopsel`、`selection=exclusive`。

- 剪貼簿：Ctrl+C / X / V 對應到 `"*` 暫存器（macOS 的 vim 有 `+clipboard`）。沒有選取時 Ctrl+X 設成 `<Nop>`，蓋掉 vim 原本「數字減 1」和插入模式的 `^X` 補全。

- 自動補括號用 `<C-g>U<Left>` 移動游標，不會打斷復原的步驟；貼上時 bracketed paste 會略過這些對應，所以貼上的程式碼不會被重複補。

- 自動縮排：`filetype indent on`，Python 用 vim 內建的 `python#GetIndent`；C++ 另外設 `cindent`。

- Esc 不等待：`ttimeout ttimeoutlen=50`（原本 Esc 要等 `timeoutlen` 的 1 秒，確定後面沒有接方向鍵之類的按鍵碼）。

- Big5：`fileencodings=ucs-bom,utf-8,cp950,latin1`，讀進來是 `cp950` 的檔案在 `BufReadPost` 改成 `fileencoding=utf-8`，存檔時就轉好。

- 暫存檔（swap）：`SwapExists` 用 `swapinfo()` 和 `kill -0` 判斷另一個 vim 還在不在；在的話用它的 tty 對照 `tmux list-panes -a` 找出分頁編號。

- `{` 加 Enter 補 `}` 前，用 `searchpair` 找配對的 `}`，而且要縮排相同才算「已經有了」，避免誤配到外層的 `}`。

8

## 原始碼與授權

原始碼在 github.com/olilllioli287/codenv（https://github.com/olilllioli287/codenv），採用 MIT 授權：可以自由使用、修改、分享，只要保留原作者的著作權聲明（`LICENSE` 檔）。

### fork 一份改成自己的版本

- 在 GitHub 的 codenv 頁面右上角按 Fork，複製一份到自己的帳號。

- 改自己那份裡的檔案，並把 `get.sh` 開頭的 `repo=olilllioli287/codenv` 改成自己的「帳號/repo 名稱」。

- 之後安裝、更新都改用自己那份的網址：`zsh -c "$(curl -fsSL https://raw.githubusercontent.com/你的帳號/codenv/main/get.sh)"`

只是想調幾個小地方的話，不用 fork，寫在 `.local` 檔就好，見使用手冊的「改成自己的習慣」。

| 檔案 | 內容 |
| --- | --- |
| `get.sh` | 一行安裝的入口 |
| `install.sh` | 安裝 / 更新 |
| `vimrc`、`tmux.conf`、`codenv.zsh` | 三個主要設定檔 |
| `codenv-ime.swift` | 輸入法切換小程式的原始碼 |
| `codenv-board.swift` | 排列視窗的原始碼 |
| `compat/` | Windows 相容：`bits/stdc++.h`、`pause`、`cls` |
| `iterm-profile.json` | iTerm 配色 |
| `docs/` | README 用的示意圖與它的原始檔 |

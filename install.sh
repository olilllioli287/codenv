#!/bin/zsh
# codenv 安裝 / 更新:複製 vim / tmux 設定,並讓 zsh 認得 codenv 指令
# 原本就有的設定檔會先備份成 檔名.bak-日期時間,不會直接蓋掉
# 已經裝過的話,~/.codenv.zsh 裡自己改過的 CODENV_ROOT、CODENV_AI、CODENV_LAYOUT 會保留
cd "${0:A:h}" || exit 1
stamp=$(date +%Y%m%d-%H%M%S)

for f in vimrc tmux.conf; do
  if [[ -e ~/.$f ]] && cmp -s $f ~/.$f; then
    print "~/.$f 已經是最新版"
    continue
  fi
  if [[ -e ~/.$f ]]; then
    cp ~/.$f ~/.$f.bak-$stamp && print "已備份原本的 ~/.$f → ~/.$f.bak-$stamp"
  fi
  cp $f ~/.$f && print "已安裝 ~/.$f"
done

# 中文輸入法開著時 Ctrl+A 也能用:編譯切換輸入法的小程式 ~/.codenv-ime(要用第 1 步裝的編譯器;原始碼沒變就不重編)
if [[ -x ~/.codenv-ime ]] && cmp -s codenv-ime.swift ~/.codenv-ime.swift; then
  print "~/.codenv-ime 已經是最新版"
elif command -v swiftc >/dev/null && swiftc -O codenv-ime.swift -o ~/.codenv-ime 2>/dev/null; then
  cp codenv-ime.swift ~/.codenv-ime.swift
  print "已安裝 ~/.codenv-ime(中文輸入法開著時,Ctrl+A 也能用)"
else
  print "~/.codenv-ime 沒有裝成(需要第 1 步的編譯器):中文輸入法開著時,Ctrl+A 之後改用連按兩次 Ctrl+A 的選單"
fi

# 用滑鼠排列 tmux 格子的視窗 ~/.codenv-board(Ctrl+A 兩下的選單打開;原始碼沒變就不重編)
if [[ -x ~/.codenv-board ]] && cmp -s codenv-board.swift ~/.codenv-board.swift; then
  print "~/.codenv-board 已經是最新版"
elif command -v swiftc >/dev/null && swiftc -O -swift-version 5 codenv-board.swift -o ~/.codenv-board 2>/dev/null; then
  cp codenv-board.swift ~/.codenv-board.swift
  print "已安裝 ~/.codenv-board(用滑鼠排列格子的視窗)"
  board_new=1
else
  print "~/.codenv-board 沒有裝成(需要第 1 步的編譯器):排列格子改用選單裡的「模塊化排列」"
fi

# 在 iTerm 裡按 Cmd+Ctrl+A 叫出排列視窗(2026-10-15 加;別的 App 在前面時不佔用這個鍵):登入時在背景啟動 ~/.codenv-board --daemon
# 不要的話執行這兩行就會關掉、以後也不會再啟動:
#   launchctl bootout gui/$UID/io.github.olilllioli287.codenv-board
#   rm ~/Library/LaunchAgents/io.github.olilllioli287.codenv-board.plist
# (用假的 HOME 測試安裝時不會設定,免得動到真正的登入項目)
agent=io.github.olilllioli287.codenv-board
plist=~/Library/LaunchAgents/$agent.plist
if [[ -x ~/.codenv-board ]] && [[ $HOME == "$(dscl . -read /Users/$(id -un) NFSHomeDirectory 2>/dev/null | awk '{print $2}')" ]]; then
  want="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
  <key>Label</key><string>$agent</string>
  <key>ProgramArguments</key><array><string>$HOME/.codenv-board</string><string>--daemon</string></array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><dict><key>SuccessfulExit</key><false/></dict>
  <key>ProcessType</key><string>Interactive</string>
</dict>
</plist>"
  if [[ -z $board_new && -e $plist && "$(<$plist)" == "$want" ]] && launchctl print gui/$UID/$agent >/dev/null 2>&1; then
    print "Cmd+Ctrl+A(叫出排列視窗)已經設定好了"
  else
    mkdir -p ~/Library/LaunchAgents
    print -r -- "$want" > $plist
    launchctl bootout gui/$UID/$agent 2>/dev/null
    if launchctl bootstrap gui/$UID $plist; then
      print "已設定 Cmd+Ctrl+A:在 iTerm 裡按一下叫出排列視窗,再按一下收起來(登入時自動在背景啟動)"
    else
      print "Cmd+Ctrl+A 沒有設定成功:排列視窗還是可以從 Ctrl+A 兩下的選單打開"
    fi
  fi
fi

# Windows 寫的程式在 Mac 上也能跑:bits/stdc++.h、conio.h、system("pause")、system("cls") 等(F9 / F10 會用到)
if diff -rq compat ~/.codenv-compat >/dev/null 2>&1; then
  print "~/.codenv-compat 已經是最新版"
else
  # 整個資料夾換成新版(先複製到旁邊再換掉),新版刪掉或改名的檔案才不會留在舊的裡面
  rm -rf ~/.codenv-compat.new && cp -R compat ~/.codenv-compat.new && rm -rf ~/.codenv-compat && mv ~/.codenv-compat.new ~/.codenv-compat && print "已安裝 ~/.codenv-compat(Windows 寫的程式也能跑,例如 bits/stdc++.h、system(\"pause\"))"
fi

# codenv 指令:新版覆蓋前,先記下自己設定過的資料夾位置、AI 指令和畫面格數,裝好後填回去
keep=()
if [[ -e ~/.codenv.zsh ]]; then
  keep=( ${(f)"$(grep -E '^CODENV_(ROOT|AI|LAYOUT)=' ~/.codenv.zsh)"} )
fi
new=()
while IFS= read -r line || [[ -n $line ]]; do
  for k in $keep; do
    [[ $line == ${k%%=*}=* ]] && line=$k
  done
  new+=("$line")
done < codenv.zsh
if [[ -e ~/.codenv.zsh ]] && [[ "$(print -rl -- "${new[@]}")" == "$(<~/.codenv.zsh)" ]]; then
  print "~/.codenv.zsh 已經是最新版"
else
  [[ -e ~/.codenv.zsh ]] && cp ~/.codenv.zsh ~/.codenv.zsh.bak-$stamp && print "已備份原本的 ~/.codenv.zsh → ~/.codenv.zsh.bak-$stamp(你設定的資料夾、AI 指令和畫面格數會保留)"
  print -rl -- "${new[@]}" > ~/.codenv.zsh && print "已安裝 ~/.codenv.zsh"
fi
if ! grep -q 'source ~/.codenv.zsh' ~/.zshrc 2>/dev/null; then
  print '\n# codenv 程式練習環境\nsource ~/.codenv.zsh' >> ~/.zshrc
  print "已在 ~/.zshrc 加上 source ~/.codenv.zsh"
fi

# tmux 正在執行的話,直接載入新設定
if tmux info >/dev/null 2>&1; then
  tmux source-file ~/.tmux.conf && print "tmux 已載入新設定"
fi

print ""
command -v tmux >/dev/null || print "還缺 tmux:請執行 brew install tmux"
command -v g++  >/dev/null || print "還缺編譯器:請執行 xcode-select --install"
print "完成。關掉 iTerm(⌘Q)重開,輸入 codenv 就能使用;已經開著的 vim 要關掉再打開才會用到新設定。"

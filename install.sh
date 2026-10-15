#!/bin/zsh
# codenv 安裝 / 更新:複製 vim / tmux 設定,並讓 zsh 認得 codenv 指令
# 原本就有的設定檔會先備份成 檔名.bak-日期時間,不會直接蓋掉
# 已經裝過的話,~/.codenv.zsh 裡自己改過的 CODENV_ROOT、CODENV_AI、CODENV_LAYOUT、CODENV_TMUXKIT、CODENV_WELCOME 會保留
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
  print "~/.codenv-ime 沒有裝成(需要第 1 步的編譯器):中文輸入法開著時,按 Ctrl+A 之前先切成英文"
fi

# 排列視窗(Cmd+Ctrl+A)和 Ctrl+A 兩下的中文選單,2026-10-15 搬到 tmux-kit(選用安裝)
# 舊版 codenv 裝過排列視窗的話:關掉它,檔案移到 ~/codenv-removed(不刪,想恢復可以搬回來)
old_agent=io.github.olilllioli287.codenv-board
if [[ -e ~/Library/LaunchAgents/$old_agent.plist || -e ~/.codenv-board ]]; then
  mkdir -p ~/codenv-removed
  if [[ -e ~/Library/LaunchAgents/$old_agent.plist ]]; then
    launchctl bootout gui/$UID/$old_agent 2>/dev/null
    mv ~/Library/LaunchAgents/$old_agent.plist ~/codenv-removed/
  fi
  for f in ~/.codenv-board ~/.codenv-board.swift; do [[ -e $f ]] && mv $f ~/codenv-removed/; done
  print "排列視窗和中文選單搬到 tmux-kit 了(選用),舊版已經關掉、移到 ~/codenv-removed。想繼續用,請安裝 tmux-kit:"
  print '  zsh -c "$(curl -fsSL https://raw.githubusercontent.com/olilllioli287/tmux-kit/main/get.sh)"'
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
  keep=( ${(f)"$(grep -E '^CODENV_(ROOT|AI|LAYOUT|TMUXKIT|WELCOME)=' ~/.codenv.zsh)"} )
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
# 在內建的「終端機」裝的話,get.sh 接著會打開 iTerm,不用叫人重開
if [[ $TERM_PROGRAM == Apple_Terminal ]]; then
  print "完成。"
else
  print "完成。關掉 iTerm(Cmd+Q)重開,輸入 codenv 就能使用;已經開著的 vim 要關掉再打開才會用到新設定。"
fi

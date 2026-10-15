#!/bin/zsh
# codenv 解除安裝(2026-10-16 加):檔案不直接刪,全部移到 ~/codenv-removed-日期時間,想恢復可以搬回來
#   會移走:~/.codenv.zsh、~/.codenv-ime、~/.codenv-compat、~/.codenv-kit,以及 codenv 裝的 ~/.vimrc、~/.tmux.conf
#   會恢復:裝 codenv 之前原本的 ~/.vimrc、~/.tmux.conf(安裝時備份成 .bak-日期時間 的那份)
#   不會動:你寫的程式(程式資料夾整個留著),Homebrew、編譯器、tmux、iTerm2(別的程式可能也在用)
# 用法: zsh -c "$(curl -fsSL https://raw.githubusercontent.com/olilllioli287/codenv/main/uninstall.sh)"
stamp=$(date +%Y%m%d-%H%M%S)
out=~/codenv-removed-$stamp

if [[ ! -e ~/.codenv.zsh && ! -e ~/.codenv-kit && ! -e ~/.codenv-compat ]] && ! grep -qs 'source ~/.codenv.zsh' ~/.zshrc; then
  print "這台電腦沒有裝 codenv,不用解除安裝。"
  exit 0
fi

# 程式資料夾在哪裡,最後告訴使用者(不會動它)
root=""
[[ -f ~/.codenv.zsh ]] && root=$(zsh -c 'source ~/.codenv.zsh >/dev/null 2>&1; print -r -- $CODENV_ROOT')

mkdir -p $out
print "解除安裝 codenv:檔案會移到 ${out/#$HOME/~},不會直接刪掉"
print ""

# 1. ~/.zshrc 裡安裝時加的兩行(說明 + source ~/.codenv.zsh)
if grep -qs 'source ~/.codenv.zsh' ~/.zshrc; then
  cp ~/.zshrc $out/zshrc.bak
  grep -v -e '^# codenv 程式練習環境$' -e '^source ~/.codenv.zsh$' $out/zshrc.bak > ~/.zshrc
  print "已從 ~/.zshrc 拿掉載入 codenv 的那行(原本的檔案在 zshrc.bak)"
fi

# 2. codenv 自己的檔案
for f in ~/.codenv.zsh ~/.codenv-ime ~/.codenv-ime.swift ~/.codenv-compat ~/.codenv-kit; do
  [[ -e $f ]] && mv $f $out/ && print "已移走 ${f/#$HOME/~}"
done

# 3. 舊版 codenv 的排列視窗(2026-10-15 前的版本才有)
old_agent=io.github.olilllioli287.codenv-board
if [[ -e ~/Library/LaunchAgents/$old_agent.plist ]]; then
  launchctl bootout gui/$UID/$old_agent 2>/dev/null
  mv ~/Library/LaunchAgents/$old_agent.plist $out/ && print "已關掉舊版的排列視窗"
fi
for f in ~/.codenv-board ~/.codenv-board.swift; do [[ -e $f ]] && mv $f $out/; done

# 4. ~/.vimrc、~/.tmux.conf:是 codenv 裝的才移走;有裝 codenv 之前的備份就放回去
for name in vimrc tmux.conf; do
  f=~/.$name
  if [[ -f $f ]] && grep -qs codenv $f; then
    mv $f $out/$name && print "已移走 codenv 的 ~/.$name"
    # 最新的、不是 codenv 版本的備份,就是裝 codenv 之前原本的設定
    orig=""
    for b in ${(On)~:-~/.$name.bak-*(N)}; do
      grep -qs codenv $b || { orig=$b; break }
    done
    if [[ -n $orig ]]; then
      cp $orig $f && print "  已放回裝 codenv 之前的 ~/.$name(${orig:t})"
    fi
  fi
done

# 5. 正在跑的 tmux 重新載入設定(沒有 ~/.tmux.conf 的話,要等 tmux 重開才會恢復原狀)
if tmux info >/dev/null 2>&1; then
  if [[ -f ~/.tmux.conf ]]; then
    tmux source-file ~/.tmux.conf 2>/dev/null
  fi
fi

print ""
print "完成。關掉 iTerm(Cmd+Q)重開,codenv 指令就不見了。"
[[ -n $root ]] && print "你寫的程式還在 ${root/#$HOME/~},沒有動。"
[[ -d ~/.tmux-kit ]] && print "另外裝的 tmux-kit 沒有動;也要拿掉的話,執行 zsh ~/.tmux-kit/uninstall.sh"
print "Homebrew、編譯器、tmux、iTerm2 都留著(別的程式可能也在用)。"
print "想恢復 codenv:再執行一次安裝的那一行就好。確定不要了,可以自己刪掉 ${out/#$HOME/~}。"

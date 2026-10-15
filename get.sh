#!/bin/zsh
# codenv 一行安裝 / 更新:缺什麼就裝什麼,已經裝好的會跳過,所以更新時也是執行同一行(2026-10-15 改成全部自動裝)
#   1. Homebrew(沒有編譯器 Command Line Tools 的話,Homebrew 的安裝程式會順便裝)
#   2. 編譯器(Homebrew 已經有、編譯器卻不見的少見情況才在這裡裝)
#   3. tmux   4. iTerm2   5. codenv 的設定(下載到 ~/.codenv-kit,再執行裡面的 install.sh)
# 用法: zsh -c "$(curl -fsSL https://raw.githubusercontent.com/olilllioli287/codenv/main/get.sh)"
# 在 Mac 內建的「終端機」或 iTerm 裡執行都可以
# 自己 fork 一份來改的話,把下面這行改成自己的「帳號/repo 名稱」
repo=olilllioli287/codenv
kit=~/.codenv-kit

# 測試用:CODENV_DRYRUN=1 只印出要做的事;CODENV_PRETEND_MISSING="brew clt tmux iterm" 假裝這些還沒裝
run() { if [[ -n $CODENV_DRYRUN ]]; then print "  (測試,沒有真的執行) $*"; else "$@"; fi }
pretend() { [[ " $CODENV_PRETEND_MISSING " == *" $1 "* ]] }

find_brew() {
  pretend brew && return 1
  local b
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do [[ -x $b ]] && { print $b; return 0 }; done
  return 1
}
have_clt() {
  pretend clt && return 1
  # 先確定有開發工具的資料夾,xcrun 才不會跳出安裝視窗
  xcode-select -p >/dev/null 2>&1 && /usr/bin/xcrun --find clang >/dev/null 2>&1
}
have_tmux() { ! pretend tmux && command -v tmux >/dev/null }
have_iterm() { ! pretend iterm && [[ -d /Applications/iTerm.app || -d ~/Applications/iTerm.app ]] }

fail() {
  print ""
  print "  $1"
  print "  可以照網站「新手上路」的手動步驟補裝,再執行一次這行,就會從沒裝好的地方接著做:"
  print "  https://olilllioli287.github.io/codenv/#start"
  exit 1
}

brew_bin=$(find_brew)
need=()
[[ -z $brew_bin ]] && need+=("Homebrew")
have_clt || need+=("編譯器")
have_tmux || need+=("tmux")
have_iterm || need+=("iTerm2")

print ""
print "codenv 安裝:缺什麼就裝什麼,已經有的會跳過"
if (( $#need )); then
  print "  這次要裝:${(j:、:)need},最後再裝 codenv 的設定"
  [[ -z $brew_bin ]] && print "  第一次安裝大約 15～40 分鐘,大部分時間在下載;電腦請接上電源、連上穩定的 Wi-Fi"
else
  print "  Homebrew、編譯器、tmux、iTerm2 都已經裝好了,直接更新 codenv 的設定"
fi

# 要裝 Homebrew 或編譯器時需要管理員密碼:先問一次,安裝過程中保持有效,不用一直輸入
if [[ -z $brew_bin ]] || ! have_clt; then
  print ""
  print "  接下來會出現 Password:,請輸入開機密碼後按 Enter"
  print "  (打字時畫面不會出現任何字,這是正常的,打完直接按 Enter)"
  run sudo -v || fail "密碼不對,或這個帳號不是電腦的管理員,沒辦法安裝 Homebrew。"
  if [[ -z $CODENV_DRYRUN ]]; then
    # 每 50 秒延長一次密碼的有效時間,這行指令結束就停
    ( while kill -0 $$ 2>/dev/null; do sudo -n true 2>/dev/null; sleep 50; done ) &!
  fi
fi

# ===== 1. Homebrew =====
if [[ -z $brew_bin ]]; then
  print ""
  print "[1/5] 安裝 Homebrew(用一行指令安裝軟體的工具;沒有編譯器的話會順便裝)…"
  hb=$(mktemp)
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o $hb || fail "下載 Homebrew 失敗,請確認網路連線後再試一次。"
  run env NONINTERACTIVE=1 /bin/bash $hb || fail "Homebrew 沒有裝成。"
  rm -f $hb
  if [[ -n $CODENV_DRYRUN ]]; then brew_bin=/opt/homebrew/bin/brew
  else brew_bin=$(find_brew) || fail "Homebrew 沒有裝成。"
  fi
else
  print "[1/5] Homebrew 已經裝好了"
fi
# 讓這次和以後打開的終端機都找得到 brew(就是 Homebrew 裝完叫你自己貼的那幾行)
if [[ -z $CODENV_DRYRUN ]]; then
  eval "$($brew_bin shellenv)"
  if ! grep -qs 'brew shellenv' ~/.zprofile; then
    print "\n# Homebrew(codenv 安裝時加的)\neval \"\$($brew_bin shellenv)\"" >> ~/.zprofile
    print "  已在 ~/.zprofile 加上 Homebrew 的路徑"
  fi
fi

# ===== 2. 編譯器 =====
if have_clt; then
  print "[2/5] 編譯器已經裝好了"
else
  print ""
  print "[2/5] 安裝編譯器(Command Line Tools,大約 10～30 分鐘)…"
  # 跟 Homebrew 一樣的做法:用 softwareupdate 在背景裝,不用按視窗
  placeholder=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  touch $placeholder
  label=$(softwareupdate -l 2>/dev/null | grep -B 1 -E 'Command Line Tools' | awk -F'*' '/^ *\*/ {print $2}' | sed -e 's/^ *Label: //' -e 's/^ *//' | sort -V | tail -n 1)
  [[ -n $label ]] && run sudo softwareupdate -i "$label"
  rm -f $placeholder
  if [[ -z $CODENV_DRYRUN ]] && ! have_clt; then
    # 背景裝不成時,改用系統的安裝視窗
    xcode-select --install 2>/dev/null
    print "  畫面上會跳出安裝視窗:按「安裝」→「同意」,等到出現「已安裝軟體」按「完成」"
    read "?  裝好之後回到這裡按 Enter 繼續 "
    have_clt || fail "編譯器沒有裝成。"
  fi
fi

# ===== 3. tmux =====
if have_tmux; then
  print "[3/5] tmux 已經裝好了"
else
  print ""
  print "[3/5] 安裝 tmux(把視窗切成好幾格的工具)…"
  run $brew_bin install tmux || fail "tmux 沒有裝成。"
fi

# ===== 4. iTerm2 =====
if have_iterm; then
  print "[4/5] iTerm2 已經裝好了"
else
  print ""
  print "[4/5] 安裝 iTerm2(codenv 的按鍵是照它設計的終端機)…"
  run $brew_bin install --cask iterm2 || fail "iTerm2 沒有裝成。"
fi

# ===== 5. codenv 的設定 =====
print ""
print "[5/5] 下載 codenv 最新版…"
tmp=$(mktemp -d) || exit 1
if ! curl -fsSL https://github.com/$repo/archive/refs/heads/main.tar.gz | tar -xz -C $tmp; then
  rm -rf $tmp
  fail "下載失敗,請確認網路連線後再試一次。"
fi
rm -rf $kit && mv $tmp/*-main $kit && rm -rf $tmp
zsh $kit/install.sh

# 在內建的「終端機」裝的話,幫忙打開 iTerm,之後都用 iTerm
if [[ $TERM_PROGRAM == Apple_Terminal ]]; then
  print ""
  print "接下來改用 iTerm:已經幫你打開了(在「應用程式」資料夾裡)。第一次問「確定要打開嗎?」就按「打開」,"
  print "然後在 iTerm 裡輸入 codenv 按 Enter。這個「終端機」視窗可以關掉了。"
  run open -a iTerm
fi

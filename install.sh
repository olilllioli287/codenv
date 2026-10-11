#!/bin/zsh
# codenv 安裝 / 更新:複製 vim / tmux 設定,並讓 zsh 認得 codenv 指令
# 原本就有的設定檔會先備份成 檔名.bak-日期時間,不會直接蓋掉
# 已經裝過的話,~/.codenv.zsh 裡自己改過的 CODENV_ROOT、CODENV_AI 會保留
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

# codenv 指令:新版覆蓋前,先記下自己設定過的資料夾位置和 AI 指令,裝好後填回去
keep=()
if [[ -e ~/.codenv.zsh ]]; then
  keep=( ${(f)"$(grep -E '^CODENV_(ROOT|AI)=' ~/.codenv.zsh)"} )
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
  [[ -e ~/.codenv.zsh ]] && cp ~/.codenv.zsh ~/.codenv.zsh.bak-$stamp && print "已備份原本的 ~/.codenv.zsh → ~/.codenv.zsh.bak-$stamp(你設定的資料夾和 AI 指令會保留)"
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

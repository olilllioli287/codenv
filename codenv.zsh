# ===== codenv:程式練習環境(vim 寫程式 + F10 執行結果,可選兩格或三格) =====
# 用法:在任何地方輸入 codenv,用數字選資料夾和檔案
#       codenv layout      重新選畫面要兩格還是三格(也可以直接打 codenv layout 2 或 3)
CODENV_ROOT=~/programming_language
# 三格時左半邊要自動執行的 AI 指令(例如 claude);留空就是普通的終端機
CODENV_AI=''
# 畫面:2 = 左邊寫程式、右邊看結果;3 = 左邊 AI 或終端機、右上寫程式、右下看結果
# 留空的話,第一次輸入 codenv 時會問,選完記在這裡
CODENV_LAYOUT=''

# 選畫面要幾格,並記到 ~/.codenv.zsh,下次開 codenv 就照這個排
_codenv_choose_layout() {
  local n=$1
  while [[ $n != [23] ]]; do
    print ""
    print "  要用哪一種畫面?"
    print ""
    print "   2) 兩格:左邊寫程式、右邊看執行結果(沒有用 AI 的話選這個)"
    print "   3) 三格:左邊放 AI 或終端機,右上寫程式、右下看執行結果"
    print ""
    print "   q) 取消"
    print ""
    n=""; read "n?  > " || return 1
    [[ $n == [qQ] ]] && { print "  已取消"; return 1 }
    [[ $n == [23] ]] || print "  請輸入 2 或 3"
  done
  CODENV_LAYOUT=$n
  local conf=~/.codenv.zsh
  if [[ -f $conf ]]; then
    if grep -q '^CODENV_LAYOUT=' $conf; then
      sed -i '' "s/^CODENV_LAYOUT=.*/CODENV_LAYOUT=$n/" $conf
    else
      print "CODENV_LAYOUT=$n" >> $conf
    fi
  fi
  print "  已設定成$( (( n == 2 )) && print 兩格 || print 三格)。之後想換,輸入 codenv layout"
}

codenv() {
  if [[ $1 == layout ]]; then
    _codenv_choose_layout $2
    return
  fi
  local root=$CODENV_ROOT dir file choice name ans i
  local -a dirs files
  # 還沒裝 tmux 就先說要怎麼裝,不然選完檔案才會跳出看不懂的 command not found
  if (( ! $+commands[tmux] )); then
    print "  還沒裝 tmux:先執行 brew install tmux(安裝步驟第 3 步),裝好再輸入 codenv"
    return 1
  fi
  # 第一次使用:先問畫面要幾格
  if [[ $CODENV_LAYOUT != [23] ]]; then
    print "\n  第一次使用 codenv,先選畫面的排法。"
    _codenv_choose_layout || return
  fi
  [[ -d $root ]] || mkdir -p -- $root
  # 1) 選資料夾
  while true; do
    dirs=( $root/*(N/:t) )
    print ""
    print "  選擇要進入的資料夾   ${root/#$HOME/~}"
    print ""
    for ((i = 1; i <= $#dirs; i++)); do printf "   %d) %s\n" $i "${dirs[i]}"; done
    print ""
    print "   n) 新增資料夾      q) 取消"
    print ""
    choice=""; read "choice?  > "
    case $choice in
      (q|Q|"") print "  已取消"; return ;;
      (n|N) name=""; read "name?  新資料夾名稱: "
            [[ -z $name ]] && continue
            if [[ $name == *.* ]]; then
              print "  「$name」看起來像檔名。這一步是建「資料夾」,檔案要進資料夾後再按 n 建立"
              ans=""; read "ans?  還是要建成資料夾嗎?(y/n) "
              [[ $ans == [yY]* ]] || continue
            fi
            mkdir -p -- "$root/$name" && print "  已建立資料夾 $name" ;;
      (<->) if (( choice >= 1 && choice <= $#dirs )); then dir="$root/${dirs[choice]}"; break; fi
            print "  沒有第 $choice 個資料夾" ;;
      (*)   print "  請輸入資料夾前面的數字,或 n、q" ;;
    esac
  done
  # 2) 選檔案(只列出有副檔名的檔案,編譯出來的執行檔不會出現)
  while true; do
    files=( "$dir"/*.*(N.:t) )
    print ""
    print "  ${dir:t} 裡的檔案"
    print ""
    for ((i = 1; i <= $#files; i++)); do printf "   %d) %s\n" $i "${files[i]}"; done
    (( $#files )) || print "   (還沒有檔案)"
    print ""
    print "   n) 新檔案      Enter) 先不開檔案      q) 取消"
    print ""
    choice=""; read "choice?  > "
    case $choice in
      (q|Q) print "  已取消"; return ;;
      ("") file=""; break ;;
      (n|N) name=""; read "name?  新檔名(例如 hw1.py、hw1.cpp): "
            [[ -z $name ]] && continue
            # 沒有副檔名的話 F9、F10 不知道是 C++ 還是 Python,選單也不會列出它
            if [[ $name != *.* ]]; then
              print "  檔名要有副檔名,例如 $name.cpp 或 $name.py"
              continue
            fi
            file=$name; break ;;
      (<->) if (( choice >= 1 && choice <= $#files )); then file="${files[choice]}"; break; fi
            print "  沒有第 $choice 個檔案" ;;
      # 直接打完整檔名(例如 hello.cpp)也可以,沒有的話會新建;沒有副檔名的多半是打錯字,不要建出空檔案
      (*.*) file=$choice; break ;;
      (*)   print "  請輸入檔案前面的數字、n、q,或完整的檔名(例如 hello.cpp)" ;;
    esac
  done
  # 新檔名先建立空檔案,不用等 vim 存檔才出現(已經有的檔案不會被清空)
  [[ -n $file && ! -e $dir/$file ]] && : >> "$dir/$file"
  _codenv_layout "$dir" "$file"
}

# 排版面:新開一個 tmux 視窗(不在 tmux 裡就開新的 session)
# 兩格:左 vim、右執行結果;三格:左 AI 或終端機、右上 vim、右下執行結果
_codenv_layout() {
  local dir=$1 file=$2 left top
  if [[ -n $TMUX ]]; then
    left=$(tmux new-window -P -F '#{pane_id}' -c "$dir" -n "${dir:t}") || return
  else
    left=$(tmux new-session -d -P -F '#{pane_id}' -c "$dir" -n "${dir:t}") || return
  fi
  if [[ $CODENV_LAYOUT == 2 ]]; then
    top=$left
    tmux split-window -h -d -l 40% -t "$left" -c "$dir"
  else
    top=$(tmux split-window -h -P -F '#{pane_id}' -t "$left" -c "$dir")
    tmux split-window -v -d -t "$top" -c "$dir"
    [[ -n $CODENV_AI ]] && tmux send-keys -t "$left" "$CODENV_AI" Enter
  fi
  # 記下這個視窗是幾格,執行結果那格被關掉時 vim 才知道要在哪裡重開
  tmux set -w -t "$left" @codenv_layout "${CODENV_LAYOUT:-3}"
  if [[ -n $file ]]; then
    tmux send-keys -t "$top" "vim ${(q)file}" Enter
  else
    tmux send-keys -t "$top" 'vim' Enter
  fi
  tmux select-pane -t "$top"
  [[ -z $TMUX ]] && tmux attach -t "$top"
}

# Home / End(Cmd+←/→)跳到行首 / 行尾(不在 tmux 裡時用)
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Ctrl+Home / Ctrl+End(Cmd+↑/↓)跳到整段輸入的最前面 / 最後面
_buffer-start() { CURSOR=0 }
_buffer-end() { CURSOR=${#BUFFER} }
zle -N _buffer-start; zle -N _buffer-end
bindkey '^[[1;5H' _buffer-start
bindkey '^[[1;5F' _buffer-end

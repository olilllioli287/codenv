" ===== 基本設定 =====
syntax on            " 語法上色
set number           " 顯示行號
set autoindent       " 自動縮排
set tabstop=4 shiftwidth=4 noexpandtab   " Tab 鍵插入真正的 Tab 字元

" 游標形狀:輸入模式是直槓,一般模式是方塊,取代模式是底線
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
let &t_SR = "\e[4 q"
autocmd VimLeave * silent !printf '\e[0 q'

" ===== F9 存檔+檢查,F10 存檔+執行(C++ 先編譯;Python 直接用 python3 跑) =====
" 在 tmux 裡:結果都顯示在右下角的 pane(沒有就自動開一個),最後一行用顏色標出結果
"   F9 :只檢查有沒有錯、不執行,游標留在 vim
"   F10:編譯有錯就跟 F9 一樣只顯示錯誤、游標留在 vim;沒錯就執行,焦點跳過去(在那格按 Esc 回到 vim)
" 不在 tmux 裡:直接在 vim 下方顯示結果
let s:red = "\e[1;31m"
let s:yellow = "\e[1;33m"
let s:green = "\e[1;32m"
let s:dim = "\e[2m"
let s:reset = "\e[0m"

" Windows(Dev-C++ 等)寫的程式在 Mac 上也能跑(2026-10-12 加,install.sh 會裝到 ~/.codenv-compat):
"   include/bits/stdc++.h  讓 #include <bits/stdc++.h> 能編譯
"   bin/pause、bin/cls     讓 system("pause")、system("cls") 跟 Windows 一樣
"   include/codenv-unbuffered.h  輸出不等換行就馬上顯示(跟 Windows 一樣,程式當掉前印的字也看得到)
let s:compat = expand('~/.codenv-compat')
let s:compat_inc = isdirectory(s:compat . '/include') ? ' -I ' . shellescape(s:compat . '/include') . ' -include codenv-unbuffered.h' : ''
let s:compat_path = 'PYTHONUNBUFFERED=1 ' . (isdirectory(s:compat . '/bin') ? 'PATH=' . shellescape(s:compat . '/bin') . ':"$PATH" ' : '')

" 檢查程式有沒有錯(compile 為 1 時順便產生執行檔),回傳 [有沒有錯, 錯誤訊息]
" 在檔案所在的資料夾執行,錯誤訊息只會顯示檔名,不會是一長串路徑
" 錯在哪裡會在 vim 裡畫底線(錯誤紅色、警告黃色),見下面的 s:Mark
function! s:Compile(compile)
  let cd = 'cd ' . shellescape(expand('%:p:h')) . ' && '
  let src = shellescape(expand('%:t'))
  if &filetype ==# 'python'
    " .pyc 放到 vim 的暫存資料夾,作業資料夾不會多出 __pycache__
    let msg = system(cd . 'PYTHONPYCACHEPREFIX=' . shellescape(fnamemodify(tempname(), ':h')) . ' python3 -m py_compile ' . src . ' 2>&1')
    let err = v:shell_error
    let line = matchstr(msg, 'File "[^"]*", line \zs\d\+')
    call s:Mark(empty(line) ? [] : [[str2nr(line), 0, 1]])
    return [err, msg]
  endif
  let color = empty($TMUX) ? '' : ' -fcolor-diagnostics'
  " 執行檔放到旁邊的 bin 資料夾,跟程式碼分開(2026-10-11 改;沒有 bin 會自動建)
  let output = a:compile ? ' -o ' . shellescape('bin/' . expand('%:t:r')) : ' -fsyntax-only'
  let mkbin = a:compile ? 'mkdir -p bin && ' : ''
  let msg = system(cd . mkbin . 'g++ -std=c++17 -Wall' . s:compat_inc . color . ' ' . src . output . ' 2>&1')
  let err = v:shell_error
  return [err, s:OnlyMyFile(msg, err) . s:WindowsOnly(msg)]
endfunction

" 編譯器的訊息裡只留下跟自己檔案有關的部分
" 編譯器常會附上一大串系統檔案(/Applications/Xcode.app/...)的 note,對找錯沒有幫助,全部拿掉
function! s:OnlyMyFile(msg, err)
  let file = expand('%:t')
  let keep = 1
  let lines = []
  let marks = []
  for line in split(a:msg, "\n")
    let plain = substitute(line, "\e\\[[0-9;]*m", '', 'g')
    " 每一則訊息的第一行長這樣: 檔名:行:字: error: 說明
    let m = matchlist(plain, '^\(.\{-}\):\(\d\+\):\(\d\+\): \(fatal error\|error\|warning\|note\):')
    if !empty(m)
      let keep = m[1] ==# file
      if keep && m[4] !=# 'note'
        call add(marks, [str2nr(m[2]), str2nr(m[3]), m[4] =~# 'error'])
      endif
      " 開頭的「檔名:行:字:」改成「第 幾 行:」(2026-10-11 加);哪個字由下面的 ^ 標出來
      if keep
        let line = substitute(line, '\V' . escape(file, '\') . ':' . m[2] . ':' . m[3] . ': ', '第 ' . m[2] . ' 行: ', '')
      endif
    elseif plain =~# '^In file included from'
      let keep = 0
    elseif plain =~# '^\d\+ \(error\|warning\)s\= .*generated\.$'
      let keep = 1
    endif
    if keep
      call add(lines, line)
    endif
  endfor
  " 萬一錯誤全都出在系統檔案裡(自己的檔案一個都沒留下),就整份照原樣顯示,免得什麼都看不到
  if a:err && empty(filter(copy(marks), 'v:val[2]'))
    call s:Mark([])
    return a:msg
  endif
  call s:Mark(marks)
  return join(lines, "\n")
endfunction

" 用到 Windows 才有的檔案(Mac 上沒有)時,多一行中文說明要怎麼改
function! s:WindowsOnly(msg)
  let hints = {
        \ 'conio.h': 'conio.h 是 Windows 才有的。getch() 可以改成 cin.get()(要按 Enter);清畫面用 system("cls")',
        \ 'windows.h': 'windows.h 是 Windows 才有的。Sleep(毫秒) 可以改成 this_thread::sleep_for(chrono::milliseconds(毫秒)),要 #include <thread>',
        \ }
  let out = ''
  for [name, hint] in items(hints)
    if a:msg =~# "'" . escape(name, '.') . "' file not found"
      let out .= "\n" . s:yellow . '→ ' . hint . s:reset
    endif
  endfor
  return out
endfunction

" 在 vim 裡把出錯的地方畫底線:marks 是 [[行, 字, 是不是錯誤], ...]
" 字是 0 或那個位置沒有字(例如少分號時指在行尾)就整行畫線;每次 F9/F10 會先清掉上次的
highlight CodeError ctermfg=red cterm=underline,bold guifg=red gui=underline,bold
highlight CodeWarning ctermfg=yellow cterm=underline guifg=orange gui=underline
let s:first_error = 0
function! s:Mark(marks)
  for id in get(w:, 'code_marks', [])
    silent! call matchdelete(id)
  endfor
  let w:code_marks = []
  let s:first_error = 0
  for [lnum, col, iserr] in a:marks
    let rest = col > 0 ? strpart(getline(lnum), col - 1) : ''
    " 底線畫在那個位置的「一個字」:名字、數字、或一串運算符號(例如 <<)
    let word = matchstr(rest, '^\(\h\w*\|\d\+\%(\.\d\+\)\=\|[-<>=!+*/%&|^~]\+\|\S\)')
    let pos = empty(word) ? [lnum] : [lnum, col, strlen(word)]
    call add(w:code_marks, matchaddpos(iserr ? 'CodeError' : 'CodeWarning', [pos], iserr ? 20 : 10))
    if iserr && !s:first_error
      let s:first_error = lnum
    endif
  endfor
endfunction

" 訊息會不會超出右下角 pane 的高度(超出的話要往上捲才看得到開頭)
function! s:Overflows(lines)
  let [width, height] = split(system("tmux display -p -t '{bottom-right}' '#{pane_width} #{pane_height}'"))
  let rows = 0
  for line in a:lines
    let rows += 1 + (strdisplaywidth(substitute(line, "\e\\[[0-9;]*m", '', 'g')) - 1) / width
  endfor
  return rows + 2 > height
endfunction

" 把檢查結果整理成要顯示的幾行:錯誤訊息,最後一行用顏色標出結果
function! s:Report(err, msg)
  let lines = split(a:msg, "\n")
  if a:err
    let hint = !empty($TMUX) && s:Overflows(lines) ? s:dim . '  (訊息較長,用滑鼠滾輪往上捲看開頭)' . s:reset : ''
    return lines + [s:red . '✗ code is error' . s:reset . hint]
  elseif !empty(lines)
    return lines + [s:yellow . '⚠ code has warnings(可以執行,但建議看一下)' . s:reset]
  endif
  return [s:green . '✓ code is ok' . s:reset]
endfunction

" 在 vim 下方用一行字告訴結果
function! s:EchoStatus(err, msg)
  let where = empty($TMUX) ? '' : ',詳細看右下角'
  if a:err
    let at = s:first_error ? ',第 ' . s:first_error . ' 行(紅色底線)' : ''
    echohl ErrorMsg | echo 'code is error' . at . where | echohl None
  elseif !empty(a:msg)
    echohl WarningMsg | echo 'code has warnings' . where | echohl None
  else
    echo '已存檔,code is ok'
  endif
endfunction

" 重開右下角的 pane:先印出 lines,再執行 after(可以是空的),結束後回到 shell
" focus 為 1 時把焦點移過去
function! s:ShowInPane(lines, after, focus)
  let target = trim(system("tmux display -p -t '{bottom-right}' '#{pane_id}'"))
  if target ==# $TMUX_PANE
    " 執行結果那格不見了(例如被關掉)就重開一格,排法跟 codenv 一樣:兩格模式開在右邊,其他開在 vim 下面
    let side = trim(system('tmux show -wv @codenv_layout')) ==# '2' ? '-h' : '-v'
    let target = trim(system('tmux split-window ' . side . ' -d -l 40% -P -F "#{pane_id}"'))
  endif
  " trap:按 Ctrl+C 只停掉程式,外面這層 shell 留著,這格才不會跟著消失
  let cmd = 'trap : INT; '
  if !empty(a:lines)
    " 要印的內容先寫進暫存檔再 cat,顏色才會保留
    let tmp = tempname()
    call writefile(a:lines, tmp)
    let cmd .= 'cat ' . shellescape(tmp) . '; rm -f ' . shellescape(tmp) . '; '
  endif
  if !empty(a:after)
    let cmd .= a:after . '; '
  endif
  let cmd .= 'exec ' . shellescape($SHELL)
  " 先清掉上一次留下的捲動紀錄,往上捲時只會看到這一次的訊息
  call system('tmux clear-history -t ' . target . ' \; respawn-pane -k -t ' . target . ' -c ' . shellescape(expand('%:p:h')) . ' ' . shellescape(cmd))
  " 標記這格並記住 vim 在哪(在那格按 Esc 會跳回 vim,見 ~/.tmux.conf)
  call system('tmux set -p -t ' . target . ' @cppvim ' . $TMUX_PANE . ' \; set -p -t ' . target . ' @cpprun 1' . (a:focus ? ' \; select-pane -t ' . target : ''))
  redraw!
endfunction

" 還沒有檔名(例如 codenv 選「先不開檔案」)就沒辦法存檔,先提醒怎麼取名;then 是提示最後要接的話
function! s:NeedName(then)
  if !empty(expand('%'))
    return 0
  endif
  echohl WarningMsg | echo '還沒有檔名:先輸入 :w 檔名 存檔(例如 :w hw1.cpp 或 :w hw1.py)' . a:then | echohl None
  return 1
endfunction

function! CheckCode()
  if s:NeedName(',再按 F9 / F10') | return | endif
  write
  if &filetype !=# 'cpp' && &filetype !=# 'python'
    echo 'F9 檢查只支援 .cpp 和 .py 檔(已存檔)'
    return
  endif
  let [err, msg] = s:Compile(0)
  if empty($TMUX)
    echo msg
  else
    call s:ShowInPane(s:Report(err, msg), '', 0)
  endif
  call s:EchoStatus(err, msg)
endfunction

function! RunCode()
  if s:NeedName(',再按 F9 / F10') | return | endif
  write
  if &filetype !=# 'cpp' && &filetype !=# 'python'
    echo 'F10 只支援 .cpp 和 .py 檔'
    return
  endif
  let out = expand('%:p:h') . '/bin/' . expand('%:t:r')
  let run = s:compat_path . (&filetype ==# 'python' ? 'python3 ' . shellescape(expand('%:p')) : shellescape(out))
  if empty($TMUX)
    if &filetype ==# 'cpp'
      execute '!clear && mkdir -p ' . shellescape(expand('%:p:h') . '/bin', 1) . ' && g++ -std=c++17 -Wall' . escape(s:compat_inc, '%#!') . ' ' . shellescape(expand('%:p'), 1) . ' -o ' . shellescape(out, 1) . ' && ' . escape(s:compat_path, '%#!') . shellescape(out, 1)
    else
      execute '!clear && ' . escape(run, '%#!')
    endif
    return
  endif
  " 先檢查(C++ 順便編譯),有錯就跟 F9 一樣只顯示錯誤、游標留在 vim
  let [err, msg] = s:Compile(1)
  if err
    call s:ShowInPane(s:Report(err, msg), '', 0)
    call s:EchoStatus(err, msg)
    return
  endif
  let report = empty(msg) ? [] : s:Report(0, msg) + [s:dim . '──────── 開始執行 ────────' . s:reset]
  " 程式不是正常結束(exit code 不是 0)就用紅字標示,常見的幾種順便說明原因;按 Ctrl+C 停止(130)只淡淡提示
  " C++ 的 main 裡 return 1 這類也會走到最後一種,所以不說「出錯」,改說回傳值不是 0
  let other = &filetype ==# 'cpp' ? '程式結束時回傳的不是 0,例如 main 裡 return 了 1,或程式出錯' : '程式執行時出錯,看上面的錯誤訊息'
  let run .= '; s=$?; why=; case $s in 0) ;;'
        \ . ' 130) printf ''\n\033[2m(已用 Ctrl+C 停止程式)\033[0m\n'' ;;'
        \ . ' 134) why="程式中止了,例如有例外(exception)沒有被處理" ;;'
        \ . ' 136) why="算術錯誤,例如整數除以 0" ;;'
        \ . ' 138|139) why="記憶體存取錯誤,例如陣列索引超出範圍、指標沒有設定好,或遞迴太深" ;;'
        \ . ' *) why="' . other . '" ;; esac;'
        \ . ' [ -n "$why" ] && printf ''\n\033[1;31m✗ code is error\033[0m(%s,exit code %s)\n'' "$why" $s'
  call s:ShowInPane(report, run, 1)
endfunction

nnoremap <F9> :call CheckCode()<CR>
inoremap <F9> <Esc>:call CheckCode()<CR>
nnoremap <F10> :call RunCode()<CR>
inoremap <F10> <Esc>:call RunCode()<CR>

" Python 習慣用 4 個空白縮排(混用 Tab 和空白在 Python 會出錯)
autocmd FileType python setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4

" ===== Cmd+← / Cmd+→ 跳到行首 / 行尾 =====
" iTerm 把 Cmd+←/→ 送成 Home/End,tmux 再轉成 Ctrl+A / Ctrl+E
nnoremap <C-a> ^
nnoremap <C-e> $
inoremap <C-a> <C-o>^
inoremap <C-e> <C-o>$

" ===== 滑鼠 =====
" 讓滑鼠滾輪可以捲動 vim 的內容,也能用滑鼠點位置移動游標(2026-10-05 加,要取消就刪掉下一行)
set mouse=a

" ===== C++ 大括號:打 { 再按 Enter,自動補上 } 並把游標放在中間縮排好的那行(2026-10-11 加) =====
" cindent 讓 vim 照 C++ 的規則自動縮排(大括號裡面多縮一格)
autocmd FileType cpp setlocal cindent
autocmd FileType cpp inoremap <buffer> <expr> <CR> <SID>BraceEnter()
function! s:BraceEnter()
  let before = getline('.')[col('.') - 2]
  let after = getline('.')[col('.') - 1]
  if before ==# '{' && after ==# '}'
    return "\<CR>\<Esc>O"
  elseif before ==# '{' && !s:HasClosingBrace()
    return "\<CR>}\<Esc>O"
  endif
  return "\<CR>"
endfunction

" 檢查游標前面那個 { 是不是已經有自己的 }(2026-10-11 加)
" 往後找跟它配對的 },而且那個 } 的縮排要跟 { 那一行一樣,才算「它自己的」;
" 不然新打的 { 會誤配到外層(例如 main)的 },以為已經有了
function! s:HasClosingBrace()
  let skip = 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string\\|comment\\|character"'
  let lnum = searchpair('{', '', '}', 'nW', skip)
  return lnum > 0 && indent(lnum) == indent('.')
endfunction

" ===== 跟 Windows 上的 C++ 編輯器一樣的操作習慣(2026-10-12 加) =====
" Ctrl+S 存檔、Ctrl+Z 復原、Ctrl+Y 重做
" (原本 Ctrl+Z 會讓 vim 縮到背景不見,Ctrl+S 在打字時會插入看不見的字元,害程式編譯不過)
nnoremap <silent> <C-s> :call SaveCode()<CR>
xnoremap <silent> <C-s> <Esc>:call SaveCode()<CR>
snoremap <silent> <C-s> <Esc>:call SaveCode()<CR>
" 打字時還沒有檔名或是唯讀:先回到一般模式再提示,不然提示會被底下的 -- INSERT -- 蓋掉
inoremap <silent> <expr> <C-s> empty(expand('%')) \|\| &readonly ? "\<Esc>:call SaveCode()\<CR>" : "\<C-o>:update\<CR>"
" 還沒有檔名時改顯示中文提示,不會跳出英文的 E32: No file name
function! SaveCode()
  if s:NeedName('')
    return
  elseif &readonly
    echohl WarningMsg | echo '這裡是唯讀,不能存檔:另一個 vim 正在編輯這個檔案' | echohl None
    return
  endif
  update
endfunction
nnoremap <C-z> u
inoremap <C-z> <C-o>u
xnoremap <C-z> <Esc>u
snoremap <C-z> <Esc>u
nnoremap <C-y> <C-r>
inoremap <C-y> <C-o><C-r>

" 用滑鼠拖曳或 Shift+方向鍵選取文字;選取後直接打字會取代它,Backspace 刪掉(不會被當成 vim 指令)
set selectmode=mouse,key
set keymodel=startsel,stopsel
" 選取範圍跟 Windows 一樣:按幾下 Shift+→ 就選幾個字
set selection=exclusive
" 在行首按 ← 跳到上一行結尾,在行尾按 → 跳到下一行開頭
set whichwrap+=<,>,[,]

" 選取後 Ctrl+C 複製、Ctrl+X 剪下,Ctrl+V 貼上,跟 Mac 的剪貼簿共用(Cmd+V 也可以貼上)
xnoremap <C-c> "*y
snoremap <C-c> <C-g>"*y
xnoremap <C-x> "*d
snoremap <C-x> <C-g>"*d
xnoremap <C-v> "_c<C-r><C-o>*
snoremap <C-v> <C-g>"_c<C-r><C-o>*
inoremap <C-v> <C-r><C-o>*
nnoremap <C-v> "*P

" 選取多行後按 Tab / Shift+Tab 整塊增加 / 減少縮排;打字時 Shift+Tab 減少這一行的縮排
xnoremap <Tab> >gv
xnoremap <S-Tab> <gv
snoremap <Tab> <C-g>>gv<C-g>
snoremap <S-Tab> <C-g><gv<C-g>
inoremap <S-Tab> <C-d>
nnoremap <S-Tab> <<

" Ctrl+F 搜尋:打要找的字按 Enter,按 n 找下一個(打字的時候就會先跳過去)
set incsearch
nnoremap <C-f> /
inoremap <C-f> <Esc>/

" 打 ( [ " 自動補上另一半;右邊已經是同一個字時,打 ) ] " 直接跳過去;
" 在一對空的括號或引號中間按 Backspace,兩個一起刪掉(貼上的程式碼不受影響)
" 只有在行尾、空白或右括號前面才補另一半;右邊還有別的字時(例如在字串 "A[ 裡面)只打一個(2026-10-12 改)
inoremap <expr> ( <SID>OpenPair('(', ')')
inoremap <expr> [ <SID>OpenPair('[', ']')
inoremap <expr> ) <SID>SkipClose(')')
inoremap <expr> ] <SID>SkipClose(']')
inoremap <expr> " <SID>Quote()
inoremap <expr> <BS> <SID>PairBackspace()
function! s:CharAt(offset)
  return getline('.')[col('.') - 1 + a:offset]
endfunction
function! s:CanPair()
  return s:CharAt(0) =~# '^$\|[[:space:])\]};,]'
endfunction
function! s:OpenPair(open, close)
  return s:CanPair() ? a:open . a:close . "\<C-g>U\<Left>" : a:open
endfunction
function! s:SkipClose(c)
  return s:CharAt(0) ==# a:c ? "\<C-g>U\<Right>" : a:c
endfunction
" 引號:先數游標前面有幾個 "(\" 和 '"' 不算),單數表示正在字串裡,這個 " 是收尾:
" 右邊已經是 " 就跳過,不然只打一個;雙數表示要開新字串,才補另一半(2026-10-12 改)
" (原本只看左右一個字,打 print(f"x = {x}") 或 '"' 時會多出 ")
function! s:Quote()
  let before = substitute(strpart(getline('.'), 0, col('.') - 1), '\\.', '', 'g')
  if before =~# '\\$'
    return '"'
  endif
  if len(substitute(substitute(before, '''"''', '', 'g'), '[^"]', '', 'g')) % 2
    return s:CharAt(0) ==# '"' ? "\<C-g>U\<Right>" : '"'
  endif
  " 左邊是 ' 或 " 時(例如 '"' 或 Python 的 """),或右邊還有別的字時,只打一個
  return s:CharAt(-1) =~# '[''"]' || !s:CanPair() ? '"' : "\"\"\<C-g>U\<Left>"
endfunction
function! s:PairBackspace()
  return index(['()', '[]', '""', '{}'], s:CharAt(-1) . s:CharAt(0)) >= 0 ? "\<BS>\<Del>" : "\<BS>"
endfunction

" ===== 打開檔案時發現上次留下的暫存檔(2026-10-12 加) =====
" vim 編輯時會在旁邊留一個 .檔名.swp,正常關掉時會刪掉。直接關掉 iTerm,或同一個檔案開了兩次,
" 再打開時原本會跳出一大段英文(E325: ATTENTION),這裡改成自動處理或用中文問:
"   另一個 vim 還開著這個檔案      → 這裡用唯讀打開(不能存檔),提醒回原本那個 vim 去改
"   上次沒正常關掉,沒有沒存的修改 → 直接刪掉暫存檔,照常打開
"   上次沒正常關掉,有沒存的修改   → 問要不要救回來
autocmd SwapExists * call s:SwapExists()
function! s:SwapExists()
  let info = swapinfo(v:swapname)
  if has_key(info, 'error')
    return
  endif
  call system('kill -0 ' . info.pid)
  if !v:shell_error
    let v:swapchoice = 'o'
    call s:LaterMsg('另一個 vim 正在編輯這個檔案,這裡只能看(唯讀),要改請回到那個 vim')
  elseif !info.dirty
    let v:swapchoice = 'd'
  elseif confirm('上次 vim 沒有正常關掉(例如直接關掉 iTerm),「' . expand('<afile>:t') . '」有還沒存檔的修改。要救回來嗎?' . "\n" . '(救回來時會接著出現一段英文說明,按 Enter 就好;回到檔案確認沒問題後按 Ctrl+S 存檔)', "&1 救回來\n&2 不要,用存好的內容", 1) == 1
    let v:swapchoice = 'r'
    " 救回來、存檔之後,舊的暫存檔就用不到了,刪掉它,下次打開才不會再問一次
    let s:old_swap = v:swapname
    autocmd BufWritePost * ++once call delete(s:old_swap)
  else
    let v:swapchoice = 'd'
  endif
endfunction
" 等檔案打開、vim 顯示完自己的訊息後再顯示,才不會被蓋掉
function! s:LaterMsg(msg)
  call timer_start(100, {-> execute('echohl WarningMsg | echo ' . string(a:msg) . ' | echohl None', '')})
endfunction

" ===== 貼上程式碼時縮排不會亂掉(2026-10-11 加) =====
" 在 tmux 裡 vim 預設沒開「bracketed paste」,貼上的文字會被當成一個字一個字打進來,
" 每一行又被自動縮排再縮一次。這幾行讓 vim 認得「這是貼上的」,原樣放進去
if &term =~# 'tmux\|screen'
  let &t_BE = "\e[?2004h"
  let &t_BD = "\e[?2004l"
  exec "set t_PS=\e[200~"
  exec "set t_PE=\e[201~"
endif

" ===== 自己的設定放這裡(2026-10-12 加) =====
" 想改成自己的習慣,寫在 ~/.vimrc.local;codenv 更新時只會換掉這個檔,不會動到 .local
if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif

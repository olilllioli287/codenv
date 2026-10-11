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
  let msg = system(cd . mkbin . 'g++ -std=c++17 -Wall' . color . ' ' . src . output . ' 2>&1')
  let err = v:shell_error
  return [err, s:OnlyMyFile(msg, err)]
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

" 還沒有檔名(例如 codenv 選「先不開檔案」)就沒辦法存檔,先提醒怎麼取名
function! s:NeedName()
  if !empty(expand('%'))
    return 0
  endif
  echohl WarningMsg | echo '還沒有檔名:先輸入 :w 檔名 存檔(例如 :w hw1.cpp 或 :w hw1.py),再按 F9 / F10' | echohl None
  return 1
endfunction

function! CheckCode()
  if s:NeedName() | return | endif
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
  if s:NeedName() | return | endif
  write
  if &filetype !=# 'cpp' && &filetype !=# 'python'
    echo 'F10 只支援 .cpp 和 .py 檔'
    return
  endif
  let out = expand('%:p:h') . '/bin/' . expand('%:t:r')
  let run = &filetype ==# 'python' ? 'python3 ' . shellescape(expand('%:p')) : shellescape(out)
  if empty($TMUX)
    if &filetype ==# 'cpp'
      execute '!clear && mkdir -p ' . shellescape(expand('%:p:h') . '/bin', 1) . ' && g++ -std=c++17 -Wall ' . shellescape(expand('%:p'), 1) . ' -o ' . shellescape(out, 1) . ' && ' . shellescape(out, 1)
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
  let run .= '; s=$?; why=; case $s in 0) ;;'
        \ . ' 130) printf ''\n\033[2m(已用 Ctrl+C 停止程式)\033[0m\n'' ;;'
        \ . ' 134) why="程式中止了,例如有例外(exception)沒有被處理" ;;'
        \ . ' 136) why="算術錯誤,例如整數除以 0" ;;'
        \ . ' 138|139) why="記憶體存取錯誤,例如陣列索引超出範圍、指標沒有設定好,或遞迴太深" ;;'
        \ . ' *) why="程式執行時出錯" ;; esac;'
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

" ===== 貼上程式碼時縮排不會亂掉(2026-10-11 加) =====
" 在 tmux 裡 vim 預設沒開「bracketed paste」,貼上的文字會被當成一個字一個字打進來,
" 每一行又被自動縮排再縮一次。這幾行讓 vim 認得「這是貼上的」,原樣放進去
if &term =~# 'tmux\|screen'
  let &t_BE = "\e[?2004h"
  let &t_BD = "\e[?2004l"
  exec "set t_PS=\e[200~"
  exec "set t_PE=\e[201~"
endif

﻿"=================================================================
"  Neovim設定ファイル for windows @pachicoma
"  Update: 2017.03.12
"=================================================================
"--------------------------------------------------
" 環境情報設定
"--------------------------------------------------
" Windows環境判定
let s:is_windows = has('win32') || has('win64')
if s:is_windows
	" Neovim設定ディレクトリ
	if $XDG_CONFIG_HOME == ""
		let s:nvim_config_dir = substitute(expand($LOCALAPPDATA) . '/nvim/', '\', '/', 'g')
	else
		let s:nvim_config_dir = substitute(expand($XDG_CONFIG_HOME) . '/nvim/', '\', '/', 'g')
	endif
	set shellslash
	set fileencoding=utf-8
	set fileencodings=iso-2022-jp,utf-8,euc-jp,cp932
else
	let s:nvim_config_dir = expand($XDG_CONFIG_HOME) . '/nvim/'
endif
" VIM起動時にプラグイン設定
let g:init_plugins = s:nvim_config_dir . "plugins.toml"
" 遅延読み込みプラグイン
let g:init_lazy_plugins = s:nvim_config_dir . "plugins_lazy.toml"

"--------------------------------------------------
" 基本設定 
"--------------------------------------------------
set nocompatible		" Vi互換モードは利用しない
set novb				" ビープ音,フラッシュ無効
set t_vb=				" ビープ音,フラッシュ無効
set iminsert=0			" 挿入モードでIMEをONしない
set imsearch=-1			" 検索時のIME状態はiminsertに依存
set history=500			" コマンド履歴の制限数
set undolevels=1000		" undoの制限数
set nobackup			" バックアップファイルは作らない
set mouse=a				" マウスを使えるようにする
set number				" 行番号表示
set ruler				" カーソル位置などを右下に表示
set cursorline			" カーソル行に強調表示
"set cursorcolumn		" カーソル列を強調表示
set cmdheight=1			" コマンドラインの高さ
set showbreak=\>		" 折り返し行の先頭に表示する文字列
set ambiwidth=double	" ■とかを正しく表示
"set foldmethod=indent	" インデントで折畳みアルゴリズム
set showcmd				" 未完了コマンドをステータスラインに表示
"Font config see ginit.vim
syntax on				" シンタックスハイライト
colors desert			" カラースキーム
" 不可視文字の表示 ※カラースキーム設定の後に設定すること
set list listchars=tab:>_,trail:_,eol:^
highlight SpecialKey term=none guifg=gray
highlight NonText guibg=none guifg=gray

" 検索
"-----------------------
set incsearch			" インクリメンタル検索
set gdefault			" 検索時は/gオプション付がデフォルト
set ignorecase			" 大文字・小文字区別無しで検索
set smartcase			" 検索パターンが大文字を含んでいたら区別する
set wrapscan			" バッファ末尾まで検索したらバッファ先頭から検索する

" Grep
"-----------------------
" 出力フォーマット
set grepformat=%f:%l:%m,%f:%l%m,%f\ \ %l%m,%f
" 使用するGrepコマンド
if executable('rg')
	set grepprg=rg\ --vimgrep
else
	set grepprg=grep\ -nH
endif
" grep後QuickFixを開く
augroup grepopen
	autocmd!
	autocmd QuickfixCmdPost grep cw
augroup END
set wildignore+=/.git/*,/*.svn/*,*.b

" タグ
"-----------------------
" タグファイル指定
set tag+=**

" コマンドライン
"-----------------------
set wildmenu               " 補完拡張モード
set wildmode=longest:full  " 共通部分最長補完＋wildmenu

" カーソル
"-----------------------
set backspace=indent,eol,start
set whichwrap=b,s,h,l,<,>,[,]

" ステータスライン
"-----------------------
set laststatus=2		" ステータスラインを常時表示
"[BuffNo][読専][Help][Preview] FilePath[修正F] >> (行,列)[utf-8:unix][最終行]
set statusline=[%n]%r%h%w%F\ %m%=(%l,%c)\ [%{&fenc!=''?&fenc:&enc}:%{&ff}][%LL]
" 挿入モード時、ステータスラインの色を変更
let s:hi_insert = 'highlight StatusLine guifg=darkblue guibg=darkyellow gui=none ctermfg=blue ctermbg=yellow cterm=none'
if has('syntax')
	augroup InsertHook
		autocmd!
		autocmd InsertEnter * call s:StatusLine('Enter')
		autocmd InsertLeave * call s:StatusLine('Leave')
	augroup END
endif
" ステータスライン切替時にコールする関数
let s:slhlcmd = ''
function! s:StatusLine(mode)
	if a:mode == 'Enter'
		silent! let s:slhlcmd = 'highlight ' . s:GetHighlight('StatusLine')
		silent exec s:hi_insert
	else
		highlight clear StatusLine
		silent exec s:slhlcmd
	endif
endfunction
" ステータスラインの色を取得
function! s:GetHighlight(hi)
	redir => hl
		exec 'highlight '.a:hi
	redir END
	let hl = substitute(hl, '[\r\n]', '', 'g')
	let hl = substitute(hl, 'xxx', '', '')
	return hl
endfunction

" インデント
"-----------------------
set tabstop=4			" 画面上でのタブが占める幅
set softtabstop=4		" TabやBS押下時のカーソル移動値
set shiftwidth=4		" autoindentや<<,>>でのインデント量
set shiftround			" インデント量をshiftwidthの倍数で丸める
set formatoptions=q		" 自動フォーマット

" タブ/ウィンドウ操作
"-----------------------
set splitbelow			" 上下に分割するとき、新しいウィンドウは下に作る
set splitright			" 左右に分割するとき、新しいウィンドウは右に作る


" セッション
"-----------------------
" sessionで保存する項目の指定
set sessionoptions=buffers,folds,resize,sesdir,winpos,winsize

" IME 日本語入力
"-----------------------
" Normalモード遷移時に無効にする
inoremap <ESC> <ESC>:set iminsert=0<CR>

" 補完メニュー
"-----------------------
set pumheight=20

"--------------------------------------------------
" ファイルオープン時のアクション
"--------------------------------------------------
" 開いたファイルのディレクトリへ移動
au BufEnter * execute 'lcd ' fnameescape(expand('%:p:h'))
" TOMLファイルはvimスクリプトとして開く
au BufNewFile,BufRead *.toml setf vim

"--------------------------------------------------
" キーバインド
"--------------------------------------------------
" 共通
"-----------------------
" Leader key
nnoremap <Space> <nop>
let mapleader = "\<Space>"

" ;でコマンド入力モードへ
noremap ; :
noremap : ;

nnoremap <C-S-s> <nop>

" help
"-----------------------
" カーソル位置の単語をヘルプ
nnoremap <F1> :<C-u>help<Space><C-r><C-w><CR>
" qでウィンドウを閉じる
autocmd FileType help nnoremap <buffer> q <C-w>c

" quickfixウィンドウ
"-----------------------
" qでウィンドウを閉じる
autocmd FileType qf nnoremap <buffer> q <C-w>c
nnoremap <silent> <Leader>O :<C-u>co<CR>
nnoremap <silent> <C-,> :<C-u>cprevious<CR>
nnoremap <silent> <C-.> :<C-u>cnext<CR>

" 日本語入力固定モード
"inoremap <silent> <C-j> <C-^>

" よく開くファイルのショートカット
"-----------------------
nnoremap <silent> <Leader>ei :<C-u>e $MYVIMRC<CR>
nnoremap <silent> <Leader>ri :<C-u>source $MYVIMRC<CR>
nnoremap <silent> <Leader>eg :<C-u>e $XDG_CONFIG_HOME/nvim/ginit.vim<CR>
nnoremap <silent> <Leader>rg :<C-u>source $XDG_CONFIG_HOME/nvim/ginit.vim<CR>
nnoremap <silent> <Leader>ep :<C-u>e $XDG_CONFIG_HOME/nvim/plugins.toml<CR>
nnoremap <silent> <Leader>el :<C-u>e $XDG_CONFIG_HOME/nvim/plugins_lazy.toml<CR>

" ファイル操作
"-----------------------
"wshadaファイルの強制更新
nnoremap <Leader>w :<C-u>wshada!<CR>

" 保存
nnoremap <C-s> <Esc>:<C-u>update<CR>
"nnoremap <Leader>w :w<CR>

" ウィンドウ幅で折り返しON/OFF切替
nnoremap <silent> <Leader><Leader>l :<C-u>setlocal wrap!<CR>

" バッファ操作
"-----------------------
nnoremap <silent> <Leader>j :bn<CR>
nnoremap <silent> <Leader>k :bp<CR>
nnoremap <silent> <Leader>W :bd<CR>
nnoremap <silent> <Leader>o <C-^>
"nnoremap <silent> <Leader>b :ls<CR>:buf

" ウィンドウ操作
"-----------------------
" フルスクリーン切り替え
nnoremap <silent><F11> :call ToggleWindowFullScreen()<CR>
let g:gui_fullscreen_status = 0
function! ToggleWindowFullScreen()
	let g:gui_fullscreen_status = (g:gui_fullscreen_status + 1) % 2
	call GuiWindowFullScreen(g:gui_fullscreen_status)
endfunction

" タブ操作
"-----------------------
nnoremap <silent> <Leader>tn :tabnew<CR> 
nnoremap <silent> <Leader>tt :tabnew `=tempname()`<CR>
nnoremap <silent> <Leader>tw :tabclose<CR>
nnoremap <silent> <Leader>h :tabprevious<CR>
nnoremap <silent> <Leader>l :tabnext<CR>

" カーソル移動
"-----------------------
" ノーマルモード
nnoremap <S-h> ^
nnoremap <S-l> $
" インサートモード(Emacs like)
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-f> <Right>
inoremap <C-b> <Left>
inoremap <C-n> <Down>
inoremap <C-p> <Up>
inoremap <C-d> <Delete>
" コマンドモード(Emacs like)
cnoremap <C-f> <Right>
cnoremap <C-b> <Left>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
inoremap <C-d> <Delete>
cnoremap <C-c> <C-f>

" カーソル中央でスクロール
noremap <expr> <C-d> max([winheight(0) - 2, 1])
      \ . "\<C-d>" . (line('w$') >= line('$') ? "L" : "M")
noremap <expr> <C-u> max([winheight(0) - 2, 1])
      \ . "\<C-u>" . (line('w0') <= 1 ? "H" : "M")

" 編集
"-----------------------
" 改行
"inoremap <C-j> <CR>
" インデント
nnoremap < <<
nnoremap > >>
vnoremap < <gv
vnoremap > >gv

" コピペ
"-----------------------
" クリップボードと共有
nnoremap <Leader>d "*dd
vnoremap <Leader>d "*d
nnoremap <Leader>y "*yy
vnoremap <Leader>y "*y
nnoremap <Leader>p "*p
vnoremap <Leader>p "*p
nnoremap <Leader>Y "*y$
" コピペしたらテキストの末尾へ移動
vnoremap <silent> y y`]
vnoremap <silent> p p`]
nnoremap <silent> p p`]
" 直前に貼り付けたテキスト素早く選択
noremap gV `[v`]
" カーソル位置の単語をヤンクで置換
nnoremap <silent> cy ce<C-r>0<ESC>:let@/=@1<CR>:noh<CR>
vnoremap <silent> cy ce<C-r>0<ESC>:let@/=@1<CR>:noh<CR>
nnoremap <silent> ciy ciw<C-r>0<ESC>:let@/=@1<CR>:noh<CR>

" 検索/置換
"-----------------------
" 検索ワードのハイライト表示を解除する
noremap <silent><ESC><ESC> :<C-u>noh<CR>
" カーソル位置の単語を書換て置換(.コマンド使用可)
nnoremap <C-c>r *``cgn
nnoremap <C-c>R *``cgN
" カーソル位置の単語を置換対象にする(*1)
nnoremap <C-e>r yiw:<C-u>%s/<C-R>"//gc<Left><Left><Left>
" ビジュアルモードで選択中の文字を置換対象にする(*1)
vnoremap <C-e>r y:<C-u>%s/<C-R>"//gc<Left><Left><Left>
" .コマンドで繰り返し可能な置換
vnoremap <expr> cn "y/\\V\<C-r>=escape(@\", '/')\<CR>\<CR>" . "``cgn"
vnoremap <expr> cN "y/\\V\<C-r>=escape(@\", '/')\<CR>\<CR>" . "``cgN"

" *1 ... 副作用で選択中の文字をヤンク

" Grep
"-----------------------
" 選択中の文字をgrep対象にする(*1)
vnoremap <C-e>g y:<C-u>grep <C-R>"
" カーソル位置の単語をgrep対象にする(*1)
nnoremap <C-e>g yiw:<C-u>grep <C-R>"

" *1 ... 副作用で選択中の文字をヤンク

" ctags
"-----------------------
nnoremap <silent>Jo <C-o>
nnoremap <silent>Ji <C-i>
nnoremap <silent>JJ <C-]>
nnoremap <silent>Jj <C-t>
"nnoremap <Leader>jj g<C-]>
"nnoremap <Leader>k <C-t>
"nnoremap <Leader>J :<C-u>tn<CR>
"nnoremap <Leader>K :<C-u>tp<CR>
"nnoremap <Leader>J <C-w>}
"nnoremap <Leader>K :<C-u>pc<CR>
"nnoremap <Leader>L :<C-u>tselect<CR>
nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> [B :bfirst<CR>
nnoremap <silent> ]B :blast<CR>

" gtags
"-----------------------
"nnoremap gj :GtagsCursor<CR>
"nnoremap gJ :Gtags -f %<CR>
"nnoremap gn :cn<CR>
"nnoremap gp :cp<CR>

"nnoremap t <Nop>
"nnoremap tj <C-]>
"nnoremap tg :<C-u>tag<CR>
"nnoremap tt :<C-u>pop<CR>
"nnoremap tl :<C-u>tags<CR>


" 日本語入力がオンのままコマンド(Enterキーは必要)
nnoremap あ a
nnoremap い i
nnoremap う u
nnoremap お o
nnoremap っd dd
nnoremap っy yy
nnoremap ｐ p

"--------------------------------------------------
" 入力補完単語候補
"--------------------------------------------------
iabbr datei <C-r>=strftime("%Y.%m.%d")<CR>
iabbr timei <C-r>=strftime("%H:%M")<CR>
iabbr dti <C-r>=strftime("%Y.%m.%d %H:%M")<CR>
iabbr maili pachicoma@gmail.com

"--------------------------------------------------
" プラグイン関連
"--------------------------------------------------
" Pythonのパス
let g:python_host_prog = fnameescape(expand('C:\Python27\python.exe'))
let g:python3_host_prog = fnameescape(expand('C:\Python36\python.exe'))

" deinのURL
let dein_path = 'github.com/Shougo/dein.vim'
let dein_url = 'https://' . dein_path

" プラグインをインストールするディレクトリ
let s:dein_dir = s:nvim_config_dir . '.cache/dein/'
" dein.vim 本体
let s:dein_repo_dir = s:dein_dir . 'repos/' . dein_path

" dein.vimがなければインストールする
if !isdirectory(s:dein_repo_dir)
	execute '!git clone ' . dein_url s:dein_repo_dir
endif
" dein.vimをruntimepathへ追加
let &runtimepath = s:dein_repo_dir . "," . &runtimepath

" 設定開始
if dein#load_state(s:dein_dir)
	call dein#begin(s:dein_dir)
	" プラグインリストファイル
	" プラグインリストファイルを読込みキャッシュする
	call dein#load_toml(g:init_plugins, {'lazy': 0})
	call dein#load_toml(g:init_lazy_plugins, {'lazy': 1})
	" 設定終了
	call dein#end()
	call dein#save_state()
endif

" 未インストールのプラグインがある場合はインストール
if dein#check_install()
	call dein#install()
endif

" プラグイン後でないと設定しないとカラー設定が有効にならない？
filetype plugin indent on


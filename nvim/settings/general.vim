" シェルを指定
if system('uname -s') == "Darwin\n"
  " mac の場合
  set shell=/bin/zsh
endif
if system('uname -s') == "Linux\n"
  " linux の場合
  set shell=/usr/bin/bash
endif

set synmaxcol=320

" .ts ファイルを開くとシンタックスが無効になる事象回避設定
" https://github.com/fatih/vim-go/issues/3171
set re=0

" setting
" 文字コードをUFT-8に設定
set encoding=utf-8
set fenc=utf-8
" バックアップファイルを作らない
set nobackup
" スワップファイルを作らない
set noswapfile
" 編集中のファイルが変更されたら自動で読み直す
set autoread
" バッファが編集中でもその他のファイルを開けるように
set hidden
" 入力中のコマンドをステータスに表示する
set showcmd
" ヤンクをクリップボードへ引き継ぐ
" mac の場合
if system('uname -s') == "Darwin\n"
  set clipboard+=unnamed
endif
" linux の場合
" sudo apt install xclip も必要
if system('uname -s') == "Linux\n"
  set clipboard=unnamedplus
endif
" 挿入モードでバックスペース削除を有効
set backspace=indent,eol,start
" xで削除した時はヤンクしない
vnoremap x "_x
nnoremap x "_x

" 見た目系
" 行番号を表示
set number
" 現在の行を強調表示
set cursorline
" 列を強調表示
set cursorcolumn
" 行末の1文字先までカーソルを移動できるように
set virtualedit=onemore
" インデントはスマートインデント
set smartindent
" ビープ音を可視化
set visualbell
" 括弧入力時の対応する括弧を表示
set showmatch
" ステータスラインを常に表示
set laststatus=2
" コマンドラインの補完
set wildmode=list:longest
" 折り返し時に表示行単位での移動できるようにする
nnoremap j gj
nnoremap k gk
" シンタックスハイライトの有効化
syntax enable
" 行数を相対的に表示
set relativenumber

" Tab系
" 不可視文字を可視化(タブが「▸-」と表示される)
set list listchars=tab:\▸\-
" Tab文字を半角スペースにする
set expandtab
" 行頭以外のTab文字の表示幅（スペースいくつ分）
set tabstop=2
" 行頭でのTab文字の表示幅
set shiftwidth=2

" 検索系
" 検索文字列が小文字の場合は大文字小文字を区別なく検索する
set ignorecase
" 検索文字列に大文字が含まれている場合は区別して検索する
set smartcase
" 検索文字列入力時に順次対象文字列にヒットさせる
set incsearch
" 検索時に最後まで行ったら最初に戻る
set wrapscan
" 検索語をハイライト表示
set hlsearch
" ESC連打でハイライト解除
nmap <Esc><Esc> :nohlsearch<CR><Esc>

" 括弧の補完
inoremap {<Enter> {}<Left><CR><ESC><S-o>
inoremap [<Enter> []<Left><CR><ESC><S-o>
inoremap (<Enter> ()<Left><CR><ESC><S-o>

" クオーテーションの補完
inoremap ' ''<LEFT>
inoremap " ""<LEFT>

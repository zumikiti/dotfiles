" シェルを指定してください
set shell=/bin/zsh

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
set clipboard+=unnamed
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
" highlight CursorLine guibg=#0000A0 ctermbg=000
" 列を強調表示
set cursorcolumn
" highlight CursorColumn guibg=#0000A0 ctermbg=000
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

" 画面分割系
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sh <C-w>h
nnoremap ss :<C-u>sp<CR><C-w>j
nnoremap sv :<C-u>vs<CR><C-w>l

" タブの操作
" 新規タブを開く
nnoremap st :tablast <bar> tabnew<CR>
" Tab で次のタブに移動
nmap <Tab> :tabnext<CR>
" Shift + Tab で前のタブに移動
nmap <S-Tab> :tabprevious<CR>
" 閉じる
nnoremap sq :tabclose<CR>
" バッファを閉じる
nnoremap sQ :bd

" option + | でファイル内の文字置換
" nnoremap \ :%s/old/new/g<LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT><LEFT>

" tig を開く
nnoremap tig :vertical terminal ++close tig<Enter>
" nnoremap tig :FloatermNew tig<Enter>
nnoremap fn :FloatermNew fish<Enter>
nnoremap git :FloatermNew lazygit<Enter>
let g:floaterm_width=0.9
let g:floaterm_height=0.9
let g:floaterm_autoclose=2

"plugin
call plug#begin('~/.vim/plugged')

Plug 'nanotech/jellybeans.vim'
Plug 'altercation/vim-colors-solarized'
Plug 'sheerun/vim-polyglot'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }
Plug 'terryma/vim-multiple-cursors'
Plug 'dhruvasagar/vim-table-mode'
Plug 'scrooloose/nerdcommenter'
Plug 'simeji/winresizer'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'
Plug 'preservim/nerdtree'
Plug 'nsf/gocode', { 'rtp': 'vim', 'do': '~/.vim/plugged/gocode/vim/symlink.sh' }
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'nathanaelkane/vim-indent-guides'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'shougo/vimfiler.vim'
Plug 'shougo/unite.vim'
Plug 'vim-scripts/gtags.vim'
Plug 'vim-scripts/taglist.vim'
Plug 'voldikss/vim-floaterm'
Plug 'kamykn/spelunker.vim'
Plug 'kamykn/popup-menu.nvim'
Plug 'phpactor/phpactor', {'for': 'php', 'branch': 'master', 'do': 'composer install --no-dev -o'}
Plug 'posva/vim-vue'
Plug 'editorconfig/editorconfig-vim'
Plug 'mattn/vim-sqlfmt'

call plug#end()

" カラーテーマ
syntax on
colorscheme jellybeans
let g:jellybeans_overrides = {
      \    'background': { 'ctermbg': 'none', '256ctermbg': 'none' },
      \}
if has('termguicolors') && &termguicolors
  let g:jellybeans_overrides['background']['guibg'] = 'none'
endif
" syntax enable
" set background=dark
" colorscheme solarized

" NERDCommenter の設定
let NERDSpaceDelims = 1
filetype on

" ,, でコメント、アンコメント
nmap ,, <Plug>NERDCommenterToggle
vmap ,, <Plug>NERDCommenterToggle

" NERDtree
" デフォルトで隠しファイルを表示
let NERDTreeShowHidden = 1
" font icon 指定
let g:webdevicons_enable_nerdtree = 1
set guifont=Hack_Nerd_Font:h9
" C-a でディレクトリツリーを表示
nmap <silent><C-a> :NERDTreeFind<CR>:vertical res 30<CR>
" The NERD Treeのウィンドウだけが残るような場合にVimを終了
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" vim-airline の設定
let g:airline_theme = 'deus'
set laststatus=2
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#wordcount#enabled = 0
let g:airline#extensions#default#layout = [['a', 'b', 'c'], ['x', 'y', 'z']]
let g:airline_section_c = '%t'
let g:airline_section_x = '%{&filetype}'
let g:airline_section_z = '%3l:%2v'
let g:airline#extensions#default#section_truncate_width = {}
let g:airline#extensions#whitespace#enabled = 1
let g:airline_powerline_fonts = 1
let g:webdevicons_enable_airline_tabline = 1

" govode の設定
let g:go_gocode_unimported_packages = 1

" fzf
command! -bang -nargs=* Rg
    \ call fzf#vim#grep(
    \ 'rg --column --line-number --hidden --ignore-case --no-heading --color=always '.shellescape(<q-args>), 1,
    \ <bang>0 ? fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'up:60%')
    \ : fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'right:50%:hidden', '?'),
    \ <bang>0)
nnoremap <C-g> :Rg<Space>
nnoremap <C-p> :GFiles<CR>
nnoremap <C-h> :History<CR>

" indent-guides
let g:indent_guides_enable_on_vim_startup = 1


" set tags = tags
let Tlist_Ctags_Cmd = "/usr/local/bin/ctags"  " ctagsのコマンド
let Tlist_Show_One_File = 1                   " 現在表示中のファイルのみのタグしか表示しない
let Tlist_Use_Right_Window = 1                " 右側にtag listのウインドうを表示する
let Tlist_Exit_OnlyWindow = 1                 " taglistのウインドウだけならVimを閉じる
map <silent> <leader>l :TlistToggle<CR>       " \lでtaglistウインドウを開いたり閉じたり出来るショートカット
let g:tlist_php_settings = 'php;c:class;d:constant;f:function'''

" vim-test
nmap <silent> t<C-f> :TestFile<CR> " 現在開いているテストファイルを実行
nmap <silent> t<C-l> :TestLast<CR> " 最後に実行したテストファイルを実行


" phpactor
" 画面を分割して定義元へのジャンプ
function! DefinitionJumpWithPhpactor()
    split
    call phpactor#GotoDefinition()
endfunction

" fugitive の設定
nmap gb :Git blame<CR>

" useの補完
nmap <silent><Leader>u      :<C-u>call phpactor#UseAdd()<CR>
" コンテキストメニューの起動(カーソル下のクラスやメンバに対して実行可能な選択肢を表示してくれます)
nmap <silent><Leader>mm     :<C-u>call phpactor#ContextMenu()<CR>
" ナビゲーションメニューの起動(クラスの参照元を列挙したり、他ファイルへのジャンプなど)
nmap <silent><Leader>nn     :<C-u>call phpactor#Navigate()<CR>
" カーソル下のクラスやメンバの定義元にジャンプ
nmap <silent><Leader>o      :<C-u>call phpactor#GotoDefinition()<CR>
" 編集中のクラスに対し各種の変更を加える(コンストラクタ補完、インタフェース実装など)
nmap <silent><Leader>tt     :<C-u>call phpactor#Transform()<CR>
" 新しいクラスを生成する(編集中のファイルに)
nmap <silent><Leader>cc     :<C-u>call phpactor#ClassNew()<CR>
" 選択した範囲を変数に抽出する
nmap <silent><Leader>ee     :<C-u>call phpactor#ExtractExpression(v:false)<CR>
" 選択した範囲を変数に抽出する
vmap <silent><Leader>ee     :<C-u>call phpactor#ExtractExpression(v:true)<CR>
" 選択した範囲を新たなメソッドとして抽出する
vmap <silent><Leader>em     :<C-u>call phpactor#ExtractMethod()<CR>
" split → jump
nmap <silent><C-w><Leader>o :<C-u>call DefinitionJumpWithPhpactor()<CR>
" カーソル下のクラスや変数の情報を表示する
" 他のエディタで、マウスカーソルをおいたときに表示されるポップアップなどに相当
vmap <silent><Leader>hh     :<C-u>call phpactor#Hover()<CR>

" enter で候補の決定ができなくなったので以下設定
" https://www.reddit.com/r/vim/comments/ekmt45/cocnvim_blocks_enter_key_although_no_suggestion/
" ==========================
" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() 
      \ ? coc#pum#confirm()
      \ : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
" ==========================

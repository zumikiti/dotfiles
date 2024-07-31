" NERDCommenter の設定
let g:NERDSpaceDelims = 1
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

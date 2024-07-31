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

" tig を開く
nnoremap tig :FloatermNew tig<Enter>
nnoremap fn :FloatermNew fish<Enter>
let g:floaterm_width=0.9
let g:floaterm_height=0.9
let g:floaterm_autoclose=2

nnoremap QQ :q<Enter>
nnoremap WQ :wq<Enter>
nnoremap WW :w<Enter>

" xで削除した時はヤンクしない
vnoremap x "_x
nnoremap x "_x

" 折り返し時に表示行単位での移動できるようにする
nnoremap j gj
nnoremap k gk

" ESC連打でハイライト解除
nmap <Esc><Esc> :nohlsearch<CR><Esc>

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
nnoremap tig :vertical terminal ++close tig<Enter>
" nnoremap tig :FloatermNew tig<Enter>
nnoremap fn :FloatermNew fish<Enter>
nnoremap git :FloatermNew lazygit<Enter>
let g:floaterm_width=0.9
let g:floaterm_height=0.9
let g:floaterm_autoclose=2

nnoremap qq :q<Enter>
nnoremap wq :wq<Enter>
nnoremap ww :w<Enter>

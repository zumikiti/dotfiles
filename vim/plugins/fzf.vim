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

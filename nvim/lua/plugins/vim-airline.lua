return {
  'vim-airline/vim-airline',
  dependencies = {
    'vim-airline/vim-airline-themes',
    'ryanoasis/vim-devicons',
  },
  init = function()
    vim.o.laststatus = 2
  end,
}

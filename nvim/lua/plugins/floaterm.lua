return {
  'voldikss/vim-floaterm',
  keys = {
    { 'tig', ':FloatermNew tig<CR>', { noremap = true, silent = true } },
    { 'fn', ':FloatermNew fish<CR>', { noremap = true, silent = true } },
  },
  init = function() 
    vim.g.floaterm_width = 0.9
    vim.g.floaterm_height = 0.9
    vim.g.floaterm_autoclose = 2
  end,
}

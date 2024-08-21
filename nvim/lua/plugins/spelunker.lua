return {
  'kamykn/spelunker.vim',
  dependencies = {
    'kamykn/popup-menu.nvim',
    init = function()
      vim.schedule(function()
        vim.cmd([[hi PmenuSel ctermfg=135 ctermbg=239 cterm=NONE guifg=#b26eff guibg=#4e4e4e gui=NONE]])
      end)
    end,
  },
  init = function()
    vim.opt.spell = false
  end,
}

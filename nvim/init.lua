vim.loader.enable()

-- leaderキーをspaceに変更
vim.g.mapleader = " "

require("core.lazy")

vim.cmd.colorscheme("jellybeans")

vim.api.nvim_create_autocmd("User", {
  callback = function()
    require("core.keymap")
    require("core.general")
  end,
})

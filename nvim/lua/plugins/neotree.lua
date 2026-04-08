return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  cmd = "Neotree",
  keys = {
    { "<leader>f", "<cmd>Neotree filesystem reveal left<cr>", desc = "NeoTree" },
  },
  init = function()
    -- nvim . でディレクトリを開いた場合にneo-treeを起動する
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("NeoTreeAutoOpen", { clear = true }),
      callback = function()
        local path = vim.fn.expand("%:p")
        if vim.fn.isdirectory(path) == 1 then
          require("lazy").load({ plugins = { "neo-tree.nvim" } })
          vim.schedule(function()
            vim.cmd("Neotree dir=" .. path)
            vim.cmd("bdelete " .. vim.fn.bufnr("%"))
          end)
        end
      end,
    })
  end,
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,
    })
  end,
}

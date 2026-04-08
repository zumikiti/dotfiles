return {
  "pwntester/octo.nvim",
  cmd = "Octo",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  config = function(_, opts)
    -- octo://バッファはGitHub APIが実態のため、スワップファイル不要
    vim.api.nvim_create_autocmd("BufReadCmd", {
      pattern = "octo://*",
      callback = function()
        vim.opt_local.swapfile = false
      end,
    })
    require("octo").setup(opts)
  end,
  opts = {
    default_remote = { "origin" },
    suppress_missing_scope = {
      projects_v2 = true,
    },
  },
}

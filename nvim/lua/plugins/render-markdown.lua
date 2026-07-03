return {
  -- Markdownのtreesitterパーサ(render-markdownが必要とする)
  {
    "nvim-treesitter/nvim-treesitter",
    commit = "cf12346a3414fa1b06af75c79faebe7f76df080a",
    build = ":TSUpdate",
    lazy = true,
    opts = {
      ensure_installed = { "markdown", "markdown_inline" },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -- Markdownをバッファ内でリッチに描画
  {
    "MeanderingProgrammer/render-markdown.nvim",
    commit = "0e4510314731181c644f7f5badff96c007ba1a60", -- v8.9.0
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },
}

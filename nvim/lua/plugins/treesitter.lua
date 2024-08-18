return {
  "nvim-treesitter/nvim-treesitter",
  version = false, -- last release is way too old and doesn't work on Windows
  build = ":TSUpdate",
  lazy = 1000, -- load treesitter early when opening a file from the cmdline
  cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
  opts = {
    highlight = { enable = true },
    indent = { enable = true },
    auto_install = true,
    ensure_installed = {
      "bash",
      "fish",
      "diff",
      "json",
      "jsonc",
      "lua",
      "luadoc",
      "luap",
      "markdown",
      "markdown_inline",
      "toml",
      "tsx",
      "vim",
      "vimdoc",
      "yaml",

      "html",
      "javascript",
      "jsdoc",
      "typescript",

      "php",
      "go",
      "rust",
    },
  },
}

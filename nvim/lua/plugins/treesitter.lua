return {
  "nvim-treesitter/nvim-treesitter",
  version = false, -- last release is way too old and doesn't work on Windows
  build = ":TSUpdate",
  lazy = false, -- treesitter does not support lazy loading
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
      "prisma",

      "php",
      "go",
      "rust",
    },
  },
}

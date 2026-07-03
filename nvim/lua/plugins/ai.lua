return {
  "zbirenbaum/copilot.lua",
  lazy = false,
  priority = 1000,
  config = function()
    require("copilot").setup({
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = "<Tab>", -- Tab で提案を受け入れる
        },
      },
      panel = { enabled = false },
      server_opts_overrides = {
        trace = "verbose",
        cmd = {
          vim.fn.stdpath("data") .. "/mason/bin/copilot-language-server",
          "--stdio",
        },
        -- copilot はファイル編集ごとにインクリメンタル同期を送るが、
        -- Neovim 0.12.x ではバッファ追跡がズレて sync.lua:195 の
        -- assert が落ちる。フル同期に切り替えて回避する。
        flags = {
          allow_incremental_sync = false,
        },
        settings = {
          advanced = {
            listCount = 10,
            inlineSuggestCount = 3,
          },
        },
      },
      filetypes = {
        yaml = true,
        markdown = true,
        help = false,
        gitcommit = true,
        gitrebase = true,
        hgcommit = false,
        svn = false,
        cvs = false,
        ["."] = false,
        ["*"] = true,
      },
    })
  end,
}

return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false,
  opts = {
    provider = "claude",
    behaviour = {
      -- 自動提案を無効にする
      auto_suggestions = false,
      -- ハイライトグループを自動設定する
      auto_set_highlight_group = true,
      -- キーマップを自動設定する
      auto_set_keymaps = true,
      -- 生成後の差分を自動適用する
      auto_apply_diff_after_generation = true,
      -- クリップボードからのペーストをサポートする
      support_paste_from_clipboard = true,
    },
    windows = {
      -- サイドバーの位置
      position = "right",
      -- サイドバーの幅
      width = 30,
      sidebar_header = {
        -- ヘッダーのテキスト配置
        align = "center",
        -- 角を丸くしない
        rounded = false,
      },
      ask = {
        -- フローティングウィンドウを使用
        floating = true,
        -- 起動時にインサートモードに入る
        start_insert = true,
        -- ウィンドウの境界線を丸くする
        border = "rounded"
      }
    },
    -- providers-setting
    ollama = {
      endpoint = "http://localhost:11434",
      model = "gemma3",
      timeout = 30000,
      temperature = 0,
      max_completion_tokens = 8192,
    },
    claude = {
      model = "claude-3-5-sonnet-20241022",
      max_tokens = 8000,
    },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "echasnovski/mini.pick", -- for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua", -- for file_selector provider fzf
    "echasnovski/mini.icons",
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}

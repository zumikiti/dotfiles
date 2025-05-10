return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false,
  opts = {
    provider = "copilot",
    -- 共通のシステムプロンプト設定
    system_prompt = [[
    あなたはプロフェッショナルなコーディングアシスタントです。
    ユーザーのコードに関する質問に答えたり、コードの生成、修正、説明、デバッグのサポートを行います。
    回答は分かりやすく、簡潔にまとめてください。
    コードを示す際は、必ず Markdown のコードブロックを使用してください。
    ユーザーからの指示に忠実に従い、親切かつ丁寧に対応します。
    言語固有の慣習やベストプラクティスに従い、効率的なコードを提案してください。
    エラーメッセージの解析や問題解決においては、根本的な原因を特定し具体的な解決策を示してください。
    日本語で回答してください。
    ]],
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
        floating = false,
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
      model = "claude-3-7-sonnet-20250219",
      timeout = 30000,
      max_tokens = 8000,
    },
    copilot = {
      enabled = true,
      endpoint = "https://api.githubcopilot.com",
      model = "claude-3.7-sonnet",
      timeout = 30000,
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
      "zbirenbaum/copilot.lua",
      lazy = false,
      priority = 1000,
      config = function()
        require("copilot").setup {
          suggestion = { enabled = false },
          panel = { enabled = false },
          server_opts_overrides = {
            trace = "verbose",
            cmd = {
              vim.fn.expand("~/.config/nvim/copilot/bin/copilot-language-server"),
              "--stdio"
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
        }
      end,
    },
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

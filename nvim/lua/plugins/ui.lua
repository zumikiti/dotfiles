return {
  -- タブラインの表示
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = "nvim-tree/nvim-web-devicons",
    keys = {
      { "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
      { "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
    },
    opts = {
      options = {
        mode = "tabs",
        -- separator_style = "slant",
        show_buffer_close_icons = false,
        show_close_icon = false,
      },
    },
  },

  -- インデントガイドライン
  {
    "shellRaining/hlchunk.nvim",
    event = { "UIEnter" },
    config = function()
      require("hlchunk").setup({
        chunk = {
          enable = true,
          use_treesitter = true,
          chars = {
            horizontal_line = "━",
            vertical_line = "┃",
            left_top = "┏",
            left_bottom = "┗",
            right_arrow = "━",
          },
        },
        blank = {
          enable = true,
        },
        line_num = {
          enable = true,
          use_treesitter = true,
        },
      })
    end,
  },

  -- コマンドライン・メッセージ・通知のUI強化
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      notify = {
        enabled = true,
        view = "notify",
      },
      views = {
        cmdline_popup = {
          position = {
            row = "40%",
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
        },
        popupmenu = {
          relative = "editor",
          position = {
            row = "40%",
            col = "50%",
          },
          size = {
            width = 60,
            height = 10,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
        },
      },
    },
  },

  -- status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    init = function()
      require("lualine").setup()
    end,
  },
}

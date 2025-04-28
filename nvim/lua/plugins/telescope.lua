return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  keys = {
    { 'ff' , "<cmd>Telescope git_files <cr>",              desc = "Gitファイルを検索" },
    { 'fa' , "<cmd>Telescope find_files hidden=true <cr>", desc = "すべてのファイルを検索" },
    { 'fw' , "<cmd>Telescope live_grep <cr>",              desc = "テキスト検索" },
    { 'fz' , "<cmd>Telescope grep_string <cr>",            desc = "カーソル位置の単語を検索" },
    { 'fb' , "<cmd>Telescope buffers <cr>",                desc = "バッファ一覧" },
    { 'ft' , "<cmd>Telescope treesitter <cr>",             desc = "クラスのシンボル一覧（型/変数/メソッド）" },
    { 'fo' , "<cmd>Telescope oldfiles <cr>",               desc = "ファイル履歴" },
    { 'fc' , "<cmd>Telescope git_bcommits <cr>",           desc = "現在のファイルのコミット履歴" },
    { 'fh' , "<cmd>Telescope help_tags <cr>" },
  },
  config = function()
    local telescope = require('telescope')

    telescope.setup {
      defaults = {
        mappings = {
          i = {
            ["<esc>"] = require("telescope.actions").close,
          },
        },

        layout_config = {
          horizontal = {
            preview_width = 0.55,
            results_width = 0.8,
          },
          width = 0.85,
          height = 0.80,
          preview_cutoff = 120,
        },
      },

      extensions = {
        fzf = {
          fuzzy = true, -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true, -- override the file sorter
          case_mode = "smart_case", -- or "ignore_case" or "respect_case"
          -- the default case_mode is "smart_case"
        },
      },

      pickers = {
        grep_string = {
          search = "",
          only_sort_text = false,
        },
      },
    }

    -- Load fzf extension
    telescope.load_extension("fzf")
  end,
}

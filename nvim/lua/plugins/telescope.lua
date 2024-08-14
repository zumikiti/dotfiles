return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  keys = {
    { 'ff' , "<cmd>Telescope find_files find_command=rg,--files,--hidden,--glob,!*.git <cr>" },
    { 'fw' , "<cmd>Telescope live_grep <cr>" },
    { 'fz' , "<cmd>Telescope grep_string <cr>" },
    { 'fb' , "<cmd>Telescope buffers <cr>" },
    { 'fgc', "<cmd>Telescope git_bcommits <cr>" },
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

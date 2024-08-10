return {
  'fatih/vim-go',
  event = "VimEnter",
  build = ":GoUpdateBinaries",
  init = function ()
    -- vim-go syntax highlighting
    vim.g.go_highlight_types = 1
    vim.g.go_highlight_fields = 1
    vim.g.go_highlight_functions = 1
    vim.g.go_highlight_function_calls = 1
    vim.g.go_highlight_operators = 1
    vim.g.go_highlight_extra_types = 1
    vim.g.go_highlight_build_constraints = 1
    vim.g.go_highlight_generate_tags = 1
  end
}

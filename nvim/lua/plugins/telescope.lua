return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    { 'ff', "<cmd>Telescope find_files<cr>" },
    { 'fg', "<cmd>Telescope live_grep<cr>" },
    { 'fb', "<cmd>Telescope buffers<cr>" },
    { 'fh', "<cmd>Telescope help_tags<cr>" },
  }
}

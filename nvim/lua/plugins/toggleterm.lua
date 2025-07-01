return {
  'akinsho/toggleterm.nvim',
  version = "*",
  opts = {
    size = 20,
    open_mapping = [[<c-\>]],
    hide_numbers = true,
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
    direction = 'float',
    close_on_exit = true,
    shell = vim.o.shell,
    float_opts = {
      border = 'curved',
      winblend = 0,
      highlights = {
        border = "Normal",
        background = "Normal",
      },
      width = function()
        return math.floor(vim.o.columns * 0.9)
      end,
      height = function()
        return math.floor(vim.o.lines * 0.9)
      end,
    },
  },
  keys = {
    -- 基本的なトグル操作
    { '<leader>tt', '<cmd>ToggleTerm<cr>', desc = 'Toggle terminal' },
    { '<leader>tf', '<cmd>ToggleTerm direction=float<cr>', desc = 'Toggle floating terminal' },
    { '<leader>th', '<cmd>ToggleTerm direction=horizontal<cr>', desc = 'Toggle horizontal terminal' },
    { '<leader>tv', '<cmd>ToggleTerm direction=vertical size=80<cr>', desc = 'Toggle vertical terminal' },
    { '<leader>ta', '<cmd>ToggleTermToggleAll<cr>', desc = 'Toggle all terminals' },
    
    -- 番号指定でターミナルを開く
    { '<leader>t1', '<cmd>1ToggleTerm<cr>', desc = 'Toggle terminal 1' },
    { '<leader>t2', '<cmd>2ToggleTerm<cr>', desc = 'Toggle terminal 2' },
    { '<leader>t3', '<cmd>3ToggleTerm<cr>', desc = 'Toggle terminal 3' },
    
    -- 特殊なターミナル
    { '<leader>tg', function() 
        local Terminal = require('toggleterm.terminal').Terminal
        local lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float" })
        lazygit:toggle()
      end, desc = 'Open lazygit' },
    { '<leader>tn', function()
        local Terminal = require('toggleterm.terminal').Terminal
        local node = Terminal:new({ cmd = "node", hidden = true, direction = "float" })
        node:toggle()
      end, desc = 'Open Node.js REPL' },
  },
  config = function(_, opts)
    require('toggleterm').setup(opts)
    
    -- ターミナルモード内でのキーマッピング
    function _G.set_terminal_keymaps()
      local opts = {buffer = 0}
      vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
      vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
      vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
      vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
    end

    -- ターミナルバッファでキーマッピングを設定
    vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
  end
}

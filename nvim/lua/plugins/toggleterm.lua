return {
  'akinsho/toggleterm.nvim',
  version = "*",

  ----------------------------------------------------------------------
  -- 既存の設定をそのまま活かしています
  ----------------------------------------------------------------------
  opts = {
    size = 80,
    open_mapping = [[<c-\>]], -- Ctrl+\ でデフォルトターミナルを開く
    hide_numbers = true,
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true, -- ターミナル内でマッピングを有効にする
    persist_size = true,
    direction = 'float', -- デフォルトはフローティング
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

  ----------------------------------------------------------------------
  -- ここでカスタムターミナルの定義と、ターミナル内キーマップを設定
  ----------------------------------------------------------------------
  config = function(_, opts)
    -- デフォルト設定を適用
    require('toggleterm').setup(opts)

    -- カスタムターミナルを一度だけ定義し、グローバル変数に格納
    local Terminal = require('toggleterm.terminal').Terminal
    _G.tig_term = Terminal:new({
      cmd = "tig",
      hidden = true,
      direction = "float",
      on_open = function(_) vim.cmd("startinsert!") end,
    })

    -- ターミナルモードに入った時のキーマッピング
    function _G.set_terminal_keymaps()
      local t_opts = { buffer = 0 } -- 現在のバッファにのみマッピング
      vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], t_opts)
      vim.keymap.set('t', 'jk', [[<C-\><C-n>]], t_opts)
      vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], t_opts)
      vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], t_opts)
      vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], t_opts)
      vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], t_opts)
    end
    vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
  end,

  ----------------------------------------------------------------------
  -- ここにすべてのキーマッピングを集約
  ----------------------------------------------------------------------
  keys = {
    -- 基本的なターミナル操作
    { '<leader>tt', '<cmd>ToggleTerm<cr>', desc = 'Toggle terminal' },
    { '<leader>tf', '<cmd>ToggleTerm direction=float<cr>', desc = 'Terminal (Float)' },
    { '<leader>th', '<cmd>ToggleTerm direction=horizontal<cr>', desc = 'Terminal (Horizontal)' },
    { '<leader>tv', '<cmd>ToggleTerm direction=vertical<cr>', desc = 'Terminal (Vertical)' },

    -- カスタムターミナルのトグル (効率化済み)
    { 'tig', function() _G.tig_term:toggle() end, desc = 'tig' },

    -- 番号指定ターミナル
    { '<leader>t1', '<cmd>1ToggleTerm<cr>', desc = 'Terminal 1' },
    { '<leader>t2', '<cmd>2ToggleTerm<cr>', desc = 'Terminal 2' },
  },
}

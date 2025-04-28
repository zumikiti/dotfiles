return {
  'numToStr/Comment.nvim',
  version = "*", -- 最新のタグを使用
  opts = {
    -- ノーマルモードのキーマップ
    toggler = {
      ---Line-comment toggle keymap
      line = ',,',
      ---Block-comment toggle keymap
      block = '<leader>,',
    },
    ---LHS of operator-pending mappings in NORMAL and VISUAL mode
    opleader = {
      ---Line-comment keymap
      line = ',,',
      ---Block-comment keymap
      block = '<leader>,',
    },
    mappings = {
      ---Extra mapping; `gco`, `gcO`, `gcA`
      extra = false,
    },
  },
  init = function()
    require('Comment').setup()
  end,
}


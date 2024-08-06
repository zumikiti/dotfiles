-- 画面分割系
vim.api.nvim_set_keymap('n', 'sj', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'sk', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'sl', '<C-w>l', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'sh', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'ss', ':<C-u>sp<CR><C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'sv', ':<C-u>vs<CR><C-w>l', { noremap = true, silent = true })

-- タブの操作
-- 新規タブを開く
vim.api.nvim_set_keymap('n', 'st', ':tablast | tabnew<CR>', { noremap = true, silent = true })
-- Tab で次のタブに移動
vim.api.nvim_set_keymap('n', '<Tab>', ':tabnext<CR>', { noremap = true, silent = true })
-- Shift + Tab で前のタブに移動
vim.api.nvim_set_keymap('n', '<S-Tab>', ':tabprevious<CR>', { noremap = true, silent = true })
-- 閉じる
vim.api.nvim_set_keymap('n', 'sq', ':tabclose<CR>', { noremap = true, silent = true })
-- バッファを閉じる
vim.api.nvim_set_keymap('n', 'sQ', ':bd<CR>', { noremap = true, silent = true })

-- tig を開く
vim.api.nvim_set_keymap('n', 'tig', ':FloatermNew tig<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'fn', ':FloatermNew fish<CR>', { noremap = true, silent = true })
vim.g.floaterm_width = 0.9
vim.g.floaterm_height = 0.9
vim.g.floaterm_autoclose = 2

vim.api.nvim_set_keymap('n', 'QQ', ':q<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'WQ', ':wq<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'WW', ':w<CR>', { noremap = true, silent = true })

-- xで削除した時はヤンクしない
vim.api.nvim_set_keymap('v', 'x', '"_x', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'x', '"_x', { noremap = true, silent = true })

-- 折り返し時に表示行単位での移動できるようにする
vim.api.nvim_set_keymap('n', 'j', 'gj', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'k', 'gk', { noremap = true, silent = true })

-- ESC連打でハイライト解除
vim.api.nvim_set_keymap('n', '<Esc><Esc>', ':nohlsearch<CR><Esc>', { noremap = true, silent = true })

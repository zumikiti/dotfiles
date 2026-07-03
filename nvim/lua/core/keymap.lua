local api = vim.api

-- 画面分割系
api.nvim_set_keymap("n", "ss", ":<C-u>sp<CR><C-w>j", { noremap = true, silent = true })
api.nvim_set_keymap("n", "sv", ":<C-u>vs<CR><C-w>l", { noremap = true, silent = true })

-- タブの操作
-- 新規タブを開く
api.nvim_set_keymap("n", "st", ":tablast | tabnew<CR>", { noremap = true, silent = true })
-- 閉じる
api.nvim_set_keymap("n", "sq", ":tabclose<CR>", { noremap = true, silent = true })
-- バッファを閉じる
api.nvim_set_keymap("n", "sQ", ":bd<CR>", { noremap = true, silent = true })

-- ペイン 移動
api.nvim_set_keymap("n", "sj", "<C-w>j", { noremap = true, silent = true })
api.nvim_set_keymap("n", "sk", "<C-w>k", { noremap = true, silent = true })
api.nvim_set_keymap("n", "sl", "<C-w>l", { noremap = true, silent = true })
api.nvim_set_keymap("n", "sh", "<C-w>h", { noremap = true, silent = true })

-- ペインサイズ変更
api.nvim_set_keymap("n", "<C-j>", "20<C-w>-", { noremap = true, silent = true })
api.nvim_set_keymap("n", "<C-k>", "20<C-w>+", { noremap = true, silent = true })

api.nvim_set_keymap("n", "QQ", ":q<CR>", { noremap = true, silent = true })
api.nvim_set_keymap("n", "WQ", ":wq<CR>", { noremap = true, silent = true })
api.nvim_set_keymap("n", "WW", ":w<CR>", { noremap = true, silent = true })

-- xで削除した時はヤンクしない
api.nvim_set_keymap("v", "x", '"_x', { noremap = true, silent = true })
api.nvim_set_keymap("n", "x", '"_x', { noremap = true, silent = true })

-- 折り返し時に表示行単位での移動できるようにする
api.nvim_set_keymap("n", "j", "gj", { noremap = true, silent = true })
api.nvim_set_keymap("n", "k", "gk", { noremap = true, silent = true })

-- ESC連打でハイライト解除
api.nvim_set_keymap("n", "<Esc><Esc>", ":nohlsearch<CR><Esc>", { noremap = true, silent = true })

-- 括弧の補完
api.nvim_set_keymap("i", "{<CR>", "{}<Left><CR><ESC><S-o>", { noremap = true, silent = true })
api.nvim_set_keymap("i", "[<CR>", "[]<Left><CR><ESC><S-o>", { noremap = true, silent = true })
api.nvim_set_keymap("i", "(<CR>", "()<Left><CR><ESC><S-o>", { noremap = true, silent = true })

-- クオーテーションの補完
api.nvim_set_keymap("i", "'", "''<Left>", { noremap = true, silent = true })
api.nvim_set_keymap("i", '"', '""<Left>', { noremap = true, silent = true })

-- コメントの切り替え (Neovim 0.10+ 標準のコメント機能を利用)
-- 標準の gcc/gc/gbc/gb へリマップするため noremap=false にする
-- ,, : 行コメントのトグル (ノーマルは現在行、ビジュアルは選択範囲)
api.nvim_set_keymap("n", ",,", "gcc", { noremap = false, silent = true })
api.nvim_set_keymap("x", ",,", "gc", { noremap = false, silent = true })
-- <leader>, : ブロックコメントのトグル
api.nvim_set_keymap("n", "<leader>,", "gbc", { noremap = false, silent = true })
api.nvim_set_keymap("x", "<leader>,", "gb", { noremap = false, silent = true })

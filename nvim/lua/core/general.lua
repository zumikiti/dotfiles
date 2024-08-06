-- シェルを指定
if vim.fn.has('mac') == 1 then
  -- mac の場合
  vim.opt.shell = '/bin/zsh'
else
  -- linux の場合
  vim.opt.shell = '/usr/bin/bash'
end

vim.opt.synmaxcol = 320

-- .ts ファイルを開くとシンタックスが無効になる事象回避設定
-- https://github.com/fatih/vim-go/issues/3171
vim.opt.re = 0

-- setting
-- 文字コードをUFT-8に設定
vim.opt.encoding = 'utf-8'
vim.opt.ma = true
vim.opt.fenc = 'utf-8'
-- バックアップファイルを作らない
vim.opt.backup = false
-- スワップファイルを作らない
vim.opt.swapfile = false
-- 編集中のファイルが変更されたら自動で読み直す
vim.opt.autoread = true
-- バッファが編集中でもその他のファイルを開けるように
vim.opt.hidden = true
-- 入力中のコマンドをステータスに表示する
vim.opt.showcmd = true

-- ヤンクをクリップボードへ引き継ぐ
if vim.fn.has('mac') == 1 then
  -- mac の場合
  vim.opt.clipboard:append('unnamed')
else
  -- linux の場合
  -- sudo apt install xclip も必要
  vim.opt.clipboard = 'unnamedplus'
end

-- 挿入モードでバックスペース削除を有効
vim.opt.backspace = 'indent,eol,start'

-- 見た目系
-- 行番号を表示
vim.opt.number = true
-- 現在の行を強調表示
vim.opt.cursorline = true
-- 列を強調表示
vim.opt.cursorcolumn = true
-- 行末の1文字先までカーソルを移動できるように
vim.opt.virtualedit = 'onemore'
-- インデントはスマートインデント
vim.opt.smartindent = true
-- ビープ音を可視化
vim.opt.visualbell = true
-- 括弧入力時の対応する括弧を表示
vim.opt.showmatch = true
-- ステータスラインを常に表示
vim.opt.laststatus = 2
-- コマンドラインの補完
vim.opt.wildmode = 'list:longest'
-- シンタックスハイライトの有効化
vim.cmd('syntax enable')
-- 行数を相対的に表示
vim.opt.relativenumber = true

-- Tab系
-- 不可視文字を可視化(タブが「▸-」と表示される)
vim.opt.list = true
vim.opt.listchars = { tab = '▸-' }
-- Tab文字を半角スペースにする
vim.opt.expandtab = true
-- 行頭以外のTab文字の表示幅（スペースいくつ分）
vim.opt.tabstop = 2
-- 行頭でのTab文字の表示幅
vim.opt.shiftwidth = 2

-- 検索系
-- 検索文字列が小文字の場合は大文字小文字を区別なく検索する
vim.opt.ignorecase = true
-- 検索文字列に大文字が含まれている場合は区別して検索する
vim.opt.smartcase = true
-- 検索文字列入力時に順次対象文字列にヒットさせる
vim.opt.incsearch = true
-- 検索時に最後まで行ったら最初に戻る
vim.opt.wrapscan = true
-- 検索語をハイライト表示
vim.opt.hlsearch = true

-- 括弧の補完
vim.api.nvim_set_keymap('i', '{<CR>', '{}<Left><CR><ESC><S-o>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '[<CR>', '[]<Left><CR><ESC><S-o>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '(<CR>', '()<Left><CR><ESC><S-o>', { noremap = true, silent = true })

-- クオーテーションの補完
vim.api.nvim_set_keymap('i', "'", "''<Left>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '"', '""<Left>', { noremap = true, silent = true })

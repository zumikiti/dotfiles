local opt = vim.opt
-- シェルを指定
if vim.fn.has("mac") == 1 then
  -- mac の場合
  opt.shell = "/bin/zsh"
else
  -- linux の場合
  opt.shell = "/usr/bin/bash"
end

opt.synmaxcol = 320

-- .ts ファイルを開くとシンタックスが無効になる事象回避設定
-- https://github.com/fatih/vim-go/issues/3171
opt.re = 0

-- setting
-- 文字コードをUFT-8に設定
opt.encoding = "utf-8"
opt.ma = true
opt.fenc = "utf-8"
-- バックアップファイルを作らない
opt.backup = false
-- スワップファイルを作らない
opt.swapfile = false
-- 編集中のファイルが変更されたら自動で読み直す
opt.autoread = true
-- バッファが編集中でもその他のファイルを開けるように
opt.hidden = true
-- 入力中のコマンドをステータスに表示する
opt.showcmd = true

-- ヤンクをクリップボードへ引き継ぐ
if vim.fn.has("mac") == 1 then
  -- mac の場合
  opt.clipboard:append("unnamed")
else
  -- linux の場合
  opt.clipboard = "unnamedplus"
  -- herdr など OSC52 対応ターミナル / 多重化環境や SSH 越しでも
  -- ヤンクをローカルのクリップボードへ送れるようにする
  -- (Neovim 0.10+ 標準の OSC52 プロバイダを利用。xclip 等は不要)
  local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
  if ok then
    -- ペーストは OSC52 で端末へ問い合わせず、nvim 自身のレジスタ（直近ヤンク）
    -- から返す。OSC52 の読み取りは herdr など多重化環境で応答が返らず
    -- 「Waiting for OSC 52 response」で固まるため。コピーは OSC52 のまま。
    local function paste()
      return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
    end
    vim.g.clipboard = {
      name = "OSC 52",
      copy = {
        ["+"] = osc52.copy("+"),
        ["*"] = osc52.copy("*"),
      },
      paste = {
        ["+"] = paste,
        ["*"] = paste,
      },
    }
  end
end

-- 挿入モードでバックスペース削除を有効
opt.backspace = "indent,eol,start"

-- 見た目系
-- 行番号を表示
opt.number = true
-- 現在の行を強調表示
opt.cursorline = false
-- 列を強調表示
opt.cursorcolumn = false
-- 行末の1文字先までカーソルを移動できるように
opt.virtualedit = "onemore"
-- インデントはスマートインデント
opt.smartindent = true
-- ビープ音を可視化
opt.visualbell = true
-- 括弧入力時の対応する括弧を表示
opt.showmatch = true
-- ステータスラインを常に表示
opt.laststatus = 2
-- コマンドラインの補完
opt.wildmode = "list:longest"
-- シンタックスハイライトの有効化
vim.cmd("syntax enable")
-- 行数を相対的に表示
opt.relativenumber = true

-- Tab系
-- 不可視文字を可視化(タブが「▸-」と表示される)
opt.list = true
opt.listchars = { tab = "▸-" }
-- Tab文字を半角スペースにする
opt.expandtab = true
-- 行頭以外のTab文字の表示幅（スペースいくつ分）
opt.tabstop = 2
-- 行頭でのTab文字の表示幅
opt.shiftwidth = 2

-- 検索系
-- 検索文字列が小文字の場合は大文字小文字を区別なく検索する
opt.ignorecase = true
-- 検索文字列に大文字が含まれている場合は区別して検索する
opt.smartcase = true
-- 検索文字列入力時に順次対象文字列にヒットさせる
opt.incsearch = true
-- 検索時に最後まで行ったら最初に戻る
opt.wrapscan = true
-- 検索語をハイライト表示
opt.hlsearch = true

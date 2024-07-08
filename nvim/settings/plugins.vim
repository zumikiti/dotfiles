"plugin
call plug#begin('~/.config/nvim/plugged')

Plug 'nanotech/jellybeans.vim'
Plug 'altercation/vim-colors-solarized'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'

"nerdtree
Plug 'preservim/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'shougo/vimfiler.vim'
Plug 'shougo/unite.vim'

Plug 'simeji/winresizer'

"置換用
Plug 'mg979/vim-visual-multi', {'branch': 'master'}

Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }
Plug 'dhruvasagar/vim-table-mode'

Plug 'sheerun/vim-polyglot'

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.x' }

"スペルチェック
Plug 'kamykn/spelunker.vim'
Plug 'kamykn/popup-menu.nvim'

"vim 内にウィンドウ出す
Plug 'voldikss/vim-floaterm'

"非同期lintツール
Plug 'dense-analysis/ale'

"インデントみやすく
Plug 'nathanaelkane/vim-indent-guides'

"git 操作
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

"言語系設定
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'nsf/gocode', { 'rtp': 'vim', 'do': '~/.config/nvim/plugged/gocode/vim/symlink.sh' }

Plug 'neoclide/coc.nvim', {'branch': 'release'}

"php 用
Plug 'vim-scripts/gtags.vim'
Plug 'vim-scripts/taglist.vim'
Plug 'phpactor/phpactor', {'for': 'php', 'branch': 'master', 'do': 'composer install --no-dev -o'}

Plug 'posva/vim-vue'
"
"プロジェクトの editorconfig お読むやつ
Plug 'editorconfig/editorconfig-vim'

"sqlのフォーマッター
Plug 'mattn/vim-sqlfmt'

"htmlタグを ul>li*3 などで作れるやつ
Plug 'mattn/emmet-vim'

Plug 'rust-lang/rust.vim'

call plug#end()

source ~/.config/nvim/settings/plugins/theme.vim
source ~/.config/nvim/settings/plugins/airline.vim
source ~/.config/nvim/settings/plugins/nredtree.vim
source ~/.config/nvim/settings/plugins/fugitive.vim

source ~/.config/nvim/settings/plugins/telescope.vim

source ~/.config/nvim/settings/plugins/go.vim

source ~/.config/nvim/settings/plugins/php.vim
# Installation (for Mac)

## set symbolic links
```sh
mkdir -p ~/.config/nvim
ln -s ~/dotfiles/nvim/init.lua ~/.config/nvim/init.lua
ln -s ~/dotfiles/nvim/lua ~/.config/nvim/lua
ln -s ~/dotfiles/.tigrc ~/.tigrc
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
```

## install & set karabiner
1. download & install

https://karabiner-elements.pqrs.org/

2. set karabiner.json

```sh
rm ~/.config/karabiner/karabiner.json
ln -s ~/dotfiles/karabiner.json ~/.config/karabiner/karabiner.json
```

## install homebrew
```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## install fish
```sh
brew install fish

# install fnm && node
brew install fnm

fish

# install fisher
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher

# install ripgrep (use fzf.vim)
brew install ripgrep

# replace config.fish
cd ~/.config/fish
mv ./config.fish ./config.fish.bak
ln -s ~/dotfiles/config.fish (pwd)/config.fish

# install OMP
cd ~/.config/fish
brew install jandedobbeleer/oh-my-posh/oh-my-posh
ln -s ~/dotfiles/posh/themes ./posh-themes
```

## install vim 
### Alacritty
1. download Alacritty

```sh
brew install alacritty
```

または、公式からDL
https://alacritty.org/index.html

2. download Hack Nerd Font

```sh
brew tap homebrew/cask-fonts
brew install --cask font-hack-nerd-font
```

3. set alacritty.toml

```sh
cd ~/dotfiles
ln -s ~/dotfiles/alacritty ~/.config/alacritty
```

4. Alacritty 起動

### nvim install plugins (lazy)
nvim を起動すると、自動でlazyでプラグインのインストールが始まる。

## install tmux
```sh
brew install tmux

tmux

# install tmux plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# press `C-s + I` in tmux
```

## install tig
```sh
brew install tig
```

## 開発 (CI / Lint / Format)

[Devbox](https://www.jetify.com/devbox) を使ってローカルで CI と同等のチェックを実行できます。

```sh
# Devbox のインストール（未インストールの場合）
curl -fsSL https://get.jetify.com/devbox | bash

# Lint (luacheck)
devbox run lint

# Format チェック (stylua)
devbox run format:check

# Format 自動修正
devbox run format

# Lint + Format チェック（CI と同等）
devbox run ci
```

## Claude Code の設定
```sh
# Claude Code の設定ファイルをシンボリックリンクで配置
ln -s ~/dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -s ~/dotfiles/claude/commands ~/.claude/commands

# Claude Code がインストールされていない場合は公式ガイドに従ってインストール
# https://docs.anthropic.com/en/docs/claude-code
```

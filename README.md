# Installation (for Mac)

## set symbolic links
```sh
mkdir -p ~/.config/nvim
ln -s ~/dotfiles/nvim/init.lua ~/.config/nvim/
ln -s ~/dotfiles/nvim/lua ~/.config/nvim/
ln -s ~/dotfiles/.tigrc ~/
ln -s ~/dotfiles/.tmux.conf ~/
```

## install & set karabiner
1. download & install

https://karabiner-elements.pqrs.org/

2. set karabiner.json

```sh
rm ~/.config/karabiner/karabiner.json
ln -s ~/dotfiles/karabiner.json ~/.config/karabiner/
```

## install flox
```sh
# first-wave CLI tools are defined in .flox/env/manifest.toml
flox activate -d ~/dotfiles
```
Linux では `flox activate` 時に `hook.on-activate` が `~/.profile` に管理ブロックを書き込み、以後 bash の対話ログインで自動的に `flox activate -d ~/dotfiles` して fish に入る（activate に失敗したらメッセージを出して bash のまま）。macOS では自動 activate しないので、シェルごとに `flox activate -d ~/dotfiles` する。

## install fish
```sh
# install fnm && node
brew install fnm

fish

# Linux ではログインし直すと ~/.profile 経由で dotfiles の flox 環境に入り fish が起動する

# replace config.fish
cd ~/.config/fish
mv ./config.fish ./config.fish.bak
ln -s ~/dotfiles/fish/config.fish ./
ln -s ~/dotfiles/fish/fish_plugins ./

# OMP theme files are tracked in this repo
cd ~/.config/fish
ln -s ~/dotfiles/fish/posh-themes ./
```

## install fisher plugins
fisher のプラグインは `fish/fish_plugins` に commit SHA で固定して管理する（[ADR 0002](docs/adr/0002-pin-fisher-plugins.md)）。

```sh
# pinned plugin list を symlink で配置
cd ~/.config/fish
ln -s ~/dotfiles/fish/fish_plugins ./fish_plugins

# fisher 本体を fish_plugins に記載した固定 SHA から bootstrap
set -l fisher_sha (string split '@' (string match -r '^jorgebucaran/fisher@.*' < ./fish_plugins))[2]
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/$fisher_sha/functions/fisher.fish | source

# fish_plugins に記載された固定バージョンを一括インストール
fisher update
```

> SHA の更新は Renovate の PR で提案され、digest 更新（GitHub Actions の浮動メジャータグ `v4` 等、および fisher プラグイン）は CI 成功後に Renovate が自動マージする（手で `fish/fish_plugins` を編集してもよい）。マージ後にローカルで `fisher update` を実行すると、固定した SHA が反映される。

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
tmux プラグインは TPM をやめ、flox の `[install]`（`tmuxPlugins.*`）で固定管理する。
`.tmux.conf` 末尾の `run-shell` 群が `$FLOX_ENV` 配下のプラグインを直接読み込むため、
`flox activate` 済みの環境で tmux を起動すれば自動で適用される（`C-s + I` は不要）。

```sh
# ログイン（~/.profile 経由で flox activate 済みの fish）した後に tmux を起動するだけ
tmux
```

## install tig
```sh
# flox activate 済みのシェルで tig を使える
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
ln -s ~/dotfiles/claude/CLAUDE.md ~/.claude/
ln -s ~/dotfiles/claude/skills ~/.claude/

# Claude Code がインストールされていない場合は公式ガイドに従ってインストール
# https://docs.anthropic.com/en/docs/claude-code
```

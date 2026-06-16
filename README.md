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
`fish` にログインしたときは `fish/config.fish` で自動的に `flox activate -d ~/dotfiles` される。

## install fish
```sh
# install fnm && node
brew install fnm

fish

# fish にログインし直すと dotfiles の flox 環境が有効になる

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

> 更新は Manual Update Policy に従い、`fish/fish_plugins` の SHA を編集してから `fisher update` を実行し、変更をコミットする。

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
# fish にログイン（= flox activate 済み）した後に tmux を起動するだけ
tmux
```

## install tig
```sh
fish にログインした後に tig を使える
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

## cocoindex-code (ccc) — ローカルコード検索
AST ベースのセマンティックコード検索。Docker コンテナで隔離して動かす。
イメージは digest 固定、`--network none` で送信を物理遮断、ローカル埋め込みで
コードを外に出さない（定義は `cocoindex/docker-compose.yml`）。

### セットアップ
```sh
cd ~/dotfiles/cocoindex

# 機種ごとの projects 絶対パスを .env に設定（.env は git 管理外）
cp .env.example .env
#   Mac 上 OrbStack: COCOINDEX_PROJECTS_DIR=/mnt/mac/Users/<user>/projects
#   実機 Ubuntu    : COCOINDEX_PROJECTS_DIR=/home/<user>/projects

# 初回のみ: volume 作成・設定 seed・モデル取得（ここだけネット使用）
./bootstrap.sh

# 起動（再起動後も自動復帰。更新は docker compose pull && up -d）
docker compose up -d
```

### fish に ccc ラッパーを追加
```fish
# fish の alias は $argv を自動付与するため、関数で定義する
function ccc
    docker exec -it -e COCOINDEX_CODE_HOST_CWD="$PWD" cocoindex-code ccc $argv
end
```

### 使い方（`$COCOINDEX_PROJECTS_DIR` 配下の repo で）
```sh
cd <repo>
ccc init      # 初回のみ（.cocoindex_code/ は自動で .gitignore される）
ccc index     # 索引の構築・更新
ccc search "クエリ"
```

### Claude Code から使う（MCP・機種ごとに一度）
```sh
claude mcp add cocoindex-code --scope user -- \
  sh -c 'exec docker exec -i -e COCOINDEX_CODE_HOST_CWD="$PWD" cocoindex-code ccc mcp'
```
`init` + `index` 済みの repo 内で Claude Code を起動すれば自動で検索が効く。

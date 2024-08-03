# Installation (for Mac)

## set symbolic links
```sh
mkdir -p ~/.config/nvim
ln -s ~/dotfiles/nvim/init.vim ~/.config/nvim/init.vim
ln -s ~/dotfiles/nvim/settings ~/.config/nvim/settings
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

fish

# install fisher && node
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
fisher install jorgebucaran/nvm.fish
nvm install lts

# install starship
cd ~/dotfiles
brew install starship
ln -s (pwd)/starship.toml ~/.config/starship.toml

# install ripgrep (use fzf.vim)
brew install ripgrep

# replace config.fish
cd ~/.config/fish
mv ./config.fish ./config.fish.bak
ln -s ~/dotfiles/config.fish (pwd)/config.fish
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

### vim-plugin
```sh
ln -s (pwd)/coc-settings.json ~/.config/nvim/coc-settings.json

curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

nvim ~/.config/nvim/init.vim

# :PlugInInstall
```

## install tmux
```sh
brew install tmux

tmux

# install tmux plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# press `C-s + I` in tmux
```

### install tig
```sh
brew install tig
```

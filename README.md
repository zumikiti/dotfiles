# Installation (for Mac)

## set symbolic links
```sh
ln -s dotfiles/.vimrc ~/.vimrc
ln -s dotfiles/.tigrc ~/.tigrc
ln -s dotfiles/.tmux.conf ~/.tmux.conf
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

# install fisher
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher

# install node
fisher install jorgebucaran/nvm.fish
nvm install lts

# install theme
fisher install oh-my-fish/theme-bobthefish 

# install ripgrep (use fzf.vim)
brew install ripgrep

# replace config.fish
cd ~/.config/fish
mv ./config.fish ./config.fish.bak
ln -s ~/dotfiles/config.fish (pwd)/config.fish
```

## install vim 
### iTerm2
1. download iTerm2

https://iterm2.com/index.html

2. download Hack Nerd Font

```sh
brew tap homebrew/cask-fonts
brew install --cask font-hack-nerd-font
```

3. set Hack Nerd Font

iTerm2 > config > Profiles > Font

### vim-plugin
```sh
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim ~/.vimrc

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

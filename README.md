# Installation (for Mac)

## set symbolic links
```sh
cd dotfiles
ln -l .vimrc ~/.vimrc
ln -l .tigrc ~/.tigrc
ln -l .tmux.conf ~/.tmux.conf
```

## install homebrew
```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## install fish
```sh
brew install fish

# install fisher
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher

# install node
fisher install jorgebucaran/nvm.fish
nvm i --lts
```

## install vim 
### iTerm2
1. download iTerm2

https://iterm2.com/index.html

2. download Hack Nerd Font

https://www.nerdfonts.com/font-downloads

3. set Hack Nerd Font

iTerm2 > config > Profiles > Font

### vim-plugin
```sh
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim ~/.vimrc

# :PluginInstall
```

## install tmux
```sh
brew install tmux

tmux

# install tmux plugins
# press `C-s + I` in tmux
```

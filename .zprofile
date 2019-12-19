export PATH="$PATH:/Users/higashiizumi/.config/composer/vendor/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm

function homestead() {
    ( cd ~/Homestead && vagrant $* )
}

alias phpunit='vendor/bin/phpunit'
alias gf='git fetch'
alias pull='git pull'
alias push='git push'
alias gs='git status'
alias lint='composer lint'

alias le='less'
alias ll='ls -al'


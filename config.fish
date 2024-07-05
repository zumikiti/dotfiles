if status is-interactive
    # Commands to run in interactive sessions can go here
end

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
set --export --prepend PATH "$HOME/.rd/bin"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

### set node
nvm use lts

### MY FUNCTIONS
# lsd
function ll --wraps=ls --wraps='lsd -al' --description 'alias ll=lsd -al'
  lsd -al $argv; 
end

# docker
function dc --wraps=docker-compose --description 'alias dc docker-compose'
  docker compose $argv; 
end

function dcc --wraps='dc -f docker-compose.custom.yml' --description 'alias dcc=dc -f docker-compose.custom.yml'
  dc -f docker-compose.custom.yml $argv; 
end

# git
function gf --wraps='git fetch -p' --description 'alias gf=git fetch -p'
  git fetch -p $argv; 
end

function gs --wraps='git switch' --description 'alias gs=git switch'
  git switch $argv; 
end

function pull --description 'alias pull=git pull'
  git pull $argv; 
end

function push --description 'alias push=git push'
  git push $argv; 
end

function stash --description 'alias stash=git stash'
  git stash $argv;
end

function pop --description 'alias pop=git stash pop'
  git stash pop $argv;
end

function glog --description 'alias git log --oneline --decorate --graph --all'
  git log --oneline --decorate --graph --all
end

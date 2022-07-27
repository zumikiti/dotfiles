function gf --wraps='git fetch -p' --description 'alias gf=git fetch -p'
  git fetch -p $argv; 
end

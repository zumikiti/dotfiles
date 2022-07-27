function ll --wraps=ls --wraps='lsd -al' --description 'alias ll=lsd -al'
  lsd -al $argv; 
end

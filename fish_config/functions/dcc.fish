function dcc --wraps='dc -f docker-compose.custom.yml' --description 'alias dcc=dc -f docker-compose.custom.yml'
  dc -f docker-compose.custom.yml $argv; 
end

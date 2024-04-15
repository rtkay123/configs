function la --wraps=ls --wraps='eza -alh --group-directories-first --git' --wraps='exa -alh --icons --group-directories-first --git' --description 'alias la exa -alh --icons --group-directories-first --git'
  eza -alh --icons --group-directories-first --git --colour always $argv; 
end

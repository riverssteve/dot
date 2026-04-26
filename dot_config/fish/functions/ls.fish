function ls --wraps='eza -lh --group-directories-first --icons=auto' --description 'alias ls=eza'
    eza -lh --group-directories-first --icons=auto $argv
end

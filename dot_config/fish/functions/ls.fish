function ls --wraps='eza -lh --group-directories-first --icons=auto' --description 'alias ls=eza'
    if command -q eza
        eza -lh --group-directories-first --icons=auto $argv
    else
        command ls $argv
    end
end

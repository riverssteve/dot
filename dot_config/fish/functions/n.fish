function n --wraps=nvim --description 'open nvim, defaulting to current directory'
    if test (count $argv) -eq 0
        nvim .
    else
        nvim $argv
    end
end

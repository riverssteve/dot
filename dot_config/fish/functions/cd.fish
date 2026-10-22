function cd --wraps=z --description 'alias cd=z'
    if functions -q z
        z $argv
    else
        builtin cd $argv
    end
end

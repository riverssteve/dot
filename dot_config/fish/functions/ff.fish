function ff --description 'fzf with syntax-highlighted preview'
    set -l bat_cmd
    if command -q bat
        set bat_cmd bat
    else if command -q batcat
        set bat_cmd batcat
    end

    if test -n "$bat_cmd"
        fzf --preview "$bat_cmd --style=numbers --color=always {}" $argv
    else
        fzf $argv
    end
end

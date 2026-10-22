function gco
    set -l branch (git branch --format='%(refname:short)' | fzf --height=20% --reverse --info=inline)
    if test -n "$branch"
        git checkout "$branch"
    end
end

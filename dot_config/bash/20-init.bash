if command -v mise >/dev/null 2>&1; then eval "$(mise activate bash)"; fi
if command -v direnv >/dev/null 2>&1; then eval "$(direnv hook bash)"; fi
if command -v zoxide >/dev/null 2>&1; then eval "$(zoxide init bash)"; fi
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
else
    PS1='\u@\h:\w\$ '
fi
# fzf --bash needs fzf 0.48+; older versions (e.g. Debian apt) skip this.
if command -v fzf >/dev/null 2>&1 && fzf_init="$(fzf --bash 2>/dev/null)"; then
    eval "$fzf_init"
fi
unset fzf_init
if command -v atuin >/dev/null 2>&1; then eval "$(atuin init bash)"; fi

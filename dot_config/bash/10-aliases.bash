if command -v eza >/dev/null 2>&1; then
    alias ls='eza -lh --group-directories-first --icons=auto'
    alias lt='eza --tree --level=2 --long --icons --git'
    alias lta='lt -a'
fi
alias lsa='ls -a'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
    alias bat='batcat'
fi
if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
    alias fd='fdfind'
fi

n() { if [ "$#" -eq 0 ]; then nvim .; else nvim "$@"; fi; }
ff() {
    if command -v bat >/dev/null 2>&1; then
        fzf --preview 'bat --style=numbers --color=always {}' "$@"
    elif command -v batcat >/dev/null 2>&1; then
        fzf --preview 'batcat --style=numbers --color=always {}' "$@"
    else
        fzf "$@"
    fi
}
alias g='git'
alias d='docker'
alias lzg='lazygit'
alias lzd='lazydocker'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress='tar -xzf'
webm2mp4() {
    local input_file="$1"
    ffmpeg -i "$input_file" -c:v libx264 -preset slow -crf 22 -c:a aac -b:a 192k "${input_file%.webm}.mp4"
}

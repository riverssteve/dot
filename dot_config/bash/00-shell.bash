for brew_path in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$brew_path" ]; then
        eval "$("$brew_path" shellenv)"
        break
    fi
done
unset brew_path

export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$HOME/.cargo/bin:$PATH"
export EDITOR=nvim
export VISUAL="$EDITOR"
export SUDO_EDITOR="$EDITOR"
export PROJECTS="$HOME/code"
if [ -t 0 ]; then
    GPG_TTY=$(tty)
    export GPG_TTY
fi

shopt -s histappend
HISTCONTROL=ignoreboth
HISTSIZE=32768
HISTFILESIZE="$HISTSIZE"

# Skip GDAL completions: 53 links to one slow script add ~1.5 s to startup
# (needs bash-completion@2)
# shellcheck disable=SC2034 # read by bash-completion
BASH_COMPLETION_COMPAT_IGNORE='gdal*|ogr*|sozip'
if [ -r /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif command -v brew >/dev/null 2>&1; then
    completion_file="$(brew --prefix)/etc/profile.d/bash_completion.sh"
    # shellcheck disable=SC1090
    if [ -r "$completion_file" ]; then . "$completion_file"; fi
    unset completion_file
fi

function gpgenv --description 'Execute a command in a subshell with decrypted Fish environment'
    if test (count $argv) -lt 2; or not test -f "$argv[1]"
        echo 'Usage: gpgenv <encrypted-fish-script> <command> [args...]' >&2
        return 1
    end
    set -l env_lines (gpg --decrypt -- "$argv[1]")
    or return 1
    set -l env_script (string join \n -- $env_lines)
    set -l cmd (string join ' ' -- (string escape -- $argv[2..-1]))
    fish -c "$env_script
$cmd"
end

function fd --description 'fd with Debian binary name support'
    if command -q fd
        command fd $argv
    else
        command fdfind $argv
    end
end

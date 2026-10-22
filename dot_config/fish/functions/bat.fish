function bat --description 'bat with Debian binary name support'
    if command -q bat
        command bat $argv
    else
        command batcat $argv
    end
end

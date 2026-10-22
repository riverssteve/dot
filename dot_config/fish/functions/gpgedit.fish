function gpgedit --description 'Edit a symmetrically encrypted file'
    if test (count $argv) -ne 1
        echo 'Usage: gpgedit <file>' >&2
        return 1
    end
    set -l file $argv[1]
    set -l tmpdir (mktemp -d)
    or return 1
    if test -f "$file"
        if not gpg --decrypt -- "$file" >"$tmpdir/plaintext"
            command rm -rf -- "$tmpdir"
            return 1
        end
    end
    set -l result 1
    if nvim "$tmpdir/plaintext"
        if gpg --symmetric --armor --output "$tmpdir/encrypted" -- "$tmpdir/plaintext"
            command mv -- "$tmpdir/encrypted" "$file"
            set result $status
        end
    end
    command rm -rf -- "$tmpdir"
    return $result
end

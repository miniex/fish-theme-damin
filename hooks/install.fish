# `omf remove` leaves ~/.config/fish/functions/fish_prompt.fish as a dangling symlink
# into our dir, which trips OMF's "Conflicting prompt setting" check on the next
# `omf theme <name>`. Drop it here so reinstall works clean.
set -l user_fp $HOME/.config/fish/functions/fish_prompt.fish
if test -L $user_fp
    set -l target (path resolve $user_fp)
    set -l self (path resolve $PWD)
    if string match -q -- "$self/*" "$target"
        command rm -f $user_fp
    end
end

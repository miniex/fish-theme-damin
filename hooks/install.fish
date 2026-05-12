# `omf remove` leaves ~/.config/fish/functions/fish_prompt.fish dangling; `omf install`
# revives it pointing into our dir while $OMF_CONFIG/theme says "default", which trips
# the next `omf theme <name>` conflict check. Drop the stale symlink so reinstall works.
set -l user_fp $HOME/.config/fish/functions/fish_prompt.fish
if test -L $user_fp
    set -l target (path resolve $user_fp)
    set -l self (path resolve $PWD)
    if string match -q -- "$self/*" "$target"
        command rm -f $user_fp
    end
end

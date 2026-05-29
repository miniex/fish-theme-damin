# flavor -> display name / description / theme (dark|light), derived from _damin_palette_table.
# field: name | desc | theme. without field -> 3 lines in that order.
# empty name signals "no .theme file" (terminal-*); unknown flavor -> empties, dark.
function _damin_palette_meta --argument-names flavor field
    set -l name
    set -l desc
    set -l theme dark
    set -l row (_damin_palette_row $flavor)
    if test -n "$row"
        set -l f (string split '|' -- $row)
        set theme $f[2]
        set name $f[3]
        set desc $f[4]
    end
    switch "$field"
        case name
            echo $name
        case desc
            echo $desc
        case theme
            echo $theme
        case '*'
            printf '%s\n%s\n%s\n' "$name" "$desc" "$theme"
    end
end

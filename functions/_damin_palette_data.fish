# 15 lines per flavor — the 14 colors (order in _damin_palette_table) + bg.
# bg empty for terminal-* (no fixed-hex preview). unknown flavor falls back to mocha.
function _damin_palette_data --argument-names flavor
    set -l row (_damin_palette_row $flavor)
    test -z "$row"; and set row (_damin_palette_row mocha)
    set -l f (string split '|' -- $row)
    printf '%s\n' (string split ' ' -- $f[6]) $f[7]
end

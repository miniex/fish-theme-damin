# palette -> "primary_hex secondary_hex", derived from _damin_palette_table.
# used by conf.d and the picker swatch. unknown flavor -> mocha (catppuccin) accents.
function _damin_palette_accents --argument-names flavor
    set -l row (_damin_palette_row $flavor)
    test -z "$row"; and set row (_damin_palette_row mocha)
    echo (string split '|' -- $row)[5]
end

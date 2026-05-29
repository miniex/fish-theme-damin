# the _damin_palette_table line for <flavor>, or empty if unknown.
function _damin_palette_row --argument-names flavor
    for line in (_damin_palette_table)
        if string match -q "$flavor|*" -- $line
            echo $line
            return
        end
    end
end

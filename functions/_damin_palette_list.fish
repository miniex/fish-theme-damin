# canonical flavor list, derived from _damin_palette_table.
# completion file keeps its own static copy for descriptions.
function _damin_palette_list
    for line in (_damin_palette_table)
        echo (string split -m1 '|' -- $line)[1]
    end
end

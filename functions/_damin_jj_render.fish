function _damin_jj_render
    set -l data (_damin_jj_compute)
    test (count $data) -lt 1; and return
    set -l name $data[1]
    echo -n -s $_damin_c_branch $name $_damin_c_normal

    if test "$theme_damin_jj_counts" = 1 -a (count $data) -ge 4
        set -l m $data[2]
        set -l a $data[3]
        set -l c $data[4]
        set -l counts_on 0
        test "$theme_damin_git_counts" = 1; and set counts_on 1
        set -l first 1
        if test $c -gt 0
            echo -n -s " " $_damin_c_err $theme_damin_glyph_conflict
            test $counts_on -eq 1; and echo -n "$c"
            echo -n -s $_damin_c_normal
            set first 0
        end
        _damin_git_part $m $theme_damin_glyph_modified $first $counts_on; and set first 0
        _damin_git_part $a $theme_damin_glyph_added $first $counts_on; and set first 0
        if test $first -eq 0
            echo -n -s $_damin_c_normal
        else
            echo -n -s " " $_damin_c_deco $theme_damin_glyph_clean $_damin_c_normal
        end
    else
        echo -n -s " " $_damin_c_deco $theme_damin_glyph_clean $_damin_c_normal
    end
end

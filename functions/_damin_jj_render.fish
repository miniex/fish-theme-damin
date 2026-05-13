function _damin_jj_render
    set -l name (_damin_jj_compute)
    test -z "$name"; and return
    echo -n -s $_damin_c_branch $name $_damin_c_normal " " $_damin_c_deco $theme_damin_glyph_clean $_damin_c_normal
end

function _damin_date_render
    set -l out
    if set -q theme_damin_date_timezone; and test -n "$theme_damin_date_timezone"
        set out (env TZ=$theme_damin_date_timezone date +"$theme_damin_date_format" 2>/dev/null)
    else
        set out (date +"$theme_damin_date_format" 2>/dev/null)
    end
    test -n "$out"; or return
    echo -n -s " " $_damin_c_sep $theme_damin_glyph_sep " " $_damin_c_dim "$out" $_damin_c_normal
end

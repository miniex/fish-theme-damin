function _damin_fossil_render
    test "$theme_damin_show_fossil" = 1; or return
    # SQLite-backed; no pure-fish path. One fork per prompt.
    type -q fossil; or return
    set -l branch (command fossil branch current 2>/dev/null | string trim)
    test -n "$branch"; or set branch '?'

    set -l hide 0
    if test "$theme_damin_hide_default_branch" = 1
        contains -- $branch $theme_damin_default_branches; and set hide 1
    end
    if test $hide = 0
        echo -n -s $_damin_c_branch $branch $_damin_c_normal
    end
    echo -n -s " " $_damin_c_deco $theme_damin_glyph_clean $_damin_c_normal
end

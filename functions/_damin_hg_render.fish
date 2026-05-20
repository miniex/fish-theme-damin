function _damin_hg_render
    test "$theme_damin_show_hg" = 1; or return
    test -n "$_damin_vcs_dir"; or return

    set -l branch_file "$_damin_vcs_dir/branch"
    set -l branch default
    if test -f $branch_file
        set -l line (command cat $branch_file 2>/dev/null)
        test -n "$line"; and set branch (string trim -- $line)
    end

    set -l hide 0
    if test "$theme_damin_hide_default_branch" = 1
        contains -- $branch $theme_damin_default_branches; and set hide 1
    end

    if test $hide = 0
        echo -n -s $_damin_c_branch $branch $_damin_c_normal
    end

    # 1 hg fork; `read -l` matches "first line non-empty" without a head fork.
    if test "$theme_damin_hg_dirty" = 1; and type -q hg
        if command hg status -q 2>/dev/null | read -l _line
            echo -n -s " " $_damin_c_meta $theme_damin_glyph_modified $_damin_c_normal
            return
        end
    end
    echo -n -s " " $_damin_c_deco $theme_damin_glyph_clean $_damin_c_normal
end

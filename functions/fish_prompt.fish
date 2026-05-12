function fish_prompt
    set -l last_status $status

    # 1 = render stub then advance, 2 = clear and render full. owning the clear
    # here keeps lifecycle independent of fish_right_prompt (user-overridable).
    switch "$_damin_in_transient"
        case 1
            echo -n -s " " $_damin_c_ok "$theme_damin_glyph_prompt " $_damin_c_normal
            set -g _damin_in_transient 2
            return
        case 2
            set -eg _damin_in_transient
    end

    _damin_context_render
    _damin_vcs_render
    _damin_jobs_render

    if test $last_status -eq 0
        echo -n -s " " $_damin_c_ok "$theme_damin_glyph_prompt " $_damin_c_normal
    else
        echo -n -s " " $_damin_c_err "$theme_damin_glyph_prompt " $_damin_c_normal
        test "$theme_damin_show_exit_code" = 1; and echo -n -s $_damin_c_exit "$last_status " $_damin_c_normal
    end
end

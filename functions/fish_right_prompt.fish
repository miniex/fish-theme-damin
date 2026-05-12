function fish_right_prompt
    if set -q _damin_in_transient
        set -e _damin_in_transient
        return
    end

    echo -n -s " " $_damin_c_deco "$theme_damin_glyph_cwd " $_damin_c_cwd (_damin_cwd_pretty) $_damin_c_normal

    _damin_lang_render
    _damin_env_render
    _damin_battery_render
    _damin_duration_render
end

function damin_set_palette --argument-names flavor
    set -l valid mocha frappe macchiato latte gruvbox gruvbox-light tokyonight rosepine nord dracula solarized solarized-light base16 base16-light zenburn colorblind terminal-dark terminal-light
    if contains -- "$flavor" --help -h
        _damin_help_block damin_set_palette 'switch theme_damin_palette + rewrite fish_color_* universals' \
            'damin_set_palette <flavor>' \
            -- \
            "flavors: $valid"
        return
    end
    if not contains -- $flavor $valid
        printf '%susage: damin_set_palette %s%s\n' \
            (set_color red) (string join '|' -- $valid) (set_color normal) >&2
        return 1
    end

    set -U theme_damin_palette $flavor
    # wipe fish_color_* and accent universals so the apply block re-fills them next load.
    for v in fish_color_normal fish_color_command fish_color_keyword fish_color_quote \
        fish_color_redirection fish_color_end fish_color_error fish_color_param \
        fish_color_comment fish_color_selection fish_color_search_match fish_color_operator \
        fish_color_escape fish_color_autosuggestion fish_color_cancel fish_color_option \
        fish_color_gray fish_color_status fish_color_cwd fish_color_user fish_color_host \
        fish_color_host_remote fish_pager_color_completion fish_pager_color_description \
        fish_pager_color_prefix fish_pager_color_progress \
        theme_damin_accent_primary theme_damin_accent_secondary
        set -e $v
    end

    source $__fish_config_dir/conf.d/damin.fish 2>/dev/null
    or source (status dirname)/../conf.d/damin.fish 2>/dev/null

    printf '  %s✿%s palette → %s%s%s. run `exec fish` to apply everywhere.\n' \
        (set_color E890B0 -o) (set_color normal) (set_color 98ABCC) $flavor (set_color normal)
end

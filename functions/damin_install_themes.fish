function damin_install_themes
    if contains -- "$argv[1]" --help -h
        _damin_help_block damin_install_themes 'write .theme files into ~/.config/fish/themes/' \
            damin_install_themes \
            -- \
            'preview / apply with `fish_config theme show`.'
        return
    end
    set -l dest "$__fish_config_dir/themes"
    mkdir -p $dest

    set -l installed
    for flavor in (_damin_palette_list)
        set -l data (_damin_palette_data $flavor)
        # terminal-* have no fixed-hex preview; skip.
        set -l bg $data[15]
        test -z "$bg"; and continue

        set -l name
        switch $flavor
            case mocha
                set name "Damin Mocha"
            case macchiato
                set name "Damin Macchiato"
            case frappe
                set name "Damin Frappe"
            case latte
                set name "Damin Latte"
            case gruvbox
                set name "Damin Gruvbox"
            case gruvbox-light
                set name "Damin Gruvbox Light"
            case tokyonight
                set name "Damin Tokyo Night"
            case rosepine
                set name "Damin Rose Pine"
            case nord
                set name "Damin Nord"
            case dracula
                set name "Damin Dracula"
            case solarized
                set name "Damin Solarized"
            case solarized-light
                set name "Damin Solarized Light"
            case base16
                set name "Damin Base16"
            case base16-light
                set name "Damin Base16 Light"
            case zenburn
                set name "Damin Zenburn"
            case colorblind
                set name "Damin Colorblind"
            case '*'
                continue
        end

        # p[1..14]: text blue mauve green pink peach red flamingo overlay1 surface0 maroon overlay0 yellow teal
        set -l p $data[1..14]
        set -l file "$dest/$name.theme"
        begin
            printf '# name: %s\n' $name
            printf '# url: https://github.com/miniex/fish-theme-damin\n'
            printf '# preferred_background: %s\n\n' $bg
            printf 'fish_color_normal %s\n' $p[1]
            printf 'fish_color_command %s\n' $p[2]
            printf 'fish_color_keyword %s\n' $p[3]
            printf 'fish_color_quote %s\n' $p[4]
            printf 'fish_color_redirection %s\n' $p[5]
            printf 'fish_color_end %s\n' $p[6]
            printf 'fish_color_error %s\n' $p[7]
            printf 'fish_color_param %s\n' $p[8]
            printf 'fish_color_comment %s\n' $p[9]
            printf 'fish_color_selection --background=%s\n' $p[10]
            printf 'fish_color_search_match --background=%s\n' $p[10]
            printf 'fish_color_operator %s\n' $p[5]
            printf 'fish_color_escape %s\n' $p[11]
            printf 'fish_color_autosuggestion %s\n' $p[12]
            printf 'fish_color_cancel %s\n' $p[7]
            printf 'fish_color_option %s\n' $p[4]
            printf 'fish_color_gray %s\n' $p[12]
            printf 'fish_color_status %s\n' $p[7]
            printf 'fish_color_cwd %s\n' $p[13]
            printf 'fish_color_user %s\n' $p[14]
            printf 'fish_color_host %s\n' $p[2]
            printf 'fish_color_host_remote %s\n' $p[4]
            printf 'fish_pager_color_completion %s\n' $p[1]
            printf 'fish_pager_color_description %s\n' $p[12]
            printf 'fish_pager_color_prefix %s\n' $p[5]
            printf 'fish_pager_color_progress %s\n' $p[12]
        end >$file
        set -a installed $name
    end

    set -l pink (set_color E890B0 -o)
    set -l blue (set_color 98ABCC)
    set -l norm (set_color normal)
    printf '  %s✿%s wrote %d theme(s) to %s%s%s:\n' $pink $norm (count $installed) $blue $dest $norm
    for t in $installed
        printf '    %s\n' $t
    end
    printf '\n  preview / apply with %sfish_config theme show%s.\n' $blue $norm
end

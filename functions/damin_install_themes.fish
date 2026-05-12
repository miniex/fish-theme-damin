function damin_install_themes
    set -l dest "$__fish_config_dir/themes"
    mkdir -p $dest

    set -l flavors mocha macchiato frappe latte
    set -l names "Damin Mocha" "Damin Macchiato" "Damin Frappe" "Damin Latte"
    set -l bgs 1e1e2e 24273a 303446 eff1f5

    set -l installed
    for i in (seq 4)
        set -l flavor $flavors[$i]
        set -l name $names[$i]
        set -l bg $bgs[$i]
        set -l p
        switch $flavor
            case mocha
                set p cdd6f4 89b4fa cba6f7 a6e3a1 f5c2e7 fab387 f38ba8 f2cdcd 7f849c 313244 eba0ac 6c7086 f9e2af 94e2d5
            case macchiato
                set p cad3f5 8aadf4 c6a0f6 a6da95 f5bde6 f5a97f ed8796 f0c6c6 8087a2 363a4f ee99a0 6e738d eed49f 8bd5ca
            case frappe
                set p c6d0f5 8caaee ca9ee6 a6d189 f4b8e4 ef9f76 e78284 eebebe 838ba7 414559 ea999c 737994 e5c890 81c8be
            case latte
                set p 4c4f69 1e66f5 8839ef 40a02b ea76cb fe640b d20f39 dd7878 8c8fa1 ccd0da e64553 9ca0b0 df8e1d 179299
        end
        # p indexes: 1=text 2=blue 3=mauve 4=green 5=pink 6=peach 7=red 8=flamingo 9=overlay1 10=surface0 11=maroon 12=overlay0 13=yellow 14=teal
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

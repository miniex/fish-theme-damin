function _damin_config_ask --argument-names question default_yes
    set -l hint '[y/N]'
    test "$default_yes" = 1; and set hint '[Y/n]'
    while true
        read -P "  $question $hint " -l ans
        switch (string lower -- $ans)
            case ''
                test "$default_yes" = 1; and echo 1; and return
                echo 0
                return
            case y yes
                echo 1
                return
            case n no
                echo 0
                return
            case '*'
                set -l dim (set_color --dim)
                printf '    %sanswer y or n%s\n' $dim (set_color normal)
        end
    end
end

function _damin_config_state --argument-names var
    set -l v
    set -q $var; and set v $$var
    test "$v" = 1; and echo on; or echo off
end

function _damin_config_pick_palette
    set -l choices mocha frappe macchiato latte gruvbox tokyonight rosepine nord dracula solarized solarized-light
    set -l current $theme_damin_palette
    set -l pink (set_color E890B0 -o)
    set -l blue (set_color 98ABCC)
    set -l dim (set_color --dim)
    set -l norm (set_color normal)
    printf '\n  %scolor palette%s\n' $pink $norm
    set -l i 1
    for c in $choices
        set -l marker " "
        set -l c_color $dim
        if test "$c" = "$current"
            set marker "*"
            set c_color $pink
        end
        printf '    %s%d.%s %s %s%s%s\n' $blue $i $norm $marker $c_color $c $norm
        set i (math $i + 1)
    end
    while true
        read -P "  pick [1-"(count $choices)"] (enter = keep $current): " -l ans
        if test -z "$ans"
            echo $current
            return
        end
        if string match -rq '^[0-9]+$' -- $ans
            if test $ans -ge 1 -a $ans -le (count $choices)
                echo $choices[$ans]
                return
            end
        end
        printf '    %sinvalid; pick a number or press enter%s\n' $dim $norm
    end
end

function damin_config
    if not isatty stdin
        echo "damin_config needs an interactive terminal" >&2
        return 1
    end

    set -l pink (set_color E890B0 -o)
    set -l blue (set_color 98ABCC)
    set -l dim (set_color --dim)
    set -l norm (set_color normal)

    printf '\n  %s✿ damin · setup%s\n\n' $pink $norm
    printf '  %swrites -U universals; run damin_help afterwards to see every value.%s\n\n' $dim $norm

    set -l qs \
        theme_damin_show_context 1 'context indicators (ssh / root / dkr / ctr)?' \
        theme_damin_show_aws 0 'AWS context (aws:profile@region)?' \
        theme_damin_show_gcp 0 'GCP context (gcp:project)?' \
        theme_damin_show_azure 0 'Azure context (az:subscription)?' \
        theme_damin_show_terraform 1 'Terraform workspace (tf:<workspace>)?' \
        theme_damin_show_pulumi 1 'Pulumi stack (pulumi:<stack>)?' \
        theme_damin_show_gh_pr 0 'GitHub PR badge (#42 next to branch, needs gh)?' \
        theme_damin_show_hg 0 'Mercurial (hg) support — branch from .hg/branch?' \
        theme_damin_hide_default_branch 0 'hide branch name when on main/master/trunk?' \
        theme_damin_show_lang_global 0 'show shell-active version manager (rbenv/pyenv/NVM) when no project pin?' \
        theme_damin_newline_prompt 0 'put the florette on its own line (multi-line prompt)?' \
        theme_damin_show_battery 0 'battery percent (laptops only)?' \
        theme_damin_show_vi_mode 1 'vi mode badge (only shown under vi keybindings)?' \
        theme_damin_notify_long_command 0 'desktop notification on long-running commands?' \
        theme_damin_ascii 0 'ASCII glyphs (only if font lacks ✿ ❥ ⇡ ⇣)?' \
        theme_damin_osc_integration 1 'OSC 7 + 133 shell integration?' \
        theme_damin_apply_colors 1 'apply palette to fish_color_* universals?'

    set -l results
    set -l i 1
    set -l n (count $qs)
    while test $i -le $n
        set -l var $qs[$i]
        set -l def $qs[(math $i + 1)]
        set -l q $qs[(math $i + 2)]
        set -l now (_damin_config_state $var)
        set -l label "$q $dim(now: $now)$norm"
        set -a results $var (_damin_config_ask "$label" $def)
        set i (math $i + 3)
    end

    set -l new_palette (_damin_config_pick_palette)

    echo
    printf '  %s✿ summary%s\n' $pink $norm
    set i 1
    while test $i -le (count $results)
        set -l var $results[$i]
        set -l val $results[(math $i + 1)]
        set -l display off
        test $val = 1; and set display on
        printf '  %s%-36s%s %s%s%s\n' $blue $var $norm $dim $display $norm
        set i (math $i + 2)
    end
    printf '  %s%-36s%s %s%s%s\n' $blue theme_damin_palette $norm $dim $new_palette $norm
    echo

    set -l apply (_damin_config_ask 'apply?' 1)
    if test $apply = 0
        printf '  %scanceled — nothing changed%s\n\n' $dim $norm
        return
    end

    set i 1
    while test $i -le (count $results)
        set -U $results[$i] $results[(math $i + 1)]
        set i (math $i + 2)
    end

    # route palette swap through damin_set_palette so universals get wiped properly.
    if test "$new_palette" != "$theme_damin_palette"
        damin_set_palette $new_palette >/dev/null
    end

    printf '\n  %sdone. exec fish to apply in this shell.%s\n\n' $pink $norm
end

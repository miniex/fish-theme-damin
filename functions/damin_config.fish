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
        theme_damin_show_gh_pr 0 'GitHub PR badge (#42 next to branch, needs gh)?' \
        theme_damin_show_battery 0 'battery percent (laptops only)?' \
        theme_damin_status_names 0 'name exit codes (130 → SIGINT)?' \
        theme_damin_notify_long_command 0 'desktop notification on long-running commands?' \
        theme_damin_ascii 0 'ASCII glyphs (only if font lacks ✿ ❥ ⇡ ⇣)?' \
        theme_damin_osc_integration 1 'OSC 7 + 133 shell integration?' \
        theme_damin_apply_colors 1 'apply Catppuccin Mocha palette?'

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

    printf '\n  %sdone. exec fish to apply in this shell.%s\n\n' $pink $norm
end

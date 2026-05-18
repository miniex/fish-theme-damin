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
    set -l choices mocha frappe macchiato latte gruvbox gruvbox-light tokyonight rosepine nord dracula solarized solarized-light base16 base16-light zenburn colorblind terminal-dark terminal-light
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

function _damin_config_print_help
    set -l pink (set_color E890B0 -o)
    set -l blue (set_color 98ABCC)
    set -l dim (set_color --dim)
    set -l norm (set_color normal)
    printf '\n  %s✿ damin_config%s — read/write theme_damin_* universals\n\n' $pink $norm
    printf '  usage:\n'
    printf '    %sdamin_config%s                       interactive wizard (default)\n' $blue $norm
    printf '    %sdamin_config wizard%s                same as above\n' $blue $norm
    printf '    %sdamin_config get [PATTERN]%s         print matching theme_damin_*\n' $blue $norm
    printf '    %sdamin_config set VAR VALUE...%s      set -U a theme_damin_* var\n' $blue $norm
    printf '    %sdamin_config reset [PATTERN]%s       unset matching universals (confirm)\n' $blue $norm
    printf '    %sdamin_config export%s                dump universals as fish script\n' $blue $norm
    printf '\n  %sexamples%s\n' $dim $norm
    printf '    damin_config get git\n'
    printf '    damin_config set theme_damin_show_jobs 0\n'
    printf '    damin_config set theme_damin_default_branches main master develop\n'
    printf '    damin_config export > ~/.config/fish/conf.d/my-damin.fish\n\n'
end

function _damin_config_get
    set -l pattern $argv[1]
    set -l c_name (set_color 98ABCC)
    set -l c_val (set_color E890B0)
    set -l c_dim (set_color --dim)
    set -l c_norm (set_color normal)
    set -l matched 0
    for v in (set --names | string match -r '^theme_damin_.*' | sort)
        if test -n "$pattern"
            string match -q "*$pattern*" -- $v; or continue
        end
        set matched (math $matched + 1)
        if set -q $v
            set -l val (string join ' ' -- $$v)
            printf '  %s%-40s%s %s%s%s\n' $c_name $v $c_norm $c_val "$val" $c_norm
        else
            printf '  %s%-40s%s %s(unset)%s\n' $c_name $v $c_norm $c_dim $c_norm
        end
    end
    if test $matched -eq 0
        if test -n "$pattern"
            printf '  %sno matches for `%s`%s\n' $c_dim $pattern $c_norm >&2
        else
            printf '  %sno theme_damin_* variables defined%s\n' $c_dim $c_norm >&2
        end
        return 1
    end
end

function _damin_config_set
    if test (count $argv) -lt 2
        printf 'damin_config set: usage: damin_config set VAR VALUE...\n' >&2
        return 1
    end
    set -l var $argv[1]
    if not string match -q 'theme_damin_*' -- $var
        printf 'damin_config set: var must start with theme_damin_ (got: %s)\n' $var >&2
        return 1
    end
    set -U $var $argv[2..]
    printf '  %s%s%s = %s%s%s\n' \
        (set_color 98ABCC) $var (set_color normal) \
        (set_color E890B0) (string join ' ' -- $argv[2..]) (set_color normal)
end

function _damin_config_reset
    set -l pattern $argv[1]
    set -l matched
    for v in (set --names -U | string match -r '^theme_damin_.*' | sort)
        if test -n "$pattern"
            string match -q "*$pattern*" -- $v; or continue
        end
        set -a matched $v
    end
    if test (count $matched) -eq 0
        printf '  no universal theme_damin_* vars match\n' >&2
        return 1
    end
    printf '  will erase %d universal var(s):\n' (count $matched)
    for v in $matched
        printf '    %s\n' $v
    end
    read -P '  proceed? [y/N] ' -l ans
    switch (string lower -- $ans)
        case y yes
            for v in $matched
                set -eU $v
            end
            printf '  erased %d.\n' (count $matched)
        case '*'
            printf '  canceled.\n'
            return 1
    end
end

# conf.d globals shadow universals — `$$v` would read the global. parse `set --show` instead.
function _damin_read_universal --argument-names var
    set -l in_uni 0
    for line in (set --show $var 2>/dev/null)
        if string match -rq '^\$.+: set in .+ scope' -- $line
            string match -q '*universal scope*' -- $line; and set in_uni 1; or set in_uni 0
        else if test $in_uni = 1
            set -l m (string match -r '\|(.*)\|$' -- $line)
            test (count $m) -ge 2; and echo $m[2]
        end
    end
end

function _damin_config_export
    printf '# damin config — generated %s\n' (command date '+%Y-%m-%dT%H:%M:%S%z')
    printf '# source this file to restore theme_damin_* universals.\n\n'
    set -l found 0
    for v in (set --names -U | string match -r '^theme_damin_.*' | sort)
        set found 1
        set -l vals (_damin_read_universal $v | while read -l x; string escape -- $x; end)
        printf 'set -U %s %s\n' $v (string join ' ' -- $vals)
    end
    test $found -eq 0; and printf '# (no theme_damin_* universals set)\n'
end

function _damin_config_wizard
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
        theme_damin_show_fossil 0 'Fossil VCS support — branch via `fossil branch current` fork?' \
        theme_damin_hide_default_branch 0 'hide branch name when on main/master/trunk?' \
        theme_damin_show_lang_global 0 'show shell-active version manager (rbenv/pyenv/NVM) when no project pin?' \
        theme_damin_show_date 0 'right-prompt clock (theme_damin_date_format default %H:%M)?' \
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

function damin_config
    switch "$argv[1]"
        case --help -h help
            _damin_config_print_help
        case get
            _damin_config_get $argv[2..]
        case set
            _damin_config_set $argv[2..]
        case reset
            _damin_config_reset $argv[2..]
        case export
            _damin_config_export
        case '' wizard
            _damin_config_wizard
        case '*'
            printf 'damin_config: unknown subcommand: %s\n\n' "$argv[1]" >&2
            _damin_config_print_help >&2
            return 1
    end
end

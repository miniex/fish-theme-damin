set -q theme_damin_show_git; or set -g theme_damin_show_git 1
set -q theme_damin_show_jj; or set -g theme_damin_show_jj 1
set -q theme_damin_show_git_op; or set -g theme_damin_show_git_op 1
set -q theme_damin_show_context; or set -g theme_damin_show_context 1
set -q theme_damin_show_jobs; or set -g theme_damin_show_jobs 1
set -q theme_damin_show_env; or set -g theme_damin_show_env 1
set -q theme_damin_show_lang; or set -g theme_damin_show_lang 1
set -q theme_damin_show_battery; or set -g theme_damin_show_battery 0
set -q theme_damin_show_duration; or set -g theme_damin_show_duration 1
set -q theme_damin_show_exit_code; or set -g theme_damin_show_exit_code 1
set -q theme_damin_git_counts; or set -g theme_damin_git_counts 1
set -q theme_damin_transient; or set -g theme_damin_transient 1
set -q theme_damin_async_git; or set -g theme_damin_async_git 1
set -q theme_damin_async_lang; or set -g theme_damin_async_lang 1
set -q theme_damin_cwd_keep; or set -g theme_damin_cwd_keep 3
set -q theme_damin_cwd_short; or set -g theme_damin_cwd_short 4
set -q theme_damin_long_command_threshold; or set -g theme_damin_long_command_threshold 3000
set -q theme_damin_battery_threshold; or set -g theme_damin_battery_threshold 30
set -q theme_damin_apply_colors; or set -g theme_damin_apply_colors 1

if test "$theme_damin_apply_colors" = 1
    set -U fish_color_normal cdd6f4
    set -U fish_color_command 89b4fa
    set -U fish_color_keyword cba6f7
    set -U fish_color_quote a6e3a1
    set -U fish_color_redirection f5c2e7
    set -U fish_color_end fab387
    set -U fish_color_error f38ba8
    set -U fish_color_param f2cdcd
    set -U fish_color_comment 7f849c
    set -U fish_color_selection --background=313244
    set -U fish_color_search_match --background=313244
    set -U fish_color_operator f5c2e7
    set -U fish_color_escape eba0ac
    set -U fish_color_autosuggestion 6c7086
    set -U fish_color_cancel f38ba8
    set -U fish_color_option a6e3a1
    set -U fish_color_gray 6c7086
    set -U fish_color_status f38ba8
    set -U fish_color_cwd f9e2af
    set -U fish_color_user 94e2d5
    set -U fish_color_host 89b4fa
    set -U fish_color_host_remote a6e3a1
    set -U fish_pager_color_completion cdd6f4
    set -U fish_pager_color_description 6c7086
    set -U fish_pager_color_prefix f5c2e7
    set -U fish_pager_color_progress 6c7086
end

set -g _damin_c_normal (set_color normal)
set -g _damin_c_branch (set_color 98ABCC)
set -g _damin_c_meta (set_color E890B0)
set -g _damin_c_count (set_color E890B0 --dim)
set -g _damin_c_ok (set_color E890B0 -o)
set -g _damin_c_err (set_color red -o)
set -g _damin_c_exit (set_color red --dim)
set -g _damin_c_cwd (set_color 98ABCC)
set -g _damin_c_dim (set_color --dim)
set -g _damin_c_deco (set_color E890B0)
set -g _damin_c_sep (set_color E890B0 --dim)
set -g _damin_c_long (set_color E890B0 -o)

set -g _damin_vcs_pwd ""
set -g _damin_vcs_value ""
set -g _damin_lang_pwd ""
set -g _damin_lang_value ""
set -g _damin_battery_value ""
set -g _damin_battery_at 0
set -g _damin_pwd_key_pwd ""
set -g _damin_pwd_key_value ""

set -g _damin_cache_dir "$HOME/.cache/damin"
set -g _damin_is_root 0
test (id -u 2>/dev/null) = 0; and set -g _damin_is_root 1

function _damin_pwd_key
    if test "$_damin_pwd_key_pwd" != "$PWD"
        set -g _damin_pwd_key_pwd "$PWD"
        set -g _damin_pwd_key_value (string replace -a / % -- "$PWD")
    end
    echo $_damin_pwd_key_value
end

function _damin_cache_path --argument-names key
    echo "$_damin_cache_dir/"(_damin_pwd_key)"-$key"
end

function _damin_read_lines --argument-names file
    test -f $file; or return 1
    while read -l line
        printf '%s\n' "$line"
    end <$file
end

function _damin_cache_prune
    test -d $_damin_cache_dir; or return
    set -l marker "$_damin_cache_dir/.last-prune"
    if test -f $marker
        set -l mtime (command stat -c %Y $marker 2>/dev/null)
        test -z "$mtime"; and set mtime (command stat -f %m $marker 2>/dev/null)
        if string match -rq '^\d+$' -- "$mtime"
            test (math (date +%s) - $mtime) -lt 86400; and return
        end
    end
    command find $_damin_cache_dir -type f -mtime +7 -delete 2>/dev/null
    command touch $marker 2>/dev/null
end

_damin_cache_prune

function _damin_detect_vcs
    if test "$_damin_vcs_pwd" != "$PWD"
        set -g _damin_vcs_pwd "$PWD"
        set -l dir $PWD
        set -l levels 0
        set -l result ""
        while test "$dir" != / -a $levels -lt 16
            if test -d "$dir/.jj"
                set result jj
                break
            end
            if test -d "$dir/.git" -o -f "$dir/.git"
                set result git
                break
            end
            set dir (path dirname $dir)
            set levels (math $levels + 1)
        end
        set -g _damin_vcs_value $result
    end
    echo $_damin_vcs_value
end

function _damin_context_render
    test "$theme_damin_show_context" = 1; or return
    test -n "$SSH_CONNECTION"; and echo -n -s $_damin_c_dim ssh $_damin_c_normal " "
    test "$_damin_is_root" = 1; and echo -n -s $_damin_c_err root $_damin_c_normal " "
    if test -f /.dockerenv
        echo -n -s $_damin_c_dim dkr $_damin_c_normal " "
    else if test -f /run/.containerenv
        echo -n -s $_damin_c_dim ctr $_damin_c_normal " "
    end
    set -q KUBERNETES_SERVICE_HOST; and echo -n -s $_damin_c_dim k8s $_damin_c_normal " "
end

function _damin_jobs_render
    test "$theme_damin_show_jobs" = 1; or return
    set -l n (count (jobs -p 2>/dev/null))
    test $n -gt 0; or return
    echo -n -s " " $_damin_c_sep "·" " " $_damin_c_dim "&$n" $_damin_c_normal
end

function _damin_git_compute
    set -l info (command git rev-parse --is-inside-work-tree --git-dir --git-common-dir 2>/dev/null)
    test "$info[1]" = true; or return
    set -l git_dir $info[2]
    set -l git_common $info[3]

    set -l branch
    set -l oid
    set -l untracked 0
    set -l modified 0
    set -l staged 0
    set -l ahead 0
    set -l behind 0

    for line in (command git status --porcelain=v2 --branch 2>/dev/null)
        switch (string sub -l 1 -- "$line")
            case '?'
                set untracked (math $untracked + 1)
            case 1 2
                set -l xy (string sub -s 3 -l 2 -- "$line")
                test (string sub -s 1 -l 1 -- "$xy") != .; and set staged (math $staged + 1)
                test (string sub -s 2 -l 1 -- "$xy") != .; and set modified (math $modified + 1)
            case '#'
                set -l parts (string split ' ' -- "$line")
                switch $parts[2]
                    case branch.head
                        set branch $parts[3]
                    case branch.oid
                        set oid $parts[3]
                    case branch.ab
                        set ahead (string sub -s 2 -- $parts[3])
                        set behind (string sub -s 2 -- $parts[4])
                end
        end
    end

    test "$branch" = '(detached)'; and set branch (string sub -l 8 -- $oid)
    test -z "$branch"; and set branch '?'

    set -l stashed 0
    set -l stash_log "$git_common/logs/refs/stash"
    test -f $stash_log; and set stashed (command wc -l <$stash_log 2>/dev/null | string trim)
    test -z "$stashed"; and set stashed 0

    set -l op ""
    if test -d "$git_dir/rebase-merge" -o -d "$git_dir/rebase-apply"
        set op rebase
    else if test -f "$git_dir/MERGE_HEAD"
        set op merge
    else if test -f "$git_dir/CHERRY_PICK_HEAD"
        set op pick
    else if test -f "$git_dir/REVERT_HEAD"
        set op revert
    else if test -f "$git_dir/BISECT_LOG"
        set op bisect
    end

    printf '%s\n' "$branch" "$untracked" "$modified" "$staged" "$stashed" "$ahead" "$behind" "$op"
end

function _damin_write_cache --argument-names cache_file pwd
    mkdir -p (path dirname $cache_file) 2>/dev/null
    set -l tmp "$cache_file.tmp.$fish_pid"
    printf '%s\n' "$pwd" $argv[3..] >$tmp 2>/dev/null
    mv $tmp $cache_file 2>/dev/null
end

function _damin_postexec --on-event fish_postexec
    set -l cmd "$argv"
    if string match -qr '\b(git|jj|hub|gh)\b' -- $cmd
        if not string match -qr '\bgit\s+(status|log|diff|show|blame|ls-(files|tree)|cat-file|rev-(list|parse)|describe|name-rev|shortlog|whatchanged|reflog|grep|ls-remote|help|version)\b' -- $cmd
            command rm -f (_damin_cache_path git) 2>/dev/null
        end
    end
    if string match -qr '\b(nvm|fnm|asdf|mise|pyenv|rbenv|rustup|volta|conda)\b' -- $cmd
        command rm -f (_damin_cache_path lang) 2>/dev/null
    end
end

function _damin_git_part
    set -l count $argv[1]
    set -l symbol $argv[2]
    set -l first $argv[3]
    set -l counts_on $argv[4]

    test $count -gt 0; or return 1

    if test $first -eq 1
        echo -n -s " " $_damin_c_meta
    else
        echo -n " "
    end
    echo -n "$symbol"
    test $counts_on -eq 1; and echo -n -s $_damin_c_count "$count" $_damin_c_meta
    return 0
end

function _damin_git_render_data --argument-names branch u m s st a b op
    echo -n -s $_damin_c_branch $branch $_damin_c_normal
    test -n "$op"; and echo -n -s " " $_damin_c_exit "($op)" $_damin_c_normal

    set -l counts_on 0
    test "$theme_damin_git_counts" = 1; and set counts_on 1

    set -l first 1
    _damin_git_part $u '?' $first $counts_on; and set first 0
    _damin_git_part $st '$' $first $counts_on; and set first 0
    _damin_git_part $m '✗' $first $counts_on; and set first 0
    _damin_git_part $s '✓' $first $counts_on; and set first 0
    _damin_git_part $b '⇣' $first $counts_on; and set first 0
    _damin_git_part $a '⇡' $first $counts_on; and set first 0

    if test $first -eq 0
        echo -n -s $_damin_c_normal
    else if test -z "$op"
        echo -n -s " " $_damin_c_deco "✧" $_damin_c_normal
    end
end

function _damin_git_render
    if test "$theme_damin_async_git" != 1
        set -l data (_damin_git_compute)
        test -z "$data"; and return
        _damin_git_render_data $data
        return
    end

    set -l cache_file (_damin_cache_path git)
    set -l data

    if test -f $cache_file
        set -l lines (_damin_read_lines $cache_file)
        if test (count $lines) -ge 9 -a "$lines[1]" = "$PWD"
            set data $lines[2..9]
        end
    end

    if test -z "$data"
        set data (_damin_git_compute)
        test -n "$data"; and _damin_write_cache $cache_file "$PWD" $data
    end

    test -z "$data"; and return
    _damin_git_render_data $data
end

function _damin_jj_compute
    set -l info (command jj log -r @ --no-graph --no-pager --color=never --template 'bookmarks.join(",") ++ "|" ++ change_id.short()' 2>/dev/null)
    test -z "$info"; and return
    set -l parts (string split '|' -- $info)
    set -l bookmark $parts[1]
    set -l change $parts[2]
    test -n "$bookmark"; and echo $bookmark; or echo $change
end

function _damin_jj_render
    set -l name (_damin_jj_compute)
    test -z "$name"; and return
    echo -n -s $_damin_c_branch $name $_damin_c_normal " " $_damin_c_deco "✧" $_damin_c_normal
end

function _damin_vcs_render
    test "$theme_damin_show_git" = 1; or return
    set -l vcs (_damin_detect_vcs)
    switch $vcs
        case jj
            test "$theme_damin_show_jj" = 1; or return
            _damin_jj_render
        case git
            _damin_git_render
    end
end

function _damin_cwd_pretty
    set -l result (prompt_pwd --dir-length=$theme_damin_cwd_short --full-length-dirs=$theme_damin_cwd_keep 2>/dev/null)
    test -n "$result"; and echo $result; and return
    prompt_pwd
end

function _damin_lang_compute
    set -l dir $PWD
    set -l levels 0
    while test "$dir" != / -a $levels -lt 8
        if test -f "$dir/Cargo.toml"
            set -l v (command rustc --version 2>/dev/null | string match -gr '\d+\.\d+\.\d+' | head -1)
            test -n "$v"; and echo "rust:$v"; or echo rust
            return
        else if test -f "$dir/package.json"
            set -l v (command node --version 2>/dev/null | string sub -s 2)
            test -n "$v"; and echo "node:$v"; or echo node
            return
        else if test -f "$dir/go.mod"
            set -l v (command go env GOVERSION 2>/dev/null | string sub -s 3)
            test -n "$v"; and echo "go:$v"; or echo go
            return
        else if test -f "$dir/pyproject.toml" -o -f "$dir/setup.py" -o -f "$dir/requirements.txt"
            set -l v (command python3 --version 2>/dev/null | string match -gr '\d+\.\d+\.\d+' | head -1)
            test -n "$v"; and echo "py:$v"; or echo py
            return
        else if test -f "$dir/deno.json" -o -f "$dir/deno.jsonc"
            set -l v (command deno --version 2>/dev/null | string match -gr '\d+\.\d+\.\d+' | head -1)
            test -n "$v"; and echo "deno:$v"; or echo deno
            return
        end
        set dir (path dirname $dir)
        set levels (math $levels + 1)
    end
end

function _damin_lang_render
    test "$theme_damin_show_lang" = 1; or return

    set -l value

    if test "$theme_damin_async_lang" = 1
        set -l cache_file (_damin_cache_path lang)
        if test -f $cache_file
            set -l lines (_damin_read_lines $cache_file)
            if test (count $lines) -ge 2 -a "$lines[1]" = "$PWD"
                set value "$lines[2]"
            end
        end

        if test -z "$value" -a "$_damin_lang_pwd" != "$PWD"
            set value (_damin_lang_compute)
            set -g _damin_lang_pwd "$PWD"
            set -g _damin_lang_value "$value"
            _damin_write_cache $cache_file "$PWD" "$value"
        end
    else
        if test "$_damin_lang_pwd" != "$PWD"
            set -g _damin_lang_pwd "$PWD"
            set -g _damin_lang_value (_damin_lang_compute)
        end
        set value $_damin_lang_value
    end

    test -n "$value"; and echo -n -s " " $_damin_c_sep "·" " " $_damin_c_dim "$value" $_damin_c_normal
end

function _damin_env_render
    test "$theme_damin_show_env" = 1; or return
    set -l parts
    set -q VIRTUAL_ENV; and set -a parts (path basename $VIRTUAL_ENV)
    set -q CONDA_DEFAULT_ENV; and set -a parts $CONDA_DEFAULT_ENV
    set -q DIRENV_DIR; and set -a parts direnv
    test (count $parts) -eq 0; and return
    set -l joined (string join , -- $parts)
    echo -n -s " " $_damin_c_sep "·" " " $_damin_c_dim "($joined)" $_damin_c_normal
end

function _damin_battery_render
    test "$theme_damin_show_battery" = 1; or return
    set -l now (date +%s)
    if test (math $now - $_damin_battery_at) -ge 60
        set -g _damin_battery_at $now
        set -l pct
        switch (uname)
            case Darwin
                set pct (command pmset -g batt 2>/dev/null | string match -gr '(\d+)%')
                set pct $pct[1]
            case Linux
                for f in /sys/class/power_supply/BAT*/capacity
                    if test -f $f
                        set pct (command cat $f 2>/dev/null | string trim)
                        break
                    end
                end
            case FreeBSD OpenBSD NetBSD DragonFly
                set pct (command apm -l 2>/dev/null | string trim)
                if not string match -rq '^\d+$' -- "$pct"
                    set pct (command sysctl -n hw.acpi.battery.life 2>/dev/null | string trim)
                end
        end
        string match -rq '^\d+$' -- "$pct"; or set pct ""
        set -g _damin_battery_value "$pct"
    end
    set -l pct $_damin_battery_value
    test -z "$pct"; and return
    test $pct -gt $theme_damin_battery_threshold; and return
    set -l color $_damin_c_dim
    test $pct -le 10; and set color $_damin_c_err
    echo -n -s " " $_damin_c_sep "·" " " $color "$pct%" $_damin_c_normal
end

function _damin_duration_format
    set -l s (math $CMD_DURATION/1000)
    set -l m (math $s/60)
    if test $m -gt 1
        echo $m m
    else if test $s -gt 1
        echo $s s
    else
        echo $CMD_DURATION ms
    end
end

function _damin_duration_render
    test "$theme_damin_show_duration" = 1; or return
    set -l color $_damin_c_dim
    test $CMD_DURATION -gt $theme_damin_long_command_threshold; and set color $_damin_c_long
    echo -n -s " " $_damin_c_sep "·" " " $color (_damin_duration_format) $_damin_c_normal
end

function _damin_help_row --argument-names name default
    set -l val
    set -q $name; and set val $$name
    set -l val_color (set_color E890B0)
    test "$val" = "$default"; and set val_color (set_color --dim)
    printf '  %-38s %s%-8s%s %sdefault %s%s\n' \
        $name $val_color $val (set_color normal) (set_color --dim) $default (set_color normal)
end

function _damin_doctor_check
    set -l sym '✗'
    set -l col (set_color yellow)
    if test "$argv[2]" = ok
        set sym '✓'
        set col (set_color green)
    end
    printf '  %s%s%s %s%s%s\n' $col $sym (set_color normal) $argv[1] (set_color --dim) " $argv[3..]"(set_color normal)
end

function _damin_transient_enter
    if test "$theme_damin_transient" = 1
        set -g _damin_in_transient 1
        commandline -f repaint
    end
    commandline -f execute
end

bind \r _damin_transient_enter
bind \n _damin_transient_enter

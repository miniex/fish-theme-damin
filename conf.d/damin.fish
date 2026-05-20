set -g _damin_theme_file (status filename)
set -g _damin_async_core_file (path dirname $_damin_theme_file)/_damin_async_core.fish
# explicit source for dev workflows that bypass conf.d auto-load (tests etc.).
# idempotent — the auto-load already ran at fish startup.
source $_damin_async_core_file 2>/dev/null

# put functions/ on $fish_function_path for dev workflows (`source conf.d/damin.fish`).
# Fisher/OMF installs already register the dir; the contains-check makes this a no-op.
set -l _damin_functions (path dirname $_damin_theme_file)/../functions
test -d $_damin_functions; and not contains -- $_damin_functions $fish_function_path; and set -p fish_function_path $_damin_functions

# completions/ — OMF doesn't register this dir; push it onto $fish_complete_path.
set -l _damin_completions (path dirname $_damin_theme_file)/../completions
test -d $_damin_completions; and not contains -- $_damin_completions $fish_complete_path; and set -p fish_complete_path $_damin_completions

# tramp / dumb terminals — adjust defaults before the `set -q; or set` block below
# so user-explicit values still win.
set -l _damin_dumb 0
test "$TERM" = dumb; and set _damin_dumb 1
set -q INSIDE_EMACS; and test -n "$INSIDE_EMACS"; and set _damin_dumb 1
if test $_damin_dumb = 1
    set -q theme_damin_ascii; or set -g theme_damin_ascii 1
    set -q theme_damin_transient; or set -g theme_damin_transient 0
    set -q theme_damin_osc_integration; or set -g theme_damin_osc_integration 0
    set -q theme_damin_apply_colors; or set -g theme_damin_apply_colors 0
end

set -q theme_damin_show_context; or set -g theme_damin_show_context 1
# host/user: no | ssh | always. default_user: matching $USER suppressed.
set -q theme_damin_show_host; or set -g theme_damin_show_host ssh
set -q theme_damin_show_user; or set -g theme_damin_show_user ssh
set -q theme_damin_show_screen; or set -g theme_damin_show_screen 0
set -q theme_damin_show_sudo_user; or set -g theme_damin_show_sudo_user 0
set -q theme_damin_show_docker_machine; or set -g theme_damin_show_docker_machine 0
set -q theme_damin_show_aws; or set -g theme_damin_show_aws 0
set -q theme_damin_show_aws_region; or set -g theme_damin_show_aws_region 1
set -q theme_damin_show_gcp; or set -g theme_damin_show_gcp 0
set -q theme_damin_show_azure; or set -g theme_damin_show_azure 0
set -q theme_damin_show_k8s_context; or set -g theme_damin_show_k8s_context 1
set -q theme_damin_show_k8s_namespace; or set -g theme_damin_show_k8s_namespace 0
set -q theme_damin_show_git; or set -g theme_damin_show_git 1
set -q theme_damin_show_jj; or set -g theme_damin_show_jj 1
set -q theme_damin_show_hg; or set -g theme_damin_show_hg 0
set -q theme_damin_show_fossil; or set -g theme_damin_show_fossil 0
set -q theme_damin_show_git_op; or set -g theme_damin_show_git_op 1
set -q theme_damin_hide_default_branch; or set -g theme_damin_hide_default_branch 0
set -q theme_damin_default_branches; or set -g theme_damin_default_branches main master trunk
# 0 = no limit. >0 truncates long branch names with `…`.
set -q theme_damin_branch_max_len; or set -g theme_damin_branch_max_len 0
# cloud label truncation. per-segment max_len (>0) wins; else cloud_max_len applies.
set -q theme_damin_cloud_max_len; or set -g theme_damin_cloud_max_len 0
set -q theme_damin_k8s_max_len; or set -g theme_damin_k8s_max_len 0
set -q theme_damin_aws_max_len; or set -g theme_damin_aws_max_len 0
set -q theme_damin_gcp_max_len; or set -g theme_damin_gcp_max_len 0
set -q theme_damin_azure_max_len; or set -g theme_damin_azure_max_len 0
set -q theme_damin_show_gh_pr; or set -g theme_damin_show_gh_pr 0
set -q theme_damin_show_jobs; or set -g theme_damin_show_jobs 1
# show_exit_code: 0|off|hidden, 1|number (default), name, both.
set -q theme_damin_show_exit_code; or set -g theme_damin_show_exit_code number
set -q theme_damin_show_vi_mode; or set -g theme_damin_show_vi_mode 1

set -q theme_damin_show_lang; or set -g theme_damin_show_lang 1
set -q theme_damin_show_lang_global; or set -g theme_damin_show_lang_global 0
set -q theme_damin_show_env; or set -g theme_damin_show_env 1
set -q theme_damin_show_nix_name; or set -g theme_damin_show_nix_name 1
set -q theme_damin_show_terraform; or set -g theme_damin_show_terraform 1
set -q theme_damin_show_pulumi; or set -g theme_damin_show_pulumi 1
set -q theme_damin_show_battery; or set -g theme_damin_show_battery 0
set -q theme_damin_show_duration; or set -g theme_damin_show_duration 1
set -q theme_damin_show_date; or set -g theme_damin_show_date 0
set -q theme_damin_date_format; or set -g theme_damin_date_format '%H:%M'
# theme_damin_date_timezone — optional TZ override (e.g. UTC, America/Los_Angeles).

set -q theme_damin_git_counts; or set -g theme_damin_git_counts 1
set -q theme_damin_git_count_untracked; or set -g theme_damin_git_count_untracked 1
set -q theme_damin_transient; or set -g theme_damin_transient 1
set -q theme_damin_async_git; or set -g theme_damin_async_git 1
set -q theme_damin_async_lang; or set -g theme_damin_async_lang 1
set -q theme_damin_async_warmup; or set -g theme_damin_async_warmup 1
set -q theme_damin_async_repaint; or set -g theme_damin_async_repaint 0
set -q theme_damin_async_gh_pr; or set -g theme_damin_async_gh_pr 1
# IPC signal — override only if SIGUSR1 collides.
set -q theme_damin_async_signal; or set -g theme_damin_async_signal SIGUSR1
# kill bg subshell after N seconds; 0 = disabled. catches hung gh/k8s/aws.
set -q theme_damin_async_timeout; or set -g theme_damin_async_timeout 5
set -q theme_damin_osc_integration; or set -g theme_damin_osc_integration 1
set -q theme_damin_notify_long_command; or set -g theme_damin_notify_long_command 0
set -q theme_damin_apply_colors; or set -g theme_damin_apply_colors 1
set -q theme_damin_palette; or set -g theme_damin_palette mocha
# light/dark auto-swap — palette_light wins when $COLORFGBG bg slot ≥ 7.
if set -q theme_damin_palette_light; and test -n "$theme_damin_palette_light"; and set -q COLORFGBG
    set -l _damin_bg (string split ';' -- $COLORFGBG)[-1]
    string match -rq '^[0-9]+$' -- "$_damin_bg"; and test "$_damin_bg" -ge 7; and set -g theme_damin_palette $theme_damin_palette_light
end
set -q theme_damin_ascii; or set -g theme_damin_ascii 0
set -q theme_damin_newline_prompt; or set -g theme_damin_newline_prompt 0
# title: user = 0|1|ssh, path = 0|1|short, process = 0|1.
set -q theme_damin_title_show_user; or set -g theme_damin_title_show_user ssh
set -q theme_damin_title_show_path; or set -g theme_damin_title_show_path 1
set -q theme_damin_title_show_process; or set -g theme_damin_title_show_process 1

set -q theme_damin_cwd_keep; or set -g theme_damin_cwd_keep 3
set -q theme_damin_cwd_short; or set -g theme_damin_cwd_short 4
# project-relative path: inside a repo show `<project>/<rel>` instead of full cwd.
set -q theme_damin_show_project_parent; or set -g theme_damin_show_project_parent 1
set -q theme_damin_project_dir_length; or set -g theme_damin_project_dir_length 0
set -q theme_damin_long_command_threshold; or set -g theme_damin_long_command_threshold 3000
set -q theme_damin_battery_threshold; or set -g theme_damin_battery_threshold 30
set -q theme_damin_gh_pr_ttl; or set -g theme_damin_gh_pr_ttl 300
set -q theme_damin_notify_threshold; or set -g theme_damin_notify_threshold 30000

# transient flag is session-global only; drain any universal-scope leak.
set -qU _damin_in_transient; and set -eU _damin_in_transient
# legacy IPC token from pre-signal versions; persists in fish_variables.
set -qU _damin_async_repaint_token; and set -eU _damin_async_repaint_token

# glyphs (defaults flip when ascii=1; theme_damin_glyph_* overrides win)
set -l _ds_prompt ✿
set -l _ds_cwd ❥
set -l _ds_clean ✧
set -l _ds_modified ✗
set -l _ds_added ✓
set -l _ds_untracked '?'
set -l _ds_stashed '$'
set -l _ds_ahead ⇡
set -l _ds_behind ⇣
set -l _ds_sep ·
set -l _ds_conflict X

if test "$theme_damin_ascii" = 1
    set _ds_prompt '*'
    set _ds_cwd '>'
    set _ds_clean '~'
    set _ds_modified '!'
    set _ds_added '+'
    set _ds_ahead '^'
    set _ds_behind v
    set _ds_sep '|'
end

set -q theme_damin_glyph_prompt; or set -g theme_damin_glyph_prompt $_ds_prompt
set -q theme_damin_glyph_transient; or set -g theme_damin_glyph_transient $theme_damin_glyph_prompt
set -q theme_damin_glyph_cwd; or set -g theme_damin_glyph_cwd $_ds_cwd
set -q theme_damin_glyph_clean; or set -g theme_damin_glyph_clean $_ds_clean
set -q theme_damin_glyph_modified; or set -g theme_damin_glyph_modified $_ds_modified
set -q theme_damin_glyph_added; or set -g theme_damin_glyph_added $_ds_added
set -q theme_damin_glyph_untracked; or set -g theme_damin_glyph_untracked $_ds_untracked
set -q theme_damin_glyph_stashed; or set -g theme_damin_glyph_stashed $_ds_stashed
set -q theme_damin_glyph_ahead; or set -g theme_damin_glyph_ahead $_ds_ahead
set -q theme_damin_glyph_behind; or set -g theme_damin_glyph_behind $_ds_behind
set -q theme_damin_glyph_sep; or set -g theme_damin_glyph_sep $_ds_sep
set -q theme_damin_glyph_conflict; or set -g theme_damin_glyph_conflict $_ds_conflict

# colors via _damin_palette_data. damin_set_palette wipes fish_color_* + accents
# first because this block only fills unset universals.
if test "$theme_damin_apply_colors" = 1
    set -l _damin_pdata (_damin_palette_data "$theme_damin_palette")
    set -l text $_damin_pdata[1]
    set -l blue $_damin_pdata[2]
    set -l mauve $_damin_pdata[3]
    set -l green $_damin_pdata[4]
    set -l pink $_damin_pdata[5]
    set -l peach $_damin_pdata[6]
    set -l red $_damin_pdata[7]
    set -l flamingo $_damin_pdata[8]
    set -l overlay1 $_damin_pdata[9]
    set -l surface0 $_damin_pdata[10]
    set -l maroon $_damin_pdata[11]
    set -l overlay0 $_damin_pdata[12]
    set -l yellow $_damin_pdata[13]
    set -l teal $_damin_pdata[14]
    set -q fish_color_normal; or set -U fish_color_normal $text
    set -q fish_color_command; or set -U fish_color_command $blue
    set -q fish_color_keyword; or set -U fish_color_keyword $mauve
    set -q fish_color_quote; or set -U fish_color_quote $green
    set -q fish_color_redirection; or set -U fish_color_redirection $pink
    set -q fish_color_end; or set -U fish_color_end $peach
    set -q fish_color_error; or set -U fish_color_error $red
    set -q fish_color_param; or set -U fish_color_param $flamingo
    set -q fish_color_comment; or set -U fish_color_comment $overlay1
    set -q fish_color_selection; or set -U fish_color_selection --background=$surface0
    set -q fish_color_search_match; or set -U fish_color_search_match --background=$surface0
    set -q fish_color_operator; or set -U fish_color_operator $pink
    set -q fish_color_escape; or set -U fish_color_escape $maroon
    set -q fish_color_autosuggestion; or set -U fish_color_autosuggestion $overlay0
    set -q fish_color_cancel; or set -U fish_color_cancel $red
    set -q fish_color_option; or set -U fish_color_option $green
    set -q fish_color_gray; or set -U fish_color_gray $overlay0
    set -q fish_color_status; or set -U fish_color_status $red
    set -q fish_color_cwd; or set -U fish_color_cwd $yellow
    set -q fish_color_user; or set -U fish_color_user $teal
    set -q fish_color_host; or set -U fish_color_host $blue
    set -q fish_color_host_remote; or set -U fish_color_host_remote $green
    set -q fish_pager_color_completion; or set -U fish_pager_color_completion $text
    set -q fish_pager_color_description; or set -U fish_pager_color_description $overlay0
    set -q fish_pager_color_prefix; or set -U fish_pager_color_prefix $pink
    set -q fish_pager_color_progress; or set -U fish_pager_color_progress $overlay0
end

# brand accents via _damin_palette_accents (autoloaded from functions/).
set -l _damin_accent_parts (string split ' ' -- (_damin_palette_accents "$theme_damin_palette"))
set -l _damin_accent_primary $_damin_accent_parts[1]
set -l _damin_accent_secondary $_damin_accent_parts[2]
set -q theme_damin_accent_primary; or set -g theme_damin_accent_primary $_damin_accent_primary
set -q theme_damin_accent_secondary; or set -g theme_damin_accent_secondary $_damin_accent_secondary

# pre-computed color escapes (set_color is a fork; do it once at theme load).
set -g _damin_c_normal (set_color normal)
set -g _damin_c_branch (set_color $theme_damin_accent_primary)
set -g _damin_c_meta (set_color $theme_damin_accent_secondary)
set -g _damin_c_count (set_color $theme_damin_accent_secondary --dim)
set -g _damin_c_ok (set_color $theme_damin_accent_secondary -o)
set -g _damin_c_transient (set_color $theme_damin_accent_secondary --dim)
set -g _damin_c_err (set_color red -o)
set -g _damin_c_exit (set_color red --dim)
set -g _damin_c_cwd (set_color $theme_damin_accent_primary)
set -g _damin_c_dim (set_color --dim)
set -g _damin_c_deco (set_color $theme_damin_accent_secondary)
set -g _damin_c_sep (set_color $theme_damin_accent_secondary --dim)
set -g _damin_c_long (set_color $theme_damin_accent_secondary -o)

# user hook: damin_colors() runs after defaults to override _damin_c_*.
functions -q damin_colors; and damin_colors

set -g _damin_vcs_pwd ""
set -g _damin_vcs_value ""
set -g _damin_vcs_dir ""
set -g _damin_vcs_worktree ""
set -g _damin_lang_pwd ""
set -g _damin_lang_value ""
set -g _damin_git_cached_pwd ""
set -g _damin_git_cached_mt ""
set -g _damin_git_cached_data ""
set -g _damin_cwd_pwd ""
set -g _damin_cwd_value ""
set -g _damin_duration_ms ""
set -g _damin_duration_value ""
set -g _damin_battery_value ""
set -g _damin_battery_at 0
set -g _damin_k8s_mt ""
set -g _damin_k8s_ctx ""
set -g _damin_k8s_ns ""
set -g _damin_aws_cfg_mt ""
set -g _damin_aws_cfg_value ""
set -g _damin_gcp_active_mt ""
set -g _damin_gcp_active_name ""
set -g _damin_gcp_cfg_mt ""
set -g _damin_gcp_cfg_value ""
set -g _damin_azure_mt ""
set -g _damin_azure_value ""
set -g _damin_osc_pwd ""
set -g _damin_osc_host ""
set -g _damin_gh_branch ""
set -g _damin_gh_value ""
set -g _damin_gh_at 0
set -g _damin_devops_pwd ""
set -g _damin_devops_tf ""
set -g _damin_devops_pl ""

set -g _damin_is_root 0
test (id -u 2>/dev/null) = 0; and set -g _damin_is_root 1

# _damin_pwd_key / _damin_cache_path / _damin_write_cache live in _damin_async_core.fish.

function _damin_read_lines --argument-names file
    test -f $file; or return 1
    while read -l line
        printf '%s\n' "$line"
    end <$file
end

# truncate to n chars with `…`. n ≤ 0 or non-numeric → passthrough.
function _damin_truncate --argument-names s n
    if not string match -rq '^[0-9]+$' -- "$n"
        echo $s
        return
    end
    if test $n -le 0 -o (string length -- $s) -le $n
        echo $s
        return
    end
    echo (string sub -l (math $n - 1) -- $s)…
end

# resolve per-segment max_len, else cloud_max_len umbrella. 0 = no limit.
function _damin_effective_max_len --argument-names seg
    set -l per theme_damin_{$seg}_max_len
    if set -q $per; and string match -rq '^[1-9][0-9]*$' -- $$per
        echo $$per
        return
    end
    if set -q theme_damin_cloud_max_len; and string match -rq '^[1-9][0-9]*$' -- $theme_damin_cloud_max_len
        echo $theme_damin_cloud_max_len
        return
    end
    echo 0
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

# osc 7 advertises cwd; osc 133 marks prompt regions. unknown OSC = ignored.
function _damin_osc_enabled
    test "$theme_damin_osc_integration" = 1
end

function _damin_osc_hostname
    if test -z "$_damin_osc_host"
        set -l h (hostname 2>/dev/null | string trim)
        test -z "$h"; and set h localhost
        set -g _damin_osc_host $h
    end
    echo $_damin_osc_host
end

# split-then-encode so the `/` separators survive url-escaping.
function _damin_osc_encode_path --argument-names path
    set -l parts (string split / -- $path)
    set -l out
    for p in $parts
        if test -z "$p"
            set -a out ""
        else
            set -a out (string escape --style=url -- $p)
        end
    end
    string join / -- $out
end

function _damin_osc7_emit
    _damin_osc_enabled; or return
    test "$_damin_osc_pwd" = "$PWD"; and return
    set -g _damin_osc_pwd "$PWD"
    set -l host (_damin_osc_hostname)
    set -l enc (_damin_osc_encode_path "$PWD")
    printf '\e]7;file://%s%s\a' "$host" "$enc"
end

# OSC 8 hyperlink wrapper. passthrough if osc disabled or url empty.
# uses BEL (\a) as the OSC terminator — ESC \ would clash with `%s` as `\%` in printf.
function _damin_osc8 --argument-names url text
    if _damin_osc_enabled; and test -n "$url"
        printf '\e]8;;%s\a%s\e]8;;\a' $url $text
    else
        printf '%s' $text
    end
end

function _damin_osc133_a
    _damin_osc_enabled; and printf '\e]133;A\a'
end

function _damin_osc133_b
    _damin_osc_enabled; and printf '\e]133;B\a'
end

function _damin_osc133_c --on-event fish_preexec
    _damin_osc_enabled; and printf '\e]133;C\a'
end

function _damin_vcs_ignored --argument-names dir
    set -q theme_damin_vcs_ignore_paths; or return 1
    test (count $theme_damin_vcs_ignore_paths) -eq 0; and return 1
    for pat in $theme_damin_vcs_ignore_paths
        string match -q -- $pat $dir; and return 0
    end
    return 1
end

function _damin_detect_vcs
    if test "$_damin_vcs_pwd" != "$PWD"
        set -g _damin_vcs_pwd "$PWD"
        set -g _damin_vcs_worktree ""
        set -l result ""
        set -l found ""
        if _damin_vcs_ignored "$PWD"
            set -g _damin_vcs_value ""
            set -g _damin_vcs_dir ""
            echo
            return
        end
        set -l dir $PWD
        set -l levels 0
        while test "$dir" != / -a $levels -lt 16
            if test -d "$dir/.jj"
                set result jj
                set found "$dir/.jj"
                break
            end
            if test -d "$dir/.git"
                set result git
                set found "$dir/.git"
                break
            end
            if test -f "$dir/.git"
                set result git
                set -l gd (command cat "$dir/.git" 2>/dev/null | string match -gr '^gitdir: (.+)')
                if test -n "$gd"
                    string match -q '/*' -- $gd[1]; and set found $gd[1]; or set found "$dir/$gd[1]"
                else
                    set found "$dir/.git"
                end
                # gitdir under .git/worktrees/<name> = git worktree; basename is the worktree name.
                string match -q '*/worktrees/*' -- $found; and set -g _damin_vcs_worktree (path basename $found)
                break
            end
            if test "$theme_damin_show_hg" = 1 -a -d "$dir/.hg"
                set result hg
                set found "$dir/.hg"
                break
            end
            if test "$theme_damin_show_fossil" = 1
                if test -f "$dir/.fslckout" -o -f "$dir/_FOSSIL_"
                    set result fossil
                    set found "$dir"
                    break
                end
            end
            set dir (path dirname $dir)
            set levels (math $levels + 1)
        end
        set -g _damin_vcs_value $result
        set -g _damin_vcs_dir $found
    end
    echo $_damin_vcs_value
end

# aws / gcp / azure / k8s renderers + helpers live in functions/ — autoloaded
# on first use; disabled segments cost zero parse time.
function _damin_context_render
    test "$theme_damin_show_context" = 1; or return
    set -l in_ssh 0
    test -n "$SSH_CONNECTION"; and set in_ssh 1
    test -n "$SSH_CLIENT" -o -n "$SSH_TTY"; and set in_ssh 1

    set -l show_user 0
    set -l show_host 0
    switch "$theme_damin_show_user"
        case always 1 yes
            set show_user 1
        case ssh
            test $in_ssh = 1; and set show_user 1
    end
    switch "$theme_damin_show_host"
        case always 1 yes
            set show_host 1
        case ssh
            test $in_ssh = 1; and set show_host 1
    end

    if test $show_user = 1 -o $show_host = 1
        set -l label
        if test $show_user = 1
            set -l u $USER
            test -z "$u"; and set u (command id -un 2>/dev/null)
            # default_user match → suppress username.
            if set -q theme_damin_default_user; and test "$u" = "$theme_damin_default_user"
                set u
            end
            test -n "$u"; and set label $u
        end
        if test $show_host = 1
            set -l h (_damin_osc_hostname)
            test -n "$label" -a -n "$h"; and set label "$label@$h"
            test -z "$label" -a -n "$h"; and set label $h
        end
        test -n "$label"; and echo -n -s $_damin_c_dim $label $_damin_c_normal " "
    else if test $in_ssh = 1
        echo -n -s $_damin_c_dim ssh $_damin_c_normal " "
    end

    test "$_damin_is_root" = 1; and echo -n -s $_damin_c_err root $_damin_c_normal " "
    # sudo_user: $SUDO_USER inside a root shell (sudo -s / -i).
    if test "$theme_damin_show_sudo_user" = 1; and set -q SUDO_USER; and test -n "$SUDO_USER"
        echo -n -s $_damin_c_dim "sudo:$SUDO_USER" $_damin_c_normal " "
    end
    if test -f /.dockerenv
        echo -n -s $_damin_c_dim dkr $_damin_c_normal " "
    else if test -f /run/.containerenv
        echo -n -s $_damin_c_dim ctr $_damin_c_normal " "
    end
    if test "$theme_damin_show_docker_machine" = 1; and set -q DOCKER_MACHINE_NAME; and test -n "$DOCKER_MACHINE_NAME"
        echo -n -s $_damin_c_dim "dm:$DOCKER_MACHINE_NAME" $_damin_c_normal " "
    end
    # $STY = "<pid>.<session>" inside GNU screen.
    if test "$theme_damin_show_screen" = 1; and set -q STY; and test -n "$STY"
        set -l name (string replace -r '^\d+\.' '' -- $STY)
        echo -n -s $_damin_c_dim "screen:$name" $_damin_c_normal " "
    end
    # gate at the caller — disabled cloud segments don't autoload at all.
    test "$theme_damin_show_aws" = 1; and _damin_aws_render
    test "$theme_damin_show_gcp" = 1; and _damin_gcp_render
    test "$theme_damin_show_azure" = 1; and _damin_azure_render
    # k8s also fires inside a pod (bare `k8s` indicator) even without toggle.
    if test "$theme_damin_show_k8s_context" = 1; or set -q KUBERNETES_SERVICE_HOST
        _damin_k8s_render
    end
end

# _damin_git_compute lives in conf.d/_damin_async_core.fish.

# single batched mtime call → [cache, index, HEAD, logs/HEAD] (missing paths dropped).
# output drives BOTH the cache-freshness key AND the stale check — one builtin invocation.
function _damin_git_path_mtimes --argument-names cache_file
    test -n "$_damin_vcs_dir"; or return 1
    path mtime $cache_file "$_damin_vcs_dir/index" "$_damin_vcs_dir/HEAD" "$_damin_vcs_dir/logs/HEAD" 2>/dev/null
end

function _damin_git_cache_stale --argument-names cache_file
    set -l mt (_damin_git_path_mtimes $cache_file)
    test (count $mt) -lt 2; and return 1
    set -l cm $mt[1]
    for m in $mt[2..]
        test $m -gt $cm; and return 0
    end
    return 1
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

function _damin_git_render_data --argument-names branch u m s st a b c op
    set -l hide 0
    if test "$theme_damin_hide_default_branch" = 1
        contains -- $branch $theme_damin_default_branches; and set hide 1
    end
    if test $hide = 1
        # branch hidden; counts/op/sparkle still render.
        test -n "$op"; and echo -n -s $_damin_c_exit "($op)" $_damin_c_normal
    else
        set -l shown $branch
        if test $theme_damin_branch_max_len -gt 0 -a (string length -- $branch) -gt $theme_damin_branch_max_len
            set shown (string sub -l (math $theme_damin_branch_max_len - 1) -- $branch)…
        end
        echo -n -s $_damin_c_branch $shown $_damin_c_normal
        test -n "$op"; and echo -n -s " " $_damin_c_exit "($op)" $_damin_c_normal
    end
    test -n "$_damin_vcs_worktree"; and echo -n -s " " $_damin_c_dim "wt:$_damin_vcs_worktree" $_damin_c_normal

    set -l counts_on 0
    test "$theme_damin_git_counts" = 1; and set counts_on 1

    set -l first 1

    # conflicts render first in bold red — always demand attention.
    if test $c -gt 0
        echo -n -s " " $_damin_c_err $theme_damin_glyph_conflict
        test $counts_on -eq 1; and echo -n "$c"
        echo -n -s $_damin_c_normal
        set first 0
    end

    _damin_git_part $u $theme_damin_glyph_untracked $first $counts_on; and set first 0
    _damin_git_part $st $theme_damin_glyph_stashed $first $counts_on; and set first 0
    _damin_git_part $m $theme_damin_glyph_modified $first $counts_on; and set first 0
    _damin_git_part $s $theme_damin_glyph_added $first $counts_on; and set first 0
    _damin_git_part $b $theme_damin_glyph_behind $first $counts_on; and set first 0
    _damin_git_part $a $theme_damin_glyph_ahead $first $counts_on; and set first 0

    if test $first -eq 0
        echo -n -s $_damin_c_normal
    else if test -z "$op"
        echo -n -s " " $_damin_c_deco $theme_damin_glyph_clean $_damin_c_normal
    end

    _damin_gh_render "$branch"
end

# _damin_git_prefill lives in _damin_async_core.fish.

# bg subshell sources only the small core file (so <fn> must live in core),
# signals parent on done. new kickoff for the same <key> kills the prior pid.
function _damin_async_kickoff --argument-names key fn
    set -l pid_var _damin_async_pid_$key
    set -l prior $$pid_var
    test -n "$prior"; and kill $prior 2>/dev/null
    set -l call (string escape -- $fn $argv[3..])
    set -l core $_damin_async_core_file
    set -l pwd $PWD
    set -l parent $fish_pid
    set -l signal $theme_damin_async_signal
    fish -c "
        cd '$pwd' 2>/dev/null
        source '$core' 2>/dev/null
        $call
        kill -s $signal $parent 2>/dev/null
    " >/dev/null 2>&1 &
    set -l bg_pid $last_pid
    set -g $pid_var $bg_pid
    disown 2>/dev/null

    set -l t $theme_damin_async_timeout
    if string match -rq '^[1-9][0-9]*$' -- "$t"
        fish -c "sleep $t; kill $bg_pid 2>/dev/null" >/dev/null 2>&1 &
        disown 2>/dev/null
    end
end

# signal captured at define time (var change needs shell restart). pid cleanup
# is left to the next kickoff — kill of a dead pid silently fails.
function _damin_async_signal_handler --on-signal $theme_damin_async_signal
    commandline -f repaint 2>/dev/null
end
set -g _damin_async_signal_loaded $theme_damin_async_signal

function _damin_git_render
    if test "$theme_damin_async_git" != 1
        set -l data (_damin_git_compute)
        test -z "$data"; and return
        _damin_git_render_data $data
        return
    end

    set -l cache_file (_damin_cache_path git)
    set -l cache_mt ""
    set -l stale 0

    # `test -f` gate: path mtime silently drops missing paths, so without this
    # mt[1] could be the index mtime instead of the cache mtime.
    if test -f $cache_file
        set -l mt (_damin_git_path_mtimes $cache_file)
        if test (count $mt) -ge 1
            set cache_mt $mt[1]
            for m in $mt[2..]
                test $m -gt $cache_mt; and set stale 1; and break
            end
        end
    end

    set -l data

    # in-memory shortcut: same pwd + same cache mtime + fresh → reuse parsed data.
    # postexec deletes the cache file on git-mutating commands → cache_mt empty → forced re-read.
    if test -n "$cache_mt" -a "$_damin_git_cached_pwd" = "$PWD" -a "$_damin_git_cached_mt" = "$cache_mt" -a $stale = 0
        set data $_damin_git_cached_data
    else if test -n "$cache_mt"
        set -l lines (_damin_read_lines $cache_file)
        if test (count $lines) -ge 10 -a "$lines[1]" = "$PWD"
            set data $lines[2..10]
            set -g _damin_git_cached_pwd "$PWD"
            set -g _damin_git_cached_mt "$cache_mt"
            set -g _damin_git_cached_data $data
        end
    end

    # async_repaint mode: render stale/empty NOW, bg refresh + repaint on completion.
    if test "$theme_damin_async_repaint" = 1
        if test -z "$data" -o $stale = 1
            _damin_async_kickoff git _damin_git_prefill
        end
        test -z "$data"; and return
        _damin_git_render_data $data
        return
    end

    # default: sync compute on miss or stale.
    if test -z "$data" -o $stale = 1
        set data (_damin_git_compute)
        if test -n "$data"
            _damin_write_cache $cache_file "$PWD" $data
            set -g _damin_git_cached_pwd "$PWD"
            # post-write stat refreshes memo key; skip-and-reread / date-fork cost more.
            set -g _damin_git_cached_mt (path mtime $cache_file 2>/dev/null)
            set -g _damin_git_cached_data $data
        end
    end

    test -z "$data"; and return
    _damin_git_render_data $data
end

# jj helpers live in functions/ — autoloaded only when in a jj repo.

# _damin_gh_compute / _damin_gh_prefill live in _damin_async_core.fish.

# disk cache: line1=PWD, line2=branch, line3=`<num> <isDraft>` or `-`.
function _damin_gh_render --argument-names branch
    test "$theme_damin_show_gh_pr" = 1; or return
    test -n "$branch"; or return

    if test "$theme_damin_async_gh_pr" != 1
        set -l now (date +%s)
        set -l ttl $theme_damin_gh_pr_ttl
        if test "$_damin_gh_branch" != "$branch"; or test (math $now - $_damin_gh_at) -ge $ttl
            set -g _damin_gh_branch "$branch"
            set -g _damin_gh_at $now
            set -g _damin_gh_value (_damin_gh_compute "$branch")
        end
        _damin_gh_render_value "$_damin_gh_value"
        return
    end

    set -l cache_file (_damin_cache_path gh-(_damin_gh_branch_key $branch))
    set -l cache_mt (path mtime $cache_file 2>/dev/null)
    set -l now (date +%s)
    set -l ttl $theme_damin_gh_pr_ttl
    set -l fresh 0
    test -n "$cache_mt" -a (math $now - "0$cache_mt") -lt $ttl; and set fresh 1

    set -l value
    if test -n "$cache_mt"
        set -l lines (_damin_read_lines $cache_file)
        if test (count $lines) -ge 3 -a "$lines[1]" = "$PWD" -a "$lines[2]" = "$branch"
            set value "$lines[3]"
        end
    end

    # missing or expired → kick off bg refresh; render stale value if any.
    test $fresh = 0; and _damin_async_kickoff gh _damin_gh_prefill "$branch"

    _damin_gh_render_value "$value"
end

function _damin_gh_render_value --argument-names value
    test -n "$value"; or return
    test "$value" = -; and return
    set -l parts (string split ' ' -- $value)
    set -l num $parts[1]
    set -l draft $parts[2]
    set -l url $parts[3]
    set -l color $_damin_c_meta
    test "$draft" = true; and set color $_damin_c_dim
    set -l label (_damin_osc8 "$url" "#$num")
    echo -n -s " " $color $label $_damin_c_normal
end

function _damin_vcs_render
    test "$theme_damin_show_git" = 1; or return
    set -l vcs (_damin_detect_vcs)
    switch $vcs
        case jj
            test "$theme_damin_show_jj" = 1; or return
            _damin_jj_render
        case hg
            _damin_hg_render
        case fossil
            _damin_fossil_render
        case git
            _damin_git_render
    end
end

function _damin_jobs_render
    test "$theme_damin_show_jobs" = 1; or return
    set -l n (count (jobs -p 2>/dev/null))
    test $n -gt 0; or return
    echo -n -s " " $_damin_c_sep $theme_damin_glyph_sep " " $_damin_c_dim "&$n" $_damin_c_normal
end

# set -U theme_damin_extra_left foo bar → calls damin_segment_foo + damin_segment_bar.
function _damin_extra_segments_render --argument-names side
    set -l var theme_damin_extra_$side
    set -q $var; or return
    for seg in $$var
        functions -q damin_segment_$seg; and damin_segment_$seg
    end
end

# vi mode badge — only shown when vi keybindings are active.
function _damin_vi_mode_render
    test "$theme_damin_show_vi_mode" = 1; or return
    test "$fish_key_bindings" = fish_vi_key_bindings; or return
    set -l label
    set -l color
    switch $fish_bind_mode
        case default
            set label N
            set color (set_color 98ABCC -o)
        case insert
            set label I
            set color (set_color a6e3a1 -o)
        case visual
            set label V
            set color (set_color f9e2af -o)
        case replace replace_one
            set label R
            set color (set_color f38ba8 -o)
        case '*'
            return
    end
    echo -n -s " " $color "[$label]" $_damin_c_normal
end

function _damin_vi_mode_repaint --on-variable fish_bind_mode
    commandline -f repaint 2>/dev/null
end

# inline POSIX signal map; avoids fish_status_to_signal's `kill -l` fork.
function _damin_status_name --argument-names code
    switch $code
        case 126
            echo noexec
        case 127
            echo not-found
        case 129
            echo SIGHUP
        case 130
            echo SIGINT
        case 131
            echo SIGQUIT
        case 132
            echo SIGILL
        case 133
            echo SIGTRAP
        case 134
            echo SIGABRT
        case 136
            echo SIGFPE
        case 137
            echo SIGKILL
        case 139
            echo SIGSEGV
        case 141
            echo SIGPIPE
        case 142
            echo SIGALRM
        case 143
            echo SIGTERM
        case '*'
            echo $code
    end
end

# show_exit_code mode: 0|off|hidden | 1|number | name | both. empty = render nothing.
function _damin_exit_label --argument-names code
    switch "$theme_damin_show_exit_code"
        case 0 off hidden
            return
        case 1 number
            echo $code
        case name
            echo (_damin_status_name $code)
        case both
            set -l n (_damin_status_name $code)
            if test "$n" = "$code"
                echo $code
            else
                echo "$code $n"
            end
    end
end

function _damin_cwd_pretty
    # PWD-memo: prompt_pwd's string work only runs on cd.
    if test "$_damin_cwd_pwd" != "$PWD"
        set -g _damin_cwd_pwd "$PWD"
        set -l value ""
        # project-relative: skip in worktrees (vcs_dir points to a different tree).
        if test "$theme_damin_show_project_parent" = 0 -a -z "$_damin_vcs_worktree"
            _damin_detect_vcs >/dev/null
            if test -n "$_damin_vcs_dir"
                set -l root (path dirname -- $_damin_vcs_dir)
                if test "$PWD" = "$root"
                    set value (path basename -- $root)
                else if string match -q -- "$root/*" $PWD
                    set -l rel (string replace -- "$root/" '' $PWD)
                    test $theme_damin_project_dir_length -gt 0; and set rel (prompt_pwd --dir-length=$theme_damin_project_dir_length --full-length-dirs=99 -- $rel 2>/dev/null)
                    set value (path basename -- $root)/$rel
                end
            end
        end
        if test -z "$value"
            set value (prompt_pwd --dir-length=$theme_damin_cwd_short --full-length-dirs=$theme_damin_cwd_keep 2>/dev/null)
            test -z "$value"; and set value (prompt_pwd)
        end
        set -g _damin_cwd_value $value
    end
    echo $_damin_cwd_value
end

# first non-empty/non-# line, strips leading `v` (.nvmrc `v18.18` → `18.18`).
function _damin_lang_read_pin --argument-names file
    test -n "$file"; or return
    test -f $file; or return
    for line in (command cat $file 2>/dev/null)
        set -l t (string trim -- $line)
        test -z "$t"; and continue
        string match -qr '^#' -- $t; and continue
        echo (string replace -r '^v' '' -- $t)
        return
    end
end

# `.tool-versions`: `<key> <version> [extras…]` per line.
function _damin_lang_read_tool_versions --argument-names file key
    test -n "$file" -a -n "$key"; or return
    test -f $file; or return
    for line in (command cat $file 2>/dev/null)
        set -l m (string match -r '^'$key' +([^ #]+)' -- $line)
        test (count $m) -ge 2; and echo $m[2]; and return
    end
end

# `.mise.toml [tools]`: `<key> = "<v>"` or `<key> = ["<v>", …]`.
function _damin_lang_read_mise --argument-names file key
    test -n "$file" -a -n "$key"; or return
    test -f $file; or return
    set -l in_tools 0
    for line in (command cat $file 2>/dev/null)
        if string match -qr '^\[' -- $line
            test (string trim -- $line) = '[tools]'; and set in_tools 1; or set in_tools 0
            continue
        end
        test $in_tools = 1; or continue
        set -l m (string match -r '^'$key'\s*=\s*"([^"]+)"' -- $line)
        test (count $m) -ge 2; and echo $m[2]; and return
        set m (string match -r '^'$key'\s*=\s*\[\s*"([^"]+)"' -- $line)
        test (count $m) -ge 2; and echo $m[2]; and return
    end
end

# single walk-up. version resolution: tool-versions → mise → lang pin → binary fork.
function _damin_lang_compute
    set -l dir $PWD
    set -l levels 0
    set -l found_lang ""
    set -l found_label ""
    set -l tool_versions ""
    set -l mise_toml ""
    set -l python_pin ""
    set -l node_pin ""
    set -l ruby_pin ""
    set -l java_pin ""

    while test "$dir" != / -a $levels -lt 8
        if test -z "$found_lang"
            if test -f "$dir/Cargo.toml"
                set found_lang rust
                set found_label rust
            else if test -f "$dir/package.json"
                set found_lang node
                set found_label node
            else if test -f "$dir/go.mod"
                set found_lang go
                set found_label go
            else if test -f "$dir/pyproject.toml" -o -f "$dir/setup.py" -o -f "$dir/requirements.txt"
                set found_lang python
                set found_label py
            else if test -f "$dir/deno.json" -o -f "$dir/deno.jsonc"
                set found_lang deno
                set found_label deno
            else if test -f "$dir/Gemfile" -o -f "$dir/Gemfile.lock"
                set found_lang ruby
                set found_label rb
            else if test -f "$dir/mix.exs"
                set found_lang elixir
                set found_label ex
            else if test -f "$dir/composer.json"
                set found_lang php
                set found_label php
            else if test -f "$dir/shard.yml"
                set found_lang crystal
                set found_label cr
            else if test -f "$dir/build.zig"
                set found_lang zig
                set found_label zig
            else if test -f "$dir/pom.xml" -o -f "$dir/build.gradle" -o -f "$dir/build.gradle.kts"
                set found_lang java
                set found_label java
            end
        end
        test -z "$tool_versions" -a -f "$dir/.tool-versions"; and set tool_versions "$dir/.tool-versions"
        test -z "$mise_toml" -a -f "$dir/.mise.toml"; and set mise_toml "$dir/.mise.toml"
        test -z "$mise_toml" -a -f "$dir/mise.toml"; and set mise_toml "$dir/mise.toml"
        test -z "$python_pin" -a -f "$dir/.python-version"; and set python_pin "$dir/.python-version"
        if test -z "$node_pin"
            if test -f "$dir/.nvmrc"
                set node_pin "$dir/.nvmrc"
            else if test -f "$dir/.node-version"
                set node_pin "$dir/.node-version"
            end
        end
        test -z "$ruby_pin" -a -f "$dir/.ruby-version"; and set ruby_pin "$dir/.ruby-version"
        test -z "$java_pin" -a -f "$dir/.java-version"; and set java_pin "$dir/.java-version"
        set dir (path dirname $dir)
        set levels (math $levels + 1)
    end

    if test -z "$found_lang"
        test "$theme_damin_show_lang_global" = 1; or return
        _damin_lang_global
        return
    end

    set -l v ""
    switch $found_lang
        case rust
            set v (_damin_lang_read_tool_versions $tool_versions rust)
            test -z "$v"; and set v (_damin_lang_read_mise $mise_toml rust)
            test -z "$v"; and set v (command rustc --version 2>/dev/null | string match -gr '\d+\.\d+\.\d+' | head -1)
        case node
            set v (_damin_lang_read_tool_versions $tool_versions nodejs)
            test -z "$v"; and set v (_damin_lang_read_mise $mise_toml node)
            test -z "$v"; and set v (_damin_lang_read_pin $node_pin)
            test -z "$v"; and set v (command node --version 2>/dev/null | string sub -s 2)
        case go
            set v (_damin_lang_read_tool_versions $tool_versions golang)
            test -z "$v"; and set v (_damin_lang_read_mise $mise_toml go)
            test -z "$v"; and set v (command go env GOVERSION 2>/dev/null | string sub -s 3)
        case python
            set v (_damin_lang_read_tool_versions $tool_versions python)
            test -z "$v"; and set v (_damin_lang_read_mise $mise_toml python)
            test -z "$v"; and set v (_damin_lang_read_pin $python_pin)
            test -z "$v"; and set v (command python3 --version 2>/dev/null | string match -gr '\d+\.\d+\.\d+' | head -1)
        case deno
            set v (_damin_lang_read_tool_versions $tool_versions deno)
            test -z "$v"; and set v (_damin_lang_read_mise $mise_toml deno)
            test -z "$v"; and set v (command deno --version 2>/dev/null | string match -gr '\d+\.\d+\.\d+' | head -1)
        case ruby
            set v (_damin_lang_read_tool_versions $tool_versions ruby)
            test -z "$v"; and set v (_damin_lang_read_mise $mise_toml ruby)
            test -z "$v"; and set v (_damin_lang_read_pin $ruby_pin)
            test -z "$v"; and set v (command ruby --version 2>/dev/null | string match -gr '\d+\.\d+\.\d+' | head -1)
        case elixir
            set v (_damin_lang_read_tool_versions $tool_versions elixir)
            test -z "$v"; and set v (_damin_lang_read_mise $mise_toml elixir)
            test -z "$v"; and set v (command elixir --version 2>/dev/null | string match -gr '\d+\.\d+\.\d+' | head -1)
        case php
            set v (_damin_lang_read_tool_versions $tool_versions php)
            test -z "$v"; and set v (_damin_lang_read_mise $mise_toml php)
            test -z "$v"; and set v (command php -r 'echo PHP_VERSION;' 2>/dev/null | string match -gr '\d+\.\d+\.\d+' | head -1)
        case crystal
            set v (_damin_lang_read_tool_versions $tool_versions crystal)
            test -z "$v"; and set v (_damin_lang_read_mise $mise_toml crystal)
            test -z "$v"; and set v (command crystal --version 2>/dev/null | string match -gr '\d+\.\d+\.\d+' | head -1)
        case zig
            set v (_damin_lang_read_tool_versions $tool_versions zig)
            test -z "$v"; and set v (_damin_lang_read_mise $mise_toml zig)
            test -z "$v"; and set v (command zig version 2>/dev/null | string match -gr '\d+\.\d+\.\d+' | head -1)
        case java
            set v (_damin_lang_read_tool_versions $tool_versions java)
            test -z "$v"; and set v (_damin_lang_read_mise $mise_toml java)
            test -z "$v"; and set v (_damin_lang_read_pin $java_pin)
            test -z "$v"; and set v (command java -version 2>&1 | string match -gr '\d+\.\d+\.\d+' | head -1)
    end

    test -n "$v"; and echo "$found_label:$v"; or echo $found_label
end

function _damin_lang_render
    test "$theme_damin_show_lang" = 1; or return

    # in-memory PWD memo first; postexec on version-manager commands clears it.
    if test "$_damin_lang_pwd" = "$PWD"
        test -n "$_damin_lang_value"; and echo -n -s " " $_damin_c_sep $theme_damin_glyph_sep " " $_damin_c_dim "$_damin_lang_value" $_damin_c_normal
        return
    end

    set -l value

    if test "$theme_damin_async_lang" = 1
        set -l cache_file (_damin_cache_path lang)
        if test -f $cache_file
            set -l lines (_damin_read_lines $cache_file)
            if test (count $lines) -ge 2 -a "$lines[1]" = "$PWD"
                set value "$lines[2]"
            end
        end

        if test -z "$value"
            set value (_damin_lang_compute)
            _damin_write_cache $cache_file "$PWD" "$value"
        end
    else
        set value (_damin_lang_compute)
    end

    set -g _damin_lang_pwd "$PWD"
    set -g _damin_lang_value "$value"

    test -n "$value"; and echo -n -s " " $_damin_c_sep $theme_damin_glyph_sep " " $_damin_c_dim "$value" $_damin_c_normal
end

# devops helpers (pulumi / terraform) live in functions/ — autoloaded on demand.

function _damin_env_render
    test "$theme_damin_show_env" = 1; or return
    set -l parts
    set -q VIRTUAL_ENV; and set -a parts (path basename $VIRTUAL_ENV)
    set -q CONDA_DEFAULT_ENV; and set -a parts $CONDA_DEFAULT_ENV

    if set -q DIRENV_DIR
        # strip leading `-` marker from $DIRENV_DIR before basename.
        set -l d (string replace -r '^-' '' -- $DIRENV_DIR)
        set -a parts "direnv:"(path basename -- $d)
    end

    if set -q IN_NIX_SHELL
        # $name = the nix derivation attr; skip the generic default.
        if test "$theme_damin_show_nix_name" = 1
            switch "$name"
                case nix-shell nix-shell-env ''
                    set -a parts nix
                case '*'
                    set -a parts "nix:$name"
            end
        else
            set -a parts nix
        end
    end

    test (count $parts) -eq 0; and return
    set -l joined (string join , -- $parts)
    echo -n -s " " $_damin_c_sep $theme_damin_glyph_sep " " $_damin_c_dim "($joined)" $_damin_c_normal
end

# battery renderer lives in functions/ — autoloaded only when show_battery=1.

function _damin_duration_format
    # CMD_DURATION is stable within a prompt cycle — repaints (arrow-key, etc.) skip the math.
    if test "$_damin_duration_ms" = "$CMD_DURATION"
        echo $_damin_duration_value
        return
    end
    set -g _damin_duration_ms $CMD_DURATION
    set -l s (math $CMD_DURATION/1000)
    set -l m (math $s/60)
    if test $m -gt 1
        set -g _damin_duration_value "$m m"
    else if test $s -gt 1
        set -g _damin_duration_value "$s s"
    else
        set -g _damin_duration_value "$CMD_DURATION ms"
    end
    echo $_damin_duration_value
end

function _damin_duration_render
    test "$theme_damin_show_duration" = 1; or return
    set -l color $_damin_c_dim
    test $CMD_DURATION -gt $theme_damin_long_command_threshold; and set color $_damin_c_long
    echo -n -s " " $_damin_c_sep $theme_damin_glyph_sep " " $color (_damin_duration_format) $_damin_c_normal
end

function _damin_help_row --argument-names name default
    if set -q _damin_help_filter; and test -n "$_damin_help_filter"
        string match -q "*$_damin_help_filter*" -- $name; or return
        set -g _damin_help_matched 1
    end
    set -l val
    set -q $name; and set val (string join ' ' -- $$name)
    if test "$_damin_help_mode" = json
        set -l set_flag false
        set -q $name; and set set_flag true
        set -l v_esc (string replace -a '\\' '\\\\' -- $val | string replace -a '"' '\\"')
        set -l d_esc (string replace -a '\\' '\\\\' -- $default | string replace -a '"' '\\"')
        test "$_damin_help_first" != 1; and printf ,
        set -g _damin_help_first 0
        # quote each arg — empty $v_esc shifts the format slots otherwise.
        printf '{"name":"%s","value":"%s","default":"%s","set":%s}' "$name" "$v_esc" "$d_esc" "$set_flag"
        return
    end
    set -l val_color (set_color E890B0)
    test "$val" = "$default"; and set val_color (set_color --dim)
    printf '  %-38s %s%-8s%s %sdefault %s%s\n' \
        $name $val_color $val (set_color normal) (set_color --dim) $default (set_color normal)
end

function _damin_doctor_check
    if test "$_damin_doctor_mode" = json
        set -l detail (string join ' ' -- $argv[3..])
        set -l esc (string replace -a '\\' '\\\\' -- $detail | string replace -a '"' '\\"' | string replace -a \n ' ')
        set -l label_esc (string replace -a '"' '\\"' -- $argv[1])
        test "$_damin_doctor_first" != 1; and printf ,
        set -g _damin_doctor_first 0
        # quote each arg — empty $esc shifts the format slots otherwise.
        printf '{"check":"%s","status":"%s","detail":"%s"}' "$label_esc" "$argv[2]" "$esc"
        return
    end
    set -l sym '✗'
    set -l col (set_color yellow)
    if test "$argv[2]" = ok
        set sym '✓'
        set col (set_color green)
    end
    printf '  %s%s%s %s%s%s\n' $col $sym (set_color normal) $argv[1] (set_color --dim) " $argv[3..]"(set_color normal)
end

function _damin_postexec --on-event fish_postexec
    set -l exit $status
    _damin_osc_enabled; and printf '\e]133;D;%s\a' $exit
    set -l cmd "$argv"

    if test "$theme_damin_notify_long_command" = 1 -a -n "$cmd"
        if test $CMD_DURATION -gt $theme_damin_notify_threshold
            set -l short (string sub -l 60 -- $cmd)
            set -l secs (math --scale=1 $CMD_DURATION/1000)
            # OSC 9 = universal terminal notification (iTerm2, Konsole, Win Terminal, …).
            printf '\e]9;%s (%ss, exit %s)\a' $short $secs $exit
            # notify-send (Linux/BSD desktops) survives focus loss; backgrounded so it doesn't block.
            type -q notify-send; and command notify-send -t 5000 "fish: $short" "$secs s · exit $exit" &
        end
    end

    if string match -qr '\b(git|jj|hub|gh)\b' -- $cmd
        if not string match -qr '\bgit\s+(status|log|diff|show|blame|ls-(files|tree)|cat-file|rev-(list|parse)|describe|name-rev|shortlog|whatchanged|reflog|grep|ls-remote|help|version)\b' -- $cmd
            command rm -f (_damin_cache_path git) 2>/dev/null
        end
        # state-changing gh pr → drop every per-branch cache for this pwd.
        if string match -qr '\bgh\s+pr\s+(create|close|reopen|merge|edit)\b' -- $cmd
            set -g _damin_gh_branch ""
            set -g _damin_gh_at 0
            command rm -f "$_damin_cache_dir/"(_damin_pwd_key)"-gh-"* 2>/dev/null
        end
    end
    if string match -qr '\b(nvm|fnm|asdf|mise|pyenv|rbenv|rustup|volta|conda)\b' -- $cmd
        command rm -f (_damin_cache_path lang) 2>/dev/null
        # also clear in-memory memo, else next prompt serves the stale version.
        set -g _damin_lang_pwd ""
        set -g _damin_lang_value ""
    end
    # aws/gcloud/az config writes hit same-second mtime; force-refresh on next prompt.
    if string match -qr '\b(aws|gcloud|az)\b' -- $cmd
        set -g _damin_aws_cfg_mt ""
        set -g _damin_gcp_active_mt ""
        set -g _damin_gcp_cfg_mt ""
        set -g _damin_azure_mt ""
    end
    # terraform workspace / pulumi stack swaps.
    if string match -qr '\b(terraform|tf|pulumi)\b' -- $cmd
        set -g _damin_devops_pwd ""
    end
    # kubectl config writes can hit same-second mtime; drop both caches.
    if string match -qr '\bkubectl\s+config\b' -- $cmd
        set -g _damin_k8s_mt ""
        command rm -f "$_damin_cache_dir/cloud-k8s" 2>/dev/null
    end
end

function _damin_transient_enter
    if test "$theme_damin_transient" = 1
        # status 2 = incomplete buffer (open quote etc.) — enter inserts newline, no execute.
        commandline --is-valid 2>/dev/null
        if test $status -ne 2
            set -g _damin_in_transient 1
            commandline -f repaint
        end
    end
    commandline -f execute
end

# bind every mode — vi `insert` (where editing happens) needs its own bind.
function _damin_install_transient_bindings
    for mode in default insert visual replace replace_one paste
        bind -M $mode \r _damin_transient_enter 2>/dev/null
        bind -M $mode \n _damin_transient_enter 2>/dev/null
    end
end

# fish_{default,vi}_key_bindings wipe all binds on swap; re-install after.
function _damin_reinstall_transient_bindings --on-variable fish_key_bindings
    _damin_install_transient_bindings
end

# fish_prompt + fish_right_prompt live in conf.d/ (not functions/) so fisher
# doesn't copy them as autoload stubs — omf would flag those as conflicting.

# blank fish's default `[I] ` mode prompt — damin renders its vi badge inline.
function fish_mode_prompt
end

function fish_prompt
    set -l last_status $status

    _damin_osc133_a
    _damin_osc7_emit

    # transient state machine: 1 = stub-then-advance, 2 = clear + render full.
    # owned in fish_prompt so an overridden fish_right_prompt can't strand the flag.
    switch "$_damin_in_transient"
        case 1
            echo -n -s " " $_damin_c_transient "$theme_damin_glyph_transient " $_damin_c_normal
            set -g _damin_in_transient 2
            _damin_osc133_b
            return
        case 2
            set -eg _damin_in_transient
    end

    _damin_context_render
    _damin_vcs_render
    _damin_jobs_render
    _damin_vi_mode_render
    _damin_extra_segments_render left

    test "$theme_damin_newline_prompt" = 1; and echo

    if test $last_status -eq 0
        echo -n -s " " $_damin_c_ok "$theme_damin_glyph_prompt " $_damin_c_normal
    else
        echo -n -s " " $_damin_c_err "$theme_damin_glyph_prompt " $_damin_c_normal
        set -l label (_damin_exit_label $last_status)
        test -n "$label"; and echo -n -s $_damin_c_exit "$label " $_damin_c_normal
    end

    _damin_osc133_b
end

function fish_right_prompt
    # fish_prompt owns the flag; render blank while it's set.
    if set -q _damin_in_transient
        return
    end

    set -l cwd_url
    _damin_osc_enabled; and set cwd_url "file://"(_damin_osc_hostname)(_damin_osc_encode_path "$PWD")
    echo -n -s " " $_damin_c_deco "$theme_damin_glyph_cwd " $_damin_c_cwd (_damin_osc8 "$cwd_url" (_damin_cwd_pretty)) $_damin_c_normal

    _damin_lang_render
    # gate at caller — disabled segments don't autoload.
    if test "$theme_damin_show_terraform" = 1; or test "$theme_damin_show_pulumi" = 1
        _damin_devops_render
    end
    _damin_env_render
    test "$theme_damin_show_battery" = 1; and _damin_battery_render
    _damin_duration_render
    test "$theme_damin_show_date" = 1; and _damin_date_render
    _damin_extra_segments_render right
end

# one backgrounded fork at theme load fills both caches. `&` forks the current
# shell, so all functions are already defined — no source reload needed.
function _damin_warmup
    if test "$theme_damin_async_git" = 1
        test (_damin_detect_vcs) = git; and _damin_git_prefill
    end
    test "$theme_damin_show_k8s_context" = 1; and _damin_k8s_prefill
end

# _damin_subshell = legacy async-mode guard. _damin_loaded = one-time bootstrap
# so damin_set_palette's re-source doesn't re-prune / re-bind / re-warmup.
if not set -q _damin_subshell; and not set -q _damin_loaded
    set -g _damin_loaded 1
    _damin_cache_prune
    _damin_install_transient_bindings

    if test "$theme_damin_async_warmup" = 1
        _damin_warmup >/dev/null 2>&1 &
        disown 2>/dev/null
    end
end

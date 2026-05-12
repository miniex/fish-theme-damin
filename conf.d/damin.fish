# record the source path so the async-repaint subshell can re-source helpers.
set -g _damin_theme_file (status filename)

# tramp / dumb terminals (emacs shell, basic ttys) — adjust defaults before they're set.
# user-explicit values still win because the regular defaults below use `set -q; or set`.
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
set -q theme_damin_show_aws; or set -g theme_damin_show_aws 0
set -q theme_damin_show_aws_region; or set -g theme_damin_show_aws_region 1
set -q theme_damin_show_gcp; or set -g theme_damin_show_gcp 0
set -q theme_damin_show_azure; or set -g theme_damin_show_azure 0
set -q theme_damin_show_k8s_context; or set -g theme_damin_show_k8s_context 1
set -q theme_damin_show_k8s_namespace; or set -g theme_damin_show_k8s_namespace 0
set -q theme_damin_show_git; or set -g theme_damin_show_git 1
set -q theme_damin_show_jj; or set -g theme_damin_show_jj 1
set -q theme_damin_show_git_op; or set -g theme_damin_show_git_op 1
set -q theme_damin_show_gh_pr; or set -g theme_damin_show_gh_pr 0
set -q theme_damin_show_jobs; or set -g theme_damin_show_jobs 1
# show_exit_code: 0|off|hidden, 1|number (default), name, both.
set -q theme_damin_show_exit_code; or set -g theme_damin_show_exit_code number
set -q theme_damin_show_vi_mode; or set -g theme_damin_show_vi_mode 1

set -q theme_damin_show_lang; or set -g theme_damin_show_lang 1
set -q theme_damin_show_env; or set -g theme_damin_show_env 1
set -q theme_damin_show_nix_name; or set -g theme_damin_show_nix_name 1
set -q theme_damin_show_terraform; or set -g theme_damin_show_terraform 1
set -q theme_damin_show_pulumi; or set -g theme_damin_show_pulumi 1
set -q theme_damin_show_battery; or set -g theme_damin_show_battery 0
set -q theme_damin_show_duration; or set -g theme_damin_show_duration 1

set -q theme_damin_git_counts; or set -g theme_damin_git_counts 1
set -q theme_damin_transient; or set -g theme_damin_transient 1
set -q theme_damin_async_git; or set -g theme_damin_async_git 1
set -q theme_damin_async_lang; or set -g theme_damin_async_lang 1
set -q theme_damin_async_warmup; or set -g theme_damin_async_warmup 1
set -q theme_damin_async_repaint; or set -g theme_damin_async_repaint 0
set -q theme_damin_osc_integration; or set -g theme_damin_osc_integration 1
set -q theme_damin_notify_long_command; or set -g theme_damin_notify_long_command 0
set -q theme_damin_apply_colors; or set -g theme_damin_apply_colors 1
set -q theme_damin_palette; or set -g theme_damin_palette mocha
set -q theme_damin_ascii; or set -g theme_damin_ascii 0

set -q theme_damin_cwd_keep; or set -g theme_damin_cwd_keep 3
set -q theme_damin_cwd_short; or set -g theme_damin_cwd_short 4
set -q theme_damin_long_command_threshold; or set -g theme_damin_long_command_threshold 3000
set -q theme_damin_battery_threshold; or set -g theme_damin_battery_threshold 30
set -q theme_damin_gh_pr_ttl; or set -g theme_damin_gh_pr_ttl 300
set -q theme_damin_notify_threshold; or set -g theme_damin_notify_threshold 30000

# transient flag is session-global only; drain any universal-scope leak.
set -qU _damin_in_transient; and set -eU _damin_in_transient

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

# catppuccin palette — `damin_set_palette <flavor>` erases universals first to switch.
if test "$theme_damin_apply_colors" = 1
    set -l text cdd6f4
    set -l blue 89b4fa
    set -l mauve cba6f7
    set -l green a6e3a1
    set -l pink f5c2e7
    set -l peach fab387
    set -l red f38ba8
    set -l flamingo f2cdcd
    set -l overlay1 7f849c
    set -l surface0 313244
    set -l maroon eba0ac
    set -l overlay0 6c7086
    set -l yellow f9e2af
    set -l teal 94e2d5
    switch "$theme_damin_palette"
        case latte
            set text 4c4f69
            set blue 1e66f5
            set mauve 8839ef
            set green 40a02b
            set pink ea76cb
            set peach fe640b
            set red d20f39
            set flamingo dd7878
            set overlay1 8c8fa1
            set surface0 ccd0da
            set maroon e64553
            set overlay0 9ca0b0
            set yellow df8e1d
            set teal 179299
        case frappe
            set text c6d0f5
            set blue 8caaee
            set mauve ca9ee6
            set green a6d189
            set pink f4b8e4
            set peach ef9f76
            set red e78284
            set flamingo eebebe
            set overlay1 838ba7
            set surface0 414559
            set maroon ea999c
            set overlay0 737994
            set yellow e5c890
            set teal 81c8be
        case macchiato
            set text cad3f5
            set blue 8aadf4
            set mauve c6a0f6
            set green a6da95
            set pink f5bde6
            set peach f5a97f
            set red ed8796
            set flamingo f0c6c6
            set overlay1 8087a2
            set surface0 363a4f
            set maroon ee99a0
            set overlay0 6e738d
            set yellow eed49f
            set teal 8bd5ca
        case gruvbox
            set text ebdbb2
            set blue 83a598
            set mauve d3869b
            set green b8bb26
            set pink fb4934
            set peach fe8019
            set red fb4934
            set flamingo e78a4e
            set overlay1 928374
            set surface0 504945
            set maroon ea6962
            set overlay0 7c6f64
            set yellow fabd2f
            set teal 8ec07c
        case tokyonight
            set text c0caf5
            set blue 7aa2f7
            set mauve bb9af7
            set green 9ece6a
            set pink f7768e
            set peach ff9e64
            set red f7768e
            set flamingo e0af68
            set overlay1 565f89
            set surface0 414868
            set maroon ff757f
            set overlay0 414868
            set yellow e0af68
            set teal 73daca
        case rosepine
            set text e0def4
            set blue 9ccfd8
            set mauve c4a7e7
            set green 31748f
            set pink ebbcba
            set peach f6c177
            set red eb6f92
            set flamingo ebbcba
            set overlay1 6e6a86
            set surface0 26233a
            set maroon eb6f92
            set overlay0 524f67
            set yellow f6c177
            set teal 9ccfd8
        case nord
            set text eceff4
            set blue 81a1c1
            set mauve b48ead
            set green a3be8c
            set pink b48ead
            set peach d08770
            set red bf616a
            set flamingo d08770
            set overlay1 4c566a
            set surface0 3b4252
            set maroon bf616a
            set overlay0 4c566a
            set yellow ebcb8b
            set teal 88c0d0
        case dracula
            set text f8f8f2
            set blue 8be9fd
            set mauve bd93f9
            set green 50fa7b
            set pink ff79c6
            set peach ffb86c
            set red ff5555
            set flamingo ffb86c
            set overlay1 6272a4
            set surface0 44475a
            set maroon ff5555
            set overlay0 6272a4
            set yellow f1fa8c
            set teal 8be9fd
    end
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

# brand accents per palette — catppuccin keeps cherry-blossom; user override wins.
set -l _damin_accent_primary 98ABCC
set -l _damin_accent_secondary E890B0
switch "$theme_damin_palette"
    case gruvbox
        set _damin_accent_primary 83a598
        set _damin_accent_secondary d3869b
    case tokyonight
        set _damin_accent_primary 7aa2f7
        set _damin_accent_secondary bb9af7
    case rosepine
        set _damin_accent_primary 9ccfd8
        set _damin_accent_secondary ebbcba
    case nord
        set _damin_accent_primary 88c0d0
        set _damin_accent_secondary b48ead
    case dracula
        set _damin_accent_primary 8be9fd
        set _damin_accent_secondary bd93f9
end
set -q theme_damin_accent_primary; or set -g theme_damin_accent_primary $_damin_accent_primary
set -q theme_damin_accent_secondary; or set -g theme_damin_accent_secondary $_damin_accent_secondary

# pre-computed color escapes (set_color is a fork; do it once at theme load).
set -g _damin_c_normal (set_color normal)
set -g _damin_c_branch (set_color $theme_damin_accent_primary)
set -g _damin_c_meta (set_color $theme_damin_accent_secondary)
set -g _damin_c_count (set_color $theme_damin_accent_secondary --dim)
set -g _damin_c_ok (set_color $theme_damin_accent_secondary -o)
set -g _damin_c_err (set_color red -o)
set -g _damin_c_exit (set_color red --dim)
set -g _damin_c_cwd (set_color $theme_damin_accent_primary)
set -g _damin_c_dim (set_color --dim)
set -g _damin_c_deco (set_color $theme_damin_accent_secondary)
set -g _damin_c_sep (set_color $theme_damin_accent_secondary --dim)
set -g _damin_c_long (set_color $theme_damin_accent_secondary -o)

set -g _damin_pwd_key_pwd ""
set -g _damin_pwd_key_value ""
set -g _damin_vcs_pwd ""
set -g _damin_vcs_value ""
set -g _damin_vcs_dir ""
set -g _damin_vcs_worktree ""
set -g _damin_lang_pwd ""
set -g _damin_lang_value ""
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

function _damin_write_cache --argument-names cache_file pwd
    mkdir -p (path dirname $cache_file) 2>/dev/null
    set -l tmp "$cache_file.tmp.$fish_pid"
    printf '%s\n' "$pwd" $argv[3..] >$tmp 2>/dev/null
    mv $tmp $cache_file 2>/dev/null
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

function _damin_osc133_a
    _damin_osc_enabled; and printf '\e]133;A\a'
end

function _damin_osc133_b
    _damin_osc_enabled; and printf '\e]133;B\a'
end

function _damin_osc133_c --on-event fish_preexec
    _damin_osc_enabled; and printf '\e]133;C\a'
end

function _damin_detect_vcs
    if test "$_damin_vcs_pwd" != "$PWD"
        set -g _damin_vcs_pwd "$PWD"
        set -g _damin_vcs_worktree ""
        set -l dir $PWD
        set -l levels 0
        set -l result ""
        set -l found ""
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
            set dir (path dirname $dir)
            set levels (math $levels + 1)
        end
        set -g _damin_vcs_value $result
        set -g _damin_vcs_dir $found
    end
    echo $_damin_vcs_value
end

# `[default]` for the default profile, `[profile <name>]` for the rest.
function _damin_aws_region_for --argument-names profile cfg
    test -f $cfg; or return
    set -l target
    if test "$profile" = default
        set target '[default]'
    else
        set target "[profile $profile]"
    end
    set -l in_section 0
    for line in (command cat $cfg 2>/dev/null)
        if string match -qr '^\[' -- $line
            test "$line" = "$target"; and set in_section 1; or set in_section 0
            continue
        end
        test $in_section = 1; or continue
        set -l m (string match -r '^region *= *(.*)$' -- $line)
        test (count $m) -ge 2; and echo (string trim -- $m[2]); and return
    end
end

function _damin_aws_render
    test "$theme_damin_show_aws" = 1; or return
    set -l profile
    if set -q AWS_PROFILE; and test -n "$AWS_PROFILE"
        set profile $AWS_PROFILE
    else if set -q AWS_DEFAULT_PROFILE; and test -n "$AWS_DEFAULT_PROFILE"
        set profile $AWS_DEFAULT_PROFILE
    end
    test -n "$profile"; or return

    set -l region
    if set -q AWS_REGION; and test -n "$AWS_REGION"
        set region $AWS_REGION
    else if set -q AWS_DEFAULT_REGION; and test -n "$AWS_DEFAULT_REGION"
        set region $AWS_DEFAULT_REGION
    else if test "$theme_damin_show_aws_region" = 1
        set -l cfg "$HOME/.aws/config"
        set -q AWS_CONFIG_FILE; and test -n "$AWS_CONFIG_FILE"; and set cfg $AWS_CONFIG_FILE
        if test -f $cfg
            set -l mt (path mtime $cfg 2>/dev/null)
            set -l key "$mt|$profile"
            if test "$_damin_aws_cfg_mt" = "$key"
                set region $_damin_aws_cfg_value
            else
                set region (_damin_aws_region_for $profile $cfg)
                set -g _damin_aws_cfg_mt "$key"
                set -g _damin_aws_cfg_value "$region"
            end
        end
    end

    set -l label "aws:$profile"
    test "$theme_damin_show_aws_region" = 1 -a -n "$region"; and set label "$label@$region"
    echo -n -s $_damin_c_dim "$label " $_damin_c_normal
end

# active_config names the live config; configurations/config_<name> [core] holds the project.
function _damin_gcp_render
    test "$theme_damin_show_gcp" = 1; or return

    set -l project
    if set -q CLOUDSDK_CORE_PROJECT; and test -n "$CLOUDSDK_CORE_PROJECT"
        set project $CLOUDSDK_CORE_PROJECT
    else
        set -l cfg_root "$HOME/.config/gcloud"
        set -q CLOUDSDK_CONFIG; and test -n "$CLOUDSDK_CONFIG"; and set cfg_root $CLOUDSDK_CONFIG
        set -l active "$cfg_root/active_config"
        test -f $active; or return

        set -l mt (path mtime $active 2>/dev/null)
        set -l name
        if test "$_damin_gcp_active_mt" = "$mt"
            set name $_damin_gcp_active_name
        else
            set name (command cat $active 2>/dev/null | string trim | head -1)
            set -g _damin_gcp_active_mt "$mt"
            set -g _damin_gcp_active_name "$name"
        end
        test -n "$name"; or return

        set -l cfg "$cfg_root/configurations/config_$name"
        test -f $cfg; or return
        set -l cmt (path mtime $cfg 2>/dev/null)
        if test "$_damin_gcp_cfg_mt" = "$cmt|$name"
            set project $_damin_gcp_cfg_value
        else
            set -l in_core 0
            for line in (command cat $cfg 2>/dev/null)
                if string match -qr '^\[' -- $line
                    test "$line" = '[core]'; and set in_core 1; or set in_core 0
                    continue
                end
                test $in_core = 1; or continue
                set -l m (string match -r '^project *= *(.*)$' -- $line)
                test (count $m) -ge 2; and set project (string trim -- $m[2]); and break
            end
            set -g _damin_gcp_cfg_mt "$cmt|$name"
            set -g _damin_gcp_cfg_value "$project"
        end
    end

    test -n "$project"; or return
    echo -n -s $_damin_c_dim "gcp:$project " $_damin_c_normal
end

# split azureProfile.json on `},` to get per-subscription chunks (schema is flat).
function _damin_azure_compute --argument-names file
    test -f $file; or return
    set -l data (command cat $file 2>/dev/null | string collect)
    test -z "$data"; and return
    set -l chunks (string split '},' -- $data)
    for chunk in $chunks
        string match -qr '"isDefault"\s*:\s*true' -- $chunk; or continue
        set -l m (string match -r '"name"\s*:\s*"([^"]+)"' -- $chunk)
        test (count $m) -ge 2; and echo $m[2]; and return
    end
end

function _damin_azure_render
    test "$theme_damin_show_azure" = 1; or return
    set -l sub
    if set -q AZURE_SUBSCRIPTION_NAME; and test -n "$AZURE_SUBSCRIPTION_NAME"
        set sub $AZURE_SUBSCRIPTION_NAME
    else if set -q AZURE_DEFAULTS_SUBSCRIPTION; and test -n "$AZURE_DEFAULTS_SUBSCRIPTION"
        set sub $AZURE_DEFAULTS_SUBSCRIPTION
    else
        set -l file "$HOME/.azure/azureProfile.json"
        set -q AZURE_CONFIG_DIR; and test -n "$AZURE_CONFIG_DIR"; and set file "$AZURE_CONFIG_DIR/azureProfile.json"
        test -f $file; or return
        set -l mt (path mtime $file 2>/dev/null)
        if test "$_damin_azure_mt" = "$mt"
            set sub $_damin_azure_value
        else
            set sub (_damin_azure_compute $file)
            set -g _damin_azure_mt "$mt"
            set -g _damin_azure_value "$sub"
        end
    end
    test -n "$sub"; or return
    echo -n -s $_damin_c_dim "az:$sub " $_damin_c_normal
end

function _damin_k8s_config_path
    if set -q KUBECONFIG; and test -n "$KUBECONFIG"
        echo (string split : -- $KUBECONFIG)[1]
        return
    end
    echo "$HOME/.kube/config"
end

# collect all blocks first so order of current-context vs contexts: doesn't matter.
function _damin_k8s_compute --argument-names cfg
    set -l current
    set -l in_contexts 0
    set -l block_ns
    set -l block_name
    set -l names
    set -l namespaces

    for line in (command cat $cfg 2>/dev/null)
        set -l m (string match -r '^current-context: *(.*)$' -- $line)
        if test (count $m) -ge 2
            set current (string trim --chars '"' -- $m[2])
            continue
        end

        if string match -q 'contexts:*' -- $line
            set in_contexts 1
            continue
        else if string match -qr '^[a-zA-Z]' -- $line
            if test -n "$block_name"
                set -a names $block_name
                set -a namespaces $block_ns
                set block_name ""
                set block_ns ""
            end
            set in_contexts 0
            continue
        end

        test $in_contexts = 1; or continue

        if test (string trim -- $line) = '- context:'
            if test -n "$block_name"
                set -a names $block_name
                set -a namespaces $block_ns
            end
            set block_ns ""
            set block_name ""
            continue
        end

        set m (string match -r '^    namespace: *(.*)$' -- $line)
        test (count $m) -ge 2; and set block_ns (string trim --chars '"' -- $m[2])

        set m (string match -r '^  name: *(.*)$' -- $line)
        test (count $m) -ge 2; and set block_name (string trim --chars '"' -- $m[2])
    end

    if test -n "$block_name"
        set -a names $block_name
        set -a namespaces $block_ns
    end

    test -z "$current"; and return

    set -l found_ns ""
    for i in (seq (count $names))
        if test "$names[$i]" = "$current"
            set found_ns $namespaces[$i]
            break
        end
    end
    printf '%s\n%s\n' "$current" "$found_ns"
end

# disk cache (mtime|ctx|ns) so cold-start skips the kubeconfig yaml walk.
function _damin_k8s_prefill
    set -l cfg (_damin_k8s_config_path)
    test -f $cfg; or return
    set -l mt (path mtime $cfg 2>/dev/null)
    test -n "$mt"; or return
    set -l cache "$_damin_cache_dir/cloud-k8s"
    if test -f $cache
        set -l lines (_damin_read_lines $cache)
        test (count $lines) -ge 1 -a "$lines[1]" = "$mt"; and return
    end
    set -l data (_damin_k8s_compute $cfg)
    set -l ctx ""
    set -l ns ""
    test (count $data) -ge 1; and set ctx $data[1]
    test (count $data) -ge 2; and set ns $data[2]
    mkdir -p $_damin_cache_dir 2>/dev/null
    set -l tmp "$cache.tmp.$fish_pid"
    printf '%s\n%s\n%s\n' "$mt" "$ctx" "$ns" >$tmp 2>/dev/null
    mv $tmp $cache 2>/dev/null
end

function _damin_k8s_render
    set -l cfg (_damin_k8s_config_path)
    set -l in_pod 0
    set -q KUBERNETES_SERVICE_HOST; and set in_pod 1

    set -l ctx ""
    set -l ns ""

    if test -f $cfg
        set -l mt (path mtime $cfg 2>/dev/null)
        if test "$mt" = "$_damin_k8s_mt"
            set ctx $_damin_k8s_ctx
            set ns $_damin_k8s_ns
        else
            set -l used_cache 0
            set -l cache "$_damin_cache_dir/cloud-k8s"
            if test -f $cache
                set -l lines (_damin_read_lines $cache)
                if test (count $lines) -ge 1 -a "$lines[1]" = "$mt"
                    test (count $lines) -ge 2; and set ctx $lines[2]
                    test (count $lines) -ge 3; and set ns $lines[3]
                    set used_cache 1
                end
            end
            if test $used_cache = 0
                set -l data (_damin_k8s_compute $cfg)
                test (count $data) -ge 1; and set ctx $data[1]
                test (count $data) -ge 2; and set ns $data[2]
                mkdir -p $_damin_cache_dir 2>/dev/null
                set -l tmp "$cache.tmp.$fish_pid"
                printf '%s\n%s\n%s\n' "$mt" "$ctx" "$ns" >$tmp 2>/dev/null
                mv $tmp $cache 2>/dev/null
            end
            set -g _damin_k8s_mt $mt
            set -g _damin_k8s_ctx $ctx
            set -g _damin_k8s_ns $ns
        end
    end

    test -n "$ctx" -o $in_pod = 1; or return

    set -l label k8s
    test "$theme_damin_show_k8s_context" = 1 -a -n "$ctx"; and set label "$label:$ctx"
    test "$theme_damin_show_k8s_namespace" = 1 -a -n "$ns"; and set label "$label/$ns"
    echo -n -s $_damin_c_dim "$label " $_damin_c_normal
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
    _damin_aws_render
    _damin_gcp_render
    _damin_azure_render
    _damin_k8s_render
end

function _damin_git_compute
    set -l info (command git rev-parse --is-inside-work-tree --git-dir --git-common-dir 2>/dev/null)
    test "$info[1]" = true; or return
    set -l git_dir $info[2]
    set -l git_common $info[3]

    set -l branch
    set -l oid
    set -l has_upstream 0
    set -l untracked 0
    set -l modified 0
    set -l staged 0
    set -l ahead 0
    set -l behind 0
    set -l conflict 0

    for line in (command git status --porcelain=v2 --branch 2>/dev/null)
        switch (string sub -l 1 -- "$line")
            case '\?'
                set untracked (math $untracked + 1)
            case u
                set conflict (math $conflict + 1)
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
                    case branch.upstream
                        set has_upstream 1
                    case branch.ab
                        set ahead (string sub -s 2 -- $parts[3])
                        set behind (string sub -s 2 -- $parts[4])
                end
        end
    end

    # no upstream → porcelain v2 omits branch.ab; rev-list against remotes to keep ⇡N alive.
    if test $has_upstream = 0 -a "$ahead" = 0
        if test -n "$(command git remote 2>/dev/null)"
            set -l unpushed (command git rev-list --count HEAD --not --remotes 2>/dev/null)
            string match -rq '^\d+$' -- "$unpushed"; and set ahead $unpushed
        end
    end

    test "$branch" = '(detached)'; and set branch (string sub -l 8 -- $oid)
    test -z "$branch"; and set branch '?'

    set -l stashed 0
    set -l stash_log "$git_common/logs/refs/stash"
    test -f $stash_log; and set stashed (command wc -l <$stash_log 2>/dev/null | string trim)
    test -z "$stashed"; and set stashed 0

    set -l op ""
    if test "$theme_damin_show_git_op" = 1
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
    end

    printf '%s\n' "$branch" "$untracked" "$modified" "$staged" "$stashed" "$ahead" "$behind" "$conflict" "$op"
end

function _damin_git_cache_stale --argument-names cache_file
    test -n "$_damin_vcs_dir"; or return 1
    # path mtime is a builtin (no fork). index/HEAD/logs/HEAD catch out-of-shell commits.
    set -l mt (path mtime $cache_file "$_damin_vcs_dir/index" "$_damin_vcs_dir/HEAD" "$_damin_vcs_dir/logs/HEAD" 2>/dev/null)
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
    echo -n -s $_damin_c_branch $branch $_damin_c_normal
    test -n "$op"; and echo -n -s " " $_damin_c_exit "($op)" $_damin_c_normal
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

# compute + write the git cache without rendering. used by warmup + async repaint.
function _damin_git_prefill
    set -l cache_file (_damin_cache_path git)
    set -l data (_damin_git_compute 2>/dev/null)
    test -n "$data"; and _damin_write_cache $cache_file "$PWD" $data
end

# universal-var IPC instead of --on-process-exit: backgrounded fish funcs don't set $last_pid.
function _damin_git_async_kickoff
    set -q _damin_git_refresh_running; and return
    set -g _damin_git_refresh_running 1
    set -l theme_file $_damin_theme_file
    set -l pwd $PWD
    fish -c "
        set -gx _damin_subshell 1
        cd '$pwd' 2>/dev/null
        source '$theme_file' 2>/dev/null
        _damin_git_prefill
        set -U _damin_async_repaint_token (random)
    " >/dev/null 2>&1 &
    disown 2>/dev/null
end

function _damin_async_repaint_handler --on-variable _damin_async_repaint_token
    set -e _damin_git_refresh_running
    commandline -f repaint 2>/dev/null
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
    set -l stale 0

    if test -f $cache_file
        set -l lines (_damin_read_lines $cache_file)
        if test (count $lines) -ge 10 -a "$lines[1]" = "$PWD"
            set data $lines[2..10]
            _damin_git_cache_stale $cache_file; and set stale 1
        end
    end

    # async_repaint mode: render stale/empty NOW, bg refresh + repaint on completion.
    if test "$theme_damin_async_repaint" = 1
        if test -z "$data" -o $stale = 1
            _damin_git_async_kickoff
        end
        test -z "$data"; and return
        _damin_git_render_data $data
        return
    end

    # default: sync compute on miss or stale.
    if test -z "$data" -o $stale = 1
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
    echo -n -s $_damin_c_branch $name $_damin_c_normal " " $_damin_c_deco $theme_damin_glyph_clean $_damin_c_normal
end

# silent skip when gh is missing, remote isn't github, or no PR is open.
function _damin_gh_compute --argument-names branch
    type -q gh 2>/dev/null; or return
    set -l remote (command git remote get-url origin 2>/dev/null)
    string match -q '*github.com*' -- $remote; or return
    set -l out (command gh pr view "$branch" --json number,isDraft --jq '"\(.number) \(.isDraft)"' 2>/dev/null)
    test -z "$out"; and return
    echo $out
end

function _damin_gh_render --argument-names branch
    test "$theme_damin_show_gh_pr" = 1; or return
    test -n "$branch"; or return
    set -l now (date +%s)
    set -l ttl $theme_damin_gh_pr_ttl
    if test "$_damin_gh_branch" != "$branch"; or test (math $now - $_damin_gh_at) -ge $ttl
        set -g _damin_gh_branch "$branch"
        set -g _damin_gh_at $now
        set -g _damin_gh_value (_damin_gh_compute "$branch")
    end
    test -n "$_damin_gh_value"; or return
    set -l parts (string split ' ' -- $_damin_gh_value)
    set -l num $parts[1]
    set -l draft $parts[2]
    set -l color $_damin_c_meta
    test "$draft" = true; and set color $_damin_c_dim
    echo -n -s " " $color "#$num" $_damin_c_normal
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
    set -l result (prompt_pwd --dir-length=$theme_damin_cwd_short --full-length-dirs=$theme_damin_cwd_keep 2>/dev/null)
    test -n "$result"; and echo $result; and return
    prompt_pwd
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

    test -z "$found_lang"; and return

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

    test -n "$value"; and echo -n -s " " $_damin_c_sep $theme_damin_glyph_sep " " $_damin_c_dim "$value" $_damin_c_normal
end

# $PULUMI_STACK wins; else read workspace file iff exactly one matches the project name
# (the *-<hash>-workspace.json suffix isn't reverse-engineerable from the path).
function _damin_pulumi_stack_for --argument-names proj_dir
    set -l proj_name
    for yaml in $proj_dir/Pulumi.yaml $proj_dir/Pulumi.yml
        test -f $yaml; or continue
        for line in (command cat $yaml 2>/dev/null)
            set -l m (string match -r '^name: *(.*)$' -- $line)
            if test (count $m) -ge 2
                set proj_name (string trim --chars '"' -- $m[2])
                break
            end
        end
        test -n "$proj_name"; and break
    end
    test -n "$proj_name"; or return

    set -q PULUMI_STACK; and test -n "$PULUMI_STACK"; and echo $PULUMI_STACK; and return

    set -l home_pulumi "$HOME/.pulumi"
    set -q PULUMI_HOME; and test -n "$PULUMI_HOME"; and set home_pulumi $PULUMI_HOME
    set -l ws_dir "$home_pulumi/workspaces"
    test -d $ws_dir; or return

    set -l matches
    for f in $ws_dir/$proj_name-*-workspace.json
        test -f $f; and set -a matches $f
    end
    test (count $matches) -eq 1; or return
    set -l stack (command cat $matches[1] 2>/dev/null | string match -gr '"stack":\s*"([^"]+)"' | head -1)
    test -n "$stack"; and echo $stack
end

# pwd-cached single walk-up; exits early once both segments resolve.
function _damin_devops_resolve
    test "$_damin_devops_pwd" = "$PWD"; and return
    set -g _damin_devops_pwd "$PWD"
    set -g _damin_devops_tf ""
    set -g _damin_devops_pl ""
    set -l want_tf 0
    set -l want_pl 0
    test "$theme_damin_show_terraform" = 1; and set want_tf 1
    test "$theme_damin_show_pulumi" = 1; and set want_pl 1
    test $want_tf = 0 -a $want_pl = 0; and return

    set -l dir $PWD
    set -l levels 0
    while test "$dir" != / -a $levels -lt 8
        if test $want_tf = 1 -a -d "$dir/.terraform"
            set -l env "$dir/.terraform/environment"
            if test -f $env
                set -l ws (command cat $env 2>/dev/null | string trim)
                test -n "$ws" -a "$ws" != default; and set -g _damin_devops_tf "$ws"
            end
            set want_tf 0
        end
        if test $want_pl = 1
            if test -f "$dir/Pulumi.yaml" -o -f "$dir/Pulumi.yml"
                set -g _damin_devops_pl (_damin_pulumi_stack_for $dir)
                set want_pl 0
            end
        end
        test $want_tf = 0 -a $want_pl = 0; and break
        set dir (path dirname $dir)
        set levels (math $levels + 1)
    end
end

function _damin_devops_render
    test "$theme_damin_show_terraform" = 1 -o "$theme_damin_show_pulumi" = 1; or return
    _damin_devops_resolve
    test -n "$_damin_devops_tf"; and echo -n -s " " $_damin_c_sep $theme_damin_glyph_sep " " $_damin_c_dim "tf:$_damin_devops_tf" $_damin_c_normal
    test -n "$_damin_devops_pl"; and echo -n -s " " $_damin_c_sep $theme_damin_glyph_sep " " $_damin_c_dim "pulumi:$_damin_devops_pl" $_damin_c_normal
end

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
    echo -n -s " " $_damin_c_sep $theme_damin_glyph_sep " " $color "$pct%" $_damin_c_normal
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
    echo -n -s " " $_damin_c_sep $theme_damin_glyph_sep " " $color (_damin_duration_format) $_damin_c_normal
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

function _damin_postexec --on-event fish_postexec
    set -l exit $status
    _damin_osc_enabled; and printf '\e]133;D;%s\a' $exit
    set -l cmd "$argv"

    if test "$theme_damin_notify_long_command" = 1 -a -n "$cmd"
        if test $CMD_DURATION -gt $theme_damin_notify_threshold
            set -l short (string sub -l 60 -- $cmd)
            set -l secs (math --scale=1 $CMD_DURATION/1000)
            # osc 9 = universal notification (iTerm2, Konsole, Windows Terminal, Final Term, ConEmu).
            printf '\e]9;%s (%ss, exit %s)\a' $short $secs $exit
            # also fire notify-send in background when available so the alert survives focus changes.
            type -q notify-send; and command notify-send -t 5000 "fish: $short" "$secs s · exit $exit" &
        end
    end

    if string match -qr '\b(git|jj|hub|gh)\b' -- $cmd
        if not string match -qr '\bgit\s+(status|log|diff|show|blame|ls-(files|tree)|cat-file|rev-(list|parse)|describe|name-rev|shortlog|whatchanged|reflog|grep|ls-remote|help|version)\b' -- $cmd
            command rm -f (_damin_cache_path git) 2>/dev/null
        end
        # state-changing gh pr subcommands invalidate the cached number.
        if string match -qr '\bgh\s+pr\s+(create|close|reopen|merge|edit)\b' -- $cmd
            set -g _damin_gh_branch ""
            set -g _damin_gh_at 0
        end
    end
    if string match -qr '\b(nvm|fnm|asdf|mise|pyenv|rbenv|rustup|volta|conda)\b' -- $cmd
        command rm -f (_damin_cache_path lang) 2>/dev/null
    end
    # `aws configure` / `gcloud config set` / `az account set` mutate same-second; force refresh.
    if string match -qr '\b(aws|gcloud|az)\b' -- $cmd
        set -g _damin_aws_cfg_mt ""
        set -g _damin_gcp_active_mt ""
        set -g _damin_gcp_cfg_mt ""
        set -g _damin_azure_mt ""
    end
    # terraform workspace / pulumi stack swaps invalidate the devops cache.
    if string match -qr '\b(terraform|tf|pulumi)\b' -- $cmd
        set -g _damin_devops_pwd ""
    end
    # kubectl mutating subcommands rewrite kubeconfig within the same mtime second.
    if string match -qr '\bkubectl\s+config\b' -- $cmd
        set -g _damin_k8s_mt ""
        command rm -f "$_damin_cache_dir/cloud-k8s" 2>/dev/null
    end
end

function _damin_transient_enter
    if test "$theme_damin_transient" = 1
        # skip incomplete buffers (status 2) — enter inserts a newline, no execute.
        commandline --is-valid 2>/dev/null
        if test $status -ne 2
            set -g _damin_in_transient 1
            commandline -f repaint
        end
    end
    commandline -f execute
end

# bind in every mode so vi `insert` (where editing happens) is covered too.
function _damin_install_transient_bindings
    for mode in default insert visual replace replace_one paste
        bind -M $mode \r _damin_transient_enter 2>/dev/null
        bind -M $mode \n _damin_transient_enter 2>/dev/null
    end
end

# `fish_{default,vi}_key_bindings` wipe all bindings; re-install after the swap.
function _damin_reinstall_transient_bindings --on-variable fish_key_bindings
    _damin_install_transient_bindings
end

# defined in conf.d/ (not functions/) so fisher doesn't copy a stub that omf would flag as conflicting.

function fish_prompt
    set -l last_status $status

    _damin_osc133_a
    _damin_osc7_emit

    # 1 = render stub then advance; 2 = clear + render full. owned here so an overridden
    # fish_right_prompt can't strand the flag.
    switch "$_damin_in_transient"
        case 1
            echo -n -s " " $_damin_c_ok "$theme_damin_glyph_prompt " $_damin_c_normal
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

    echo -n -s " " $_damin_c_deco "$theme_damin_glyph_cwd " $_damin_c_cwd (_damin_cwd_pretty) $_damin_c_normal

    _damin_lang_render
    _damin_devops_render
    _damin_env_render
    _damin_battery_render
    _damin_duration_render
    _damin_extra_segments_render right
end

# one bg fork warms every prefill — fish's `&` forks the current shell, no reload.
function _damin_warmup
    if test "$theme_damin_async_git" = 1
        test (_damin_detect_vcs) = git; and _damin_git_prefill
    end
    test "$theme_damin_show_k8s_context" = 1; and _damin_k8s_prefill
end

# async_repaint subshell needs only the function defs; skip init side effects.
if not set -q _damin_subshell
    _damin_cache_prune
    _damin_install_transient_bindings

    if test "$theme_damin_async_warmup" = 1
        _damin_warmup >/dev/null 2>&1 &
        disown 2>/dev/null
    end
end

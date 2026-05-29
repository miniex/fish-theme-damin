function damin_help
    if contains -- "$argv[1]" --help -h
        _damin_help_block damin_help 'list every theme_damin_* toggle, current value, default' \
            'damin_help [PATTERN] [--json]' \
            -- \
            'PATTERN substring-filters var names (e.g. `damin_help git`).' \
            '--json dumps every row as JSON for dotfile / CI tooling.' \
            'for read/write of universals see: damin_config --help.'
        return
    end
    set -l filter
    set -g _damin_help_mode text
    for arg in $argv
        switch $arg
            case --json
                set -g _damin_help_mode json
            case '*'
                test -z "$filter"; and set filter $arg
        end
    end
    if test -n "$filter"
        set -g _damin_help_filter $filter
        set -e _damin_help_matched
    end
    if test "$_damin_help_mode" = json
        set -g _damin_help_first 1
        printf '['
    end
    set -l c_dim (set_color --dim)
    set -l c_norm (set_color normal)

    if test "$_damin_help_mode" = text
        echo
        printf '  %sdamin%s — config\n' (set_color E890B0 -o) (set_color normal)
        echo
        echo "  toggles (1 = on, 0 = off)"
    end
    # defaults below come from the shared registry (_damin_defaults); only vars
    # that are unset-by-default or computed pass an explicit default here.
    _damin_help_row theme_damin_show_git
    _damin_help_row theme_damin_show_jj
    _damin_help_row theme_damin_show_hg
    _damin_help_row theme_damin_show_fossil
    _damin_help_row theme_damin_show_git_op
    _damin_help_row theme_damin_hide_default_branch
    _damin_help_row theme_damin_show_context
    _damin_help_row theme_damin_show_k8s_context
    _damin_help_row theme_damin_show_k8s_namespace
    _damin_help_row theme_damin_show_screen
    _damin_help_row theme_damin_show_sudo_user
    _damin_help_row theme_damin_show_docker_machine
    _damin_help_row theme_damin_show_wsl
    _damin_help_row theme_damin_show_codespaces
    _damin_help_row theme_damin_show_devcontainer
    _damin_help_row theme_damin_show_tmux
    _damin_help_row theme_damin_show_zellij
    _damin_help_row theme_damin_show_jobs
    _damin_help_row theme_damin_show_env
    _damin_help_row theme_damin_show_nix_name
    _damin_help_row theme_damin_show_lang
    _damin_help_row theme_damin_show_lang_global
    _damin_help_row theme_damin_show_battery
    _damin_help_row theme_damin_show_duration
    _damin_help_row theme_damin_show_date
    _damin_help_row theme_damin_show_vi_mode
    _damin_help_row theme_damin_show_aws
    _damin_help_row theme_damin_show_aws_region
    _damin_help_row theme_damin_show_gcp
    _damin_help_row theme_damin_show_azure
    _damin_help_row theme_damin_show_terraform
    _damin_help_row theme_damin_show_pulumi
    _damin_help_row theme_damin_show_gh_pr
    _damin_help_row theme_damin_show_project_parent
    _damin_help_row theme_damin_stash_age
    _damin_help_row theme_damin_hg_dirty
    _damin_help_row theme_damin_jj_counts
    _damin_help_row theme_damin_notify_long_command
    _damin_help_row theme_damin_git_counts
    _damin_help_row theme_damin_git_count_untracked
    _damin_help_row theme_damin_newline_prompt
    _damin_help_row theme_damin_transient
    _damin_help_row theme_damin_async_git
    _damin_help_row theme_damin_async_lang
    _damin_help_row theme_damin_async_warmup
    _damin_help_row theme_damin_async_repaint
    _damin_help_row theme_damin_osc_integration
    _damin_help_row theme_damin_apply_colors
    _damin_help_row theme_damin_ascii
    _damin_help_row theme_damin_nerd_font
    if test "$_damin_help_mode" = text
        echo
        echo "  enums / strings"
    end
    _damin_help_row theme_damin_show_exit_code
    _damin_help_row theme_damin_show_user
    _damin_help_row theme_damin_show_host
    _damin_help_row theme_damin_default_user '(unset)'
    _damin_help_row theme_damin_title_show_user
    _damin_help_row theme_damin_title_show_path
    _damin_help_row theme_damin_title_show_process
    _damin_help_row theme_damin_date_format
    _damin_help_row theme_damin_date_timezone '(unset)'
    _damin_help_row theme_damin_issue_url_template '(unset)'
    _damin_help_row theme_damin_palette
    _damin_help_row theme_damin_palette_light '(unset)'
    if test "$_damin_help_mode" = text
        echo
        echo "  palette accent overrides (hex without #; defaults shift per palette)"
    end
    _damin_help_row theme_damin_accent_primary 98ABCC
    _damin_help_row theme_damin_accent_secondary E890B0
    if test "$_damin_help_mode" = text
        echo
        echo "  numeric"
    end
    _damin_help_row theme_damin_cwd_keep
    _damin_help_row theme_damin_cwd_short
    _damin_help_row theme_damin_project_dir_length
    _damin_help_row theme_damin_branch_max_len
    _damin_help_row theme_damin_cloud_max_len
    _damin_help_row theme_damin_k8s_max_len
    _damin_help_row theme_damin_aws_max_len
    _damin_help_row theme_damin_gcp_max_len
    _damin_help_row theme_damin_azure_max_len
    _damin_help_row theme_damin_long_command_threshold
    _damin_help_row theme_damin_battery_threshold
    _damin_help_row theme_damin_gh_pr_ttl
    _damin_help_row theme_damin_notify_threshold
    _damin_help_row theme_damin_async_timeout
    if test "$_damin_help_mode" = text
        echo
        echo "  glyphs (override individually; theme_damin_ascii=1 swaps all defaults)"
    end
    if test "$theme_damin_ascii" = 1
        _damin_help_row theme_damin_glyph_prompt '*'
        _damin_help_row theme_damin_glyph_transient '*'
        _damin_help_row theme_damin_glyph_cwd '>'
        _damin_help_row theme_damin_glyph_clean '~'
        _damin_help_row theme_damin_glyph_modified '!'
        _damin_help_row theme_damin_glyph_added '+'
        _damin_help_row theme_damin_glyph_untracked '?'
        _damin_help_row theme_damin_glyph_stashed '$'
        _damin_help_row theme_damin_glyph_ahead '^'
        _damin_help_row theme_damin_glyph_behind v
        _damin_help_row theme_damin_glyph_conflict X
        _damin_help_row theme_damin_glyph_sep '|'
    else
        _damin_help_row theme_damin_glyph_prompt ✿
        _damin_help_row theme_damin_glyph_transient ✿
        _damin_help_row theme_damin_glyph_cwd ❥
        _damin_help_row theme_damin_glyph_clean ✧
        _damin_help_row theme_damin_glyph_modified ✗
        _damin_help_row theme_damin_glyph_added ✓
        _damin_help_row theme_damin_glyph_untracked '?'
        _damin_help_row theme_damin_glyph_stashed '$'
        _damin_help_row theme_damin_glyph_ahead ⇡
        _damin_help_row theme_damin_glyph_behind ⇣
        _damin_help_row theme_damin_glyph_conflict X
        _damin_help_row theme_damin_glyph_sep ·
    end
    # list-typed rows reuse the same row format (space-joined values).
    _damin_help_row theme_damin_default_branches
    _damin_help_row theme_damin_vcs_ignore_paths '(unset)'
    _damin_help_row theme_damin_right_segments

    if test "$_damin_help_mode" = json
        printf ']\n'
        set -e _damin_help_filter
        set -e _damin_help_matched
        set -e _damin_help_mode
        set -e _damin_help_first
        return
    end

    echo
    echo "  commands (every command takes --help / -h)"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_config (set_color normal) "wizard / get / set / reset / export / edit — see damin_config --help"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_help (set_color normal) "this listing (--json for dotfile / CI tooling)"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_doctor (set_color normal) "environment + font diagnostic (--json)"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_profile (set_color normal) "time each segment (damin_profile [N=20])"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_bench (set_color normal) "per-segment P50/P95/P99 (damin_bench [N=1000] [--json])"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_set_palette (set_color normal) "switch palette (19 flavors — tab-completes)"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_palette_preview (set_color normal) "render a sample prompt in <flavor> without applying"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_install_themes (set_color normal) "write .theme files for fish_config theme show"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_uninstall_themes (set_color normal) "remove the Damin .theme files (confirms)"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_reset_cache (set_color normal) "wipe $_damin_cache_dir"
    echo
    echo "  set:        $c_dim""set -U theme_damin_show_jobs 0$c_norm"
    echo "  unset:      $c_dim""set -e theme_damin_show_jobs$c_norm"
    echo "  list:       $c_dim""set -U theme_damin_default_branches main master develop$c_norm"
    echo "  ignore:     $c_dim""set -U theme_damin_vcs_ignore_paths '/mnt/nfs/*' '/Volumes/*'$c_norm"
    echo "  hooks:      $c_dim""set -U theme_damin_extra_left  <fn1> <fn2>$c_norm  (defines damin_segment_<fn>)"
    echo "              $c_dim""set -U theme_damin_extra_right <fn>$c_norm"
    echo
    if test -n "$filter"; and not set -q _damin_help_matched
        printf '  %sno theme_damin_* names match `%s`%s\n\n' $c_dim $filter $c_norm
    end
    set -e _damin_help_filter
    set -e _damin_help_matched
    set -e _damin_help_mode
    set -e _damin_help_first
end

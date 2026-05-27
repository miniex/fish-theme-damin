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
    _damin_help_row theme_damin_show_git 1
    _damin_help_row theme_damin_show_jj 1
    _damin_help_row theme_damin_show_hg 0
    _damin_help_row theme_damin_show_fossil 0
    _damin_help_row theme_damin_show_git_op 1
    _damin_help_row theme_damin_hide_default_branch 0
    _damin_help_row theme_damin_show_context 1
    _damin_help_row theme_damin_show_k8s_context 1
    _damin_help_row theme_damin_show_k8s_namespace 0
    _damin_help_row theme_damin_show_screen 0
    _damin_help_row theme_damin_show_sudo_user 0
    _damin_help_row theme_damin_show_docker_machine 0
    _damin_help_row theme_damin_show_wsl 0
    _damin_help_row theme_damin_show_codespaces 0
    _damin_help_row theme_damin_show_devcontainer 0
    _damin_help_row theme_damin_show_tmux 0
    _damin_help_row theme_damin_show_zellij 0
    _damin_help_row theme_damin_show_jobs 1
    _damin_help_row theme_damin_show_env 1
    _damin_help_row theme_damin_show_nix_name 1
    _damin_help_row theme_damin_show_lang 1
    _damin_help_row theme_damin_show_lang_global 0
    _damin_help_row theme_damin_show_battery 0
    _damin_help_row theme_damin_show_duration 1
    _damin_help_row theme_damin_show_date 0
    _damin_help_row theme_damin_show_vi_mode 1
    _damin_help_row theme_damin_show_aws 0
    _damin_help_row theme_damin_show_aws_region 1
    _damin_help_row theme_damin_show_gcp 0
    _damin_help_row theme_damin_show_azure 0
    _damin_help_row theme_damin_show_terraform 1
    _damin_help_row theme_damin_show_pulumi 1
    _damin_help_row theme_damin_show_gh_pr 0
    _damin_help_row theme_damin_show_project_parent 1
    _damin_help_row theme_damin_stash_age 0
    _damin_help_row theme_damin_hg_dirty 0
    _damin_help_row theme_damin_jj_counts 0
    _damin_help_row theme_damin_notify_long_command 0
    _damin_help_row theme_damin_git_counts 1
    _damin_help_row theme_damin_git_count_untracked 1
    _damin_help_row theme_damin_newline_prompt 0
    _damin_help_row theme_damin_transient 1
    _damin_help_row theme_damin_async_git 1
    _damin_help_row theme_damin_async_lang 1
    _damin_help_row theme_damin_async_warmup 1
    _damin_help_row theme_damin_async_repaint 1
    _damin_help_row theme_damin_osc_integration 1
    _damin_help_row theme_damin_apply_colors 1
    _damin_help_row theme_damin_ascii 0
    if test "$_damin_help_mode" = text
        echo
        echo "  enums / strings"
    end
    _damin_help_row theme_damin_show_exit_code number
    _damin_help_row theme_damin_show_user ssh
    _damin_help_row theme_damin_show_host ssh
    _damin_help_row theme_damin_default_user '(unset)'
    _damin_help_row theme_damin_title_show_user ssh
    _damin_help_row theme_damin_title_show_path 1
    _damin_help_row theme_damin_title_show_process 1
    _damin_help_row theme_damin_date_format '%H:%M'
    _damin_help_row theme_damin_date_timezone '(unset)'
    _damin_help_row theme_damin_issue_url_template '(unset)'
    _damin_help_row theme_damin_palette mocha
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
    _damin_help_row theme_damin_cwd_keep 3
    _damin_help_row theme_damin_cwd_short 4
    _damin_help_row theme_damin_project_dir_length 0
    _damin_help_row theme_damin_branch_max_len 0
    _damin_help_row theme_damin_cloud_max_len 0
    _damin_help_row theme_damin_k8s_max_len 0
    _damin_help_row theme_damin_aws_max_len 0
    _damin_help_row theme_damin_gcp_max_len 0
    _damin_help_row theme_damin_azure_max_len 0
    _damin_help_row theme_damin_long_command_threshold 3000
    _damin_help_row theme_damin_battery_threshold 30
    _damin_help_row theme_damin_gh_pr_ttl 300
    _damin_help_row theme_damin_notify_threshold 30000
    _damin_help_row theme_damin_async_timeout 5
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
    _damin_help_row theme_damin_default_branches 'main master trunk'
    _damin_help_row theme_damin_vcs_ignore_paths '(unset)'
    _damin_help_row theme_damin_right_segments 'cwd lang devops env battery duration date extra'

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

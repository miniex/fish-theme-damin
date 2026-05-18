function damin_help
    if contains -- "$argv[1]" --help -h
        _damin_help_block damin_help 'list every theme_damin_* toggle, current value, default' \
            'damin_help [PATTERN]' \
            -- \
            'PATTERN substring-filters var names (e.g. `damin_help git`).' \
            'for read/write of universals see: damin_config --help.'
        return
    end
    set -l filter $argv[1]
    if test -n "$filter"
        set -g _damin_help_filter $filter
        set -e _damin_help_matched
    end
    set -l c_dim (set_color --dim)
    set -l c_norm (set_color normal)

    echo
    printf '  %sdamin%s — config\n' (set_color E890B0 -o) (set_color normal)
    echo
    echo "  toggles (1 = on, 0 = off)"
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
    _damin_help_row theme_damin_notify_long_command 0
    _damin_help_row theme_damin_git_counts 1
    _damin_help_row theme_damin_git_count_untracked 1
    _damin_help_row theme_damin_newline_prompt 0
    _damin_help_row theme_damin_transient 1
    _damin_help_row theme_damin_async_git 1
    _damin_help_row theme_damin_async_lang 1
    _damin_help_row theme_damin_async_warmup 1
    _damin_help_row theme_damin_async_repaint 0
    _damin_help_row theme_damin_osc_integration 1
    _damin_help_row theme_damin_apply_colors 1
    _damin_help_row theme_damin_ascii 0
    echo
    echo "  enums / strings"
    _damin_help_row theme_damin_show_exit_code number
    _damin_help_row theme_damin_show_user ssh
    _damin_help_row theme_damin_show_host ssh
    _damin_help_row theme_damin_default_user '(unset)'
    _damin_help_row theme_damin_title_show_user ssh
    _damin_help_row theme_damin_title_show_path 1
    _damin_help_row theme_damin_title_show_process 1
    _damin_help_row theme_damin_date_format '%H:%M'
    _damin_help_row theme_damin_date_timezone '(unset)'
    _damin_help_row theme_damin_palette mocha
    _damin_help_row theme_damin_palette_light '(unset)'
    echo
    echo "  palette accent overrides (hex without #; defaults shift per palette)"
    _damin_help_row theme_damin_accent_primary 98ABCC
    _damin_help_row theme_damin_accent_secondary E890B0
    echo
    echo "  numeric"
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
    echo
    echo "  glyphs (override individually; theme_damin_ascii=1 swaps all defaults)"
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
    echo
    echo "  commands (every command takes --help / -h)"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_config (set_color normal) "wizard / get / set / reset / export — see damin_config --help"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_help (set_color normal) "this listing"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_doctor (set_color normal) "environment + font diagnostic"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_profile (set_color normal) "time each segment (damin_profile [N=20])"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_bench (set_color normal) "per-segment P50/P95/P99 (damin_bench [N=1000] [--json])"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_set_palette (set_color normal) "switch palette (18 flavors — tab-completes)"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_install_themes (set_color normal) "write .theme files for fish_config theme show"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_uninstall_themes (set_color normal) "remove the Damin .theme files (confirms)"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_reset_cache (set_color normal) "wipe $_damin_cache_dir"
    echo
    echo "  lists (set -U <var> <items…>)"
    set -l _db_default "main master trunk"
    set -l _db_val (set -q theme_damin_default_branches; and string join ' ' -- $theme_damin_default_branches)
    set -l _db_color (set_color E890B0)
    test "$_db_val" = "$_db_default"; and set _db_color (set_color --dim)
    printf '  %-38s %s%s%s %sdefault %s%s\n' theme_damin_default_branches $_db_color "[$_db_val]" $c_norm (set_color --dim) "[$_db_default]" $c_norm
    set -l _ip_val ""
    set -q theme_damin_vcs_ignore_paths; and set _ip_val (string join ' ' -- $theme_damin_vcs_ignore_paths)
    printf '  %-38s %s%s%s %sdefault %s%s\n' theme_damin_vcs_ignore_paths (set_color E890B0) "[$_ip_val]" $c_norm (set_color --dim) "[]" $c_norm
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
end

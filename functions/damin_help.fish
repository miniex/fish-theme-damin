function damin_help
    set -l c_dim (set_color --dim)
    set -l c_norm (set_color normal)

    echo
    printf '  %sdamin%s — config\n' (set_color E890B0 -o) (set_color normal)
    echo
    echo "  toggles (1 = on, 0 = off)"
    _damin_help_row theme_damin_show_git 1
    _damin_help_row theme_damin_show_jj 1
    _damin_help_row theme_damin_show_git_op 1
    _damin_help_row theme_damin_show_context 1
    _damin_help_row theme_damin_show_k8s_context 1
    _damin_help_row theme_damin_show_k8s_namespace 0
    _damin_help_row theme_damin_show_jobs 1
    _damin_help_row theme_damin_show_env 1
    _damin_help_row theme_damin_show_nix_name 1
    _damin_help_row theme_damin_show_lang 1
    _damin_help_row theme_damin_show_battery 0
    _damin_help_row theme_damin_show_duration 1
    _damin_help_row theme_damin_show_vi_mode 1
    _damin_help_row theme_damin_show_aws 0
    _damin_help_row theme_damin_show_aws_region 1
    _damin_help_row theme_damin_show_gcp 0
    _damin_help_row theme_damin_show_azure 0
    _damin_help_row theme_damin_show_gh_pr 0
    _damin_help_row theme_damin_notify_long_command 0
    _damin_help_row theme_damin_git_counts 1
    _damin_help_row theme_damin_transient 1
    _damin_help_row theme_damin_async_git 1
    _damin_help_row theme_damin_async_lang 1
    _damin_help_row theme_damin_async_warmup 1
    _damin_help_row theme_damin_async_repaint 0
    _damin_help_row theme_damin_osc_integration 1
    _damin_help_row theme_damin_apply_colors 1
    _damin_help_row theme_damin_ascii 0
    echo
    echo "  enums"
    _damin_help_row theme_damin_show_exit_code number
    _damin_help_row theme_damin_palette mocha
    echo
    echo "  numeric"
    _damin_help_row theme_damin_cwd_keep 3
    _damin_help_row theme_damin_cwd_short 4
    _damin_help_row theme_damin_long_command_threshold 3000
    _damin_help_row theme_damin_battery_threshold 30
    _damin_help_row theme_damin_gh_pr_ttl 300
    _damin_help_row theme_damin_notify_threshold 30000
    echo
    echo "  glyphs (override individually; theme_damin_ascii=1 swaps all defaults)"
    if test "$theme_damin_ascii" = 1
        _damin_help_row theme_damin_glyph_prompt '*'
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
    echo "  commands"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_config (set_color normal) "interactive setup wizard"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_help (set_color normal) "this listing"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_doctor (set_color normal) "environment + font diagnostic"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_set_palette (set_color normal) "switch catppuccin flavor (mocha|frappe|macchiato|latte)"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_install_themes (set_color normal) "write .theme files for fish_config theme show"
    printf '    %s%-22s%s  %s\n' (set_color 98ABCC) damin_reset_cache (set_color normal) "wipe $_damin_cache_dir"
    echo
    echo "  set:        $c_dim""set -U theme_damin_show_jobs 0$c_norm"
    echo "  unset:      $c_dim""set -e theme_damin_show_jobs$c_norm"
    echo "  hooks:      $c_dim""set -U theme_damin_extra_left  <fn1> <fn2>$c_norm  (defines damin_segment_<fn>)"
    echo "              $c_dim""set -U theme_damin_extra_right <fn>$c_norm"
    echo
end

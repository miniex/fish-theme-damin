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
    _damin_help_row theme_damin_show_jobs 1
    _damin_help_row theme_damin_show_env 1
    _damin_help_row theme_damin_show_lang 1
    _damin_help_row theme_damin_show_battery 0
    _damin_help_row theme_damin_show_duration 1
    _damin_help_row theme_damin_show_exit_code 1
    _damin_help_row theme_damin_git_counts 1
    _damin_help_row theme_damin_transient 1
    _damin_help_row theme_damin_async_git 1
    _damin_help_row theme_damin_async_lang 1
    _damin_help_row theme_damin_apply_colors 1
    echo
    echo "  numeric"
    _damin_help_row theme_damin_cwd_keep 3
    _damin_help_row theme_damin_cwd_short 4
    _damin_help_row theme_damin_long_command_threshold 3000
    _damin_help_row theme_damin_battery_threshold 30
    echo
    echo "  commands"
    printf '    %s%-18s%s  %s\n' (set_color 98ABCC) damin_help (set_color normal) "this listing"
    printf '    %s%-18s%s  %s\n' (set_color 98ABCC) damin_doctor (set_color normal) "environment + font diagnostic"
    printf '    %s%-18s%s  %s\n' (set_color 98ABCC) damin_reset_cache (set_color normal) "wipe $_damin_cache_dir"
    echo
    echo "  set:        $c_dim""set -U theme_damin_show_jobs 0$c_norm"
    echo "  unset:      $c_dim""set -e theme_damin_show_jobs$c_norm"
    echo
end

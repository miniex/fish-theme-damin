# single source of truth for scalar/list defaults — consumed by conf.d/damin.fish
# (apply at load) and damin_help (display). each line: "<var-suffix> <default…>".
# NOT here (computed or unset-by-default): accent_primary/secondary, palette_light,
# default_user, issue_url_template, date_timezone, glyph_* — see conf.d/damin.fish.
function _damin_defaults
    # context / identity. host/user: no | ssh | always.
    printf '%s\n' \
        'show_context 1' 'show_host ssh' 'show_user ssh' \
        'show_screen 0' 'show_sudo_user 0' 'show_docker_machine 0' \
        'show_wsl 0' 'show_codespaces 0' 'show_devcontainer 0' \
        'show_tmux 0' 'show_zellij 0'
    # cloud
    printf '%s\n' \
        'show_aws 0' 'show_aws_region 1' 'show_gcp 0' 'show_azure 0' \
        'show_k8s_context 1' 'show_k8s_namespace 0'
    # vcs. branch_max_len 0 = no limit. default_branches feed hide_default_branch.
    printf '%s\n' \
        'show_git 1' 'show_jj 1' 'jj_counts 0' 'show_hg 0' 'show_fossil 0' \
        'show_git_op 1' 'hg_dirty 0' 'hide_default_branch 0' \
        'default_branches main master trunk' 'branch_max_len 0' \
        'show_gh_pr 0' 'stash_age 0'
    # cloud-label truncation. per-segment (>0) wins; else cloud_max_len umbrella.
    printf '%s\n' \
        'cloud_max_len 0' 'k8s_max_len 0' 'aws_max_len 0' 'gcp_max_len 0' 'azure_max_len 0'
    # segments. show_exit_code: 0|off|hidden | 1|number | name | both.
    printf '%s\n' \
        'show_jobs 1' 'show_exit_code number' 'show_vi_mode 1' \
        'show_lang 1' 'show_lang_global 0' 'show_env 1' 'show_nix_name 1' \
        'show_terraform 1' 'show_pulumi 1' 'show_battery 0' 'show_duration 1' \
        'show_date 0' 'date_format %H:%M'
    # behavior. async_signal: override only if SIGUSR1 collides. async_timeout 0 = off.
    # async_threshold (ms): repos with git status faster than this stay inline; 0 = always async.
    printf '%s\n' \
        'git_counts 1' 'git_count_untracked 1' 'transient 1' \
        'async_git 1' 'async_lang 1' 'async_warmup 1' 'async_repaint 1' \
        'async_gh_pr 1' 'async_signal SIGUSR1' 'async_timeout 5' \
        'async_threshold 80' \
        'osc_integration 1' 'notify_long_command 0' 'apply_colors 1' \
        'palette mocha' 'ascii 0' 'nerd_font 0' 'newline_prompt 0'
    # terminal title. user 0|1|ssh, path 0|1|short, process 0|1.
    printf '%s\n' \
        'title_show_user ssh' 'title_show_path 1' 'title_show_process 1'
    # path + numeric thresholds.
    printf '%s\n' \
        'cwd_keep 3' 'cwd_short 4' 'show_project_parent 1' 'project_dir_length 0' \
        'long_command_threshold 3000' \
        'right_segments cwd lang devops env battery duration date extra' \
        'battery_threshold 30' 'gh_pr_ttl 300' 'notify_threshold 30000'
end

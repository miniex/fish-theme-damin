function damin_doctor
    if contains -- "$argv[1]" --help -h
        _damin_help_block damin_doctor 'environment + install diagnostic' \
            'damin_doctor [--json] [--fix]' \
            -- \
            '--json emits one JSON object per check for CI / issue reporting.' \
            '--fix  auto-resolves safe items: orphan fish_prompt symlink, leaked' \
            '       universal _damin_in_transient, missing cache dir.'
        return
    end
    set -g _damin_doctor_mode text
    contains -- --json $argv; and set -g _damin_doctor_mode json
    set -g _damin_doctor_fix 0
    contains -- --fix $argv; and set -g _damin_doctor_fix 1
    if test "$_damin_doctor_mode" = json
        set -g _damin_doctor_first 1
        printf '['
    end
    set -l parts (string split . -- $FISH_VERSION)
    set -l major $parts[1]
    set -l minor $parts[2]
    if test $major -gt 3 -o \( $major -eq 3 -a $minor -ge 7 \)
        _damin_doctor_check "fish ≥ 3.7" ok "($FISH_VERSION)"
    else
        _damin_doctor_check "fish ≥ 3.7" fail "(found $FISH_VERSION — need 3.7 for path mtime)"
    end

    set -l manager
    functions -q omf; and set manager "$manager omf"
    functions -q fisher; and set manager "$manager fisher"
    if test -n "$manager"
        _damin_doctor_check "plugin manager" ok "($(string trim -- $manager))"
    else
        _damin_doctor_check "plugin manager" fail "(neither omf nor fisher detected)"
    end

    # accept any installed name (omf install -> fish-theme-damin, local symlink -> anything).
    set -l omf_root $OMF_PATH
    test -z "$omf_root"; and set omf_root $HOME/.local/share/omf
    if functions -q omf
        set -l theme (command cat ~/.config/omf/theme 2>/dev/null)
        set -l damin_names
        for d in $omf_root/themes/*/
            test -f $d/conf.d/damin.fish; and set damin_names $damin_names (path basename $d)
        end
        if contains -- $theme $damin_names
            _damin_doctor_check "omf active theme" ok "($theme)"
        else if test (count $damin_names) -gt 0
            _damin_doctor_check "omf active theme" fail "(current: $theme — run: omf theme $damin_names[1])"
        else
            _damin_doctor_check "omf active theme" fail "(current: $theme — no damin theme found under $omf_root/themes/)"
        end
    end

    set -l prompt_src (functions --details fish_prompt 2>/dev/null)
    if test -z "$prompt_src" -o "$prompt_src" = n/a -o "$prompt_src" = stdin
        _damin_doctor_check "fish_prompt loaded" fail "(function not defined — theme not active)"
    else
        _damin_doctor_check "fish_prompt loaded" ok "($prompt_src)"
    end

    # only OMF should leave this here (symlink -> themes/<active>/). anything
    # else trips OMF's "Conflicting prompt setting" check.
    set -l user_fp ~/.config/fish/functions/fish_prompt.fish
    if not test -e $user_fp -o -L $user_fp
        _damin_doctor_check "fish_prompt symlink" ok "(none — fisher-style install)"
    else if functions -q omf
        set -l theme (command cat ~/.config/omf/theme 2>/dev/null)
        set -l want $omf_root/themes/$theme/fish_prompt.fish
        if test -L $user_fp; and contains -- (readlink $user_fp) $want
            _damin_doctor_check "fish_prompt symlink" ok "(omf -> themes/$theme)"
        else
            _damin_doctor_check "fish_prompt symlink" fail "(target ≠ themes/$theme — fix: rm $user_fp; then omf theme $theme)"
        end
    else
        if test "$_damin_doctor_fix" = 1
            command rm -f $user_fp
            _damin_doctor_check "fish_prompt symlink" ok "(removed orphan: $user_fp)"
        else
            _damin_doctor_check "fish_prompt symlink" fail "($user_fp exists without omf — delete it: rm $user_fp, or rerun with --fix)"
        end
    end
    set -l stray_rp ~/.config/fish/functions/fish_right_prompt.fish
    if test -e $stray_rp
        if test "$_damin_doctor_fix" = 1
            command rm -f $stray_rp
            _damin_doctor_check "no stray fish_right_prompt.fish" ok "(removed: $stray_rp)"
        else
            _damin_doctor_check "no stray fish_right_prompt.fish" fail "(damin doesn't ship this — delete to avoid override, or rerun with --fix)"
        end
    else
        _damin_doctor_check "no stray fish_right_prompt.fish" ok
    end

    if test "$theme_damin_show_hg" = 1
        if test -d "$_damin_vcs_dir"; and test "$_damin_vcs_value" = hg
            _damin_doctor_check "hg repo detected" ok "($_damin_vcs_dir)"
        else
            _damin_doctor_check "hg support" ok "enabled (theme_damin_show_hg=1)"
        end
    end

    if test "$theme_damin_show_fossil" = 1
        if type -q fossil
            _damin_doctor_check "fossil cli" ok (command -v fossil)
        else
            _damin_doctor_check "fossil cli" fail "(theme_damin_show_fossil=1 but `fossil` not on PATH)"
        end
    end

    if set -q AWS_VAULT; and test -n "$AWS_VAULT"
        _damin_doctor_check "aws-vault session" ok "($AWS_VAULT)"
    end

    if set -q theme_damin_default_user; and test -n "$theme_damin_default_user"
        set -l ufx 'matches — user suppressed'
        test "$USER" = "$theme_damin_default_user"; or set ufx "($USER differs from default_user=$theme_damin_default_user)"
        _damin_doctor_check default_user ok "$ufx"
    end

    set -q theme_damin_vcs_ignore_paths; and test (count $theme_damin_vcs_ignore_paths) -gt 0; and _damin_doctor_check "vcs ignore paths" ok "($theme_damin_vcs_ignore_paths)"

    set -l ssh_state inactive
    test -n "$SSH_CONNECTION$SSH_CLIENT$SSH_TTY"; and set ssh_state "active ($USER@"(command hostname 2>/dev/null | string trim)")"
    _damin_doctor_check "ssh session" ok $ssh_state

    set -l missing
    for cmd in damin_config damin_help damin_set_palette damin_install_themes damin_reset_cache damin_profile damin_bench
        type -q $cmd; or set missing $missing $cmd
    end
    if test (count $missing) -gt 0
        _damin_doctor_check "damin commands" fail "(not on autoload path: $missing — try exec fish)"
    else
        _damin_doctor_check "damin commands" ok
    end

    if mkdir -p $_damin_cache_dir 2>/dev/null; and test -w $_damin_cache_dir
        _damin_doctor_check "cache dir writable" ok "($_damin_cache_dir)"
    else if test "$_damin_doctor_fix" = 1
        command mkdir -p $_damin_cache_dir 2>/dev/null
        if test -w $_damin_cache_dir
            _damin_doctor_check "cache dir writable" ok "(created: $_damin_cache_dir)"
        else
            _damin_doctor_check "cache dir writable" fail "(could not create $_damin_cache_dir — check permissions)"
        end
    else
        _damin_doctor_check "cache dir writable" fail '(rerun with --fix to mkdir)'
    end

    set -l n_caches (count (path filter -tf $_damin_cache_dir/* 2>/dev/null))
    _damin_doctor_check "cache entries" ok "$n_caches files"

    if test "$theme_damin_ascii" = 1
        _damin_doctor_check "ascii glyph mode" ok "(theme_damin_ascii=1)"
    else
        _damin_doctor_check "ascii glyph mode" ok "off — set -U theme_damin_ascii 1 if any glyph below shows as '?'"
    end

    set -l dumb_reason
    test "$TERM" = dumb; and set dumb_reason "TERM=dumb"
    set -q INSIDE_EMACS; and test -n "$INSIDE_EMACS"; and set dumb_reason "INSIDE_EMACS=$INSIDE_EMACS"
    if test -n "$dumb_reason"
        _damin_doctor_check "dumb terminal" ok "auto-minimal applied ($dumb_reason)"
    else
        _damin_doctor_check "dumb terminal" ok "no — full prompt active"
    end

    if test "$theme_damin_transient" = 1
        set -l missing_modes
        for mode in default insert
            if not bind -M $mode \r 2>/dev/null | string match -q '*_damin_transient_enter*'
                set missing_modes $missing_modes $mode
            end
        end
        if test (count $missing_modes) -gt 0
            _damin_doctor_check "transient binding" fail "(Enter not bound in modes: $missing_modes — another plugin (fzf, atuin, …) likely rebound \r after damin loaded; rebind with bind -M <mode> \\r _damin_transient_enter)"
        else
            _damin_doctor_check "transient binding" ok
        end

        if set -qU _damin_in_transient
            if test "$_damin_doctor_fix" = 1
                set -eU _damin_in_transient
                _damin_doctor_check "transient state clean" ok '(erased leaked universal)'
            else
                _damin_doctor_check "transient state clean" fail "(_damin_in_transient leaked to universal scope — run: set -eU _damin_in_transient, or rerun with --fix)"
            end
        else
            _damin_doctor_check "transient state clean" ok
        end
    else
        _damin_doctor_check "transient prompt" ok "(disabled via theme_damin_transient=0)"
    end

    set -l sig $theme_damin_async_signal
    set -l non_damin
    for line in (functions --handlers-type signal 2>/dev/null)
        set -l parts (string split ' ' -- $line)
        test (count $parts) -ge 2 -a "$parts[1]" = "$sig"; or continue
        string match -q '_damin_*' -- $parts[2]; or set -a non_damin $parts[2]
    end
    if test (count $non_damin) -gt 0
        _damin_doctor_check "$sig handlers" fail "(non-damin: $non_damin — set theme_damin_async_signal differently then exec fish)"
    else
        _damin_doctor_check "$sig handlers" ok "(no non-damin collisions)"
    end

    # signal is captured at function-define time; toggle changes need exec fish.
    if set -q _damin_async_signal_loaded; and test "$_damin_async_signal_loaded" != "$theme_damin_async_signal"
        _damin_doctor_check "async signal capture" fail "(handler bound to $_damin_async_signal_loaded at load; current=$theme_damin_async_signal — exec fish to apply)"
    end

    if test "$theme_damin_notify_long_command" = 1
        if type -q notify-send
            _damin_doctor_check notify-send ok (command -v notify-send)
        else
            _damin_doctor_check notify-send fail '(theme_damin_notify_long_command=1 but notify-send missing — OSC 9 still fires)'
        end
    end

    if test "$theme_damin_show_gh_pr" = 1
        if type -q gh
            if command gh auth status >/dev/null 2>&1
                _damin_doctor_check 'gh cli' ok authenticated
            else
                _damin_doctor_check 'gh cli' fail '(installed but not authenticated — run: gh auth login)'
            end
        else
            _damin_doctor_check 'gh cli' fail '(theme_damin_show_gh_pr=1 but gh not on PATH)'
        end
    end

    if test "$theme_damin_show_k8s_context" = 1
        set -l cfg (_damin_k8s_config_path)
        if test -f $cfg
            _damin_doctor_check kubeconfig ok "($cfg)"
        else if set -q KUBERNETES_SERVICE_HOST
            _damin_doctor_check kubeconfig ok "(in-pod; bare 'k8s' indicator)"
        else
            _damin_doctor_check kubeconfig fail "($cfg unreadable; theme_damin_show_k8s_context=1)"
        end
    end

    if set -q TERM_PROGRAM; and test "$TERM_PROGRAM" = vscode
        _damin_doctor_check "VSCode terminal" fail "(VSCode injects its own OSC 633/133 — double-emission likely. set theme_damin_osc_integration=0 to silence damin's half)"
    end

    if test "$_damin_doctor_mode" = json
        printf ']\n'
    else
        echo
        echo "  font width sanity — each glyph should sit immediately before the |:"
        for c in ✿ ❥ ✗ ✓ ⇣ ⇡ ✧ · ?
            printf '    %s|\n' $c
        end
        echo "  (a '?' or visible gap before | = font is missing the glyph; enable ascii mode)"
    end
    set -e _damin_doctor_mode
    set -e _damin_doctor_first
    set -e _damin_doctor_fix
end

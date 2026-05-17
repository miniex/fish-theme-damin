function damin_doctor
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

    # accept any installed name (omf install → fish-theme-damin, local symlink → anything).
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

    # only OMF should leave this here (symlink → themes/<active>/). anything
    # else trips OMF's "Conflicting prompt setting" check.
    set -l user_fp ~/.config/fish/functions/fish_prompt.fish
    if not test -e $user_fp -o -L $user_fp
        _damin_doctor_check "fish_prompt symlink" ok "(none — fisher-style install)"
    else if functions -q omf
        set -l theme (command cat ~/.config/omf/theme 2>/dev/null)
        set -l want $omf_root/themes/$theme/fish_prompt.fish
        if test -L $user_fp; and contains -- (readlink $user_fp) $want
            _damin_doctor_check "fish_prompt symlink" ok "(omf → themes/$theme)"
        else
            _damin_doctor_check "fish_prompt symlink" fail "(target ≠ themes/$theme — fix: rm $user_fp; then omf theme $theme)"
        end
    else
        _damin_doctor_check "fish_prompt symlink" fail "($user_fp exists without omf — delete it: rm $user_fp)"
    end
    if test -e ~/.config/fish/functions/fish_right_prompt.fish
        _damin_doctor_check "no stray fish_right_prompt.fish" fail "(damin doesn't ship this — delete to avoid override)"
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
    else
        _damin_doctor_check "cache dir writable" fail
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
            _damin_doctor_check "transient state clean" fail "(_damin_in_transient leaked to universal scope — run: set -eU _damin_in_transient)"
        else
            _damin_doctor_check "transient state clean" ok
        end
    else
        _damin_doctor_check "transient prompt" ok "(disabled via theme_damin_transient=0)"
    end

    echo
    echo "  font width sanity — each glyph should sit immediately before the |:"
    for c in ✿ ❥ ✗ ✓ ⇣ ⇡ ✧ · ?
        printf '    %s|\n' $c
    end
    echo "  (a '?' or visible gap before | = font is missing the glyph; enable ascii mode)"
end

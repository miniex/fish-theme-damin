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

    if functions -q omf
        set -l theme (command cat ~/.config/omf/theme 2>/dev/null)
        if test "$theme" = fish-theme-damin
            _damin_doctor_check "omf active theme" ok "($theme)"
        else
            _damin_doctor_check "omf active theme" fail "(current: $theme — run: omf theme fish-theme-damin)"
        end
    end

    set -l prompt_src (functions --details fish_prompt 2>/dev/null)
    if test -z "$prompt_src" -o "$prompt_src" = n/a -o "$prompt_src" = stdin
        _damin_doctor_check "fish_prompt loaded" fail "(function not defined — theme not active)"
    else
        _damin_doctor_check "fish_prompt loaded" ok "($prompt_src)"
    end

    # damin defines prompts in conf.d/, so nothing should land in ~/.config/fish/functions/.
    # catch leftovers (old damin, manual installs, other plugins) that block omf activation.
    set -l strays
    for f in fish_prompt.fish fish_right_prompt.fish
        test -e ~/.config/fish/functions/$f; and set strays $strays $f
    end
    if test (count $strays) -gt 0
        _damin_doctor_check "no stray prompt files" fail "(found in ~/.config/fish/functions/: $strays — damin doesn't ship these; delete to unblock OMF theme switching)"
    else
        _damin_doctor_check "no stray prompt files" ok
    end

    set -l missing
    for cmd in damin_config damin_help damin_reset_cache
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
    for c in ✿ ❥ ✗ ✓ ⇣ ⇡ ✧ ?
        printf '    %s|\n' $c
    end
    echo "  (a '?' or visible gap before | = font is missing the glyph; enable ascii mode)"
end

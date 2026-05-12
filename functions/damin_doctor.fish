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
        if test "$theme" = damin
            _damin_doctor_check "omf active theme" ok "($theme)"
        else
            _damin_doctor_check "omf active theme" fail "(current: $theme — run: omf theme damin)"
        end
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

    echo
    echo "  font width sanity — each glyph should sit immediately before the |:"
    for c in ✿ ❥ ✗ ✓ ⇣ ⇡ ✧ ?
        printf '    %s|\n' $c
    end
    echo "  (a '?' or visible gap before | = font is missing the glyph; enable ascii mode)"
end

# preview <flavor> without applying. --all = stack every flavor for comparison.
function damin_palette_preview --argument-names flavor
    if contains -- "$flavor" --help -h
        _damin_help_block damin_palette_preview 'render a sample prompt in <flavor> without applying it' \
            'damin_palette_preview [<flavor>|--all]' \
            -- \
            'no arg -> current $theme_damin_palette.' \
            '--all -> stack every flavor for side-by-side comparison.'
        return
    end
    if test "$flavor" = --all
        # hoist flavor-independent set_color out of the loop.
        set -l c_dim (set_color --dim)
        set -l c_norm (set_color normal)
        set -l c_label (set_color E890B0 -o)
        for f in (_damin_palette_list)
            _damin_palette_preview_line $f $c_dim $c_norm $c_label
        end
        return
    end
    test -z "$flavor"; and set flavor $theme_damin_palette
    if not contains -- $flavor (_damin_palette_list)
        printf 'damin_palette_preview: unknown flavor: %s\n' $flavor >&2
        printf '  valid: %s\n' (string join ' ' -- (_damin_palette_list)) >&2
        return 1
    end
    _damin_palette_preview_line $flavor
end

function _damin_palette_preview_line --argument-names flavor c_dim c_norm c_label
    set -l accents (string split ' ' -- (_damin_palette_accents $flavor))
    set -l c_branch (set_color $accents[1])
    set -l c_meta (set_color $accents[2])
    set -l c_ok (set_color $accents[2] -o)
    # single-flavor callers don't pass hoisted colors; fill in defaults.
    test -z "$c_dim"; and set c_dim (set_color --dim)
    test -z "$c_norm"; and set c_norm (set_color normal)
    test -z "$c_label"; and set c_label (set_color E890B0 -o)
    set -l label $c_label$flavor$c_norm

    printf '  %-32s ' $label
    printf '%smain%s %s%s2%s %s%s3%s %s%s1%s  %s✿%s  ' \
        $c_branch $c_norm \
        $c_meta '?' $c_norm \
        $c_meta '✗' $c_norm \
        $c_meta '⇡' $c_norm \
        $c_ok $c_norm
    printf '%s❥%s %s~/proj%s %s· py:3.12%s\n' \
        $c_meta $c_norm \
        $c_branch $c_norm \
        $c_dim $c_norm
end

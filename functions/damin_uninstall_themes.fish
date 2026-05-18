function damin_uninstall_themes
    if contains -- "$argv[1]" --help -h
        _damin_help_block damin_uninstall_themes 'inverse of damin_install_themes — remove Damin .theme files' \
            damin_uninstall_themes
        return
    end
    set -l dest "$__fish_config_dir/themes"
    set -l matches $dest/Damin\ *.theme
    set -l n (count $matches)
    set -l pink (set_color E890B0 -o)
    set -l blue (set_color 98ABCC)
    set -l dim (set_color --dim)
    set -l norm (set_color normal)

    if test $n -eq 0
        printf '  %sno Damin *.theme files in %s%s\n' $dim $dest $norm
        return
    end

    printf '  %s✿%s will remove %d file(s) from %s%s%s:\n' $pink $norm $n $blue $dest $norm
    for f in $matches
        printf '    %s\n' (path basename $f)
    end
    read -P '  proceed? [y/N] ' -l ans
    switch (string lower -- $ans)
        case y yes
            for f in $matches
                command rm -f $f
            end
            printf '  removed %d.\n' $n
        case '*'
            printf '  canceled.\n'
            return 1
    end
end

function damin_install_themes
    set -l dest "$__fish_config_dir/themes"
    mkdir -p $dest

    set -l src
    if test -d $__fish_config_dir/conf.d -a -f $__fish_config_dir/conf.d/damin.fish
        set src (path resolve $__fish_config_dir/conf.d/../themes 2>/dev/null)
    end
    test -d "$src"; or set src (path resolve (status dirname)/../themes 2>/dev/null)
    test -d "$src"
    or begin
        printf '%scannot locate themes/ directory%s\n' (set_color red) (set_color normal) >&2
        return 1
    end

    set -l installed
    for f in $src/Damin*.theme
        set -l name (path basename $f)
        ln -sfn $f "$dest/$name"
        set -a installed $name
    end

    printf '  %s✿%s installed %d theme(s) to %s:\n' \
        (set_color E890B0 -o) (set_color normal) (count $installed) $dest
    for t in $installed
        printf '    %s\n' $t
    end
    printf '\n  preview / apply with %sfish_config theme show%s.\n' (set_color 98ABCC) (set_color normal)
end

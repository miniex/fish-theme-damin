# shared --help renderer. args: <name> <desc> <usage>... [-- <extra-dim-line>...]
function _damin_help_block
    set -l name $argv[1]
    set -l desc $argv[2]
    set -l rest $argv[3..]
    set -l usage_lines
    set -l extra_lines
    set -l in_extra 0
    for x in $rest
        if test "$x" = --
            set in_extra 1
            continue
        end
        test $in_extra = 1; and set -a extra_lines $x; or set -a usage_lines $x
    end
    set -l pink (set_color E890B0 -o)
    set -l blue (set_color 98ABCC)
    set -l dim (set_color --dim)
    set -l norm (set_color normal)
    printf '\n  %s%s%s — %s\n\n' $pink $name $norm $desc
    printf '  usage:\n'
    for line in $usage_lines
        printf '    %s%s%s\n' $blue $line $norm
    end
    if test (count $extra_lines) -gt 0
        echo
        for line in $extra_lines
            printf '  %s%s%s\n' $dim $line $norm
        end
    end
    echo
end

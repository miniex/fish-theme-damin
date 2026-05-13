# `[default]` for the default profile, `[profile <name>]` for the rest.
function _damin_aws_region_for --argument-names profile cfg
    test -f $cfg; or return
    set -l target
    if test "$profile" = default
        set target '[default]'
    else
        set target "[profile $profile]"
    end
    set -l in_section 0
    for line in (command cat $cfg 2>/dev/null)
        if string match -qr '^\[' -- $line
            test "$line" = "$target"; and set in_section 1; or set in_section 0
            continue
        end
        test $in_section = 1; or continue
        set -l m (string match -r '^region *= *(.*)$' -- $line)
        test (count $m) -ge 2; and echo (string trim -- $m[2]); and return
    end
end

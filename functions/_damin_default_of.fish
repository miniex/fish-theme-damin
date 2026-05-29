# default value (space-joined) of a theme_damin_<suffix> var, from _damin_defaults.
# empty if the var has no registry default (computed / unset-by-default vars).
function _damin_default_of --argument-names var
    set -l suffix (string replace 'theme_damin_' '' -- $var)
    for spec in (_damin_defaults)
        set -l parts (string split ' ' -- $spec)
        if test "$parts[1]" = "$suffix"
            echo (string join ' ' -- $parts[2..])
            return
        end
    end
end

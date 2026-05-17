function fish_title
    set -l in_ssh 0
    test -n "$SSH_CONNECTION$SSH_CLIENT$SSH_TTY"; and set in_ssh 1

    set -l parts

    set -l want_user 0
    switch "$theme_damin_title_show_user"
        case 1 yes always
            set want_user 1
        case ssh
            test $in_ssh = 1; and set want_user 1
    end
    if test $want_user = 1
        set -l u $USER
        test -z "$u"; and set u (command id -un 2>/dev/null)
        set -l h (command hostname 2>/dev/null | string trim)
        test -z "$h"; and set h localhost
        if test -n "$u"
            set -a parts "$u@$h"
        else
            set -a parts $h
        end
    end

    switch "$theme_damin_title_show_path"
        case 1 yes always
            set -a parts (prompt_pwd --dir-length=0 --full-length-dirs=99 2>/dev/null)
        case short
            set -a parts (prompt_pwd 2>/dev/null)
    end

    if test "$theme_damin_title_show_process" = 1
        # $argv = running command (empty when idle).
        set -l proc (string trim -- "$argv")
        test -n "$proc"; and set -a parts "— $proc"
    end

    string join ' ' -- $parts
end

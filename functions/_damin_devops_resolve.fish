# pwd-cached single walk-up; exits early once both segments resolve.
function _damin_devops_resolve
    test "$_damin_devops_pwd" = "$PWD"; and return
    set -g _damin_devops_pwd "$PWD"
    set -g _damin_devops_tf ""
    set -g _damin_devops_pl ""
    set -l want_tf 0
    set -l want_pl 0
    test "$theme_damin_show_terraform" = 1; and set want_tf 1
    test "$theme_damin_show_pulumi" = 1; and set want_pl 1
    test $want_tf = 0 -a $want_pl = 0; and return

    set -l dir $PWD
    set -l levels 0
    while test "$dir" != / -a $levels -lt 8
        if test $want_tf = 1 -a -d "$dir/.terraform"
            set -l env "$dir/.terraform/environment"
            if test -f $env
                set -l ws (command cat $env 2>/dev/null | string trim)
                test -n "$ws" -a "$ws" != default; and set -g _damin_devops_tf "$ws"
            end
            set want_tf 0
        end
        if test $want_pl = 1
            if test -f "$dir/Pulumi.yaml" -o -f "$dir/Pulumi.yml"
                set -g _damin_devops_pl (_damin_pulumi_stack_for $dir)
                set want_pl 0
            end
        end
        test $want_tf = 0 -a $want_pl = 0; and break
        set dir (path dirname $dir)
        set levels (math $levels + 1)
    end
end

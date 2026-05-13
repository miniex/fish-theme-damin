# $PULUMI_STACK wins; else read workspace file iff exactly one matches the project name
# (the *-<hash>-workspace.json suffix isn't reverse-engineerable from the path).
function _damin_pulumi_stack_for --argument-names proj_dir
    set -l proj_name
    for yaml in $proj_dir/Pulumi.yaml $proj_dir/Pulumi.yml
        test -f $yaml; or continue
        for line in (command cat $yaml 2>/dev/null)
            set -l m (string match -r '^name: *(.*)$' -- $line)
            if test (count $m) -ge 2
                set proj_name (string trim --chars '"' -- $m[2])
                break
            end
        end
        test -n "$proj_name"; and break
    end
    test -n "$proj_name"; or return

    set -q PULUMI_STACK; and test -n "$PULUMI_STACK"; and echo $PULUMI_STACK; and return

    set -l home_pulumi "$HOME/.pulumi"
    set -q PULUMI_HOME; and test -n "$PULUMI_HOME"; and set home_pulumi $PULUMI_HOME
    set -l ws_dir "$home_pulumi/workspaces"
    test -d $ws_dir; or return

    set -l matches
    for f in $ws_dir/$proj_name-*-workspace.json
        test -f $f; and set -a matches $f
    end
    test (count $matches) -eq 1; or return
    set -l stack (command cat $matches[1] 2>/dev/null | string match -gr '"stack":\s*"([^"]+)"' | head -1)
    test -n "$stack"; and echo $stack
end

# _damin_profile_now_ms lives in its own autoload file (shared with damin_bench).

function damin_profile
    if contains -- "$argv[1]" --help -h
        _damin_help_block damin_profile 'per-segment mean render time (means only)' \
            'damin_profile [N] [--json]' \
            -- \
            'N      iterations per segment (default 20)' \
            '--json emit single-line JSON for CI comparison' \
            'for P50/P95/P99 distribution see: damin_bench --help.'
        return
    end
    set -l runs 20
    set -l json 0
    for arg in $argv
        switch $arg
            case --json
                set json 1
            case '*'
                string match -rq '^[0-9]+$' -- $arg; and set runs $arg
        end
    end

    set -l pink (set_color E890B0 -o)
    set -l blue (set_color 98ABCC)
    set -l dim (set_color --dim)
    set -l norm (set_color normal)

    if test $json = 0
        printf '\n  %s✿ damin · profile%s  %sruns=%d  pwd=%s%s\n\n' \
            $pink $norm $dim $runs $PWD $norm
    else
        printf '{"runs":%d,"pwd":"%s","segments":[' $runs $PWD
    end

    set -l segments \
        context _damin_context_render \
        vcs _damin_vcs_render \
        jobs _damin_jobs_render \
        vi_mode _damin_vi_mode_render \
        lang _damin_lang_render \
        devops _damin_devops_render \
        env _damin_env_render \
        battery _damin_battery_render \
        duration _damin_duration_render

    set -l total_ms 0
    set -l first 1
    set -l i 1
    while test $i -le (count $segments)
        set -l name $segments[$i]
        set -l fn $segments[(math $i + 1)]
        set i (math $i + 2)
        functions -q $fn; or continue

        set -l t0 (_damin_profile_now_ms)
        for r in (seq $runs)
            $fn >/dev/null 2>&1
        end
        set -l t1 (_damin_profile_now_ms)
        set -l total (math "$t1 - $t0")
        set -l per (math --scale=2 "$total / $runs")
        set total_ms (math --scale=2 "$total_ms + $per")

        if test $json = 1
            test $first = 0; and printf ,
            printf '{"name":"%s","per_ms":%s,"total_ms":%d}' $name $per $total
            set first 0
        else
            printf '  %s%-12s%s  %s%9s ms/render%s  %s(%d ms · %d runs)%s\n' \
                $blue $name $norm $pink $per $norm $dim $total $runs $norm
        end
    end

    if test $json = 1
        printf '],"sum_ms":%s}\n' $total_ms
    else
        printf '\n  %ssum:%s %s%s ms/prompt%s\n\n' $dim $norm $pink $total_ms $norm
    end
end

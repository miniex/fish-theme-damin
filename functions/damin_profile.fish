# GNU `date %N` gives ns; BSD silently drops it — fall through to gdate/python3/perl.
# Divide via string-slice (drop trailing 6 digits) because fish math is f64 and
# loses precision on 19-digit ns values.
function _damin_profile_now_ms
    set -l n (command date +%s%N 2>/dev/null)
    if string match -rq '^[0-9]{13,}$' -- $n
        echo (string sub --end -6 -- $n)
        return
    end
    set n (command gdate +%s%N 2>/dev/null)
    if string match -rq '^[0-9]{13,}$' -- $n
        echo (string sub --end -6 -- $n)
        return
    end
    if command -q python3
        echo (command python3 -c 'import time; print(int(time.time()*1000))' 2>/dev/null)
        return
    end
    if command -q perl
        echo (command perl -MTime::HiRes=time -e 'printf("%d\n", time()*1000)' 2>/dev/null)
        return
    end
    echo (math (command date +%s) "*" 1000)
end

function damin_profile
    if contains -- "$argv[1]" --help -h
        _damin_help_block damin_profile 'per-segment mean render time (means only)' \
            'damin_profile [N]' \
            -- \
            'N      iterations per segment (default 20)' \
            'for P50/P95/P99 distribution see: damin_bench --help.'
        return
    end
    set -l runs 20
    if test (count $argv) -ge 1
        if string match -rq '^[0-9]+$' -- $argv[1]
            set runs $argv[1]
        end
    end

    set -l pink (set_color E890B0 -o)
    set -l blue (set_color 98ABCC)
    set -l dim (set_color --dim)
    set -l norm (set_color normal)

    printf '\n  %s✿ damin · profile%s  %sruns=%d  pwd=%s%s\n\n' \
        $pink $norm $dim $runs $PWD $norm

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
    set -l i 1
    while test $i -le (count $segments)
        set -l name $segments[$i]
        set -l fn $segments[(math $i + 1)]
        if functions -q $fn
            set -l t0 (_damin_profile_now_ms)
            for r in (seq $runs)
                $fn >/dev/null 2>&1
            end
            set -l t1 (_damin_profile_now_ms)
            set -l total (math "$t1 - $t0")
            set -l per (math --scale=2 "$total / $runs")
            set total_ms (math --scale=2 "$total_ms + $per")
            printf '  %s%-12s%s  %s%9s ms/render%s  %s(%d ms · %d runs)%s\n' \
                $blue $name $norm $pink $per $norm $dim $total $runs $norm
        else
            printf '  %s%-12s%s  %s(not defined)%s\n' $blue $name $norm $dim $norm
        end
        set i (math $i + 2)
    end

    printf '\n  %ssum:%s %s%s ms/prompt%s\n\n' $dim $norm $pink $total_ms $norm
end

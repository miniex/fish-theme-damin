# diff two --json outputs and print Δ ms / % per segment + total. needs python3.
function _damin_bench_compare
    set -l base
    set -l head
    set -l i 1
    while test $i -le (count $argv)
        if test "$argv[$i]" = --compare
            set base $argv[(math $i + 1)]
            set head $argv[(math $i + 2)]
            break
        end
        set i (math $i + 1)
    end
    if test -z "$base" -o -z "$head"
        printf 'damin_bench --compare: needs BASE.json HEAD.json\n' >&2
        return 1
    end
    if not test -f $base; or not test -f $head
        printf 'damin_bench --compare: BASE or HEAD file missing\n' >&2
        return 1
    end
    if not command -q python3
        printf 'damin_bench --compare: python3 required\n' >&2
        return 1
    end
    # python script as a single -c arg (fish has no heredoc syntax).
    set -l py 'import json,sys
b=json.load(open(sys.argv[1]))["segments"]
h=json.load(open(sys.argv[2]))["segments"]
bm={s["name"]:float(s["p50"]) for s in b}
hm={s["name"]:float(s["p50"]) for s in h}
names=list(dict.fromkeys(list(bm)+list(hm)))
print(f"  {\'segment\':<12}  {\'base p50\':>10}  {\'head p50\':>10}  {\'Δ ms\':>10}  {\'Δ %\':>8}")
print("  "+"-"*60)
tb=th=0.0
for n in names:
    bp=bm.get(n,0.0); hp=hm.get(n,0.0); tb+=bp; th+=hp
    d=hp-bp; pct=(d/bp*100) if bp else 0.0
    s="+" if d>0 else ""
    print(f"  {n:<12}  {bp:>10.3f}  {hp:>10.3f}  {s}{d:>9.3f}  {s}{pct:>7.1f}")
print("  "+"-"*60)
d=th-tb; pct=(d/tb*100) if tb else 0.0
s="+" if d>0 else ""
print(f"  {\'p50 sum\':<12}  {tb:>10.3f}  {th:>10.3f}  {s}{d:>9.3f}  {s}{pct:>7.1f}")'
    command python3 -c "$py" $base $head
end

# per-segment P50/P95/P99. complements damin_profile (means only).
# usage: `damin_bench [N=1000] [--json] [--cold] [--compare BASE HEAD]`.
# each sample = mean of BATCH runs so the 1ms timer doesn't swallow sub-ms segments.
function damin_bench
    if contains -- "$argv[1]" --help -h
        _damin_help_block damin_bench 'per-segment P50/P95/P99 timing distribution' \
            'damin_bench [N] [--json] [--cold]' \
            'damin_bench --compare BASE.json HEAD.json' \
            -- \
            'N        iterations (default 1000, batched in groups of 50)' \
            '--json   emit single-line JSON for CI comparison' \
            '--cold   wipe caches before each segment, N=1, no warmup (cold-path regress check)' \
            '--compare diff two --json outputs and emit Δ ms / %'
        return
    end
    if contains -- --compare $argv
        _damin_bench_compare $argv
        return $status
    end
    set -l runs 1000
    set -l batch 50
    set -l json 0
    set -l cold 0
    for arg in $argv
        switch $arg
            case --json
                set json 1
            case --cold
                set cold 1
            case '*'
                string match -rq '^[0-9]+$' -- $arg; and set runs $arg
        end
    end
    if test $cold = 1
        set runs 1
        set batch 1
    end
    test $runs -lt $batch; and set batch $runs
    set -l num_batches (math --scale=0 "$runs / $batch")

    set -l pink (set_color E890B0 -o)
    set -l blue (set_color 98ABCC)
    set -l dim (set_color --dim)
    set -l norm (set_color normal)

    if test $json = 0
        printf '\n  %s✿ damin · bench%s  %sruns=%d (×%d batches of %d)  pwd=%s%s\n\n' \
            $pink $norm $dim $runs $num_batches $batch $PWD $norm
        printf '  %-12s  %12s  %12s  %12s  %12s\n' segment min p50 p95 p99
        printf '  %s%s%s\n' $dim (string repeat -n 70 -) $norm
    else
        printf '{"runs":%d,"batches":%d,"pwd":"%s","segments":[' $runs $num_batches $PWD
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
        duration _damin_duration_render \
        prompt fish_prompt \
        right_prompt fish_right_prompt

    set -l first 1
    set -l p50_sum 0
    set -l i 1
    while test $i -le (count $segments)
        set -l name $segments[$i]
        set -l fn $segments[(math $i + 1)]
        set i (math $i + 2)
        functions -q $fn; or continue

        if test $cold = 0
            # warmup so cold-cache miss doesn't skew batch 1.
            for r in (seq 5)
                $fn >/dev/null 2>&1
            end
        end

        set -l samples
        for b in (seq $num_batches)
            # --cold: drop every cache + memo between samples to surface cold-path cost.
            if test $cold = 1
                command rm -rf $_damin_cache_dir 2>/dev/null
                damin_reset_cache >/dev/null 2>&1
            end
            set -l t0 (_damin_profile_now_ms)
            for r in (seq $batch)
                $fn >/dev/null 2>&1
            end
            set -l t1 (_damin_profile_now_ms)
            set -a samples (math --scale=3 "($t1 - $t0) / $batch")
        end

        set -l sorted (printf '%s\n' $samples | sort -n)
        set -l n (count $sorted)
        set -l min $sorted[1]
        set -l p50 $sorted[(math --scale=0 "ceil($n * 0.50)")]
        set -l p95 $sorted[(math --scale=0 "ceil($n * 0.95)")]
        set -l p99 $sorted[(math --scale=0 "ceil($n * 0.99)")]
        set p50_sum (math --scale=3 "$p50_sum + $p50")

        if test $json = 1
            test $first = 0; and printf ,
            printf '{"name":"%s","min":%s,"p50":%s,"p95":%s,"p99":%s}' \
                $name $min $p50 $p95 $p99
            set first 0
        else
            printf '  %s%-12s%s  %s%9s ms%s  %s%9s ms%s  %s%9s ms%s  %s%9s ms%s\n' \
                $blue $name $norm $dim $min $norm $pink $p50 $norm $pink $p95 $norm $pink $p99 $norm
        end
    end

    if test $json = 1
        printf '],"p50_sum":%s}\n' $p50_sum
    else
        printf '\n  %sp50 sum:%s %s%s ms/prompt%s\n\n' $dim $norm $pink $p50_sum $norm
    end
end

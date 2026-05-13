function _damin_k8s_render
    set -l cfg (_damin_k8s_config_path)
    set -l in_pod 0
    set -q KUBERNETES_SERVICE_HOST; and set in_pod 1

    set -l ctx ""
    set -l ns ""

    if test -f $cfg
        set -l mt (path mtime $cfg 2>/dev/null)
        if test "$mt" = "$_damin_k8s_mt"
            set ctx $_damin_k8s_ctx
            set ns $_damin_k8s_ns
        else
            set -l used_cache 0
            set -l cache "$_damin_cache_dir/cloud-k8s"
            if test -f $cache
                set -l lines (_damin_read_lines $cache)
                if test (count $lines) -ge 1 -a "$lines[1]" = "$mt"
                    test (count $lines) -ge 2; and set ctx $lines[2]
                    test (count $lines) -ge 3; and set ns $lines[3]
                    set used_cache 1
                end
            end
            if test $used_cache = 0
                set -l data (_damin_k8s_compute $cfg)
                test (count $data) -ge 1; and set ctx $data[1]
                test (count $data) -ge 2; and set ns $data[2]
                mkdir -p $_damin_cache_dir 2>/dev/null
                set -l tmp "$cache.tmp.$fish_pid"
                printf '%s\n%s\n%s\n' "$mt" "$ctx" "$ns" >$tmp 2>/dev/null
                mv $tmp $cache 2>/dev/null
            end
            set -g _damin_k8s_mt $mt
            set -g _damin_k8s_ctx $ctx
            set -g _damin_k8s_ns $ns
        end
    end

    test -n "$ctx" -o $in_pod = 1; or return

    set -l label k8s
    test "$theme_damin_show_k8s_context" = 1 -a -n "$ctx"; and set label "$label:$ctx"
    test "$theme_damin_show_k8s_namespace" = 1 -a -n "$ns"; and set label "$label/$ns"
    echo -n -s $_damin_c_dim "$label " $_damin_c_normal
end

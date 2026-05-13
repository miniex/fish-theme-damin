# disk cache (mtime|ctx|ns) so cold-start skips the kubeconfig yaml walk.
function _damin_k8s_prefill
    set -l cfg (_damin_k8s_config_path)
    test -f $cfg; or return
    set -l mt (path mtime $cfg 2>/dev/null)
    test -n "$mt"; or return
    set -l cache "$_damin_cache_dir/cloud-k8s"
    if test -f $cache
        set -l lines (_damin_read_lines $cache)
        test (count $lines) -ge 1 -a "$lines[1]" = "$mt"; and return
    end
    set -l data (_damin_k8s_compute $cfg)
    set -l ctx ""
    set -l ns ""
    test (count $data) -ge 1; and set ctx $data[1]
    test (count $data) -ge 2; and set ns $data[2]
    mkdir -p $_damin_cache_dir 2>/dev/null
    set -l tmp "$cache.tmp.$fish_pid"
    printf '%s\n%s\n%s\n' "$mt" "$ctx" "$ns" >$tmp 2>/dev/null
    mv $tmp $cache 2>/dev/null
end
